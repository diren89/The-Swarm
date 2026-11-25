# Unbeaufsichtigte Schleifen und autonome Läufe

Zweck: Ein Lauf ohne laufende Aufsicht braucht Grenzen, bevor er startet. Laden, wenn ein Agent wiederholt, über Nacht oder ohne Rückfragen arbeiten soll. Grundlage: Kern „Befunde und Abbruch“ und [MANIFEST §5.5](../MANIFEST.md).

## Vorab festlegen (vor dem Start, schriftlich im Auftrag)

- [ ] **Fortschrittsmarken:** was als Fortschritt zählt, messbar (z. B. Zahl grüner Tests, erfüllte Kriterien, abgearbeitete Einträge). „Es läuft noch“ ist kein Fortschritt.
- [ ] **Budget:** Tokens, Zeit und Kosten mit Obergrenze, je mit **Messquelle** (Anzeige oder Statistik des Werkzeugs, Uhr). Eine Grenze ohne Messquelle ist keine.
- [ ] **Rückweg:** eigener Worktree oder Zweig, Sicherung des Ausgangsstands, Beschreibung, wie zurückgerollt wird (z. B. Zweig verwerfen). Nichts im Hauptzweig, kein Push.
- [ ] **Isolation:** riskante Läufe (fremder Code, unbeaufsichtigte Schleifen) isoliert oder gar nicht (MANIFEST §5.5): ohne Zugänge zu Geheimnissen, mit eng gefassten Rechten.

## Stoppbedingungen

Der Lauf hält an, sobald eine davon eintritt:

- [ ] zwei Marken hintereinander ohne Fortschritt,
- [ ] dieselbe Fehlersignatur (Meldung, Test, Stelle) wiederholt sich,
- [ ] eine Budgetgrenze ist erreicht.

Beim Stopp: **Pause, Stand sichern, Bericht** (was erreicht, was nicht, Fehlersignatur, Verbrauch, Vorschlag für den nächsten Schritt). Nicht weiterlaufen und nicht „noch einen Versuch“.

## Grenze

Eine Textregel stoppt keine Schleife. Die echte Grenze setzen Werkzeug (Limits, Zeitlimit, gesperrte Rechte) oder Aufsicht (Nutzerin sieht Marken und Verbrauch und kann abbrechen). Steht keine solche Grenze zur Verfügung, den Lauf nicht unbeaufsichtigt starten und das der Nutzerin sagen.
