#!/usr/bin/env bash
# Selbsttest skills-status.sh (Wegwerf-Ordner unter mktemp, keine Netzaufrufe, echtes HOME bleibt unberührt)
# Aufruf: bash tools/test-skills-status.sh     Exit 0 nur, wenn alle Fälle bestehen.
S="$(cd "$(dirname "$0")" && pwd)/skills-status.sh"
BASH_BIN="$(command -v bash)"; PY_BIN="$(command -v python3)"
T=$(cd "$(mktemp -d)" && pwd -P); pass=0; total=0   # pwd -P: macOS-Temp liegt hinter Symlink (/var -> /private/var)
trap 'rm -rf "$T"' EXIT
chk() { total=$((total+1)); if [ "$2" = "$3" ]; then pass=$((pass+1)); echo "ok   $1"; else echo "FAIL $1 (erwartet '$3', war '$2')"; fi; }
# run: Ausgabe (stdout+stderr) in $out, Exit in $rc; HOME und Arbeitsordner sind Wegwerf-Ordner
run() { out=$(cd "${CWD:-$T/cwd0}" && HOME="${H:-$T/nohome}" "$BASH_BIN" "$S" "$@" 2>&1); rc=$?; }
has()  { printf '%s\n' "$out" | grep -qF -- "$2"; chk "$1" "$?" 0; }
hasn() { printf '%s\n' "$out" | grep -qF -- "$2"; chk "$1" "$?" 1; }
rep() { printf '%*s' "$1" '' | tr ' ' "${2:-x}"; }
# unabhängiger Hash eines Skills, der nur aus SKILL.md besteht (ohne skills-status.sh)
h1() { { printf 'SKILL.md\0%s\0' "$(wc -c < "$1/SKILL.md" | tr -d ' ')"; cat "$1/SKILL.md"; } | shasum -a 256 | cut -d' ' -f1; }

mkdir -p "$T/cwd0" "$T/nohome" "$T/fx"
F="$T/fx"

# ---------- Fixtures (alle vorab, damit der Read-only-Fall den ganzen Baum prüft) ----------
# Hash-Vektoren
mkdir -p "$F/v1" "$F/v2" "$F/v3" "$F/v3crlf"
printf '# hi\n' > "$F/v2/SKILL.md"
mkdir -p "$F/v3/docs" "$F/v3crlf/docs"
printf 'a\n' > "$F/v3/SKILL.md"; printf 'b\n' > "$F/v3/docs/b.md"
printf 'a\r\n' > "$F/v3crlf/SKILL.md"; printf 'b\r\n' > "$F/v3crlf/docs/b.md"
mkdir -p "$F/v3extra/docs" "$F/v3extra/.git" "$F/v3extra/__pycache__"
printf 'a\n' > "$F/v3extra/SKILL.md"; printf 'b\n' > "$F/v3extra/docs/b.md"
printf '{}' > "$F/v3extra/metadata.json"; printf 'x' > "$F/v3extra/.git/HEAD"; printf 'x' > "$F/v3extra/__pycache__/a.pyc"

# Ort 1: alpha (ausgeblendet), beta (Lock v2), gamma (kein Lock)
O1="$F/ort1"; mkdir -p "$O1/alpha" "$O1/beta" "$O1/gamma"
printf -- '---\nname: alpha\ndescription: %s\nmetadata: { opencode/autoinvoke: false }\n---\n# alpha\n' "$(rep 70)" > "$O1/alpha/SKILL.md"
printf -- '---\nname: beta\ndescription: "%s"\n---\n# beta\n' "$(rep 35 b)" > "$O1/beta/SKILL.md"
printf -- '---\nname: gamma\ndescription: äöüäöüä\n---\n# gamma\n' > "$O1/gamma/SKILL.md"
HB=$(h1 "$O1/beta")
mkdir -p "$F/locks"
printf '{"version":2,"skills":{"beta":{"source":"owner/repo","computedHash":"%s","commit":"0123456789abcdef0123456789abcdef01234567"}}}\n' "$HB" > "$F/locks/v2.json"
printf '{"version":3,"skills":{"beta":{"source":"owner/repo","skillFolderHash":"deadbeef","updatedAt":"2026-01-01T00:00:00Z"}}}\n' > "$F/locks/v3.json"
printf '{"version":2,"skills":{"beta":{"source":"owner/repo","computedHash":"%s"}}}\n' "$HB" > "$F/locks/v2nocommit.json"
printf '{ das ist kein json' > "$F/locks/kaputt.json"
# beta verändert
cp -R "$O1" "$F/ort1b"; printf 'zusatz\n' >> "$F/ort1b/beta/SKILL.md"

