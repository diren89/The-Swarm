#!/usr/bin/env bash
# Selbsttest pruefen.sh
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
echo "Selbsttest: $pass/$total"; rm -rf "$T"; [ $pass -eq $total ]
