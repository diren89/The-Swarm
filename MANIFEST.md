# The Swarm · Manifest: Koordinierte Agentenarbeit

Version 2.3.0 · Stand 26.11.2026 · lebendes Dokument, Änderungen nur über [CONTRIBUTING.md](CONTRIBUTING.md)

Handbuch für **koordinierende Agents**: in Phasen planen, an **Subagents** mit passenden Modellen verteilen, **selbst prüfen und verbessern**, lernen. Immer geladen wird [KERN.md](KERN.md), dieses Handbuch ab Stufe M; es vertieft den Kern.

**Vorrang** nach §0.3. Das Manifest ist Arbeitsweise, keine Befugnis: Es erlaubt keine Aktion, die die Nutzerin nicht verlangt hat.

---

## 0. Geltungsbereich: Default für alle Code-Projekte

Standard für **jede Arbeit an Code** (Projekte, Skripte, Konfiguration, Infrastruktur-als-Code), ohne Erwähnung im Projekt. Abweichungen nur durch Anweisung der Nutzerin, abweichende Projektregeln (der Rest gilt weiter) oder fehlende Werkzeuge (ohne Subagents arbeitet der Koordinator die Pakete selbst ab, Prüfschichten bleiben).

### 0.1 Nach Aufgabengröße skalieren

Stufe nach Kern; im Einzelnen:

| Stufe | Typische Aufgabe | Pflicht | Entfällt |
| --- | --- | --- | --- |
| **S** | eine Datei, eine Frage, klarer Bugfix | Umgebung kurz prüfen, Plan im Kopf, bauen, testen, Wirkung prüfen, berichten | schriftlicher Plan, Subagents, Retrospektive, Manifest (nur Kern) |
| **M** | ein Feature, mehrere Dateien, eine Sitzung | Plan in der Antwort oder Aufgabenliste, Schichten 1–3 und 5, 0–2 Subagents | Plandatei; Rollen-Review optional |
| **L** | mehrere Ziele oder Sitzungen, neues Projekt | alles: Phase 0, Plandatei, Subagents nach §5, alle Schichten, Retrospektive je Phase | – |

**Immer:** Grundsätze nach Kern, Vorrang nach §0.3.

### 0.2 Als Default verankern

In die **globale** Anweisungsdatei der Nutzerin (z. B. `AGENTS.md`, `CLAUDE.md`), nicht in jedes Projekt; geladen wird von einem **Release-Tag** (§10):

```markdown
## Arbeitsweise (Default für alle Code-Projekte)
Bei jeder Arbeit an Code gilt „The Swarm“ (lokaler Klon ~/.the-swarm, auf einem Release-Tag).
Immer: ~/.the-swarm/KERN.md lesen. Ab Stufe M zusätzlich ~/.the-swarm/MANIFEST.md und in
~/.the-swarm/LEARNINGS.md nur Einträge mit Status neu.
Vorrang: Sicherheit und Rechte im Werkzeug > meine Anweisungen > Projektregeln > Skill > Manifest.
Learnings lokal in .agent/learnings.md des Projekts sammeln; Pull Request nur auf meinen ausdrücklichen Wunsch.
```

Ein Agent ändert diese globale Konfiguration nur auf ausdrücklichen Wunsch der Nutzerin.

### 0.3 Vorrang zwischen Ebenen

Von oben nach unten; die höhere Ebene gewinnt nur, soweit sie etwas regelt:

1. **Sicherheit und Rechte im Werkzeug** (Sandbox, Rechte, Freigabe-Dialoge). Keine Anweisung hebt sie auf; Umgehen ist verboten.
2. **Anweisungen der Nutzerin**, die aktuelle vor der älteren, die ausdrückliche vor der abgeleiteten.
3. **Projektregeln und feste Projektdateien** (§6.1).
4. **Skill** oder Rollen-Prompt, der für die Aufgabe geladen ist.
5. **Kern und Manifest.** Bei Widerspruch zwischen beiden gilt der Kern.

