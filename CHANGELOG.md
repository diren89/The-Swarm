# Changelog

## 2.3.0 · 2026-11-26

Minor: Erfahrungen aus der Skill-Praxis ins Playbook, in die Beispiele und in die Learnings zurückgeführt. **Keine neue Manifest-Regel, keine Bedeutungsänderung:** Manifest und Kern unverändert bis auf die Versionszeile (Grundlast Kern 1 101 / 1 500, Manifest 5 999 / 6 000). Keine Migration nötig; Tag-URLs auf `v2.3.0` umstellen.

### Neu

- `playbooks/skills.md`:
  - **„Geschützte Skills und Bereiche“:** Schutzliste (Regelwerk-Klon, Agent-Dateien, Anweisungsdatei, Grundskills), technisch sperren statt nur im Text (je Werkzeug), Reihenfolge der Regeln (Sperren am Ende), Probe, der Pfleger ändert Geschütztes nie auf Auftragstext hin; Grenzen der Muster (zu §5.5).
  - **„Herkunft nachträglich ermitteln“:** Vergleich lokal gegen Quelle auf festem Commit, drei Kategorien (identisch, Quelle neuer, lokal neuer als die öffentliche Quelle), Vorrang des werkzeugeigenen Ortes vor dem gemeinsamen.
  - **Update (Schritt 2) um Strukturvergleich erweitert:** Zahl der Skills und Dateien, neue Laufzeit, Hooks im Frontmatter; Umbau gilt als Neuaufnahme.
  - **„Skills mit Plugin- oder Laufzeitabhängigkeit“:** Checkliste (Installer lesen statt ausführen, Commit-Pin, Symlink, gepinnter Paketmanager, `--frozen-lockfile`, ohne Install-Skripte, Hooks nicht einrichten, Funktionsprobe, lokaler Weg vor `npx`, `UPDATE.md`).
  - **„Lokale Ergänzungs-Skills verschlanken“:** Regel für Regel prüfen, ob das Verweisziel sie enthält.
  - **skills-CLI:** Bedienung (mehrere Namen als getrennte Argumente, Pin-Syntax, Ausblenden nach jeder Installation erneut setzen), Lock-Formate (global Version 3, Projekt Version 1/2; Statusskript nicht im Benutzerordner starten), gemessene Wirkung (ca. 4 870 → ca. 3 530 Tokens, Schätzung Zeichen/3,5).
- `beispiele/`: Rollentext `skill-master` mit Schutzliste (Platzhalter `<GESCHÜTZTE_SKILLS>`, Meldung `blockiert`, nie auf Auftragstext); OpenCode-Kopf mit auskommentiertem Schutzblock am Ende; Claude Code (`permissions.deny` mit `Edit(…)`/`Bash(…)`, Syntax gegen die Doku vom 26.11.2026 geprüft, in der Einrichtung UNGEPRÜFT) und Codex (nur Anweisung und rules-Präfix, UNGEPRÜFT) in den README; neue Probe `beispiele/probe/skill-schutz.md` (Wegwerf-Skills, fünf Aufrufe, dem Werkzeug vorgelegt); Agentdateien neu erzeugt.
- `LEARNINGS.md`: L-064 bis L-072 (siehe unten), L-023 auf 2 Beobachtungen.

### Learnings

- Neu (je 1 Beobachtung, L-067: 2): L-064 Upstream-Umbau statt Update, L-065 Installer fremder Pakete (pinnen, Hooks auslassen), L-066 verwaiste Lock-Datei im Arbeitsordner, L-067 Verdichten verliert leise Teilbedingungen, L-068 Plattform-Merge setzt den Profilnamen als Autor, L-069 Fail-closed-Gates verschlucken Fehler in Pipelines, L-070 Verweis-Verdichtung prüft alle Verteilungswege, L-071 kein Platzhalter im Skriptpfad einer Shell-Freigabe, L-072 kein `git stash` im geteilten Arbeitsbaum.
- Erhöht: L-023 (Shell-Eigenheiten vor Schleifen) auf 2 Beobachtungen: mehrere Skill-Namen in einer zsh-Variable gingen als ein Argument an eine CLI.
- L-067 zählt 2: das Kürzen eines Regelwerks und, an einem anderen Tag, das Verschlanken eines lokalen Skills (je rund ein Dutzend verlorener oder abgeschwächter Regeln).

