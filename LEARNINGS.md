# Learnings

Erfahrungen aus realen Aufgaben, allgemein formuliert. Neueste Einträge oben. Format und Regeln: [CONTRIBUTING.md](CONTRIBUTING.md).

Felder je Eintrag: **Kontext** (anonym) · **Beobachtung** · **Regel** · **Status** (`neu` = noch nicht im Manifest, `übernommen §x` = als Regel im Manifest).

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