# Ort 5: Sonderfälle der Beschreibung und des Ausblendens
O5="$F/ort5"; mkdir -p "$O5/blk" "$O5/lit" "$O5/dmi" "$O5/cdx" "$O5/nod" "$O5/wtu" "$O5/quo" "$O5/teams/release/agents" "$O5/.versteckt/x" "$O5/node_modules/y" "$O5/cdxok/agents" "$O5/ohnefm"
printf -- '---\nname: blk\ndescription: >\n  erste Zeile\n  zweite Zeile\nlicense: MIT\n---\n# blk\n' > "$O5/blk/SKILL.md"      # gefaltet: "erste Zeile zweite Zeile" = 24 Zeichen -> 7
printf -- '---\nname: lit\ndescription: |-\n  abc\n  def\n---\n' > "$O5/lit/SKILL.md"                                  # "abc\ndef" = 7 Zeichen -> 2
printf -- '---\nname: dmi\ndescription: %s\ndisable-model-invocation: true\n---\n' "$(rep 14)" > "$O5/dmi/SKILL.md"   # 14 -> 4
printf -- '---\nname: cdx\ndescription: %s\n---\n' "$(rep 7)" > "$O5/cdx/SKILL.md"                                  # 7 -> 2
mkdir -p "$O5/cdx/agents"; printf 'interface:\n  display_name: "x"\npolicy:\n  allow_implicit_invocation: false\n' > "$O5/cdx/agents/openai.yaml"
printf -- '---\nname: cdxok\ndescription: %s\n---\n' "$(rep 7)" > "$O5/cdxok/SKILL.md"                              # 2, bleibt sichtbar
printf 'policy:\n  allow_implicit_invocation: true\n' > "$O5/cdxok/agents/openai.yaml"
printf -- '---\nname: nod\nlicense: MIT\n---\n# nod\n' > "$O5/nod/SKILL.md"
printf '# nur Text, kein Frontmatter\n' > "$O5/ohnefm/SKILL.md"
printf -- '---\ndescription: %s\nwhen_to_use: %s\n---\n' "$(rep 10)" "$(rep 11)" > "$O5/wtu/SKILL.md"                  # 21 -> 6
printf -- "---\ndescription: 'Es gibt: Doppelpunkt # kein Kommentar'\n---\n" > "$O5/quo/SKILL.md"                  # 37 Zeichen -> 11
printf -- '---\ndescription: %s\n---\n' "$(rep 3)" > "$O5/teams/release/SKILL.md"                                  # 3 -> 1
printf -- '---\ndescription: verborgen\n---\n' > "$O5/.versteckt/x/SKILL.md"
printf -- '---\ndescription: verborgen\n---\n' > "$O5/node_modules/y/SKILL.md"

# Ort 6: Symlink auf gamma aus Ort 1
mkdir -p "$F/ort6"; ln -s "$O1/gamma" "$F/ort6/gamma"

# Ort 7: zu tief (Tiefe 7 wird nicht gefunden, Tiefe 6 schon)
mkdir -p "$F/ort7/a/b/c/d/e/f" "$F/ort7/a/b/c/d/e/f/g"
printf -- '---\ndescription: tief6\n---\n' > "$F/ort7/a/b/c/d/e/f/SKILL.md"

# Attrappen für --check
mkdir -p "$T/bin0" "$T/bin1" "$T/bin2"
ln -s "$PY_BIN" "$T/bin0/python3"
printf '#!/bin/sh\necho "attrappe check TEL=$DISABLE_TELEMETRY $DO_NOT_TRACK"\nexit 1\n' > "$T/bin1/skills"
printf '#!/bin/sh\necho "attrappe check ok"\nexit 0\n' > "$T/bin2/skills"
chmod +x "$T/bin1/skills" "$T/bin2/skills"

