# Learnings

Erfahrungen aus realen Aufgaben, allgemein formuliert. Neueste Einträge oben. Hier stehen nur Einträge mit Status `neu`; Übernommenes, Verfallenes und Verworfenes liegt im [Archiv](learnings/archiv.md). Format und Regeln: [CONTRIBUTING.md](CONTRIBUTING.md).

Felder je Eintrag: **Kontext** (anonym) · **Beobachtung** · **Regel** · **Beobachtungen** (Anzahl unabhängiger Beobachtungen; fehlt die Angabe, gilt 1) · **Status**:
- `neu`: noch nicht im Manifest; bleibt hier.
- `übernommen §x`: als Regel im Manifest, wandert ins Archiv.
- `verfallen`: 30 Tage ohne zweite Beobachtung, wandert ins Archiv.
- `verworfen: <Grund>`: widerlegt, wandert ins Archiv.

Eine Regel entsteht erst bei zwei unabhängigen Beobachtungen (MANIFEST §9).

---

## 2026-11-26 · Skill-Praxis und Regelwerk-Release

Kontext: Externe Agent-Skills wurden nach Playbook und Pflege-Rolle in ein bestehendes Setup aufgenommen, aktualisiert und gegen Änderung geschützt; dazu kamen Erfahrungen aus der Pflege eines Regelwerks mit Prüfskripten und Pull Requests.

### L-072 · Kein git stash bei Parallel-Agents
- **Beobachtung:** Ein Umsetzer nutzte `git stash`/`pop` im Arbeitsbaum, in dem parallel andere Agents schrieben; deren Änderungen verschwanden kurz.
- **Regel:** Im geteilten Arbeitsbaum stash, checkout und restore im Brief verbieten und, wo möglich, in den Rechten sperren.
- **Beobachtungen:** 1
- **Status:** neu

### L-071 · Kein Platzhalter im Skriptpfad einer Shell-Freigabe
- **Beobachtung:** Eine Allowlist erlaubte `bash */name.sh*`, während derselbe Agent in Ordner schreiben durfte; er hätte ein gleichnamiges Skript ablegen und ausführen können (vgl. L-040).
- **Regel:** Shell-Freigaben für Skripte nur mit festem Pfad außerhalb der beschreibbaren Bereiche; maschinell prüfen.
- **Beobachtungen:** 1
- **Status:** neu

### L-070 · Verweis-Verdichtung prüft alle Verteilungswege
- **Beobachtung:** Eine Verdichtung ersetzte Manifest-Details durch Verweise auf eine Beitragsdatei; ein unterstützter Verteilungsweg lädt nur Manifest und Learnings, dort fehlte der Inhalt danach.
- **Regel:** Vor dem Ersetzen durch einen Verweis prüfen, ob jeder Verteilungsweg das Verweisziel mitliefert; sonst Inhalt behalten.
- **Beobachtungen:** 1
- **Status:** neu

### L-069 · Fail-closed-Gates verschlucken Fehler in Pipelines
- **Beobachtung:** Ein als fail-closed beschriebenes Shell-Gate ließ Commits durch, weil Fehler von Abfragen in Prozesssubstitution, Pipelines oder einem „kein Repo → durchlassen“-Zweig nicht vom Normalfall unterschieden wurden; erst ein unabhängiger Review mit simulierten Ausfällen fand es, in mehreren Runden.
- **Regel:** Bei fail-closed jede Abfrage einzeln auf ihren Exitcode prüfen, erwartete Sonderfälle (z. B. kein Repo) eng von echten Fehlern trennen und Ausfälle per Wrapper simuliert testen.
- **Auslöser:** Prüfskripte oder Hooks, die blockieren sollen, wenn sie nicht prüfen können.
- **Beobachtungen:** 1
- **Status:** neu

