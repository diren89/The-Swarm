#!/usr/bin/env bash
# Listet installierte Agent-Skills (Skill = Ordner mit SKILL.md): Ort, Herkunft, Beschreibungs-Tokens, ausgeblendet, Hash-Abgleich mit Lock.
# Tokens = Unicode-Zeichen der Beschreibung (+ when_to_use) / 3,5 (aufgerundet); nur sichtbare Skills mit Beschreibung zählen zur Summe.
# Aufruf:  bash tools/skills-status.sh [--werkzeug W] [--check] [--max N] [--lock DATEI]... [--help] [ORDNER ...]
#          bash tools/skills-status.sh --hash ORDNER      (allein; mit anderen Optionen oder ORDNER: Exit 2)
#   ORDNER      Orte, die durchsucht werden (rekursiv bis Tiefe 6; versteckte Ordner und node_modules übersprungen).
#               Ohne ORDNER: ~/.config/opencode/skills, ~/.claude/skills, ~/.agents/skills sowie im aktuellen Ordner
#               (bzw. bis zur Git-Wurzel) .opencode/skills, .claude/skills, .agents/skills, jeweils nur falls vorhanden.
#   --lock D    Lock-Datei (mehrfach). Ersetzt die Standardsuche (./skills-lock.json, ~/.agents/.skill-lock.json).
#               Lock Version 1/2: computedHash wird verglichen; Version 3 (skillFolderHash): hash=nicht-prüfbar.
#   --max N     Befund (Exit 1), wenn die Summe der Tokens größer als N ist.
#   --hash O    Gibt nur den computedHash des Ordners O aus (Exit 0), z. B. zur Prüfung nach Updates. Nur allein erlaubt:
#               zusammen mit --check, --max, --lock, --werkzeug oder ORDNER Exit 2 (kein stiller Teilerfolg).
#   --werkzeug W  opencode | claude-code | codex | alle (Standard alle). Bestimmt, für wen „ausgeblendet“ gilt. Ein Skill ist
#               für ein Werkzeug nur ausgeblendet, wenn ein von diesem Werkzeug beachteter Mechanismus greift:
#                 opencode     `metadata: opencode/autoinvoke: false` ODER `disable-model-invocation: true`
#                              (ist `opencode/autoinvoke` gesetzt, gewinnt es: `true` macht sichtbar)
#                 claude-code  `disable-model-invocation: true` (`metadata` wird ignoriert)
#                 codex        nie per Datei: `agents/openai.yaml` `policy.allow_implicit_invocation: false` verbietet nur den
#                              impliziten Aufruf; ob die Beschreibung aus der Liste fällt, ist nicht dokumentiert. Konservativ
#                              zählt der Skill als sichtbar (Summe), die Zeile trägt `implizit-aus=codex`.
#               Bei `alle` gilt ein Skill nur als ausgeblendet, wenn er für alle drei Werkzeuge ausgeblendet ist. Wegen codex
#               ist das nie der Fall: die Summe ist dann eine Obergrenze, die Zeile nennt `ausgeblendet=<Werkzeuge>`.
#               Für eine genaue Summe `--werkzeug` angeben. Ungültiger Wert: Exit 2.
#               Grenze: Abschalten per Konfiguration (Codex `[[skills.config]] enabled=false`, Claude Code `skillOverrides`,
#               OpenCode-/Claude-Rechte `deny`) liegt außerhalb der Skill-Ordner und wird nicht ausgewertet.
#   --check     Führt `skills check` aus, falls das Programm `skills` im PATH liegt (kein npx, keine Telemetrie).
# Ausgabe je Skill: `<sichtbar|ausgeblendet=<Werkzeuge>|ohne-beschreibung> <tokens> <id> ort=… herkunft=… hash=…`
# Zusätze am Zeilenende: `ausgeblendet=<Werkzeuge>` (bei sichtbar, nur für einen Teil der Werkzeuge ausgeblendet),
# `implizit-aus=codex`, `doppelt=<erster Ort>` (gleiches Ziel über mehrere Orte; zählt nicht doppelt). Dann
# `SUMME sichtbar=<n> tokens=<t> ausgeblendet=<n> ohne-herkunft=<n> abweichung=<n>` und `OK|FAIL: skills-status`.
# Herkunft: <source>@<commit, 12 Zeichen> | <source>@ohne-commit | ohne (kein Lock-Eintrag = lokal, nicht aktualisierbar).
# hash: ok | ABWEICHUNG | ohne-lock | nicht-prüfbar (leerer Hash im Lock oder Lock Version 3).
# Exit 0 = alles ok, 1 = Befund (Summe > --max, Hash-ABWEICHUNG, --check fehlgeschlagen), 2 = Aufruf- oder Lesefehler
# (unbekannte Option, fehlender Ordner, kaputter Lock, python3 fehlt), 3 = --check verlangt, aber skills-CLI nicht installiert
# (nicht prüfbar ≠ bestanden; ein Befund mit Exit 1 oder 2 hat Vorrang). Schreibt nie etwas (keine Datei, kein Cache).
# Hash-Verfahren: https://github.com/vercel-labs/skills (README, „Lock File Content Hash“). Beispiel-Quelle: owner/repo.
set -u
set -o pipefail
for a in "$@"; do
  case "$a" in
    --help|-h) awk 'NR>1 && /^#/ {sub(/^# ?/,""); print; next} NR>1 {exit}' "$0"; exit 0 ;;
  esac