# Temp-HOME mit Standardorten
H1="$F/home"; mkdir -p "$H1/.agents/skills/hs" "$H1/.claude/skills/hc" "$F/proj/.opencode/skills/po" "$F/proj/.claude/skills/pc"
printf -- '---\ndescription: %s\n---\n' "$(rep 7)" > "$H1/.agents/skills/hs/SKILL.md"
printf -- '---\ndescription: %s\n---\n' "$(rep 14)" > "$H1/.claude/skills/hc/SKILL.md"
printf -- '---\ndescription: %s\n---\n' "$(rep 21)" > "$F/proj/.opencode/skills/po/SKILL.md"
printf -- '---\ndescription: %s\n---\n' "$(rep 35)" > "$F/proj/.claude/skills/pc/SKILL.md"
printf '{"version":3,"skills":{"hs":{"source":"owner/repo","skillFolderHash":"abc","updatedAt":"2026-01-01"}}}\n' > "$H1/.agents/.skill-lock.json"
printf '{"version":2,"skills":{"pc":{"source":"owner/repo","computedHash":"%s"}}}\n' "$(h1 "$F/proj/.claude/skills/pc")" > "$F/proj/skills-lock.json"

snap() { { find "$F" | LC_ALL=C sort; find "$F" -type f -exec shasum -a 256 {} + | LC_ALL=C sort; find "$F" -type l -exec readlink {} +; } | shasum -a 256; }
SNAP1=$(snap)

# ---------- 1 Hash-Testvektoren ----------
run --hash "$F/v1"; chk "1a Hash leerer Ordner" "$out" e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855; chk "1a Exit 0" "$rc" 0
run --hash "$F/v2"; chk "1b Hash SKILL.md='# hi'" "$out" 93c36952d8843b33e68ae970ebabcc03e1687c9bb0dd1ecaf357060318952f55
run --hash "$F/v3"; chk "1c Hash zwei Dateien" "$out" b22c4d22aa319d2924312fa18fcbfedc88fa89c74dbd8f298c683e1caf7b7f24
run --hash "$F/v3crlf"; chk "1d CRLF gleich LF" "$out" b22c4d22aa319d2924312fa18fcbfedc88fa89c74dbd8f298c683e1caf7b7f24
run --hash "$F/v3extra"; chk "1e metadata.json/.git/__pycache__ zählen nicht" "$out" b22c4d22aa319d2924312fa18fcbfedc88fa89c74dbd8f298c683e1caf7b7f24
run --hash "$F/gibt-es-nicht"; chk "1f --hash Ordner fehlt: Exit 2" "$rc" 2

# ---------- 2 Ort mit 3 Skills ----------
run --werkzeug opencode --lock "$F/locks/v2.json" "$O1"; chk "2 Exit 0" "$rc" 0
has "2 alpha ausgeblendet, Tokens gezeigt" "ausgeblendet=opencode 20 alpha "
has "2 beta sichtbar mit Herkunft+hash=ok" "sichtbar 10 beta ort=$O1 herkunft=owner/repo@0123456789ab hash=ok"
has "2 gamma (Unicode: 7 Zeichen = 2 Tokens) ohne Lock" "sichtbar 2 gamma ort=$O1 herkunft=ohne hash=ohne-lock"
has "2 Summe nur beta+gamma" "SUMME sichtbar=2 tokens=12 ausgeblendet=1 ohne-herkunft=2 abweichung=0"
has "2 Schlusszeile OK" "OK: skills-status"
run --werkzeug opencode --lock "$F/locks/v2nocommit.json" "$O1"; has "2b ohne commit" "herkunft=owner/repo@ohne-commit hash=ok"

# ---------- 3 beta verändert ----------
run --lock "$F/locks/v2.json" "$F/ort1b"; chk "3 Abweichung: Exit 1" "$rc" 1
has "3 hash=ABWEICHUNG" "beta ort=$F/ort1b herkunft=owner/repo@0123456789ab hash=ABWEICHUNG"
has "3 Summe abweichung=1" "abweichung=1"
has "3 Schlusszeile FAIL" "FAIL: skills-status (Hash-ABWEICHUNG 1)"

