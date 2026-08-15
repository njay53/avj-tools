# Einrichtung — einmalig

## 1. Repository holen

Terminal öffnen, diese zwei Zeilen nacheinander:

```bash
cd '/Users/niran/Documents/Claude Cowork/avj programme'
git clone https://github.com/njay53/avj-tools.git
```

Damit entsteht der Ordner `avj-tools` mit dem Inhalt des Repositories —
also `index.html`, `README.md` und `CNAME`.

Die Anmeldung von der Schadenmanager-Einrichtung gilt weiter; sie hängt an
deinem Konto, nicht am einzelnen Repository.

## 2. Skript hineinlegen

Die Datei `hochladen.command` in den neuen Ordner `avj-tools` kopieren, dann
einmalig ausführbar machen:

```bash
cd '/Users/niran/Documents/Claude Cowork/avj programme/avj-tools'
chmod +x hochladen.command
```

**Beim ersten Doppelklick** meldet macOS womöglich, die Datei stamme von einem
unbekannten Entwickler. Dann einmal Rechtsklick → Öffnen → Öffnen. Danach
funktioniert der normale Doppelklick.

## 3. Fertig

Ab jetzt zum Hochladen: **Doppelklick auf `hochladen.command`** im Finder.
Das Terminal öffnet sich, erledigt alles und wartet auf einen Tastendruck.

Wer lieber tippt, kann auch eine eigene Notiz mitgeben:

```bash
cd '/Users/niran/Documents/Claude Cowork/avj programme/avj-tools'
./hochladen.command "Rabattfelder ergänzt"
```

---

# So läuft es künftig

Im Cowork-Chat schreibe ich direkt in diesen Ordner — als `index.html`, nicht
mehr als `avj-tools.html`. Das Umbenennen entfällt also.

Du machst danach einen Doppelklick auf `hochladen.command`. Das Skript prüft vorher:

- Liegt überhaupt eine `index.html` da?
- Ist sie vollständig (endet mit `</html>`)?
- Hat sich seit dem letzten Mal etwas geändert?

Erst dann lädt es hoch und nennt dir die Build-Nummer sowie die Adresse mit
Versionsanhang, falls der Zwischenspeicher wieder klemmt.

Wenn die Übertragung scheitert, bleibt der Commit lokal liegen — ein erneuter
Aufruf genügt, es geht nichts verloren.

---

# Was im Ordner liegen sollte

```
avj-tools/
├── index.html        ← die App, wird von mir geschrieben
├── hochladen.command ← Doppelklick zum Hochladen
├── CNAME             ← die Domain, NICHT löschen
├── README.md
└── STAND.md          ← Projektstand für neue Chats
```

Die sechs Onepage-Dateien für die Kundenrechner gehören **nicht** ins
Repository — die kopierst du weiterhin von Hand in die Custom-Code-Felder.
Sie liegen im Cowork-Ordner daneben, aber außerhalb von `avj-tools`.
