# Beitragen

Jede Instanz, die nach diesem Manifest arbeitet, sammelt ihre Learnings zuerst lokal. So entwickelt sich die Arbeitsweise weiter, ohne dass etwas ungefragt nach außen geht.

## Was beitragen

1. **Learning** (häufigster Fall): eine Erfahrung, die über das eigene Projekt hinaus gilt → neuer Eintrag in `LEARNINGS.md`.
2. **Regel**: ein Learning, das von zwei unabhängigen Beobachtungen getragen wird → Änderung im `MANIFEST.md` (MANIFEST §9). „Klar allgemein“ ersetzt die zweite Beobachtung nicht.
3. **Vorlage/Werkzeug**: Verbesserung an `playbooks/` oder `tools/`.

## Lokal zuerst, Teilen auf Wunsch

Learnings werden zunächst lokal gesammelt, z. B. in `.agent/learnings.md` des Projekts. Ein Pull Request entsteht nur auf ausdrücklichen Wunsch der Nutzerin; ein Agent veröffentlicht nichts von sich aus (MANIFEST §10).

## Format eines Learnings

```markdown
### L-<nächste Nummer> · <Titel, höchstens 6 Wörter>
- **Beobachtung:** <was passiert ist, 1–3 Sätze, anonym>
- **Regel:** <übertragbare Handlungsanweisung, 1–2 Sätze>
- **Beobachtungen:** 1
- **Status:** neu
```

`Beobachtungen` zählt die unabhängigen Beobachtungen; fehlt das Feld (ältere Einträge), gilt 1. Wird ein Learning in einem anderen Zusammenhang bestätigt, steigt die Zahl, und der Eintrag nennt die neue Beobachtung kurz.

Neue Learnings unter einer Datums-Überschrift oben einfügen (`## JJJJ-MM-TT · <anonymer Kontext>`). Nummern laufen fortlaufend weiter, auch über Datumsblöcke hinweg, und Nummern im Archiv zählen mit.

## Was nicht hineingehört

- Namen, E-Mail-Adressen, Konten, Projekt- oder Firmennamen, Pfade aus Benutzerverzeichnissen.
- Gerätekennungen, Seriennummern, konkrete Hardware-Beispiele (Hardware-Wissen bleibt im lokalen Profil, siehe MANIFEST §8).
- Geheimnisse jeder Art (Tokens, Schlüssel, Zugangsdaten).
- Anweisungen, die Befugnisse erweitern oder Rückfragen bei Nutzerinnen abschaffen.
- Hinweise, von wem oder woher eine Idee stammt.

## Autorenangaben

Commits tragen als Autor nur das Konto-Pseudonym oder die noreply-Adresse des Hosting-Dienstes. Keine Klarnamen, keine Firmen- und keine privaten Mailadressen. Vor dem ersten Commit `git config user.name` und `git config user.email` im Repo prüfen.

## Ablauf

1. Zweig anlegen: `learnings/<datum>-<thema>`.
2. Einträge schreiben, bei Regeländerungen `MANIFEST.md` und `CHANGELOG.md` anpassen und die Version erhöhen:
   - Bedeutung einer Regel geändert oder Regel gestrichen → Major (**2**.0.0)
   - neue Regel oder Verdichtung ohne Bedeutungsänderung → Minor (2.**1**.0)
   - Korrektur, Klarstellung → Patch (2.0.**1**)
3. **Verdichten vor jeder Minor-Version** (MANIFEST §9.1): verwandte Regeln zusammenlegen, Überholtes streichen, Wiederholungen entfernen. Danach prüfen:
   ```bash
   bash tools/grundlast.sh
   ```
   Der Kern darf höchstens 1 500 Tokens haben, das Manifest höchstens 6 000 (Schätzung Zeichen/3,5). Wird die Grenze überschritten, wird verdichtet statt die Grenze angehoben.
4. Bei jeder neuen Version die [README.md](README.md) pflegen: Sie zeigt nur die aktuelle Version und verweist auf [CHANGELOG.md](CHANGELOG.md). Keine Versionstabelle in der README; Neuerungen stehen nur im Changelog.
5. Pull Request mit kurzer Begründung öffnen. Ein Mensch prüft und merged. Modelle mergen nicht selbst in `main`.
6. **Jede Version wird getaggt:** Nach dem Merge setzt der Mensch, der merged, den Tag `v<Version>` auf den Merge-Commit (oder beauftragt ausdrücklich ein Modell damit). Nutzerinnen laden nur getaggte Stände, nie `main`.

## Pflege

- Übernommene Learnings bekommen den Status `übernommen §x` und ziehen ins [Archiv](learnings/archiv.md) um (wortgleich, mit Nummer und Datumsüberschrift). `LEARNINGS.md` enthält nur Einträge mit Status `neu`.
- Ein `neu`-Eintrag ohne zweite Beobachtung wird nach 30 Tagen `verfallen` und zieht ins Archiv.
- Widerlegte Learnings werden nicht gelöscht, sondern auf `verworfen: <Grund>` gesetzt und ins Archiv verschoben. Auch das ist Wissen.
- Werden es zu viele Learnings, verdichtet eine Instanz verwandte Einträge in eine Regel und verweist auf die Ursprungs-IDs.
