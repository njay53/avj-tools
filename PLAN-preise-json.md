# Plan: zentrale Preisliste `preise.json`

**Stand: 15.08.2026 · abgestimmt, noch nicht gebaut**

Ziel: Preise stehen an **einer** Stelle. Eine Änderung wirkt nach einem Upload
sowohl in der internen App als auch in beiden Kundenrechnern auf der Website —
aber erst, wenn Niran sie ausdrücklich freigibt.

---

## 1. Wo die Preise heute stehen

| Was | Wo im Code | Zeile |
|---|---|---|
| 9-Sitzer (Sprinter, Vito) | `var CARS = { … }` im 9-Sitzer-IIFE | ~1848 |
| Transporter (M, XL) | `var CARS = { … }` im Transporter-IIFE | ~2825 |
| LB-Preis (Yaris) | `const DEFAULTS = { … }` | ~1665 |
| Tank-Fahrzeuge | `var DEFAULTS = [ … ]` | ~4027 |
| Kundenrechner 9-Sitzer | `9sitzer-3-JS.txt`, eigene Kopie | — |
| Kundenrechner Transporter | `transporter-3-JS.txt`, eigene Kopie | — |

Sechs Kopien derselben Zahlen. Bei einer Preisänderung müssen heute alle sechs
angefasst werden — genau daraus entsteht der Fehler, dass App und Website
auseinanderlaufen.

---

## 2. Die neue Datei

`preise.json` liegt im Repository `njay53/avj-tools` und ist danach unter
`https://avj-tools.rent-in-nom.de/preise.json` abrufbar.

Aufbau — die Struktur bleibt **exakt so wie im Code heute**, nur eine Ebene
darüber zusammengefasst. Dadurch bleiben alle Rechenfunktionen unverändert:

```json
{
  "version": 1,
  "stand": "15.08.2026",
  "gueltigAbBuild": 26,

  "neunsitzer": {
    "sprinter": {
      "name": "Sprinter Tourer",
      "frSaPlus": 20,
      "planKm": 0.18,
      "overKm": 0.33,
      "dayMoDo": [[200,130],[500,150],[800,175],[1200,225]],
      "dayFrSa": [[200,150],[500,175],[800,200],[1200,250]],
      "weekend": [[200,245],[600,275],[900,330],[1200,395]],
      "tier":    [130,255,375,475,555,615,650],
      "tierKm":  [200,400,650,900,1200,1500,1800],
      "sb": [
        { "label": "1.500 €", "we": 0,  "tier": [0,0,0,0,0,0,0] },
        { "label": "1.000 €", "we": 25, "tier": [15,30,43,54,63,70,75] },
        { "label": "500 €",   "we": 60, "tier": [30,58,78,90,98,102,105] }
      ]
    },
    "vito": { … }
  },

  "transporter": { "m": { … }, "xl": { … } },

  "lb": {
    "price": [45,85,120,150,175,195,210],
    "km":    [400,700,1000,1250,1450,1650,1800],
    "monthPrice": 620, "monthKm": 3500, "overKm": 0.15
  },

  "tank": [
    { "name": "VW Golf 8 Energy 1.5 eTSI", "fuel": "Super E10", "tank": 45 }
  ]
}
```

Der Entwurf wurde per Skript aus Build 25 erzeugt, nicht abgetippt. 7,7 KB.

---

## 3. Woher die Preise kommen — die Reihenfolge

Beide Rechner gehen beim Start dieselben drei Stufen durch:

1. **`preise.json` vom Server holen.** Klappt das, gilt sie — und wird
   gleichzeitig in localStorage abgelegt.
2. **Klappt das nicht** (offline, GitHub gestört): der zuletzt gespeicherte
   Stand aus localStorage.
3. **Gibt es auch den nicht** (erster Aufruf ohne Netz): die fest im Code
   eingebauten Werte.

