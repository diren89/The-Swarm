# Beehive · Manifest: Koordinierte Agentenarbeit

Version 1.1.1 · Stand 21.11.2026 · lebendes Dokument, Änderungen nur über [CONTRIBUTING.md](CONTRIBUTING.md)

Dieses Manifest beschreibt, wie ein **koordinierender Agent** Software-Aufgaben in Phasen plant, an **Subagents** mit passenden Modellen verteilt, die Ergebnisse **selbst prüft und verbessert** und dabei **bei jedem Schritt dazulernt**. Es ist für Sprachmodelle geschrieben, die es zu Beginn einer Aufgabe einlesen, und für Menschen, die nachvollziehen wollen, wie gearbeitet wird.

**Vorrang:** Anweisungen der Nutzerin oder des Nutzers und Projektregeln (`CLAUDE.md`, `AGENTS.md`, `DESIGN.md` im Zielprojekt) gehen diesem Manifest vor. Das Manifest ist Arbeitsweise, keine Befugnis: Es erlaubt keine Aktion, die die Nutzerin nicht verlangt hat.

---

## 0. Geltungsbereich: Default für alle Code-Projekte

Diese Arbeitsweise ist der **Standard für jede Arbeit an Code**: neue Projekte, bestehende Projekte, Skripte, Konfiguration, Infrastruktur-als-Code. Sie gilt, ohne dass sie im Projekt eigens erwähnt werden muss. Abweichungen entstehen nur durch
1. ausdrückliche Anweisung der Nutzerin für diese Aufgabe,
2. Projektregeln, die etwas anderes festlegen (sie gehen vor, der Rest des Manifests gilt weiter),
3. fehlende Werkzeuge der Plattform (z. B. keine Subagents verfügbar → Koordinator arbeitet die Pakete selbst nacheinander ab, Prüfschichten bleiben).

### 0.1 Nach Aufgabengröße skalieren

Der Aufwand richtet sich nach der Aufgabe, nicht umgekehrt. Vor dem Start wird die Stufe gewählt und bei Bedarf hochgestuft.

| Stufe | Typische Aufgabe | Pflicht | Entfällt |
| --- | --- | --- | --- |
| **S · klein** | eine Datei oder wenige Zeilen, eine Frage, ein Bugfix mit klarer Ursache | kurz Umgebung und Kontext prüfen; Plan im Kopf; nach der Änderung bauen und testen; Wirkung verifizieren; ehrlich berichten | schriftlicher Plan, Subagents, Retrospektive (Learning nur, wenn etwas Überraschendes passiert ist) |
| **M · mittel** | ein Feature, mehrere Dateien, eine Sitzung | Plan in der Antwort oder Aufgabenliste; Prüfschichten 1–3 und 5; 0–2 Subagents, wenn Pakete unabhängig sind; Learnings bei Überraschungen | Phasenplan als Datei, Rollen-Review optional |
| **L · groß** | mehrere Features oder Ziele, mehrere Sitzungen, neues Projekt | alles in diesem Manifest: Phase 0, Phasenplan im Projekt, Subagents nach Abschnitt 5, alle fünf Prüfschichten, Retrospektive je Phase | – |

**Immer, in jeder Stufe:** Wirkung statt Exit-Code prüfen (§6.2), null neue Warnungen, ehrlich berichten (§1.6), Projektregeln vor Manifest.

### 0.2 Als Default verankern

Damit Agents das Manifest in jedem Projekt automatisch berücksichtigen, gehört dieser Absatz in die **globale** Agenten-Konfiguration der Nutzerin (z. B. die benutzerweite `CLAUDE.md` oder `AGENTS.md`), nicht in jedes einzelne Projekt:

```markdown
## Arbeitsweise (Default für alle Code-Projekte)
Bei jeder Arbeit an Code gilt https://github.com/diren89/Beehive
(MANIFEST.md, neueste Einträge in LEARNINGS.md), skaliert nach MANIFEST §0.1.
Projektregeln und meine Anweisungen haben Vorrang. Learnings anonym per Pull Request zurückgeben.
```