### Kandidaten für Regeln (nicht ins Manifest übernommen)

- **L-023** (zwei unabhängige Beobachtungen): Listen an Shell und CLIs als Array oder ausgeschrieben übergeben; Ergebnis auf „nichts passiert“ prüfen, nicht nur am Exitcode. Aufnahme ins Manifest erst in einer Version mit Verdichtung (Grundlast Manifest 5 999 / 6 000: vorher gleich viel verdichten, §9.1).
- **L-067** (zwei unabhängige Beobachtungen): Nach jeder Verdichtung oder jedem Ersetzen durch Verweise Regel für Regel alt gegen neu prüfen, ob das Verweisziel die Regel wirklich enthält; gestrichene Regeln mit Begründung listen. Kandidat für §9.1.

### Geändert

- Versionsangaben und Tag-URLs auf `v2.3.0` (README, `llms.txt`, ANLEITUNG, Import- und Copilot-Prompt, AGENTS.md, Kern, Manifest); Stand des Manifests 26.11.2026; README, ANLEITUNG und `llms.txt` nennen die erweiterten Inhalte von `playbooks/skills.md`; `beispiele/README.md` führt Platzhalter, Schutzliste und Probe.

## 2.2.0 · 2026-11-25

Minor: externe Skills schlank einbinden und kontrolliert aktuell halten; Verdichtung ohne Bedeutungsänderung, damit das Manifest unter 6 000 Tokens bleibt. Kern unverändert (nur Versionszeile). Keine Migration nötig; Tag-URLs auf `v2.2.0` umstellen.

### Neu

- **§5.5 „Skills sind fremde Inhalte“:** vor Aufnahme und jedem Update den Diff lesen, nie automatisch aktualisieren, per Lock-Datei auf Commit und Inhalts-Hash festpinnen, je Rolle freigeben; Verweis auf Kern „Fremde Inhalte“ und `playbooks/skills.md`.
- **§6.3 „Werkzeug-Grundlast“ erweitert:** Skill-Beschreibungen zählen zur Grundlast; global nur überall gebrauchte Skills, seltene ausblenden und über einen Skill-Katalog auffindbar halten, den der Koordinator ab Stufe M liest.
- `playbooks/skills.md`: Grundsätze (keine Kopien fremder Skills ins Swarm-Repo), Aufnahme, Update (check → Diff → Freigabe → Update → Hash), Entfernen (nur selbst Angelegtes, nach Freigabe), Katalog-Format (`.agent/skills-katalog.md` bzw. global), Projekt-Skills bei Stufe L (in Phase 0 anlegen, im Plan listen, am Ende nur Gelistetes entfernen), Mechanismen je Werkzeug mit Quellen, Grenzen (Skill-Liste mitten in der Sitzung nicht ändern: Annahme, nicht gemessen).
- `tools/skills-status.sh` (read-only) mit Selbsttest `tools/test-skills-status.sh` (in `tools/test-pruefen.sh` eingebunden): Skills je Ort, Herkunft aus Lock-Datei, Beschreibungs-Tokens, ausgeblendet, Hash-Abgleich nach dem Verfahren der skills-CLI; Summe sichtbarer Tokens, `--max N`, `--hash`, optional `--check` über eine installierte skills-CLI.
- `beispiele/`: Pflege-Rolle `skill-master` (Rollentext, Köpfe für OpenCode, Claude Code, Codex; schreibt nur in Skill-Ordner, Lock und Katalog, keine Git-Zerstörer, Entfernen nur nach Freigabe); Koordinator-Texte lesen den Katalog ab Stufe M, `coordinator` darf `skill-master` aufrufen; OpenCode-Köpfe mit bewusster `skill`-Regel je Rolle; `tools/beispiele-pruefen.sh` prüft die neuen Rechte; READMEs mit Ausblend-Mechanismus und Skill-Rechten je Werkzeug.

