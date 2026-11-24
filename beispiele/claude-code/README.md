# Beispiel-Rollen für Claude Code

Optional, nur ein Beispiel. Überblick, Platzhalter und Grenzen: [../README.md](../README.md). Status: **teilweise erprobt.** Git-Sperren erprobt (Claude Code 2.1.285, Projektordner mit diesen Agent-Dateien und `settings.json`): Subagent `implementer` lief, `git status` ausgeführt, `reset --hard`, `clean -fd`, `branch -D`, `push` vom Werkzeug abgelehnt, auch bei allgemein erlaubtem `Bash`; Repo danach unverändert. Übrige Rollen und Modellzuweisung nicht einzeln geprüft.

## Dateien und Ziel

| Datei hier | Ziel |
|---|---|
| `agents/<id>.md` (6) | `~/.claude/agents/<id>.md` (global) oder `.claude/agents/<id>.md` (Projekt) |
| `CLAUDE.md.ausschnitt` | Koordinator-Text: am Ende von `~/.claude/CLAUDE.md` bzw. der Projekt-`CLAUDE.md` ergänzen (der Koordinator ist die Hauptsitzung, kein Agent) |
| `settings.json.ausschnitt` | Git-Sperren: in `~/.claude/settings.json` unter `permissions.deny` zusammenführen (nur nach Diff und Freigabe) |
| `../gemeinsam/skill-orchestrierung/` | `~/.claude/skills/orchestrierung/` (oder `.claude/skills/orchestrierung/`) |
| `../gemeinsam/skill-fremd-review/` (optional, nicht erprobt) | `~/.claude/skills/fremd-review/` (oder `.claude/skills/fremd-review/`) |

Vorhandene Dateien gleichen Namens nicht überschreiben.

## Aufbau einer Agentdatei

YAML-Kopf mit nur dokumentierten Feldern (`name`, `description`, `tools`, `disallowedTools`, `model`, `maxTurns`, `skills`), darunter der Rollentext. Claude Code **ignoriert unbekannte Felder still**; deshalb keine Felder wie `mode`, `steps`, `permissions`, `color`.

- **Modell:** `# model:` auskommentiert; ohne Zeile erbt der Agent das Modell der Hauptsitzung. Alias oder Modell-ID einsetzen.
- **Werkzeuge (`tools`, Allowlist):** `Agent` steht **nur** bei `coordinator-code` und `implementer`; so können nur diese weitere Subagents starten. `reviewer`: `Read, Grep, Glob, Bash, WebSearch, WebFetch` plus `disallowedTools: Edit, Write`. `researcher`, `scout`: ohne `Bash`, ohne Schreibwerkzeuge. `editor-lite`: `Edit` und `Bash`.
- **Schrittlimit:** `maxTurns` (`implementer` 50, `reviewer` 30, `researcher` 30, `scout` 20, `editor-lite` 25).
- **Git-Sperren: global, nicht je Agent.** `disallowedTools` mit einem Bash-Muster (`Bash(git push *)`) würde Bash ganz entziehen. Deshalb steht `permissions.deny` in `settings.json` und gilt für Haupt- und Subagents; `deny` hat Vorrang vor `ask` und `allow`. Folge: Auch die Hauptsitzung kann nicht pushen, bis die Zeile entfernt wird. Wer das nicht will, setzt die Muster in `ask` um.
- **Grenzen:** Bash-Muster sind keine harte Grenze (z. B. `git -C <ordner> push`); stärker durchsetzen mit Sandbox oder Hook. Der Schreibschutz des `reviewer` sperrt `Edit` und `Write`, nicht Schreiben per Shell. Das nennt der Plan als „nur vereinbart“.
- **Tiefe:** nicht per Feld einstellbar; Claude Code begrenzt sie zur Laufzeit. Die Kette vor dem ersten Einsatz mit einem Probeauftrag durchlaufen.

## Prüfer anderer Familie

**Nicht erzwingbar.** Subagents nutzen nur Modelle des Anbieters der Hauptsitzung; ein Feld für einen anderen Anbieter gibt es nicht. Der Koordinator-Text weist die Nutzerin einmal darauf hin und nennt die Einschränkung im Plan. Möglicher Umweg, nicht fest eingebaut: den `reviewer` die Kommandozeile eines anderen Anbieters im Lesemodus per Bash aufrufen lassen (Befehl `<FREMD_CLI_PRUEFBEFEHL>`, falls installiert und gewollt; Ablauf, Rechte und Kosten im optionalen Skill [`fremd-review`](../gemeinsam/skill-fremd-review/SKILL.md), nicht erprobt). Ohne ihn prüft ein unabhängiger Prüfer derselben Familie, und der Plan nennt die Einschränkung.

## Prüfen

1. Modellzeilen anpassen, Dateien kopieren, `settings.json`-Diff freigeben.
2. [Probe `git-sperren.md`](../probe/git-sperren.md) mit dem `implementer`.
3. Wirksame Rechte der übrigen Rollen bei Bedarf mit einem echten Lauf prüfen.