done
command -v python3 >/dev/null 2>&1 || { echo "FAIL: python3 fehlt" >&2; exit 2; }
exec python3 - "$@" <<'PYEOF'
import hashlib, json, os, subprocess, shutil, sys, re

TIEFE = 6
WERKZEUGE = ["opencode", "claude-code", "codex"]
SKIP = {"node_modules"}
HASH_SKIP_DIRS = {".git", "__pycache__", "__pypackages__"}


def fehler(msg):
    print(f"FAIL: skills-status ({msg})", file=sys.stderr)
    sys.exit(2)


# ---------- Argumente ----------
args = sys.argv[1:]
check = False
max_tokens = None
locks_arg = []
hash_ordner = None
werkzeug = "alle"
werkzeug_gesetzt = False
orte_arg = []
i = 0
while i < len(args):
    a = args[i]
    if a == "--check":
        check = True
    elif a in ("--max", "--lock", "--hash", "--werkzeug"):
        if i + 1 >= len(args):
            fehler(f"{a} braucht einen Wert")
        i += 1
        v = args[i]
        if a == "--max":
            if not re.fullmatch(r"[0-9]+", v):
                fehler("--max braucht eine ganze Zahl")
            max_tokens = int(v)
        elif a == "--lock":
            locks_arg.append(v)
        elif a == "--werkzeug":
            if v not in WERKZEUGE + ["alle"]:
                fehler(f"--werkzeug erwartet opencode|claude-code|codex|alle, nicht '{v}'")
            werkzeug, werkzeug_gesetzt = v, True
        else:
            hash_ordner = v
    elif a.startswith("-") and a != "-":
        fehler(f"unbekannte Option {a}")
    else:
        orte_arg.append(a)
    i += 1

if hash_ordner is not None and (check or max_tokens is not None or locks_arg or werkzeug_gesetzt or orte_arg):
    fehler("--hash nur allein: nicht mit --check, --max, --lock, --werkzeug oder ORDNER kombinierbar")

HOME = os.environ.get("HOME") or os.path.expanduser("~")
HOMES = sorted({h for h in (HOME.rstrip("/"), os.path.realpath(HOME).rstrip("/")) if h}, key=len, reverse=True)


def kurz(p):
    for h in HOMES:
        if p == h:
            return "~"
        if p.startswith(h + "/"):
            return "~" + p[len(h):]
    return p


# ---------- Hash (Verfahren aus der skills-CLI) ----------
def sammle(root_real, d, rel, stack, out):
    try:
        namen = os.listdir(d)
    except OSError as e:
        fehler(f"Ordner nicht lesbar: {kurz(d)} ({e.strerror})")
    for n in namen:
        p = os.path.join(d, n)
        r = rel + [n]
        if os.path.islink(p):
            real = os.path.realpath(p)
            if not os.path.exists(real):
                continue  # kaputter Link
            if real != root_real and not real.startswith(root_real + os.sep):
                continue  # zeigt aus dem Skill-Ordner hinaus
        else:
            real = os.path.realpath(p)
        if os.path.isdir(p):
            if n in HASH_SKIP_DIRS or real in stack:
                continue
            sammle(root_real, p, r, stack | {real}, out)
        elif os.path.isfile(p):
            if n == "metadata.json":
                continue
            out.append(("/".join(r), p))


