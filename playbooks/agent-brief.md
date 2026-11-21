# Vorlage: Auftrag an einen Subagent

Kopieren, Platzhalter `<…>` füllen, Unpassendes streichen. Ziel: Der Agent kann ohne Rückfrage und ohne Gesprächskontext arbeiten.

~~~text
Repo "<Name>": <ein Satz, was das Projekt ist>, <Plattform/Sprache/Version>.
Lies zuerst `<Projektregeln, z. B. CLAUDE.md>` (verbindlich), `<Backlog-Stories>` und `<relevante Dateien>`.

Scope: **<Story-IDs und Titel>**.
Du besitzt: <Dateien/Ordner>. Neue Dateien bevorzugt in <Ordner>.
Nicht anfassen: <Dateien>. Parallel arbeitet ein anderer Agent an <Thema/Dateien>.
Ist eine Änderung außerhalb deines Scopes unvermeidbar: minimal halten und im Bericht mit Begründung nennen.

Must-haves:
- <prüfbares Kriterium 1>
- <prüfbares Kriterium 2>
- Bekannte Fallstricke: <aus LEARNINGS / früheren Runden, z. B. "X stürzt ohne Berechtigung Y ab – im Ersatz-Prüfweg Z verwenden">
- Neue Fachlogik → <Kernbibliothek> mit Tests in einer NEUEN Testdatei.

Prüfen (exakt so, Umgebung beachten):
```
<Umgebungsvariablen / Pfade>
<Build-Befehl> 2>&1 | grep -E "error:|warning:|BUILD"
<Test-Befehl> 2>&1 | grep -E "warning:|error:|Test run"
<Sichtprüfungs-Skript>   # PNGs mit dem Bild-Lesewerkzeug ansehen
```
Done = alle Builds grün, null Warnungen in berührten Dateien, Tests grün, Sichtprüfung angesehen.
Ressourcen: <Maschinenhinweis, z. B. "langsam, ein anderer Agent baut parallel – keine unnötigen Rebuilds">. Geteilte Geräte (Emulator, Simulator) nicht benutzen. Keine Drittanbieter-Pakete ohne Freigabe.

Abgabe: Commit im eigenen Worktree, Nachricht endet mit `<Attributionszeile>`.
Bericht ≤ <N> Zeilen: Änderungen je Datei, Kriterien erfüllt/offen, UNGEPRÜFT, Abweichungen vom Scope. Keine Code-Dumps.
~~~

## Checkliste vor dem Absenden

- [ ] Kann der Agent mit diesem Text allein anfangen?
- [ ] Sind alle Dateien, die parallel bearbeitet werden, ausgeschlossen?
- [ ] Zeigen die Prüfbefehle Warnungen?
- [ ] Ist das passende Modell gewählt (Abschnitt 5.1 im Manifest)?
- [ ] Startet der Agent aus einem Arbeitsverzeichnis im Repo (für Worktree-Isolation)?
- [ ] Sind die Fallstricke aus den letzten Runden enthalten?

## Vorlage: Prüfer (read-only)

```text
Read-only-Review. Keine Dateien ändern, nichts bauen. Repo: <Pfad>.
Rolle: <z. B. UX-Researcherin für Kinderprodukte / Sicherheitsprüfer>. Du hast den Code nicht geschrieben.
Szenarien: 1. <konkrete Person + Ziel> 2. <…> 3. <…>
Prüfe gegen: <Regeln aus Projektdatei>. Scope: <Ordner>.
Nur echte Fehler, keine Stilfragen.
Antwort: Ergebnis (bestanden / nicht bestanden), höchstens <N> Befunde nach Schwere (kritisch, wichtig, Kleinigkeit),
je eine Zeile `Datei:Zeile – Befund – konkreter Fix`. Kein Lob, kein Code.
```
