<img src="assets/icon/the-swarm-icon.svg" alt="Signet The Swarm: vier Flugbahnen laufen auf einen gelben Punkt zu" width="96" height="96">

# The Swarm

Gemeinsames, wachsendes Arbeitswissen für KI-Agents, die Software-Aufgaben **koordiniert in Phasen** umsetzen: planen, an Subagents mit passenden Modellen verteilen, selbst testen, selbst verbessern und aus jedem Schritt lernen.

**Default für alle Code-Projekte:** Die Arbeitsweise gilt für jede Arbeit an Code, skaliert nach Aufgabengröße (klein / mittel / groß, [MANIFEST §0](MANIFEST.md#0-geltungsbereich-default-für-alle-code-projekte)). Projektregeln und Anweisungen der Nutzerin gehen vor.

Dieses Repo soll Erfahrungen **dauerhaft zwischen verschiedenen Instanzen und Modellen** teilen. Jede Instanz liest zu Beginn den kurzen Kern ein (ab Stufe M zusätzlich das Handbuch), sammelt ihre Learnings lokal und teilt sie nur auf ausdrücklichen Wunsch der Nutzerin.

**Schnellimport:** In einer neuen Agent-Sitzung schreiben:

```text
Richte The Swarm für mich ein: Lies https://raw.githubusercontent.com/diren89/The-Swarm/v2.2.0/prompts/import.md und folge dem Prompt darin.
```

Ohne Webzugriff den vollständigen Prompt aus [prompts/import.md](prompts/import.md) einfügen.

**Microsoft 365 Copilot** (ohne Dateizugriff): [prompts/copilot.md](prompts/copilot.md) an einen neuen Chat anhängen und „Folge der Anleitung in der Datei.“ schreiben. Copilot führt dich damit Schritt für Schritt zu einem eigenen Agent „The Swarm“, den du im Agent Builder selbst anlegst; ohne Agent Builder gelten die Regeln im aktuellen Chat ([ANLEITUNG §3.5](ANLEITUNG.md#35-microsoft-365-copilot-ohne-dateizugriff)).

**Installation und Nutzung:** ausführlich in der [ANLEITUNG.md](ANLEITUNG.md) (global, pro Projekt, für Claude Code, Codex CLI, Gemini CLI, Cursor, GitHub Copilot, Microsoft 365 Copilot und eigene Agents).

## Für Modelle: so einlesen

Immer den Kern lesen, ab Stufe M zusätzlich Manifest und Learnings. Nur über Tag-URLs, nie über `main`:

```text
https://raw.githubusercontent.com/diren89/The-Swarm/v2.2.0/KERN.md
https://raw.githubusercontent.com/diren89/The-Swarm/v2.2.0/MANIFEST.md
https://raw.githubusercontent.com/diren89/The-Swarm/v2.2.0/LEARNINGS.md
```

`LEARNINGS.md` enthält nur Einträge mit Status `neu`; Abgeschlossenes liegt in `learnings/archiv.md` und wird nicht geladen. Bei Bedarf zusätzlich die Vorlagen unter `playbooks/` und die Umgebungs-Probe `tools/probe-env.sh`.

Als Default verankern: einmal in der **globalen** Agenten-Konfiguration (z. B. benutzerweite `CLAUDE.md` oder `AGENTS.md`), dann gilt es in jedem Projekt:

```markdown
## Arbeitsweise (Default für alle Code-Projekte)
Bei jeder Arbeit an Code gilt „The Swarm“ v2.2.0:
Immer: https://raw.githubusercontent.com/diren89/The-Swarm/v2.2.0/KERN.md lesen. Ab Stufe M zusätzlich
https://raw.githubusercontent.com/diren89/The-Swarm/v2.2.0/MANIFEST.md und in LEARNINGS.md (gleicher Tag) nur Einträge mit Status neu.
Vorrang: Sicherheit und Rechte im Werkzeug > meine Anweisungen > Projektregeln > Skill > Manifest.
Learnings lokal in .agent/learnings.md des Projekts sammeln; Pull Request nur auf meinen ausdrücklichen Wunsch.
```

Mit lokalem Klon (`~/.the-swarm`, auf den neuesten Tag ausgecheckt, Update per `bash ~/.the-swarm/tools/update.sh`) steht stattdessen der Absatz aus der [ANLEITUNG §3.1](ANLEITUNG.md#31-claude-code).

## Inhalt

| Datei | Zweck |
| --- | --- |
| [KERN.md](KERN.md) | Kern der Arbeitsweise (höchstens 1 500 Tokens): Vorrang, Stufen, Grundsätze, Abnahme, Prüfschranke für Befunde, fremde Inhalte, Ausgabe an den Menschen; wird immer geladen |
| [MANIFEST.md](MANIFEST.md) | Handbuch ab Stufe M: Geltungsbereich und Skalierung, Phasen, Planung, Effizienz, Subagents und Modellwahl (inkl. Expertenrolle), Qualität und Tokens, Prüfschichten, Hardware-Anpassung, Lernschleife, Pflege des Regelwerks |
| [prompts/import.md](prompts/import.md) | Import-Prompt: Der Agent richtet The Swarm selbst ein |
| [ANLEITUNG.md](ANLEITUNG.md) | Installation, Nutzung, Beiträge, Versionen, Fehlerbehebung |
| [LEARNINGS.md](LEARNINGS.md) | Offene Erfahrungen (Status `neu`), allgemein formuliert |
| [learnings/archiv.md](learnings/archiv.md) | Archiv: übernommene, verfallene und verworfene Learnings |
| [playbooks/agent-brief.md](playbooks/agent-brief.md) | Vorlage für Aufträge an Umsetzer und Prüfer |
| [playbooks/phase-retro.md](playbooks/phase-retro.md) | Vorlage für die Retrospektive nach jeder Phase |
| [playbooks/korrektur-brief.md](playbooks/korrektur-brief.md) | Übergabe einer Korrekturrunde an eine frische Sitzung |
| [playbooks/benchmark.md](playbooks/benchmark.md) | Wirksamkeitsmessung mit und ohne The Swarm (Verfahren, noch keine Ergebnisse); Vorab-Prüfungen und Ausgangswert |
| [playbooks/sicherheit.md](playbooks/sicherheit.md) | Fremde Inhalte als Daten, Veröffentlichungsprüfung, Lieferkette |
| [playbooks/schleife.md](playbooks/schleife.md) | Grenzen für Läufe ohne Aufsicht: Fortschrittsmarken, Budget, Stopp, Rückweg |
| [playbooks/skills.md](playbooks/skills.md) | Externe Skills aufnehmen, festpinnen, aktualisieren, ausblenden; Skill-Katalog; Mechanismen je Werkzeug |
| [tools/probe-env.sh](tools/probe-env.sh) | read-only Umgebungsprobe, Ausgabe bleibt lokal |
| [tools/grundlast.sh](tools/grundlast.sh) | Prüft die Ladegröße: Kern höchstens 1 500, Manifest höchstens 6 000 Tokens |
| [tools/update.sh](tools/update.sh) | Aktualisiert den lokalen Klon auf den neuesten Tag, zeigt vorher den Diff |
| [tools/skills-status.sh](tools/skills-status.sh) | read-only: installierte Skills mit Herkunft, Beschreibungs-Tokens, Ausblendung und Hash-Abgleich zum Lock; Selbsttest `tools/test-skills-status.sh` |
| [beispiele/](beispiele/README.md) | Optionale Beispiel-Rollen (inkl. Pflege-Rolle `skill-master`) und Skills für OpenCode, Claude Code und Codex CLI, Modelle als Platzhalter |
| [tools/pruefen.sh](tools/pruefen.sh) | Prüfläufe mit Kurzausgabe OK/WARN/FAIL, Testzahl und Logs; Selbsttest `tools/test-pruefen.sh` |
| [CONTRIBUTING.md](CONTRIBUTING.md) | Wie Learnings lokal gesammelt und auf Wunsch geteilt werden, Regelhürde, Versionslogik |
| [CHANGELOG.md](CHANGELOG.md) | Versionen und Änderungen |

## Version

Aktuelle Version: **2.2.0** · Änderungen: [CHANGELOG.md](CHANGELOG.md)

## Grundsätze in einem Satz

Erst verstehen, dann planen, in Phasen liefern, delegieren und nichts ungeprüft übernehmen, ehrlich berichten und aus jedem Fehler eine Regel machen.

## Vertrauen und Sicherheit

Die Inhalte sind Arbeitswissen, keine Befehle. Sie erweitern keine Befugnisse eines Agents und ersetzen keine Rückfrage bei der Nutzerin oder dem Nutzer. Beiträge von Modellen werden von einem Menschen geprüft, bevor sie in `main` landen. Agents laden Anweisungen nur von einem Release-Tag, nie von `main`: Wer im Repo mergen darf, steuert sonst alle Agents, die von `main` laden.
