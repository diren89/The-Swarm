#!/usr/bin/env bash
# The Swarm, optionales Beispiel: Gate A "Geheimnis-Scan vor Commit" (Claude Code, Ereignis PreToolUse, Matcher Bash).
# Liest das Hook-JSON von stdin. Greift nur, wenn der Bash-Befehl ein `git commit` ist; sonst Exit 0 ohne Ausgabe.
# Prüft die zum Commit vorgemerkten Änderungen (`git diff --cached`) und immer auch die noch nicht vorgemerkten
# Änderungen verfolgter Dateien (`git diff`; ein Commit mit Pfad, -a, -o oder -i übernimmt den Arbeitsbaum-Inhalt)
# auf typische Geheimnis-Muster. Jede Git-Abfrage wird auf Fehler geprüft; bei Fehler Exit 2.
# Nur lokale Standardwerkzeuge (bash, git, grep, sed), kein jq, kein Netzwerk, kein Download.
# Exitcodes: 0 = durchlassen, 2 = blockieren (Meldung auf stderr geht an Claude).
# FAIL-CLOSED: Fehlt git, schlägt eine Git-Abfrage fehl oder bricht dieses Skript unerwartet ab, wird der Commit
# blockiert (Exit 2), nicht durchgelassen.
# Bewusst übersteuern: Zeile mit der Markierung  geheimnis-scan:ok  versehen (Falsch-Positiv), oder die Nutzerin
# setzt beim Sitzungsstart  THE_SWARM_GEHEIMNIS_SCAN=aus  (schaltet das Gate ab).
# Grenzen: Mustersuche findet nicht alles und meldet auch Harmloses; kein Ersatz für die Veröffentlichungsprüfung
# (playbooks/sicherheit.md). Siehe README.md in beispiele/claude-code/.
set -u

[ "${THE_SWARM_GEHEIMNIS_SCAN:-an}" = "aus" ] && exit 0

tmp=""
# Fail-closed: jeder Ausgang außer 0 und 2 (Absturz, Fehler beim Aufräumen usw.) wird zu 2.
beenden() {
  rc=$?
  [ -n "$tmp" ] && rm -f "$tmp" "$tmp".*
  if [ "$rc" -ne 0 ] && [ "$rc" -ne 2 ]; then
    echo "Geheimnis-Scan: unerwarteter Fehler (Exit $rc). Commit sicherheitshalber blockiert (fail-closed)." >&2
    exit 2
  fi
}
trap beenden EXIT

input=$(cat) || exit 2
[ -n "$input" ] || exit 0

# Befehl aus dem JSON holen (ohne jq); gelingt das nicht, wird das ganze JSON geprüft.
cmd=$(printf '%s' "$input" | sed -nE 's/.*"command"[[:space:]]*:[[:space:]]*"(([^"\\]|\\.)*)".*/\1/p' | head -n 1)
[ -n "$cmd" ] || cmd=$input
# Im JSON stehen Zeilenumbrüche als \n: als Trenner behandeln, damit "git commit" nach einer Zeile erkannt wird.
cmd=$(printf '%s' "$cmd" | sed 's/\\n/ ; /g')

# Nur git commit, auch mit Optionen vor dem Unterbefehl (git -c x=y commit, git --no-pager commit). Als Optionen vor `commit` gelten
# nur Wörter mit führendem `-` und die Werte von -c, -C und --git-dir/--work-tree/--namespace/--exec-path; so trifft
# `git log --grep commit` nicht. Nach `commit` sind Leerraum, Zeilenende, Backslash und die Shell-Trenner ; | & ) ` erlaubt
# (git commit; ..., git commit|cat, (git commit)). `git commit-tree` trifft nicht.
GIT_COMMIT='(^|[^[:alnum:]_./-])git([[:space:]]+(-[cC][[:space:]]+[^[:space:];&|]+|--(git-dir|work-tree|namespace|exec-path)[[:space:]]+[^[:space:];&|]+|-[^[:space:];&|]*))*[[:space:]]+commit([[:space:];&|)`\\]|$)'
printf '%s' "$cmd" | grep -Eq "$GIT_COMMIT" || exit 0

