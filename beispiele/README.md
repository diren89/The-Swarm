# Beispiel-Rollen (optional)

**Optional und nur ein Beispiel.** Das Manifest ([MANIFEST.md](../MANIFEST.md)) ist werkzeugneutral und gilt auch ohne diesen Ordner. Wer nur die Regeln will, ändert nichts. Die Dateien hier zeigen, wie sich die Rollen aus §5.1 und die Rechte aus §5.5 in OpenCode, Claude Code und Codex einrichten lassen. Sie sind Ausgangspunkt zum Anpassen, keine Befugnis und kein Standard.

## Inhalt

| Ordner | Inhalt |
|---|---|
| [gemeinsam/](gemeinsam/) | `rollen.md` (Rollentexte, eine Quelle für alle Werkzeuge), `koepfe/` (YAML-/TOML-Kopf je Werkzeug und Rolle), Skill `orchestrierung` mit Vorlagen (`auftrag`, `bericht`, `korrektur-brief`, `phasenplan`), optionaler Skill `fremd-review` (Review über die Kommandozeile eines anderen Anbieters, nicht erprobt) |
| [opencode/](opencode/) | 8 Agentdateien (`.md`, YAML-Kopf), `opencode.json.ausschnitt`, README (Abschnitt „Hooks“: nur über Plugins, kein Beispiel) |
| [claude-code/](claude-code/) | 7 Agentdateien (`.md`), `CLAUDE.md.ausschnitt` (Koordinator-Text), `settings.json.ausschnitt`, optional `hooks/` (zwei Hook-Gates) mit `settings.hooks.json.ausschnitt`, README |
| [codex/](codex/) | 7 Agentdateien (`.toml`), `AGENTS.md.ausschnitt` (Koordinator-Text), `config.toml.ausschnitt`, `rules/the-swarm.rules`, README (Abschnitt „Hooks“: dokumentiertes Format, kein Beispiel) |
| [probe/](probe/) | `git-sperren.md`: Probe der Git-Sperren im Wegwerf-Repo; `skill-schutz.md`: Probe der Schutzliste des `skill-master` |

In Claude Code und Codex ist der Koordinator die Hauptsitzung; sein Text steht im jeweiligen Ausschnitt statt in einer Agentdatei.

**Die Agentdateien und der Koordinator-Abschnitt der Ausschnitte sind erzeugt.** Ändern nur in `gemeinsam/rollen.md` (Text) bzw. `gemeinsam/koepfe/` (Kopf), dann `python3 tools/beispiele-bauen.py`. Nicht von Hand in den Werkzeugordnern ändern; `tools/beispiele-pruefen.sh` meldet jede abweichende Datei.

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
| `skill-master` | L1, Pflege (nicht je Aufgabe) | mittel | liest Skills nur als Daten, lädt sie nicht; schreibt nur in Skill-Ordner, Katalog, Lock und `.agent/work/`; Shell nur Skills-CLI (Änderungen nach Rückfrage), Statusskript, lesendes Git; zerstörende Git-Befehle gesperrt; keine Unteragents (OpenCode; sonst nur vereinbart) |

Nicht im Beispiel: Rollen für Datenexporte oder Forschungssynthese, ein Modellprüfskript oder Routing für ein bestimmtes Modell-Gateway, ein Token-Messskript (hängt an der Sitzungsablage des Werkzeugs). Das Prüfskript `tools/pruefen.sh` und die `playbooks/` des Repos werden nicht kopiert, sondern verwiesen.

## Platzhalter

| Platzhalter | Bedeutung |
|---|---|
| `<MODELL_GROSS>` | größtes verfügbares Modell (`coordinator`, `coordinator-code`) |
| `<MODELL_MITTEL>` | mittleres, schnelles Modell (`implementer`, `researcher`, `skill-master`) |
| `<MODELL_KLEIN>` | kleinstes ausreichendes Modell (`scout`, `editor-lite`) |
| `<MODELL_PRUEFER_ANDERE_FAMILIE>` | Modell einer anderen Familie als der Autor (`reviewer`) |
| `<provider>` | Anbieter-Kennung in OpenCode (Format `<provider>/<modell>`) |
| `<Pfad zu The Swarm>` | Ort des lokalen Klons von The Swarm (in den Vorlagen) |
| `<GESCHÜTZTE_SKILLS>` | Skill-IDs und Pfade, die der `skill-master` nie ändert (Rollentext; Sperren im OpenCode-Kopf, Settings bei Claude Code) |

