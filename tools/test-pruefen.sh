#!/usr/bin/env bash
# Selbsttest pruefen.sh, grundlast.sh und update.sh (Fälle 18 ff. mit eigenen Testdateien und Temp-Repo, unabhängig vom echten Manifest)
P="$(cd "$(dirname "$0")" && pwd)/pruefen.sh"
T=$(mktemp -d); pass=0; total=0
chk() { total=$((total+1)); if [ "$2" = "$3" ]; then pass=$((pass+1)); echo "ok   $1"; else echo "FAIL $1 (erwartet '$3', war '$2')"; fi; }
run() { out=$(bash "$P" -l "$T/logs" "$@" 2>&1); rc=$?; }

run 'echo hallo'; chk "1 OK: Exit 0" "$rc" 0; chk "1 OK: Zeile beginnt mit OK" "${out:0:2}" OK
run 'exit 3'; chk "2 FAIL-Exit: Exit 1" "$rc" 1; echo "$out" | grep -q '^FAIL 3' ; chk "2 FAIL 3 in Zeile" "$?" 0
run 'echo "warning: x"; echo OK'; chk "3 Warnung bei Exit 0: Gesamtexit 1" "$rc" 1; echo "$out" | grep -q '^WARN 0 .*warn=1'; chk "3 WARN mit warn=1" "$?" 0
run 'echo "Ran 0 tests in 0.0s"; echo OK' ; chk "4a 0 Tests ohne -t: OK" "$rc" 0
run -t 'echo "Ran 0 tests in 0.0s"; echo OK'; chk "4b 0 Tests mit -t: FAIL" "$rc" 1; echo "$out" | grep -q '^FAIL 0 tests=0'; chk "4b FAIL tests=0" "$?" 0
run -t 'echo nur OK'; chk "4c nicht erkannt mit -t: FAIL" "$rc" 1
run -t 'echo "Ran 5 tests in 0.1s"; echo OK'; chk "4d unittest 5 mit -t: OK" "$rc" 0; echo "$out" | grep -q 'tests=5'; chk "4d tests=5" "$?" 0
run -t 'echo "===== 7 passed in 0.2s ====="'; echo "$out" | grep -q 'tests=7'; chk "4e pytest tests=7" "$?" 0
run -t 'printf "Tests:       1 failed, 4 passed, 5 total\n"'; echo "$out" | grep -q 'tests=5'; chk "4f jest tests=5" "$?" 0
run -t 'echo "      Tests  6 passed (6)"'; echo "$out" | grep -q 'tests=6'; chk "4g vitest tests=6" "$?" 0
run "echo 'a b \"c\"' > \"$T/x y.txt\" && cat \"$T/x y.txt\""; chk "5 Leerzeichen/Quotes: Exit 0" "$rc" 0; chk "5 Datei mit Leerzeichen" "$(cat "$T/x y.txt")" 'a b "c"'
echo "$out" | grep -q 'a b "c"'; chk "5 letzte Zeile mit Quotes" "$?" 0
run 'false | cat'; chk "6 pipefail: false|cat = FAIL" "$rc" 1
run 'make_nichts_da 2>&1 | grep -v zzz'; chk "7 fehlender Befehl in Pipe: FAIL (pipefail)" "$rc" 1; echo "$out" | grep -q '^FAIL 127'; chk "7 Exit 127 sichtbar" "$?" 0
# 8 zwei Läufe überschreiben sich nicht
rm -rf "$T/l2"; bash "$P" -l "$T/l2" 'echo eins' >/dev/null; sleep 1; bash "$P" -l "$T/l2" 'echo zwei' >/dev/null
n=$(ls -d "$T"/l2/*/ | wc -l | tr -d ' '); chk "8 zwei Lauf-Ordner" "$n" 2
c=$(cat "$T"/l2/*/01.log | sort | tr '\n' ' '); chk "8 beide Logs erhalten" "$c" "eins zwei "
# 9 gleiche Sekunde: PID trennt
rm -rf "$T/l3"; bash "$P" -l "$T/l3" 'echo a' >/dev/null; bash "$P" -l "$T/l3" 'echo b' >/dev/null
n=$(ls -d "$T"/l3/*/ | wc -l | tr -d ' '); chk "9 gleiche Sekunde, 2 Ordner" "$n" 2
# 10 Pfad in Summenzeile
run 'echo x'; echo "$out" | grep -q "Logs: $T/logs/"; chk "10 Logpfad in Summenzeile" "$?" 0
# 11 -w eigenes Muster
run -w 'BOOM' 'echo BOOM'; chk "11 -w BOOM: WARN, Exit 1" "$rc" 1
run 'echo "my warnings-free"' ; echo "$out" | grep -q '^OK'; chk "12 'warnings' als Wortteil -> trifft (bewusst)" "$?" 1
# 13-16 R2: übersprungene Tests zählen nicht, WARN: wird erkannt
run -t 'echo "===== 5 skipped in 0.01s ====="'; chk "13 pytest nur skipped mit -t: Exit 1" "$rc" 1
run -t 'printf "Ran 3 tests in 0.0s\n\nOK (skipped=3)\n"'; chk "14 unittest alle skipped mit -t: Exit 1" "$rc" 1
run -t 'printf "Ran 3 tests in 0.0s\n\nOK (skipped=1)\n"'; echo "$out" | grep -q '^OK 0 tests=2 '; chk "15 unittest 3-1 skipped: tests=2" "$?" 0
run 'echo "WARN: veraltet"; echo fertig'; echo "$out" | grep -q '^WARN 0 .*warn=1'; chk "16 WARN: erkannt" "$?" 0
run -t 'printf "Ran 1 test in 0.0s\n\nOK (skipped=2)\n"'; chk "17 Subtests skipped>Ran mit -t: Exit 1" "$rc" 1; echo "$out" | grep -q 'tests=0 '; chk "17 tests=0 statt negativ" "$?" 0
# --- grundlast.sh (Testdateien im Temp-Ordner, nicht das echte Regelwerk) ---
GL="$(cd "$(dirname "$0")" && pwd)/grundlast.sh"
mkgl() { rm -rf "$T/gl"; mkdir -p "$T/gl"; python3 -c "
import sys
d=sys.argv[1]
for n,z in (('KERN.md',int(sys.argv[2])),('MANIFEST.md',int(sys.argv[3])),('LEARNINGS.md',int(sys.argv[4]))):
    open(d+'/'+n,'w',encoding='utf-8').write('ä'*z)
" "$T/gl" "$1" "$2" "$3"; }
glrun() { out=$(bash "$GL" "$T/gl" 2>&1); rc=$?; }
mkgl 5250 21000 99999; glrun; chk "18 grundlast genau an den Grenzen: Exit 0" "$rc" 0; echo "$out" | grep -q '^OK: grundlast'; chk "18 Schlusszeile OK" "$?" 0
echo "$out" | grep -q '^INFO LEARNINGS.md 28572 '; chk "18 LEARNINGS nur INFO, Unicode-Zeichen statt Bytes" "$?" 0
echo "$out" | grep -q '^OK   KERN.md 1500 / 1500'; chk "18 KERN 1500 / 1500" "$?" 0
mkgl 5251 100 100; glrun; chk "19 KERN 1 Zeichen über Grenze: Exit 1" "$rc" 1; echo "$out" | grep -q '^FAIL KERN.md 1501 / 1500'; chk "19 FAIL-Zeile KERN" "$?" 0
mkgl 100 21001 100; glrun; chk "20 MANIFEST über Grenze: Exit 1" "$rc" 1; echo "$out" | grep -q '^FAIL MANIFEST.md 6001 / 6000'; chk "20 FAIL-Zeile MANIFEST" "$?" 0
echo "$out" | grep -q '^FAIL: grundlast'; chk "20 Schlusszeile FAIL" "$?" 0
rm "$T/gl/MANIFEST.md"; glrun; chk "21 Datei fehlt: Exit 2" "$rc" 2
mkgl 100 100 700000; glrun; chk "22 LEARNINGS groß: kein FAIL, Exit 0" "$rc" 0

# --- update.sh (Temp-Repo mit zwei Tags) ---
UP="$(cd "$(dirname "$0")" && pwd)/update.sh"
if command -v git >/dev/null 2>&1; then
  O="$T/up/origin"; K="$T/up/klon mit leerzeichen"; rm -rf "$T/up"; mkdir -p "$O"
  G="git -c user.email=t@example.invalid -c user.name=Test -c commit.gpgsign=false -c tag.gpgsign=false"
  ( cd "$O" && git init -q . && echo "kern 1" > KERN.md && echo "man 1" > MANIFEST.md && git add . && $G commit -q -m eins && git tag v1.0.0 ) >/dev/null 2>&1
  git clone -q "$O" "$K" >/dev/null 2>&1; git -C "$K" checkout -q v1.0.0 >/dev/null 2>&1
  uprun() { out=$(bash "$UP" "$@" 2>&1 < "${UPIN:-/dev/null}"); rc=$?; }
  uprun "$K"; chk "23 update: bereits aktuell: Exit 0" "$rc" 0; echo "$out" | grep -q 'bereits auf v1.0.0'; chk "23 Meldung bereits aktuell" "$?" 0
  ( cd "$O" && echo "kern 2" > KERN.md && git add . && $G commit -q -m zwei && git tag v1.1.0 ) >/dev/null 2>&1
  printf 'n\n' > "$T/in_n"; UPIN="$T/in_n" uprun "$K"; chk "24 update Eingabe n: Exit 0" "$rc" 0
  chk "24 kein Wechsel bei n" "$(git -C "$K" describe --tags --always)" v1.0.0
  echo "$out" | grep -q 'Auf v1.1.0 wechseln? \[j/N\]'; chk "24 Frage mit neuem Tag" "$?" 0
  echo "$out" | grep -q '^-kern 1'; chk "24 Diff von KERN.md gezeigt" "$?" 0
  UPIN=/dev/null uprun "$K"; chk "25 update leere Eingabe (EOF): kein Wechsel" "$(git -C "$K" describe --tags --always)" v1.0.0
  echo "x" >> "$K/KERN.md"; uprun -y "$K"; chk "26 lokale Änderung: Exit 1" "$rc" 1; chk "26 kein Wechsel bei lokaler Änderung" "$(git -C "$K" describe --tags --always)" v1.0.0
  git -C "$K" checkout -q -- KERN.md
  printf 'j\n' > "$T/in_j"; UPIN="$T/in_j" uprun "$K"; chk "27 update Eingabe j: Wechsel auf v1.1.0" "$(git -C "$K" describe --tags --always)" v1.1.0
  git -C "$K" checkout -q v1.0.0; uprun -y "$K"; chk "28 update -y: Exit 0" "$rc" 0; chk "28 update -y: Wechsel ohne Frage" "$(git -C "$K" describe --tags --always)" v1.1.0
  chk "29 detached HEAD, nicht auf Zweig" "$(git -C "$K" symbolic-ref -q HEAD || echo detached)" detached
  uprun "$T/gibt-es-nicht"; chk "30 Klon fehlt: Exit 2" "$rc" 2
else
  echo "UNGEPRÜFT update.sh (git fehlt)"
fi
# --- skills-status.sh (eigener Selbsttest mit Wegwerf-Ordnern) ---
bash "$(dirname "$0")/test-skills-status.sh" >/dev/null 2>&1; chk "31 skills-status Selbsttest" "$?" 0
echo "Selbsttest: $pass/$total"; rm -rf "$T"; [ $pass -eq $total ]