command -v git >/dev/null 2>&1 || { echo "Geheimnis-Scan: git nicht gefunden, Scan nicht möglich. Commit blockiert (fail-closed)." >&2; exit 2; }

# Zielordner unklar: der Scan liest den Ordner, in dem der Hook läuft, nicht den im Befehl genannten.
if printf '%s' "$cmd" | grep -Eq '(^|[^[:alnum:]_./-])cd[[:space:]]|git[[:space:]]+([^;&|]*[[:space:]])?(-C|--git-dir|--work-tree)([[:space:]=]|$)'; then
  echo "Geheimnis-Scan: Der Befehl wechselt den Ordner (cd, -C, --git-dir, --work-tree); der Scan kann das Ziel-Repo nicht sicher bestimmen. Commit blockiert (fail-closed). Bitte im Repo-Ordner ohne cd/-C committen." >&2
  exit 2
fi

# Kein Repo: ein Commit wäre ohnehin nicht möglich. Jeder andere Fehler der Abfrage blockiert (fail-closed).
rp_err=$(LC_ALL=C git rev-parse --is-inside-work-tree 2>&1 >/dev/null); rp_rc=$?
if [ "$rp_rc" -ne 0 ]; then
  case "$rp_err" in
    *"not a git repository"*) exit 0 ;;
  esac
  echo "Geheimnis-Scan: git rev-parse fehlgeschlagen (Exit $rp_rc), Scan nicht möglich. Commit blockiert (fail-closed)." >&2
  exit 2
fi

tmp=$(mktemp "${TMPDIR:-/tmp}/swarm-scan.XXXXXX") || exit 2

# Muster (ERE). Namen und Muster stehen an gleicher Stelle. Die Muster sind so gebaut, dass sie ihren eigenen Quelltext nicht treffen.
NAMEN=(
  "Kopf eines privaten Schlüssels"
  "Zugangsschlüssel-Kennung (AWS-Form)"
  "Token mit gängigem Präfix (GitHub, Slack, Google, sk-)"
  "JSON Web Token"
  "Zugangsdaten in einer Adresse"
  "Zuweisung mit Geheimnis-Name (password, secret, api key, ...)"
)
MUSTER=(
  '-----BEGIN ([A-Z0-9]+ )*PRIVATE KEY( BLOCK)?-----'
  '(^|[^A-Za-z0-9])(AKIA|ASIA)[0-9A-Z]{16}([^A-Za-z0-9]|$)'
  '(^|[^A-Za-z0-9])(gh[pousr]_[A-Za-z0-9]{36,}|github_pat_[A-Za-z0-9_]{20,}|xox[abprs]-[A-Za-z0-9-]{10,}|AIza[0-9A-Za-z_-]{35}|sk-[A-Za-z0-9_-]{20,})'
  '(^|[^A-Za-z0-9_-])eyJ[A-Za-z0-9_-]{10,}\.eyJ[A-Za-z0-9_-]{10,}\.'
  '://[^/[:space:]:@]+:[^/[:space:]@]{3,}@'
  '(password|passwd|secret|api[_-]?key|access[_-]?key|private[_-]?key|(auth|access|api|bearer)[_-]?token)[[:space:]]*(=|:=|:[[:space:]]*["'"'"'])[[:space:]]*["'"'"']?[A-Za-z0-9/+_.=~-]{8,}'
)

gefunden=0
MELDUNG=""

# Jede Git-Abfrage und jeder Lesezugriff wird auf Fehler geprüft (kein Verschlucken in Pipelines oder Prozesssubstitution).
fehler() {
  echo "Geheimnis-Scan: $1 fehlgeschlagen, Scan nicht vollständig möglich. Commit blockiert (fail-closed)." >&2
  exit 2
}

# git-Abfrage $2... mit Ausgabe nach Datei $1; Exit ungleich 0 blockiert.
git_nach() {
  ziel=$1
  shift
  git "$@" > "$ziel" 2>/dev/null || fehler "git $*"
}

