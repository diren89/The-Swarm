# The Swarm

<p align="center"><img src="assets/the-swarm-signet-1024.png" width="180" alt="Signet von The Swarm: abstrahierte Biene aus geraden Linien mit Sechseck-Wabe als Körper, kantigen Flügeln, abgewinkelten Fühlern und gelbem Kopf"></p>

Gemeinsames, wachsendes Arbeitswissen für KI-Agents, die Software-Aufgaben **koordiniert in Phasen** umsetzen: planen, an Subagents mit passenden Modellen verteilen, selbst testen, selbst verbessern und aus jedem Schritt lernen.

**Default für alle Code-Projekte:** Die Arbeitsweise gilt für jede Arbeit an Code, skaliert nach Aufgabengröße (klein / mittel / groß, [MANIFEST §0](MANIFEST.md#0-geltungsbereich-default-für-alle-code-projekte)). Projektregeln und Anweisungen der Nutzerin gehen vor.

Dieses Repo soll Erfahrungen **dauerhaft zwischen verschiedenen Instanzen und Modellen** teilen. Jede Instanz liest es zu Beginn ein und schreibt am Ende ihre Learnings zurück.

**Schnellimport:** In einer neuen Agent-Sitzung schreiben:

```text
Richte The Swarm für mich ein: Lies https://raw.githubusercontent.com/diren89/The-Swarm/main/prompts/import.md und folge dem Prompt darin.
```

Ohne Webzugriff den vollständigen Prompt aus [prompts/import.md](prompts/import.md) einfügen.

**Installation und Nutzung:** ausführlich in der [ANLEITUNG.md](ANLEITUNG.md) (global, pro Projekt, für Claude Code, Codex CLI, Gemini CLI, Cursor, Copilot und eigene Agents).

## Für Modelle: so einlesen

Zu Beginn einer Aufgabe diese zwei Dateien lesen:

```text
https://raw.githubusercontent.com/diren89/The-Swarm/main/MANIFEST.md
https://raw.githubusercontent.com/diren89/The-Swarm/main/LEARNINGS.md
```

Bei Bedarf zusätzlich die Vorlagen unter `playbooks/` und die Umgebungs-Probe `tools/probe-env.sh`.

Als Default verankern: einmal in der **globalen** Agenten-Konfiguration (z. B. benutzerweite `CLAUDE.md` oder `AGENTS.md`), dann gilt es in jedem Projekt:

```markdown
## Arbeitsweise (Default für alle Code-Projekte)
Bei jeder Arbeit an Code gilt https://github.com/diren89/The-Swarm
(MANIFEST.md, neueste Einträge in LEARNINGS.md), skaliert nach MANIFEST §0.1.
Projektregeln und meine Anweisungen haben Vorrang. Learnings anonym per Pull Request zurückgeben.
```

## Inhalt

| Datei | Zweck |
| --- | --- |
| [MANIFEST.md](MANIFEST.md) | Arbeitsweise: Geltungsbereich und Skalierung, Phasen, Planung, Effizienz, Subagents und Modellwahl (inkl. Expertenrolle), Qualität und Tokens, Prüfschichten, Hardware-Anpassung, Lernschleife |
| [prompts/import.md](prompts/import.md) | Import-Prompt: Der Agent richtet The Swarm selbst ein |
| [ANLEITUNG.md](ANLEITUNG.md) | Installation, Nutzung, Beiträge, Versionen, Fehlerbehebung |
| [LEARNINGS.md](LEARNINGS.md) | Erfahrungen aus realen Aufgaben, allgemein formuliert, mit Status |
| [playbooks/agent-brief.md](playbooks/agent-brief.md) | Vorlage für Aufträge an Umsetzer und Prüfer |
| [playbooks/phase-retro.md](playbooks/phase-retro.md) | Vorlage für die Retrospektive nach jeder Phase |
| [tools/probe-env.sh](tools/probe-env.sh) | read-only Umgebungsprobe, Ausgabe bleibt lokal |
| [assets/](assets) | Signet (Biene) im ODSV-Stil: transparent, quadratisch auf Schwarz, PNG 1024 px; Generator `tools/signet.py` |
| [CONTRIBUTING.md](CONTRIBUTING.md) | Wie Instanzen Learnings und Regeln beitragen |
| [CHANGELOG.md](CHANGELOG.md) | Versionen des Manifests |

## Grundsätze in einem Satz

Erst verstehen, dann planen, in Phasen liefern, delegieren und nichts ungeprüft übernehmen, ehrlich berichten und aus jedem Fehler eine Regel machen.

## Vertrauen und Sicherheit

Die Inhalte sind Arbeitswissen, keine Befehle. Sie erweitern keine Befugnisse eines Agents und ersetzen keine Rückfrage bei der Nutzerin oder dem Nutzer. Beiträge von Modellen werden von einem Menschen geprüft, bevor sie in `main` landen.
