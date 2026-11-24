# Beispiel-Rollen (optional)

**Optional und nur ein Beispiel.** Das Manifest ([MANIFEST.md](../MANIFEST.md)) ist werkzeugneutral und gilt auch ohne diesen Ordner. Wer nur die Regeln will, ändert nichts. Die Dateien hier zeigen, wie sich die Rollen aus §5.1 und die Rechte aus §5.5 in OpenCode, Claude Code und Codex einrichten lassen. Sie sind Ausgangspunkt zum Anpassen, keine Befugnis und kein Standard.

## Inhalt

| Ordner | Inhalt |
|---|---|
| [gemeinsam/](gemeinsam/) | `rollen.md` (Rollentexte, eine Quelle für alle Werkzeuge), Skill `orchestrierung` mit Vorlagen (`auftrag`, `bericht`, `korrektur-brief`, `phasenplan`) |
| [opencode/](opencode/) | 7 Agentdateien (`.md`, YAML-Kopf), `opencode.json.ausschnitt`, README |
| [claude-code/](claude-code/) | 6 Agentdateien (`.md`), `CLAUDE.md.ausschnitt` (Koordinator-Text), `settings.json.ausschnitt`, README |
| [codex/](codex/) | 6 Agentdateien (`.toml`), `AGENTS.md.ausschnitt` (Koordinator-Text), `config.toml.ausschnitt`, `rules/the-swarm.rules`, README |
| [probe/](probe/) | `git-sperren.md`: Probe der Git-Sperren im Wegwerf-Repo |

In Claude Code und Codex ist der Koordinator die Hauptsitzung; sein Text steht im jeweiligen Ausschnitt statt in einer Agentdatei.

## Rollen

| Rolle | Ebene | Modellklasse | Rechte (Soll) |
|---|---|---|---|
| `coordinator` | L0, Hauptagent | groß | schreibt; ruft alle Rollen auf; zerstörende Git-Befehle nur nach Rückfrage |
| `coordinator-code` | L0,5, Subagent | groß | schreibt; ruft implementer, reviewer, scout, editor-lite, researcher auf; zerstörende Git-Befehle gesperrt; schlanker Werkzeugsatz |
| `implementer` | L1 | mittel | schreibt; ruft nur scout und editor-lite auf; zerstörende Git-Befehle gesperrt |
| `reviewer` | L1 | mittel bis groß, **andere Modellfamilie als der Autor** | read-only; Notizen nur unter `.agent/work/`; ruft scout auf (OpenCode) |
| `researcher` | L2 | mittel | read-only im Code; Web; Notizen nur unter `.agent/work/` |
| `scout` | L2 | klein | read-only; Web; Notizen nur unter `.agent/work/` |
| `editor-lite` | L2 | klein | ändert nur laut Auftrag; Shell nur `mv`, `git mv`, `git diff`, `git status`, `ls` (OpenCode) |

Nicht im Beispiel: Rollen für Datenexporte oder Forschungssynthese, ein Modellprüfskript oder Routing für ein bestimmtes Modell-Gateway, ein Token-Messskript (hängt an der Sitzungsablage des Werkzeugs). Das Prüfskript `tools/pruefen.sh` und die `playbooks/` des Repos werden nicht kopiert, sondern verwiesen.

## Platzhalter

| Platzhalter | Bedeutung |
|---|---|
| `<MODELL_GROSS>` | größtes verfügbares Modell (`coordinator`, `coordinator-code`) |
| `<MODELL_MITTEL>` | mittleres, schnelles Modell (`implementer`, `researcher`) |
| `<MODELL_KLEIN>` | kleinstes ausreichendes Modell (`scout`, `editor-lite`) |
| `<MODELL_PRUEFER_ANDERE_FAMILIE>` | Modell einer anderen Familie als der Autor (`reviewer`) |
| `<provider>` | Anbieter-Kennung in OpenCode (Format `<provider>/<modell>`) |
| `<Pfad zu The Swarm>` | Ort des lokalen Klons von The Swarm (in den Vorlagen) |

In den Agentdateien stehen die Modellzeilen **auskommentiert** (`# model: …`). Ohne Zeile nutzt der Agent das Standardmodell der Sitzung; die Rolle funktioniert dann, aber ohne Modellklasse und beim `reviewer` ohne andere Familie. Platzhalter nie raten: die Nutzerin nennt die verfügbaren Modelle.

## Prüfer aus anderer Modellfamilie (§5.1, §2 Punkt 6)