def computed_hash(ordner):
    root_real = os.path.realpath(ordner)
    dateien = []
    sammle(root_real, ordner, [], {root_real}, dateien)
    dateien.sort(key=lambda x: x[0].encode("utf-8"))
    h = hashlib.sha256()
    for rel, p in dateien:
        try:
            with open(p, "rb") as f:
                inhalt = f.read()
        except OSError as e:
            fehler(f"Datei nicht lesbar: {kurz(p)} ({e.strerror})")
        if b"\0" not in inhalt:
            inhalt = inhalt.replace(b"\r\n", b"\n")
        h.update(rel.encode("utf-8") + b"\0" + str(len(inhalt)).encode("ascii") + b"\0" + inhalt)
    return h.hexdigest()


if hash_ordner is not None:
    if not os.path.isdir(hash_ordner):
        fehler(f"Ordner fehlt: {kurz(os.path.abspath(hash_ordner))}")
    print(computed_hash(hash_ordner))
    sys.exit(0)


# ---------- kleiner Frontmatter-Parser (nur die benötigten Fälle) ----------
KEY = re.compile(r"^([A-Za-z0-9_][A-Za-z0-9_./-]*)\s*:(?:\s+(.*)|\s*)$")
BLOCK = re.compile(r"^[>|][+-]?[0-9]*\s*(#.*)?$")


def top_level(zeilen):
    """Oberste Schlüssel -> (Inline-Wert, Folgezeilen)."""
    res, cur = {}, None
    for z in zeilen:
        if z.strip() == "" or z.lstrip().startswith("#"):
            if cur is not None and z.strip() == "":
                res[cur][1].append(z)
            continue
        if z[0] not in " \t":
            m = KEY.match(z.rstrip())
            if m:
                cur = m.group(1)
                res[cur] = ((m.group(2) or "").strip(), [])
                continue
            cur = None
            continue
        if cur is not None:
            res[cur][1].append(z)
    return res


def wert(inline, folge):
    """Skalar als Text (einzeilig, quoted, Plain mit Folgezeilen oder Block)."""
    if BLOCK.match(inline):
        nb = [z for z in folge if z.strip()]
        if not nb:
            return ""
        ein = min(len(z) - len(z.lstrip(" \t")) for z in nb)
        zl = [z[ein:].rstrip() for z in folge]
        while zl and zl[-1] == "":
            zl.pop()
        if inline.startswith("|"):
            return "\n".join(zl)
        out, para = [], []
        for z in zl:
            if z == "":
                out.append(" ".join(para)); para = []
            else:
                para.append(z.strip())
        out.append(" ".join(para))
        return "\n".join(out)
    teile = [inline] + [z.strip() for z in folge if z.strip()]
    t = " ".join(x for x in teile if x != "").strip()
    if t[:1] == '"':
        m = re.match(r'^"((?:[^"\\]|\\.)*)"', t)
        if m:
            s = m.group(1)
            return re.sub(r"\\(.)", lambda k: "\n" if k.group(1) == "n" else k.group(1), s)
        return t[1:]
    if t[:1] == "'":
        m = re.match(r"^'((?:[^']|'')*)'", t)
        if m:
            return m.group(1).replace("''", "'")
        return t[1:]
    return re.sub(r"\s+#.*$", "", t)


def frontmatter(text):
    zeilen = text.lstrip("\ufeff").splitlines()
    k = 0
    while k < len(zeilen) and zeilen[k].strip() == "":
        k += 1
    if k >= len(zeilen) or zeilen[k].strip() != "---":
        return {}
    fm = []
    for z in zeilen[k + 1:]:
        if z.strip() in ("---", "..."):
            break
        fm.append(z)
    return top_level(fm)


def ist_falsch(s):
    return s.strip().strip("\"'").lower() == "false"


FALSE_INLINE = r"[\"']?{k}[\"']?\s*:\s*[\"']?false[\"']?\s*(?:[,}}#]|$)"


def hat_false(inline, folge, schluessel, wert_="false"):
    muster = re.compile(FALSE_INLINE.replace("false", wert_).format(k=re.escape(schluessel)), re.I)
    if muster.search(inline):
        return True
    return any(muster.search(z.strip()) for z in folge)


