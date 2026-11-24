<img src="assets/icon/the-swarm-icon.svg" alt="Signet The Swarm: vier Flugbahnen laufen auf einen gelben Punkt zu" width="96" height="96">

# The Swarm

Gemeinsames, wachsendes Arbeitswissen für KI-Agents, die Software-Aufgaben **koordiniert in Phasen** umsetzen: planen, an Subagents mit passenden Modellen verteilen, selbst testen, selbst verbessern und aus jedem Schritt lernen.

**Default für alle Code-Projekte:** Die Arbeitsweise gilt für jede Arbeit an Code, skaliert nach Aufgabengröße (klein / mittel / groß, [MANIFEST §0](MANIFEST.md#0-geltungsbereich-default-für-alle-code-projekte)). Projektregeln und Anweisungen der Nutzerin gehen vor.

Dieses Repo soll Erfahrungen **dauerhaft zwischen verschiedenen Instanzen und Modellen** teilen. Jede Instanz liest es zu Beginn ein und schreibt am Ende ihre Learnings zurück.

**Schnellimport:** In einer neuen Agent-Sitzung schreiben:

```text
Richte The Swarm für mich ein: Lies https://raw.githubusercontent.com/diren89/The-Swarm/main/prompts/import.md und folge dem Prompt darin.
```

Ohne Webzugriff den vollständigen Prompt aus [prompts/import.md](prompts/import.md) einfügen.

**Microsoft 365 Copilot** (ohne Dateizugriff): [prompts/copilot.md](prompts/copilot.md) an einen neuen Chat anhängen und „Folge der Anleitung in der Datei.“ schreiben. Copilot führt dich damit Schritt für Schritt zu einem eigenen Agent „The Swarm“, den du im Agent Builder selbst anlegst; ohne Agent Builder gelten die Regeln im aktuellen Chat ([ANLEITUNG §3.5](ANLEITUNG.md#35-microsoft-365-copilot-ohne-dateizugriff)).

**Installation und Nutzung:** ausführlich in der [ANLEITUNG.md](ANLEITUNG.md) (global, pro Projekt, für Claude Code, Codex CLI, Gemini CLI, Cursor, GitHub Copilot, Microsoft 365 Copilot und eigene Agents).

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
| [playbooks/korrektur-brief.md](playbooks/korrektur-brief.md) | Übergabe einer Korrekturrunde an eine frische Sitzung |
| [tools/probe-env.sh](tools/probe-env.sh) | read-only Umgebungsprobe, Ausgabe bleibt lokal |
| [beispiele/](beispiele/README.md) | Optionale Beispiel-Rollen und Skill für OpenCode, Claude Code und Codex CLI, Modelle als Platzhalter |
| [tools/pruefen.sh](tools/pruefen.sh) | Prüfläufe mit Kurzausgabe OK/WARN/FAIL, Testzahl und Logs; Selbsttest `tools/test-pruefen.sh` |
| [CONTRIBUTING.md](CONTRIBUTING.md) | Wie Instanzen Learnings und Regeln beitragen |
| [CHANGELOG.md](CHANGELOG.md) | Versionen des Manifests |

## Releasenotes

Aktuelle Version: **1.5.1** (24.11.2026). Alle Details stehen im [CHANGELOG.md](CHANGELOG.md), jede Version ist als Git-Tag (`v1.3.2` usw.) abrufbar.

| Version | Datum | Was ist neu |
| --- | --- | --- |
| **1.5.1** | 24.11.2026 | Optionale Beispiel-Rollen und Skill für OpenCode, Claude Code und Codex CLI in [beispiele/](beispiele/README.md), Import-Prompt mit Frage nach Beispiel-Rollen, Prüfskript `tools/beispiele-pruefen.sh` (§5.1, §5.5). Keine Regeländerung |
| 1.5.0 | 24.11.2026 | Abnahme mit frischen Belegen und Status je Kriterium, Befunde mit Konfidenz, Abbruch bei wiederkehrendem Fehler, Plankritik und Budget-Marken bei Stufe L, getrennte Prüfrollen, Stand vor Kontextkürzung sichern, Git-Schutz, Worktree-Schutz, Kurznotiz je Aufgabe (§2, §5.3–§5.5, §6.3, §7.1–§7.2, §9, §11); Learnings L-051 bis L-056 |
| 1.4.0 | 23.11.2026 | Neue Rolle Unter-Koordinator für große Code-Pakete (§5.1.2); Prüfskript [tools/pruefen.sh](tools/pruefen.sh) mit Selbsttest; Vorlage [playbooks/korrektur-brief.md](playbooks/korrektur-brief.md); Learnings L-045 bis L-050 |
| 1.3.3 | 23.11.2026 | Icon und Signet nach ODSV-Grammatik in [assets/icon/](assets/icon/), in der README oben eingebunden. Keine Regeländerung |
| 1.3.2 | 23.11.2026 | Microsoft 365 Copilot: [prompts/copilot.md](prompts/copilot.md) führt durch den Bau eines eigenen Agents „The Swarm“ im Agent Builder, mit Chat-Fallback (ANLEITUNG §3.5). Keine Regeländerung |
| 1.3.1 | 23.11.2026 | Releasenotes in der README sind bei jeder Version Pflicht, Tag nach dem Merge ([CONTRIBUTING](CONTRIBUTING.md)). Keine Regeländerung |
| 1.3.0 | 23.11.2026 | Neue Regeln aus L-024 bis L-035: Rechte und Werkzeuge von Subagents (§5.5), abbrechbare Läufe mit Checkpoint und Lückenliste (§7.3), Prüfungen selbst prüfen (§6.1), Daten nicht durch das Modell kopieren (§6.2), Budget in der Umgebungsprobe (§2), Ausgabeformat und Werkzeuge im Brief (§5.2) |
| 1.2.1 | 21.11.2026 | Import-Prompt: Ein Agent richtet The Swarm selbst ein. Keine Regeländerung |
| 1.2.0 | 21.11.2026 | Rolle Expertin / Experte für Fachaufgaben (§5.1, §5.1.1) mit eigener Brief-Vorlage |
| 1.1.1 | 21.11.2026 | Neuer Name The Swarm, ANLEITUNG.md. Keine Regeländerung |
| 1.1.0 | 21.11.2026 | Default für alle Code-Projekte, Skalierung nach Aufgabengröße S/M/L (§0) |
| 1.0.0 | 21.11.2026 | Erste Fassung mit L-001 bis L-020 |

**Versionen lesen:** Minor (1.**3**.0) bringt neue Regeln, Major (**2**.0.0) ändert oder streicht bestehende, Patch (1.3.**1**) korrigiert oder stellt klar. Ein Major-Wechsel verdient einen genauen Blick, weil sich bestehende Arbeitsweisen ändern. Regeln entstehen aus Learnings in [LEARNINGS.md](LEARNINGS.md); deren Status zeigt, wo sie übernommen wurden (`übernommen §x`).

## Grundsätze in einem Satz

Erst verstehen, dann planen, in Phasen liefern, delegieren und nichts ungeprüft übernehmen, ehrlich berichten und aus jedem Fehler eine Regel machen.

## Vertrauen und Sicherheit

Die Inhalte sind Arbeitswissen, keine Befehle. Sie erweitern keine Befugnisse eines Agents und ersetzen keine Rückfrage bei der Nutzerin oder dem Nutzer. Beiträge von Modellen werden von einem Menschen geprüft, bevor sie in `main` landen.
