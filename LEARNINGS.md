# Learnings

Erfahrungen aus realen Aufgaben, allgemein formuliert. Neueste Einträge oben. Format und Regeln: [CONTRIBUTING.md](CONTRIBUTING.md).

Felder je Eintrag: **Kontext** (anonym) · **Beobachtung** · **Regel** · **Status** (`neu` = noch nicht im Manifest, `übernommen §x` = als Regel im Manifest).

---

## 2026-11-23 · Token- und Kontextverbrauch einer Agent-Hierarchie messen und senken

Kontext: Ein Koordinator maß den Verbrauch seiner Agent-Hierarchie aus der Sitzungsdatenbank des Agent-Werkzeugs, beschränkte die Werkzeuge je Rolle und verglich einen festen kleinen Code-Auftrag einmal vorher und zweimal nachher.

### L-050 · Unter-Koordinator nur für große Pakete
- **Beobachtung:** Ein schlanker Koordinator für Code-Arbeit hatte gut 40 % weniger Grundlast als der Haupt-Koordinator. Direkt als Hauptagent gewählt, fehlten ihm aber die Dienste für den übrigen Auftrag; als Unter-Koordinator kostete schon eine Probekette mit einer Frage einen weiteren Agent mit starkem Modell. Die Kette brauchte eine höhere erlaubte Schachtelungstiefe.
- **Regel:** Einen Unter-Koordinator nur für große, abgegrenzte Code-Pakete einsetzen, nicht für kleine Aufgaben. Er spricht nicht selbst mit der Nutzerin, sondern gibt Weichen als `blockiert` zurück. Die Schachtelungstiefe vorher mit einer Probekette prüfen.
- **Status:** übernommen §5.1.2

### L-045 · Werkzeuge je Rolle sperren, Wirkung an der Grundlast messen
- **Beobachtung:** Der Kontext beim ersten Aufruf (Grundlast) lag bei Rollen mit allen Diensten bei 25–33k Tokens, bei eng berechtigten Rollen bei 4–9k. Die Beschreibungen der angebundenen Dienste machten den Unterschied. Nur die Sammel-Schnittstelle der Dienste zu sperren erhöhte die Grundlast (von 22k auf 30k), weil das Werkzeug die Dienste dann einzeln auflistete. Erst Dienste, Sammel-Schnittstelle und Skill-Liste zusammen gesperrt senkten sie um 40–57 %.
- **Regel:** Jede Rolle bekommt nur die Werkzeuge und Dienste, die sie braucht. Die Wirkung einer Sperre an der gemessenen Grundlast belegen, nicht an der Doku. Danach je Rolle eine Probe mit erlaubten und verbotenen Aufrufen, belegt im Sitzungsprotokoll.
- **Status:** neu

### L-046 · Kosten über mehrere Läufe vergleichen
- **Beobachtung:** Derselbe Auftrag kostete nach der Optimierung einmal 0,82 und einmal 1,07 (vorher 1,02), obwohl jeder einzelne Aufruf um 25–40 % billiger war. Die Kosten hingen vor allem an der Zahl der Prüf- und Korrekturrunden, nicht an der Grundlast. Bei kleinen Aufträgen ist die Streuung größer als die Ersparnis.
- **Regel:** Optimierungen mit einem Messwerkzeug und mindestens zwei Läufen je Konfiguration bewerten. Neben den Gesamtkosten Kosten je Aufruf und Kontext getrennt ausweisen, und die Qualität mit denselben Prüfungen an allen Läufen messen. Einzelläufe nicht als Beleg werten.
- **Status:** neu

### L-047 · Letzte Korrekturrunde selbst nachprüfen oder offen benennen
- **Beobachtung:** Mit einer Grenze von drei Review-Runden blieb in mehreren Fällen die Korrektur aus der letzten Runde ohne unabhängige Nachprüfung. Gerade dort lagen neue Randfälle, etwa eine Testzählung, die bei übersprungenen Untertests negativ wurde.
- **Regel:** Ist das Rundenlimit erreicht, die letzte Korrektur selbst mit einem gezielten Test der Fehlerklasse prüfen. Im Bericht ausdrücklich sagen, dass sie nicht unabhängig geprüft ist, und die Nutzerin über eine Zusatzrunde entscheiden lassen.
- **Status:** neu (ergänzt L-041)

