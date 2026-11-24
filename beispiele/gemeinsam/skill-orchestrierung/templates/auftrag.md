## Auftrag <ID>
Ziel: <ein Satz, was am Ende vorliegen soll>
Arbeitsordner: <absoluter Pfad>
Kontext: <zwei Sätze>. Lies zuerst: <Projektregeln, relevante Dateien>.
Eingaben: <Pfade, IDs, URLs>
Scope: Du besitzt <Dateien/Ordner>. Nicht anfassen: <Dateien>. Parallel arbeitet <Agent> an <Dateien/Thema>.
Grenzen: <was NICHT getan werden darf>. Ist eine Änderung außerhalb des Scopes unvermeidbar: minimal halten und im Bericht unter `abweichungen` begründen.
Abnahmekriterien:
- <prüfbar>
- <prüfbar>
- Bekannte Fallstricke: <aus früheren Runden oder LEARNINGS.md von The Swarm; sonst streichen>
Prüfen (exakt so):
  bash <Pfad zu The Swarm>/tools/pruefen.sh [-t wenn Tests erwartet] -d <Arbeitsordner> '<Befehl 1>' '<Befehl 2>'   (Testbefehle mit -t und Build/Lint ohne -t in getrennten Aufrufen; WARN/FAIL = nicht bestanden; Exitcode des Befehls bleibt maßgeblich, kein eigener Filter mit `| grep`)
Done: Kriterien erfüllt, null neue Warnungen, Tests grün, Sichtprüfung angesehen (falls sichtbar).
Rückgabe: Ergebnisbericht, höchstens <N> Zeilen, je Kriterium erfüllt (Beleg aus Lauf nach der letzten Änderung) / teilweise / fehlt / UNGEPRÜFT. Reviewer: je Befund Schwere + Konfidenz, unsichere als offene Fragen. Keine Code-Dumps.
Große Daten: nach <Arbeitsordner>/.agent/work/<ID>/ schreiben, nur den Pfad zurückgeben.

<!-- Checkliste vor dem Absenden (nicht mitschicken):
- Kann der Agent ohne Rückfrage und ohne Gesprächskontext anfangen?
- Sind parallel bearbeitete Dateien ausgeschlossen?
- Zeigen die Prüfbefehle Warnungen?
- Passt das Modell (eindeutig → klein, Fachwissen → groß)?
- Sind die Fallstricke der letzten Runden enthalten?
- Widerspricht ein im Auftrag verlangtes Ausgabeformat dem Berichtsformat des Agents? Dann ausdrücklich sagen, welches gilt.
- Bei Prüfer-Aufträgen: Ist die Modellfamilie des Autors genannt?
- Wird Code oder Inhalt aus Modellantworten ausgeführt? Nur isoliert (Sandbox), nie mit den Rechten des Agents.
-->
