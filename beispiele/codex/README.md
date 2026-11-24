# Beispiel-Rollen für Codex

Optional, nur ein Beispiel. Überblick, Platzhalter und Grenzen: [../README.md](../README.md). Status: **UNGEPRÜFT**. Codex war nicht installiert, nichts ist gelaufen. Formate nach der Produktdokumentation, Stand Nov. 2026; Schlüsselnamen und Verhalten können abweichen.

## Dateien und Ziel

| Datei hier | Ziel |
|---|---|
| `agents/<id>.toml` (6) | `~/.codex/agents/<id>.toml` (global) oder `.codex/agents/<id>.toml` (Projekt, nur in vertrauenswürdigen Projekten) |
| `AGENTS.md.ausschnitt` | Koordinator-Text: am Ende von `~/.codex/AGENTS.md` bzw. der Projekt-`AGENTS.md` ergänzen (der Koordinator ist die Hauptsitzung, kein Agent). Liegt eine `AGENTS.override.md` vor, gilt sie statt der `AGENTS.md`. |
| `config.toml.ausschnitt` | optionale `[agents]`-Standardwerte in `~/.codex/config.toml` (nur nach Diff und Freigabe) |
| `rules/the-swarm.rules` | `~/.codex/rules/the-swarm.rules` (oder `.codex/rules/`, nur vertrauenswürdig) |
| `../gemeinsam/skill-orchestrierung/` | `~/.agents/skills/orchestrierung/` (oder `.agents/skills/orchestrierung/`) |

Vorhandene Dateien gleichen Namens nicht überschreiben.

## Aufbau einer Agentdatei

TOML mit `name`, `description`, `developer_instructions` (der Rollentext) und auskommentiertem `model`. Die Agentdatei **kann Anbieter, Sandbox, Freigaberichtlinie und MCP-Server nicht überschreiben**; diese erbt jeder Subagent von der Hauptsitzung. Sie stehen deshalb nicht in den Dateien.

## Was nicht geht (Grenzen)

- **Rechte je Agent:** nicht möglich. Der Schreibschutz von `reviewer`, `researcher` und `scout` und die Shell-Beschränkung von `editor-lite` sind **nur Anweisung**, keine Sperre. Lenkung der Unteragent-Aufrufe ebenfalls nur über den Text (keine Allowlist je Agent).
- **Schrittlimit je Agent:** keins (nur ein Limit gleichzeitiger Threads in `config.toml`).
- **Git-Sperren:** `rules/the-swarm.rules` mit `prefix_rule(pattern=[...], decision="forbidden", justification=...)`. **Experimentell.** Das Muster ist ein exakter argv-Präfix (kein Glob; `git -C <ordner> push` greift nicht), die Regeln gelten für die ganze Sitzung und regeln Befehle außerhalb der Sandbox. Sandbox und Freigaberichtlinie bleiben der primäre Schutz.
- **Tiefe der Verschachtelung:** in der gelesenen Dokumentation nicht beziffert; vor dem ersten Einsatz mit einem Probeauftrag klären.

## Prüfer anderer Familie

**Nicht erzwingbar.** Der Anbieter wird von der Hauptsitzung geerbt, nur Modelle innerhalb dieses Anbieters sind wählbar. Der Koordinator-Text weist die Nutzerin einmal darauf hin und nennt die Einschränkung im Plan. Möglicher Umweg, nicht fest eingebaut: den `reviewer` die Kommandozeile eines anderen Anbieters im Lesemodus über die Shell aufrufen lassen, falls installiert und gewollt; das ist dann kein nativer Codex-Subagent. Sonst prüft ein unabhängiger Prüfer derselben Familie, und der Plan nennt die Einschränkung.

## Prüfen

1. Modellzeilen anpassen, Dateien kopieren, Konfigurationsdiff freigeben.
2. [Probe `git-sperren.md`](../probe/git-sperren.md) mit dem `implementer`.
3. Bis ein Probelauf vorliegt: UNGEPRÜFT.