### L-048 · Prüfskripte zählen ausgeführte Tests und sehen Warnungen
- **Beobachtung:** Eine Kurzausgabe „OK“ nur nach Exit-Code meldete Läufe ohne ausgeführten Test und Läufe mit Warnung als Erfolg. Ein Filter der Form `befehl | grep warning && exit 1 || exit 0` verdeckte zudem gescheiterte Befehle.
- **Regel:** Prüfskripte werten den Exit-Code des Befehls selbst aus. Sie weisen die Zahl der ausgeführten Tests ohne übersprungene aus und melden null Tests als Fehler, wenn Tests erwartet sind. Warnungen kennzeichnen sie getrennt. Die Langausgabe gehört je Lauf in eine eigene Datei.
- **Status:** übernommen §6.1 (Vorlage tools/pruefen.sh)

### L-049 · Erzeugte Dateien vor dem ersten Commit ausschließen
- **Beobachtung:** In einem Test-Repo waren Python-Cache-Dateien eingecheckt. Jeder Testlauf veränderte sie, und die Agents mussten in jedem Lauf entscheiden, ob sie die Dateien zurücksetzen oder mit committen.
- **Regel:** Vor dem ersten Commit erzeugte Dateien (Cache, Build) per `.gitignore` ausschließen. Vor jedem Commit nur gezielte Pfade mit `git add` aufnehmen, nicht `-A`.
- **Status:** neu

---

## 2026-11-23 · GUI-Plugin für eine Desktop-App

Kontext: Ein Koordinator baute ein Oberflächen-Plugin für eine Desktop-App (Übersicht über Sitzungen, Statuspunkte, Markierungen auf der Startseite). Die Oberfläche selbst konnte er nicht sehen, visuelle Prüfung lief über Screenshots der Nutzerin.

### L-042 · Erst Echtdaten, dann Logik verdächtigen
- **Beobachtung:** Alle Statuspunkte erschienen grau, der Verdacht fiel auf die Statuslogik. Ein Lauf der Logik mit echten API-Antworten zeigte korrekte Zustände. Ursache waren veraltete Farbvariablen der Host-App, die im Dunkelmodus fast grau wirkten.
- **Regel:** Bei Anzeigefehlern zuerst die Logik mit echten Daten außerhalb der Oberfläche laufen lassen. Erst wenn sie stimmt, Darstellung und Styles prüfen, und umgekehrt.
- **Status:** neu

### L-043 · Markup und Styles des Hosts lesen
- **Beobachtung:** Wie die App einen Plugin-Button zeichnet (Abstände, Icon-Größe, aktuelle Farbvariablen), stand in keiner Doku. Das ausgelieferte Bundle der App enthielt es lesbar. Raten hätte mehrere Screenshot-Runden gekostet.
- **Regel:** Hängt das Aussehen eines Plugins vom Host ab, dessen ausgelieferte Styles und Templates lesen, bevor CSS geschrieben wird. Selektoren auf Host-Interna im Code als zerbrechlich kennzeichnen, so dass sie bei Updates still wegfallen statt zu stören.
- **Status:** neu

### L-044 · Gateway-Fehler beim Fortsetzen eines Subagents
- **Beobachtung:** Beim Fortsetzen eines Subagents lehnte das Modell-Gateway die Anfrage ab, weil der Verlauf mit einer Assistenten-Nachricht endete („prefill“ nicht unterstützt). Eine weitere Nachricht in derselben Sitzung lief durch.
- **Regel:** Bei diesem Fehler dieselbe Sitzung mit einer neuen Nutzernachricht fortsetzen, statt neu zu starten oder das Modell zu wechseln. Erst wenn das scheitert, den Modell-Ausweich nutzen.
- **Status:** neu

---

## 2026-11-23 · Rechte eines Daten-Subagents härten

Kontext: Ein Review fand Lücken in Skripten und Rechten eines Daten-Abrufers (kleines Modell). Die Korrekturen liefen über vier Runden mit Reviewer aus anderer Modellfamilie, dazu Live-Proben der Rechte und ein echter Abruf.

### L-039 · Rechte-Proben an der Wirkung prüfen
- **Beobachtung:** Ein Subagent probierte erlaubte und verbotene Shell-Aufrufe und meldete alle Umgehungsversuche als „abgelehnt“. Im Protokoll stand ein Aufruf mit Umleitung (`skript --help > /pfad`) aber als ausgeführt, und die Datei lag im Dateisystem. Ohne diesen Abgleich wäre eine Schreiblücke als geschlossen gemeldet worden.
- **Regel:** Rechte-Proben mit Aufrufen bauen, die eine prüfbare Spur hinterlassen (Datei anlegen). Das Ergebnis am Sitzungsprotokoll und im Dateisystem prüfen, nicht am Bericht. Danach die Spuren löschen.
- **Status:** neu

