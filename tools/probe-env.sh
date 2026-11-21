#!/usr/bin/env bash
# Probes the local machine before planning (MANIFEST §8) and prints a Markdown profile.
# Usage: tools/probe-env.sh > hardware/$(hostname -s).local.md   (local only, never commit)
# Read-only: changes nothing, installs nothing.
set -u

have() { command -v "$1" >/dev/null 2>&1; }
row() { printf '| %s | %s |\n' "$1" "${2:-–}"; }

echo "# Umgebungsprofil ($(date +%Y-%m-%d))"
echo
echo "| Merkmal | Wert |"
echo "| --- | --- |"
os=$(uname -s)
row "Betriebssystem" "$os $(uname -r)"
row "Architektur" "$(uname -m)"
if [ "$os" = "Darwin" ]; then
  row "macOS" "$(sw_vers -productVersion 2>/dev/null)"
  row "Kerne" "$(sysctl -n hw.ncpu 2>/dev/null)"
  row "RAM (GB)" "$(( $(sysctl -n hw.memsize 2>/dev/null || echo 0) / 1073741824 ))"
  row "GPU / Metal" "$(system_profiler SPDisplaysDataType 2>/dev/null | awk -F': ' '/Chipset Model|Metal Support/{printf "%s; ", $2}')"
  row "Developer-Verzeichnis" "$(xcode-select -p 2>/dev/null)"
  if [ -d /Applications/Xcode.app ]; then
    X="DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer"
    row "Xcode" "$(env $X xcodebuild -version 2>/dev/null | head -1)"
    row "Xcode-Lizenz/First Launch" "$(env $X xcodebuild -checkFirstLaunchStatus >/dev/null 2>&1 && echo ok || echo 'offen')"
    row "Simulator-Laufzeiten" "$(env $X xcrun simctl list runtimes 2>/dev/null | grep -c -E '^(iOS|watchOS|tvOS|visionOS)')"
    row "Geräte (USB/Netz)" "$(env $X xcrun devicectl list devices 2>/dev/null | tail -n +3 | awk '{print $(NF)}' | paste -sd ',' -)"
  else
    row "Xcode" "nicht installiert"
  fi
  row "Signier-Identitäten" "$(security find-identity -v -p codesigning 2>/dev/null | tail -1)"
else
  row "Kerne" "$(nproc 2>/dev/null)"
  row "RAM (GB)" "$(awk '/MemTotal/{printf "%d", $2/1048576}' /proc/meminfo 2>/dev/null)"
  row "GPU" "$(lspci 2>/dev/null | grep -i -E 'vga|3d' | head -1 | cut -d: -f3)"
fi
row "Last (1/5/15 min)" "$(uptime | sed 's/.*load averages*: //')"
for t in git gh node python3 swift docker brew; do
  if have "$t"; then row "$t" "$($t --version 2>&1 | head -1)"; else row "$t" "fehlt"; fi
done
echo
echo "## Bewährte Grenzen (von Hand pflegen)"
echo
echo "- Parallele Builds: <Zahl nach Lastmessung>"
echo "- Sichtprüfweg: <Emulator / Gerät / Ersatz>"
echo "- Bekannte Umgehungen: <…>"
