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
Bericht ≤ <N> Zeilen: Änderungen je Datei, je Kriterium erfüllt (frischer Beleg) / teilweise / fehlt / UNGEPRÜFT (mit Grund), Abweichungen vom Scope. Keine Code-Dumps.
Prüfart: je Kriterium nennen, welche Prüfung gefordert war und welche tatsächlich lief (z. B. gefordert: Browser-Test, gelaufen: nur Code gelesen), bei Abweichung mit Grund. Eine nicht gelaufene Zielprüfung ist UNGEPRÜFT.
~~~

## Checkliste vor dem Absenden

- [ ] Kann der Agent mit diesem Text allein anfangen?
- [ ] Sind alle Dateien, die parallel bearbeitet werden, ausgeschlossen?
- [ ] Zeigen die Prüfbefehle Warnungen?
- [ ] Ist das passende Modell gewählt (Abschnitt 5.1 im Manifest)?
- [ ] Startet der Agent aus einem Arbeitsverzeichnis im Repo (für Worktree-Isolation)?
- [ ] Sind die Fallstricke aus den letzten Runden enthalten?

## Vorlage: Expertin / Experte (MANIFEST §5.1.1)

Für Fachaufgaben wie 3D-Modellierung, Video- und Audiobearbeitung, Grafik, anspruchsvolle Algorithmen. Modell: das größte, leistungsfähigste verfügbare.

~~~text
Fachaufgabe: <z. B. "parametrisches 3D-Gehäuse für Gerät X" / "Trailer 30 s aus Material Y">.
Rolle: Du bist Expertin für <Fach>. Du arbeitest autark, der Koordinator integriert und prüft dein Ergebnis.
Kontext: <Projekt in 2 Sätzen>, lies <Dateien/Material>.

Werkzeuge (vorhanden, per Kommandozeile): <z. B. 3D-Suite im Hintergrundmodus, Video-Encoder, Bild-CLI> – Versionen: <…>.
Kein Werkzeug installieren; fehlt etwas, abbrechen und melden.
Material und Rechte: nur <eigenes / frei lizenziertes> Material; Quelle jedes Assets im Bericht nennen.

Abnahmekriterien (messbar):
- <Maße ± Toleranz / Polygonzahl / Wandstärke>
- <Format, Auflösung, Bildrate, Bitrate, Dauer, Lautheit, Farbraum>
- <weitere fachliche Kriterien>

Vorgehen: erst eine Probe (kleine Auflösung / kurzer Ausschnitt), Laufzeit hochrechnen; Grenze: <N> Minuten Rechenzeit gesamt.
Abgabe in <Ordner>:
- Quelle reproduzierbar (Skript, parametrische Datei, Schnittliste, Befehle)
- Ergebnisdatei(en)
- Vorschau: <Renderings aus festen Kameras / Kontaktabzug aus Frames / Wellenform> als PNG
- Messprotokoll: Ausgabe der Analysewerkzeuge, die die Abnahmekriterien belegen

Commit im eigenen Worktree, Nachricht endet mit `<Attributionszeile>`.
Bericht ≤ <N> Zeilen: Ergebnis je Kriterium (erfüllt mit frischem Beleg / teilweise / fehlt / UNGEPRÜFT mit Grund), Rechenzeit, Assets mit Quelle, fachliche Annahmen. Keine Dumps.
~~~

## Vorlage: Prüfer (read-only)

```text
Read-only-Review. Keine Dateien ändern, nichts bauen. Repo: <Pfad>.
Rolle: <z. B. UX-Researcherin für Kinderprodukte / Sicherheitsprüfer>. Du hast den Code nicht geschrieben.
Szenarien: 1. <konkrete Person + Ziel> 2. <…> 3. <…>
Prüfe gegen: <Regeln aus Projektdatei>. Scope: <Ordner>.
Blickwinkel: <Abnahme gegen Kriterien | Code-Review | Sicherheit | Nutzerszenarien> (Abnahme zuerst, MANIFEST §7.1).
Nur echte Fehler, keine Stilfragen. Belege nur zum aktuellen Stand (Lauf nach der letzten Änderung, aktuelle Datei:Zeile, eigene Sichtprüfung).
Antwort: Ergebnis (bestanden / nicht bestanden), höchstens <N> Befunde nach Schwere (kritisch, wichtig, Kleinigkeit),
je eine Zeile `Datei:Zeile – Befund – Schwere – Konfidenz (hoch/mittel/niedrig) – konkreter Fix`.
Unsichere Befunde gesondert als „offene Fragen“. Kein Lob, kein Code.
Gefordert und tatsächlich gelaufene Prüfart getrennt nennen (z. B. Browser-Test gefordert, nur Code gelesen), mit Grund; nicht gelaufene Zielprüfung = UNGEPRÜFT.
```
