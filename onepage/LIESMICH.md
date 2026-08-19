# Onepage-Felder · Stand Version 52 · 19.08.2026

Alles, was bei Onepage in ein Custom-Code-Feld eingesetzt wird.
Ein Feld hat drei Kästen: **HTML**, **CSS**, **JS**. Die Dateien sind
danach benannt: `…-1-HTML.txt` gehört in den HTML-Kasten, `…-2-CSS.txt`
in den CSS-Kasten, `…-3-JS.txt` in den JS-Kasten.

**Arbeitsweise:** Datei ändern → bei Onepage einfügen → `hochladen.command`

---

## Die Felder

**Reihenfolge beim Einsetzen — immer diese:**

| # | Feld | Dateien | wohin |
|---|---|---|---|
| **1** | Rechner **Kleinbus/Van** | `9sitzer-1-HTML` `-2-CSS` `-3-JS` | Fahrzeugseite |
| **2** | Rechner **PKW** | `pkw-1-HTML` `-2-CSS` `-3-JS` | Fahrzeugseite |
| **3** | Rechner **Transporter** | `transporter-1-HTML` `-2-CSS` `-3-JS` | Fahrzeugseite |
| **4** | **Tariftabellen · Motor** | `tariftabelle-1-CSS` `-2-JS` | Fahrzeugseite, einmal |

Danach, unabhängig von der Reihenfolge:

| Feld | Dateien | wohin |
|---|---|---|
| Tariftabellen · je Popup | siehe `tariftabelle-3-EINBAU.txt` | in jedes Fahrzeug-Popup |
| Notfallhinweis | `stoerung-1-HTML` `-2-CSS` `-3-JS` | Fahrzeugseite, einmal |

**Neu in v47 sind auch die HTML-Kästen** der drei Rechner — sie waren
seit v37 unverändert. Wer nur die JS-Kästen tauscht, behält die alten
Unterzeilen und die fest eingetragenen Fahrzeugknöpfe.

`404.html` gehört nicht zu Onepage, sondern in den Ordner `avj-tools`
und wird mit `hochladen.command` mit hochgeladen.

---

## Kleinbus/Van statt 9-Sitzer (v47)

Die Kategorie heißt überall **Kleinbus/Van** — im Tool, am Knopf, in der
Überschrift des Rechners und in der Auswertung. Grund: eine V-Klasse mit
sieben Sitzen ist kein 9-Sitzer und hätte sonst nicht hineingepasst.

**Was sich NICHT ändert:** der Abschnitt in `preise.json` heißt weiter
`neunsitzer`, die Element-Kennungen weiter `avj…`, die CSS-Klassen weiter
`avj-…`, und `data-fz="neunsitzer.vito"` bleibt genau so stehen. Sonst
wären alle bisherigen Daten und alle Popup-Zeilen ungültig.

Die **Größenklasse je Fahrzeug** bleibt frei wählbar: ein Sprinter Tourer
214 ist weiter ein 9-Sitzer, eine V-Klasse wäre ein Van. Beides steht
jetzt in der Klassenliste des Tools.

---

## Der Hinweis über dem WhatsApp-Knopf (v50)

Dass die Angaben mitgehen, merkt der Kunde sonst erst **nach** dem Klick
— und tippt bis dahin entweder alles noch einmal ab oder schreibt nur
„hallo". Deshalb steht es jetzt vorher da, gelb auf dem dunklen Kasten,
direkt über dem Knopf. Der Text wechselt mit dem Zustand:

**nichts eingetragen**

> **Erst oben Zeitraum und Kilometer eintragen.** Dann gehen deine
> Angaben mit der WhatsApp-Nachricht direkt an uns — ohne Abtippen.

**alles da**

> **Deine Angaben werden mitgeschickt.** Fahrzeug, Zeitraum, Kilometer
> und der Richtpreis stehen fertig in der Nachricht — du musst nichts
> abtippen. Abgeschickt wird sie erst von dir.

Dazu die kleine Zeile im Knopf: „über WhatsApp" wird zu
**„über WhatsApp · mit deinen Angaben"**, sobald etwas zu übertragen ist.