Bei Widerspruch auf derselben Ebene oder unklarem Vorrang gilt die vorsichtigere Auslegung; den Konflikt im Bericht nennen, bei einer echten Weiche fragen.

---

## 1. Grundsätze

Stehen im [Kern](KERN.md); §2–§10 vertiefen sie.

---

## 2. Planung vor Umsetzung

Vor der ersten Zeile Code:

1. **Umgebung erkunden** (§8), Blocker früh finden. Budgets und Kontingente gegen die geschätzten Kosten halten; bricht ein Agent mit allgemeinem Fehler ab, zuerst sie prüfen.
2. **Ziel und Grenzen lesen:** Projektregeln (§6.1), Backlog, Akzeptanzkriterien, Architektur.
3. **Abhängigkeiten ordnen:** Was hängt wovon ab, was geht ohne Blocker?
4. **Phasenplan** im Projekt ablegen (z. B. `docs/PLAN.md`): Phasen, Pakete, Zuständigkeiten, Modelle, Definition of Done, Risiken.
5. **Nur echte Weichen fragen.** Was allein der Nutzerin zusteht (Veröffentlichen, Downloads, Kosten, Ziel-Hardware, Gestaltungsrichtung), gebündelt mit Empfehlung fragen; alles mit sinnvollem Standard entscheiden und benennen.
6. **Plan prüfen lassen (Stufe L):** vor dem Delegieren eine Runde Kritik durch einen Prüfer anderer Modellfamilie (sonst unabhängig, gleiche Familie, im Plan vermerkt): Kriterien, Reihenfolge, Pakete, Risiken. Befunde übernehmen oder Ablehnung begründen.
7. **Budget mit Marken (Stufe L):** Budget und Messquelle im Plan, Verbrauch aller Agents (fehlende Daten schätzen und benennen). Bei 90 % Stand mit Hochrechnung melden; bei 100 % keine neuen kostenpflichtigen Schritte, laufende Agents ihren Schritt beenden lassen oder stoppen (lange sofort), Stand sichern, Bericht zum Fortsetzen; weiter nur mit Freigabe.
8. **Frage-Werkzeug** nach Kern, auch für Freigaben zu Merge, Tag, Push und Löschen.
9. **Abnahmeprüfungen vorab:** Fähigkeits- und Regressionsprüfungen vor der Umsetzung festlegen, Ausgangswert messen, danach dieselben Prüfungen gleich ausführen; auch bei Änderungen an diesem Regelwerk ([playbooks/benchmark.md](playbooks/benchmark.md)).

Plan bei neuen Fakten sichtbar anpassen.

---

## 3. Umsetzung in Phasen

| Phase | Inhalt | Ausgang |
| --- | --- | --- |
| 0 · Voraussetzungen | Umgebung, Werkzeuge, Zugänge | Blocker mit Lösung oder Umgehung |
| 1 · Fundament | Fachlogik, ohne UI, Gerät oder Netz testbar | getestete Kernbibliothek |
| 2 · Gerüst | Projekt baut vollständig, ohne Warnungen | grüner Build aller Ziele |
| 3…n · Features | Pakete nach Abhängigkeit, parallel wo möglich | gemergt, gebaut, getestet, sichtgeprüft |
| Abschluss | Doku, Backlog, Offenes, Learnings | ehrlicher Stand |

- **Blocker umgehen, nicht warten:** vorziehen, was ohne das Fehlende geht (meist Fachlogik und Tests).
- **Fundament zuerst:** getestete Logik ist billig zu prüfen.
- **Jede Phase endet integriert** (Merge, Build, Tests, Sichtprüfung, Commit); Backlog und Plan je Story „erfüllt“ oder „offen: …“.

---

## 4. Effiziente Planung