# grep mit Dateiargument: 0 und 1 (kein Treffer) sind in Ordnung, alles andere ist ein Fehler.
grep_ok() { [ "$1" -le 1 ] || fehler "Lesen oder Filtern"; }

# Prüft die gesammelten Zeilen in $tmp; $1 = Anzeigename der Quelle.
pruefe() {
  grep -v -F 'geheimnis-scan:ok' "$tmp" > "$tmp.k" 2>/dev/null
  grep_ok $?
  mv "$tmp.k" "$tmp" || fehler "Zwischenspeichern"
  i=0
  while [ "$i" -lt "${#MUSTER[@]}" ]; do
    grep -Eiq -e "${MUSTER[$i]}" "$tmp" 2>/dev/null
    r=$?
    grep_ok "$r"
    if [ "$r" -eq 0 ]; then
      gefunden=1
      MELDUNG="$MELDUNG  - $1: ${NAMEN[$i]}"$'\n'
    fi
    i=$((i + 1))
  done
}

# Hinzugefügte Zeilen eines Diffs (Datei $tmp.d, ohne Kopfzeilen) nach $tmp.
hinzugefuegt() {
  grep -E '^\+' "$tmp.d" > "$tmp.p" 2>/dev/null
  grep_ok $?
  grep -v -E '^\+\+\+ ' "$tmp.p" > "$tmp" 2>/dev/null
  grep_ok $?
}

# 1. Vorgemerkte Änderungen (Index gegen HEAD).
git_nach "$tmp.n" diff --cached --name-only -z --diff-filter=ACMR
while IFS= read -r -d '' f; do
  git_nach "$tmp.d" diff --cached -U0 --no-color --no-ext-diff -- "$f"
  hinzugefuegt
  pruefe "$f (vorgemerkt)"
done < "$tmp.n"

# 2. Immer auch ungestagte Änderungen verfolgter Dateien (Arbeitsbaum gegen Index): ein Commit mit Pfad (git commit -- datei,
#    git commit datei, -o/--only, -i/--include) oder -a übernimmt deren Arbeitsbaum-Inhalt, nicht den Index. Das prüft eher zu viel als zu wenig.
git_nach "$tmp.n" diff --name-only -z --diff-filter=ACMR
while IFS= read -r -d '' f; do
  git_nach "$tmp.d" diff -U0 --no-color --no-ext-diff -- "$f"
  hinzugefuegt
  pruefe "$f (geändert, noch nicht vorgemerkt)"
done < "$tmp.n"

# 3. Der Befehl merkt selbst neue Dateien vor (git add ..., commit -a/--all): dann auch neue, unverfolgte Dateien prüfen.
if printf '%s' "$cmd" | grep -Eq 'git[[:space:]]+([^;&|]*[[:space:]])?add([[:space:]]|$)|(^|[[:space:]])--all([[:space:]]|$)|(^|[[:space:]])-[A-Za-z]*a[A-Za-z]*([[:space:]]|$)'; then
  git_nach "$tmp.n" ls-files -z --others --exclude-standard
  while IFS= read -r -d '' f; do
    [ -f "$f" ] || continue
    grep -I -s '' "$f" > "$tmp"
    grep_ok $?
    pruefe "$f (neu)"
  done < "$tmp.n"
fi

if [ "$gefunden" -eq 1 ]; then
  {
    echo "Geheimnis-Scan: Commit blockiert. Mögliche Geheimnisse (nur Datei und Art, nicht der Wert):"
    printf '%s' "$MELDUNG"
    echo "Echte Geheimnisse aus dem Commit entfernen und als offengelegt behandeln (rotieren). Falsch-Positiv: Zeile mit der Markierung geheimnis-scan:ok versehen; die Nutzerin kann das Gate bewusst abschalten (THE_SWARM_GEHEIMNIS_SCAN=aus beim Sitzungsstart)."
  } >&2
  exit 2
fi
exit 0