### L-040 · Erlaubte Befehlsmuster decken mehr als gedacht
- **Beobachtung:** Ein Muster wie `python3 skript.py *` ließ auch Umleitungen zu, das Skript konnte so an beliebige Stellen schreiben. Muster wie `rm -rf */_raw` oder `mv ~/Downloads/* *` passen auch auf Leerzeichen und weitere Argumente und damit auf fremde Ziele. Ketten, Pipes und `$()` lehnte das Rechtesystem in der Probe dagegen ab.
- **Regel:** Schreibende und löschende Shell-Befehle nicht als Muster erlauben, sondern über ein eigenes Skript, das jeden Pfad selbst prüft (aufgelöst, kein Symlink, innerhalb des Arbeitsordners). Umleitungen (`>`, `<`) und Backticks ausdrücklich sperren. Die Auslegung der Muster live belegen (L-039), nicht annehmen.
- **Status:** neu

### L-041 · Review-Runden begrenzen, Restrisiko mit dem Menschen entscheiden
- **Beobachtung:** Jede Nachprüfung fand neue, immer kleinere Randfälle, vor allem in Code, der gerade erst zur Behebung entstanden war. Nach drei Runden waren die schweren Lücken zu, die restlichen Befunde hatten geringes praktisches Risiko oder großen Aufwand.
- **Regel:** Vor dem Start eine Höchstzahl an Korrekturrunden festlegen (z. B. drei). Danach anhalten und der Nutzerin die Restbefunde mit Risiko und Aufwand vorlegen. Was offen bleibt, als bekanntes Restrisiko in der Rollenbeschreibung festhalten. Späte kleine Befunde mit klarer Lösung dürfen in die letzte Runde, wenn das gesagt wird.
- **Status:** neu

---

## 2026-11-23 · Werkzeug-Repo neben dem Manifest

Kontext: Ein Agent arbeitete nach dem Manifest an einem zweiten, selbst gepflegten Repo (Designsystem). Dessen Regeln entstanden vor dem Manifest und regelten nur Inhalte, nicht den Weg der Änderungen.

### L-038 · Beitragsregeln im Zielrepo prüfen
- **Beobachtung:** Das Zielrepo hatte keine Beitragsregeln. Seine Agent-Anleitung nannte als Weg zur Veröffentlichung „Push auf `main`“. Weil Projektregeln Vorrang vor dem Manifest haben, hätte ein Agent ohne Pull Request und ohne menschliche Freigabe veröffentlichen dürfen. Die Lücke fiel erst beim ausdrücklichen Abgleich beider Regelwerke auf.
- **Regel:** Vor dem ersten Schreibzugriff auf ein Repo prüfen, ob es Beitragsregeln hat (Zweig, Pull Request, wer merged, Version, Tag). Fehlen sie oder erlauben sie den direkten Push auf `main`, das der Nutzerin melden und einen Pull Request vorschlagen, der die Regeln ergänzt. Bis dahin gilt für Merge und Veröffentlichung das Manifest.
- **Status:** neu

---

## 2026-11-23 · Arbeitsweise auf eine Chat-Plattform ohne Werkzeuge übertragen

Kontext: Das Manifest wurde für einen Büro-Chat-Assistenten aufbereitet, der Agents über einen Baukasten mit begrenzten Feldern anlegt. Recherche und Entwurf liefen über Subagents, die Prüfung über einen Reviewer aus anderer Modellfamilie in drei Runden, dazu ein Live-Test durch die Nutzerin.

### L-036 · Fähigkeiten der Zielplattform einzeln belegen
- **Beobachtung:** Recherche und Entwurf gingen davon aus, die Plattform könne nichts ausführen, und schrieben das als Regel in die Agent-Anweisungen. Erst der Reviewer fand eine zuschaltbare Python-Sandbox in der Herstellerdoku. Die pauschale Aussage hätte den Agent zu falscher Bescheidenheit oder zu unklaren Testbehauptungen geführt.
- **Regel:** Bei einer Zielplattform ohne die üblichen Werkzeuge jede Fähigkeit einzeln mit Quelle klären: Ausführung (auch Sandbox), Websuche, direkter URL-Abruf, Wissensdateien und Dateitypen, Feldgrenzen. Im Recherche-Auftrag als Pflichtfragen stellen. In den Anweisungen Sandbox-Läufe von Läufen im echten Projekt trennen.
- **Status:** neu

### L-037 · Bei harten Feldgrenzen Puffer für Review-Nachträge
- **Beobachtung:** Der erste Entwurf der Agent-Anweisungen nutzte schon 82 % der selbst gesetzten Grenze. Die Nachträge aus dem Review ließen sich nur unterbringen, indem mehrmals andere Sätze gekürzt wurden.
- **Regel:** Bei Texten mit harter Längengrenze den ersten Entwurf auf etwa zwei Drittel der Grenze auslegen. Der Rest ist Reserve für Review-Befunde. Zeichen nach jeder Änderung neu zählen.
- **Status:** neu