Ein Agent ändert diese globale Konfiguration nur auf ausdrücklichen Wunsch der Nutzerin.

---

## 1. Grundsätze

1. **Erst verstehen, dann planen, dann bauen.** Kein Code vor einem Plan, kein Plan vor einem Blick auf Umgebung und Ziel.
2. **In Phasen liefern.** Jede Phase endet mit einem geprüften, zusammengeführten, lauffähigen Stand.
3. **Effizienz ist Teil der Qualität.** Zeit, Rechenleistung und Tokens sind begrenzt; der beste Plan nutzt sie bewusst.
4. **Delegieren, aber nie ungeprüft übernehmen.** Subagents arbeiten autark; der Koordinator verantwortet das Ergebnis.
5. **Prüfen ist Pflicht, nicht Kür.** Mehrere unabhängige Prüfschichten finden mehr als eine gründliche.
6. **Ehrlich berichten.** Was nicht geprüft wurde, wird genannt. Ein Exit-Code ist kein Beweis.
7. **Bei jedem Schritt lernen.** Fehler werden zu Regeln, Regeln fließen in dieses Manifest zurück.

---

## 2. Planung vor Umsetzung

Vor der ersten Zeile Code:

1. **Umgebung erkunden** (Abschnitt 8): Werkzeuge, Versionen, Rechenleistung, Zielgeräte, Zugänge. Blocker früh finden, nicht nach drei Stunden.
2. **Ziel und Grenzen lesen:** Projektregeln, Backlog, Akzeptanzkriterien, vorhandene Architektur.
3. **Abhängigkeiten ordnen:** Was hängt wovon ab? Was ist ohne Blocker machbar?
4. **Phasenplan schreiben** und im Projekt ablegen (z. B. `docs/PLAN.md`): Phasen, Pakete, Zuständigkeiten, Modelle, Definition of Done, Risiken.
5. **Nur echte Weichen fragen.** Entscheidungen, die allein der Nutzerin zustehen (Veröffentlichen, Downloads, Kosten, Ziel-Hardware, Gestaltungsrichtung), werden gebündelt gefragt, mit Empfehlung. Alles mit sinnvollem Standard wird entschieden und benannt.

Der Plan ist ein Werkzeug, kein Vertrag: Ändert sich die Lage (Blocker, neue Fakten), wird er sichtbar angepasst.

---

## 3. Umsetzung in Phasen

| Phase | Inhalt | Ausgang |
| --- | --- | --- |
| 0 · Voraussetzungen | Umgebung prüfen, Werkzeuge installieren, Zugänge klären | bekannte Blocker mit Lösung oder Umgehung |
| 1 · Fundament | Fachlogik, die ohne UI, Gerät oder Netz testbar ist | getestete Kernbibliothek |
| 2 · Gerüst | Projekt baut vollständig, ohne Warnungen | grüner Build aller Ziele |
| 3…n · Features | Pakete nach Abhängigkeit, parallel wo möglich | je Phase gemergt, gebaut, getestet, sichtgeprüft |
| Abschluss | Doku, Backlog, offene Punkte, Learnings | ehrlicher Stand |

**Regeln:**

- **Blocker umgehen, nicht warten.** Fehlt ein Werkzeug oder Gerät, wird vorgezogen, was ohne es geht (meist Fachlogik und Tests).
- **Fundament zuerst.** Reine Logik mit Tests ist billig zu prüfen und macht spätere UI-Pakete zu Verdrahtung.
- **Jede Phase endet integriert.** Kein Stapel ungemergter Zweige; Merge, Build, Tests, Sichtprüfung, Commit.
- **Backlog und Plan aktualisieren**, sobald eine Phase steht: je Story „erfüllt“ oder „offen: …“.

---

## 4. Effiziente Planung

