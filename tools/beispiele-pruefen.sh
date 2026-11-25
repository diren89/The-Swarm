#!/usr/bin/env bash
# Prüft die optionalen Beispiel-Rollen (beispiele/) auf Drift und Lesbarkeit.
# Die Agent-Dateien und Koordinator-Ausschnitte sind ERZEUGT: ändern nur in beispiele/gemeinsam/rollen.md (Text) bzw.
# beispiele/gemeinsam/koepfe/ (Kopf), dann `python3 tools/beispiele-bauen.py`. Dieses Skript schreibt nie.
# Aufruf:  bash tools/beispiele-pruefen.sh [WURZEL]      (WURZEL = Repo-Ordner, Standard: Ordner über tools/)
# Prüft:
#   0. Erzeugt == eingecheckt: tools/beispiele-bauen.py wird im Speicher ausgeführt; jede abweichende oder fehlende
#      Datei ergibt FAIL (Abhilfe: `python3 tools/beispiele-bauen.py`).
#   1. Der Rollentext jeder Rolle aus beispiele/gemeinsam/rollen.md (Abschnitt `## <id>`) steht identisch im Rumpf
#      jeder Werkzeugdatei (Markdown: Text nach dem YAML-Kopf; TOML: `developer_instructions`; Ausschnitte: Text
#      zwischen den Markern). Der Koordinator-Text steht in den Ausschnitten von Claude Code und Codex.
#   2. YAML-Köpfe parsen (PyYAML, sonst Ruby), TOML parst (python3 tomllib), JSON-Ausschnitte parsen.
#      OpenCode: jeder Kopf hat `* * deny` oder eine `skill`-Regel; `skill-master` ist eine Allowlist (`* * deny` zuerst, edit nur auf
#      Skill-Ordner, Katalog, Lock und .agent/work, Git-Sperren nach den Freigaben, `skill * deny`, kein subagent allow);
#      `coordinator` darf `skill-master` aufrufen und hat eine explizite `skill`-Regel.
#   3. Nur dokumentierte Felder (Claude Code: Frontmatter; Codex: TOML-Schlüssel); `Agent` nur bei coordinator-code
#      und implementer; Git-Sperren in settings.json und the-swarm.rules vorhanden.
#      Optionale Hooks (Claude Code): settings.hooks.json.ausschnitt parst, nur dokumentierte Felder, Skripte da und `bash -n` sauber.
#   4. Anonymität: keine Namen, Firmen, Benutzerpfade, Gateway-, Dienst- oder Modellnamen.
# Ausgabe je Prüfung `OK|FAIL <Text>`, zum Schluss `OK|FAIL: n OK, m FAIL`. Exit 0 nur ohne FAIL.
# Ein Grün sagt nichts über das Laufzeitverhalten der Werkzeuge (siehe beispiele/README.md, Status).
root=${1:-$(cd "$(dirname "$0")/.." && pwd)}
[ -d "$root/beispiele" ] || { echo "FAIL: $root/beispiele fehlt" >&2; exit 2; }
exec python3 - "$root" <<'PYEOF'
import json, os, re, subprocess, sys, tomllib

root = sys.argv[1]
bd = os.path.join(root, "beispiele")
ok = fail = 0

def res(good, text):
    global ok, fail
    if good: ok += 1
    else: fail += 1
    print(("OK   " if good else "FAIL ") + text)

def read(p):
    with open(p, encoding="utf-8") as f: return f.read()

IDS = ["coordinator", "coordinator-code", "implementer", "reviewer", "researcher", "scout", "editor-lite", "skill-master"]
SUB = [i for i in IDS if i != "coordinator"]

# --- Erzeugt == eingecheckt (Vergleich im Speicher, nichts wird geschrieben) ---
try:
    import importlib.util; sys.dont_write_bytecode = True
    spec = importlib.util.spec_from_file_location("beispiele_bauen", os.path.join(root, "tools", "beispiele-bauen.py"))
    bauen = importlib.util.module_from_spec(spec); spec.loader.exec_module(bauen)
    erzeugt = bauen.erzeuge(root)
    for rel, inhalt in sorted(erzeugt.items()):
        p = os.path.join(root, rel)
        alt = read(p) if os.path.isfile(p) else None
        res(alt == inhalt, f"erzeugt == eingecheckt: {rel}" + ("" if alt == inhalt else (" (fehlt)" if alt is None else " (weicht ab: python3 tools/beispiele-bauen.py)")))