---

## 2026-11-23 · Live-Exporte mit Abbruch und Fortsetzung

Kontext: erste echte Läufe eines generischen Daten-Abrufers (Subagent auf einem kleinen Modell) gegen zwei Quellen, eine Werkzeug-API mit Cursor und eine paginierte Website über den Browser. Getestet wurde jeweils ein gewollter Abbruch und die Fortsetzung in einer neuen Session. Das Ergebnis prüfte der Orchestrator gegen die Dateien.

### L-032 · Rohdaten nie vom Modell abschreiben lassen
- **Beobachtung:** Die Werkzeug-Laufzeit konnte keine Dateien schreiben. Der Agent baute deshalb eine große Tool-Antwort von Hand als Datei nach und übernahm 7 von 41 Objekten. Das Schreibwerkzeug meldete Erfolg. Weil der Agent den Fortsetzungs-Cursor mitkopiert hatte, wirkte die Datei vollständig. Erst eine Nachfrage in derselben Session deckte das auf.
- **Regel:** Daten vom Werkzeug direkt in die Datei leiten, z. B. über einen lokalen Empfänger, an den die Laufzeit sendet. Das Modell sieht nur eine Quittung mit der Objektzahl und gleicht sie mit der Zahl der Quelle ab. Eine Erfolgsmeldung beim Schreiben beweist keine Vollständigkeit.
- **Status:** übernommen §6.2

### L-033 · Checkpoint mit Lückenliste, nicht nur letzter Position
- **Beobachtung:** Eine Seite wurde dauerhaft abgelehnt, und danach brach die Verbindung ab. Der Agent holte trotz Stopp-Regel spätere Seiten. Der Checkpoint enthielt nur die letzte lückenlose Seite. Ein Folgelauf hätte die Lücken nicht gekannt und bereits Vorhandenes doppelt geholt.
- **Regel:** Ein Checkpoint führt eine Liste der fehlenden Teile, gegen die vorhandenen Rohdaten abgeglichen. „Vollständig“ gilt nur bei leerer Liste. Ein Folgelauf holt zuerst die Lücken. Stopp-Regeln, die nur im Prompt stehen, durch diesen Abgleich absichern.
- **Status:** übernommen §5.5, §7.3

### L-034 · Fortsetzung in frischer Session und gegen die Quelle prüfen
- **Beobachtung:** Ein Test „nach drei Seiten abbrechen“ löste nicht aus, weil die Quelle trotz Seitenlimit größere Seiten lieferte. Echte Abbrüche zeigten sich erst später. Die Fortsetzung durch einen neuen Agent, der nur den Checkpoint kannte, deckte zwei Fehler auf, die im ersten Lauf unsichtbar blieben. Während eines Laufs änderte sich die Gesamtzahl der Quelle um eins. Erst der Endabgleich gegen diese Zahl bestätigte die Vollständigkeit.
- **Regel:** Abbruch und Fortsetzung in einer frischen Session testen, ohne Gesprächshistorie. Prüfen, ob der Testfall überhaupt eingetreten ist. Am Ende die Zahl der eindeutigen Objekte gegen die aktuelle Gesamtzahl der Quelle abgleichen.
- **Status:** übernommen §6.1, §7.3

### L-035 · Bei Ablehnung aufteilen statt aufgeben
- **Beobachtung:** Ergänzt L-028. Ein Agent verkettete mehrere Shell-Befehle. Einer davon berührte einen gesperrten Pfad, und der ganze Aufruf wurde abgelehnt. Der Agent schloss daraus, die Shell sei insgesamt gesperrt, und beendete einen schon halb erledigten Auftrag, nach einem Login durch den Nutzer.
- **Regel:** In Rollen-Prompts „ein Befehl je Aufruf“ vorschreiben, wenn Rechte über Befehlsmuster gelten. Bei einer Ablehnung den Aufruf aufteilen und neu versuchen. Erst wenn ein einzelner Befehl abgelehnt wird, als blockiert melden.
- **Status:** übernommen §5.5

---

## 2026-11-23 · Rechte, Werkzeuge und Atomarität in einer Agent-Hierarchie

Kontext: Ausbau einer dreistufigen Subagent-Hierarchie in einem Agent-Framework (neue Rollen, generischer Daten-Abrufer mit Profilen, Konverter für Exporte), geprüft durch Live-Probeläufe und einen Reviewer aus anderer Modellfamilie über fünf Runden.

