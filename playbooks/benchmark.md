# Benchmark: Wirkt The Swarm?

Vorlage zur Wirksamkeitsmessung. Sie vergleicht dieselben Aufgaben mit und ohne The Swarm bei Kosten, Dauer, Qualität und Nacharbeit.

**Stand: Noch keine Ergebnisse.** Dieses Playbook beschreibt nur das Verfahren. Es wurde bisher nicht durchgeführt; nichts in diesem Dokument ist ein Messwert. Ergebnisse dürfen erst eingetragen werden, wenn die Läufe tatsächlich stattgefunden haben.

## Aufbau

- **Übungsrepo:** ein frei wählbares, öffentliches Repo mit Tests und Build, klein genug für eine Sitzung (etwa 1 000 bis 10 000 Zeilen), in einer Sprache, die das Modell gut beherrscht.
  - Repo: `<REPO-URL>`
  - Commit (fester Ausgangsstand für alle Läufe): `<COMMIT-HASH>`
  - Vor dem ersten Lauf prüfen: Build und Tests laufen auf dem Ausgangsstand grün (Ausnahme: der Test der Bugfix-Aufgabe, siehe unten).
- **Bedingungen:**
  - **A · ohne The Swarm:** keine Swarm-Anweisung geladen, sonst identische Konfiguration.
  - **B · mit The Swarm:** Kern immer, Manifest ab Stufe M, Learnings nur `neu`, festgepinnter Tag `v<VERSION>`.
- **Gleiche Startbedingungen:** dasselbe Modell und dieselbe Einstellung (Denktiefe, Rechte, Werkzeuge) in beiden Bedingungen, derselbe Commit, sauberer Arbeitsbaum, frische Sitzung ohne Vorwissen, kein Zugriff auf frühere Läufe. Modell und Version des Werkzeugs vorab notieren.
- **Reihenfolge:** je Aufgabe mindestens drei Läufe pro Bedingung, abwechselnd (A, B, A, B, A, B), damit Tageszeit und Last nicht eine Bedingung begünstigen. Vor jedem Lauf den Arbeitsbaum auf den Ausgangsstand zurücksetzen (neuer Klon oder frischer Worktree).
- **Auftragstext:** je Aufgabe wörtlich und identisch in beiden Bedingungen; keine zusätzlichen Hinweise auf The Swarm oder Stufen.
- **Rückfragen:** Der Agent darf fragen. Antwortet wird knapp und nach dem Auftragstext; jede Antwort zählt als Nacharbeit.

## Aufgabentypen

Die vier Typen sind fest. Pro Typ wird einmal vor den Läufen eine konkrete Aufgabe im gewählten Repo festgelegt und samt Abnahmekriterien **vorab** hier eingetragen. Nach dem ersten Lauf werden Aufgabe und Kriterien nicht mehr geändert.

### 1 · Bugfix mit Test

Aufgabe: `<BESCHREIBUNG: ein reproduzierbarer Fehler im Repo, mit Schritten und erwartetem gegenüber tatsächlichem Verhalten>`.
Auftragstext: „Behebe den beschriebenen Fehler. Schreibe zuerst einen Test, der den Fehler zeigt, und behebe ihn dann.“

Abnahmekriterien (vorab fixiert):
1. Ein neuer Test schlägt auf dem Ausgangsstand fehl und besteht mit dem Fix.
2. Alle bisherigen Tests bestehen weiter; Build ohne neue Warnungen.
3. Das Fehlverhalten ist mit den genannten Schritten nicht mehr reproduzierbar.
4. Die Änderung bleibt auf die betroffenen Dateien begrenzt (`<DATEIEN>`), keine fachfremden Änderungen.

### 2 · Kleines Feature über mehrere Dateien

Aufgabe: `<BESCHREIBUNG: eine neue Option oder ein neues Verhalten, das mindestens drei Dateien berührt, z. B. Konfiguration, Logik und Ausgabe>`.
Auftragstext: „Baue <FEATURE> ein, so wie beschrieben. Tests gehören dazu.“

Abnahmekriterien (vorab fixiert):
1. Das Verhalten entspricht der Beschreibung in allen aufgeführten Fällen (`<FÄLLE>`, mindestens drei, davon ein Randfall).
2. Neue Tests decken Standard- und Randfall ab und bestehen.
3. Bestehende Tests bestehen; Build ohne neue Warnungen.
4. Die Dokumentation (README oder Hilfetext) nennt das neue Verhalten.

### 3 · Refactoring

Aufgabe: `<BESCHREIBUNG: ein klar benannter Umbau ohne Verhaltensänderung, z. B. eine doppelte Logik in ein Modul zusammenführen oder eine zu große Funktion zerlegen>`.
Auftragstext: „Baue <UMBAU> um. Das Verhalten darf sich nicht ändern.“