except SystemExit as e:
    res(False, f"beispiele-bauen.py: {e}")
except Exception as e:
    res(False, f"beispiele-bauen.py nicht ausführbar ({e})")

# --- Rollentexte ---
roles, cur = {}, None
for line in read(os.path.join(bd, "gemeinsam", "rollen.md")).split("\n"):
    m = re.match(r"^## (\S+)$", line)
    if m and m.group(1) in IDS:
        cur = m.group(1); roles[cur] = []; continue
    if cur: roles[cur].append(line)
roles = {k: "\n".join(v).strip() for k, v in roles.items()}
res(sorted(roles) == sorted(IDS) and all(roles.values()), f"rollen.md: {len(roles)} von {len(IDS)} Rollen mit Text")

def split_md(p):
    t = read(p)
    m = re.match(r"^---\n(.*?)\n---\n(.*)$", t, re.S)
    return (m.group(1), m.group(2).strip()) if m else (None, None)

# YAML-Parser: PyYAML, sonst Ruby
def yaml_parse(head):
    try:
        import yaml
        return yaml.safe_load(head)
    except ImportError:
        pass
    try:
        r = subprocess.run(["ruby", "-ryaml", "-rjson", "-e", "puts JSON.generate(YAML.load(STDIN.read))"],
                           input=head, capture_output=True, text=True)
    except FileNotFoundError:
        raise RuntimeError("kein YAML-Parser (weder PyYAML noch Ruby)")
    if r.returncode != 0: raise ValueError(r.stderr.strip().splitlines()[0][-140:] if r.stderr.strip() else "YAML-Fehler")
    return json.loads(r.stdout)

CC_FIELDS = {"name", "description", "tools", "disallowedTools", "model", "maxTurns", "skills"}
CODEX_KEYS = {"name", "description", "developer_instructions", "model", "model_reasoning_effort"}