Damit gilt: **Der Rechner kann nie kaputtgehen, nur veralten.** Das ist die
Bedingung, ohne die dieser Umbau nicht zu empfehlen wäre — er hängt sonst
an der Erreichbarkeit von GitHub.

Die interne App zeigt an, aus welcher Quelle gerade gerechnet wird:
`Preise: Server · 15.08.2026` / `Preise: gespeichert vom 02.08.` /
`Preise: eingebaut`.

### Zwischenspeicher

GitHub Pages liefert statische Dateien mit etwa zehn Minuten Verfallszeit aus.
Damit eine Preisänderung nicht bis zu zehn Minuten hängt, wird die Adresse mit
einem Zeitstempel abgerufen:

```js
fetch('https://avj-tools.rent-in-nom.de/preise.json?t=' + Math.floor(Date.now()/60000))
```

Der Wert ändert sich einmal pro Minute — also höchstens eine Minute Verzug,
ohne den Zwischenspeicher ganz auszuhebeln.

---

## 4. Zwei getrennte Preisstände — der Kern des Ganzen

Die App unterscheidet ab Build 26 sauber zwischen:

- **Mein Stand** — die localStorage-Übersteuerung. Gilt nur auf Nirans Geräten,
  sofort wirksam, für Kunden unsichtbar.
- **Kundenstand** — das, was in `preise.json` auf GitHub liegt. Gilt für die
  Rechner auf der Website.

Beide dürfen auseinanderlaufen, das ist Absicht. Aber die App **verschweigt es
nie**: weichen sie voneinander ab, steht dauerhaft ein Hinweis im Reiter, mit
einer Liste, welche Werte betroffen sind. Sonst nennt man am Telefon einen
Preis, den der Kunde online nicht findet.

### Der Speichern-Dialog

Wird ein Preis geändert und auf Speichern gedrückt, fragt die App:

```
  Preis geändert: Vito Tourer · Wochenstaffel

  ○  Nur für mich
     Gilt sofort auf deinen Geräten. Kunden sehen weiter den alten Preis.

  ○  Für Kunden freigeben
     Erzeugt preise.json zum Herunterladen.
     Danach: Datei in den avj-tools-Ordner ziehen, hochladen.command starten.
     In ein bis zwei Minuten ist der neue Preis online.
```

Die App kann selbst nichts ins Netz stellen — sie ist eine Webseite ohne
Schreibrecht auf GitHub. „Freigeben" heißt deshalb: sie erzeugt die fertige
Datei, der Upload bleibt dein bewusster Handgriff. Genau das ist der
gewünschte Zwischenschritt: **nichts geht ungefragt an Kunden.**

Bei „Für Kunden freigeben" zeigt die App vorher noch eine Gegenüberstellung —
alter Wert, neuer Wert, betroffene Fahrzeuge —, damit ein Zahlendreher vor dem
Upload auffällt und nicht danach.

---

## 5. Was sich in welcher Datei ändert

### `index.html` (interne App)

- Neu: Ladefunktion, die `preise.json` holt und auf die vier Bereiche verteilt
  (9-Sitzer, Transporter, LB, Tank).
- Die bestehenden `CARS`- und `DEFAULTS`-Blöcke **bleiben stehen** — sie sind
  ab jetzt die Rückfallebene aus Stufe 3.
- Die localStorage-Schlüssel (`avj_preise_v1`, `avjT_preise_v1`) bleiben und
  sind ab jetzt ausdrücklich „mein Stand".
- Neu: Speichern-Dialog mit den zwei Wegen (siehe oben).
- Neu: Abweichungs-Hinweis, wenn mein Stand ≠ Kundenstand.
- Neu: Knopf **„Auf Kundenstand zurück"**, der die Übersteuerung verwirft.

### `9sitzer-3-JS.txt` und `transporter-3-JS.txt` (Kundenrechner)

- Am Anfang die Ladefunktion mit denselben drei Stufen.
- Der bestehende `CARS`-Block bleibt als Rückfallebene stehen.
- Sonst nichts. Die Rechenlogik wird nicht angefasst.