Der Hinweis wird **vom JS erzeugt** und mit Inline-Stilen versehen —
deshalb bleiben HTML- und CSS-Kasten unangetastet, es sind wieder nur
die drei JS-Felder zu tauschen.

---

## WhatsApp mit vorausgefüllter Nachricht (v49)

Der grüne Knopf im Rechner führt jetzt auf

```
https://wa.me/49555154545?text=<Nachricht>
```

WhatsApp legt den Text dem Kunden **ins Eingabefeld** — abgeschickt wird
er erst mit seinem Fingertipp. Es geht also nichts heimlich raus, und er
kann vorher noch etwas dazuschreiben. Funktioniert auf iPhone, Android
und am Rechner (web.whatsapp.com) gleich.

So sieht die Nachricht aus:

```
Hallo, ich habe euren Preisrechner benutzt und hätte gern ein Angebot.

Fahrzeug: Vito Tourer (9-Sitzer · Bus · Diesel · Automatik · 119 extralang)
Abholung: Mo 17.08.2026, 09:00 Uhr
Rückgabe: Mo 24.08.2026, 09:00 Uhr
Dauer: 7 Tage
Geplante Kilometer: 800 km
Selbstbeteiligung: 1.000 €

Richtpreis laut Rechner: 1.050 € (Wochentarif)
Frei-Kilometer: 1.800 km

Ist das Fahrzeug in dem Zeitraum frei?
```

Drin steht **nur, was ohnehin im Rechner steht**. Nach Name oder
Telefonnummer wird nicht gefragt — das wäre ein Formular, und beides
steht in WhatsApp ohnehin dran.

Zwei Sonderfälle:

* **Nichts eingetragen** → nur „Hallo, ich interessiere mich für ein
  Fahrzeug bei euch." Kein Gerüst mit Lücken.
* **Ab 29 Tagen** → kein Preis, sondern „Für diese Mietdauer nennt der
  Rechner keinen Preis — bitte um ein Angebot." Zeitraum und Kilometer
  stehen trotzdem drin, gerade dort sind sie wichtig.

Die Adresse wird bei **jeder** Eingabe neu gesetzt (`waLink(r)` steht
direkt hinter `quote()`), auch beim Wechsel von Fahrzeug oder
Selbstbeteiligung. Länge bei einer vollen Anfrage: rund 630 Zeichen,
weit unter jeder Grenze.

Die Nummer steht als `var WA_NUMMER = "49555154545";` oben in der
WhatsApp-Funktion — an einer Stelle je Feld.

Geprüft mit `pruefwa49.js`: 26 Proben über alle drei Rechner, unter
anderem dass der Preis in der Nachricht mit dem im Kasten übereinstimmt.

---

## Die beiden Felder über dem Preis (v48)

Sie haben feste Rollen:

| | |
|---|---|
| **links**, klein und grau | die **Dauer** — „4 Tage", „1 Tag · Mo–Do" |
| **rechts**, gelb | die **Tarifart** — „Tagestarif", „Wochentarif", … |

Einzige Ausnahme links: beim Wochenende steht dort der Zeitrahmen
**Fr 12:00 – Mo 10:00** statt „3 Tage und 21 Std." — das ist die Angabe,
die der Kunde sonst nachfragen müsste.

| Dauer | gelbes Feld |
|---|---|
| 1–6 Tage | Tagestarif |
| Wochenende | Wochenendtarif |
| 7 Tage | Wochentarif |
| 8–27 Tage | Mehrwochentarif |
| 28 Tage | Monatstarif |
| ab 29 Tagen | Langzeitmiete *(ohne Preis)* |

Vorher war es gemischt: beim Wochentarif stand der Name rechts, beim
Wochenende links, bei drei bis sechs Tagen nirgends. Man konnte also
nicht ablesen, nach welchem Tarif gerechnet wurde, ohne zu wissen, wo
man hinschauen muss.

Das gelbe Feld bleibt durchgehend in Versalien; nur die Schriftgröße
gibt bei „Mehrwochentarif" und „Wochenendtarif" etwas nach, damit auf
dem iPhone nichts umbricht. Geprüft mit `bildbadge.js` bei 390 px und
900 px Breite.