# --- OpenCode ---
for r in IDS:
    p = os.path.join(bd, "opencode", "agents", r + ".md")
    if not os.path.isfile(p): res(False, f"opencode/{r}.md fehlt"); continue
    head, body = split_md(p)
    res(head is not None and body == roles[r], f"opencode/{r}.md: Rollentext identisch")
    try:
        y = yaml_parse(head)
        good = isinstance(y, dict) and y.get("description") and y.get("mode") in ("primary", "subagent") and isinstance(y.get("permissions"), list)
        good = good and all(isinstance(x, dict) and {"action", "resource", "effect"} <= set(x) for x in y["permissions"])
        res(bool(good), f"opencode/{r}.md: YAML-Kopf parsebar, Felder und permissions-Liste ok")
        if r in ("implementer", "coordinator-code"):
            pats = [x["resource"] for x in y["permissions"] if x["action"] == "shell" and x["effect"] == "deny"]
            need = ["git push*", "git reset --hard*", "git clean*", "git branch -D*"]
            res(all(n in pats for n in need), f"opencode/{r}.md: Git-Sperren (deny) vorhanden")
        if r == "reviewer":
            res(not any(x["action"] == "edit" and x["effect"] == "allow" and not ".agent/work" in x["resource"] for x in y["permissions"]),
                "opencode/reviewer.md: edit nur unter .agent/work erlaubt")
        pm = y["permissions"]
        # Skill-Regel bewusst gesetzt: Allowlist (`* * deny`) oder eigene `skill`-Regel
        res(any(x["action"] == "skill" for x in pm) or (pm[0]["action"] == "*" and pm[0]["resource"] == "*" and pm[0]["effect"] == "deny"),
            f"opencode/{r}.md: Skill-Rechte bewusst gesetzt (`* * deny` oder `skill`-Regel)")
        if r == "coordinator":
            res(any(x["action"] == "subagent" and x["resource"] == "skill-master" and x["effect"] == "allow" for x in pm),
                "opencode/coordinator.md: subagent skill-master allow")
            res(any(x["action"] == "skill" for x in pm), "opencode/coordinator.md: explizite skill-Regel")
        if r == "skill-master":
            res(pm[0] == {"action": "*", "resource": "*", "effect": "deny"}, "opencode/skill-master.md: erste Regel `* * deny` (Allowlist)")
            edits = [x["resource"] for x in pm if x["action"] == "edit" and x["effect"] == "allow"]
            res(bool(edits) and all(any(k in e for k in ("skills", "skills-katalog.md", "skills-lock.json", ".agent/work")) for e in edits),
                "opencode/skill-master.md: edit nur auf Skill-Ordner, Katalog, Lock und .agent/work")
            deny = [x["resource"] for x in pm if x["action"] == "shell" and x["effect"] == "deny"]
            res(all(n in deny for n in ["git push*", "git reset --hard*", "git clean*", "git branch -D*"]), "opencode/skill-master.md: Git-Sperren (deny) vorhanden")
            last = lambda a: [x["effect"] for x in pm if x["action"] == a and x["resource"] == "*"]
            res(last("skill")[-1:] == ["deny"], "opencode/skill-master.md: skill * deny (Skills werden nicht geladen)")
            res(not any(x["action"] == "subagent" and x["effect"] != "deny" for x in pm) and last("subagent")[-1:] == ["deny"],
                "opencode/skill-master.md: kein subagent allow")
            # Reihenfolge (letzte passende Regel gewinnt): Git-Sperren stehen nach allen Shell-Freigaben
            idx = lambda f: [i for i, x in enumerate(pm) if x["action"] == "shell" and f(x)]
            ia, id_ = idx(lambda x: x["effect"] in ("allow", "ask")), idx(lambda x: x["effect"] == "deny" and x["resource"] in ("git push*", "rm *", "*>*"))
            res(bool(ia) and bool(id_) and max(ia) < min(id_), "opencode/skill-master.md: Shell-Sperren stehen nach den Shell-Freigaben (letzte Regel gewinnt)")
            # Skripte nur über festen Pfad: kein `*` vor `.sh` in einer Shell-Freigabe (sonst ausführbar aus beschreibbaren Skill-Ordnern)
            res(not any(x["action"] == "shell" and x["effect"] == "allow" and ".sh" in x["resource"] and "*" in x["resource"].split(".sh")[0] for x in pm),
                "opencode/skill-master.md: Skript-Freigaben ohne Platzhalter im Pfad")
    except Exception as e:
        res(False, f"opencode/{r}.md: YAML-Kopf nicht parsebar ({e})")

# --- Claude Code ---
for r in SUB:
    p = os.path.join(bd, "claude-code", "agents", r + ".md")
    if not os.path.isfile(p): res(False, f"claude-code/{r}.md fehlt"); continue
    head, body = split_md(p)
    res(head is not None and body == roles[r], f"claude-code/{r}.md: Rollentext identisch")
    try:
        y = yaml_parse(head)
        res(isinstance(y, dict) and y.get("name") == r and y.get("description"), f"claude-code/{r}.md: YAML-Kopf parsebar, name/description ok")
        res(set(y) <= CC_FIELDS, f"claude-code/{r}.md: nur dokumentierte Felder ({', '.join(sorted(set(y) - CC_FIELDS)) or 'keine fremden'})")
        tools = [t.strip() for t in str(y.get("tools", "")).split(",")]
        res(("Agent" in tools) == (r in ("coordinator-code", "implementer")), f"claude-code/{r}.md: Agent in tools nur bei coordinator-code und implementer")
        if r == "reviewer":
            res("Edit" in str(y.get("disallowedTools")) and "Write" in str(y.get("disallowedTools")) and "Edit" not in tools and "Write" not in tools,
                "claude-code/reviewer.md: Edit und Write gesperrt")
    except Exception as e:
        res(False, f"claude-code/{r}.md: YAML-Kopf nicht parsebar ({e})")

