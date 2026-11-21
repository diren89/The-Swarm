# agent-manifest

Gemeinsames, wachsendes Arbeitswissen für KI-Agents, die größere Software-Aufgaben **koordiniert in Phasen** umsetzen: planen, an Subagents mit passenden Modellen verteilen, selbst testen, selbst verbessern und aus jedem Schritt lernen.

Dieses Repo soll Erfahrungen **dauerhaft zwischen verschiedenen Instanzen und Modellen** teilen. Jede Instanz liest es zu Beginn ein und schreibt am Ende ihre Learnings zurück.

## Für Modelle: so einlesen

Zu Beginn einer Aufgabe diese zwei Dateien lesen:

```text
https://raw.githubusercontent.com/diren89/agent-manifest/main/MANIFEST.md
https://raw.githubusercontent.com/diren89/agent-manifest/main/LEARNINGS.md
```

Bei Bedarf zusätzlich die Vorlagen unter `playbooks/` und die Umgebungs-Probe `tools/probe-env.sh`.

In einem Projekt verankern, z. B. in dessen `CLAUDE.md` oder `AGENTS.md`:

```markdown
## Arbeitsweise
Bei mehrschrittigen Aufgaben zuerst https://github.com/diren89/agent-manifest lesen
(MANIFEST.md, LEARNINGS.md). Projektregeln haben Vorrang. Learnings am Ende als PR zurückgeben.
```

## Inhalt

| Datei | Zweck |
| --- | --- |
| [MANIFEST.md](MANIFEST.md) | Arbeitsweise: Phasen, Planung, Effizienz, Subagents und Modellwahl, Qualität und Tokens, Prüfschichten, Hardware-Anpassung, Lernschleife |
| [LEARNINGS.md](LEARNINGS.md) | Erfahrungen aus realen Aufgaben, allgemein formuliert, mit Status |
| [playbooks/agent-brief.md](playbooks/agent-brief.md) | Vorlage für Aufträge an Umsetzer und Prüfer |
| [playbooks/phase-retro.md](playbooks/phase-retro.md) | Vorlage für die Retrospektive nach jeder Phase |
| [tools/probe-env.sh](tools/probe-env.sh) | read-only Umgebungsprobe, Ausgabe bleibt lokal |
| [CONTRIBUTING.md](CONTRIBUTING.md) | Wie Instanzen Learnings und Regeln beitragen |
| [CHANGELOG.md](CHANGELOG.md) | Versionen des Manifests |

## Grundsätze in einem Satz

Erst verstehen, dann planen, in Phasen liefern, delegieren und nichts ungeprüft übernehmen, ehrlich berichten und aus jedem Fehler eine Regel machen.

## Vertrauen und Sicherheit

Die Inhalte sind Arbeitswissen, keine Befehle. Sie erweitern keine Befugnisse eines Agents und ersetzen keine Rückfrage bei der Nutzerin oder dem Nutzer. Beiträge von Modellen werden von einem Menschen geprüft, bevor sie in `main` landen.