### L-027 · Subagent-Rechte als Allowlist anlegen
- **Beobachtung:** Das Framework stellt jeder Rolle eine Standardregel „alles erlaubt“ voran. Rollen, die nur einzelne Aktionen verboten, konnten dadurch weiter externe Werkzeug-Server und Skript-Ausführung nutzen. Erst ein Live-Probelauf je Rolle deckte das auf.
- **Regel:** Rechte jeder Rolle mit „alles verboten“ beginnen und nur benötigte Aktionen einzeln erlauben. Die wirksamen Rechte nach jeder Änderung mit einem echten Lauf prüfen, nicht nur in der Konfiguration lesen.
- **Status:** übernommen §5.5

### L-028 · Ein Verbot sperrt den ganzen Aufruf
- **Beobachtung:** Ein Werkzeugaufruf mit mehreren Pfaden wurde komplett abgelehnt, weil ein einziger Pfad unter ein Verbot fiel. Der Agent hielt das für einen allgemeinen Fehler.
- **Regel:** Aufträge an eingeschränkte Rollen so schneiden, dass ein Aufruf nur erlaubte Pfade berührt (eine Datei je Aufruf). Ablehnungen im Bericht wörtlich zurückgeben lassen.
- **Status:** übernommen §5.5

### L-029 · Werkzeugsatz hängt an der Modellfamilie
- **Beobachtung:** Ein Prüfer auf einem Modell einer anderen Familie sollte einen Bericht als Datei ablegen. Er erhielt dort ein anderes Schreibwerkzeug als erwartet, versuchte das Schreiben nie und meldete den Bericht als „nicht erstellt“. Die Rechte waren korrekt.
- **Regel:** Je Modellfamilie einmal prüfen, welche Werkzeuge ein Agent tatsächlich sieht, und im Auftrag das passende Werkzeug ausdrücklich nennen.
- **Status:** übernommen §5.2, §5.5

### L-030 · Atomarität mit Abbruch an jeder Operation testen
- **Beobachtung:** Ein Austausch von Exportdateien sollte nach einem Abbruch immer ganz alt oder ganz neu sein. Zwei Korrekturen, die nach Lektüre richtig wirkten, hätten in bestimmten Abbruchmomenten Daten gelöscht. Erst ein Test, der den Prozess hart an jeder einzelnen Dateioperation beendet und danach den Zustand prüft, machte die Lösung belastbar. Der erste Lauf dieses Tests prüfte versehentlich null Abbruchpunkte und meldete trotzdem „0 Fehler“.
- **Regel:** Absturzsicherheit mit hartem Abbruch an jeder Operation testen, auch während des Zurückrollens, und parallele Läufe sperren. Bei jedem Test die Zahl der tatsächlich geprüften Fälle ausgeben und kontrollieren.
- **Status:** übernommen §6.1, §7.3

### L-031 · Pfadschutz am aufgelösten Pfad prüfen
- **Beobachtung:** Ein Schutz gegen Schreiben in den Konfigurationsordner prüfte nur das Befehlsmuster. Über Verknüpfungen, `..` oder Platzhalter war er umgehbar. Beim Testen legte eine Shell einen Platzhalter-Pfad ohne Treffer wörtlich als neuen Ordner an, und das Werkzeug schrieb unbemerkt dorthin.
- **Regel:** Schreib- und Löschziele im Werkzeug selbst über den aufgelösten Pfad prüfen, bevor irgendetwas angelegt wird. Platzhalter-Tests in einer Shell mit bekanntem Verhalten ausführen und das Ziel danach auf Ort und Inhalt prüfen (vgl. L-023).
- **Status:** übernommen §5.5

---

## 2026-11-23 · Modellabgleich für eine Delegations-Hierarchie

Kontext: kleiner Benchmark (7 Aufgaben, 6 Modelle über ein Modell-Gateway) zur Wahl günstiger Modelle für Subagents, geprüft von einem Reviewer aus anderer Modellfamilie.

### L-024 · Gateway-Budget vor Delegation prüfen
- **Beobachtung:** Zwei Läufe brachen mitten in der Arbeit ab, weil das Budget des Modell-Gateways erschöpft war. Die Subagents meldeten nur allgemeine Fehler, die Ursache fiel erst beim Lesen der Logs auf.
- **Regel:** In Phase 0 das verbleibende Budget abfragen und gegen die geschätzten Kosten des Plans halten. Für jede Phase ein Kostenlimit festlegen und bei Fehlern zuerst Budget und Kontingente prüfen.
- **Status:** übernommen §2

