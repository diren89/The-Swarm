# Beispiel-Rollen für Codex

Optional, nur ein Beispiel. Überblick, Platzhalter und Grenzen: [../README.md](../README.md). Status: **UNGEPRÜFT**. Codex war nicht installiert, nichts ist gelaufen. Formate nach der Produktdokumentation, Stand Nov. 2026; Schlüsselnamen und Verhalten können abweichen.

## Dateien und Ziel

| Datei hier | Ziel |
|---|---|
| `agents/<id>.toml` (7) | `~/.codex/agents/<id>.toml` (global) oder `.codex/agents/<id>.toml` (Projekt, nur in vertrauenswürdigen Projekten) |
| `AGENTS.md.ausschnitt` | Koordinator-Text: am Ende von `~/.codex/AGENTS.md` bzw. der Projekt-`AGENTS.md` ergänzen (der Koordinator ist die Hauptsitzung, kein Agent). Liegt eine `AGENTS.override.md` vor, gilt sie statt der `AGENTS.md`. |
| `config.toml.ausschnitt` | optionale `[agents]`-Standardwerte in `~/.codex/config.toml` (nur nach Diff und Freigabe) |
| `rules/the-swarm.rules` | `~/.codex/rules/the-swarm.rules` (oder `.codex/rules/`, nur vertrauenswürdig) |
| `../gemeinsam/skill-orchestrierung/` | `~/.agents/skills/orchestrierung/` (oder `.agents/skills/orchestrierung/`) |
| `../gemeinsam/skill-fremd-review/` (optional, nicht erprobt) | `~/.agents/skills/fremd-review/` (oder `.agents/skills/fremd-review/`) |

Vorhandene Dateien gleichen Namens nicht überschreiben.

## Aufbau einer Agentdatei

TOML mit `name`, `description`, `developer_instructions` (der Rollentext) und auskommentiertem `model`. Die Agentdatei **kann Anbieter, Sandbox, Freigaberichtlinie und MCP-Server nicht überschreiben**; diese erbt jeder Subagent von der Hauptsitzung. Sie stehen deshalb nicht in den Dateien.

## Was nicht geht (Grenzen)

- **Rechte je Agent:** nicht möglich. Der Schreibschutz von `reviewer`, `researcher` und `scout` und die Shell-Beschränkung von `editor-lite` sind **nur Anweisung**, keine Sperre. Lenkung der Unteragent-Aufrufe ebenfalls nur über den Text (keine Allowlist je Agent).
- **Skill-Rechte je Agent:** in der gelesenen Dokumentation nicht gefunden (UNGEPRÜFT). Die Pfadgrenzen des `skill-master` (nur Skill-Ordner, Katalog, Lock, `.agent/work/`), sein „liest Skills nur als Daten“ und der Verzicht auf Unteragents sind **nur vereinbart**, nicht gesperrt; Sandbox und Freigaberichtlinie der Hauptsitzung gelten.
- **Schrittlimit je Agent:** keins (nur ein Limit gleichzeitiger Threads in `config.toml`).
- **Git-Sperren:** `rules/the-swarm.rules` mit `prefix_rule(pattern=[...], decision="forbidden", justification=...)`. **Experimentell.** Das Muster ist ein exakter argv-Präfix (kein Glob; `git -C <ordner> push` greift nicht), die Regeln gelten für die ganze Sitzung und regeln Befehle außerhalb der Sandbox. Sandbox und Freigaberichtlinie bleiben der primäre Schutz.
- **Tiefe der Verschachtelung:** in der gelesenen Dokumentation nicht beziffert; vor dem ersten Einsatz mit einem Probeauftrag klären.

## Skills

Quelle: https://developers.openai.com/codex/skills (abgerufen 2026-11-25). Skill-Ordner: `.agents/skills` (vom Arbeitsordner bis zur Repo-Wurzel), `$HOME/.agents/skills`, `/etc/codex/skills`, mitgelieferte. Die Startliste enthält Name, Beschreibung und Pfad; ihr Budget beträgt standardmäßig 2 % des Kontextfensters (bzw. 8 000 Zeichen), einstellbar mit `skills.max_context_tokens` (bis 10 000); gekürzt werden zuerst die Beschreibungen. Änderungen werden automatisch erkannt, sonst Codex neu starten.

