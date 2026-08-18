# Onepage-Felder — Sicherung

Die Custom-Code-Felder der Fahrzeugseite. Sie liegen im Repository und wandern
bei jedem `hochladen.command` mit nach GitHub.

| Datei | Onepage-Feld |
|---|---|
| `9sitzer-1-HTML.txt` | HTML, Rechner 9-Sitzer |
| `9sitzer-2-CSS.txt` | CSS, Rechner 9-Sitzer |
| `9sitzer-3-JS.txt` | JS, Rechner 9-Sitzer |
| `transporter-1-HTML.txt` | HTML, Rechner Transporter |
| `transporter-2-CSS.txt` | CSS, Rechner Transporter |
| `transporter-3-JS.txt` | JS, Rechner Transporter |
| `pkw-1-HTML.txt` | HTML, Rechner PKW |
| `pkw-2-CSS.txt` | CSS, Rechner PKW |
| `pkw-3-JS.txt` | JS, Rechner PKW |

## Arbeitsregel

Diese Dateien sind die Sicherung — sie stimmen nur, wenn ihr Inhalt auch bei
Onepage eingefügt wurde.

Reihenfolge: **Datei ändern → bei Onepage einfügen → hochladen.command**

Läuft es auseinander, sieht man es an der Kennung unten im Kunden-Popup
(`Rechner vNN · Datum`). Die Nummer soll dieselbe sein wie die Build-Nummer
der App.

## Was wo hingehört

Die drei Rechner sind unabhängige Blöcke mit eigenen Vorsilben:

| Rechner | Kennungen | CSS-Klassen | Abschnitt in preise.json |
|---|---|---|---|
| 9-Sitzer | `avj…` | `avj-…` | `neunsitzer` |
| Transporter | `avjT…` | `avjt-…` | `transporter` |
| PKW | `avjP…` | `avjp-…` | `pkw` |

> **Wichtig:** Alle drei JS-Felder enthalten oben dasselbe Lademodul
> (`window.AVJ_PREISE = window.AVJ_PREISE || …`). Es wird nur einmal
> ausgeführt — welcher Block es anlegt, hängt an der Reihenfolge auf der
> Seite. Deshalb muss dieser Abschnitt in allen drei Dateien **wortgleich**
> sein. Wird er in einer Datei geändert, gehört die Änderung in alle drei.

## Fahrzeugknöpfe

Seit v37 werden sie aus den Tarifdaten gezeichnet, nicht mehr aus dem
HTML-Feld. Ein Fahrzeug, das du in AVJ Tools anlegst und freigibst, taucht
damit auch bei Kunden auf — ohne dass ein Onepage-Feld angefasst werden muss.
Im HTML steht nur noch der leere Behälter `<div class="…-cars">`.

## Kopieren aus Onepage

Onepage → Fahrzeugseite → Custom-Code-Abschnitt → Feld → ⌘A, ⌘C.
Beim Zurückschreiben in eine Datei: TextEdit, Format → In reinen Text
umwandeln (⇧⌘T). Kein RTF.
