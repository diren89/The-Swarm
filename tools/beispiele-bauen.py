#!/usr/bin/env python3
"""Erzeugt die Beispiel-Rollen aus einer Quelle (nur Standardbibliothek).

Aufruf:  python3 tools/beispiele-bauen.py [WURZEL]            baut (schreibt nur geänderte Dateien)
         python3 tools/beispiele-bauen.py --pruefen [WURZEL]  schreibt nichts, meldet abweichende Dateien (Exit 1)
WURZEL = Repo-Ordner (Standard: Ordner über tools/).

Quellen (nur dort ändern, danach bauen):
  beispiele/gemeinsam/rollen.md                        Rollentexte, Abschnitt `## <id>`
  beispiele/gemeinsam/koepfe/<werkzeug>/<rolle>.<ext>  Kopf je Werkzeug und Rolle (.yaml für OpenCode und Claude Code,
                                                       .toml für Codex: alles vor `developer_instructions`)
Erzeugt:
  beispiele/opencode/agents/<rolle>.md        (YAML-Kopf + Rollentext)
  beispiele/claude-code/agents/<rolle>.md     (ohne coordinator: dort ist der Koordinator die Hauptsitzung)
  beispiele/codex/agents/<rolle>.toml         (Kopf + developer_instructions)
  Koordinator-Abschnitt zwischen den Markern in claude-code/CLAUDE.md.ausschnitt und codex/AGENTS.md.ausschnitt
Der Rest der Ausschnitte bleibt von Hand gepflegt. Ergebnis ist deterministisch: ein zweiter Lauf ändert nichts.
Ausgabe: Zahl erzeugter, geänderter und unveränderter Dateien.
"""
import os
import re
import sys

IDS = ["coordinator", "coordinator-code", "implementer", "reviewer", "researcher", "scout", "editor-lite", "skill-master"]
SUB = [i for i in IDS if i != "coordinator"]
START = "<!-- the-swarm:coordinator:start -->\n"
ENDE = "\n<!-- the-swarm:coordinator:ende -->"


def read(p):
    with open(p, encoding="utf-8", newline="") as f:
        return f.read()


def rollen(bd):
    roles, cur = {}, None
    for line in read(os.path.join(bd, "gemeinsam", "rollen.md")).split("\n"):
        m = re.match(r"^## (\S+)$", line)
        if m and m.group(1) in IDS:
            cur = m.group(1)
            roles[cur] = []
            continue
        if cur:
            roles[cur].append(line)
    roles = {k: "\n".join(v).strip() for k, v in roles.items()}
    fehlt = [i for i in IDS if not roles.get(i)]
    if fehlt:
        sys.exit("FAIL: rollen.md ohne Text für: " + ", ".join(fehlt))
    return roles


def toml_string(text):
    """Mehrzeiliger TOML-String. Literal (''') wenn möglich, sonst Basic (\"\"\") mit Escaping."""
    ctrl = any(ord(c) < 32 and c not in "\n\t" or ord(c) == 127 for c in text)
    if "'''" not in text and not ctrl and "\r" not in text:
        return "'''\n" + text + "\n'''\n"
    esc = text.replace("\\", "\\\\").replace('"""', '\\"\\"\\"')
    esc = "".join(c if (ord(c) >= 32 and ord(c) != 127) or c in "\n\t" else "\\u%04x" % ord(c) for c in esc)
    if esc.endswith('"'):
        esc = esc[:-1] + '\\"'
    return '"""\n' + esc + '\n"""\n'


def erzeuge(root):
    """Gibt {relativer Pfad: Inhalt} zurück."""
    bd = os.path.join(root, "beispiele")
    roles = rollen(bd)
    kopf = lambda tool, r, ext: read(os.path.join(bd, "gemeinsam", "koepfe", tool, r + "." + ext))
    out = {}
    for tool, ids in (("opencode", IDS), ("claude-code", SUB)):
        for r in ids:
            h = kopf(tool, r, "yaml").rstrip("\n")
            out[f"beispiele/{tool}/agents/{r}.md"] = "---\n" + h + "\n---\n\n" + roles[r] + "\n"
    for r in SUB:
        h = kopf("codex", r, "toml")
        if not h.endswith("\n"):
            h += "\n"
        out[f"beispiele/codex/agents/{r}.toml"] = h + "developer_instructions = " + toml_string(roles[r])
    for tool, fn in (("claude-code", "CLAUDE.md.ausschnitt"), ("codex", "AGENTS.md.ausschnitt")):
        rel = f"beispiele/{tool}/{fn}"
        t = read(os.path.join(root, rel))
        i, j = t.find(START), t.find(ENDE)
        if i < 0 or j < i:
            sys.exit(f"FAIL: Marker fehlen in {rel}")
        out[rel] = t[: i + len(START)] + roles["coordinator"] + t[j:]
    return out


def main(argv):
    pruefen = "--pruefen" in argv
    args = [a for a in argv if not a.startswith("--")]
    root = args[0] if args else os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    if not os.path.isdir(os.path.join(root, "beispiele")):
        sys.exit(f"FAIL: {root}/beispiele fehlt")
    neu = geaendert = gleich = 0
    abweichend = []
    for rel, inhalt in sorted(erzeuge(root).items()):
        p = os.path.join(root, rel)
        alt = read(p) if os.path.isfile(p) else None
        if alt == inhalt:
            gleich += 1
            continue
        abweichend.append(rel)
        if alt is None:
            neu += 1
        else:
            geaendert += 1
        if not pruefen:
            os.makedirs(os.path.dirname(p), exist_ok=True)
            with open(p, "w", encoding="utf-8", newline="") as f:
                f.write(inhalt)
    if pruefen:
        for rel in abweichend:
            print("abweichend: " + rel)
        print(f"{'OK' if not abweichend else 'FAIL'}: {gleich} gleich, {len(abweichend)} abweichend")
        return 1 if abweichend else 0
    print(f"beispiele-bauen: {neu} neu, {geaendert} geändert, {gleich} unverändert")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
