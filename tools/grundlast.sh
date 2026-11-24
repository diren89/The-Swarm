#!/usr/bin/env bash
# Misst die Grundlast des Regelwerks: Tokens = Unicode-Zeichen / 3,5 (aufgerundet), nicht Bytes.
# Aufruf:  bash tools/grundlast.sh [WURZEL]      (WURZEL = Repo-Ordner, Standard: Ordner über tools/)
# Je Datei eine Zeile `OK|FAIL <datei> <tokens> / <grenze>` (LEARNINGS: nur `INFO`, keine harte Grenze),
# zum Schluss `OK|FAIL: grundlast`. Exit 0 = alles innerhalb der Grenzen, 1 = Grenze überschritten, 2 = Datei fehlt.
# Grenzen siehe MANIFEST §9.1 (Pflege des Regelwerks).
set -u
GRENZE_KERN=1500
GRENZE_MANIFEST=6000
# LEARNINGS.md hat keine harte Grenze (nur Info)
root=${1:-$(cd "$(dirname "$0")/.." && pwd)}
command -v python3 >/dev/null 2>&1 || { echo "FAIL: python3 fehlt" >&2; exit 2; }
exec python3 - "$root" "$GRENZE_KERN" "$GRENZE_MANIFEST" <<'PYEOF'
import math, os, sys
root, g_kern, g_man = sys.argv[1], int(sys.argv[2]), int(sys.argv[3])
rc = 0
for name, grenze in (("KERN.md", g_kern), ("MANIFEST.md", g_man), ("LEARNINGS.md", None)):
    p = os.path.join(root, name)
    if not os.path.isfile(p):
        print(f"FAIL {name} fehlt")
        rc = 2
        continue
    with open(p, encoding="utf-8") as f:
        zeichen = len(f.read())
    tokens = math.ceil(zeichen / 3.5)
    if grenze is None:
        print(f"INFO {name} {tokens} (keine harte Grenze)")
    elif tokens > grenze:
        print(f"FAIL {name} {tokens} / {grenze}")
        rc = max(rc, 1) if rc != 2 else 2
    else:
        print(f"OK   {name} {tokens} / {grenze}")
print(("OK" if rc == 0 else "FAIL") + ": grundlast")
sys.exit(rc)
PYEOF
