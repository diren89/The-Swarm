# Beispiel-Rollen für Claude Code

Optional, nur ein Beispiel. Überblick, Platzhalter und Grenzen: [../README.md](../README.md). Status: **teilweise erprobt.** Git-Sperren erprobt (Claude Code 2.1.285, Projektordner mit diesen Agent-Dateien und `settings.json`): Subagent `implementer` lief, `git status` ausgeführt, `reset --hard`, `clean -fd`, `branch -D`, `push` vom Werkzeug abgelehnt, auch bei allgemein erlaubtem `Bash`; Repo danach unverändert. Übrige Rollen und Modellzuweisung nicht einzeln geprüft.

## Dateien und Ziel

| Datei hier | Ziel |
|---|---|
| `agents/<id>.md` (7) | `~/.claude/agents/<id>.md` (global) oder `.claude/agents/<id>.md` (Projekt) |
| `CLAUDE.md.ausschnitt` | Koordinator-Text: am Ende von `~/.claude/CLAUDE.md` bzw. der Projekt-`CLAUDE.md` ergänzen (der Koordinator ist die Hauptsitzung, kein Agent) |
| `settings.json.ausschnitt` | Git-Sperren: in `~/.claude/settings.json` unter `permissions.deny` zusammenführen (nur nach Diff und Freigabe) |
| `settings.hooks.json.ausschnitt` + `hooks/*.sh` (optional) | zwei Hook-Gates, siehe [Optionale Hooks](#optionale-hooks): Ausschnitt in `.claude/settings.json` des Projekts (oder `~/.claude/settings.json`) unter `hooks` zusammenführen, Skripte nach `.claude/hooks/` kopieren |
| `../gemeinsam/skill-orchestrierung/` | `~/.claude/skills/orchestrierung/` (oder `.claude/skills/orchestrierung/`) |
| `../gemeinsam/skill-fremd-review/` (optional, nicht erprobt) | `~/.claude/skills/fremd-review/` (oder `.claude/skills/fremd-review/`) |

Vorhandene Dateien gleichen Namens nicht überschreiben.

## Aufbau einer Agentdatei

YAML-Kopf mit nur dokumentierten Feldern (`name`, `description`, `tools`, `disallowedTools`, `model`, `maxTurns`, `skills`), darunter der Rollentext. Claude Code **ignoriert unbekannte Felder still**; deshalb keine Felder wie `mode`, `steps`, `permissions`, `color`.

- **Modell:** `# model:` auskommentiert; ohne Zeile erbt der Agent das Modell der Hauptsitzung. Alias oder Modell-ID einsetzen.
- **Werkzeuge (`tools`, Allowlist):** `Agent` steht **nur** bei `coordinator-code` und `implementer`; so können nur diese weitere Subagents starten. `reviewer`: `Read, Grep, Glob, Bash, WebSearch, WebFetch` plus `disallowedTools: Edit, Write`. `researcher`, `scout`: ohne `Bash`, ohne Schreibwerkzeuge. `editor-lite`: `Edit` und `Bash`. `skill-master`: `Read, Grep, Glob, Edit, Write, Bash, WebFetch`, kein `Agent`; **die Pfadgrenzen (nur Skill-Ordner, Katalog, Lock, `.agent/work/`) und die Beschränkung auf Skills-CLI, Statusskript und lesendes Git sind nur vereinbart (Anweisung), nicht gesperrt.**
- **Schrittlimit:** `maxTurns` (`implementer` 50, `skill-master` 40, `reviewer` 30, `researcher` 30, `scout` 20, `editor-lite` 25).
- **Git-Sperren: global, nicht je Agent.** `disallowedTools` mit einem Bash-Muster (`Bash(git push *)`) würde Bash ganz entziehen. Deshalb steht `permissions.deny` in `settings.json` und gilt für Haupt- und Subagents; `deny` hat Vorrang vor `ask` und `allow`. Folge: Auch die Hauptsitzung kann nicht pushen, bis die Zeile entfernt wird. Wer das nicht will, setzt die Muster in `ask` um.
- **Grenzen:** Bash-Muster sind keine harte Grenze (z. B. `git -C <ordner> push`); stärker durchsetzen mit Sandbox oder Hook. Der Schreibschutz des `reviewer` sperrt `Edit` und `Write`, nicht Schreiben per Shell. Das nennt der Plan als „nur vereinbart“.
- **Tiefe:** nicht per Feld einstellbar; Claude Code begrenzt sie zur Laufzeit. Die Kette vor dem ersten Einsatz mit einem Probeauftrag durchlaufen.

## Skills

Quelle: https://code.claude.com/docs/en/skills (abgerufen 2026-11-25). Skill-Ordner: global `~/.claude/skills/<name>/`, Projekt `.claude/skills/<name>/` (auch in Elternordnern bis zur Repo-Wurzel).

- **Ausblenden:** im Kopf der `SKILL.md` `disable-model-invocation: true`: die Beschreibung steht dann nicht im Kontext, der Skill wird erst geladen, wenn die Nutzerin `/name` aufruft. Alternativ `skillOverrides` in den Settings (z. B. `"user-invocable-only"`, `"off"`), ohne die Datei zu ändern. `description` und `when_to_use` werden im Listing auf 1 536 Zeichen gekürzt.
- **Rechte:** Permission-Regeln `Skill(name)` bzw. `Skill(name *)` in den Settings (`allow`, `ask`, `deny`); `deny` sperrt. Sie gelten für Haupt- und Subagents gemeinsam, **nicht je Agent**. Das Agent-Feld `skills` lädt Skills vorab in den Kontext; der `skill-master` setzt es nicht (er liest Skills als Dateien).
- **Neu laden:** Änderungen an einer `SKILL.md` werden live erkannt; fehlt ein neuer Skill, hilft `/reload-skills`.
- **Grenze:** Pfadgrenzen und Netz des `skill-master` sind nur vereinbart. Wer sie durchsetzen will, nutzt Sandbox oder einen Hook (siehe unten); das Beispiel enthält keinen.

## Prüfer anderer Familie

**Nicht erzwingbar.** Subagents nutzen nur Modelle des Anbieters der Hauptsitzung; ein Feld für einen anderen Anbieter gibt es nicht. Der Koordinator-Text weist die Nutzerin einmal darauf hin und nennt die Einschränkung im Plan. Möglicher Umweg, nicht fest eingebaut: den `reviewer` die Kommandozeile eines anderen Anbieters im Lesemodus per Bash aufrufen lassen (Befehl `<FREMD_CLI_PRUEFBEFEHL>`, falls installiert und gewollt; Ablauf, Rechte und Kosten im optionalen Skill [`fremd-review`](../gemeinsam/skill-fremd-review/SKILL.md), nicht erprobt). Ohne ihn prüft ein unabhängiger Prüfer derselben Familie, und der Plan nennt die Einschränkung.

## Prüfen

1. Modellzeilen anpassen, Dateien kopieren, `settings.json`-Diff freigeben.
2. [Probe `git-sperren.md`](../probe/git-sperren.md) mit dem `implementer`.
3. Wirksame Rechte der übrigen Rollen bei Bedarf mit einem echten Lauf prüfen.

## Optionale Hooks

**Optional, nur ein Beispiel, nicht Teil der Rollen.** Zwei eng begrenzte Gates als Hook (Skript, das das Werkzeug an einem Ereignis aufruft). Hooks sind eine Ergänzung zu Rechten und Sandbox, kein Ersatz: Regeln, die nur im Text stehen, sind keine Grenze (§5.5), ein Hook ist eine, aber nur im Rahmen seiner Muster.

**Vor dem Einbau lesen.** Ein Hook läuft **mit den Rechten der Nutzerin** (Shell, Dateien, Zugänge) bei jedem passenden Ereignis. Die beiden Skripte sind kurz und nutzen nur `bash`, `git`, `grep`, `sed`, `tr`, `head`, `tail`, `wc`, `mktemp`; sie laden nichts nach und greifen nicht aufs Netz zu. Trotzdem: Skripte und Ausschnitt lesen, bevor sie aktiv werden.

### Dateien

| Datei | Zweck |
|---|---|
| `hooks/geheimnis-scan-vor-commit.sh` | Gate A (Ereignis `PreToolUse`, Matcher `Bash`) |
| `hooks/pruefung-bei-sitzungsende.sh` | Gate B (Ereignis `Stop`) |
| `settings.hooks.json.ausschnitt` | `hooks`-Block für `settings.json` (bewusst eine eigene Datei, damit `settings.json.ausschnitt` mit den Git-Sperren unberührt bleibt) |

### Einbau

1. Skripte nach `.claude/hooks/` des Projekts kopieren (`chmod +x`; der Ausschnitt ruft sie mit `bash` auf). Der Pfad `${CLAUDE_PROJECT_DIR}` ist der Projektordner der Sitzung.
2. `hooks`-Block aus `settings.hooks.json.ausschnitt` in die `settings.json` **zusammenführen, nicht überschreiben**; vorhandene Hooks bleiben. Wie bei `settings.json.ausschnitt`: erst Diff zeigen, nach Freigabe zusammenführen (der Import-Agent tut das nicht selbst). Projektlokal (`.claude/settings.json`) ist der engere, empfohlene Einstieg.
3. Für Gate B optional den Prüfbefehl des Projekts setzen, z. B. `export THE_SWARM_PRUEFBEFEHL="bash tools/pruefen.sh"` (Umgebung der Nutzerin, vor dem Start der Sitzung). Ohne Variable listet Gate B nur.
4. In einer neuen Sitzung einmal beide Gates mit einem Wegwerf-Repo ausprobieren (Negativfall muss blockieren, Positivfall durchgehen) und im Werkzeug mit `/hooks` ansehen, welche Hooks geladen sind. Ein Tippfehler im Pfad bedeutet: der Hook läuft nie.

### Die zwei Gates

| | Gate A: Geheimnis-Scan vor Commit | Gate B: Prüfung bei Sitzungsende |
|---|---|---|
| Ereignis | `PreToolUse`, Matcher `Bash` | `Stop` |
| Greift bei | Bash-Befehl mit `git commit` (auch nach `;`, `&&`, einer Pipe, in Klammern oder `$( )`; `git commit-tree` und `git log --grep commit` zählen nicht; alles andere: Exit 0, keine Ausgabe) | jedem Ende einer Antwort, wenn `git status --porcelain` Einträge zeigt |
| Wirkung | **blockierend**: Exit 2, Meldung (Datei und Art des Treffers, nie der Wert) auf stderr geht an Claude | **warnend**: immer Exit 0; Liste und Ergebnis als `systemMessage` an die Nutzerin; hält Claude nicht auf |
| Prüft | `git diff --cached` **und immer auch** die noch nicht vorgemerkten Änderungen verfolgter Dateien (`git diff`), weil ein Commit mit Pfad (`git commit -- datei`, `git commit datei`, `-o`/`--only`, `-i`/`--include`) oder `-a` deren Arbeitsbaum-Inhalt übernimmt, nicht den Index; das prüft eher zu viel als zu wenig (ein Geheimnis in einer ungestagten, nicht mitcommitteten Änderung blockiert ebenfalls). Bei `git add …` oder `--all`/`-a` im selben Befehl zusätzlich neue, unverfolgte Dateien. Gesucht wird nach: Kopf eines privaten Schlüssels, `AKIA`/`ASIA`-Kennungen, Token-Präfixe (`ghp_`, `github_pat_`, `xox…-`, `AIza…`, `sk-…`), JSON Web Token, Zugangsdaten in Adressen (Benutzer und Kennwort vor dem `@`), Zuweisungen mit Namen wie `password`, `secret`, `api_key`, `access_key`, `auth_token` (Zeichen `=` oder `:`) mit Wert ab 8 Zeichen | listet geänderte Dateien (höchstens 15 Zeilen), führt `THE_SWARM_PRUEFBEFEHL` aus (Standard: leer, nur Hinweis); bei Exit ≠ 0 Warnung mit den letzten 15 Ausgabezeilen |
| Bei Ausfall | **fail-closed**: fehlt `git`, schlägt eine Git-Abfrage des Skripts fehl (Exit ≠ 0, z. B. beschädigter Index; jede Abfrage wird einzeln geprüft), ist der Zielordner unklar (`cd`, `-C`, `--git-dir`, `--work-tree` im Befehl) oder bricht das Skript unerwartet ab, wird der Commit blockiert. Begründung: ein stiller Fehler würde genau den Fall durchlassen, den das Gate verhindern soll; ein Commit lässt sich nach Behebung wiederholen. Übersteuern: Zeile mit `geheimnis-scan:ok` markieren (Falsch-Positiv) oder die Nutzerin setzt `THE_SWARM_GEHEIMNIS_SCAN=aus` vor dem Start. Fällt der **Hook selbst** aus (Skript fehlt, Zeitüberschreitung), blockiert nur `"onFailure": "block"` (im Ausschnitt gesetzt; nach der Dokumentation ab Claude Code 2.1.295, in älteren Versionen wird das Feld ignoriert und der Commit läuft durch) | **fail-open**: fehlt `git`, kein Repo, Fehler im Skript oder Zeitüberschreitung: die Sitzung endet wie ohne Hook (immer Exit 0; `onFailure` bleibt ungesetzt) |
| Schleifenschutz | nicht nötig (blockiert einen Aufruf, keine Fortsetzung) | endet sofort mit Exit 0, wenn die Eingabe `stop_hook_active: true` enthält; blockiert nie. Das Werkzeug begrenzt aufeinanderfolgende Fortsetzungen durch Stop-Hooks zusätzlich |
| Grenzen | Mustersuche findet nicht alles (unbekannte Formate, verschlüsselte oder codierte Werte, Geheimnisse in Binärdateien, kurze Passwörter, Umbenennungen) und meldet auch Harmloses. Erkennt `git commit` im Befehlstext; Umwege (z. B. Skript, das committet, oder ein Alias) sieht sie nicht. Prüft nur den Ordner, in dem der Hook läuft. Kein Ersatz für die Veröffentlichungsprüfung ([playbooks/sicherheit.md](../../playbooks/sicherheit.md)) und keine Hilfe gegen schon früher committete Geheimnisse | Gibt nur Hinweise. Ein Prüfbefehl läuft bei **jedem** Antwortende mit Änderungen: schnell halten (Zeitgrenze `timeout` im Ausschnitt, 120 s). Prüft die Wirkung nicht (ein grüner Befehl sagt nur, was der Befehl prüft). Der Befehl kommt aus der Umgebung der Nutzerin, nie aus dem Hook-Eingabe-JSON |
| Status | siehe unten | siehe unten |

Das Muster, das ein `git commit` im Befehl erkennt, und die Geheimnis-Muster stehen am Anfang des Skripts und lassen sich dort anpassen. Die Muster sind so geschrieben, dass das Skript sich nicht selbst blockiert, wenn es committet wird.

### Format, Quelle und Status

- **Quelle:** https://code.claude.com/docs/en/hooks, abgerufen am 2026-11-25. Dort geprüft: Ereignisnamen `PreToolUse` und `Stop`; `matcher` (`Bash` = Werkzeugname; `Stop` kennt keinen Matcher); Handler `"type": "command"` mit `command`, `timeout` (Sekunden), `statusMessage`, `onFailure` (`continue` oder `block`, ab 2.1.295); Eingabe als JSON auf stdin (`tool_input.command`, bei `Stop` `stop_hook_active`); Exit 0 = Erfolg, **Exit 2 = blockierender Fehler** (stderr ist die Begründung, bei `PreToolUse` wird der Aufruf blockiert), jeder andere Exit = nicht blockierender Fehler (die Aktion läuft weiter); bei `Stop` bedeutet Exit 2 oder `decision: "block"` „weiterarbeiten“, deshalb ist Gate B warnend und endet immer mit 0; `systemMessage` als JSON-Feld zeigt der Nutzerin eine Warnung.
- **Gate A:** erprobt in Claude Code 2.1.285 in einem Wegwerf-Repo (nur projektlokal): Commit mit einer Datei mit offensichtlich unechtem Geheimnis wurde vom Hook blockiert (Meldung kam bei Claude an, es entstand kein Commit), ein harmloser Commit lief durch; dazu 37 Skript-Tests mit simuliertem stdin-JSON (Negativ-, Positiv- und Ausfallfälle: Trenner nach `commit`, Pfad-Commits mit Geheimnis nur im Arbeitsbaum, simulierter Git-Fehler → Exit 2, `git` nicht auffindbar → Exit 2, keine Fehlalarme bei `git log --grep commit` und `git commit-tree`). Nicht geprüft: `onFailure: "block"` (die installierte Version ist älter als 2.1.295; mit fehlendem Skript lief der Commit durch, wie für ältere Versionen dokumentiert), Windows, andere Shells als bash.
- **Gate B:** erprobt in derselben Version: der Hook lief am Antwortende (`hook_response`, Exit 0, `outcome: success`), `systemMessage` mit Liste und „Prüfbefehl ausgeführt, Exit 0“ kam an; Skript-Tests: Prüfbefehl mit Exit 3 → Warnung, Exit 0; `stop_hook_active: true` → keine Ausgabe, Exit 0; nichts geändert oder kein Repo → keine Ausgabe. Nicht geprüft: Fortsetzungsverhalten bei Fehlern des Skripts, langlaufende Prüfbefehle bis zur Zeitgrenze.
- Der Ausschnitt ist ein Beispiel, kein Standard. Hooks in anderen Werkzeugen: [opencode/README.md](../opencode/README.md#hooks), [codex/README.md](../codex/README.md#hooks).