Nebenbei: vor **„auf Anfrage"** steht kein Eurozeichen mehr, und der
Text ist kleiner gesetzt — in Preisgröße brach er auf dem iPhone um.

---

## Unterzeile am Knopf (v47)

Stand vorher `Golf & Golf Variant`, `Sprinter Tourer & Vito Tourer`,
`Transporter M & XL`. Zu speziell — die Flotte wechselt, der Rechner
nicht. Jetzt:

| Rechner | Unterzeile |
|---|---|
| Kleinbus/Van | Alle Kleinbusse & Vans · in 30 Sekunden |
| PKW | Alle PKW-Modelle · in 30 Sekunden |
| Transporter | Alle Größen · in 30 Sekunden |

Im selben Zug sind die **fest eingetragenen Fahrzeugknöpfe** aus
`9sitzer-1-HTML` und `transporter-1-HTML` verschwunden. Das JS-Feld baut
sie ohnehin aus den Tarifdaten (`renderCars`) — die festen Knöpfe waren
nur ein kurzes Aufblitzen womöglich falscher Namen und wären bei einem
neuen Fahrzeug stehengeblieben. Das PKW-Feld macht es seit v37 so.

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

## Eigener Mehrkilometer-Satz für Kurzzeit (v52)

Die Kurzzeitzeile nahm bisher den allgemeinen Satz des Fahrzeugs mit.
Wer die Freigrenze auf 50 km zieht, kann damit nicht weiterrechnen —
deshalb gibt es jetzt `kurzzeit.overKm`.

Im Tool: *Tarif Config.* → Fahrzeug → Abschnitt **Kurzzeittarife**,
Feld **Mehr-km bei KZ**. Leer heißt „wie beim Fahrzeug"; der Platzhalter
zeigt, welcher Satz das gerade ist.

Betrifft **nur** die Kurzzeitzeile der Tabelle. Tages-, Wochenend- und
Langzeitzeilen behalten den Satz des Fahrzeugs. Der Kundenrechner ist
gar nicht betroffen — er kennt keine Stundenmieten.

---

## Die blaue Kopfzeile (v51) — WICHTIG beim Nachziehen

Bis v50 stand in jeder Popup-Zeile ein `data-titel` mit einer von Hand
übernommenen Überschrift. Die stand fest bei Onepage und wusste nichts
vom Tool — deshalb zeigten Tabelle und Rechner verschiedene Namen:

| | |
|---|---|
| Tool | VW Golf 8 Energy Variant |
| Rechner-Knopf | VW Golf 8 Energy Variant jetzt berechnen |
| Kopfzeile | ~~PKW Volkswagen *Golf Variant* 8 (Kombi, Automatik)~~ |

**Ab v51 gilt: Popup-Zeile ohne `data-titel`.**

```html
<div class="avjtab" data-fz="pkw.golfvariant"></div>
```

Die Kopfzeile kommt dann aus `preise.json` — Name plus Kurzbeschreibung,
also genau das, was im Bearbeiten-Dialog unter dem Namen steht. Der
**Name** wird rot:

> **VW Golf 8 Energy Variant** (Kompaktklasse · Kombi · Benzin · Automatik)

Umbenennen im Tool → freigeben → hochladen: Kopfzeile, Rechner-Knopf und
Fahrzeugauswahl heißen überall gleich. Kein Nachpflegen bei Onepage.

**Zu tun:** in jedem Fahrzeug-Popup das ` data-titel="…"` aus der Zeile
löschen. Die fertigen Zeilen stehen in `tariftabelle-3-EINBAU.txt`.

### Kein Rot?

Ganz oben in `tariftabelle-2-JS.txt`:

```js
var AVJTAB_ROT = false;
```

Dann ist die Kopfzeile einfarbig weiß. Die Sternchen verschwinden in
beiden Fällen.

### Eigene Kopfzeile (Ausnahme)

Im Dialog *Popup-Zeile* gibt es den Haken **„Eigene Kopfzeile
schreiben"**. Dann kommt wieder ein `data-titel` in die Zeile, und was
zwischen `*Sternchen*` steht, wird rot. Der Text steht damit aber wieder
fest bei Onepage und läuft mit der Zeit vom Tool weg — im Zweifel
weglassen.

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
Modellnamen rot.