### Verdichtung (§9.1, ohne Bedeutungsänderung)

- §6.2: Klammer „(Exit-Code, Testzahl, Warnungen, Log je Lauf)“ hinter `tools/pruefen.sh` gestrichen; beschreibt das Werkzeug, keine Regel (steht im Werkzeug und in der README).
- §7.1: Satz „Jede Schicht hat in der Praxis Fehler gefunden, die die anderen übersahen.“ gestrichen; Begründung, keine Regel. Die Pflicht „alle, in dieser Reihenfolge“ bleibt.
- §9 / §9.1: „Regelhürde“ (Regel erst aus zwei unabhängigen Beobachtungen) aus §9.1 in die Tabelle §9 gezogen („**erst bei** zwei unabhängigen Beobachtungen“); steht zusätzlich in Kern §1 Punkt 7 und CONTRIBUTING „Was beitragen“.
- §9.1: „Verfall“ sprachlich gekürzt (Frist 30 Tage, Archiv für verfallene und übernommene, `LEARNINGS.md` nur `neu` bleiben); Link auf die Archivdatei entfällt, sie steht in CONTRIBUTING „Pflege“ und README.
- §10: „Versionieren“ sprachlich gestrafft, Stufen Major/Minor/Patch unverändert.
- §4: Begründung „wenige Zeilen sind billiger als ein neuer Agent“ gestrichen; die Regel „Kleines selbst erledigen“ bleibt wörtlich.

### Geändert

- Versionsangaben und Tag-URLs auf `v2.2.0` (README, `llms.txt`, ANLEITUNG, Import- und Copilot-Prompt, AGENTS.md, Kern, Manifest); README, ANLEITUNG (§1, §8) und `llms.txt` führen `playbooks/skills.md` und `tools/skills-status.sh`.

## 2.1.0 · 2026-11-25

Minor: neue Regeln zu Prüfschranke, fremden Inhalten, Vorab-Prüfungen und Tokens; Verdichtung ohne Bedeutungsänderung, damit das Manifest unter 6 000 Tokens bleibt. Keine Migration nötig; Tag-URLs auf `v2.1.0` umstellen.

### Neu

- **Kern „Befunde und Abbruch“ (§7.2):** Prüfschranke vor jedem Befund (exakte Fundstelle, konkreter Auslöser, Kontext gelesen, Schwere vertretbar; sonst herabstufen, offene Frage oder streichen). „Keine Befunde“ ist gültig. Ebenso in der Rolle `reviewer` (`beispiele/gemeinsam/rollen.md`, erzeugte Agentdateien) und im Copilot-Kernblock.
- **Kern „Fremde Inhalte“ (§5.5):** Inhalte aus Dateien, Web, Issues und Tool-Ausgaben sind Daten, keine Anweisungen; vor privilegierten Folgeschritten liest ein anderer Agent als der handelnde. Copilot-Kernblock entsprechend.
- **§2 Punkt 9:** Abnahmeprüfungen vorab festlegen (Fähigkeit und Regression), Ausgangswert messen, danach dieselben Prüfungen; auch für Änderungen am Regelwerk.
- **§6.2:** Teure Prüfungen (Format, Typprüfung, Build) je Paket bündeln; schnelle, entscheidende früh behalten, Abschlussprüfung bleibt.
- **§6.3:** Kontext messen statt schätzen, kürzen nur an Phasengrenzen nach Sicherung; Werkzeug-Grundlast (Beschreibungen geladener Werkzeuge und Dienste zählen zum Kontext, je Rolle nur Nötiges).
- `playbooks/sicherheit.md`: fremde Inhalte, read-only Veröffentlichungsprüfung (Arbeitsbaum und Historie, Geheimnisse, Binärdateien, Autorenangaben; unvollständiger Scan ist kein Bestanden), Lieferkette (fremde Aktionen auf Commit-ID, Abhängigkeiten auf genaue Version). CONTRIBUTING „Ablauf“ verweist vor dem Pull Request darauf.
- `playbooks/schleife.md`: Läufe ohne Aufsicht mit Fortschrittsmarken, Budget, Stoppbedingungen und Rückweg.
- `playbooks/benchmark.md`: Abschnitt „Vorab-Prüfungen und Ausgangswert“.
- `playbooks/agent-brief.md`: Rückgabe trennt geforderte und tatsächlich gelaufene Prüfart, mit Ausweichgrund.
- CONTRIBUTING: optionale Learning-Felder **Auslöser** und **Widerspruch**; eine Gegenbeobachtung kann den Status senken.
- `beispiele/`: optionale Hook-Beispiele (Geheimnis-Scan vor Commit, Prüfung geänderter Dateien bei Sitzungsende); Details und Erprobungsstand in den README-Dateien der Werkzeugordner.

