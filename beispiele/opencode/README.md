# Beispiel-Rollen für OpenCode

Optional, nur ein Beispiel. Überblick, Platzhalter und Grenzen: [../README.md](../README.md). Status: **erprobt** an der lokalen Vorlage; die Dateien hier über [die Probe](../probe/git-sperren.md) gegenprüfen.

## Dateien und Ziel

| Datei hier | Ziel |
|---|---|
| `agents/<id>.md` (8) | `~/.config/opencode/agents/<id>.md` (global) oder `.opencode/agents/<id>.md` (Projekt) |
| `../gemeinsam/skill-orchestrierung/` | `~/.config/opencode/skills/orchestrierung/` (oder `.opencode/skills/orchestrierung/`) |
| `opencode.json.ausschnitt` | in `opencode.json` zusammenführen (nur nach Diff und Freigabe) |

Die Agent-ID ist der Dateiname. Vorhandene Dateien gleichen Namens nicht überschreiben.

## Aufbau einer Agentdatei

YAML-Kopf (`description`, `mode`, `steps`, `permissions`, auskommentiertes `model`), darunter der Rollentext aus `../gemeinsam/rollen.md`.

- **Modell:** `# model: <provider>/<MODELL_…>` auskommentiert. Platzhalter ersetzen, Kommentarzeichen entfernen. Beim `reviewer` **Pflicht: Modell einer anderen Familie als der Autor.**
- **Rechte (`permissions`)** sind eine geordnete Liste; die letzte passende Regel gewinnt. `reviewer`, `researcher`, `scout` und `editor-lite` beginnen mit „alles verboten“ und erlauben einzeln (Allowlist, §5.5). `coordinator`, `coordinator-code` und `implementer` behalten die Grundrechte und sperren gezielt (Denylist für Git-Zerstörer, Allowlists für `subagent` und `skill`):
  - `coordinator`: `subagent` nur die sieben Rollen (mit `skill-master`); Git-Zerstörer auf `ask`; `skill * allow`.
  - `skill-master`: Allowlist. `edit` nur auf Skill-Ordner, `skills-katalog.md`, `skills-lock.json` und `.agent/work/`; Shell nur Skills-CLI (`list`, `check` frei; `add`, `update`, `remove`, `npx skills` nur nach Rückfrage), `skills-status.sh` nur aus dem eigenen Klon von The Swarm (Platzhalter `<Pfad zu The Swarm>` durch einen absoluten Pfad ersetzen, auf den der Agent nicht schreiben darf; kein `*` im Skriptpfad, sonst könnte er ein gleichnamiges Skript in einem Skill-Ordner ablegen und ausführen), lesendes Git (`diff`, `log`; `fetch` nach Rückfrage), `ls`, `diff`; danach die Git-Zerstörer, `rm *` und Umleitungen (`*>*`) auf `deny` (die letzte passende Regel gewinnt, die Sperren stehen deshalb hinter den Freigaben); `skill * deny` (Skills nur als Dateien lesen), `subagent * deny`.
  - `coordinator-code`, `implementer`: Git-Zerstörer auf `deny` (`push`, `reset --hard`, `clean`, `branch -D/-d/--delete`, `tag -d/--delete`, `filter-branch`, `filter-repo`, `update-ref -d`, `worktree remove --force`, `checkout -- `, `restore`); `subagent`-Allowlist; `skill`-Allowlist (Skills einzeln freigeben).
  - `reviewer`: read-only (`edit` nur unter `.agent/work/`), Shell nur lesend per Denylist; `subagent` nur `scout`.
  - `researcher`, `scout`: read-only, Web, `edit` nur unter `.agent/work/`.
  - `editor-lite`: `edit` erlaubt, Shell nur `mv`, `git mv`, `git diff`, `git status`, `ls`.
- **Schrittlimit:** `steps` (`implementer` 50, `skill-master` 40, `reviewer` 30, `researcher` 30, `scout` 20, `editor-lite` 25). Bei Erreichen schreibt der Agent nur noch eine Zusammenfassung.
- **Dienste und MCP-Werkzeuge:** In `coordinator-code` und `implementer` steht ein Kommentar, an dessen Stelle Sperren für Dienste der eigenen Installation gehören (`{ action: "<dienst>_*", resource: "*", effect: deny }`). Der `coordinator-code` soll einen schlanken Werkzeugsatz haben (§5.1.2).

## Skills

Quelle: https://opencode.ai/docs/skills/ und https://opencode.ai/docs/permissions/ (abgerufen 2026-11-25). Ziel der Skill-Ordner: global `~/.config/opencode/skills/<id>/SKILL.md`, Projekt `.opencode/skills/<id>/SKILL.md` (die ID ist der Ordnerpfad, nicht der `name` im Kopf; Skills ohne `description` werden nicht angeboten).