In den Agentdateien stehen die Modellzeilen **auskommentiert** (`# model: …`). Ohne Zeile nutzt der Agent das Standardmodell der Sitzung; die Rolle funktioniert dann, aber ohne Modellklasse und beim `reviewer` ohne andere Familie. Platzhalter nie raten: die Nutzerin nennt die verfügbaren Modelle.

## Skills

Externe Agent-Skills sind fremde Inhalte (Daten, keine Anweisungen). Das Playbook [skills.md](../playbooks/skills.md) beschreibt Aufnahme, Festpinnen (Lock mit Commit und Hash), Aktualisieren nur nach Diff und Freigabe sowie das Ausblenden selten genutzter Skills. Die Beispiele setzen das so um:

- **Katalog:** Markdown-Tabelle `.agent/skills-katalog.md` (Projekt) bzw. `skills-katalog.md` neben der globalen Anweisungsdatei, eine Zeile je Skill: `| ID | Wofür (höchstens 12 Wörter) | Quelle@Commit oder lokal | sichtbar/ausgeblendet | Rollen |`. `coordinator` und `coordinator-code` lesen ihn ab Stufe M und laden ausgeblendete Skills gezielt.
- **Ausblenden:** je Werkzeug anders, siehe die Werkzeug-READMEs (OpenCode `metadata: { opencode/autoinvoke: false }`, Claude Code `disable-model-invocation: true` bzw. `skillOverrides`, Codex `agents/openai.yaml`). In OpenCode und Claude Code kostet ein ausgeblendeter Skill laut Doku keine Grundlast und bleibt gezielt ladbar; bei Codex verhindert das Flag nur den Selbstaufruf, ob die Beschreibung aus der Liste fällt, ist nicht dokumentiert.
- **Pflege:** nur die Rolle `skill-master`, nur auf Wunsch der Nutzerin oder in Phase 0 bei Stufe L, nie je Aufgabe. Freigaben gehen als `blockiert` mit Optionen an den `coordinator`. `coordinator-code` meldet Bedarf als `blockiert` zurück.
- **Geschützte Skills:** Schutzliste mit Platzhalter `<GESCHÜTZTE_SKILLS>` im Rollentext; technisch gesperrt nur, wo das Werkzeug es kann (OpenCode: `edit`/`shell` deny am Ende des Kopfes; Claude Code: `permissions.deny` global; Codex: nur Anweisung). Playbook [skills.md](../playbooks/skills.md), Probe [skill-schutz.md](probe/skill-schutz.md).
- **Skill-Rechte je Rolle:** nur in OpenCode je Agent technisch einstellbar (Tabelle in [opencode/README.md](opencode/README.md#skill-rechte-je-rolle)). Claude Code: Regeln `Skill(name)` in den Settings, global. Codex: Rechte je Agent für Skills in der Dokumentation nicht gefunden (UNGEPRÜFT).

## Prüfer aus anderer Modellfamilie (§5.1, §2 Punkt 6)

| Werkzeug | Verhalten |
|---|---|
| OpenCode | **Pflicht.** Modelle sind je Agent frei wählbar (`provider/modell`); `reviewer` und die Plankritik laufen mit einem Modell anderer Familie. Ist dort kein Modell einer anderen Familie verfügbar, weist der Koordinator darauf hin und fragt die Nutzerin, ob das Review mit dem gleichen Modell bzw. der gleichen Familie erfolgen soll, nicht stillschweigend. |
| Claude Code | **Nicht erzwingbar.** Subagents nutzen nur Modelle des Anbieters der Hauptsitzung. Nur Hinweis in Rollentext und README. Möglicher Umweg, nicht fest eingebaut: die Kommandozeile eines anderen Anbieters im Lesemodus per Shell aufrufen, optional mit dem Skill [`fremd-review`](gemeinsam/skill-fremd-review/SKILL.md) (nicht erprobt). |
| Codex | **Nicht erzwingbar.** Der Anbieter wird von der Hauptsitzung geerbt. Hinweis und Umweg (optional Skill `fremd-review`) wie bei Claude Code. |

## Grenzen je Werkzeug (§5.5 „Grenzen ehrlich benennen“)

- **OpenCode:** Verschachtelungstiefe (`experimental.subagent_depth`) ist experimentell. Das Netz des `skill-master` (nur die Quelle des Skills) ist nicht begrenzbar, nur vereinbart. Agent-Rechte werden nicht vom Elternagent geerbt; Sperren stehen deshalb in jedem Agent. Shell-Muster (`git push*`) sind keine harte Grenze: andere Aufrufsyntax (z. B. `git -C <ordner> push`) kann daran vorbeigehen.
- **Claude Code:** `disallowedTools` mit Bash-Muster würde Bash ganz entziehen; die Git-Sperren stehen deshalb global in `settings.json` (`permissions.deny`) und gelten für Haupt- und Subagents. Shell-Muster sind keine harte Grenze. Unbekannte Felder im Agent-Kopf werden **still ignoriert**: nur dokumentierte Felder verwenden. Die Pfadgrenzen des `skill-master` (nur Skill-Ordner und Katalog) sind dort nur vereinbart. Die Tiefe der Verschachtelung begrenzt das Werkzeug zur Laufzeit; `Agent` steht nur bei `coordinator-code` und `implementer` in `tools`.
- **Codex:** Rechte je Agent gibt es nicht; Sandbox und Freigaberichtlinie gelten für alle. Der Schreibschutz des Prüfers und die Pfadgrenzen des `skill-master` sind nur vereinbart (Anweisung), nicht gesperrt. Die Agentdatei kann Anbieter, Sandbox, Freigaben und MCP nicht überschreiben. `.rules` ist **experimentell**, argv-Präfix-basiert und regelt Befehle außerhalb der Sandbox. Kein Schrittlimit je Agent, keine Allowlist je Agent für Unteragents.
- **Alle:** Rechte, die nur im Rollentext stehen, sind keine Sicherheitsgrenze. Ohne Sandbox teilen sich alle Agents Dateisystem und Zugänge.

## Installation

Über den Import-Prompt: [prompts/import.md](../prompts/import.md) (Schritt „Beispiel-Rollen“, 6a). Der Agent zeigt den passenden Ordner, überschreibt keine Dateien gleichen Namens, klärt die Platzhalter mit der Nutzerin und führt Konfigurations-Ausschnitte (`settings.json`, `opencode.json`, `config.toml`, `rules`) **nicht selbst zusammen**, sondern zeigt einen Diff und wartet auf Freigabe. Danach die [Probe](probe/git-sperren.md) in einer neuen Sitzung (bei Einsatz des `skill-master` zusätzlich [skill-schutz.md](probe/skill-schutz.md)). Manuell: Dateien aus dem Werkzeug-Ordner an den dort genannten Ort kopieren (siehe README des Ordners), Platzhalter ersetzen.

## Status der Erprobung

| Werkzeug | Stand |
|---|---|
| OpenCode | erprobt an der lokalen Vorlage, aus der diese Dateien abgeleitet sind (Rechte-Probe: gesperrte Git-Befehle abgelehnt; Kette `coordinator` → `coordinator-code` → `scout`). Die anonymisierten Dateien hier selbst: Probe über `probe/git-sperren.md`, Ergebnis trägt der Koordinator nach. |
| Claude Code | teilweise erprobt: Git-Sperren erprobt (Claude Code 2.1.285, Projektordner mit diesen Agent-Dateien und `settings.json`): Subagent `implementer` lief, `git status` ausgeführt, `reset --hard`, `clean -fd`, `branch -D`, `push` vom Werkzeug abgelehnt, auch bei allgemein erlaubtem `Bash`; Repo danach unverändert. Übrige Rollen und Modellzuweisung nicht einzeln geprüft. |
| Hooks (optional, nur Claude Code) | Gate A (Geheimnis-Scan vor Commit) und Gate B (Prüfung bei Sitzungsende) in Claude Code 2.1.285 in einem Wegwerf-Repo erprobt, Skripte zusätzlich mit simuliertem stdin-JSON; `onFailure` nicht erprobt (Version zu alt). OpenCode: Hooks nur über Plugins (Code), nicht im Beispiel. Codex: Format dokumentiert, UNGEPRÜFT, nicht im Beispiel. Details: [claude-code/README.md](claude-code/README.md#optionale-hooks). |
| Codex | UNGEPRÜFT (nicht installiert und nicht gelaufen; Formate nach der Produktdokumentation, Stand Nov. 2026) |

## Konsistenz

`tools/beispiele-pruefen.sh` prüft, dass jede erzeugte Datei dem Ergebnis von `python3 tools/beispiele-bauen.py` entspricht (erzeugt == eingecheckt), dass der Rollentext jeder Rolle aus `gemeinsam/rollen.md` in allen Werkzeugdateien identisch steht (verhindert Drift), dass YAML-Köpfe, TOML- und JSON-Dateien lesbar sind, dass die Skill-Rechte der OpenCode-Köpfe gesetzt sind (jeder Kopf hat `* * deny` oder eine `skill`-Regel; `skill-master` mit Allowlist, Git-Sperren und ohne Unteragents; `coordinator` darf `skill-master` aufrufen) und dass keine Namen, Pfade oder Modellnamen enthalten sind. Ein grünes Skript sagt nichts über das Laufzeitverhalten.