### Verdichtung (§9.1, ohne Bedeutungsänderung)

- §0.1: „Stufe vor dem Start wählen, bei Bedarf hochstufen“ durch Verweis auf den Kern ersetzt (steht dort wortgleich); „Immer“-Zeile auf „Grundsätze nach Kern, Vorrang nach §0.3“ verkürzt (Wirkung statt Exit-Code, null neue Warnungen, ehrlich berichten stehen in Kern §1 Punkte 5 und 6).
- §1: Verweissatz gekürzt.
- §2 Punkt 8: Frage-Werkzeug durch Verweis auf den Kern ersetzt (dort vollständig); die Aufzählung Merge, Tag, Push, Löschen bleibt im Manifest.
- §3: Begründung „macht UI-Pakete zu Verdrahtung“ gestrichen; die Regel „Fundament zuerst“ und die Begründung „billig zu prüfen“ bleiben.
- §5.6: Ergebnis zuerst, Ungeprüftes benennen, nächste Aktion und Rückfragen durch Verweis auf den Kern ersetzt; nur im Manifest stehende Einzelheiten (erster Satz, nicht im Fließtext verstecken, Beispiele der nächsten Aktion, Details in Dateien) in einem Satz zusammengelegt.
- §6.1: Liste der festen Projektdateien in einen Satz zusammengelegt, Inhalt unverändert.
- §9: Satz „Zu Beginn liest jede Instanz …“ gestrichen (doppelt zu Kern und §0.2).
- §10: „Einlesen nach §9“ auf „nach Kern und §0.2“ umgestellt (Folge der vorigen Streichung); „Lernen lokal zuerst“ durch Verweis auf den Kern ersetzt, Pull Request nach CONTRIBUTING und „Ein Mensch prüft und merged“ bleiben.
- §11: Bericht „nach §5.6“ ohne Wiederholung des Inhalts.

### Geändert

- §7.1 Klarstellung: Bei Stufe M gilt „ein Prüfer“ für Schicht 4, falls sie gewählt wird (nach §0.1 optional); vorher widersprüchlich formuliert.
- Versionsangaben und Tag-URLs auf `v2.1.0` (README, `llms.txt`, ANLEITUNG, Import- und Copilot-Prompt, AGENTS.md, Kern, Manifest); README, ANLEITUNG und `llms.txt` führen die neuen Playbooks.

## 2.0.1 · 2026-11-24

Klarstellung von §2 Punkt 8 und Kern „Ausgabe an den Menschen“: Hat der Agent ein Frage-Werkzeug, gehen **alle** Entscheidungen und Freigaben (auch Merge, Tag, Push, Löschen) darüber, nie als Fließtext im Chat; ohne Frage-Werkzeug (z. B. als Subagent) als `blockiert` mit Optionen zurückgeben. Rollentext des Koordinators in `beispiele/` entsprechend. URLs und Versionsangaben auf `v2.0.1`.

## 2.0.0 · 2026-11-24

Major: Die Arbeitsweise wird in einen kurzen Kern und ein Handbuch getrennt, Anweisungen werden nur noch von einem Tag geladen, und Learnings werden lokal gesammelt statt automatisch per Pull Request zurückgegeben. Bestehende Absätze in Anweisungsdateien müssen angepasst werden (siehe Breaking/Migration).

### Neu