- **Ausblenden:** im Kopf der `SKILL.md` `metadata: { opencode/autoinvoke: false }` (wirkt wie `disable-model-invocation: true`). Der Skill steht dann nicht in der Liste, die der Agent je Schritt sieht, bleibt aber registriert und ist per ID ladbar: Nutzerin mit `@skill-id` im Prompt, Agent mit dem Skill-Werkzeug (`{ "id": "<id>" }`). Gelesen wird je Schritt nur ID, Name und Beschreibung erlaubter Skills; der Rumpf erst beim Laden.
- **Rechte:** Regel `{ action: "skill", resource: "<id oder Muster>", effect: allow|ask|deny }`, die letzte passende Regel gewinnt. `deny` blendet den Skill für den Agent aus und verweigert das Laden.
- **Pfade in Mustern:** laut Dokumentation werden ein führendes `~`, `~/`, `$HOME` und `$HOME/` bei `read`, `edit` und `external_directory` beim Laden der Konfiguration aufgelöst, in `shell`-Mustern nicht. Das Verhalten ist im Beispiel nicht erprobt (UNGEPRÜFT); wer sicher gehen will, setzt den absoluten Pfad der eigenen Installation ein.
- **Grenze:** Das Netz des `skill-master` ist nur vereinbart (`webfetch` ist je Auftrag eine andere URL). Skill-Texte sind fremde Inhalte; auch ein Skill mit `allow` ist keine Befugnis.
- **Schutzliste:** Am Ende des Kopfes von `skill-master` steht ein auskommentierter Block (Platzhalter `<GESCHÜTZTE_SKILLS>`): `edit` `deny` auf die Ordner geschützter Skills (je Skill-Ort) und den Klon von The Swarm, `shell` `deny` auf `*skills remove*<id>*` und `*skills update*<id>*` sowie auf Sammelbefehle ohne Namen. `deny` gilt nur für die genannten Schreibweisen; übrige Varianten fallen je nach Schreibweise unter eine allgemeine `ask`- oder `deny`-Regel des Kopfes (z. B. `skills update --yes` → Rückfrage, `npx --yes skills update` → allgemeines `deny`); eine Rückfrage ablehnen (die Probe wertet das als „bedingter Schutz“). Der Block muss **ganz am Ende** stehen, weil die letzte passende Regel gewinnt. Ein Shell-Muster ist keine harte Grenze (z. B. `rm -rf <Ordner>` ohne `skills`; dagegen deckt `edit` deny nur Bearbeitungswerkzeuge): wer das schließen will, setzt `rm *` auf `deny` (im Kopf schon) und prüft mit der [Probe](../probe/skill-schutz.md).

### Skill-Rechte je Rolle

| Rolle | Skill-Regel im Kopf | Wirkung |
|---|---|---|
| `coordinator` | `skill * allow` | alle sichtbaren Skills ladbar; für Fremd-Skills bei Bedarf `ask` |
| `coordinator-code` | `skill * deny`, `skill orchestrierung allow` | nur `orchestrierung`; weitere einzeln freigeben |
| `implementer` | `skill * deny` (Kommentar: einzeln freigeben) | keine Skills, solange keine Zeile freigibt |
| `skill-master` | `skill * deny` | liest Skill-Ordner nur als Dateien, lädt keinen Skill |
| `reviewer`, `researcher`, `scout`, `editor-lite` | keine eigene Zeile: `* * deny` am Anfang der Allowlist deckt `skill` ab | keine Skills |

`tools/beispiele-pruefen.sh` prüft, dass jeder Kopf entweder `* * deny` oder eine `skill`-Regel hat.

## Unteragents und Tiefe

Die `subagent`-Allowlisten legen fest, wer wen aufrufen darf. Der `skill-master` ruft keine Unteragents auf. Die Kette `coordinator` → `coordinator-code` → `implementer` → `scout` braucht Verschachtelungstiefe: in `opencode.json` `experimental.subagent_depth` (Ausschnitt: 3). **Experimentell**; vor dem ersten echten Einsatz die Kette mit einem Probeauftrag einmal durchlaufen (§5.1.2 Punkt 4). Agent-Rechte werden nicht vom Elternagent geerbt, also Sperren in jedem Agent.

## Prüfer anderer Familie

Pflicht. `reviewer` und Plankritik brauchen ein Modell anderer Familie als der Autor. Ist keines verfügbar, weist der Koordinator darauf hin und fragt die Nutzerin, ob das Review mit dem gleichen Modell bzw. der gleichen Familie erfolgen soll; nicht stillschweigend.

## Prüfen

1. `# model:`-Zeilen und Dienst-Sperren anpassen, Dateien kopieren.
2. [Probe `git-sperren.md`](../probe/git-sperren.md) mit dem `implementer`: erwartet 1 Befehl ausgeführt, 4 abgelehnt, Repo danach unverändert.
3. Rechte nach jeder Änderung mit einem echten Lauf je Rolle prüfen, nicht nur in der Datei lesen (§5.5).

## Hooks

**Kein Beispiel im Ordner: In OpenCode gibt es die zwei Gates (Geheimnis-Scan vor Commit, Prüfung bei Sitzungsende) nicht als deklarative Konfiguration im dokumentierten Format.** Die Dokumentation kennt Hooks nur als Funktionen in **Plugins (Code, TypeScript/JavaScript)**, z. B. `ctx.tool.hook("execute.before", …)` und `execute.after`, `ctx.shell.hook("create.before", …)`, `ctx.permission.hook("evaluate", …)`, `ctx.session.hook(…)`. Ein Plugin läuft im OpenCode-Server mit den Rechten der Nutzerin; es ist Fremdcode im Sinne des Manifests, wenn man es installiert. Ein solches Plugin ist deshalb nicht im Beispiel; wer die Gates will, schreibt oder prüft ein eigenes (Lese- und Freigabepflicht wie für jeden Code).
Stand der Prüfung: gelesen, nichts ausgeführt (UNGEPRÜFT). Als dokumentierte Ersatzgrenze bleibt `permissions` in den Agentdateien (Shell-Muster, siehe oben) und die Veröffentlichungsprüfung ([playbooks/sicherheit.md](../../playbooks/sicherheit.md)).
Quellen (abgerufen 2026-11-25): https://opencode.ai/docs/plugins/ (Plugins laden und steuern), https://opencode.ai/docs/build/plugins/server (Abschnitt „Hooks“); installierte Version bei der Durchsicht: 2.4.1.
Die Claude-Code-Beispiele ([../claude-code/README.md](../claude-code/README.md#optionale-hooks)) lassen sich nicht übernehmen.