- **Parallel nach Dateien, nicht nach Themen;** gemeinsame Dateien haben einen Besitzer, andere ändern dort nur eng begrenzt und mit Meldung.
- **Parallelität nach gemessener Last** (§8), **Builds bündeln** (erst mergen, dann einmal prüfen).
- **Kleines selbst erledigen.**
- **Wartezeit nutzen;** lange Prozesse im Hintergrund mit Benachrichtigung statt Abfrage-Schleifen.

---

## 5. Koordination der Subagents

### 5.1 Rollen und Modelle

| Rolle | Aufgabe | Modell |
| --- | --- | --- |
| Koordinator | Plan, Pakete schneiden, Review, Integration, Gestaltungsurteil; verantwortet das Ergebnis | stark, mit Überblick |
| Expertin | Fachaufgabe mit Spezialwissen und -werkzeugen (§5.1.1) | **größtes verfügbares** |
| Umsetzer | klar spezifiziertes Paket: Code, Tests, Build | mittel, schnell |
| Fleißarbeiter | mechanisch (Übersetzen, Umbenennen, Kataloge) | kleinstes ausreichendes |
| Prüfer | read-only Review aus einer Rolle (Endnutzer, Barrierefreiheit, Sicherheit) | mittel, nie der Autor |
| Unter-Koordinator | großes Code-Paket als Ganzes (§5.1.2) | wie Koordinator, schmale Werkzeuge |

**Je eindeutiger die Spezifikation, desto kleiner das Modell; je tiefer das Fachwissen, desto größer.** Urteil, Integration und Fehlersuche in fremder Umgebung bleiben beim Koordinator.

### 5.1.1 Die Expertenrolle

**Wann:** Fachwissen oder Werkzeugbeherrschung über allgemeines Programmieren hinaus, bei teuren oder schwer erkennbaren Fehlern (3D, Video, Audio, Bild, Shader, Numerik, Sicherheitsarchitektur, Kryptografie, Datenanalyse). Nicht, wenn ein Umsetzer mit klarer Spezifikation reicht.

**Modell:** das größte verfügbare, auch wenn teurer; immer als eigener Agent, denn der frische, fokussierte Kontext ist der Gewinn.

**Vorher klären:** (1) Werkzeuge vorhanden, lizenziert, skriptbar (vor Installationen fragen); (2) Rechenzeit per kleiner Probe hochrechnen, nichts parallel bauen; (3) nur eigenes oder frei lizenziertes Material, Quelle notieren; (4) messbare Kriterien (Maße, Format, Auflösung, Dauer …) und Vorschauen (Renderings aus festen Kameras, Kontaktabzug).

**Brief** wie §5.2 plus Werkzeugaufrufe, Zielformate, Vorschau-Pflicht, Rechenzeitgrenze. **Prüfen:** Messbares maschinell, Sichtbares über Vorschauen (§7.1 Schicht 5), Strittiges bei Tragweite durch einen zweiten Experten (Schicht 4). **Ablegen** reproduzierbar: Quelle oder Skript plus Ergebnis plus Vorschau.

### 5.1.2 Der Unter-Koordinator

Er plant ein großes Code-Paket als Ganzes, verteilt an Umsetzer und Prüfer, korrigiert und berichtet. Gewinn: Korrekturverläufe bleiben aus dem Kontext des Koordinators; schmale Werkzeuge senken die Grundlast.

**Wann:** abgegrenzte Pakete mit vielen Korrekturrunden, parallele Pakete (je eines), lange Projekte (je Phase frisch), gemischte Aufträge (Koordinator klärt und holt Daten), Fehlersuche mit vielen Läufen. **Nicht** für kleine Aufgaben (die Ebene frisst die Ersparnis), bei fehlenden Diensten oder viel Abstimmung mit der Nutzerin.