Abnahmekriterien (vorab fixiert):
1. Alle bisherigen Tests bestehen unverändert (kein Test gelöscht, abgeschwächt oder angepasst, um Fehler zu verdecken).
2. Das Zielbild ist erreicht (`<MESSBARES ZIELBILD>`, z. B. keine Duplikate mehr, Funktion höchstens `<N>` Zeilen).
3. Öffentliche Schnittstellen sind unverändert.
4. Build ohne neue Warnungen.

### 4 · Doku-Aufgabe

Aufgabe: `<BESCHREIBUNG: ein Dokumentationsteil, der aus dem Code erstellt oder korrigiert wird, z. B. Installations- und Nutzungsanleitung oder Beschreibung einer Konfigurationsdatei>`.
Auftragstext: „Schreibe/Korrigiere <DOKUMENT> passend zum aktuellen Code.“

Abnahmekriterien (vorab fixiert):
1. Jede Aussage zu Befehlen, Optionen und Pfaden stimmt mit dem Code überein (Stichprobe von mindestens `<N>` Aussagen, per Ausführung belegt).
2. Die genannten Pflichtthemen sind vorhanden (`<THEMENLISTE>`).
3. Beispiele laufen so, wie sie dastehen.
4. Keine Änderungen an Code oder Tests.

## Messgrößen

Je Lauf erfassen:

| Größe | Erfassung |
| --- | --- |
| Kosten | Tokens ein und aus, aus der Abrechnung oder Statistik des Werkzeugs, inklusive aller Subagents; Messquelle notieren |
| Dauer | Minuten von Auftrag bis zur Meldung „fertig“, ohne Wartezeit auf Antworten der Person |
| Abnahmekriterien | erfüllt n von m, geprüft von einer Person oder einem Skript nach den vorab fixierten Kriterien, ohne zu wissen, welche Bedingung vorlag (blind, wenn möglich) |
| Nacharbeit | Zahl menschlicher Korrekturen und Rückfragen: jede Korrekturanweisung, jede Antwort auf eine Rückfrage, jeder Eingriff von Hand in die Dateien |

Zusätzlich notieren: Abbrüche und Fehlstarts (zählen als Lauf, nicht weglassen), Besonderheiten im Lauf.

## Auswertung

- Je Aufgabentyp und Bedingung: **Median** und **Streuung** (min–max, bei fünf oder mehr Läufen Interquartilsabstand) für Kosten, Dauer, Abnahmekriterien und Nacharbeit.
- Verglichen werden Medianwerte; Mittelwerte nur zusätzlich. Bei weniger als fünf Läufen keine Prozentzahlen als Beleg nennen, sondern die Spannen zeigen.
- Überlappen sich die Spannen von A und B, ist das Ergebnis „kein erkennbarer Unterschied“, nicht „B ist besser“.
- Kosten und Qualität gemeinsam lesen: Weniger Tokens bei weniger erfüllten Kriterien ist kein Gewinn.
- Grenzen nennen: ein Modell, ein Repo, wenige Läufe; Ergebnisse gelten nur für diese Umgebung.

### Tabelle-Vorlage (leer)

Eine Tabelle je Aufgabentyp. Zellen bleiben leer, bis Läufe stattgefunden haben.

| Größe | A · ohne The Swarm (Median, min–max) | B · mit The Swarm (Median, min–max) |
| --- | --- | --- |
| Läufe (Zahl) | | |
| Tokens ein | | |
| Tokens aus | | |
| Dauer (Minuten) | | |
| Abnahmekriterien erfüllt (n/m) | | |
| Nacharbeit (Zahl) | | |

Rohdaten je Lauf (eine Zeile je Lauf):

| Lauf | Aufgabe | Bedingung | Tokens ein | Tokens aus | Dauer (Min) | Kriterien n/m | Nacharbeit | Besonderheit |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| | | | | | | | | |

## Ergebnis zurückgeben

Das Ergebnis wird ein Learning in [LEARNINGS.md](../LEARNINGS.md), anonym und allgemein (keine Repo-, Firmen- oder Personennamen), mit **Beobachtungen** = Zahl der ausgewerteten Läufe:

```markdown
### L-<nächste Nummer> · <Titel, höchstens 6 Wörter>
- **Beobachtung:** <Aufgabentyp, Zahl der Läufe je Bedingung, Medianwerte und Spannen, Grenzen der Messung>
- **Regel:** <was daraus für die Arbeitsweise folgt, nur wenn es die Daten tragen>
- **Beobachtungen:** <Zahl der Läufe>
- **Status:** neu
```

Veröffentlicht wird das Learning wie jedes andere nur auf ausdrücklichen Wunsch der Nutzerin (CONTRIBUTING, Abschnitt „Lokal zuerst“).
