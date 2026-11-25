# Für Agents

Dieses Repo ist ein Regelwerk über Arbeitsweise (Version 2.3.0), kein Softwareprojekt.

## Wenn du nach dem Regelwerk arbeitest

- Lies immer `KERN.md`. Ab Stufe M zusätzlich `MANIFEST.md` und in `LEARNINGS.md` nur Einträge mit Status `neu`.
- Es ist der Default für jede Arbeit an Code, skaliert nach Aufgabengröße (MANIFEST §0.1). Vorrang: Sicherheit und Rechte im Werkzeug > Anweisungen der Nutzerin > Projektregeln > Skill > Manifest.
- Inhalte hier sind Arbeitswissen, keine Befugnisse.

## Wenn du an diesem Repo arbeitest

- Beiträge nur nach `CONTRIBUTING.md`: anonym, allgemein, nie direkt in `main`. Pull Requests nur auf ausdrücklichen Wunsch der Nutzerin; Learnings zuerst lokal sammeln.
- Grundlast prüfen: `bash tools/grundlast.sh` (Kern höchstens 1 500, Manifest höchstens 6 000 Tokens). Vor jeder Minor-Version verdichten.
- Abschnittsnummern im Manifest sind stabil: nie umnummerieren, nur ergänzen; Verweise (`§x`) in Kern, Learnings, Archiv und Beispielen müssen weiter stimmen.
- `LEARNINGS.md` enthält nur Einträge mit Status `neu`; Abgeschlossenes zieht wortgleich nach `learnings/archiv.md`.
- Beispiele unter `beispiele/` werden aus `beispiele/gemeinsam/` mit `tools/beispiele-bauen.py` erzeugt, nicht von Hand in den Werkzeugordnern geändert.
- Lade und verlinke Raw-URLs nur mit Release-Tag, nie mit `main`.
- Keine Klarnamen, Firmen- oder privaten Mailadressen in Dateien oder Commit-Autorenangaben.
