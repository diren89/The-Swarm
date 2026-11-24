# Beispiel-Rollen für OpenCode

Optional, nur ein Beispiel. Überblick, Platzhalter und Grenzen: [../README.md](../README.md). Status: **erprobt** an der lokalen Vorlage; die Dateien hier über [die Probe](../probe/git-sperren.md) gegenprüfen.

## Dateien und Ziel

| Datei hier | Ziel |
|---|---|
| `agents/<id>.md` (7) | `~/.config/opencode/agents/<id>.md` (global) oder `.opencode/agents/<id>.md` (Projekt) |
| `../gemeinsam/skill-orchestrierung/` | `~/.config/opencode/skills/orchestrierung/` (oder `.opencode/skills/orchestrierung/`) |
| `opencode.json.ausschnitt` | in `opencode.json` zusammenführen (nur nach Diff und Freigabe) |

Die Agent-ID ist der Dateiname. Vorhandene Dateien gleichen Namens nicht überschreiben.

## Aufbau einer Agentdatei

YAML-Kopf (`description`, `mode`, `steps`, `permissions`, auskommentiertes `model`), darunter der Rollentext aus `../gemeinsam/rollen.md`.

- **Modell:** `# model: <provider>/<MODELL_…>` auskommentiert. Platzhalter ersetzen, Kommentarzeichen entfernen. Beim `reviewer` **Pflicht: Modell einer anderen Familie als der Autor.**
- **Rechte (`permissions`)** sind eine geordnete Liste; die letzte passende Regel gewinnt. `reviewer`, `researcher`, `scout` und `editor-lite` beginnen mit „alles verboten“ und erlauben einzeln (Allowlist, §5.5). `coordinator`, `coordinator-code` und `implementer` behalten die Grundrechte und sperren gezielt (Denylist für Git-Zerstörer, Allowlists für `subagent` und `skill`):
  - `coordinator`: `subagent` nur die sechs Rollen; Git-Zerstörer auf `ask`.
  - `coordinator-code`, `implementer`: Git-Zerstörer auf `deny` (`push`, `reset --hard`, `clean`, `branch -D/-d/--delete`, `tag -d/--delete`, `filter-branch`, `filter-repo`, `update-ref -d`, `worktree remove --force`, `checkout -- `, `restore`); `subagent`-Allowlist; `skill`-Allowlist (Skills einzeln freigeben).
  - `reviewer`: read-only (`edit` nur unter `.agent/work/`), Shell nur lesend per Denylist; `subagent` nur `scout`.
  - `researcher`, `scout`: read-only, Web, `edit` nur unter `.agent/work/`.
  - `editor-lite`: `edit` erlaubt, Shell nur `mv`, `git mv`, `git diff`, `git status`, `ls`.
- **Schrittlimit:** `steps` (`implementer` 50, `reviewer` 30, `researcher` 30, `scout` 20, `editor-lite` 25). Bei Erreichen schreibt der Agent nur noch eine Zusammenfassung.
- **Dienste und MCP-Werkzeuge:** In `coordinator-code` und `implementer` steht ein Kommentar, an dessen Stelle Sperren für Dienste der eigenen Installation gehören (`{ action: "<dienst>_*", resource: "*", effect: deny }`). Der `coordinator-code` soll einen schlanken Werkzeugsatz haben (§5.1.2).

## Unteragents und Tiefe

Die `subagent`-Allowlisten legen fest, wer wen aufrufen darf. Die Kette `coordinator` → `coordinator-code` → `implementer` → `scout` braucht Verschachtelungstiefe: in `opencode.json` `experimental.subagent_depth` (Ausschnitt: 3). **Experimentell**; vor dem ersten echten Einsatz die Kette mit einem Probeauftrag einmal durchlaufen (§5.1.2 Punkt 4). Agent-Rechte werden nicht vom Elternagent geerbt, also Sperren in jedem Agent.

## Prüfer anderer Familie

Pflicht. `reviewer` und Plankritik brauchen ein Modell anderer Familie als der Autor. Ist keines verfügbar, weist der Koordinator darauf hin und fragt die Nutzerin, ob das Review mit dem gleichen Modell bzw. der gleichen Familie erfolgen soll; nicht stillschweigend.

## Prüfen

1. `# model:`-Zeilen und Dienst-Sperren anpassen, Dateien kopieren.
2. [Probe `git-sperren.md`](../probe/git-sperren.md) mit dem `implementer`: erwartet 1 Befehl ausgeführt, 4 abgelehnt, Repo danach unverändert.
3. Rechte nach jeder Änderung mit einem echten Lauf je Rolle prüfen, nicht nur in der Datei lesen (§5.5).