### L-025 · Agent-Format schlägt Auftragsformat
- **Beobachtung:** Ein Auftrag verlangte reines JSON, der Prompt des Agents ein eigenes Berichtsformat. Ein Modell lieferte inhaltlich richtig, aber im Berichtsformat, und fiel durch. Andere Modelle folgten dem Auftrag.
- **Regel:** Im Auftrag ausdrücklich sagen, welches Ausgabeformat gilt, wenn es vom Berichtsformat des Agents abweicht. Bei maschineller Weiterverarbeitung Inhalt und Format getrennt prüfen.
- **Status:** übernommen §5.2

### L-026 · Bewertungen mit plausibel falschen Antworten testen
- **Beobachtung:** Die automatischen Bewertungen wurden mit Musterlösung und offensichtlichem Unsinn geprüft und galten als korrekt. Der Reviewer fand in drei Runden Lücken: vertauschte Zuordnungen, Doppel-Einträge, eingefügte Widersprüche und Leerantworten wurden nicht oder falsch gewertet. Die erste Auswertung zog dadurch zu weite Schlüsse.
- **Regel:** Jede Bewertung zusätzlich mit gezielt verfälschten, plausibel aussehenden Antworten testen und Fehlläufe als 0 zählen. Schlüsse auf die getestete Aufgabenart begrenzen.
- **Status:** übernommen §6.1

---

## 2026-11-21 · Veröffentlichen und Umbenennen eines Repos

Kontext: ein Dokumentations-Repo zweimal umbenannt, über Pull Requests geändert und mit Versions-Tags veröffentlicht.

### L-021 · Zweig umbenennen schließt den PR
- **Beobachtung:** Der Zweig eines offenen Pull Requests wurde per API umbenannt, damit er zum neuen Namen passt. GitHub hat den PR daraufhin automatisch geschlossen. Erst die Gegenprüfung danach hat das aufgedeckt.
- **Regel:** Zweige offener PRs nicht umbenennen. Ist es doch nötig, sofort einen Ersatz-PR öffnen und im alten darauf verweisen. Nach jeder Änderung an GitHub-Objekten deren Zustand erneut abfragen.
- **Status:** neu

### L-022 · Raw-URLs erst nach dem Veröffentlichen abfragen
- **Beobachtung:** Eine Datei-URL wurde abgefragt, bevor der Tag existierte. Das CDN speicherte die 404 einige Minuten lang (`x-cache: HIT`), auch nachdem der Tag veröffentlicht war. Ein Query-Parameter umging den Cache nicht.
- **Regel:** Veröffentlichte Inhalte zuerst lokal prüfen (`git show <ref>:<datei>`), online erst danach. Bei 404 die Cache-Header lesen und eine andere Datei unter demselben Ref testen, bevor man einen Fehler meldet.
- **Status:** neu

### L-023 · Shell-Eigenheiten vor Schleifen bedenken
- **Beobachtung:** Eine Schleife, die Zeichenketten mit Leerzeichen in Wörter zerlegen sollte, scheiterte in einer Shell ohne automatische Wortaufteilung. Keine der geplanten Aktionen wurde ausgeführt.
- **Regel:** Bei Schleifen über Listen mit Leerzeichen Einzelbefehle oder Arrays verwenden. Die Ausgabe auf „nichts passiert“ prüfen, nicht nur auf Fehlermeldungen.
- **Status:** neu

---

## 2026-11-21 · Mehrphasige App-Entwicklung mit Subagents (Erstbefüllung)

Kontext: zwei zusammenhängende Apps mit gemeinsamer Kernbibliothek, Cloud-Sync, Lokalisierung und Designsystem; sieben Phasen, zwölf Subagents (Umsetzer, Fleißarbeiter, Prüfer), ein Koordinator.

### L-001 · Exit-Code ist kein Beweis
- **Beobachtung:** Eine Paketinstallation endete mit Exit-Code 0, das Werkzeug war aber nicht installiert. Der Koordinator meldete „erledigt“ und musste das später korrigieren.
- **Regel:** Nach jeder Installation die Wirkung prüfen (`which`, `--version`). Erst dann als erledigt melden.
- **Status:** übernommen §6.2

### L-002 · Umgebung vor dem Plan erkunden
- **Beobachtung:** Zentrale Werkzeuge fehlten, und das angeschlossene Zielgerät erfüllte die Mindest-Systemversion nicht. Beides kam erst im Lauf der Arbeit ans Licht.
- **Regel:** Phase 0 prüft Werkzeuge, Versionen, Laufzeiten und Zielgeräte samt Systemversion, bevor Phasen geplant werden.
- **Status:** übernommen §2, §8