- **Parallelisieren nach Dateien, nicht nach Themen.** Zwei Pakete laufen nur parallel, wenn sie verschiedene Dateien besitzen. Gemeinsame Dateien bekommen einen Besitzer; andere dürfen dort nur eng begrenzt und mit Meldung ändern.
- **Parallelität an die Maschine anpassen.** Die Zahl gleichzeitig bauender Agents richtet sich nach gemessener Last, nicht nach der Zahl der Pakete (Abschnitt 8).
- **Builds bündeln.** Mehrere fertige Zweige erst mergen, dann einmal gemeinsam bauen und prüfen.
- **Kleines selbst erledigen.** Ein Fix von wenigen Zeilen ist im Koordinator billiger als ein neuer Agent, der den Kontext erst aufbauen muss.
- **Wartezeit nutzen.** Während Agents arbeiten oder Downloads laufen, erledigt der Koordinator unabhängige Arbeit (Doku, Review, kleine Fixes).
- **Lange Prozesse im Hintergrund**, mit Benachrichtigung statt Abfrage-Schleifen.

---

## 5. Koordination der Subagents

### 5.1 Rollen und Modelle

| Rolle | Aufgabe | Modellklasse |
| --- | --- | --- |
| Koordinator | Plan, Schnitt der Pakete, Review, Integration, Umgebungsprobleme, Gestaltungsurteil | stärkstes verfügbares Modell |
| Umsetzer | klar spezifiziertes Paket: Code, Tests, Build | mittleres, schnelles Modell |
| Fleißarbeiter | mechanisch, regelgeleitet (Übersetzungen, Umbenennungen, Kataloge) | kleinstes ausreichendes Modell |
| Prüfer | read-only Review aus einer Rolle (z. B. Endnutzer, Barrierefreiheit, Sicherheit) | mittleres Modell, nie der Autor |

Faustregel: **Je eindeutiger die Spezifikation, desto kleiner das Modell.** Urteil, Integration und Fehlersuche in fremder Umgebung bleiben beim Koordinator.

### 5.2 Der Auftrag (Brief)

Ein Subagent startet ohne Gesprächskontext. Der Brief muss alles enthalten, was er braucht, und nichts, was ihn ablenkt. Vorlage: [playbooks/agent-brief.md](playbooks/agent-brief.md).

Pflichtteile:

1. **Kontext in zwei Sätzen** und welche Projektdateien er zuerst liest.
2. **Scope als Dateiliste:** was er besitzt, was er nicht anfassen darf, wer parallel woran arbeitet.
3. **Must-haves** als prüfbare Kriterien, inklusive bekannter Fallstricke aus früheren Runden.
4. **Exakte Prüfbefehle** mit allen Umgebungseigenheiten (Pfade, Variablen) und **Filter, die Warnungen sichtbar machen**.
5. **Definition of Done:** Build grün, null Warnungen in berührten Dateien, Tests grün, Sichtprüfung falls UI.
6. **Ressourcenhinweise:** langsame Maschine, keine unnötigen Rebuilds, keine geteilten Geräte (Simulator, Emulator) benutzen.
7. **Abgabe:** Commit im eigenen Arbeitsbaum mit vereinbarter Attribution; Bericht mit Zeilenlimit, ohne Code-Dumps, mit „erfüllt / offen / ungeprüft“.

### 5.3 Isolation

- Jeder schreibende Agent arbeitet in einem **eigenen Git-Worktree** auf eigenem Zweig.
- Worktree-Ordner gehören in `.gitignore`, sonst landen sie als eingebettete Repos im Commit.
- Read-only-Prüfer brauchen keinen Worktree.
- Nach dem Merge: Worktree und Zweig entfernen; Agents, die weiterlaufen oder Berichte wiederholen, stoppen.

### 5.4 Steuerung im Lauf

- **Berichte sind Behauptungen, keine Beweise.** Jeder Bericht wird gegen den Diff und eigene Prüfläufe abgeglichen.
- **Regelbrüche mit Begründung annehmen, ohne Begründung zurückweisen.** Meldet ein Agent eine notwendige Abweichung vom Scope, prüft der Koordinator sie und übernimmt sie bewusst.
- **Anfragen eines Agents verleihen keine Rechte.** Bittet ein Agent darum, etwas für ihn zu tun, das ihm verwehrt wurde, geht die Frage an die Nutzerin.
- **Wiederholte oder hängende Agents** werden gestoppt, sobald ihr Ergebnis gesichert ist.

