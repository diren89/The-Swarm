#!/usr/bin/env bash
# Aktualisiert den lokalen Klon von The Swarm auf den neuesten Release-Tag, erst nach Bestätigung.
# Aufruf:  bash tools/update.sh [-y] [KLON]      (KLON: Standard ~/.the-swarm)
#   -y   überspringt die Rückfrage. NUR für Skripte; von Hand immer Diff lesen und bestätigen.
# Ablauf: git fetch --tags; zeigt aktuellen Stand und neuesten Tag; zeigt die Änderungen (diff --stat sowie den Diff von
# KERN.md und MANIFEST.md); fragt „Auf <tag> wechseln? [j/N]“; wechselt erst dann mit `git checkout -q <tag>`
# (detached HEAD ist gewollt). Nie pull, nie reset, nie Wechsel auf main. Der Klon ist eine Lesekopie: nichts darin ändern.
# Exit: 0 = aktuell, gewechselt oder abgelehnt; 1 = ungesicherte lokale Änderungen, Fehler oder Wechsel gescheitert; 2 = Klon fehlt.
set -u
auto=0
if [ "${1:-}" = "-y" ]; then auto=1; shift; fi
klon=${1:-$HOME/.the-swarm}
[ -d "$klon/.git" ] || { echo "FAIL: kein Git-Klon unter $klon (Anlegen: git clone https://github.com/diren89/The-Swarm.git \"$klon\")" >&2; exit 2; }
g() { git -C "$klon" "$@"; }
if [ -n "$(g status --porcelain)" ]; then
  echo "FAIL: ungesicherte lokale Änderungen in $klon; Abbruch, nichts geändert. Der Klon ist eine Lesekopie: Änderungen sichern oder verwerfen (von Hand, nicht durch dieses Skript)." >&2
  exit 1
fi
g fetch --tags -q || { echo "FAIL: git fetch --tags gescheitert (offline?); Stand bleibt unverändert" >&2; exit 1; }
aktuell=$(g describe --tags --always 2>/dev/null) || { echo "FAIL: aktueller Stand nicht ermittelbar" >&2; exit 1; }
neu=$(g tag --sort=-v:refname | head -1)
[ -n "$neu" ] || { echo "FAIL: keine Tags im Klon" >&2; exit 1; }
echo "Aktuell: $aktuell"
echo "Neuester Tag: $neu"
if [ "$(g rev-parse HEAD)" = "$(g rev-parse "$neu^{commit}")" ]; then
  echo "OK: bereits auf $neu, nichts zu tun"
  exit 0
fi
echo "--- Änderungen $aktuell -> $neu ---"
g --no-pager diff --stat "$aktuell" "$neu"
echo "--- Diff KERN.md und MANIFEST.md ---"
g --no-pager diff "$aktuell" "$neu" -- KERN.md MANIFEST.md
echo "---"
if [ "$auto" -eq 0 ]; then
  printf 'Auf %s wechseln? [j/N] ' "$neu"
  read -r antwort || antwort=""
  case "$antwort" in j|J|ja|Ja|JA) ;; *) echo "Abgebrochen, Stand bleibt $aktuell"; exit 0;; esac
fi
g checkout -q "$neu" || { echo "FAIL: Wechsel auf $neu gescheitert" >&2; exit 1; }
echo "OK: jetzt auf $(g describe --tags --always)"
