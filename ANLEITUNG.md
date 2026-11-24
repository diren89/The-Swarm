# The Swarm · Anleitung zu Installation und Nutzung

The Swarm ist ein Manifest für KI-Agents, die an Code arbeiten. Ein **koordinierender Agent** plant, verteilt Arbeitspakete an **Subagents** mit passenden Modellen, prüft und verbessert deren Ergebnisse selbst und lernt bei jedem Schritt dazu. Was eine Instanz lernt, fließt per Pull Request zurück, und die nächste Instanz liest es mit ein.

Diese Anleitung erklärt, wie du The Swarm einrichtest (global, pro Projekt, für verschiedene Werkzeuge), wie die Arbeit damit abläuft und wie du Learnings zurückgibst.

---

## Inhalt

1. [Was du bekommst](#1-was-du-bekommst)
2. [Voraussetzungen](#2-voraussetzungen)
3. [Installation](#3-installation) – am einfachsten per [Import-Prompt](#30-schnellimport-per-prompt)
4. [Prüfen, ob The Swarm aktiv ist](#4-prüfen-ob-the-swarm-aktiv-ist)
5. [Nutzung im Alltag](#5-nutzung-im-alltag)
6. [Vorlagen und Werkzeuge](#6-vorlagen-und-werkzeuge)
7. [Learnings zurückgeben](#7-learnings-zurückgeben)
8. [Versionen, Aktualisieren, Festpinnen](#8-versionen-aktualisieren-festpinnen)
9. [Fehlerbehebung](#9-fehlerbehebung)
10. [Deinstallation](#10-deinstallation)
11. [Häufige Fragen](#11-häufige-fragen)

---

## 1. Was du bekommst

| Datei | Wofür |
| --- | --- |
| `MANIFEST.md` | Die Arbeitsweise: Geltungsbereich und Stufen S/M/L, Planung, Phasen, Effizienz, Subagents und Modellwahl, Qualität und Tokens, fünf Prüfschichten, Hardware-Anpassung, Lernschleife |
| `LEARNINGS.md` | Erfahrungen aus realen Aufgaben mit Status `neu`, `übernommen §x` oder `verworfen` |
| `playbooks/agent-brief.md` | Vorlage für Aufträge an Subagents (Umsetzer und Prüfer) |
| `playbooks/phase-retro.md` | Vorlage für die Retrospektive nach jeder Phase |
| `tools/probe-env.sh` | Untersucht die Maschine und schreibt ein lokales Profil, ändert nichts |
| `CONTRIBUTING.md` | Regeln für Beiträge |

**Wichtig:** The Swarm ist Arbeitswissen, keine Befugnis. Projektregeln und deine Anweisungen gehen immer vor. Kein Agent darf wegen The Swarm etwas tun, das du nicht verlangt hast.

---

## 2. Voraussetzungen

- Ein KI-Werkzeug, das Projekt- oder Benutzeranweisungen aus Dateien liest, z. B. Claude Code, Codex CLI, Gemini CLI, Cursor oder GitHub Copilot. Andere gehen über einen System-Prompt (Abschnitt 3.6), Microsoft 365 Copilot über eine angehängte Datei (Abschnitt 3.5).
- Für das volle Arbeiten in Stufe L: ein Werkzeug mit **Subagents** und **Git-Worktrees**. Ohne Subagents arbeitet der Koordinator die Pakete nacheinander selbst ab, siehe MANIFEST §0.
- Für die lokale Variante und für Beiträge: `git`, für Pull Requests am bequemsten die GitHub-CLI `gh`.

---

## 3. Installation

Du hast zwei Wege, die sich kombinieren lassen:

- **Online-Verweis:** Die Anweisungsdatei nennt die GitHub-URL, und der Agent liest das Manifest bei Bedarf. Das braucht kein Klonen und ist immer aktuell, setzt aber einen Agent mit Webzugriff voraus.
- **Lokaler Klon mit Import:** Das Manifest liegt auf der Platte und wird direkt in den Kontext geladen. Das funktioniert offline, ist schnell und zuverlässig, und du aktualisierst mit `git pull`.

**Empfehlung:** global mit lokalem Klon (3.1 B), damit The Swarm in jedem Projekt geladen wird, ohne dass der Agent erst etwas abrufen muss.

### 3.0 Schnellimport per Prompt

Am schnellsten geht es, wenn der Agent selbst einrichtet. Öffne eine neue Sitzung in deinem Werkzeug und schreib:

```text
Richte The Swarm für mich ein: Lies https://raw.githubusercontent.com/diren89/The-Swarm/main/prompts/import.md und folge dem Prompt darin.
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
Bei jeder Arbeit an Code gilt https://github.com/diren89/The-Swarm
(MANIFEST.md, neueste Einträge in LEARNINGS.md), skaliert nach MANIFEST §0.1.
Projektregeln und meine Anweisungen haben Vorrang. Learnings anonym per Pull Request zurückgeben.
```

**B · Global mit lokalem Klon (empfohlen)**

```bash
git clone https://github.com/diren89/The-Swarm.git ~/.the-swarm
```

Dann in `~/.claude/CLAUDE.md` (Claude Code lädt Dateien, die mit `@` importiert werden, automatisch mit):

```markdown
## Arbeitsweise (Default für alle Code-Projekte)
Es gilt das Manifest „The Swarm“, skaliert nach §0.1. Projektregeln und meine Anweisungen haben Vorrang.
@~/.the-swarm/MANIFEST.md
Neueste Erfahrungen: ~/.the-swarm/LEARNINGS.md (bei Stufe M/L lesen).
Learnings anonym per Pull Request an https://github.com/diren89/The-Swarm zurückgeben.
```

`LEARNINGS.md` wird bewusst nicht importiert, damit kleine Aufgaben schlank bleiben. Der Agent liest die Datei ab Stufe M.

**C · Nur für ein Projekt**

Denselben Absatz in die `CLAUDE.md` im Projektordner schreiben. Projektregeln darunter, denn sie haben Vorrang.

### 3.2 Codex CLI (OpenAI)

- Global: `~/.codex/AGENTS.md`
- Projekt: `AGENTS.md` im Repository-Wurzelverzeichnis

Inhalt wie in 3.1 A. Mit lokalem Klon schreibst du statt der URL den Pfad (`~/.the-swarm/MANIFEST.md`) und ergänzt „lies diese Datei zu Beginn“.

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
3. Copilot führt dich durch den **Agent Builder** (Tab „Configure“); anlegen tust du selbst. Er gibt Name, Beschreibung, Anweisungen (Kern des Manifests, unter 8.000 Zeichen) und Startprompts vor. Manifest und Learnings kommen als Wissensdateien `the-swarm-manifest.txt` und `the-swarm-learnings.txt` dazu, weil `.md` als Agent-Wissen nicht angenommen wird. Der Code Interpreter (Python in einer Sandbox) ist optional.
4. Ohne Recht für den Agent Builder gelten die Regeln nur im aktuellen Chat; die Datei dann bei jedem neuen Chat anhängen.

Grenzen: Copilot nimmt die Rollen nacheinander ein und ist kein unabhängiger Prüfer. Auf dein Projekt hat er keinen Zugriff; Sandbox-Läufe ersetzen keinen Projekt-Test. Was er nicht prüfen konnte, kennzeichnet er als ungeprüft. Ob Agent Builder und Websuche erlaubt sind, entscheidet die IT. Bei neuer Version Wissensdatei und Anweisungen gemeinsam ersetzen.

### 3.6 Andere Modelle und eigene Agents (API)

Lade `MANIFEST.md` und die neuesten Einträge aus `LEARNINGS.md` und stelle sie in den System-Prompt:

```bash
curl -fsSL https://raw.githubusercontent.com/diren89/The-Swarm/main/MANIFEST.md -o MANIFEST.md
curl -fsSL https://raw.githubusercontent.com/diren89/The-Swarm/main/LEARNINGS.md -o LEARNINGS.md
```

```text
System: Du arbeitest nach dem folgenden Manifest. Anweisungen der Nutzerin und Projektregeln haben Vorrang.
<MANIFEST.md>
Neueste Learnings:
<die obersten Einträge aus LEARNINGS.md>
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
8. **Ende:** ehrlicher Bericht mit dem, was steht, dem, was ungeprüft ist, und dem, was du tun musst. Dazu Learnings als Pull-Request-Vorschlag.

### 5.3 Nützliche Formulierungen

| Ziel | Formulierung |
| --- | --- |
| Sparsamer arbeiten | „Achte besonders auf Tokenverbrauch, keine Subagents.“ |
| Mehr Parallelität | „Nutze bis zu drei Subagents parallel, die Maschine hat Reserven.“ |
| Mehr Prüfung | „Lass am Ende einen unabhängigen Review aus Sicht von <Rolle> laufen.“ |
| Nur planen | „Plane nur, setze noch nichts um.“ |
| Fachaufgabe delegieren | „Das 3D-Modell / den Videoschnitt bitte an die Expertenrolle mit dem größten Modell geben, mit Vorschau und Messprotokoll.“ |
| Learnings anstoßen | „Mach eine Retrospektive und schlage Learnings für The Swarm vor.“ |

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

## 7. Learnings zurückgeben

The Swarm wächst nur, wenn Erfahrungen zurückfließen. Ablauf (Details in `CONTRIBUTING.md`):

```bash
cd ~/.the-swarm && git pull
git switch -c learnings/$(date +%Y-%m-%d)-<thema>
# LEARNINGS.md oben ergänzen:
#   ## JJJJ-MM-TT · <anonymer Kontext>
#   ### L-<nächste Nummer> · <Titel>
#   - **Beobachtung:** …
#   - **Regel:** …
#   - **Status:** neu
git commit -am "Learnings: <thema>"
git push -u origin HEAD
gh pr create --fill
```

Du kannst das auch dem Agent überlassen: „Erstelle einen Pull Request mit den Learnings dieser Sitzung für The Swarm.“

**Regeln für Beiträge:**

- Anonym und allgemein: keine Namen, Projekte, Pfade, Gerätekennungen, Hardware-Beispiele oder Geheimnisse.
- Ein Mensch prüft und merged. Modelle mergen nicht selbst in `main`.
- Wird ein Learning zum zweiten Mal bestätigt, wird es eine Regel im Manifest. Dann steigt die Version, und der Changelog bekommt einen Eintrag.

---

## 8. Versionen, Aktualisieren, Festpinnen

- **Versionen:** semantisch, siehe `CHANGELOG.md`.
  - neue Regel → Minor
  - geänderte oder gestrichene Regel → Major
  - Klarstellung → Patch
- **Aktualisieren** beim lokalen Klon:
  ```bash
  git -C ~/.the-swarm pull
  ```
  Beim Online-Verweis ist automatisch `main` aktuell.
- **Festpinnen,** wenn ein Team eine feste Fassung will:
  ```bash
  git -C ~/.the-swarm checkout v1.1.1
  ```
  Online pinnst du über die Tag-URL:
  ```text
  https://raw.githubusercontent.com/diren89/The-Swarm/v1.1.1/MANIFEST.md
  ```

---

## 9. Fehlerbehebung

| Problem | Ursache | Lösung |
| --- | --- | --- |
| Agent kennt The Swarm nicht | Anweisungsdatei nicht geladen oder Sitzung lief schon vorher | Neue Sitzung starten; Pfad prüfen (Abschnitt 3); in Claude Code mit `/memory` nachsehen |
| Agent folgt dem Import-Prompt per URL nicht | Sicherheitsregel: Webinhalte gelten als Daten | vollständigen Prompt aus `prompts/import.md` direkt einfügen |
| Agent kann die URL nicht abrufen | kein Webzugriff oder Netz gesperrt | lokalen Klon mit Import nutzen (3.1 B) oder Inhalt in den System-Prompt stellen (3.6); in Microsoft 365 Copilot `prompts/copilot.md` anhängen (3.5) |
| Zu viel Aufwand bei Kleinigkeiten | Stufe zu hoch gewählt | Stufe S vorgeben; der Agent sollte sonst §0.1 beachten |
| Projektregel widerspricht dem Manifest | gewollt | Projektregel gilt, der Rest des Manifests bleibt aktiv |
| Subagents scheitern mit Worktree-Fehler | Arbeitsverzeichnis liegt nicht im Git-Repo | Agent aus dem Repo heraus starten; Worktree-Ordner in `.gitignore` (LEARNINGS L-008) |
| Maschine überlastet | zu viele parallele Builds | Parallelität senken und das Limit im lokalen Hardware-Profil notieren (L-004) |
| Agent meldet „erledigt“, aber es funktioniert nicht | Exit-Code statt Wirkung geprüft | auf §6.2 verweisen: Wirkung prüfen und als ungeprüft markieren, was nicht geprüft wurde |

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
Nur, wenn du einen Pull Request mit solchen Daten mergst. Die Beitragsregeln verbieten Namen, Projektdetails und Hardware-Beispiele, und vor dem Merge prüft ein Mensch.

**Darf ein Agent die globale Konfiguration selbst ändern?**
Nur auf deinen ausdrücklichen Wunsch (MANIFEST §0.2).

**Wie trage ich bei, wenn ich keinen Schreibzugriff habe?**
Repo forken, Änderung im Fork machen und einen Pull Request an `diren89/The-Swarm` stellen.