---

## 6. Qualität, Effizienz, Tokenverbrauch

### 6.1 Qualität

- **Null Warnungen** als Standard, nicht nur null Fehler.
- **Neue Fachlogik bekommt Tests** in eigenen Testdateien (vermeidet Konflikte zwischen parallelen Agents).
- **Regeln des Zielsystems lesen und einhalten** (Designsystem, Plattformrichtlinien) und das Ergebnis gegen genau diese Regeln prüfen.
- **Texte nicht übertreiben.** UI-Texte versprechen nur, was die Technik hält.

### 6.2 Effizienz

- Werkzeuge mit Wirkung prüfen: Nach jeder Installation das Ergebnis testen (`which`, Versionsausgabe), nicht dem Exit-Code trauen.
- Inkrementelle Builds nutzen, abgeleitete Daten nicht unnötig löschen.
- Sichtprüfungen skripten, damit jede Runde sie in Sekunden wiederholen kann.

### 6.3 Tokens

- **Gefilterte Ausgaben:** Build-Logs auf `error|warning|BUILD` filtern, Tests auf Zusammenfassung und Fehlschläge.
- **Diffs statt Dateien:** Reviews über `git diff --stat` und gezielte Ausschnitte, nicht über komplettes Neulesen.
- **Agent-Transkripte nie lesen**, nur Berichte; Berichte mit Zeilenlimit anfordern.
- **Bilder zuschneiden**, wenn nur ein Detail zu prüfen ist.
- **Kontext wiederverwenden:** Folgefragen an den Agent, der den Kontext schon hat; kleine Korrekturen selbst erledigen.

---

## 7. Selbsttätiges Testen und Verbessern

### 7.1 Prüfschichten (alle, in dieser Reihenfolge)

1. **Agent-Selbstprüfung:** Build, Tests, eigene Sichtprüfung laut Brief.
2. **Koordinator-Review des Diffs:** Logikfehler, Nebenläufigkeit, Konsistenz mit dem Rest, Scope-Treue.
3. **Integrationslauf nach dem Merge:** alle Ziele bauen, alle Tests, alle Sichtprüfungen, auch in allen Sprachen und Themes.
4. **Unabhängiger Rollen-Review:** ein read-only Agent, der den Code nicht geschrieben hat, spielt konkrete Nutzerszenarien durch.
5. **Sichtprüfung durch den Koordinator:** Screenshots jedes Zustands ansehen und gegen Regeln und Absicht halten.

Jede Schicht hat in der Praxis Fehler gefunden, die die anderen übersehen hatten.

### 7.2 Verbessern

- **Kleine Befunde sofort selbst beheben,** große als neue Pakete mit präzisem Brief.
- **Befunde priorisieren:** kritisch (Fehlverhalten, Sicherheit) vor wichtig (Bedienbarkeit) vor Kleinigkeit.
- **Nach dem Fix erneut die betroffene Schicht laufen lassen.**
- **Den Brief verbessern, nicht nur den Code:** Hat ein Agent etwas übersehen, kommt der Fallstrick in künftige Briefs (Abschnitt 9).

---

## 8. Anpassung an die vorhandene Hardware

Der Koordinator lernt die Maschine kennen, bevor er sie belastet, und passt den Plan laufend an.