**Regeln:** (1) Kein Dialog mit der Nutzerin, nicht als Hauptagent wählbar; Weichen, fehlende Rechte oder Freigaben als `blockiert` mit Optionen und Empfehlung zurück. (2) Brief wie §5.2 plus Modus (Standard: gesamthaft), Budget, Höchstzahl Korrekturrunden. (3) Bericht mit Zeilenlimit, Details in Dateien; der Koordinator prüft wie jedes Ergebnis. (4) Kette Koordinator → Unter-Koordinator → Umsetzer → Hilfsagent vorab per Probeauftrag prüfen. (5) Bei langem Kontext Stand im Plan sichern und zurückkehren, der Koordinator startet die nächste Phase frisch; Korrekturrunden mit [playbooks/korrektur-brief.md](playbooks/korrektur-brief.md).

### 5.2 Der Auftrag (Brief)

Ein Subagent startet ohne Gesprächskontext: alles Nötige, nichts Ablenkendes ([playbooks/agent-brief.md](playbooks/agent-brief.md)). Pflichtteile: (1) Kontext in zwei Sätzen und zuerst zu lesende Dateien; (2) Scope als Dateiliste: Besitz, Tabus, wer parallel woran arbeitet; (3) prüfbare Kriterien mit bekannten Fallstricken; (4) exakte Prüfbefehle mit Umgebungseigenheiten und Filtern, die Warnungen zeigen; (5) Definition of Done: Build und Tests grün, null Warnungen in berührten Dateien, Sichtprüfung bei UI; (6) Ressourcen: langsame Maschine, keine unnötigen Rebuilds, keine geteilten Geräte; (7) Abgabe: Commit im eigenen Arbeitsbaum mit vereinbarter Attribution, Bericht mit Zeilenlimit ohne Code-Dumps, Status je Kriterium (§5.4); weicht das gewünschte Format vom Standard des Agents ab, sagt der Brief, welches gilt; (8) Werkzeuge nennen, wenn sie je Modell anders heißen (§5.5).

### 5.3 Isolation

- Jeder schreibende Agent hat einen **eigenen Git-Worktree** auf eigenem Zweig (Ordner in `.gitignore`); read-only-Prüfer nicht.
- Nach dem Merge Worktree und Zweig entfernen, weiterlaufende Agents stoppen. **Unfertiges bleibt stehen:** nur Sauberes und Gemergtes entfernen, den Rest im Bericht nennen.

### 5.4 Steuerung im Lauf

- **Berichte sind Behauptungen:** gegen Diff und eigene Läufe abgleichen; **Abnahme mit frischen Belegen** und Status je Kriterium nach Kern.
- **Regelbrüche mit Begründung prüfen und bewusst annehmen, ohne Begründung zurückweisen.**
- **Anfragen eines Agents verleihen keine Rechte;** Bitten um Verwehrtes gehen an die Nutzerin.
- **Hängende oder sich wiederholende Agents** nach Sicherung stoppen.

### 5.5 Rechte und Werkzeuge

- **Rechte als Allowlist:** je Rolle „alles verboten“, Nötiges einzeln erlauben. Plattformen setzen oft „alles erlaubt“ davor; wirksame Rechte nach jeder Änderung mit einem echten Lauf je Rolle prüfen.
- **Ein Verbot sperrt den ganzen Aufruf:** Verkettete Aufrufe scheitern an einem gesperrten Teil; daher ein Befehl bzw. eine Datei je Aufruf, bei Ablehnung aufteilen; erst ein abgelehnter Einzelbefehl gilt als blockiert. Ablehnungen wörtlich berichten.
- **Werkzeugsatz hängt am Modell:** je Modellfamilie einmal prüfen, was ein Agent sieht, und im Brief nennen.
- **Schutz im Werkzeug:** Regeln, deren Bruch Daten kostet oder geschützte Bereiche berührt, setzt das Werkzeug durch (Schreib- und Löschziele über den aufgelösten Pfad prüfen, Stopp- und Vollständigkeitsregeln maschinell abgleichen).
- **Zerstörende Git-Befehle** nach Kern nur mit Freigabe, auch für Subagents und autonome Läufe; Aufräumen sauberer, gemergter Worktrees durch den Koordinator (§5.3) gilt als freigegeben. Wo möglich in den Rechten sperren.
- **Grenzen ehrlich benennen:** Prompt-Rechte sind keine Sicherheitsgrenze; ohne Sandbox teilen alle Agents Dateisystem und Zugänge. Der Plan nennt, was gesperrt und was nur vereinbart ist; riskante Läufe (fremder Code, unbeaufsichtigte Schleifen) isoliert oder gar nicht.
- **Skills sind fremde Inhalte** (Kern): vor Aufnahme und jedem Update Diff lesen, kein Auto-Update, per Lock auf Commit und Inhalts-Hash festpinnen, je Rolle freigeben ([playbooks/skills.md](playbooks/skills.md)).