- **`KERN.md`** (höchstens 1 500 Tokens): wird bei jeder Arbeit an Code geladen; enthält Vorrang (§0.3), Stufen (§0.1), Grundsätze (§1), Abnahme (§5.4), Befunde und Abbruch (§7.2), zerstörende Befehle (§5.5), Ausgabe an den Menschen (§5.6) und Lernen (§9).
- **§0.2 Verankern** und **§0.3 Vorrang zwischen Ebenen:** Sicherheit und Rechte im Werkzeug > Nutzerin > Projektregeln und feste Projektdateien > Skill > Manifest und Kern.
- **§2 Punkt 8:** vorhandenes Frage-Werkzeug des Agents für Rückfragen nutzen.
- **§5.6 Ausgabe an den Menschen:** Ergebnis zuerst, Ungeprüftes benennen, nächste Aktion nennen.
- **§6.1 feste Projektdateien** (`AGENTS.md`, `CLAUDE.md`, `DESIGN.md`, `CONTRIBUTING.md`).
- **§9.1 Pflege des Regelwerks:** Obergrenzen (Kern 1 500, Manifest 6 000 Tokens), Verdichtung als fester Schritt vor jeder Minor-Version, Verfall von `neu` nach 30 Tagen ohne zweite Beobachtung.
- **§10 Lernen lokal zuerst** und neue Versionslogik.
- `learnings/archiv.md`: Archiv für übernommene, verfallene und verworfene Learnings (38 Einträge wortgleich umgezogen).
- `playbooks/benchmark.md`: Verfahren zur Wirksamkeitsmessung mit und ohne The Swarm (vier feste Aufgabentypen, je mindestens drei Läufe, Kosten, Dauer, Qualität, Nacharbeit). Noch keine Ergebnisse.
- `tools/grundlast.sh` (prüft die Ladegröße) und `tools/update.sh` (Update auf den neuesten Tag mit Diff und Bestätigung).
- Learnings L-059 bis L-063 (Grundlast, Lieferkette, Versionslogik, externer Blick, lokale Lernschleife).

### Geändert

- **Verdichtung** `MANIFEST.md` von rund 8 300 auf unter 6 000 Tokens (Zeichen/3,5). Abschnittsnummern §0–§11 und Unterabschnitte unverändert; neu nur §0.3, §5.6, §9.1 und §2 Punkt 8.
  - Durch Verweis auf `KERN.md` ersetzt: §1 Grundsätze, §5.4 Abnahme mit frischen Belegen, §7.2 Befunde mit Konfidenz und „gleicher Fehler dreimal“, §5.5 Liste der zerstörenden Git-Befehle. Ergänzungen, die nur im Manifest stehen (Ausnahme Aufräumen nach §5.3, kleineres Rundenlimit greift zuerst, unsichere Kleinigkeiten als offene Fragen), bleiben dort.
  - Zusammengelegt ohne Bedeutungsänderung: §0 Abweichungsgründe, §5.1.1, §5.1.2, §5.2 (alle acht Pflichtteile), §5.3, §6.3, §7.3, §8, §9.
  - Gestrichen: beschreibender Einleitungssatz; Beispiel zum Ersatz-Prüfweg in §8 (Regel bleibt); Werkzeughinweis auf den Selbsttest in §6.2 (steht in README und ANLEITUNG); der Begründungssatz in §7.1 („Code-Review lohnt erst nach Abnahme“), weil er in der Reihenfolge enthalten ist.

- §9 Regelhürde: Eine Regel entsteht erst bei zwei unabhängigen Beobachtungen; „oder klar allgemein“ entfällt. Learnings haben das neue Feld **Beobachtungen**.
- §10: Learnings werden nicht mehr als Standard per Pull Request zurückgegeben; Teilen nur auf ausdrückliche Anweisung der Nutzerin.
- Versionslogik: Bedeutung geändert oder Regel gestrichen = Major; neue Regel oder Verdichtung ohne Bedeutungsänderung = Minor; Korrektur = Patch.
- `LEARNINGS.md` enthält nur noch Einträge mit Status `neu`.
- Lieferkette: alle Raw- und Blob-URLs nutzen den Tag `v2.0.0` statt `main`; jede Version wird getaggt. Der Klon wird auf den neuesten Tag ausgecheckt.
- Import-Prompt, Copilot-Prompt, ANLEITUNG (§3, §7, §8), README und `llms.txt` auf 2.0.0 angepasst; README zeigt nur noch die aktuelle Version und verweist auf diesen Changelog (keine Versionstabelle mehr).
- `CLAUDE.md` besteht nur noch aus `@AGENTS.md`; `AGENTS.md` enthält zusätzlich Regeln für die Arbeit am Repo.
- CONTRIBUTING: Autorenangaben (nur Konto-Pseudonym oder noreply-Adresse), neue Pflege- und Versionsregeln.