# ---------- 4 --max ----------
run --werkzeug opencode --max 11 --lock "$F/locks/v2.json" "$O1"; chk "4a --max 11 bei Summe 12: Exit 1" "$rc" 1; has "4a Grund genannt" "Summe 12 > max 11"
run --werkzeug opencode --max 12 --lock "$F/locks/v2.json" "$O1"; chk "4b --max 12 bei Summe 12: Exit 0" "$rc" 0

# ---------- 5 Beschreibungsformen, Ausblenden, Tiefe ----------
run --werkzeug opencode "$O5"; chk "5 Exit 0" "$rc" 0
has "5a Block > gefaltet: 24 Zeichen = 7 Tokens" "sichtbar 7 blk "
has "5b Block |- : 7 Zeichen = 2 Tokens" "sichtbar 2 lit "
has "5c disable-model-invocation (opencode-Blick): ausgeblendet=opencode" "ausgeblendet=opencode 4 dmi "
has "5d agents/openai.yaml false: sichtbar, implizit-aus=codex" "sichtbar 2 cdx ort=$O5 herkunft=ohne hash=ohne-lock implizit-aus=codex"
has "5e openai.yaml true: bleibt sichtbar" "sichtbar 2 cdxok "
has "5f ohne description" "ohne-beschreibung 0 nod "
has "5g ohne Frontmatter: ohne-beschreibung" "ohne-beschreibung 0 ohnefm "
has "5h when_to_use zählt mit: 21 Zeichen = 6" "sichtbar 6 wtu "
has "5i Quote mit Doppelpunkt und #: 37 Zeichen = 11" "sichtbar 11 quo "
has "5j verschachtelte ID teams/release" "sichtbar 1 teams/release "
hasn "5k versteckter Ordner übersprungen" " .versteckt"
hasn "5k2 versteckter Ordner übersprungen" ".versteckt/x"
hasn "5l node_modules übersprungen" " y ort="
# Summe (opencode): blk7 lit2 cdxok2 cdx2 wtu6 quo11 release1 = 31 (7 sichtbar); ausgeblendet: dmi; ohne Lock: alle 10 Skills
has "5m Summe" "SUMME sichtbar=7 tokens=31 ausgeblendet=1 ohne-herkunft=10 abweichung=0"
run "$F/ort7"; has "5n Tiefe 6 gefunden" "sichtbar 2 a/b/c/d/e/f "

# ---------- 6 Symlink in zweitem Ort ----------
run --werkzeug opencode --lock "$F/locks/v2.json" "$O1" "$F/ort6"; chk "6 Exit 0" "$rc" 0
has "6 doppelt= mit erstem Ort" "gamma ort=$F/ort6 herkunft=ohne hash=ohne-lock doppelt=$O1"
has "6 Summe unverändert (einmal gezählt)" "SUMME sichtbar=2 tokens=12 ausgeblendet=1 ohne-herkunft=2 abweichung=0"

# ---------- 7 Lock v3, kaputter Lock, Fehler ----------
run --lock "$F/locks/v3.json" "$O1"; chk "7a Lock v3: Exit 0" "$rc" 0
has "7a hash=nicht-prüfbar mit Herkunft" "beta ort=$O1 herkunft=owner/repo@ohne-commit hash=nicht-prüfbar"
run --lock "$F/locks/kaputt.json" "$O1"; chk "7b kaputter Lock: Exit 2" "$rc" 2
run --lock "$F/locks/gibt-es-nicht.json" "$O1"; chk "7c fehlender Lock: Exit 2" "$rc" 2
run "$F/gibt-es-nicht"; chk "7d fehlender Ordner: Exit 2" "$rc" 2
run --unbekannt "$O1"; chk "7e unbekannte Option: Exit 2" "$rc" 2
run --max abc "$O1"; chk "7f --max ohne Zahl: Exit 2" "$rc" 2
run --max; chk "7g --max ohne Wert: Exit 2" "$rc" 2
run --help; chk "7h --help: Exit 0" "$rc" 0; has "7h Hilfe zeigt Aufruf" "Aufruf:  bash tools/skills-status.sh"