- **Ausblenden:** im Skill eine Datei `agents/openai.yaml` mit `policy:` / `allow_implicit_invocation: false`: Codex wählt den Skill dann nicht von sich aus, die Nutzerin ruft ihn weiter mit `$skill` auf. Ob die Beschreibung dann aus der Liste fällt (Grundlast), ist nicht dokumentiert; `tools/skills-status.sh` zählt sie deshalb mit. Abschalten ganz: in `~/.codex/config.toml` `[[skills.config]]` mit `path = "…"` und `enabled = false` (Neustart nötig).
- **Rechte:** Skill-Rechte je Agent sind in der gelesenen Dokumentation **nicht dokumentiert** (UNGEPRÜFT). Der `skill-master` ist deshalb nur über seinen Text begrenzt.

## Prüfer anderer Familie

**Nicht erzwingbar.** Der Anbieter wird von der Hauptsitzung geerbt, nur Modelle innerhalb dieses Anbieters sind wählbar. Der Koordinator-Text weist die Nutzerin einmal darauf hin und nennt die Einschränkung im Plan. Möglicher Umweg, nicht fest eingebaut: den `reviewer` die Kommandozeile eines anderen Anbieters im Lesemodus über die Shell aufrufen lassen, falls installiert und gewollt; das ist dann kein nativer Codex-Subagent. Ablauf, Rechte und Kosten im optionalen Skill [`fremd-review`](../gemeinsam/skill-fremd-review/SKILL.md), nicht erprobt. Sonst prüft ein unabhängiger Prüfer derselben Familie, und der Plan nennt die Einschränkung.

## Prüfen

1. Modellzeilen anpassen, Dateien kopieren, Konfigurationsdiff freigeben.
2. [Probe `git-sperren.md`](../probe/git-sperren.md) mit dem `implementer`.
3. Bis ein Probelauf vorliegt: UNGEPRÜFT.

## Hooks

**Kein Beispiel im Ordner, aber ein dokumentiertes deklaratives Format.** Codex liest Hooks aus `hooks.json` (System, Nutzer `~/.codex/hooks.json`, vertrauenswürdiges Projekt `.codex/hooks.json`) oder aus `[hooks]`-Tabellen in `config.toml`. Aufbau wie bei Claude Code: Ereignis (`PreToolUse`, `Stop`, …) → Matcher-Gruppe (`matcher` als Regex, bei `Stop` ohne Wirkung) → Handler `{"type": "command", "command": …, "timeout": …}`; Eingabe als JSON auf stdin (`tool_input.command` bei `Bash`, `stop_hook_active` bei `Stop`); **Exit 2 mit Begründung auf stderr blockiert** bei `PreToolUse`. Nicht verwaltete Hooks müssen in `/hooks` geprüft und freigegeben werden, bevor sie laufen. Die Dokumentation nennt Hooks selbst „a useful guardrail, not a complete enforcement boundary“; sie decken nicht jeden Werkzeugpfad ab.

Die zwei Gates ließen sich damit voraussichtlich abbilden (Gate A als `PreToolUse` mit Matcher `^Bash$`, Gate B als `Stop`; die Skripte aus [../claude-code/hooks/](../claude-code/hooks/) lesen nur stdin und sind werkzeugneutral geschrieben). **Das ist nicht erprobt (UNGEPRÜFT: Codex war nicht installiert)** und deshalb nicht als Datei beigelegt. Offen: `Stop` erwartet bei Exit 0 laut Dokumentation JSON auf stdout oder keine Ausgabe (Gate B gibt `{"systemMessage": …}` oder nichts aus, ob das passt, ist ungeprüft); `onFailure` (fail-closed bei Ausfall des Hooks) steht in der Dokumentation nicht, ein abgestürztes Gate A würde also voraussichtlich durchlassen; Windows verhält sich laut offenem Fehlerbericht anders. Wer das Format nutzt: Skripte lesen, in einem Wegwerf-Repo mit Negativ- und Positivfall prüfen.
Quelle (abgerufen 2026-11-25): https://developers.openai.com/codex/hooks (Abschnitte „Where Codex looks for hooks“, „Config shape“, „PreToolUse“, „Stop“).