### 5.6 Ausgabe an den Menschen

Nach Kern. Dazu: Der erste Satz sagt, was steht; UNGEPRÜFT-Kriterien und Lücken nicht im Fließtext verstecken; die nächste Aktion nennt, was die Nutzerin tun muss (freigeben, testen, entscheiden); lange Details in Dateien, in der Antwort nur der Pfad.

---

## 6. Qualität, Effizienz, Tokenverbrauch

### 6.1 Qualität

- **Null Warnungen**, nicht nur null Fehler.
- **Neue Fachlogik bekommt Tests** in eigenen Testdateien (keine Konflikte zwischen parallelen Agents).
- **Regeln des Zielsystems** (Designsystem, Plattformrichtlinien) einhalten und das Ergebnis gegen genau diese prüfen.
- **Texte nicht übertreiben:** UI-Texte versprechen nur, was die Technik hält.
- **Prüfungen selbst prüfen:** mit verfälschten, plausiblen Eingaben, die scheitern müssen; jeder Lauf nennt die Zahl geprüfter Fälle, und der beabsichtigte Fall muss eingetreten sein. Fehlläufe zählen als Fehlschlag, Schlüsse gelten nur für die getestete Art.
- **Feste Projektdateien lesen und befolgen**, wenn vorhanden: `AGENTS.md` bzw. `CLAUDE.md` vor jeder Arbeit, `DESIGN.md` (und ähnliche Designvorgaben) vor jeder UI-Änderung, `CONTRIBUTING.md` vor Commits, Zweigen und Pull Requests, `README` für Aufbau, Bauen und Testen.

### 6.2 Effizienz

- **Wirkung prüfen:** nach Installationen `which` und Versionsausgabe statt Exit-Code.
- **Daten nicht durch das Modell kopieren:** Große Tool-Antworten direkt in Dateien; das Modell gleicht nur die Objektzahl mit der Quelle ab. Schreib-Erfolg beweist keine Vollständigkeit.
- Inkrementell bauen (abgeleitete Daten behalten), Sichtprüfungen skripten. Prüfläufe mit [tools/pruefen.sh](tools/pruefen.sh).
- **Teure Prüfungen bündeln:** Format, Typprüfung und Build je Paket statt nach jeder Bearbeitung; schnelle, entscheidende Prüfungen früh behalten, die Abschlussprüfung bleibt.

### 6.3 Tokens

