#!/usr/bin/env bash
# The Swarm, optionales Beispiel: Gate B "Prüfung geänderter Dateien bei Sitzungsende" (Claude Code, Ereignis Stop).
# Listet die geänderten Dateien (git status --porcelain) und führt, falls festgelegt, den Prüfbefehl des Projekts aus:
#   THE_SWARM_PRUEFBEFEHL="<Befehl>"   (Standard: leer = nur Liste und Hinweis)
# WARNEND, NIE BLOCKIEREND: Das Skript endet immer mit Exit 0 und gibt die Meldung als JSON-Feld systemMessage aus
# (wird der Nutzerin angezeigt). Es hält Claude nicht vom Beenden ab; so entsteht keine Endlosschleife.
# stop_hook_active=true (Claude läuft wegen eines Stop-Hooks weiter): sofort Exit 0, kein zweiter Lauf.
# FAIL-OPEN: Fehlt git, schlägt etwas fehl oder gibt es nichts zu melden, endet die Sitzung wie ohne Hook.
# Der Prüfbefehl kommt aus der Umgebung der Nutzerin, nicht aus dem Hook-JSON. Laufzeitgrenze: "timeout" im Hook-Block.
# Siehe README.md in beispiele/claude-code/.
set -u
trap 'exit 0' EXIT

input=$(cat) || exit 0
printf '%s' "$input" | grep -Eq '"stop_hook_active"[[:space:]]*:[[:space:]]*true' && exit 0

command -v git >/dev/null 2>&1 || exit 0
wurzel=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
cd "$wurzel" || exit 0

status=$(git status --porcelain 2>/dev/null) || exit 0
[ -n "$status" ] || exit 0
anzahl=$(printf '%s\n' "$status" | wc -l | tr -d ' ')

msg="The Swarm, Sitzungsende: $anzahl Einträge in git status --porcelain (höchstens 15 gezeigt):"$'\n'
msg="$msg$(printf '%s\n' "$status" | head -n 15)"$'\n'

if [ -n "${THE_SWARM_PRUEFBEFEHL:-}" ]; then
  ausgabe=$(bash -c "$THE_SWARM_PRUEFBEFEHL" 2>&1 < /dev/null)
  rc=$?
  if [ "$rc" -eq 0 ]; then
    msg="${msg}Prüfbefehl ausgeführt, Exit 0."
  else
    msg="${msg}WARNUNG: Prüfbefehl endete mit Exit $rc. Letzte Zeilen:"$'\n'"$(printf '%s\n' "$ausgabe" | tail -n 15)"
  fi
else
  msg="${msg}Kein Prüfbefehl festgelegt (THE_SWARM_PRUEFBEFEHL). Vor dem Abschluss prüfen, wie das Projekt es vorsieht."
fi

# Als JSON-String maskieren (ohne jq): Backslash, Anführungszeichen, Tabs, Steuerzeichen, Zeilenumbrüche.
json=$(printf '%s' "$msg" | tr '\t' ' ' | tr -d '\000-\010\013-\037' | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' | sed -e ':a' -e 'N' -e '$!ba' -e 's/\n/\\n/g')
printf '{"systemMessage":"%s"}\n' "$json"
exit 0
