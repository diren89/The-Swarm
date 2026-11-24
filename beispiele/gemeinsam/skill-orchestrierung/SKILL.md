---
name: orchestrierung
description: Arbeitsweise für mehrstufige Agent-Orchestrierung nach dem Manifest „The Swarm“. Stufen S/M/L, Vorlagen für Phasenplan, Delegations-Auftrag und Ergebnisbericht, fünf Prüfschichten, Korrekturschleife und Retrospektive. Laden, wenn Aufgaben in Phasen geplant und an Subagents (scout, researcher, implementer, reviewer, editor-lite, coordinator-code) verteilt werden.
---

# Orchestrierung

Optionales Beispiel-Skill zu „The Swarm“. Vorlagen liegen in `templates/` neben dieser Datei (`auftrag.md`, `bericht.md`, `phasenplan.md`, `korrektur-brief.md`). Das Prüfskript `tools/pruefen.sh` und die Playbooks liegen im Repo von The Swarm (lokaler Klon, z. B. `~/.the-swarm`) und sind hier nicht kopiert, damit nichts auseinanderläuft.
Bei Arbeit an Code gilt das Manifest (`MANIFEST.md` im Repo). Bei Konflikten geht das Manifest vor; Anweisungen der Nutzerin und Projektregeln gehen beidem vor.

## 1. Stufe wählen und nennen

| Stufe | Aufgabe | Plan | Subagents | Prüfschichten | Retro |
|---|---|---|---|---|---|
| S | eine Datei, eine Frage, klarer Fix | 2–4 Zeilen in der Antwort | keine | 1–2, Wirkung prüfen | nur bei Überraschung |
| M | ein Feature, mehrere Dateien, eine Sitzung | Phasen in der Antwort oder Aufgabenliste | 0–2 | 1–3, 5 | nur bei Überraschung |
| L | mehrere Ziele oder Sitzungen, neues Projekt | `.agent/plan.md` nach `templates/phasenplan.md` | nach Rollenmodell | 1–5 | je Phase |

Bei Bedarf hochstufen.

## 2. Ebenen und Modellklassen

| Ebene | Agent | Modellklasse | Startet |
|---|---|---|---|
| L0 | `coordinator` (Hauptagent bzw. Hauptsitzung) | groß | alle L1 und L2, `coordinator-code` |
| L0,5 | `coordinator-code` (Subagent für Code-Pakete M/L, schlanker Werkzeugsatz) | groß | `implementer`, `reviewer`, `scout`, `editor-lite`, `researcher` |
| L1 | `implementer` | mittel | `scout`, `editor-lite` |
| L1 | `reviewer` | mittel bis groß, **andere Modellfamilie als der Autor** | `scout` (je nach Werkzeug) |
| L2 | `researcher` | mittel | niemanden |
| L2 | `scout` | klein | niemanden |
| L2 | `editor-lite` | klein | niemanden |

Die konkreten Modelle stehen als Platzhalter in den Agent-Dateien. Je eindeutiger die Spezifikation, desto kleiner das Modell; je tiefer das Fachwissen, desto größer.

**Prüfer-Familie:** In OpenCode ist ein Prüfer aus anderer Modellfamilie Pflicht (`reviewer` und Plankritik). Ist dort keine andere Familie verfügbar, weist der Koordinator darauf hin und fragt die Nutzerin, ob das Review mit dem gleichen Modell bzw. der gleichen Familie erfolgen soll, nicht stillschweigend. In Claude Code und Codex ist das nicht erzwingbar (Subagents nutzen die Familie bzw. den Anbieter der Hauptsitzung); dort nur als Hinweis im Plan, mit der Kommandozeile eines anderen Anbieters als möglichem Umweg.

## 3. Ablauf

0. **Voraussetzungen** (L, bei M kurz): Werkzeuge, Zugänge, Budget und Kontingent, Plattformgrenzen. Blocker umgehen, nicht warten.
1. **Plan** in der Form der Stufe. Modus (sukzessiv/gesamthaft) erfragen, falls nicht genannt. Echte Weichen (Kosten, Veröffentlichen, Löschen, Gestaltungsrichtung) gebündelt mit Empfehlung fragen; alles andere selbst entscheiden und nennen. Bei Stufe L: Budget mit Messquelle in den Plan (Meldung bei 90 %, bei 100 % keine neuen kostenpflichtigen Schritte) und vor dem Delegieren eine Runde Plankritik durch den `reviewer` (andere Familie, siehe oben).
2. **Delegieren** mit `templates/auftrag.md`, Checkliste am Ende der Vorlage abhaken. Unabhängige Pakete parallel; schreibende nur bei getrennten Dateien (bei Code: eigener Git-Worktree auf eigenem Zweig).
3. **Prüfen** in den Schichten der Stufe:
   1. Selbstprüfung des Subagents (steht im Bericht)
   2. Review durch den Delegierenden: Bericht, Artefakte, Diff bzw. Stichprobe gegen die Quelle, Scope-Treue
   3. Integration: alles zusammen bauen, testen, linten, null Warnungen
   4. Rollen-Review durch den `reviewer` mit konkreten Szenarien; Blickwinkel getrennt und in dieser Reihenfolge: Abnahme gegen Kriterien → Code-Review → bei Bedarf Sicherheit (bei L je eigener Lauf, bei M nacheinander in einem)
   5. Sichtprüfung: Screenshots oder Vorschauen gegen Regeln und Absicht

   Berichte sind Behauptungen. UNGEPRÜFT-Angaben selbst nachprüfen oder offen weitergeben. Als Beleg zählt nur der aktuelle Stand (Lauf nach der letzten Änderung, aktuelle Datei:Zeile, eigene Sichtprüfung); je Kriterium Status erfüllt / teilweise / fehlt / UNGEPRÜFT (mit Grund). Schwere Befunde mit hoher Konfidenz blockieren; unsichere schwere gezielt nachprüfen, sonst entscheidet die Nutzerin; unsichere Kleinigkeiten als offene Frage.