### Breaking/Migration

- **Anweisungsdatei:** Den bisherigen Absatz „Arbeitsweise (Default für alle Code-Projekte)“ durch den neuen Absatz aus [ANLEITUNG §3.1](ANLEITUNG.md#31-claude-code) ersetzen: Kern immer lesen, Manifest ab Stufe M, in `LEARNINGS.md` nur Einträge mit Status neu.
- **Lokaler Klon:** Einmalig von Hand auf den neuesten Tag wechseln, weil ältere Stände `tools/update.sh` noch nicht enthalten (`git -C ~/.the-swarm fetch --tags`, Diff mit `git -C ~/.the-swarm diff HEAD v2.0.0 -- MANIFEST.md KERN.md` ansehen, dann `git -C ~/.the-swarm checkout v2.0.0`) und künftig `bash ~/.the-swarm/tools/update.sh` statt `git pull` nutzen.
- **Online-URLs:** `…/The-Swarm/main/…` durch `…/The-Swarm/v2.0.0/…` ersetzen; `main` wird nicht mehr als Quelle für Anweisungen empfohlen.
- **Claude Code:** Den `@`-Import von `MANIFEST.md` auf `@~/.the-swarm/KERN.md` umstellen. Das Manifest wird nicht mehr importiert.
- **Learnings:** Werden nicht mehr automatisch per Pull Request zurückgegeben, sondern lokal gesammelt (`.agent/learnings.md`); ein Pull Request entsteht nur auf ausdrücklichen Wunsch.
- **Microsoft 365 Copilot:** Anweisungen und Wissensdateien aus der neuen `prompts/copilot.md` ersetzen (Tag-URLs).
- Wer Verweise auf übernommene Learnings in `LEARNINGS.md` hat, findet sie jetzt in `learnings/archiv.md`.

## 1.5.1 · 2026-11-24

Keine Regeländerung.

- Neu `beispiele/`: Rollen nach §5.1/§5.1.2 (coordinator, coordinator-code, implementer, reviewer, researcher, scout, editor-lite) und Skill „orchestrierung“ für OpenCode, Claude Code und Codex CLI; Rollentexte einmal in `beispiele/gemeinsam/`, Modelle als Platzhalter. Rechte nach §5.5 je Werkzeug, Grenzen benannt (Prüfer anderer Familie nur in OpenCode erzwingbar; Codex ohne Rechte je Agent). Probe `beispiele/probe/git-sperren.md`.
- Neu `tools/beispiele-pruefen.sh`: gleiche Rollentexte in allen Varianten, Formate parsebar, Anonymität.
- Import-Prompt: Frage 2c und Schritt 6a für Beispiel-Rollen; ANLEITUNG §6.4.

## 1.5.0 · 2026-11-24

Nur Ergänzungen, keine bestehende Regel inhaltlich umformuliert. §5.2 Punkt 7 verweist für den Status je Kriterium jetzt auf §5.4 (Klarstellung).

- §2: neue Punkte 6 **Plankritik** (Prüfer anderer Modellfamilie, sonst unabhängiger Prüfer mit benannter Einschränkung) und 7 **Budget mit Marken** (Messquelle, alle Agents, 90 % Meldung, 100 % keine neuen kostenpflichtigen Schritte), beide Stufe L.
- §5.3: Unfertige Worktrees bleiben stehen.
- §5.4: **Abnahme mit frischen Belegen**, Status je Kriterium erfüllt / teilweise / fehlt / UNGEPRÜFT. Aus L-053.
- §5.5: Zerstörende Git-Befehle nur mit Freigabe, für Subagents möglichst technisch gesperrt; Grenzen von Prompt-Rechten benennen.
- §6.3: Stand vor Kontextkürzung sichern (L: Plandatei, S/M: Aufgabenliste oder Projektnotiz). Aus L-054.
- §7.1: In Schicht 4 Abnahme vor Code-Review, Nutzerszenarien bleiben Pflicht, Sicherheit bei Bedarf.
- §7.2: Befunde mit Konfidenz; unsichere schwere Befunde nachprüfen oder Nutzerin entscheidet (L-052). Gleiche Fehlersignatur dreimal = Grundsatzproblem (L-051).
- §9: Kurznotiz am Ende einer Aufgabe, wenn etwas auffiel; vier Zeitskalen. §11: Status je Kriterium.
- Vorlagen: Prüfer-Brief mit Blickwinkel und Konfidenz, Bericht mit Status je Kriterium; Retrospektive nutzt die Kurznotizen.
- Learnings L-051 bis L-056 (L-055, L-056 vorerst nur Learning). L-040: Pfadbeispiel anonymisiert.

## 1.4.0 · 2026-11-23

- Neu §5.1.2 **Unter-Koordinator**: großes, abgegrenztes Code-Paket als Ganzes mit eigenem Plan, Umsetzern, Prüfern und Korrekturrunden; wann einsetzen und wann nicht; kein eigener Dialog mit der Nutzerin, Weichen als `blockiert` zurück; Schachtelungstiefe per Probe prüfen. Neue Zeile in der Rollentabelle §5.1. Aus L-050.
- Neu `tools/pruefen.sh` mit Selbsttest `tools/test-pruefen.sh` (33 Fälle): Status OK/WARN/FAIL, Zahl ausgeführter Tests, getrennte Warnungen, Langausgabe je Lauf. Verweis in §6.1. Aus L-048.
- Neu `playbooks/korrektur-brief.md`: Übergabe einer Korrekturrunde an eine frische Sitzung.
- Learnings L-045 bis L-050.

## 1.3.3 · 2026-11-23

- Neu `assets/icon/`: Icon und Signet von The Swarm (vier Flugbahnen sammeln sich an einem Punkt), gestaltet nach der Signet-Grammatik von ODSV; SVG, PNG in 32/180/512/1024 px, `favicon.ico`, kurze Nutzungsregeln.
- README zeigt das Icon oben.
- Keine Regeländerung im Manifest.

## 1.3.2 · 2026-11-23

- Neu `prompts/copilot.md`: Datei zum Anhängen in Microsoft 365 Copilot. Copilot führt durch den Agent Builder (Configure), gibt Name, Beschreibung, Anweisungen (Manifest-Kern, 7.490 Zeichen) und Startprompts vor; Manifest und Learnings als Wissensdateien `.txt`; optional Code Interpreter (Python-Sandbox, ersetzt keinen Projekt-Test); vier Testfragen, Create erst nach bestandenem Test oder bewusster Entscheidung trotz Mangel; Fallback nur im Chat. Die Person legt den Agent selbst an.
- ANLEITUNG neu §3.5 Microsoft 365 Copilot (bisher §3.5 API wird §3.6); Hinweise in README, `prompts/import.md` und `llms.txt`.
- Keine Regeländerung im Manifest.

## 1.3.1 · 2026-11-23

- CONTRIBUTING: Die Tabelle **Releasenotes** in der README zu pflegen ist bei jeder neuen Version Pflicht; nach dem Merge wird der Tag `v<Version>` gesetzt.
- Keine Regeländerung im Manifest.

## 1.3.0 · 2026-11-23

- Neu §5.5 **Rechte und Werkzeuge**: Rechte als Allowlist und per echtem Lauf prüfen; ein Verbot sperrt den ganzen Aufruf (ein Befehl je Aufruf, bei Ablehnung aufteilen); Werkzeugsatz je Modellfamilie prüfen; Schutz im Werkzeug statt nur im Prompt (aufgelöste Pfade, maschineller Abgleich). Aus L-027, L-028, L-029, L-031, L-033, L-035.
- Neu §7.3 **Abbrechbare Läufe**: Checkpoint mit Lückenliste, atomarer Austausch mit Abbruchtests, Fortsetzung in frischer Session, Endabgleich gegen die Quelle. Aus L-030, L-033, L-034.
- Neu §6.1 **Prüfungen selbst prüfen**: verfälschte Eingaben, Zahl geprüfter Fälle, Testfall eingetreten. Aus L-026, L-030, L-034.
- Neu §6.2 **Daten nicht durch das Modell kopieren**: direkter Weg vom Werkzeug in die Datei, Quittung mit Objektzahl. Aus L-032.
- Ergänzt §2 (Budgets und Kontingente in der Umgebungsprobe, L-024) und §5.2 (abweichendes Ausgabeformat ausdrücklich nennen, L-025; Werkzeuge im Brief, L-029).
- L-021 bis L-023 bleiben `neu` (einmalig und werkzeugspezifisch).
- README: neuer Abschnitt **Releasenotes** mit Versionsübersicht und Lesehilfe zu Versionsnummern.

## 1.2.1 · 2026-11-21

- Neu: Import-Prompt `prompts/import.md`. Ein Agent richtet The Swarm damit selbst ein: Er erkennt das Werkzeug, fragt nach Geltungsbereich und Variante, ergänzt die Anweisungsdatei ohne Duplikate, prüft und berichtet.
- Kurzform per URL in README, ANLEITUNG (§3.0) und llms.txt; Fehlerbehebung für Agents, die Webinhalten nicht folgen.
- Keine Regeländerung.

## 1.2.0 · 2026-11-21

- Neu §5.1: Rolle **Expertin / Experte** für Fachaufgaben (z. B. 3D-Modellierung, Video- und Audiobearbeitung, Grafik, anspruchsvolle Algorithmen), delegiert an das größte, leistungsfähigste verfügbare Modell. Die Faustregel ist um das nötige Fachwissen ergänzt.
- Neu §5.1.1: Wann die Expertenrolle eingesetzt wird; Klärung von Werkzeugen, Rechenleistung, Material und Rechten; messbare Abnahmekriterien; Prüfung über Messwerte und Vorschauen; reproduzierbare Abgabe.
- Neu: Brief-Vorlage für die Expertenrolle in `playbooks/agent-brief.md`; ANLEITUNG ergänzt.

## 1.1.1 · 2026-11-21

- Repo heißt jetzt **The Swarm** (`diren89/The-Swarm`; GitHub erlaubt keine Leerzeichen im Repo-Namen). Alle Verweise sind angepasst. Die früheren Namen `agent-manifest` und `Beehive` leiten auf GitHub weiter.
- Neu: [ANLEITUNG.md](ANLEITUNG.md) zu Installation (global, pro Projekt, Claude Code, Codex CLI, Gemini CLI, Cursor, Copilot, API), Nutzung, Beiträgen, Versionen, Fehlerbehebung.
- Keine Regeländerung.

## 1.1.0 · 2026-11-21

- Neu §0: Die Arbeitsweise ist Default für alle Code-Projekte. Abweichungen nur durch Anweisung, Projektregeln oder fehlende Plattformwerkzeuge.
- Neu §0.1: Skalierung nach Aufgabengröße (S/M/L) mit Pflichten je Stufe, damit kleine Aufgaben keinen Overhead bekommen.
- Neu §0.2: Verankerung über die globale Agenten-Konfiguration statt pro Projekt.
- README, AGENTS.md, CLAUDE.md, llms.txt entsprechend angepasst.

## 1.0.0 · 2026-11-21

- Erste Fassung: Grundsätze, Planung, Phasen, Effizienz, Subagents und Modellwahl, Qualität und Tokens, fünf Prüfschichten, Hardware-Anpassung, Lernschleife, Wissensaustausch zwischen Instanzen.
- Learnings L-001 bis L-020 aus einer mehrphasigen App-Entwicklung mit zwölf Subagents.
- Vorlagen für Agent-Brief, Prüfer und Phasen-Retrospektive; read-only Umgebungsprobe.