def lies_skill(skill_dir):
    pfad = os.path.join(skill_dir, "SKILL.md")
    try:
        with open(pfad, encoding="utf-8", errors="replace") as f:
            fm = frontmatter(f.read())
    except OSError as e:
        fehler(f"SKILL.md nicht lesbar: {kurz(pfad)} ({e.strerror})")
    desc = wert(*fm["description"]).strip() if "description" in fm else ""
    wtu = wert(*fm["when_to_use"]).strip() if "when_to_use" in fm else ""
    zeichen = len(desc) + len(wtu)
    tokens = (2 * zeichen + 6) // 7  # ceil(zeichen / 3,5)
    aus = set()  # Werkzeuge, für die ein beachteter Mechanismus die Beschreibung ausblendet
    implizit_aus = False
    dmi = "disable-model-invocation" in fm and wert(*fm["disable-model-invocation"]).strip().lower() == "true"
    # OpenCode: ist opencode/autoinvoke gesetzt, gewinnt es gegen disable-model-invocation (Doku, Abschnitt Frontmatter)
    oc_false = "metadata" in fm and hat_false(*fm["metadata"], "opencode/autoinvoke")
    oc_true = "metadata" in fm and hat_false(*fm["metadata"], "opencode/autoinvoke", "true")
    if oc_false or (dmi and not oc_true):
        aus.add("opencode")
    if dmi:
        aus.add("claude-code")
    y = os.path.join(skill_dir, "agents", "openai.yaml")
    if os.path.isfile(y):
        try:
            with open(y, encoding="utf-8", errors="replace") as f:
                ty = top_level(f.read().splitlines())
        except OSError as e:
            fehler(f"Datei nicht lesbar: {kurz(y)} ({e.strerror})")
        if "policy" in ty and hat_false(*ty["policy"], "allow_implicit_invocation"):
            implizit_aus = True  # codex: nur impliziter Aufruf verboten, Listung nicht dokumentiert -> sichtbar
    return desc != "", tokens, aus, implizit_aus


# ---------- Orte ----------
if orte_arg:
    orte = []
    for o in orte_arg:
        if not os.path.isdir(o):
            fehler(f"Ordner fehlt: {kurz(os.path.abspath(o))}")
        orte.append(os.path.abspath(o))
else:
    kandidaten = [os.path.join(HOME, ".config/opencode/skills"), os.path.join(HOME, ".claude/skills"),
                  os.path.join(HOME, ".agents/skills")]
    # Projekt: ab aktuellem Ordner aufwärts bis zur Git-Wurzel; ohne Git nur der aktuelle Ordner
    cwd = os.getcwd()
    kette, d, wurzel = [cwd], cwd, False
    while os.path.dirname(d) != d:
        if os.path.exists(os.path.join(d, ".git")):
            wurzel = True
            break
        d = os.path.dirname(d)
        kette.append(d)
    if os.path.exists(os.path.join(d, ".git")):
        wurzel = True
    if not wurzel:
        kette = [cwd]
    for d in kette:
        for u in (".opencode/skills", ".claude/skills", ".agents/skills"):
            kandidaten.append(os.path.join(d, u))
    orte = [k for k in kandidaten if os.path.isdir(k)]

gesehen, orte_eindeutig = set(), []
for o in orte:
    r = os.path.realpath(o)
    if r not in gesehen:
        gesehen.add(r)
        orte_eindeutig.append(o)
orte = orte_eindeutig


def finde(ort):
    res = []

    def rek(d, rel, stack):
        try:
            namen = sorted(os.listdir(d))
        except OSError as e:
            fehler(f"Ordner nicht lesbar: {kurz(d)} ({e.strerror})")
        for n in namen:
            if n.startswith(".") or n in SKIP:
                continue
            p = os.path.join(d, n)
            if not os.path.isdir(p):
                continue
            real = os.path.realpath(p)
            if real in stack:
                continue
            r = rel + [n]
            if os.path.isfile(os.path.join(p, "SKILL.md")):
                res.append(("/".join(r), p))
            elif len(r) < TIEFE:
                rek(p, r, stack | {real})

    if os.path.isfile(os.path.join(ort, "SKILL.md")):
        res.append((os.path.basename(ort.rstrip("/")), ort))
    else:
        rek(ort, [], {os.path.realpath(ort)})
    return res


# ---------- Lock ----------
if locks_arg:
    lock_dateien = locks_arg
else:
    lock_dateien = [p for p in ("./skills-lock.json", os.path.join(HOME, ".agents/.skill-lock.json")) if os.path.isfile(p)]