# --- Codex ---
for r in SUB:
    p = os.path.join(bd, "codex", "agents", r + ".toml")
    if not os.path.isfile(p): res(False, f"codex/{r}.toml fehlt"); continue
    try:
        with open(p, "rb") as f: t = tomllib.load(f)
        res(True, f"codex/{r}.toml: TOML parsebar")
        res(t.get("developer_instructions", "").strip() == roles[r], f"codex/{r}.toml: Rollentext identisch (developer_instructions)")
        res(t.get("name") == r and t.get("description") and set(t) <= CODEX_KEYS, f"codex/{r}.toml: name/description ok, nur Schlüssel {sorted(CODEX_KEYS)}")
    except Exception as e:
        res(False, f"codex/{r}.toml: TOML nicht parsebar ({e})")

# --- Koordinator-Ausschnitte ---
for tool, fn in (("claude-code", "CLAUDE.md.ausschnitt"), ("codex", "AGENTS.md.ausschnitt")):
    p = os.path.join(bd, tool, fn)
    m = re.search(r"<!-- the-swarm:coordinator:start -->\n(.*?)\n<!-- the-swarm:coordinator:ende -->", read(p) if os.path.isfile(p) else "", re.S)
    res(bool(m) and m.group(1).strip() == roles["coordinator"], f"{tool}/{fn}: Koordinator-Text identisch")

# --- JSON, TOML, Regeln ---
for rel in ("opencode/opencode.json.ausschnitt", "claude-code/settings.json.ausschnitt"):
    try:
        j = json.loads(read(os.path.join(bd, rel))); res(True, f"{rel}: JSON parsebar")
    except Exception as e:
        j = None; res(False, f"{rel}: JSON nicht parsebar ({e})")
    if rel.startswith("claude") and j:
        deny = j.get("permissions", {}).get("deny", [])
        need = ["Bash(git push *)", "Bash(git reset --hard *)", "Bash(git clean *)", "Bash(git branch -D *)"]
        res(all(n in deny for n in need), f"{rel}: permissions.deny enthält die Git-Sperren")
# Optionale Hooks (Claude Code): Ausschnitt parsebar, nur dokumentierte Felder, Skripte vorhanden und syntaktisch ok
try:
    hj = json.loads(read(os.path.join(bd, "claude-code", "settings.hooks.json.ausschnitt")))
    res(True, "claude-code/settings.hooks.json.ausschnitt: JSON parsebar")
except Exception as e:
    hj = None; res(False, f"claude-code/settings.hooks.json.ausschnitt: JSON nicht parsebar ({e})")
if hj is not None:
    HOOK_EVENTS = {"PreToolUse": "Bash", "Stop": None}
    HANDLER_FIELDS = {"type", "command", "args", "timeout", "statusMessage", "onFailure", "if", "async", "shell"}
    h = hj.get("hooks", {}) if isinstance(hj, dict) else {}
    good = set(hj) == {"hooks"} and set(h) == set(HOOK_EVENTS)
    for ev, m in HOOK_EVENTS.items():
        for grp in h.get(ev, []) if isinstance(h.get(ev), list) else []:
            good = good and set(grp) <= {"matcher", "hooks"} and (grp.get("matcher") == m)
            for hd in grp.get("hooks", []):
                good = good and hd.get("type") == "command" and set(hd) <= HANDLER_FIELDS and ".claude/hooks/" in hd.get("command", "")
                scr = re.search(r"\.claude/hooks/([A-Za-z0-9._-]+\.sh)", hd.get("command", ""))
                good = good and bool(scr) and os.path.isfile(os.path.join(bd, "claude-code", "hooks", scr.group(1)))
    res(bool(good), "claude-code/settings.hooks.json.ausschnitt: Ereignisse PreToolUse (Matcher Bash) und Stop, nur dokumentierte Felder, Skripte vorhanden")
    stop_hd = [hd for g in h.get("Stop", []) for hd in g.get("hooks", [])] if isinstance(h.get("Stop"), list) else []
    res(bool(stop_hd) and all(hd.get("onFailure") != "block" for hd in stop_hd), "claude-code/settings.hooks.json.ausschnitt: Stop-Hook blockiert nie bei Ausfall (kein onFailure block)")
