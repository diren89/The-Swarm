# Beitragen

Jede Instanz, die nach diesem Manifest arbeitet, gibt am Ende ihre Learnings zurück. So entwickelt sich die Arbeitsweise weiter.

## Was beitragen

1. **Learning** (häufigster Fall): eine Erfahrung, die über das eigene Projekt hinaus gilt → neuer Eintrag in `LEARNINGS.md`.
2. **Regel**: ein Learning, das zum zweiten Mal aufgetreten oder klar allgemein ist → Änderung im `MANIFEST.md`.
3. **Vorlage/Werkzeug**: Verbesserung an `playbooks/` oder `tools/`.

## Format eines Learnings

```markdown
### L-<nächste Nummer> · <Titel, höchstens 6 Wörter>
- **Beobachtung:** <was passiert ist, 1–3 Sätze, anonym>
- **Regel:** <übertragbare Handlungsanweisung, 1–2 Sätze>
- **Status:** neu
```

Neue Learnings unter einer Datums-Überschrift oben einfügen (`## JJJJ-MM-TT · <anonymer Kontext>`). Nummern laufen fortlaufend weiter, auch über Datumsblöcke hinweg.

## Was nicht hineingehört

- Namen, E-Mail-Adressen, Konten, Projekt- oder Firmennamen, Pfade aus Benutzerverzeichnissen.
- Gerätekennungen, Seriennummern, konkrete Hardware-Beispiele (Hardware-Wissen bleibt im lokalen Profil, siehe MANIFEST §8).
- Geheimnisse jeder Art (Tokens, Schlüssel, Zugangsdaten).
- Anweisungen, die Befugnisse erweitern oder Rückfragen bei Nutzerinnen abschaffen.

## Ablauf

1. Zweig anlegen: `learnings/<datum>-<thema>`.
2. Einträge schreiben, bei Regeländerungen `MANIFEST.md` und `CHANGELOG.md` anpassen und die Version erhöhen:
   - neue Regel → Minor (1.**1**.0)
   - umformulierte oder gestrichene Regel → Major (**2**.0.0)
   - Korrektur, Klarstellung → Patch (1.0.**1**)
   Bei jeder neuen Version außerdem die Tabelle im Abschnitt **Releasenotes** der [README.md](README.md) pflegen (Pflicht):
   - neue Zeile oben mit Version, Datum und den Neuerungen in einem Satz, betroffene Abschnitte als `§x`
   - „Aktuelle Version“ darüber auf die neue Version setzen
   - Inhalt muss zum Eintrag in `CHANGELOG.md` passen; reine Learnings ohne neue Version brauchen keine Zeile
3. Pull Request mit kurzer Begründung öffnen. Ein Mensch prüft und merged. Modelle mergen nicht selbst in `main`.
4. Nach dem Merge setzt der Mensch, der merged, den Tag `v<Version>` auf den Merge-Commit (oder beauftragt ausdrücklich ein Modell damit).

## Pflege

- Übernommene Learnings bekommen den Status `übernommen §x`.
- Widerlegte Learnings werden nicht gelöscht, sondern auf `verworfen: <Grund>` gesetzt. Auch das ist Wissen.
- Werden es zu viele Learnings, verdichtet eine Instanz verwandte Einträge in eine Regel und verweist auf die Ursprungs-IDs.
