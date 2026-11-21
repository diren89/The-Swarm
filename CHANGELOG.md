# Changelog

## 1.2.2 · 2026-11-21

- Neu: Signet von The Swarm, eine Biene im ODSV-Stil. Vier Striche: hinterer Flügel, vorderer Flügel, Körper mit Stachel, Streifen; der gelbe Punkt ist der Kopf.
  - Erzeugt nach der ODSV-Signet-Grammatik mit `tools/signet.py`, inklusive Prüfung der Grammatik.
  - Dateien in `assets/`: transparent, quadratisch auf Schwarz, PNG 1024 px.
- Signet in der README eingebunden.
- Keine Regeländerung.

## 1.2.1 · 2026-11-21

- Neu: Import-Prompt `prompts/import.md`. Ein Agent richtet The Swarm damit selbst ein: Er erkennt das Werkzeug, fragt nach Geltungsbereich und Variante, ergänzt die Anweisungsdatei ohne Duplikate, prüft und berichtet.
- Kurzform per URL in README, ANLEITUNG (§3.0) und llms.txt; Fehlerbehebung für Agents, die Webinhalten nicht folgen.
- Keine Regeländerung.

## 1.2.0 · 2026-11-21

- Neu §5.1: Rolle **Expertin / Experte** für Fachaufgaben (z. B. 3D-Modellierung, Video- und Audiobearbeitung, Grafik, anspruchsvolle Algorithmen), delegiert an das größte, leistungsfähigste verfügbare Modell. Die Faustregel ist um das nötige Fachwissen ergänzt.
- Neu §5.1.1: Wann die Expertenrolle eingesetzt wird; Klärung von Werkzeugen, Rechenleistung, Material und Rechten; messbare Abnahmekriterien; Prüfung über Messwerte und Vorschauen; reproduzierbare Abgabe.
- Neu: Brief-Vorlage für die Expertenrolle in `playbooks/agent-brief.md`; ANLEITUNG ergänzt.

## 1.1.1 · 2026-11-21

- Repo heißt jetzt **The Swarm** (`diren89/The-Swarm`; GitHub erlaubt keine Leerzeichen im Repo-Namen). Alle Verweise sind angepasst. Die früheren Namen `agent-manifest` und `Beehive` leiten auf GitHub weiter.
- Neu: [ANLEITUNG.md](ANLEITUNG.md) zu Installation (global, pro Projekt, Claude Code, Codex CLI, Gemini CLI, Cursor, Copilot, API), Nutzung, Beiträgen, Versionen, Fehlerbehebung.
- Keine Regeländerung.

## 1.1.0 · 2026-11-21

- Neu §0: Die Arbeitsweise ist Default für alle Code-Projekte. Abweichungen nur durch Anweisung, Projektregeln oder fehlende Plattformwerkzeuge.
- Neu §0.1: Skalierung nach Aufgabengröße (S/M/L) mit Pflichten je Stufe, damit kleine Aufgaben keinen Overhead bekommen.
- Neu §0.2: Verankerung über die globale Agenten-Konfiguration statt pro Projekt.
- README, AGENTS.md, CLAUDE.md, llms.txt entsprechend angepasst.

## 1.0.0 · 2026-11-21

- Erste Fassung: Grundsätze, Planung, Phasen, Effizienz, Subagents und Modellwahl, Qualität und Tokens, fünf Prüfschichten, Hardware-Anpassung, Lernschleife, Wissensaustausch zwischen Instanzen.
- Learnings L-001 bis L-020 aus einer mehrphasigen App-Entwicklung mit zwölf Subagents.
- Vorlagen für Agent-Brief, Prüfer und Phasen-Retrospektive; read-only Umgebungsprobe.