hdir = os.path.join(bd, "claude-code", "hooks")
for sc in ("geheimnis-scan-vor-commit.sh", "pruefung-bei-sitzungsende.sh"):
    fp = os.path.join(hdir, sc)
    if not os.path.isfile(fp): res(False, f"claude-code/hooks/{sc} fehlt"); continue
    r = subprocess.run(["bash", "-n", fp], capture_output=True, text=True)
    res(r.returncode == 0, f"claude-code/hooks/{sc}: bash -n" + ("" if r.returncode == 0 else f" ({r.stderr.strip()[:100]})"))
    res(os.access(fp, os.X_OK), f"claude-code/hooks/{sc}: ausführbar")
try:
    with open(os.path.join(bd, "codex", "config.toml.ausschnitt"), "rb") as f: tomllib.load(f)
    res(True, "codex/config.toml.ausschnitt: TOML parsebar")
except Exception as e:
    res(False, f"codex/config.toml.ausschnitt: TOML nicht parsebar ({e})")
rp = os.path.join(bd, "codex", "rules", "the-swarm.rules")
rt = read(rp) if os.path.isfile(rp) else ""
res(all(f'pattern=["git", "{c}"' in rt for c in ("push", "reset", "clean", "branch")) and rt.count('decision="forbidden"') >= 5,
    "codex/rules/the-swarm.rules: prefix_rule mit decision=\"forbidden\" für push, reset, clean, branch")

# --- Pflichtdateien ---
need = ["README.md", "gemeinsam/skill-orchestrierung/SKILL.md", "probe/git-sperren.md", "opencode/README.md", "claude-code/README.md", "codex/README.md"]
need += ["gemeinsam/skill-fremd-review/SKILL.md"]
need += [f"gemeinsam/koepfe/{w}/skill-master.{e}" for w, e in (("opencode", "yaml"), ("claude-code", "yaml"), ("codex", "toml"))]
need += ["claude-code/settings.hooks.json.ausschnitt", "claude-code/hooks/geheimnis-scan-vor-commit.sh", "claude-code/hooks/pruefung-bei-sitzungsende.sh"]
need += [f"gemeinsam/skill-orchestrierung/templates/{t}.md" for t in ("auftrag", "bericht", "korrektur-brief", "phasenplan")]
miss = [n for n in need if not os.path.isfile(os.path.join(bd, n))]
res(not miss, "Pflichtdateien vorhanden" + (f" (fehlt: {', '.join(miss)})" if miss else ""))

# --- Anonymität (Muster aus Teilen, damit dieses Skript sich nicht selbst trifft) ---
parts = [("lite", "llm"), ("fellen", "stein"), ("job", "rad"), ("/Us", "ers/"), ("ampli", "tude"), ("atlas", "sian"), ("conden", "s"),
         ("ma", "ze"), ("run-", "workflow"), ("open-", "knowledge"), ("op", "us"), ("son", "net"), ("hai", "ku"), ("gp", "t-"),
         ("ter", "ra"), ("lu", "na"), ("23\\.11", "\\.2026")]
pat = re.compile("|".join("".join(x) for x in parts), re.I)
hits = []
targets = [os.path.join(dp, f) for dp, _, fs in os.walk(bd) for f in fs] + [os.path.join(root, "tools", n) for n in ("beispiele-pruefen.sh", "beispiele-bauen.py", "grundlast.sh", "update.sh")]
for fp in targets:
    if os.path.isfile(fp):
        for n, line in enumerate(read(fp).split("\n"), 1):
            if pat.search(line): hits.append(f"{os.path.relpath(fp, root)}:{n}")
res(not hits, "Anonymität: keine Namen, Pfade, Gateway-, Dienst- oder Modellnamen" + (f" (Treffer: {', '.join(hits[:5])})" if hits else ""))

print(("OK" if not fail else "FAIL") + f": {ok} OK, {fail} FAIL")
sys.exit(1 if fail else 0)
PYEOF