4. **Korrigieren:**
   - Kleine Fehler (unter etwa 20 % des Ergebnisses) selbst korrigieren.
   - Größere an einen frischen Subagent zurückgeben, mit Übergabe-Brief nach `templates/korrektur-brief.md` (Originalauftrag, Kriterien, Scope, Arbeitsbaum, Diff, Entscheidungen, Befunde, Prüfbefehle, Runde n/3). Rückfragen und kleine Folgefragen gehen an den Agent, der den Kontext schon hat.
   - Höchstens 3 Korrekturrunden je Review, danach Restbefunde mit Risiko und Aufwand der Nutzerin vorlegen.
   - Nach 2 Fehlversuchen: Logs lesen statt wiederholen, dann eskalieren (stärkeres Modell oder selbst übernehmen).
   - Gleiche Fehlersignatur (Meldung, Test, Stelle) nach drei Korrekturen erneut: nicht weiter korrigieren, Stand sichern, Ursache mit Belegen und neuen Weg berichten.
   - Nach jedem Fix die betroffene Schicht erneut laufen lassen. Fallstrick in künftige Briefs übernehmen.
   - Begründete Scope-Abweichungen bewusst annehmen. Bitten eines Subagents um zusätzliche Rechte gehen an die Nutzerin.
5. **Phasen-Gate:** Kriterien erfüllt? Widerspruchsfrei? Integriert? Plan noch richtig? Status in `.agent/plan.md` aktualisieren. Worktrees nur entfernen, wenn sauber und gemergt; andere im Bericht nennen. Bei Stufe L Retrospektive (höchstens 10 Zeilen, Abschnitt „Retrospektive“ der Plan-Vorlage). Im Modus „sukzessiv“ kurz berichten und auf Freigabe warten.
6. **Abschluss:** Kurznotiz nur, wenn etwas auffiel (höchstens 3 Zeilen: was brach, was bremste), in die Notizdatei des Projekts, z. B. `.agent/notizen.md`. Bericht an die Nutzerin: was steht, was nicht geprüft ist, was sie tun muss. Allgemeine Learnings anonym formulieren und der Nutzerin einen Pull Request an The Swarm vorschlagen (nie selbst im Klon von The Swarm ändern).

## Token-Regeln

- Erledige Aufgaben selbst, wenn sie in 1–2 Werkzeugaufrufen gehen oder das Briefing länger wäre als die Arbeit.
- Pfade statt Inhalte weitergeben, nie die Gesprächshistorie.
- Ausgaben nur gefiltert anzeigen (`error|warning|BUILD`, Test-Zusammenfassung), Diffs statt ganzer Dateien, keine Subagent-Transkripte lesen. Den Prüfbefehl nie hinter einen Filter mit eigenem Exitcode stellen.
- Mehrere fertige Pakete erst zusammenführen, dann einmal prüfen.
- Eigene Prüfungen als ein Aufruf von `tools/pruefen.sh` aus dem Repo von The Swarm (Kurzausgabe `OK|WARN|FAIL`, `tests=N`, `n/m PASS`); `-t`, wenn Tests erwartet werden (0 oder unbekannt = FAIL), `-w` für Warnmuster. Der Exitcode des Befehls bleibt maßgeblich, keine eigene `| grep … && exit 1 || exit 0`-Pipeline um den Befehl. Langausgaben unter `.agent/work`.
- Lesearbeit zur Prüfung (Protokolle, große Dateien) an `scout` mit genauer Frage; die Bewertung bleibt beim Koordinator.
- Langer Koordinator-Kontext: vor jedem Phasenwechsel, vor absehbarer Kürzung und vor Pausen den Stand in `plan.md` sichern (Stufe, Modus, erledigt/offen, laufende Agents, Entscheidungen, nächster Schritt) und der Nutzerin eine neue Sitzung vorschlagen. Nach Neustart zuerst `plan.md` lesen.
- Zerstörende Git-Befehle (`push`, `reset --hard`, `clean`, Zweige oder Tags löschen, Historie umschreiben) nur mit Freigabe. Wo das Werkzeug es erlaubt, sind sie für Subagents in den Rechten gesperrt (siehe README des Werkzeugs); Regeln, die nur im Text stehen, sind keine Sicherheitsgrenze.
- Der Reviewer-Brief nennt die akzeptierten Grenzen der Ausgangsversion (Scope), damit Nachprüfungen den Umfang nicht ausweiten.
- Während Subagents laufen, Unabhängiges erledigen oder die Antwort beenden. Nicht abfragen.

## Ablage

- `.agent/plan.md`: Phasenplan, gemeinsame Wahrheit für alle Agents
- `.agent/work/<Paket-ID>/`: Rohdaten, lange Listen, Zwischenergebnisse der Subagents