**Lässt man `data-titel` weg**, baut die Tabelle die Kopfzeile im
gleichen Stil selbst — `*Name* (Klasse · Karosserie · Kraftstoff ·
Getriebe)`. Der Vorteil: sie kommt dann aus `preise.json` und wandert
mit, wenn im Tool eine Angabe geändert wird. Eine eingetragene
`data-titel`-Zeile tut das **nicht**, die steht fest bei Onepage und
müsste nach jeder Änderung neu kopiert werden.

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

## Langzeit (ab v41, neu geregelt in v46)

Bis sieben Tage rechnet alles wie bisher. Darüber gilt ein zweiter
Anker: **vier Wochen = 28 Tage**. Zwischen Woche und Monat wird linear
interpoliert, dadurch fällt der Wochenpreis mit der Dauer. **Ab Tag 29**
zeigt der Rechner keinen Preis mehr, sondern *„auf Anfrage"* mit der
Telefonnummer.

Fehlt der Monatsanker beim Fahrzeug, wird er geschätzt: Preis 3 × Woche,
Frei-km 2 × Wochen-km, Haftung 3 × Wochensatz. Diese Regel steht
**wortgleich an vier Stellen** — im Tool und in den drei Rechner-Feldern,
und noch einmal im Tariftabellen-Motor. Wer sie ändert, ändert sie
überall, sonst rechnet die Website anders als der Betrieb.

Die Schätzung ist kein Notbehelf, sondern der Normalfall: sie trifft
Nirans eigene Erwartung. Eine Woche 450 € ergibt für 14 Tage 750 € —
er nennt 730 bis 800. Für 28 Tage ergibt sie 1.350 €; er rechnet mit
rund 1.360 bis 1.410. Ein Monatspreis muss also **nicht** für jedes
Fahrzeug eingetragen werden, er verschiebt die Staffel nur dort, wo
Niran es genauer will.

**Schalter je Fahrzeug (v42, Bedeutung geändert in v46):** im Tool steht
unter den Langzeitfeldern der Haken *„Vier-Wochen-Preis nicht anzeigen"*.

| | ohne Haken | mit Haken |
|---|---|---|
| 1–7 Tage | Preis | Preis |
| 8–27 Tage | Preis | **Preis** (v45: auf Anfrage) |
| 28 Tage | Preis | auf Anfrage |
| ab 29 Tagen | auf Anfrage | auf Anfrage |

Bis v45 stieg der Rechner mit Haken schon ab Tag 8 aus. Das war zu viel:
zwei und drei Wochen sind gängige Anfragen, und sie hängen nicht davon
ab, ob der Monatspreis schon feststeht — der Monatswert ist dort nur
Zwischenziel der Staffel und wird nie gezeigt.

In der **Tariftabelle** heißt der Block jetzt in beiden Fällen
*Langzeitmiete* und fängt bei vier Wochen an:

* ohne Haken — Zeile „1 Monat · 4 Wochen · 28 Tage" mit Betrag und Frei-km
* mit Haken — Zeile „ab 4 Wochen · 28 Tage" mit *Preis auf Anfrage*

Darunter steht in beiden Fällen der Verweis auf den Preisrechner für
alles zwischen einer und vier Wochen. Die Haftungszeile „pro Monat"
entfällt mit Haken.

Im Einstellungsteil steht unter den beiden Feldern eine **Vorschau**:
7 / 14 / 21 / 28 Tage mit Betrag, umgerechnetem Wochenpreis und Frei-km.
Sie zeigt auch dann Zahlen, wenn kein Monatspreis eingetragen ist, und
sagt dazu, dass geschätzt wird. Mit Haken bleibt der Betrag stehen —
darunter steht „Kunde: auf Anfrage".

Geprüft wird das mit `pruefweb41.js` (240 Fälle Tool gegen Website, jeder
Preis auf den Euro gleich) und `pruefschalter46.js` (der Haken über Tool,
Kundenrechner und Tabelle hinweg).

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