# ---------- 8 --check ----------
out=$(cd "$T/cwd0" && HOME="$T/nohome" PATH="$T/bin0:/usr/bin:/bin" "$BASH_BIN" "$S" --check "$O1" 2>&1); rc=$?
chk "8a ohne skills im PATH: Exit 3" "$rc" 3; has "8a UNGEPRÜFT-Zeile" "UNGEPRÜFT: skills-CLI nicht installiert"
out=$(cd "$T/cwd0" && HOME="$T/nohome" PATH="$T/bin1:$T/bin0:/usr/bin:/bin" "$BASH_BIN" "$S" --check "$O1" 2>&1); rc=$?
chk "8b Attrappe Exit 1: Exit 1" "$rc" 1; has "8b Ausgabe durchgereicht, Telemetrie aus" "attrappe check TEL=1 1"
out=$(cd "$T/cwd0" && HOME="$T/nohome" PATH="$T/bin2:$T/bin0:/usr/bin:/bin" "$BASH_BIN" "$S" --check "$O1" 2>&1); rc=$?
chk "8c Attrappe Exit 0: Exit 0" "$rc" 0; has "8c Ausgabe durchgereicht" "attrappe check ok"
out=$(cd "$T/cwd0" && HOME="$T/nohome" PATH="$T/bin0:/usr/bin:/bin" "$BASH_BIN" "$S" --check --lock "$F/locks/v2.json" "$F/ort1b" 2>&1); rc=$?
chk "8d Abweichung + nicht prüfbar: Exit 1 hat Vorrang" "$rc" 1

# ---------- 10 Temp-HOME, Standardorte ohne ORDNER ----------
H="$H1" CWD="$F/proj" run; chk "10 Exit 0" "$rc" 0
has "10 ~ statt HOME-Pfad (global)" "ort=~/.agents/skills herkunft=owner/repo@ohne-commit hash=nicht-prüfbar"
has "10 ~ (claude global)" "sichtbar 4 hc ort=~/.claude/skills"
has "10 Projektort gefunden (relativ zum aktuellen Ordner)" "sichtbar 6 po ort=$F/proj/.opencode/skills"
has "10 Projekt-Lock ./skills-lock.json: hash=ok" "pc ort=$F/proj/.claude/skills herkunft=owner/repo@ohne-commit hash=ok"
hasn "10 HOME-Pfad nicht in der Ausgabe" "$H1"
has "10 Summe aller vier" "SUMME sichtbar=4 tokens=$((2+4+6+10)) ausgeblendet=0 ohne-herkunft=2 abweichung=0"
H="$H1" CWD="$F/proj" run --hash "$H1/.agents/skills/hs"; chk "10 --hash Ordner unter HOME: nur Hash" "${#out}" 64
CWD="$T/cwd0" H="$T/nohome" run; chk "10b leere Umgebung: Exit 0" "$rc" 0; has "10b Summe 0" "SUMME sichtbar=0 tokens=0 ausgeblendet=0 ohne-herkunft=0 abweichung=0"

# ---------- 11 Sichtbarkeit je Werkzeug ----------
# Fixtures: O1/alpha = nur opencode/autoinvoke:false (20 Tokens); O5/dmi = disable-model-invocation (4); O5/cdx = nur openai.yaml (2)
run --werkzeug opencode "$O1"; chk "11a alpha opencode: Exit 0" "$rc" 0
has "11a alpha opencode: ausgeblendet" "ausgeblendet=opencode 20 alpha "
has "11a Summe ohne alpha" "SUMME sichtbar=2 tokens=12 ausgeblendet=1 "
run --werkzeug claude-code "$O1"
has "11b alpha claude-code: sichtbar (metadata ignoriert)" "sichtbar 20 alpha "
hasn "11b ohne Zusatz ausgeblendet=opencode" "ausgeblendet=opencode"
has "11b Summe mit alpha" "SUMME sichtbar=3 tokens=32 ausgeblendet=0 "
run --werkzeug codex "$O1"; has "11c alpha codex: sichtbar" "sichtbar 20 alpha "; has "11c Summe mit alpha" "SUMME sichtbar=3 tokens=32 ausgeblendet=0 "
run "$O1"
has "11d alpha alle: sichtbar mit Zusatz" "sichtbar 20 alpha ort=$O1 herkunft=ohne hash=ohne-lock ausgeblendet=opencode"
has "11d Summe alle = Obergrenze" "SUMME sichtbar=3 tokens=32 ausgeblendet=0 "
run --werkzeug alle "$O1"; has "11d2 --werkzeug alle ausdrücklich wie Standard" "sichtbar 20 alpha ort=$O1 herkunft=ohne hash=ohne-lock ausgeblendet=opencode"
run --werkzeug opencode "$O5"; has "11e dmi opencode: ausgeblendet" "ausgeblendet=opencode 4 dmi "
run --werkzeug claude-code "$O5"; has "11e dmi claude-code: ausgeblendet" "ausgeblendet=claude-code 4 dmi "
has "11e Summe claude-code: nur dmi weg" "SUMME sichtbar=7 tokens=31 ausgeblendet=1 "
run --werkzeug codex "$O5"; has "11e dmi codex: sichtbar" "sichtbar 4 dmi "
has "11e Summe codex mit dmi" "SUMME sichtbar=8 tokens=35 ausgeblendet=0 "
run "$O5"; has "11e dmi alle: sichtbar, ausgeblendet=opencode,claude-code" "sichtbar 4 dmi ort=$O5 herkunft=ohne hash=ohne-lock ausgeblendet=opencode,claude-code"
has "11e Summe alle" "SUMME sichtbar=8 tokens=35 ausgeblendet=0 "
for w in opencode claude-code codex alle; do
  run --werkzeug "$w" "$O5"
  has "11f cdx ($w): sichtbar + implizit-aus=codex" "sichtbar 2 cdx ort=$O5 herkunft=ohne hash=ohne-lock implizit-aus=codex"
  has "11f cdx ($w): in Summe" "ausgeblendet=$([ "$w" = codex ] || [ "$w" = alle ] && echo 0 || echo 1) ohne-herkunft=10"