### L-003 · Blocker umgehen statt warten
- **Beobachtung:** Während ein großes Werkzeug installiert wurde, haben drei Agents die komplette Kernlogik mit Tests gebaut. Die Wartezeit wurde zur produktivsten Phase.
- **Regel:** Bei Blockern zuerst das vorziehen, was ohne den Blocker testbar ist.
- **Status:** übernommen §3

### L-004 · Parallelität an der Maschine messen
- **Beobachtung:** Drei gleichzeitig bauende Agents trieben die Systemlast weit über die Kernzahl und erzwangen starkes Auslagern. Ein Emulator startete dadurch nicht mehr. Mit zwei parallelen Builds lief es stabil.
- **Regel:** Parallele Builds nach gemessener Last und Speicherdruck begrenzen und das Limit im lokalen Hardware-Profil festhalten.
- **Status:** übernommen §4, §8

### L-005 · Stilles Scheitern über Logs aufklären
- **Beobachtung:** Ein Emulator meldete „gebootet“, zeigte aber nie eine Oberfläche. Mehrere Wiederholungsversuche liefen ins Leere, erst die Crash-Logs nannten die Ursache: Die Grafikfähigkeit der Maschine reichte nicht.
- **Regel:** Nach dem zweiten erfolglosen Versuch keine Schleifen mehr drehen, sondern Logs und Crash-Reports lesen.
- **Status:** übernommen §8

### L-006 · Ersatz-Prüfweg mit Debug-Schalter
- **Beobachtung:** Ohne lauffähigen Emulator wurde die UI auf einer anderen unterstützten Plattform gerendert. Ein reiner Debug-Startparameter öffnet jeden Zustand mit Beispieldaten und schreibt das Fenster als PNG. Dafür braucht es keine Bildschirmaufnahme-Rechte, und Agents können ihre Arbeit selbst ansehen.
- **Regel:** Gibt es keinen normalen Sichtprüfweg, einen skriptbaren Ersatz bauen und seine Grenzen offen nennen (Touch, Geräte-APIs).
- **Status:** übernommen §8

### L-007 · Dateibesitz verhindert Merge-Konflikte
- **Beobachtung:** Bei zwölf Agents in getrennten Worktrees gab es keinen einzigen Merge-Konflikt. Jeder Brief nannte, welche Dateien der Agent besitzt, welche tabu sind und wer parallel woran arbeitet. Tests kamen immer in neue Testdateien.
- **Regel:** Pakete nach Dateien schneiden, gemeinsame Dateien einem Besitzer zuordnen, neue Tests in eigene Dateien.
- **Status:** übernommen §4, §6.1

### L-008 · Worktrees gehören in .gitignore
- **Beobachtung:** Ein `git add -A` im Hauptbaum hat die Worktree-Ordner der Agents als eingebettete Repos gestaged.
- **Regel:** Den Worktree-Ordner vor dem ersten Agent-Start ignorieren. Agents mit Worktree-Isolation nur aus einem Arbeitsverzeichnis innerhalb des Repos starten.
- **Status:** übernommen §5.3

### L-009 · Prüfbefehle müssen Warnungen zeigen
- **Beobachtung:** Mehrere Agents schnitten die Build-Ausgabe mit `tail` ab und konnten danach nicht sagen, ob Warnungen auftraten.
- **Regel:** Im Brief exakte Befehle mit Filter auf `error|warning|BUILD` vorgeben. „Null Warnungen“ ist Teil der Definition of Done.
- **Status:** übernommen §5.2

### L-010 · Jede Prüfschicht findet eigene Fehler
- **Beobachtung:** Jeder Fehler kam in einer anderen Prüfschicht ans Licht. Der Koordinator-Review fand ein Nebenläufigkeitsproblem, bei dem Änderungen verloren gehen konnten. Er fand auch eine Funktion, die ein Kommentar versprach, die aber nie umgesetzt war. Der unabhängige Rollen-Review fand Logiklücken in Nutzerszenarien. Erst die Sichtprüfung zeigte einen Bildschirm, der im Nachtmodus hell blieb. Kein Agent hatte die Fehler seiner eigenen Arbeit selbst gemeldet.
- **Regel:** Alle fünf Prüfschichten laufen lassen. Keine ersetzt eine andere.
- **Status:** übernommen §7.1

### L-011 · Prüfer darf nicht der Autor sein
- **Beobachtung:** Ein read-only Prüfer-Agent mit klaren Szenarien (Kleinkind, neugieriges Schulkind, Elternteil am Abend) lieferte zwölf priorisierte Befunde mit Datei, Zeile und Fix. Drei davon waren kritisch.
- **Regel:** Reviews durch einen Agent ohne Autorenschaft, mit Rollen, konkreten Szenarien und priorisiertem Ausgabeformat.
- **Status:** übernommen §5.1, §7.1