### L-068 · Plattform-Merge setzt den Profilnamen als Autor
- **Beobachtung:** Nach bereinigter Historie trug der Merge-Commit eines Pull Requests wieder den Anzeigenamen des Kontos, weil die Plattform den Merge im Namen des Profils erstellt.
- **Regel:** Autorenregeln gelten auch für Plattform-Merges: Profilnamen vorher anpassen oder lokal mergen und pushen.
- **Beobachtungen:** 1
- **Status:** neu

### L-067 · Verdichten verliert leise Teilbedingungen
- **Beobachtung:** Beim Kürzen eines Regelwerks unter eine feste Obergrenze und beim Verschlanken eines lokalen Ergänzungs-Skills auf Verweise ging eine Reihe von Regeln verloren oder wurde still abgeschwächt (Zusätze wie „gleichwertig“ oder „und Fehlschläge“ entfielen; einige Regeln standen im Verweisziel gar nicht). Erst ein Review Regel für Regel, alt gegen neu, fand sie. Zwei unabhängige Vorgänge an verschiedenen Tagen: Verdichtung des Regelwerks (12 abgeschwächte Regeln) und Verschlanken eines lokalen Skills (12 fehlende Regeln).
- **Regel:** Nach jeder Verdichtung ein Review, das jede Regel alt gegen neu vergleicht und bei Verweisen prüft, ob das Ziel sie wirklich enthält; gestrichene oder zusammengelegte Regeln mit Begründung auflisten.
- **Auslöser:** Kürzen unter eine Größengrenze, Ersetzen von Text durch Verweise.
- **Beobachtungen:** 2
- **Status:** neu

### L-066 · Verwaiste Lock-Datei im Arbeitsordner
- **Beobachtung:** Ein Statusskript liest die Projekt-Lock-Datei im aktuellen Ordner. Eine alte Datei im Benutzerordner erzeugte deshalb viele falsche Hash-Abweichungen. Der globale Lock der CLI hat ein anderes Format (Version 3, eigener Hash), das das Skript nicht prüfen kann.
- **Regel:** Statusskripte nur im Projektordner starten oder die Lock-Datei ausdrücklich angeben; verwaiste Locks im Benutzerordner entfernen. Lock-Format und -Version vor dem Hash-Vergleich prüfen.
- **Beobachtungen:** 1
- **Status:** neu

### L-065 · Installer fremder Pakete: pinnen, Hooks auslassen
- **Beobachtung:** Der offizielle Installer eines Skill-Pakets mit Plugin-Abhängigkeit lud ungepinnt von einem beweglichen Zweig (`curl | bash`); das Plugin brachte Hooks mit (Auto-Update bei jedem Shell-Aufruf, Sitzungsstart) und bot einen „schnellen Weg“ an, der Werkzeuge per `npx` aus Releases nachlädt. Sicher ging es mit Klon auf festem Commit, Symlink an den Kandidatenpfad, gepinnter Paketmanager-Version, `--frozen-lockfile` ohne Install-Skripte, ohne Plugin-Hooks, belegt durch eine Funktionsprobe im Wegwerfprojekt.
- **Regel:** Fremde Installer lesen statt ausführen; auf festen Commit pinnen, Abhängigkeiten ohne Install-Skripte aus der Lock-Datei installieren, Hooks und Auto-Update nicht einrichten, Nachladewege (`npx`, Releases) meiden und die Wirkung an einem Wegwerfprojekt belegen.
- **Auslöser:** Aufnahme von Skills, die ein Plugin außerhalb des Skill-Ordners brauchen.
- **Beobachtungen:** 1
- **Status:** neu

### L-064 · Upstream-Umbau statt Update
- **Beobachtung:** Ein Update-Check meldete nur „1 Update“. Tatsächlich hatte die Quelle fast alle Skills gelöscht und den verbleibenden durch einen völlig neuen ersetzt (sehr viele Dateien, Laufzeit Node und Browser, eigener Stop-Hook im Frontmatter).
- **Regel:** Vor jedem Skill-Update Struktur, Dateizahl und Frontmatter (Hooks, Laufzeit, Abhängigkeiten) alt gegen neu vergleichen, nicht nur die Update-Meldung lesen; ein Umbau gilt als Neuaufnahme.
- **Beobachtungen:** 1
- **Status:** neu