done
run --werkzeug foo "$O1"; chk "11g --werkzeug foo: Exit 2" "$rc" 2; has "11g Meldung" "--werkzeug erwartet"
run --werkzeug; chk "11h --werkzeug ohne Wert: Exit 2" "$rc" 2

# ---------- 12 --hash nur allein ----------
run --hash "$F/v2" --check; chk "12a --hash + --check: Exit 2" "$rc" 2; has "12a Meldung" "--hash nur allein"
run --hash "$F/v2" --max 5; chk "12b --hash + --max: Exit 2" "$rc" 2
run --hash "$F/v2" --lock "$F/locks/v2.json"; chk "12c --hash + --lock: Exit 2" "$rc" 2
run --hash "$F/v2" --werkzeug opencode; chk "12d --hash + --werkzeug: Exit 2" "$rc" 2
run --hash "$F/v2" "$O1"; chk "12e --hash + ORDNER: Exit 2" "$rc" 2
run --check --hash "$F/v2"; chk "12f --check vor --hash: Exit 2" "$rc" 2
hasn "12f kein Hash ausgegeben" "93c36952"
run --hash "$F/v2"; chk "12g --hash allein: weiter Exit 0" "$rc" 0

# ---------- 13 OpenCode-Vorrang: opencode/autoinvoke gewinnt gegen disable-model-invocation ----------
O13="$T/ort13"; mkdir -p "$O13/an" "$O13/aus"; printf '{"version":2,"skills":{}}' > "$T/l13.json"
printf -- '---\ndescription: abcdefg\ndisable-model-invocation: true\nmetadata:\n  opencode/autoinvoke: true\n---\n' > "$O13/an/SKILL.md"
printf -- '---\ndescription: abcdefg\ndisable-model-invocation: true\nmetadata: { opencode/autoinvoke: false }\n---\n' > "$O13/aus/SKILL.md"
run --lock "$T/l13.json" --werkzeug opencode "$O13"; chk "13a opencode: Exit 0" "$rc" 0
has "13a autoinvoke true gewinnt: sichtbar" "sichtbar 2 an "
has "13a autoinvoke false: ausgeblendet" "ausgeblendet=opencode 2 aus "
has "13a Summe nur an" "SUMME sichtbar=1 tokens=2 "
run --lock "$T/l13.json" --werkzeug claude-code "$O13"; has "13b claude-code: beide ausgeblendet" "SUMME sichtbar=0 tokens=0 ausgeblendet=2 "

# ---------- 9 Read-only ----------
SNAP2=$(snap); chk "9 Baum vor/nach allen Läufen unverändert" "$SNAP2" "$SNAP1"

echo "Selbsttest skills-status: $pass/$total"; [ $pass -eq $total ]