| Werkzeug | Verhalten |
|---|---|
| OpenCode | **Pflicht.** Modelle sind je Agent frei wählbar (`provider/modell`); `reviewer` und die Plankritik laufen mit einem Modell anderer Familie. Ist dort kein Modell einer anderen Familie verfügbar, weist der Koordinator darauf hin und fragt die Nutzerin, ob das Review mit dem gleichen Modell bzw. der gleichen Familie erfolgen soll, nicht stillschweigend. |
| Claude Code | **Nicht erzwingbar.** Subagents nutzen nur Modelle des Anbieters der Hauptsitzung. Nur Hinweis in Rollentext und README. Möglicher Umweg, nicht fest eingebaut: die Kommandozeile eines anderen Anbieters im Lesemodus per Shell aufrufen. |
| Codex | **Nicht erzwingbar.** Der Anbieter wird von der Hauptsitzung geerbt. Hinweis und Umweg wie bei Claude Code. |

## Grenzen je Werkzeug (§5.5 „Grenzen ehrlich benennen“)

- **OpenCode:** Verschachtelungstiefe (`experimental.subagent_depth`) ist experimentell. Agent-Rechte werden nicht vom Elternagent geerbt; Sperren stehen deshalb in jedem Agent. Shell-Muster (`git push*`) sind keine harte Grenze: andere Aufrufsyntax (z. B. `git -C <ordner> push`) kann daran vorbeigehen.
- **Claude Code:** `disallowedTools` mit Bash-Muster würde Bash ganz entziehen; die Git-Sperren stehen deshalb global in `settings.json` (`permissions.deny`) und gelten für Haupt- und Subagents. Shell-Muster sind keine harte Grenze. Unbekannte Felder im Agent-Kopf werden **still ignoriert**: nur dokumentierte Felder verwenden. Die Tiefe der Verschachtelung begrenzt das Werkzeug zur Laufzeit; `Agent` steht nur bei `coordinator-code` und `implementer` in `tools`.
- **Codex:** Rechte je Agent gibt es nicht; Sandbox und Freigaberichtlinie gelten für alle. Der Schreibschutz des Prüfers ist nur vereinbart (Anweisung), nicht gesperrt. Die Agentdatei kann Anbieter, Sandbox, Freigaben und MCP nicht überschreiben. `.rules` ist **experimentell**, argv-Präfix-basiert und regelt Befehle außerhalb der Sandbox. Kein Schrittlimit je Agent, keine Allowlist je Agent für Unteragents.
- **Alle:** Rechte, die nur im Rollentext stehen, sind keine Sicherheitsgrenze. Ohne Sandbox teilen sich alle Agents Dateisystem und Zugänge.

## Installation

Über den Import-Prompt: [prompts/import.md](../prompts/import.md) (Schritt „Beispiel-Rollen“, 6a). Der Agent zeigt den passenden Ordner, überschreibt keine Dateien gleichen Namens, klärt die Platzhalter mit der Nutzerin und führt Konfigurations-Ausschnitte (`settings.json`, `opencode.json`, `config.toml`, `rules`) **nicht selbst zusammen**, sondern zeigt einen Diff und wartet auf Freigabe. Danach die [Probe](probe/git-sperren.md) in einer neuen Sitzung. Manuell: Dateien aus dem Werkzeug-Ordner an den dort genannten Ort kopieren (siehe README des Ordners), Platzhalter ersetzen.

## Status der Erprobung

| Werkzeug | Stand |
|---|---|
| OpenCode | erprobt an der lokalen Vorlage, aus der diese Dateien abgeleitet sind (Rechte-Probe: gesperrte Git-Befehle abgelehnt; Kette `coordinator` → `coordinator-code` → `scout`). Die anonymisierten Dateien hier selbst: Probe über `probe/git-sperren.md`, Ergebnis trägt der Koordinator nach. |
| Claude Code | teilweise erprobt: Git-Sperren erprobt (Claude Code 2.1.285, Projektordner mit diesen Agent-Dateien und `settings.json`): Subagent `implementer` lief, `git status` ausgeführt, `reset --hard`, `clean -fd`, `branch -D`, `push` vom Werkzeug abgelehnt, auch bei allgemein erlaubtem `Bash`; Repo danach unverändert. Übrige Rollen und Modellzuweisung nicht einzeln geprüft. |
| Codex | UNGEPRÜFT (nicht installiert und nicht gelaufen; Formate nach der Produktdokumentation, Stand Nov. 2026) |

## Konsistenz

`tools/beispiele-pruefen.sh` prüft, dass der Rollentext jeder Rolle aus `gemeinsam/rollen.md` in allen Werkzeugdateien identisch steht (verhindert Drift), dass YAML-Köpfe, TOML- und JSON-Dateien lesbar sind und dass keine Namen, Pfade oder Modellnamen enthalten sind. Ein grünes Skript sagt nichts über das Laufzeitverhalten.