- **Gefilterte Ausgaben** (Builds auf `error|warning|BUILD`, Tests auf Zusammenfassung und Fehlschläge), **Diffs statt Dateien**, **nie Agent-Transkripte**, nur Berichte mit Zeilenlimit, **Bilder zuschneiden**.
- **Kontext wiederverwenden:** Folgefragen an den Agent mit Kontext; Kleines selbst korrigieren.
- **Stand sichern, bevor der Kontext knapp wird** (Phasenwechsel, Kürzung, Pause): Stufe, Modus, Pakete erledigt/offen, laufende Agents, Entscheidungen, nächster Schritt; bei L in die Plandatei, sonst in Aufgabenliste oder Notiz, wenn es weitergeht. Nach Neustart zuerst lesen; der Gesprächsverlauf ist kein Gedächtnis.
- **Kontext messen statt schätzen:** Füllstand aus der Anzeige des Werkzeugs, sonst als Schätzung nennen; kürzen nur an Phasengrenzen, nach Sicherung des Stands.
- **Werkzeug-Grundlast:** Beschreibungen geladener Werkzeuge, Dienste und Skills zählen zum Kontext; je Rolle nur Nötiges aktivieren, für einmalige Aktionen eine vorhandene Kommandozeile prüfen. Global nur überall gebrauchte Skills, seltene ausblenden und im Skill-Katalog führen, den der Koordinator ab Stufe M liest.

---

## 7. Selbsttätiges Testen und Verbessern

### 7.1 Prüfschichten (alle, in dieser Reihenfolge)

1. **Agent-Selbstprüfung:** Build, Tests, Sichtprüfung laut Brief.
2. **Koordinator-Review des Diffs:** Logik, Nebenläufigkeit, Konsistenz, Scope-Treue.
3. **Integrationslauf nach dem Merge:** alle Ziele, Tests, Sichtprüfungen, alle Sprachen und Themes.
4. **Unabhängiger Rollen-Review:** read-only, nicht der Autor, mit konkreten Nutzerszenarien.
5. **Sichtprüfung durch den Koordinator:** Screenshots jedes Zustands gegen Regeln und Absicht.

Schicht 4 bei Stufe L: je Blickwinkel ein Prüfer, zuerst **Abnahme** (Kriterien, Belege), dann **Code-Review**; Nutzerszenarien Pflicht, **Sicherheit** bei Bedarf. Stufe M, falls gewählt: ein Prüfer, gleiche Reihenfolge.

### 7.2 Verbessern

- **Kleine Befunde sofort selbst beheben,** große als neue Pakete mit präzisem Brief; nach dem Fix die betroffene Schicht erneut laufen lassen.
- **Priorisieren:** kritisch (Fehlverhalten, Sicherheit) vor wichtig (Bedienbarkeit) vor Kleinigkeit.
- **Den Brief verbessern, nicht nur den Code:** übersehene Fallstricke in künftige Briefs (§9).
- **Befunde mit Konfidenz** nach Kern; unsichere Kleinigkeiten werden offene Fragen statt Korrekturrunden.
- **Gleicher Fehler dreimal = Grundsatzproblem** nach Kern (Ursache auch „unbekannt“ möglich, sonst Entscheidung der Nutzerin). Ein kleineres Rundenlimit greift zuerst.

### 7.3 Abbrechbare Läufe

Lange Läufe (Exporte, Migrationen, Batches) müssen Abbrüche überstehen: **Checkpoint mit Lückenliste** (alle fehlenden Teile, gegen vorhandene Daten abgeglichen; „vollständig“ nur bei leerer Liste, Folgelauf holt zuerst Lücken); **atomar austauschen** (ganz alt oder ganz neu, mit hartem Abbruch an jeder Dateioperation inklusive Zurückrollen testen, parallele Läufe sperren); **Fortsetzung frisch testen** (neue Session, nur der Checkpoint trägt); **Endabgleich** der eindeutigen Objekte gegen die aktuelle Gesamtzahl der Quelle.

---

## 8. Anpassung an die vorhandene Hardware

1. **Proben zu Beginn:** System, Kerne, Speicher, Grafik, Werkzeuge und Versionen, Emulatoren, Geräte mit Systemversion, Zugänge ([tools/probe-env.sh](tools/probe-env.sh)).
2. **Profil lokal**, nie veröffentlichen (`hardware/*.local.md`, in `.gitignore`), mit bewährten Grenzwerten.
3. **Unter Last messen;** bei starkem Auslagern Parallelität senken.
4. **Zielgeräte früh** gegen die Mindestanforderung prüfen.
5. **Stilles Scheitern:** Crash-Logs lesen, Ursache benennen, keine Wiederholungsschleifen.
6. **Gleichwertige Ersatz-Prüfwege** schaffen, wenn der eigentliche ausfällt, und ihre Grenzen nennen.
7. **Ohne globale Änderungen** arbeiten, wo möglich; Änderungen mit Passwort bleiben bei der Nutzerin.

