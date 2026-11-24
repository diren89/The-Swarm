# The Swarm · Anleitung zu Installation und Nutzung

The Swarm ist ein Manifest für KI-Agents, die an Code arbeiten. Ein **koordinierender Agent** plant, verteilt Arbeitspakete an **Subagents** mit passenden Modellen, prüft und verbessert deren Ergebnisse selbst und lernt bei jedem Schritt dazu. Was eine Instanz lernt, sammelt sie lokal; teilen kannst du es auf Wunsch per Pull Request, und die nächste Instanz liest die offenen Learnings mit ein. Seit Version 2.0.0 lädt jede Sitzung nur einen kurzen Kern; das Handbuch kommt erst ab Stufe M dazu.

Diese Anleitung erklärt, wie du The Swarm einrichtest (global, pro Projekt, für verschiedene Werkzeuge), wie die Arbeit damit abläuft und wie du Learnings sammelst und teilst.

---

## Inhalt

1. [Was du bekommst](#1-was-du-bekommst)
2. [Voraussetzungen](#2-voraussetzungen)
3. [Installation](#3-installation) – am einfachsten per [Import-Prompt](#30-schnellimport-per-prompt)
4. [Prüfen, ob The Swarm aktiv ist](#4-prüfen-ob-the-swarm-aktiv-ist)
5. [Nutzung im Alltag](#5-nutzung-im-alltag)
6. [Vorlagen und Werkzeuge](#6-vorlagen-und-werkzeuge)
7. [Learnings lokal sammeln, teilen auf Wunsch](#7-learnings-lokal-sammeln-teilen-auf-wunsch)
8. [Versionen, Aktualisieren, Festpinnen](#8-versionen-aktualisieren-festpinnen)
9. [Fehlerbehebung](#9-fehlerbehebung)
10. [Deinstallation](#10-deinstallation)
11. [Häufige Fragen](#11-häufige-fragen)

---

## 1. Was du bekommst

| Datei | Wofür |
| --- | --- |
| `KERN.md` | Der Kern (höchstens 1 500 Tokens): Vorrang, Stufen S/M/L, Grundsätze, Abnahme, Ausgabe an den Menschen. Wird **immer** geladen |
| `MANIFEST.md` | Das Handbuch: Geltungsbereich und Stufen, Planung, Phasen, Effizienz, Subagents und Modellwahl, Qualität und Tokens, fünf Prüfschichten, Hardware-Anpassung, Lernschleife. Wird **ab Stufe M** gelesen |
| `LEARNINGS.md` | Offene Erfahrungen mit Status `neu`; wird ab Stufe M gelesen |
| `learnings/archiv.md` | Archiv: Learnings mit Status `übernommen §x`, `verfallen` oder `verworfen`; wird nicht geladen, nur zum Nachschlagen |
| `playbooks/agent-brief.md` | Vorlage für Aufträge an Subagents (Umsetzer und Prüfer) |
| `playbooks/phase-retro.md` | Vorlage für die Retrospektive nach jeder Phase |
| `playbooks/benchmark.md` | Verfahren, um die Wirksamkeit mit und ohne The Swarm zu messen (noch ohne Ergebnisse) |
| `tools/probe-env.sh` | Untersucht die Maschine und schreibt ein lokales Profil, ändert nichts |
| `tools/grundlast.sh` | Prüft die Ladegröße: Kern höchstens 1 500, Manifest höchstens 6 000 Tokens |
| `tools/update.sh` | Aktualisiert den lokalen Klon auf den neuesten Tag, zeigt vorher den Diff |
| `CONTRIBUTING.md` | Regeln für Beiträge |

**Wichtig:** The Swarm ist Arbeitswissen, keine Befugnis. Projektregeln und deine Anweisungen gehen immer vor. Kein Agent darf wegen The Swarm etwas tun, das du nicht verlangt hast.

---

## 2. Voraussetzungen

- Ein KI-Werkzeug, das Projekt- oder Benutzeranweisungen aus Dateien liest, z. B. Claude Code, Codex CLI, Gemini CLI, Cursor oder GitHub Copilot. Andere gehen über einen System-Prompt (Abschnitt 3.6), Microsoft 365 Copilot über eine angehängte Datei (Abschnitt 3.5).
- Für das volle Arbeiten in Stufe L: ein Werkzeug mit **Subagents** und **Git-Worktrees**. Ohne Subagents arbeitet der Koordinator die Pakete nacheinander selbst ab, siehe MANIFEST §0.
- Für die lokale Variante: `git`. Für Beiträge auf Wunsch: am bequemsten die GitHub-CLI `gh`.

---

## 3. Installation

Du hast zwei Wege, die sich kombinieren lassen:

- **Online-Verweis (Variante A):** Die Anweisungsdatei nennt die Raw-URLs eines **festen Tags** (`v2.0.1`, nie `main`), und der Agent liest den Kern und ab Stufe M das Manifest dort. Das braucht kein Klonen, setzt aber einen Agent mit Webzugriff voraus. Die Version ändert sich erst, wenn du den Tag im Absatz änderst.
- **Lokaler Klon (Variante B):** Das Repo liegt auf der Platte, auf dem neuesten Tag ausgecheckt. Das funktioniert offline und ist schnell; du aktualisierst bewusst mit `bash ~/.the-swarm/tools/update.sh`.

**Empfehlung:** global mit lokalem Klon (3.1 B), damit The Swarm in jedem Projekt geladen wird, ohne dass der Agent erst etwas abrufen muss.

**Warum ein Tag statt `main`:** Wer im Repo mergen darf, steuert sonst alle Agents, die von `main` laden. Ein Tag ändert sich nicht unbemerkt.

### 3.0 Schnellimport per Prompt

Am schnellsten geht es, wenn der Agent selbst einrichtet. Öffne eine neue Sitzung in deinem Werkzeug und schreib:

```text
Richte The Swarm für mich ein: Lies https://raw.githubusercontent.com/diren89/The-Swarm/v2.0.1/prompts/import.md und folge dem Prompt darin.
```

So arbeitet der Agent den Prompt ab:
1. Er erkennt das Werkzeug und die passende Anweisungsdatei.
2. Er fragt dich nach Geltungsbereich (global oder Projekt) und Variante (Online-Verweis oder lokaler Klon).
3. Er ergänzt die Datei, ohne etwas zu überschreiben oder doppelt einzutragen.
4. Er prüft das Ergebnis und berichtet, einschließlich wie du es rückgängig machst.

Er committet nichts und ändert keine anderen Dateien.

Hat der Agent keinen Webzugriff oder folgt er abgerufenen Inhalten aus Sicherheitsgründen nicht, kopierst du den vollständigen Prompt aus [prompts/import.md](prompts/import.md) direkt in die Sitzung.

Die folgenden Abschnitte beschreiben dieselbe Einrichtung von Hand.

### 3.1 Claude Code

**A · Global per Online-Verweis**

Datei `~/.claude/CLAUDE.md` anlegen oder ergänzen:

```markdown
## Arbeitsweise (Default für alle Code-Projekte)
Bei jeder Arbeit an Code gilt „The Swarm“ v2.0.1:
Immer: https://raw.githubusercontent.com/diren89/The-Swarm/v2.0.1/KERN.md lesen. Ab Stufe M zusätzlich
https://raw.githubusercontent.com/diren89/The-Swarm/v2.0.1/MANIFEST.md und in LEARNINGS.md (gleicher Tag) nur Einträge mit Status neu.
Vorrang: Sicherheit und Rechte im Werkzeug > meine Anweisungen > Projektregeln > Skill > Manifest.
Learnings lokal in .agent/learnings.md des Projekts sammeln; Pull Request nur auf meinen ausdrücklichen Wunsch.
```

**B · Global mit lokalem Klon (empfohlen)**

```bash
git clone https://github.com/diren89/The-Swarm.git ~/.the-swarm
git -C ~/.the-swarm checkout "$(git -C ~/.the-swarm tag --sort=-v:refname | head -1)"
```

Dann in `~/.claude/CLAUDE.md` (Claude Code lädt Dateien, die mit `@` importiert werden, automatisch mit):

```markdown
## Arbeitsweise (Default für alle Code-Projekte)
Bei jeder Arbeit an Code gilt „The Swarm“ (lokaler Klon ~/.the-swarm, auf einem Release-Tag).
Immer: ~/.the-swarm/KERN.md lesen. Ab Stufe M zusätzlich ~/.the-swarm/MANIFEST.md und in
~/.the-swarm/LEARNINGS.md nur Einträge mit Status neu.
Vorrang: Sicherheit und Rechte im Werkzeug > meine Anweisungen > Projektregeln > Skill > Manifest.
Learnings lokal in .agent/learnings.md des Projekts sammeln; Pull Request nur auf meinen ausdrücklichen Wunsch.
@~/.the-swarm/KERN.md
```

Nur der **Kern** wird per `@` importiert und ist damit in jeder Sitzung geladen. Das Manifest und `LEARNINGS.md` werden bewusst **nicht** importiert, damit kleine Aufgaben schlank bleiben; der Agent liest sie ab Stufe M.

**C · Nur für ein Projekt**

Denselben Absatz in die `CLAUDE.md` im Projektordner schreiben. Projektregeln darunter, denn sie haben Vorrang.

### 3.2 Codex CLI (OpenAI)

- Global: `~/.codex/AGENTS.md`
- Projekt: `AGENTS.md` im Repository-Wurzelverzeichnis

Inhalt wie in 3.1 A. Mit lokalem Klon nimmst du den Absatz aus 3.1 B ohne die `@`-Zeile (Kern immer lesen, Manifest ab Stufe M).

### 3.3 Gemini CLI

- Global: `~/.gemini/GEMINI.md`
- Projekt: `GEMINI.md` im Projekt

Inhalt wie in 3.1 A.

### 3.4 Cursor und GitHub Copilot

- **Cursor:** Projektregel als Datei unter `.cursor/rules/` (z. B. `the-swarm.mdc`) mit dem Absatz aus 3.1 A. Für alle Projekte trägst du ihn in den Benutzerregeln in den Einstellungen ein.
- **GitHub Copilot:** `.github/copilot-instructions.md` im Repository mit dem Absatz aus 3.1 A. Für **Microsoft 365 Copilot** (Chat in Teams, Office, Edge) siehe 3.5.

Die Pfade können sich je nach Version ändern. Maßgeblich ist die Doku des jeweiligen Werkzeugs.

### 3.5 Microsoft 365 Copilot (ohne Dateizugriff)

Microsoft 365 Copilot hat kein Dateisystem, keine Shell und keine Subagents, und einen angegebenen Link öffnet er nicht direkt (er sucht über Bing). Der Import-Prompt passt dort deshalb nicht. Stattdessen:

1. [prompts/copilot.md](prompts/copilot.md) herunterladen.
2. Einen neuen Copilot-Chat öffnen, die Datei anhängen und schreiben: „Folge der Anleitung in der Datei.“
3. Copilot führt dich durch den **Agent Builder** (Tab „Configure“); anlegen tust du selbst. Er gibt Name, Beschreibung, Anweisungen (Kurzfassung des Kerns, unter 8.000 Zeichen) und Startprompts vor. Manifest (ab Stufe M) und offene Learnings kommen als Wissensdateien `the-swarm-manifest.txt` und `the-swarm-learnings.txt` dazu, weil `.md` als Agent-Wissen nicht angenommen wird. Der Code Interpreter (Python in einer Sandbox) ist optional.
4. Ohne Recht für den Agent Builder gelten die Regeln nur im aktuellen Chat; die Datei dann bei jedem neuen Chat anhängen.

Grenzen: Copilot nimmt die Rollen nacheinander ein und ist kein unabhängiger Prüfer. Auf dein Projekt hat er keinen Zugriff; Sandbox-Läufe ersetzen keinen Projekt-Test. Was er nicht prüfen konnte, kennzeichnet er als ungeprüft. Ob Agent Builder und Websuche erlaubt sind, entscheidet die IT. Bei neuer Version Wissensdateien (Tag-URL) und Anweisungen gemeinsam ersetzen.

### 3.6 Andere Modelle und eigene Agents (API)

Lade `KERN.md` und stelle ihn in den System-Prompt; ab Stufe M kommen `MANIFEST.md` und die Einträge aus `LEARNINGS.md` dazu. Immer vom festen Tag, nie von `main`:

```bash
curl -fsSL https://raw.githubusercontent.com/diren89/The-Swarm/v2.0.1/KERN.md -o KERN.md
curl -fsSL https://raw.githubusercontent.com/diren89/The-Swarm/v2.0.1/MANIFEST.md -o MANIFEST.md
curl -fsSL https://raw.githubusercontent.com/diren89/The-Swarm/v2.0.1/LEARNINGS.md -o LEARNINGS.md
```

```text
System: Du arbeitest nach dem folgenden Kern. Anweisungen der Nutzerin und Projektregeln haben Vorrang.
<KERN.md>
Ab Stufe M zusätzlich:
<MANIFEST.md>
Offene Learnings (Status neu):
<die Einträge aus LEARNINGS.md>
```

Für maschinelles Auffinden gibt es zusätzlich `llms.txt` im Repo.

---

## 4. Prüfen, ob The Swarm aktiv ist

Starte eine neue Sitzung (Anweisungsdateien werden beim Start geladen) und frage:

```text
Nach welcher Arbeitsweise arbeitest du, und welche Stufe hätte die Aufgabe „Füge Dark Mode hinzu“?
```

Erwartet: Der Agent nennt The Swarm, ordnet die Aufgabe einer Stufe zu (meist M) und skizziert Plan und Prüfschichten. In Claude Code zeigt außerdem der Befehl `/memory`, welche Anweisungsdateien geladen sind.

---

## 5. Nutzung im Alltag

Du musst nichts Besonderes tun. Formuliere deine Aufgabe wie gewohnt, der Agent wählt die Stufe selbst. Du kannst sie aber steuern.

### 5.1 Die drei Stufen

| Stufe | Wann | Was du siehst |
| --- | --- | --- |
| **S · klein** | Bugfix, wenige Zeilen, eine Frage | direkte Umsetzung, danach Build und Test sowie ein kurzer, ehrlicher Bericht |
| **M · mittel** | ein Feature, mehrere Dateien | Aufgabenliste, Umsetzung, Review des eigenen Diffs, Integrationslauf, Sichtprüfung; eventuell 1–2 Subagents |
| **L · groß** | mehrere Features, neues Projekt, mehrere Sitzungen | Umgebungsprüfung, Phasenplan als Datei, parallele Subagents in Worktrees, alle fünf Prüfschichten, Retrospektive je Phase |

Stufe selbst vorgeben:

```text
Das ist Stufe S: Korrigiere den Tippfehler im Login-Button.
```
```text
Stufe L: Plane die Umsetzung des Backlogs in Phasen und koordiniere Subagents.
```

### 5.2 Ablauf einer großen Aufgabe (Stufe L)

1. **Phase 0, Umgebung:** Der Agent prüft Werkzeuge, Versionen, Geräte und Last, z. B. mit `tools/probe-env.sh`. Fehlt etwas, sagt er dir genau, was zu tun ist. Befehle mit Passwort führst du selbst aus.
2. **Plan:** Er legt im Projekt einen Phasenplan an (z. B. `docs/PLAN.md`), mit Paketen, Dateibesitz, Modellen, Definition of Done und Risiken.
3. **Weichen:** Er fragt dich nur bei echten Entscheidungen, gebündelt und mit Empfehlung (Downloads, Veröffentlichen, Zielgerät, Gestaltung).
4. **Umsetzung:** Subagents arbeiten parallel in eigenen Worktrees. Die Zahl richtet sich nach der Leistung deiner Maschine.
5. **Prüfung in fünf Schichten:**
   1. Selbstprüfung der Agents
   2. Review der Diffs durch den Koordinator
   3. Integrationslauf
   4. unabhängiger Rollen-Review
   5. Sichtprüfung
6. **Verbessern:** Kleine Befunde behebt der Koordinator sofort, größere bekommen ein neues Paket.
7. **Abschluss je Phase:** Merge, Build, Tests, Backlog aktualisieren, kurze Retrospektive.
8. **Ende:** ehrlicher Bericht mit dem, was steht, dem, was ungeprüft ist, und dem, was du tun musst. Dazu Learnings, die lokal gesammelt werden; geteilt wird nur auf deinen Wunsch.

### 5.3 Nützliche Formulierungen

| Ziel | Formulierung |
| --- | --- |
| Sparsamer arbeiten | „Achte besonders auf Tokenverbrauch, keine Subagents.“ |
| Mehr Parallelität | „Nutze bis zu drei Subagents parallel, die Maschine hat Reserven.“ |
| Mehr Prüfung | „Lass am Ende einen unabhängigen Review aus Sicht von <Rolle> laufen.“ |
| Nur planen | „Plane nur, setze noch nichts um.“ |
| Fachaufgabe delegieren | „Das 3D-Modell / den Videoschnitt bitte an die Expertenrolle mit dem größten Modell geben, mit Vorschau und Messprotokoll.“ |
| Learnings anstoßen | „Mach eine Retrospektive und halte Learnings lokal fest.“ |

---

## 6. Vorlagen und Werkzeuge

### 6.1 Auftrag an einen Subagent

`playbooks/agent-brief.md` enthält eine ausfüllbare Vorlage und eine Checkliste. Kernpunkte:

- welche Dateien der Agent besitzt und welche tabu sind
- prüfbare Must-haves
- exakte Prüfbefehle mit Warnungsfilter
- Definition of Done
- Bericht mit Zeilenlimit und dem Feld „ungeprüft“

Außerdem gibt es eine Vorlage für read-only Prüfer mit Rollen und Szenarien.

### 6.2 Retrospektive

`playbooks/phase-retro.md`: höchstens zehn Zeilen nach jeder Phase. Aus „Brief-Delta“ und „Regelvorschlag“ werden bessere Aufträge und neue Learnings.

### 6.3 Umgebungsprobe und lokales Hardware-Profil

```bash
~/.the-swarm/tools/probe-env.sh > ~/.the-swarm/hardware/$(hostname -s).local.md
```

Das Profil enthält Betriebssystem, Architektur, Kerne, RAM, Grafik, Werkzeuge, Laufzeiten, Geräte und Last. Darunter stehen von Hand gepflegte **bewährte Grenzen**, zum Beispiel wie viele parallele Builds die Maschine verträgt, welcher Sichtprüfweg funktioniert und welche Umgehungen es gibt.

`*.local.md` ist per `.gitignore` ausgeschlossen. Hardware-Details werden nie veröffentlicht, nur allgemeine Regeln.

### 6.4 Beispiel-Rollen (optional)

`beispiele/` enthält eine fertige Rollenaufteilung nach MANIFEST §5.1 für **OpenCode**, **Claude Code** und **Codex CLI**: Koordinator, Unter-Koordinator, Umsetzer, Prüfer, Recherche, Suche und mechanische Änderungen, dazu ein Skill „orchestrierung“ mit Vorlagen. Modelle stehen als Platzhalter drin.

- Einrichten: im Import-Prompt Frage 2c mit „ja“ beantworten oder nach `beispiele/<werkzeug>/README.md` von Hand kopieren.
- Wichtigster Unterschied: Nur OpenCode kann dem Prüfer ein Modell einer anderen Familie fest zuweisen. In Claude Code und Codex nutzen Subagents die Familie bzw. den Anbieter der Hauptsitzung; dort ist die Familienregel nur ein Hinweis.
- Stand: OpenCode erprobt, Claude Code Git-Sperren erprobt, Codex ungeprüft. Details in [beispiele/README.md](beispiele/README.md).

---

## 7. Learnings lokal sammeln, teilen auf Wunsch

The Swarm wächst durch Erfahrungen, aber nichts wird automatisch veröffentlicht. Ablauf (Details in `CONTRIBUTING.md`):

1. **Lokal sammeln:** Der Agent hält Learnings in `.agent/learnings.md` des Projekts fest, im Format von `CONTRIBUTING.md` (Kontext, Beobachtung, Regel, Beobachtungen, Status `neu`). Das ist alles, was er von sich aus tut.
2. **Teilen nur auf Wunsch:** Willst du ein Learning beitragen, sagst du es ausdrücklich, zum Beispiel: „Erstelle einen Pull Request mit den Learnings dieser Sitzung für The Swarm.“ Ohne dieses Wort entsteht kein Pull Request.
3. **Von Hand:** Repo forken oder neuen Zweig anlegen (`git switch -c learnings/$(date +%Y-%m-%d)-<thema>`), Einträge oben in `LEARNINGS.md` ergänzen, committen und per `gh pr create --fill` einen Pull Request öffnen. Nicht im Klon unter `~/.the-swarm` arbeiten, dort sollen keine lokalen Änderungen liegen.

**Regeln für Beiträge:**

- Anonym und allgemein: keine Namen, Projekte, Pfade, Gerätekennungen, Hardware-Beispiele oder Geheimnisse. Commits tragen nur das Konto-Pseudonym oder die noreply-Adresse des Hosting-Dienstes.
- Ein Mensch prüft und merged. Modelle mergen nicht selbst in `main`.
- Eine Regel entsteht erst bei zwei unabhängigen Beobachtungen. Ein `neu`-Learning ohne zweite Beobachtung verfällt nach 30 Tagen und wandert ins Archiv `learnings/archiv.md`.
- Wird eine Regel übernommen, steigt die Version, und der Changelog bekommt einen Eintrag.

---

## 8. Versionen, Aktualisieren, Festpinnen

- **Versionen:** semantisch, siehe `CHANGELOG.md`. Jede Version ist als Tag `v<Version>` abrufbar.
  - Bedeutung geändert oder Regel gestrichen → Major
  - neue Regel oder Verdichtung ohne Bedeutungsänderung → Minor
  - Korrektur, Klarstellung → Patch
- **Standard ist der neueste Tag**, nie `main`. Ein Major-Wechsel verdient einen genauen Blick, weil sich bestehende Arbeitsweisen ändern.
- **Aktualisieren** beim lokalen Klon:
  ```bash
  bash ~/.the-swarm/tools/update.sh
  ```
  Das Skript holt die Tags, zeigt die neue Version und den Diff zu `KERN.md` und `MANIFEST.md` und wechselt erst nach deiner Bestätigung. Die Option `-y` überspringt die Bestätigung und ist nur für Skripte gedacht.
- **Online** gilt die Tag-URL; ein Update ist der bewusste Wechsel des Tags im Absatz der Anweisungsdatei:
  ```text
  https://raw.githubusercontent.com/diren89/The-Swarm/v2.0.1/KERN.md
  ```
- **Festpinnen,** wenn ein Team eine feste Fassung will: auf einen Tag auschecken und `update.sh` nicht ausführen:
  ```bash
  git -C ~/.the-swarm checkout v2.0.1
  ```
- **Warnung:** Wer im Repo mergen darf, steuert sonst alle Agents, die von `main` laden. Darum lädt The Swarm nur getaggte Stände.

---

## 9. Fehlerbehebung

| Problem | Ursache | Lösung |
| --- | --- | --- |
| Agent kennt The Swarm nicht | Anweisungsdatei nicht geladen oder Sitzung lief schon vorher | Neue Sitzung starten; Pfad prüfen (Abschnitt 3); in Claude Code mit `/memory` nachsehen |
| Agent folgt dem Import-Prompt per URL nicht | Sicherheitsregel: Webinhalte gelten als Daten | vollständigen Prompt aus `prompts/import.md` direkt einfügen |
| Agent kann die URL nicht abrufen | kein Webzugriff oder Netz gesperrt | lokalen Klon mit Import nutzen (3.1 B) oder Inhalt in den System-Prompt stellen (3.6); in Microsoft 365 Copilot `prompts/copilot.md` anhängen (3.5) |
| Zu viel Aufwand bei Kleinigkeiten | Stufe zu hoch gewählt | Stufe S vorgeben; der Agent sollte sonst den Abschnitt „Stufe wählen“ im Kern beachten |
| Projektregel widerspricht dem Manifest | gewollt | Projektregel gilt, der Rest des Manifests bleibt aktiv |
| Subagents scheitern mit Worktree-Fehler | Arbeitsverzeichnis liegt nicht im Git-Repo | Agent aus dem Repo heraus starten; Worktree-Ordner in `.gitignore` (LEARNINGS L-008) |
| Maschine überlastet | zu viele parallele Builds | Parallelität senken und das Limit im lokalen Hardware-Profil notieren (L-004) |
| Agent meldet „erledigt“, aber es funktioniert nicht | Exit-Code statt Wirkung geprüft | auf den Kern verweisen (Abnahme, MANIFEST §5.4): Wirkung prüfen und als ungeprüft markieren, was nicht geprüft wurde |

---

## 10. Deinstallation

1. Den The-Swarm-Absatz aus `~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md`, `~/.gemini/GEMINI.md` oder den Projektdateien entfernen.
2. Optional den lokalen Klon löschen: `rm -rf ~/.the-swarm`. Dabei gehen auch deine lokalen Hardware-Profile verloren, also vorher sichern, falls du sie brauchst.

---

## 11. Häufige Fragen

**Muss ich The Swarm in jedem Projekt erwähnen?**
Nein. Global eingetragen gilt es überall (MANIFEST §0.2). Projektdateien brauchst du nur für Abweichungen.

**Funktioniert The Swarm ohne Subagents?**
Ja. Der Koordinator arbeitet die Pakete dann nacheinander ab. Planung, Prüfschichten, Ehrlichkeit und Lernschleife bleiben.

**Welche Modelle soll ich für Subagents nehmen?**
Je eindeutiger der Auftrag, desto kleiner das Modell, und je tiefer das nötige Fachwissen, desto größer (MANIFEST §5.1). Fachaufgaben wie 3D-Modellierung oder Videobearbeitung gehen an die **Expertenrolle** mit dem größten verfügbaren Modell (§5.1.1). Urteil, Integration und Fehlersuche bleiben beim stärksten Modell.

**Gelangen meine Projektdaten nach GitHub?**
Nur, wenn du ausdrücklich einen Pull Request stellst und ein Mensch ihn mergt. Learnings werden zunächst nur lokal gesammelt, die Beitragsregeln verbieten Namen, Projektdetails und Hardware-Beispiele, und vor dem Merge prüft ein Mensch.

**Darf ein Agent die globale Konfiguration selbst ändern?**
Nur auf deinen ausdrücklichen Wunsch (MANIFEST §0.2).

**Wie trage ich bei, wenn ich keinen Schreibzugriff habe?**
Repo forken, Änderung im Fork machen und einen Pull Request an `diren89/The-Swarm` stellen.