eintraege = {}  # Name -> (Version, Eintrag), erster Treffer gewinnt
for lf in lock_dateien:
    try:
        with open(lf, encoding="utf-8") as f:
            daten = json.load(f)
    except (OSError, ValueError) as e:
        fehler(f"Lock nicht lesbar: {kurz(os.path.abspath(lf))} ({type(e).__name__})")
    ver = daten.get("version") if isinstance(daten, dict) else None
    sk = daten.get("skills") if isinstance(daten, dict) else None
    if not isinstance(ver, int) or isinstance(ver, bool) or not isinstance(sk, dict) \
            or not all(isinstance(v, dict) for v in sk.values()):
        fehler(f"Lock ungültig: {kurz(os.path.abspath(lf))}")
    for name, e in sk.items():
        eintraege.setdefault(name, (ver, e))

# ---------- Auswertung ----------
zeilen, ziele = [], {}
n_sicht = tokens_sum = n_aus = n_ohne_herkunft = n_abw = 0
for ort in orte:
    for sid, sdir in finde(ort):
        ort_kurz = kurz(ort)
        real = os.path.realpath(sdir)
        hat_desc, tokens, aus, implizit_aus = lies_skill(sdir)
        blick = WERKZEUGE if werkzeug == "alle" else [werkzeug]
        grund = [w for w in WERKZEUGE if w in aus]
        ganz_aus = all(w in aus for w in blick)
        name = sid.split("/")[-1]
        if name in eintraege:
            ver, e = eintraege[name]
            quelle = str(e.get("source") or "unbekannt")
            commit = str(e.get("commit") or "")
            herkunft = f"{quelle}@{commit[:12] if commit else 'ohne-commit'}"
            gespeichert = str(e.get("computedHash") or "")
            if ver >= 3 or not gespeichert:
                hs = "nicht-prüfbar"
            else:
                hs = "ok" if computed_hash(sdir) == gespeichert else "ABWEICHUNG"
        else:
            herkunft, hs = "ohne", "ohne-lock"
        if not hat_desc:
            status, tokens = "ohne-beschreibung", 0
        elif ganz_aus:
            status = "ausgeblendet=" + ",".join(w for w in grund if w in blick)
        else:
            status = "sichtbar"
        zeile = f"{status} {tokens} {sid} ort={ort_kurz} herkunft={herkunft} hash={hs}"
        if hat_desc and status == "sichtbar" and grund and werkzeug == "alle":
            zeile += " ausgeblendet=" + ",".join(grund)
        if hat_desc and implizit_aus:
            zeile += " implizit-aus=codex"
        if real in ziele:
            zeile += f" doppelt={ziele[real]}"
        else:
            ziele[real] = ort_kurz
            if status == "sichtbar":
                n_sicht += 1
                tokens_sum += tokens
            elif status.startswith("ausgeblendet="):
                n_aus += 1
            if herkunft == "ohne":
                n_ohne_herkunft += 1
            if hs == "ABWEICHUNG":
                n_abw += 1
        zeilen.append(zeile)

for z in zeilen:
    print(z)
print(f"SUMME sichtbar={n_sicht} tokens={tokens_sum} ausgeblendet={n_aus} ohne-herkunft={n_ohne_herkunft} abweichung={n_abw}")

gruende, rc = [], 0
if max_tokens is not None and tokens_sum > max_tokens:
    gruende.append(f"Summe {tokens_sum} > max {max_tokens}")
    rc = 1
if n_abw:
    gruende.append(f"Hash-ABWEICHUNG {n_abw}")
    rc = 1
if check:
    if shutil.which("skills"):
        sys.stdout.flush()
        env = dict(os.environ, DISABLE_TELEMETRY="1", DO_NOT_TRACK="1")
        try:
            cr = subprocess.run(["skills", "check"], env=env).returncode
        except OSError as e:
            fehler(f"skills check nicht ausführbar ({e.strerror})")
        if cr != 0:
            gruende.append(f"skills check Exit {cr}")
            rc = 1
    else:
        print("UNGEPRÜFT: skills-CLI nicht installiert")
        gruende.append("--check nicht prüfbar, skills-CLI fehlt")
        if rc == 0:
            rc = 3
print("OK: skills-status" if not gruende else f"FAIL: skills-status ({', '.join(gruende)})")
sys.exit(rc)
PYEOF