---

## 2026-11-24 · Grundlast, Lieferkette und Lernschleife des Regelwerks

Kontext: Ein externer Blick auf das Regelwerk selbst prüfte nicht mehr einzelne Regeln gegeneinander, sondern Ladegröße, Bezugsweg der Anweisungen, Versionslogik und den Weg, auf dem Learnings zurückfließen.

### L-063 · Lernschleife veröffentlicht nichts automatisch
- **Beobachtung:** Die Lernschleife sah als Standard vor, am Ende jeder Aufgabe Learnings per Pull Request zurückzugeben. Dabei hätte ein Agent ohne ausdrückliche Freigabe Inhalte aus Projektarbeit nach außen geschickt.
- **Regel:** Learnings lokal sammeln. Teilen ist eine Freigabe der Nutzerin und kein Schritt, den ein Agent von sich aus am Aufgabenende ausführt.
- **Beobachtungen:** 1
- **Status:** neu

### L-062 · Externer Blick findet Systemfehler
- **Beobachtung:** Drei interne Reviews prüften Regeln gegen Regeln und fanden Widersprüche im Text. Ladegröße und Bezugsweg der Anweisungen hat keines geprüft; das zeigte erst ein externer Blick.
- **Regel:** Ein Regelwerk regelmäßig auch von außen prüfen lassen, mit der Frage nach Last, Lieferkette und Wirkung, nicht nur nach Konsistenz der Regeln untereinander.
- **Beobachtungen:** 1
- **Status:** neu

### L-061 · Verdichten braucht eigenen Schritt
- **Beobachtung:** Eine Versionslogik, die nur Hinzufügen als Minor und Umformulieren als Major kennt, belohnt Anhäufen: Verdichten war teurer versioniert als Ergänzen, also wuchs das Regelwerk mit jeder Version.
- **Regel:** Verdichtung als festen Schritt vor jeder Minor-Version einplanen und nicht teurer versionieren als eine neue Regel, solange sich die Bedeutung nicht ändert.
- **Beobachtungen:** 1
- **Status:** neu

### L-060 · Anweisungen nie von beweglichem Zweig laden
- **Beobachtung:** Anweisungsdateien wurden live vom Hauptzweig geladen, auch beim lokalen Klon per `git pull`. Wer dort mergen darf, steuert damit alle Agents, die davon lesen, ohne dass jemand die Änderung vor dem Laden sieht.
- **Regel:** Anweisungen von einem festen Tag laden und Updates bewusst auslösen: neuen Tag holen, Diff ansehen, erst nach Bestätigung wechseln.
- **Beobachtungen:** 1
- **Status:** neu

### L-059 · Grundlast des Regelwerks selbst messen
- **Beobachtung:** Ein Regelwerk, das Tokensparen lehrt, belegte vor der ersten Zeile Arbeit rund 18 000 Tokens des Kontexts in jeder Sitzung, weil Manifest und Learnings vollständig geladen wurden.
- **Regel:** Die eigene Ladegröße begrenzen und prüfen (Kern immer, Handbuch erst ab Stufe M, nur offene Learnings) und die Grenze in der Pflege des Regelwerks festschreiben.
- **Beobachtungen:** 1
- **Status:** neu

---

## 2026-11-24 · Projektordner mit laufenden Sitzungen verschieben

Kontext: Mehrere Projektordner sollten in einen anderen Sammelordner wandern, ohne dass gespeicherte Agent-Sitzungen, Plugins oder Verweise in der Agent-Konfiguration brechen.