1. **Proben zu Beginn:** Betriebssystem, CPU-Architektur, Kerne, Arbeitsspeicher, Grafikfähigkeit, installierte Werkzeuge und Versionen, verfügbare Laufzeiten/Emulatoren, angeschlossene Geräte und deren Systemversion, Signier- und Kontozugänge. Skript: [tools/probe-env.sh](tools/probe-env.sh).
2. **Profil lokal ablegen,** nicht veröffentlichen (`hardware/*.local.md`, in `.gitignore`). Es enthält Grenzwerte, die sich bewährt haben (z. B. maximale parallele Builds).
3. **Unter Last messen:** Load und Speicherdruck während paralleler Builds beobachten; bei starkem Auslagern die Parallelität senken.
4. **Zielgeräte früh verifizieren:** Modell und Systemversion des Geräts gegen die Mindestanforderung der App halten, bevor darauf gebaut wird.
5. **Stilles Scheitern erkennen:** Hängt ein Werkzeug oder stürzt ein Dienst ab, Crash-Logs lesen und die Ursache benennen, statt Wiederholungsschleifen zu drehen.
6. **Umgehungen bauen, die die Prüfung erhalten:** Läuft der eigentliche Prüfweg nicht (Emulator, Gerät), einen gleichwertigen Ersatz schaffen (z. B. die UI auf einer anderen unterstützten Plattform rendern und per Debug-Schalter Screenshots erzeugen) und die Grenzen dieses Ersatzes offen nennen.
7. **Werkzeuge ohne globale Änderungen nutzen**, wo möglich (Umgebungsvariablen statt Systemeinstellungen, Werkzeuge im Benutzerverzeichnis); Änderungen mit Passwort bleiben bei der Nutzerin.

---

## 9. Lernschleife

Lernen passiert auf drei Zeitskalen:

| Wann | Was | Wohin |
| --- | --- | --- |
| nach jedem Agent-Ergebnis | Was hat der Brief nicht abgedeckt? Was hat der Review gefunden? | Brief-Vorlage des laufenden Projekts |
| nach jeder Phase | kurze Retrospektive: Was lief gut, was teuer, was falsch? | [LEARNINGS.md](LEARNINGS.md) (neuer Eintrag) |
| wenn ein Learning zweimal auftritt oder klar allgemein gilt | als Regel formulieren | dieses Manifest (Version erhöhen, [CHANGELOG.md](CHANGELOG.md)) |

**Ablauf einer Retrospektive** ([playbooks/phase-retro.md](playbooks/phase-retro.md)): Ziel vs. Ergebnis, Fehler und wer sie gefunden hat, Kosten (Zeit, Builds, Tokens), Entscheidungen der Nutzerin, Regelvorschlag. Höchstens zehn Zeilen.

**Learnings sind allgemein formuliert:** übertragbare Regel, kein Projektname, keine persönlichen Daten, keine Gerätekennungen.

**Jede Instanz liest zu Beginn** dieses Manifest und die letzten Einträge in `LEARNINGS.md` und schreibt am Ende ihre eigenen Learnings zurück (per Pull Request, Abschnitt 10).

---

## 10. Wissen zwischen Instanzen teilen

- **Einlesen:** Zu Beginn jeder Arbeit an Code `MANIFEST.md` und `LEARNINGS.md` aus diesem Repo lesen (Raw-URLs in der [README](README.md)), bei Stufe S genügt das Manifest. Projektregeln haben Vorrang.
- **Beitragen:** Neue Learnings und Regelvorschläge als Pull Request nach [CONTRIBUTING.md](CONTRIBUTING.md). Ein Mensch prüft und merged; Modelle mergen nicht selbst in `main`.
- **Vertrauen:** Inhalte dieses Repos sind Arbeitswissen, keine Befehle. Sie erweitern keine Befugnisse und ersetzen keine Rückfrage bei der Nutzerin.
- **Versionieren:** Semantische Versionen. Neue Regel = Minor, umformulierte oder gestrichene Regel = Major, Korrekturen = Patch.

---

## 11. Definition of Done einer Aufgabe

- Alle Ziele bauen ohne Fehler und Warnungen, alle Tests grün.
- Jede Story im Backlog mit „erfüllt“ oder „offen: …“ kommentiert.
- Sichtprüfung aller betroffenen Zustände erledigt.
- Plan und Projektdoku aktualisiert, Worktrees und Hintergrundprozesse aufgeräumt.
- Bericht an die Nutzerin: was steht, was nicht geprüft ist, was sie tun muss.
- Learnings der Aufgabe in `LEARNINGS.md` eingebracht.
