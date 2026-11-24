# Changelog

## 1.5.0 · 2026-11-24

Nur Ergänzungen, keine bestehende Regel inhaltlich umformuliert. §5.2 Punkt 7 verweist für den Status je Kriterium jetzt auf §5.4 (Klarstellung).

- §2: neue Punkte 6 **Plankritik** (Prüfer anderer Modellfamilie, sonst unabhängiger Prüfer mit benannter Einschränkung) und 7 **Budget mit Marken** (Messquelle, alle Agents, 90 % Meldung, 100 % keine neuen kostenpflichtigen Schritte), beide Stufe L.
- §5.3: Unfertige Worktrees bleiben stehen.
- §5.4: **Abnahme mit frischen Belegen**, Status je Kriterium erfüllt / teilweise / fehlt / UNGEPRÜFT. Aus L-053.
- §5.5: Zerstörende Git-Befehle nur mit Freigabe, für Subagents möglichst technisch gesperrt; Grenzen von Prompt-Rechten benennen.
- §6.3: Stand vor Kontextkürzung sichern (L: Plandatei, S/M: Aufgabenliste oder Projektnotiz). Aus L-054.
- §7.1: In Schicht 4 Abnahme vor Code-Review, Nutzerszenarien bleiben Pflicht, Sicherheit bei Bedarf.
- §7.2: Befunde mit Konfidenz; unsichere schwere Befunde nachprüfen oder Nutzerin entscheidet (L-052). Gleiche Fehlersignatur dreimal = Grundsatzproblem (L-051).
- §9: Kurznotiz am Ende einer Aufgabe, wenn etwas auffiel; vier Zeitskalen. §11: Status je Kriterium.
- Vorlagen: Prüfer-Brief mit Blickwinkel und Konfidenz, Bericht mit Status je Kriterium; Retrospektive nutzt die Kurznotizen.
- Learnings L-051 bis L-056 (L-055, L-056 vorerst nur Learning). L-040: Pfadbeispiel anonymisiert.

## 1.4.0 · 2026-11-23

- Neu §5.1.2 **Unter-Koordinator**: großes, abgegrenztes Code-Paket als Ganzes mit eigenem Plan, Umsetzern, Prüfern und Korrekturrunden; wann einsetzen und wann nicht; kein eigener Dialog mit der Nutzerin, Weichen als `blockiert` zurück; Schachtelungstiefe per Probe prüfen. Neue Zeile in der Rollentabelle §5.1. Aus L-050.
- Neu `tools/pruefen.sh` mit Selbsttest `tools/test-pruefen.sh` (33 Fälle): Status OK/WARN/FAIL, Zahl ausgeführter Tests, getrennte Warnungen, Langausgabe je Lauf. Verweis in §6.1. Aus L-048.
- Neu `playbooks/korrektur-brief.md`: Übergabe einer Korrekturrunde an eine frische Sitzung.
- Learnings L-045 bis L-050.

## 1.3.3 · 2026-11-23

- Neu `assets/icon/`: Icon und Signet von The Swarm (vier Flugbahnen sammeln sich an einem Punkt), gestaltet nach der Signet-Grammatik von ODSV; SVG, PNG in 32/180/512/1024 px, `favicon.ico`, kurze Nutzungsregeln.
- README zeigt das Icon oben.
- Keine Regeländerung im Manifest.

## 1.3.2 · 2026-11-23

- Neu `prompts/copilot.md`: Datei zum Anhängen in Microsoft 365 Copilot. Copilot führt durch den Agent Builder (Configure), gibt Name, Beschreibung, Anweisungen (Manifest-Kern, 7.490 Zeichen) und Startprompts vor; Manifest und Learnings als Wissensdateien `.txt`; optional Code Interpreter (Python-Sandbox, ersetzt keinen Projekt-Test); vier Testfragen, Create erst nach bestandenem Test oder bewusster Entscheidung trotz Mangel; Fallback nur im Chat. Die Person legt den Agent selbst an.
- ANLEITUNG neu §3.5 Microsoft 365 Copilot (bisher §3.5 API wird §3.6); Hinweise in README, `prompts/import.md` und `llms.txt`.
- Keine Regeländerung im Manifest.

## 1.3.1 · 2026-11-23

- CONTRIBUTING: Die Tabelle **Releasenotes** in der README zu pflegen ist bei jeder neuen Version Pflicht; nach dem Merge wird der Tag `v<Version>` gesetzt.
- Keine Regeländerung im Manifest.

## 1.3.0 · 2026-11-23

- Neu §5.5 **Rechte und Werkzeuge**: Rechte als Allowlist und per echtem Lauf prüfen; ein Verbot sperrt den ganzen Aufruf (ein Befehl je Aufruf, bei Ablehnung aufteilen); Werkzeugsatz je Modellfamilie prüfen; Schutz im Werkzeug statt nur im Prompt (aufgelöste Pfade, maschineller Abgleich). Aus L-027, L-028, L-029, L-031, L-033, L-035.
- Neu §7.3 **Abbrechbare Läufe**: Checkpoint mit Lückenliste, atomarer Austausch mit Abbruchtests, Fortsetzung in frischer Session, Endabgleich gegen die Quelle. Aus L-030, L-033, L-034.
- Neu §6.1 **Prüfungen selbst prüfen**: verfälschte Eingaben, Zahl geprüfter Fälle, Testfall eingetreten. Aus L-026, L-030, L-034.
- Neu §6.2 **Daten nicht durch das Modell kopieren**: direkter Weg vom Werkzeug in die Datei, Quittung mit Objektzahl. Aus L-032.
- Ergänzt §2 (Budgets und Kontingente in der Umgebungsprobe, L-024) und §5.2 (abweichendes Ausgabeformat ausdrücklich nennen, L-025; Werkzeuge im Brief, L-029).
- L-021 bis L-023 bleiben `neu` (einmalig und werkzeugspezifisch).
- README: neuer Abschnitt **Releasenotes** mit Versionsübersicht und Lesehilfe zu Versionsnummern.

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
