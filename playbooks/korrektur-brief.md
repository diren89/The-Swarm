## Korrektur-Brief <ID> – Runde <n>/3
Übergabe an eine frische Sitzung. Der Agent kennt nichts aus früheren Runden; alles Nötige steht hier oder in den genannten Dateien.

Originalauftrag: <Pfad, z. B. .agent/work/<ID>/auftrag.md>   (zuerst lesen)
Abnahmekriterien (unverändert aus dem Originalauftrag, ggf. ergänzt um den Befund):
- <prüfbar>
- <prüfbar>
Scope: Du besitzt <Dateien/Ordner>. Nicht anfassen: <Dateien>. Akzeptierte Grenzen der Ausgangsversion (nicht ausweiten): <z. B. Datei X bleibt unverändert; Manifest-Änderung kommt später; bekannte Einzelmessungen>.
Arbeitsordner/Branch: <absoluter Pfad, Worktree, Branch, Basis-Commit>
Stand (Befehle ausführen, nicht Inhalt einfügen):
- Commits: `git -C <Pfad> diff <Basis>..HEAD -- <Pfade>`
- Nicht committet (Index + Arbeitsbaum): `git -C <Pfad> diff HEAD -- <Pfade>`
- Unversioniert: `git -C <Pfad> status --short --untracked-files=all`
Getroffene Entscheidungen (nicht neu aufrollen): <Stichpunkte mit Begründung>
Befunde:
- Zu beheben: <Pfad der Befund-Datei, z. B. .agent/work/<ID>/review-<n>.md>, Nr. <…>
- Akzeptiert/bewusst offen (nicht anfassen): <Nr. + Grund oder Pfad>
Fallstricke: <aus früheren Runden, Auftrag und LEARNINGS.md von The Swarm; sonst streichen>
Prüfen (exakt so, Regression eingeschlossen):
  bash tools/pruefen.sh -t -d <Arbeitsordner> '<Testbefehl>'
  bash tools/pruefen.sh -d <Arbeitsordner> '<Build/Lint>'   (getrennt: -t verlangt in jedem Befehl eine Testzahl)
Done: behobene Befunde einzeln belegt (Wirkung, nicht nur Exit-Code), Regressionsprüfung unverändert grün, null neue Warnungen, Scope eingehalten.
Rückgabe: Ergebnisbericht nach Berichtsformat des Agents, mit erfüllt / offen / UNGEPRÜFT je Befund. Lange Ausgaben nach <Arbeitsordner>/.agent/work/<ID>/.
Runde <n> von höchstens 3; danach legt der Koordinator Restbefunde mit Risiko und Aufwand der Nutzerin vor.

<!-- Checkliste vor dem Absenden (nicht mitschicken):
- Steht der Pfad des Originalauftrags drin, und passen Kriterien und Scope?
- Sind Arbeitsbaum/Branch und der Diff-Befehl korrekt (Befehl probehalber ausgeführt)?
- Sind akzeptierte Befunde/Grenzen getrennt von zu behebenden genannt?
- Läuft der Prüfbefehl so, wie er dasteht (Pfade absolut)?
- Fortsetzen der alten Sitzung wäre billiger? (Rückfrage, kleine Folgefrage oder Sitzung < ~60k Kontext) Dann dort fortsetzen statt neu briefen.
-->