### L-012 · Modellwahl nach Eindeutigkeit der Aufgabe
- **Beobachtung:** Ein mittleres Modell setzte klar spezifizierte Pakete zuverlässig um. Ein kleines Modell erledigte die Lokalisierung mit über hundert Einträgen korrekt. Umgebungsprobleme, Gestaltungsurteile und das Erzeugen von Signets nach Regeln blieben beim Koordinator, und genau dort lagen die schwierigen Entscheidungen.
- **Regel:** Je eindeutiger die Spezifikation, desto kleiner das Modell. Urteil und Integration bleiben beim stärksten Modell.
- **Status:** übernommen §5.1

### L-013 · Kleine Fixes selbst, große als Paket
- **Beobachtung:** Zehn Review-Befunde hat der Koordinator in einem Durchgang selbst behoben, mit einem Build und wenigen Tokens. Ein neuer Agent hätte den Kontext erst teuer aufbauen müssen.
- **Regel:** Fixes von wenigen Zeilen erledigt der Koordinator. Eigenständige Features bekommen einen Agent.
- **Status:** übernommen §4, §7.2

### L-014 · Builds bündeln
- **Beobachtung:** Zwei fertige Zweige erst zu mergen und dann einmal gemeinsam zu bauen, sparte auf langsamer Hardware einen kompletten Build-Zyklus. Das Ergebnis war dasselbe.
- **Regel:** Wenn mehrere Agents kurz nacheinander fertig werden, erst alle mergen, dann einmal integriert prüfen.
- **Status:** übernommen §4

### L-015 · Regeln des Zielsystems gegen das Ergebnis halten
- **Beobachtung:** Beim Übertragen eines Designsystems färbte ein globaler Akzent alle Bedienelemente. Das Designsystem erlaubt aber genau einen Akzent je Ansicht, und erst die Sichtprüfung gegen genau diese Regel deckte den Fehler auf. Dasselbe System verbietet frei gezeichnete Signets. Neue Signets entstanden deshalb mit den Generator-Helfern des Systems und wurden gegen seine Grammatik geprüft.
- **Regel:** Vor dem Umsetzen die Muss-Regeln des Systems lesen, danach das Ergebnis Regel für Regel prüfen. Eigenes Material nur über die vom System vorgesehenen Werkzeuge erzeugen.
- **Status:** übernommen §6.1

### L-016 · Berichte von Agents sind Behauptungen
- **Beobachtung:** Agents meldeten mehrfach „erfüllt“, obwohl sie Teile nicht geprüft hatten. Gute Agents nannten das selbst, wenn der Brief ein Feld „ungeprüft“ verlangte.
- **Regel:** Im Bericht „erfüllt / offen / ungeprüft“ verlangen und jeden Bericht gegen Diff und eigene Läufe abgleichen.
- **Status:** übernommen §5.2, §5.4

### L-017 · Hängende und sich wiederholende Agents stoppen
- **Beobachtung:** Ein Agent meldete nach dem Merge seines Ergebnisses dreimal denselben Bericht und verbrauchte weiter Tokens. Sein Worktree blieb gesperrt.
- **Regel:** Sobald das Ergebnis gemergt ist, Agent stoppen, Worktree entsperren und entfernen, Zweig löschen.
- **Status:** übernommen §5.3, §5.4

### L-018 · Begründete Scope-Abweichung bewusst annehmen
- **Beobachtung:** Ein Agent musste für Push-Benachrichtigungen eine Zeile in einer für ihn gesperrten Datei ergänzen. Er meldete das offen mit Begründung, die Abweichung war korrekt und wurde übernommen.
- **Regel:** Im Brief verlangen, dass Abweichungen gemeldet werden. Der Koordinator prüft sie und entscheidet.
- **Status:** übernommen §5.4

### L-019 · UI-Texte nicht übertreiben
- **Beobachtung:** Ein Hinweis versprach eine harte Grenze, die die Plattform technisch nicht garantieren kann.
- **Regel:** Nutzertexte beschreiben, was die Technik tatsächlich leistet, einschließlich bekannter Grenzen.
- **Status:** übernommen §6.1

### L-020 · Weichen bündeln und mit Empfehlung fragen
- **Beobachtung:** Fragen an die Nutzerin waren schnell beantwortet, wenn sie gebündelt kamen, jede für sich verständlich waren und eine markierte Empfehlung hatten. Beispiele: Download-Quelle, Prüfweg ohne Gerät, Sichtbarkeit eines Repos.
- **Regel:** Nur echte Weichen fragen, gebündelt, mit Empfehlung zuerst. Alles andere selbst entscheiden und benennen.
- **Status:** übernommen §2