### L-057 · Verschieben mit Symlink am alten Ort
- **Beobachtung:** Das Agent-Werkzeug speichert zu jeder Sitzung das Arbeitsverzeichnis als absoluten Pfad, ebenso Logs, Notizen und Konfigurationsverweise. Ein bloßes Verschieben hätte diese Pfade gebrochen. Verschieben und am alten Ort einen Symlink auf den neuen Ort anlegen hielt alles lauffähig, ohne die Sitzungsdatenbank anzufassen.
- **Regel:** Vor dem Verschieben die Sitzungsablage und die Konfiguration nach dem alten Pfad durchsuchen und prüfen, dass kein Prozess im Ordner arbeitet. Dann verschieben, am alten Ort einen Symlink setzen und interne Datenbanken des Werkzeugs nicht von Hand umschreiben.
- **Status:** neu

### L-058 · Ladepfade direkt auf das Ziel
- **Beobachtung:** Ein Plugin-Pfad in der Konfiguration hätte über den Symlink weiter funktioniert, wäre aber still kaputtgegangen, sobald jemand den vermeintlich überflüssigen Symlink entfernt.
- **Regel:** Pfade, aus denen Code geladen wird (Plugins, Skripte, Skills), nach einem Umzug direkt auf den neuen Ort setzen und das Laden prüfen. Der Symlink dient nur Altbeständen wie Sitzungen, Logs und Notizen.
- **Status:** neu

---

## 2026-11-24 · Regeln für Abnahme, Abbruch und Zustand

Kontext: Ein Koordinator prüfte seine Arbeitsweise gegen wiederkehrende Schwachstellen aus früheren Aufgaben: Korrekturschleifen ohne Fortschritt, Review-Runden für unsichere Befunde, Abnahmen mit veralteten Belegen, verlorener Stand nach Kontextkürzung.

### L-055 · Vage Aufträge zuerst schärfen
- **Beobachtung:** Fehlen einem Auftrag prüfbare Kriterien, lässt sich weder sinnvoll delegieren noch abnehmen; Unklarheiten zeigen sich erst nach teurer Umsetzung.
- **Regel:** Bei fehlenden Kriterien eine kurze, gebündelte Rückfragerunde (höchstens fünf Fragen, je mit Vorschlag) und das Ergebnis als Anforderungsliste mit prüfbaren Kriterien in den Plan. Bei klaren Aufträgen entfällt der Schritt.
- **Status:** neu

### L-056 · Projektwissen bleibt im Projekt
- **Beobachtung:** Fakten, die nur in einem Projekt gelten, blähen gemeinsame Learnings auf und gehen zwischen Sitzungen verloren, wenn sie nur im Gespräch stehen.
- **Regel:** Projektspezifisches in eine Projektnotiz schreiben, die jede Sitzung zu Beginn liest. Ein Learning wird daraus nur, wenn es nicht trivial ist, sich nicht schnell nachschlagen lässt und durch echte Arbeit gewonnen wurde.
- **Status:** neu

---

## 2026-11-23 · Token- und Kontextverbrauch einer Agent-Hierarchie messen und senken

Kontext: Ein Koordinator maß den Verbrauch seiner Agent-Hierarchie aus der Sitzungsdatenbank des Agent-Werkzeugs, beschränkte die Werkzeuge je Rolle und verglich einen festen kleinen Code-Auftrag einmal vorher und zweimal nachher.

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
- **Beobachtung:** Ein Muster wie `python3 skript.py *` ließ auch Umleitungen zu, das Skript konnte so an beliebige Stellen schreiben. Muster wie `rm -rf */_raw` oder `mv <Quelle>/* *` passen auch auf Leerzeichen und weitere Argumente und damit auf fremde Ziele. Ketten, Pipes und `$()` lehnte das Rechtesystem in der Probe dagegen ab.
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
- **Beobachtungen:** 2 (zweite Beobachtung: mehrere Skill-Namen in einer zsh-Variable gingen als ein Argument an eine CLI, Ergebnis „keine passenden Skills“; Listen als Array oder ausgeschrieben übergeben und das Ergebnis per Liste oder Status prüfen, nicht am Exitcode)
- **Status:** neu