Die HTML- und CSS-Felder auf Onepage bleiben **unverändert** — nur die beiden
JS-Felder werden einmal ersetzt.

---

## 6. Prüfung vor jedem Upload

1. **JSON-Prüfung.** Ist die Datei lesbar? Sind alle vier Bereiche da? Haben
   `tier` und `tierKm` je sieben Werte? Sind alle Preise Zahlen > 0? Steigen
   die Staffelpreise monoton?
2. **jsdom-Test** wie bisher, zusätzlich mit einer Gegenrechnung: derselbe
   Mietfall einmal mit eingebauten und einmal mit geladenen Preisen — kommt
   dasselbe heraus, ist der Umbau sauber.

Eine kaputte `preise.json` würde sonst beide Rechner gleichzeitig auf die
Rückfallebene werfen, und das fiele erst auf, wenn ein Kunde einen alten
Preis genannt bekommt.

---

## 7. Was Niran tun muss

**Einmalig:** die beiden JS-Felder auf der Onepage-Fahrzeugseite ersetzen
(`9sitzer-3-JS.txt`, `transporter-3-JS.txt`).

**Ab dann bei jeder Preisänderung — einer von zwei Wegen:**

- *Selbst:* Preis in der App ändern → Speichern → „Für Kunden freigeben" →
  Datei in den avj-tools-Ordner ziehen → `hochladen.command`
- *Über Claude:* „Vito Wochenpreis auf 880" → Datei wird geändert und geprüft →
  `hochladen.command`

In beiden Fällen: **ein Upload, und beide Rechner sind aktuell.**

---

## 8. Reihenfolge

| Build | Inhalt | Prüfung |
|---|---|---|
| 26 | `preise.json` erzeugen, App liest sie, Quellenanzeige, Speichern-Dialog, Abweichungs-Hinweis | jsdom + Gegenrechnung |
| 27 | beide Kundenrechner umstellen, Onepage-Felder ersetzen | Testrechnung Website gegen App |

Zwischen 26 und 27 läuft alles normal weiter — die Kundenrechner rechnen so
lange mit ihren eingebauten Werten. Es gibt keinen Zustand, in dem etwas
kaputt ist.

---

## 9. Entscheidungen und offene Punkte

**Entschieden am 15.08.2026:**

- **Vito-Wochenpreis bleibt bei 950 €.** Der auffällige Unterschied zum
  Sprinter (650 €) ist gewollt, kein Übertragungsfehler. Damit ist der
  entsprechende offene Punkt in der STAND.md erledigt.
- **Kein separates Zwischenlager nötig.** Der Speichern-Dialog aus Abschnitt 4
  erfüllt den Zweck: „Nur für mich" ist die Vorstufe, „Für Kunden freigeben"
  der bewusste Schritt nach draußen. Eine zweite Datei `preise-entwurf.json`
  entfällt.

**Offen:**

- **`preise.json` ist öffentlich lesbar**, wie das Repository selbst. Enthält
  dieselben Zahlen, die ein Kunde ohnehin über den Rechner bekommt, plus die
  Tankgrößen. Keine neue Preisgabe gegenüber heute.
- **PKW-Rechner** wird mit dieser Grundlage möglich, ist aber nicht Teil
  dieses Umbaus.

---

## 10. Nebenbefund: SB-Grundstufe

Beim Auslesen des Codes aufgefallen — die Grund-Selbstbeteiligung ist je
Fahrzeug unterschiedlich und stand so nicht in der STAND.md:

| Fahrzeug | Grund-SB (ohne Aufpreis) |
|---|---|
| Sprinter Tourer | 1.500 € |
| Vito Tourer | **2.000 €** |
| Transporter M | 1.500 € |
| Transporter XL | **2.000 €** |

Plausibel bei den teureren Fahrzeugen. Gehört bei Gelegenheit in die STAND.md,
sonst geht es beim nächsten Umbau verloren.