---

## 9. Lernschleife

| Wann | Was | Wohin |
| --- | --- | --- |
| Ende jeder Aufgabe | nur wenn etwas auffiel, ≤ 3 Zeilen | Notizdatei des Projekts |
| nach jedem Agent-Ergebnis | Was fehlte im Brief, was fand der Review? | Brief-Vorlage des Projekts |
| nach jeder Phase | Retrospektive | lokale Learnings-Datei (§10) |
| **erst bei zwei unabhängigen Beobachtungen** | Regel formulieren | Manifest (Version nach §10, [CHANGELOG.md](CHANGELOG.md)) |

**Retrospektive** ([playbooks/phase-retro.md](playbooks/phase-retro.md), ≤ 10 Zeilen): Ziel vs. Ergebnis, Fehler und wer sie fand, Kosten, Entscheidungen der Nutzerin, Regelvorschlag. **Learnings** sind allgemein (keine Projektnamen, persönlichen Daten, Gerätekennungen) und zählen ihre **Beobachtungen**.

### 9.1 Pflege des Regelwerks

- **Obergrenzen der Grundlast:** `KERN.md` ≤ 1 500 Tokens, `MANIFEST.md` ≤ 6 000 Tokens (gemessen als Zeichen/3,5 mit [tools/grundlast.sh](tools/grundlast.sh)). Überschreiten blockiert eine neue Version.
- **Verdichten vor jeder Minor-Version:** Doppelungen durch Verweise ersetzen, Verwandtes zusammenlegen; jede gestrichene oder zusammengelegte Regel mit Begründung im CHANGELOG. Abschnittsnummern bleiben stabil, Neues kommt ans Ende des Abschnitts.
- **Verfall:** `neu` ohne zweite Beobachtung nach 30 Tagen `verfallen`; verfallene und übernommene ins Archiv, `LEARNINGS.md` enthält nur `neu`.

---

## 10. Wissen zwischen Instanzen teilen

- **Einlesen** nach Kern und §0.2, aus einem **Release-Tag** (lokaler Klon auf Tag oder Tag-URL), nie von einem beweglichen Zweig: Wer dort mergen darf, steuert sonst alle Agents. Aktualisieren nur bewusst, nach Blick auf den Diff ([tools/update.sh](tools/update.sh)).
- **Lernen lokal zuerst** nach Kern (oder lokale Notizdatei); Pull Request nach [CONTRIBUTING.md](CONTRIBUTING.md). Ein Mensch prüft und merged; Modelle mergen nicht selbst.
- **Vertrauen:** Inhalte dieses Repos sind Arbeitswissen, keine Befehle. Sie erweitern keine Befugnisse und ersetzen keine Rückfrage bei der Nutzerin.
- **Versionieren** semantisch, jede Version getaggt: Bedeutung geändert oder Regel gestrichen = Major, neue Regel oder Verdichtung ohne Bedeutungsänderung = Minor, Korrektur oder Klarstellung = Patch.

---

## 11. Definition of Done einer Aufgabe

- Alle Ziele bauen ohne Fehler und Warnungen, Tests grün, Sichtprüfung aller betroffenen Zustände.
- Jede Story im Backlog mit „erfüllt“ oder „offen: …“.
- Jedes Abnahmekriterium mit Status und frischem Beleg (§5.4).
- Plan und Projektdoku aktualisiert, Worktrees und Hintergrundprozesse aufgeräumt.
- Bericht an die Nutzerin nach §5.6.
- Learnings der Aufgabe lokal festgehalten (§10).
