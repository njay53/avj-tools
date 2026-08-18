# Onepage-Felder · Stand Version 39 · 19.08.2026

Alles, was bei Onepage in ein Custom-Code-Feld eingesetzt wird.
Ein Feld hat drei Kästen: **HTML**, **CSS**, **JS**. Die Dateien sind
danach benannt: `…-1-HTML.txt` gehört in den HTML-Kasten, `…-2-CSS.txt`
in den CSS-Kasten, `…-3-JS.txt` in den JS-Kasten.

**Arbeitsweise:** Datei ändern → bei Onepage einfügen → `hochladen.command`

---

## Die Felder

| Feld | Dateien | wohin | eingebaut |
|---|---|---|---|
| Rechner 9-Sitzer | `9sitzer-1-HTML` `-2-CSS` `-3-JS` | Fahrzeugseite | ja |
| Rechner Transporter | `transporter-1-HTML` `-2-CSS` `-3-JS` | Fahrzeugseite | ja |
| Rechner PKW | `pkw-1-HTML` `-2-CSS` `-3-JS` | Fahrzeugseite | noch nicht |
| **Tariftabellen · Motor** | `tariftabelle-1-CSS` `-2-JS` | Fahrzeugseite, einmal | neu |
| **Tariftabellen · je Popup** | siehe `tariftabelle-3-EINBAU.txt` | in jedes Fahrzeug-Popup | neu |
| **Notfallhinweis** | `stoerung-1-HTML` `-2-CSS` `-3-JS` | Fahrzeugseite, einmal | neu |

`404.html` gehört nicht zu Onepage, sondern in den Ordner `avj-tools`
und wird mit `hochladen.command` mit hochgeladen.

---

## Vorsilben

Damit sich die Felder nicht ins Gehege kommen, hat jedes seine eigene
Vorsilbe. Wer eins kopiert, muss **alle drei Schreibweisen** mitziehen —
und in dieser Reihenfolge, sonst frisst die eine die andere:

| Feld | Element-Kennungen | CSS-Klassen | Abschnitt in preise.json |
|---|---|---|---|
| 9-Sitzer | `avj…` | `avj-…` | `neunsitzer` |
| Transporter | `avjT…` | `avjt-…` | `transporter` |
| PKW | `avjP…` | `avjp-…` | `pkw` |
| Low Budget | `avjL…` | `avjl-…` | `lb` |
| Tariftabellen | — | `avjtab-…` | alle |
| Notfallhinweis | — | `avjnot-…` | — |

---

## Der gemeinsame Preislader

Ganz oben in `9sitzer-3-JS`, `transporter-3-JS`, `pkw-3-JS` und
`tariftabelle-2-JS` steht derselbe Block:

```js
window.AVJ_PREISE = window.AVJ_PREISE || (function(){ … })();
```

**Dieser Block muss in allen vier Dateien wortgleich sein.** Welches Feld
zuerst läuft, entscheidet Onepage über die Reihenfolge auf der Seite —
und wer zuerst läuft, baut den Lader für alle anderen mit. Steht in einer
Datei eine ältere Fassung, hängt es vom Zufall ab, welche gewinnt.

Das Bauskript prüft das und bricht ab, wenn eine Datei abweicht.

---

## Tariftabellen

Ersetzen die JPG-Bilder in den Fahrzeug-Popups. Die Tabelle wird im
Browser aus `preise.json` gebaut — derselben Datei, aus der auch die
Rechner ihre Preise holen.

**Damit gilt:** Preis im Tool ändern → *Für Kunden freigeben* →
`Kundenpreise aktualisieren.command`. Rechner **und** Tabelle stimmen.
Kein Bild mehr bauen, kein Bild mehr austauschen.

Unter der Kopfzeile steht ein **Knopf zum Preisrechner**. Die Tabelle
deckt nur einzelne Tage, das Wochenende und 7 Tage ab — alles dazwischen
kann nur der Rechner. Bis v38 stand dort ein Link im Fließtext; das hat
niemand angeklickt.

Einbau in zwei Schritten, ausführlich in `tariftabelle-3-EINBAU.txt`:

1. **einmal pro Seite** — ein Feld mit `tariftabelle-1-CSS` und
   `tariftabelle-2-JS`, HTML bleibt leer.
2. **einmal pro Popup** — JPG raus, ein Feld rein, nur HTML, eine Zeile:

```html
<div class="avjtab" data-fz="neunsitzer.vito"
     data-titel="Kleinbus Mercedes-Benz *Vito Tourer* 119 (9-Sitzer, extralang, AHK)"></div>
```

`data-titel` ist die blaue Kopfzeile, `*Sternchen*` machen den
Modellnamen rot. Lässt man es weg, kommt der Titel aus dem Tool.

**Abtippen muss man die Zeile nicht:** im Tool unter *Tarif Config.* das
Fahrzeug auswählen, Knopf **Popup-Zeile** — dort steht sie fertig und geht
per Klick in die Zwischenablage.

Was die Tabelle zeigt, richtet sich nach dem, was beim Fahrzeug
hinterlegt ist: Kurzzeittarife nur mit `kurzzeit`, Wochenende nur mit
`weekend`, Haftung nur mit `sb`, AHK-Zeilen nur mit `ahk`. Low Budget
hat kein Tagespaketraster und bekommt stattdessen die Staffel 1–7 Tage
plus Monatspreis.

### Wenn preise.json etwas nicht kennt

`kurzzeit`, `ahk` und `kaution` braucht nur die Tabelle, nicht der
Rechner. Liefert der Server sie zu einem Fahrzeug nicht mit, nimmt die
Tabelle **genau diese drei** aus dem Code — sonst würden die
Kurzzeittarife und alle AHK-Zeilen stillschweigend verschwinden.
Preise werden nie ersetzt: `tier`, `tierKm`, `dayMoDo`, `dayFrSa`,
`weekend` und `sb` kommen immer vom Server, sobald er antwortet.

Geprüft an der Datei vom 16.08. (Build 29): dort sind die drei bei
9-Sitzer und Transporter schon drin, der Nachtrag greift also gar nicht.
Der `pkw`-Abschnitt fehlt dagegen komplett — die beiden Golf-Tabellen
rechnen bis zum nächsten *Für Kunden freigeben* mit den eingebauten
Werten. Richtig, aber noch nicht zentral pflegbar.

**Ein Punkt zum Entscheiden:** ganz oben in `tariftabelle-2-JS` steht

```js
var AVJTAB_GEPLANT = false;
```

Auf `false` zeigt die Spalte „je extra km“ nur den ungeplanten Satz —
genau wie die bisherigen JPGs. Der Rechner rechnet aber mit zwei
Sätzen: vorab geplante Mehrkilometer sind günstiger. Auf `true`
stehen beide in der Tabelle.

---

## Notfallhinweis

Zeigt im Normalfall **nichts**. Er springt nur ein, wenn ein Rechner
oder eine Tabelle leer geblieben ist — Skript blockiert, Browser zu alt,
ein Feld bei Onepage versehentlich gelöscht. Dann steht dort die
Telefonnummer statt eines leeren Rahmens. Zusätzlich ein `<noscript>`
für Browser mit abgeschaltetem JavaScript.

**Er prüft nicht, ob GitHub erreichbar ist** — das wäre falsch. Fällt
`avj-tools` aus, nehmen Rechner und Tabellen die Werte, die beim letzten
Hochladen mitgegeben wurden. Der Kunde sieht dann Preise vom vorletzten
Stand statt gar nichts. Ein Störungshinweis würde an der Stelle jemanden
vertreiben, der einen völlig gültigen Preis vor sich hat.

Frist: 7 Sekunden. Der Abruf von `preise.json` bricht selbst nach 3
Sekunden ab, danach wird zurückgefallen — also reichlich Puffer.

---

## 404.html

Kommt in den Ordner `avj-tools`, neben `index.html` und `CNAME`.
GitHub Pages zeigt sie automatisch, wenn jemand eine Adresse auf
`avj-tools.rent-in-nom.de` aufruft, die es nicht gibt: alter Link,
Tippfehler, Datei noch nicht hochgeladen. Statt der grauen GitHub-Seite
steht dann „Technische Störung“ mit Telefonnummer und WhatsApp.

Was sie **nicht** kann: ist GitHub Pages selbst ausgefallen, wird auch
diese Datei nicht ausgeliefert. Dann zeigt GitHub seine eigene
Fehlerseite. Dagegen hilft nur ein zweiter Anbieter — lohnt sich für
eine Datei, die ohnehin nur du benutzt, nicht.

**`CNAME` niemals löschen.** Sonst ist die Adresse weg.
