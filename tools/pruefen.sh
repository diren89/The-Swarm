#!/usr/bin/env bash
# Prüfskript-Vorlage: führt Befehle aus, Langausgabe je Befehl in eine Datei, Kurzausgabe auf der Konsole.
# Aufruf:  pruefen.sh [-l LOGORDNER] [-d ARBEITSORDNER] [-w REGEX] [-t] 'befehl 1' 'befehl 2' ...
#   -l  Logordner (Standard: .agent/work/pruefen); jeder Lauf legt darin einen eigenen Unterordner an
#       (Zeitstempel-PID), frühere Läufe bleiben erhalten.
#   -d  Arbeitsordner, in dem die Befehle laufen (Standard: aktueller Ordner)
#   -w  Warnmuster (egrep, ohne Groß-/Kleinschreibung) für das Log.
#       Standard: (^|[^a-z])(warning|warnung|error|traceback). Treffer bei Exit 0 => WARN (zählt nicht als PASS).
#   -t  Tests erwartet: wird keine Testzahl erkannt oder ist sie 0 => FAIL. Gilt für ALLE Befehle des Aufrufs
#       (Test- und Nicht-Test-Befehle getrennt aufrufen).
# Testzahl = ausgeführte Tests (übersprungene zählen nicht), erkannt aus: "Ran N tests" (unittest), "N passed/failed/…" (pytest), "Tests: N total" / "Tests N" (jest/vitest).
# Ausgabe je Befehl:  OK|WARN|FAIL <exit> tests=<N|-> warn=<Treffer> <befehl> (<letzte Zeile>)
# Zum Schluss:        n/m PASS, w WARN, f FAIL (Logs: <Lauf-Ordner>)   Exit 0 nur, wenn alle Befehle OK sind.
# Maßgeblich ist der Exitcode des Befehls selbst (Läufe mit `-o pipefail`). Keine eigene Filterpipeline wie
# 'befehl | grep warning && exit 1 || exit 0' um den Befehl bauen: das verdeckt Fehler. Warnungen erkennt -w.
log=.agent/work/pruefen; dir=.; warn='(^|[^a-z])(warn(ing)?|warnung|error|traceback)'; need_tests=0
while getopts "l:d:w:t" o; do case $o in l) log=$OPTARG;; d) dir=$OPTARG;; w) warn=$OPTARG;; t) need_tests=1;; *) exit 2;; esac; done
shift $((OPTIND-1))
[ $# -gt 0 ] || { echo "Aufruf: pruefen.sh [-l LOGORDNER] [-d ORDNER] [-w REGEX] [-t] 'befehl' ..." >&2; exit 2; }
case $log in /*) ;; *) log=$PWD/$log;; esac
run="$log/$(date +%Y%m%d-%H%M%S)-$$"
mkdir -p "$run" || exit 2
cd "$dir" || exit 2

count_tests() { # Testzahl aus Log $1 oder leer
  local f=$1 n line
  n=$(grep -E '^Ran [0-9]+ tests? in' "$f" | tail -n 1 | awk '{print $2}')
  if [ -n "$n" ]; then # unittest: übersprungene abziehen
    local sk; sk=$(grep -oE 'skipped=[0-9]+' "$f" | tail -n 1 | cut -d= -f2)
    n=$(( n - ${sk:-0} )); [ "$n" -lt 0 ] && n=0   # Subtests: skipped kann > Ran sein; fail-safe auf 0
    echo "$n"; return
  fi
  line=$(grep -E '^[[:space:]]*Tests:?[[:space:]]+[0-9]' "$f" | tail -n 1)
  if [ -n "$line" ]; then
    n=$(echo "$line" | sed -nE 's/.*[^0-9]([0-9]+) total.*/\1/p')
    [ -z "$n" ] && n=$(echo "$line" | sed -nE 's/.*\(([0-9]+)\)[^()]*$/\1/p')
    [ -z "$n" ] && n=$(echo "$line" | sed -nE 's/^[^0-9]*([0-9]+).*/\1/p')
    echo "$n"; return
  fi
  line=$(grep -E '[0-9]+ (passed|failed|errors?|skipped)' "$f" | tail -n 1)
  [ -n "$line" ] && echo "$line" | grep -oE '[0-9]+ (passed|failed|errors?|xfailed|xpassed)' | awk '{s+=$1} END{print s}'
}

n=0; ok=0; nw=0; nf=0
for cmd in "$@"; do
  n=$((n+1)); f=$(printf '%s/%02d.log' "$run" "$n")
  bash -o pipefail -c "$cmd" >"$f" 2>&1; rc=$?
  last=$(grep -v '^[[:space:]]*$' "$f" | tail -n 1 | cut -c1-160)
  w=$(grep -Eic -- "$warn" "$f"); w=${w:-0}
  t=$(count_tests "$f")
  if [ $rc -ne 0 ]; then s=FAIL
  elif [ "$need_tests" -eq 1 ] && { [ -z "$t" ] || [ "$t" -eq 0 ]; }; then s=FAIL
  elif [ "$w" -gt 0 ]; then s=WARN
  else s=OK; fi
  case $s in OK) ok=$((ok+1));; WARN) nw=$((nw+1));; FAIL) nf=$((nf+1));; esac
  echo "$s $rc tests=${t:--} warn=$w $cmd (${last:-keine Ausgabe})"
done
echo "$ok/$n PASS, $nw WARN, $nf FAIL (Logs: $run)"
[ "$ok" -eq "$n" ]
