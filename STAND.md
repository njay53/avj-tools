# AVJ Tools — Projektstand

**Stand: Build 38 · Onepage v38 · 18.08.2026**
Diese Datei zu Beginn eines neuen Chats hochladen. Sie enthält alles, was für die
Weiterarbeit nötig ist — Aufbau, Preisdaten, Fallstricke, Arbeitsablauf.

---

## 1. Was existiert

Zwei getrennte Dinge, die dieselbe Rechenlogik teilen:

| | Wo | Zweck |
|---|---|---|
| **AVJ Tools** | `avj-tools.rent-in-nom.de` (GitHub Pages) | Interne App, Niran allein |
| **Kundenrechner** | rent-in-nom.de, Onepage Custom Code | 9-Sitzer + Transporter, öffentlich |

Dazu ein drittes Projekt in einem eigenen Chat: **Schadenmanager**
(`avj-damage.rent-in-nom.de`), eigenes Repository, hier nicht behandelt.

### Die App (6 Reiter)

1. **Mietdauer** — Tage zwischen zwei Terminen, angefangene Tage aufgerundet
2. **Rabatt** — Prozentwert für rentsoft, 5 Nachkommastellen, Kopierknopf
3. **LB-Preis** — Low-Budget-Klasse (Yaris), ab Build 27 im Aufbau wie 9-Sitzer
4. **9-Sitzer** — Sprinter Tourer / Vito Tourer
5. **Transporter** — Transporter M / XL
6. **Tank** — Tankfehlmenge mit PDF-Export

Reiter lassen sich per langem Druck (420 ms) verschieben, Reihenfolge wird gespeichert.

---

## 2. Harte Randbedingungen

- **Eine einzige HTML-Datei.** Kein Build-Schritt, keine externen Bibliotheken,
  kein CDN. Bilder als Base64 eingebettet. Läuft offline.
- **Safari** ist der Zielbrowser (Mac und iPhone) — nicht Chrome.
- Auf GitHub muss die Datei **`index.html`** heißen.
- Die Datei **`CNAME`** im Repository nicht löschen.
- Kein `structuredClone`, keine neueren JS-Funktionen ohne Rückfallweg.

---

## 3. Preisdaten (Ist-Stand im Code)

### 9-Sitzer

**Sprinter Tourer** — frSaPlus 20 · planKm 0,18 · overKm 0,33
```
tier    130  255  375  475  555  615  650
tierKm  200  400  650  900 1200 1500 1800
dayMoDo  [200,130] [500,150] [800,175] [1200,225]
dayFrSa  [200,150] [500,175] [800,200] [1200,250]
weekend  [200,245] [600,275] [900,330] [1200,395]
SB 1.000 €:  we 25 · tier 15 30 43 54 63 70 75
SB   500 €:  we 60 · tier 30 58 78 90 98 102 105
```

**Vito Tourer** — frSaPlus 10 · planKm 0,22 · overKm 0,37
```
tier    160  315  465  600  730  845  950
tierKm  200  400  650  900 1200 1500 1800
dayMoDo  [200,160] [500,195] [800,230] [1200,275]
dayFrSa  [200,170] [500,210] [800,250] [1200,300]
weekend  [200,275] [600,345] [900,395] [1200,460]
SB 1.000 €:  we 35 · tier 18 36 52 68 82 92 100
SB   500 €:  we 75 · tier 35 68 95 118 134 144 150
```

### Transporter

**Transporter M** (z. B. Renault Trafic L2H1) — frSaPlus 5 · planKm 0,20 · overKm 0,30
```
tier     75  150  225  290  350  395  425
tierKm  100  250  450  650  900 1200 1500
dayMoDo  [100,75]  [400,115] [800,155] [1200,200]
dayFrSa  [100,80]  [400,125] [800,165] [1200,220]
weekend  [200,175] [600,225] [1200,325]        ← nur 3 Stufen
SB 1.000 €:  we 35 · tier 15 30 42 52 62 70 75
SB   500 €:  we 60 · tier 25 50 75 98 118 133 145
```

**Transporter XL** (z. B. Mercedes Sprinter L3) — frSaPlus 10 · planKm 0,26 · overKm 0,37
```
tier    110  220  330  430  520  595  645
tierKm  100  250  450  650  900 1200 1500
dayMoDo  [100,110] [400,155] [800,199] [1200,249]
dayFrSa  [100,120] [400,165] [800,210] [1200,270]
weekend  [200,225] [600,355] [1200,465]        ← nur 3 Stufen
SB 1.000 €:  we 65 · tier 25 50 72 95 115 133 150
SB   500 €:  we 120 · tier 45 90 132 175 212 255 295
```

### Tank

Kraftstoffe: **Super · Super E10 · Diesel**
```
VW Golf 8 Energy 1.5 eTSI          Super E10   45 l
VW Golf 8 Variant Energy 1.5 eTSI  Super E10   50 l
VW Touran Goal 1.5 TSI             Super E10   58 l
VW Touran Energy 1.5 TSI           Super E10   58 l
Skoda Octavia Combi 2.0 TDI        Diesel      47,8 l
```

### LB (Yaris-Klasse)
Tag 1–7: 45 / 85 / 120 / 150 / 175 / 195 / 210 €
Frei-km gesamt: 400 / 700 / 1000 / 1250 / 1450 / 1650 / 1800
Mehr-km 0,15 €/km · Monatsanker 620 € / 3500 km · dazwischen interpoliert

---

## 4. Rechenlogik

**1–2 Tage → Tagespakete.** Zwischen je zwei Paketstufen wird automatisch die
Mitte eingezogen (100/75 + 400/115 ergibt zusätzlich 250/95). Der Rechner wählt
dann die für den Kunden günstigere Variante: nächstgrößeres Paket **oder**
kleineres Paket plus geplante Mehrkilometer.

**Ab 3 Tagen → Staffel** (`tier`), die auf den Wochenpreis zuläuft.
Gesamtpreis steigt monoton, Tagessatz fällt monoton. Über 7 Tage linear
fortgeschrieben mit Faktor 0,92.

**Wochenendtarif** greift bei:
- Abholung Fr ab 11:00 oder Sa
- **und** Rückgabe Mo bis 11:00 **oder** So mit mehr als 30 Stunden Gesamtdauer
- und Gesamtdauer höchstens 96 Stunden

> Die 30-Stunden-Grenze ist der Fix für einen echten Fehler: Sa 09:00 → So 09:00
> ist eine 24-Stunden-Tagesmiete, kein Wochenende. Vorher landete das im WE-Raster.

**Fr/Sa-Zuschlag** (`frSaPlus`) nur bei 1–2 Tagen.

**Öffnungszeiten:** Mo–Fr 8–18, Sa 8–13, So zu.
**Feiertage Niedersachsen** werden gerechnet (Gauß-Formel für Ostern) → geschlossen.
**Heiligabend und Silvester** → verkürzt 8–13, außer sie fallen auf Sonntag.

**Rabatt** (nur intern): Euro- und Prozentfeld halten sich gegenseitig aktuell.
Das zuletzt bearbeitete Feld führt — ändert sich der Grundpreis, zieht das andere nach.

**Preisverschiebung** (nur intern): Prozentwert auf Staffel, Tagespakete, Wochenende
und Fr/Sa-Zuschlag, gerundet auf 5 €. Frei-km, km-Sätze und SB bleiben unberührt.
Monotonie wird nach dem Runden erzwungen.

---

## 5. Fallstricke — bitte lesen

**Die App enthält mehrere gleichnamige Funktionen.** 9-Sitzer und Transporter sind
zwei getrennte IIFEs mit jeweils eigener `renderSettings`, `render`, `CARS` usw.
Der Tank-Reiter hat ebenfalls eine `renderSettings`. Bei Textersetzungen deshalb
**immer den Block eingrenzen**, sonst landet Code im falschen Rechner.
→ Genau so entstand der Fehler, der Build 21 lahmlegte.

**Syntaxprüfung reicht nicht.** `new Function(js)` findet keine Laufzeitfehler.
Ein einziger Fehler bricht das ganze Skript ab, und alles danach läuft nicht mehr —
inklusive Build-Anzeige und Reiter-Sortierung. Deshalb:

```bash
npm install jsdom --silent
node -e "
const {JSDOM,VirtualConsole}=require('jsdom');
const errs=[];
const vc=new VirtualConsole().on('jsdomError',e=>errs.push(e.message));
const dom=new JSDOM(require('fs').readFileSync('avj-tools.html','utf8'),
  {runScripts:'dangerously',pretendToBeVisual:true,virtualConsole:vc,url:'https://x.de/'});
setTimeout(()=>{ console.log(errs.length?errs.join(' | '):'keine Fehler'); process.exit(0); },1000);
"
```

**Weitere Stolpersteine:**
- CSS greift nicht auf `<option>`-Elemente in Safari → Zusatzinfos in den Text schreiben
  (siehe „· Tresor" und „· ausserhalb" bei den Uhrzeiten)
- Das native Datumsformat lässt sich nicht ändern → Wochentag steht daneben in der Beschriftung
- `showPicker()` funktioniert in Safari nicht zuverlässig
- Base64 im `<link rel="icon">` wird von Browsern ignoriert, wenn die Datei lokal liegt

---

## 6. Arbeitsablauf

### App

**In Cowork** (ab Build 24): Ich schreibe direkt `index.html` in
`/Users/niran/Documents/Claude Cowork/avj programme/avj-tools`.
Niran startet dort `hochladen.command` per Doppelklick — das Skript prüft die Datei, liest die
Build-Nummer und überträgt sie ans Repository `njay53/avj-tools`.

Zwei Skripte, zwei Zwecke:

- `hochladen.command` — lädt den ganzen Stand hoch (App, Doku, alles)
- `Kundenpreise aktualisieren.command` — nur die `preise.json`, mit Vergleich
  vorher (siehe Abschnitt 11)

**Ohne Cowork**: Datei als `index.html` über die GitHub-Weboberfläche hochladen
(Add file → Upload files → Commit). Nach ein bis zwei Minuten live.

**Bei hartnäckigem Zwischenspeicher:** `?v=NN` an die Adresse hängen zum Gegenprüfen.
Am iPhone: Einstellungen → Safari → Verlauf löschen, App vom Homescreen entfernen
und neu hinzufügen.

### Kundenrechner (Onepage)
Zwei Custom-Code-Abschnitte auf der Fahrzeugseite, je drei Felder:

```
9sitzer-1-HTML.txt      → HTML-Feld    (Rechner 9-Sitzer)
9sitzer-2-CSS.txt       → CSS-Feld
9sitzer-3-JS.txt        → JS-Feld
transporter-1-HTML.txt  → HTML-Feld    (Rechner Transporter)
transporter-2-CSS.txt   → CSS-Feld
transporter-3-JS.txt    → JS-Feld
```

Namensräume sind getrennt: `avj-` für 9-Sitzer, `avjt-` für Transporter.
Beide Rechner können auf derselben Seite laufen.

**Wichtig:** Das Overlay hängt sich per JavaScript an `document.body`, weil Onepage-
Abschnitte einen eigenen Stacking-Context haben. Ohne das erscheint das Popup
hinter dem nächsten Abschnitt.

Versionskennung unten im Popup: `Rechner v23 · Datum` — dieselbe Nummer wie die App,
damit man sofort sieht, ob beide auf demselben Stand sind.

---

## 7. Infrastruktur

**Domain:** Registrar IONOS, **DNS-Zone bei Onepage** (`ns1/ns2.onepage.io`).
DNS-Einträge deshalb in Onepage pflegen, nicht bei IONOS — dort wirkungslos.

Nötige Einträge:
```
CNAME   avj-tools    njay53.github.io
CNAME   avj-damage   njay53.github.io
CAA     @            0 issue "letsencrypt.org"
```
Der CAA-Eintrag ist Pflicht: ohne ihn erlaubt die Domain nur Sectigo,
GitHub Pages braucht aber Let's Encrypt.

**GA4** ist auf der Website aktiv (Mess-ID in Onepage → Integrationen → Google Tag,
IP-Anonymisierung an). Events der Kundenrechner:
`rechner_geoeffnet` · `fahrzeug_gewechselt` · `preis_berechnet` · `whatsapp_klick`
Benutzerdefinierte Dimensionen angelegt: Kategorie, Fahrzeug, Tage, Tarif;
Messwerte: Preis, Kilometer.
**Die interne App sendet bewusst keine Events**, damit Niran die Kundenstatistik
nicht verfälscht.

**Gespeicherte Daten im Browser (localStorage):**
```
avj_preise_v1            eigene Abweichungen 9-Sitzer (nur Unterschiede)
avjT_preise_v1           eigene Abweichungen Transporter (nur Unterschiede)
avj_kundenpreise_v1      Zwischenspeicher der preise.json vom Server
avj_tabreihenfolge_v1    Reihenfolge der Reiter
tk_fahrzeuge_v2          Fahrzeugliste Tank
tk_tanks_v1              alte Fassung, wird beim Laden übernommen
```

---

## 8. PDF-Export (Tank-Reiter)

Selbst geschriebener PDF-Erzeuger, keine Bibliothek. Helvetica mit WinAnsi-
Kodierung, Zeichenbreiten fest hinterlegt. Das Logo liegt als 1-Bit-Maske mit
Lauflängen-Kompression (1800 px breit, ~23 KB) — gelbe Fläche als Rechteck,
blaue Zeichnung als Maske darüber. Bei 600 dpi noch scharf.

Metadaten enthalten ausschließlich „Autovermietung Jansen" — kein Hinweis auf
Browser oder Werkzeug. Das ist Absicht.

Auf dem Blatt: Logo, Anschrift, Grundlagentabelle, fehlende Menge groß,
Betrag im gelben Balken, Preisquelle mit Zeitpunkt, beide Formeln mit
eingesetzten Zahlen, Hinweis auf die Unschärfe von 2–3 Litern.

---

## 9. Offene Punkte

- **Zentrale Preisliste**: seit Build 26 zur Hälfte erledigt — die App liest
  `preise.json`. Offen: die beiden Kundenrechner umstellen (Build 27), sowie
  LB-Preis und Tank-Fahrzeuge mit aufnehmen.
- **PKW-Rechner** — Fahrzeuge wechseln ständig, deshalb erst sinnvoll mit
  zentraler Preisliste.
- **Onepage-MCP**: Könnte das Kopieren in sechs Felder ersparen. Die Anleitung
  beschreibt nur das Neuerstellen von Seiten, nicht das Bearbeiten von Custom-Code-
  Blöcken. Vor einem Anschluss an die Live-Seite erst an einem Testprojekt prüfen.
- ~~**Vito-Wochenpreis**~~ — am 15.08.2026 entschieden: bleibt bei 950 €. Der
  Unterschied zum Sprinter (650 €) ist gewollt, kein Übertragungsfehler.
- **Feiertage und Tarifzuordnung**: Ein Feiertagsmontag verlängert derzeit nicht
  automatisch den Wochenendtarif. Bewusst offen gelassen — das ist eine
  Preisentscheidung, keine technische.

---

## 10. Zusammenarbeit

- Sprache: Deutsch, direkt, keine Floskeln
- Niran korrigiert Preisannahmen selbst — Vorschläge zur Diskussion stellen,
  nicht als gesetzt behandeln
- Bei Preisfragen: erst rechnen und zeigen, was die Zahlen bedeuten,
  dann bauen. Mehrere Fehler wurden so vorab gefunden
  (2 Tage teurer als 3, der siebte Tag für 5 €, das WE-Raster bei 650 km)
- Build-Nummer bei jeder Auslieferung hochzählen, in App und Kundenrechner gleich
- Nach jedem Umbau den jsdom-Test laufen lassen

---

## 11. Zentrale Preisliste (ab Build 26)

`preise.json` im Repository ist die Preisquelle für Kunden. Abrufbar unter
`https://avj-tools.rent-in-nom.de/preise.json`.

### Drei Stufen beim Laden

1. **Server** — `preise.json` wird beim Start geholt und in localStorage
   zwischengespeichert
2. **gespeichert** — der zuletzt geholte Stand, falls der Server nicht antwortet
3. **eingebaut** — die fest im Code stehenden `CARS`-Blöcke

Der Rechner kann dadurch nie kaputtgehen, nur veralten. Welche Stufe gerade
gilt, steht als kleine Marke oben in den Einstellungen.

Die Datei wird vor der Übernahme geprüft: `tier` und `tierKm` je sieben Werte,
alle Preise Zahlen ≥ 0, Tagespakete und Haftungsstufen vorhanden. Fällt die
Prüfung durch, greift stillschweigend die nächste Stufe.

### Mein Stand gegen Kundenstand

`avj_preise_v1` und `avjT_preise_v1` enthalten ab Build 26 **nur noch die
Abweichungen** vom Kundenstand, nicht mehr den kompletten Satz. Alte Einträge
werden beim ersten Laden automatisch umgestellt.

Änderungen in der App gelten sofort — aber nur auf Nirans Geräten. Weicht
etwas ab, steht ein Hinweis in den Einstellungen mit der Liste der betroffenen
Werte. Nichts geht ungefragt an Kunden.

### Ablauf einer Preisänderung

1. Preis in der App ändern (gilt sofort für mich, Hinweis erscheint)
2. Knopf **„Für Kunden freigeben"** — zeigt alter Wert gegen neuer Wert
3. Bestätigen → `preise.json` landet im Download-Ordner
4. **`Kundenpreise aktualisieren.command`** doppelklicken — holt die Datei aus
   dem Download-Ordner, prüft sie mit `plutil` und Python, zeigt den Vergleich
   nochmal, und lädt erst nach Bestätigung hoch
5. Nach ein bis zwei Minuten rechnen die Kundenrechner damit

Die vorherige Fassung bleibt als `.preise-vorher.json` im Ordner liegen.

### Was noch nicht drin ist

- **Die Kundenrechner selbst** lesen die Datei noch nicht — das ist Build 27.
  Bis dahin rechnen sie mit ihren eingebauten Werten weiter, es ist also
  nichts kaputt, nur noch nicht verbunden.
- **LB-Preis und Tank-Fahrzeuge** stehen weiter nur im Code. Der LB-Bereich
  speichert seine Einstellungen ohnehin nicht — Änderungen dort sind nach
  einem Neuladen wieder weg. Beides bewusst für später.

---

## 12. LB-Rechner (ab Build 27)

Der LB-Reiter sieht und funktioniert jetzt wie 9-Sitzer und Transporter:
gleiche Oberfläche, gleiche Einstellungen, Anbindung an `preise.json`,
Kundenstand-Hinweis und Freigabe-Knopf.

Technisch ist er ein Klon des Transporter-Blocks. Die **CSS-Klassen bleiben
`avjt-`**, nur die Element-IDs heißen `avjL…`. Dadurch ist das Aussehen ohne
doppeltes CSS identisch — bei Änderungen am Aussehen des Transporters ändert
sich der LB-Rechner mit. Das alte `#tool-lb`-CSS ist entfallen.

### Bewusst weggelassen

Der LB-Rechner hat **nur die Preise, die es wirklich gibt**:

| vorhanden | nicht vorhanden |
|---|---|
| Tagespreise 1–7 | Wochenendtarif |
| Frei-km je Mietdauer | Tagespakete Mo–Do / Fr/Sa |
| Mehrkilometer geplant/ungeplant | Fr/Sa-Zuschlag |
| Monatsanker (Preis + Frei-km) | Haftungsstufen (SB) |

Eine Fr→Mo-Miete rechnet also ganz normal als 3 Tage, nicht als Wochenende.
Die Zahlen sind unverändert die des alten LB-Rechners.

### Über sieben Tage

Statt der linearen Fortschreibung mit Faktor 0,92 (wie bei den anderen)
wird beim LB **zwischen Wochen- und Monatspreis interpoliert** — Monatsmieten
sind bei einem Yaris ein realistischer Fall. Über 30 Tage hinaus wird mit
`monthPrice / 30` je Tag weitergerechnet.

Prüfwerte (Stand Build 27): 1 T = 45 € · 7 T = 210 € · 14 T = 335 € ·
30 T = 620 € · 45 T = 930 €.

### Fahrzeuge

Aktuell ein Eintrag, `yaris` / „Low-Budget". Weitere lassen sich im
`CARS`-Block ergänzen, die Fahrzeugauswahl im HTML wächst dann mit.

### Noch offen

Der LB-Rechner ist so gebaut, dass er später ohne zweiten Umbau als
Kundenrechner auf die Website kann — eigener Namensraum, `preise.json`
angebunden. Gemacht wird das erst, wenn das Fahrzeug da ist.

---

## 13. Geänderte Felder leuchten auf (ab Build 28)

Nach einer Preisverschiebung, einem Zurücksetzen oder einem Verwerfen leuchten
in allen drei Rechnern genau die Felder kurz grün auf, deren Wert sich
tatsächlich geändert hat — Rahmen, Beschriftung und Differenzanzeige. Nach
1,7 Sekunden geht es von selbst wieder aus.

Der Sinn: durch die Rundung auf 5 € bewegt sich bei kleinen Prozentwerten
nicht jede Stufe. Bei +2,5 % auf die LB-Preise bleiben 45 € und 85 € stehen,
während 120 € bis 210 € um je 5 € steigen. Das Aufleuchten zeigt sofort,
wo der Sprung angekommen ist.

Die Statusanzeige nennt dazu die Anzahl: `+2,5 % · 6 Werte`.

Technisch: `avjWerte(bodyId)` merkt sich vor der Änderung alle Feldwerte,
`avjBlitz(bodyId, werte)` vergleicht danach und setzt die Klasse `avj-blitz`
auf die betroffene Spalte. Beide Funktionen sind global, damit alle drei
Rechner dieselben benutzen. Grünton `#2E8B4F` wie bei „Gespeichert".

---

## 14. Kundenrechner auf Onepage (Stand v28)

Die sechs Custom-Code-Felder liegen jetzt als Sicherung unter
`avj programme/onepage/`. Vorher existierten sie **nur** bei Onepage.

| Datei | Onepage-Feld | Stand |
|---|---|---|
| `9sitzer-1-HTML.txt` | HTML, 9-Sitzer | unverändert |
| `9sitzer-2-CSS.txt` | CSS, 9-Sitzer | unverändert |
| `9sitzer-3-JS.txt` | JS, 9-Sitzer | **v28** |
| `transporter-1-HTML.txt` | HTML, Transporter | unverändert |
| `transporter-2-CSS.txt` | CSS, Transporter | unverändert |
| `transporter-3-JS.txt` | JS, Transporter | **v28** |

### Versionskennung wieder synchron

Die Kundenrechner standen auf v21, die App auf 28 — die beiden Zähler waren
irgendwann auseinandergelaufen (v23 war ein interner Stand, kein Kundenstand).
Ab jetzt tragen beide dieselbe Nummer. Steht unten im Kunden-Popup dieselbe
Zahl wie in der App, sind beide auf einem Stand.

### Was in den JS-Feldern dazugekommen ist

- **Anbindung an `preise.json`** — dieselbe dreistufige Logik wie in der App:
  Server, dann der gemerkte Stand aus dem Browser, dann die fest im Code
  stehenden Werte. Der Rechner kann dadurch nie kaputtgehen, nur veralten.
- Beide Rechner teilen sich **eine** Lade-Instanz (`window.AVJ_PREISE ||`),
  es wird pro Seitenaufruf nur einmal geladen — geprüft.
- **Kautionshinweis** als abgesetzter Kasten unter der Summe. Der Betrag geht
  **nicht** in den Richtpreis ein. Er kommt aus `preise.json` (Schlüssel
  `kaution`), sonst gilt 300 €.

HTML- und CSS-Felder wurden nicht angefasst; der Hinweis arbeitet mit
Inline-Stilen, damit nur zwei Felder zu ersetzen sind.

### Arbeitsregel

Der Ordner ist die Sicherung — er stimmt nur, wenn der Inhalt auch bei
Onepage eingefügt wurde. Also: Datei ändern → **einfügen** → erst dann gilt
der Ordner als aktueller Stand.

### Ablage

Seit dem 16.08.2026 liegt der Ordner als `avj-tools/onepage/` im Repository und
wandert bei jedem `hochladen.command` mit nach GitHub. Neue Preisgabe entsteht
dadurch nicht — der Code steht ohnehin im Quelltext der Website.

---

## 15. Reiter „Tarife" (ab Build 29, Layout ab Build 30)

Die Preise werden ab jetzt an **einer** Stelle gepflegt: im Reiter `Preise`.
Die Rechner haben keinen Einstellungsbereich mehr.

### Wie das technisch gelöst ist

Die drei Einstellungsbereiche wurden **nicht neu gebaut, sondern umgehängt**.
`AVJ_EDITOR.umhaengen()` verschiebt `avjSetBody`, `avjTSetBody` und
`avjLSetBody` beim Start per `appendChild` in den Reiter. Weil der gesamte
Einstellungs-Code seine Felder über IDs anspricht, funktioniert er unverändert
weiter — Prozentverschiebung, Verwerfen, Zurücksetzen, das grüne Aufleuchten,
der Kundenstand-Hinweis. Kein Code wurde verdoppelt.

Aus den Rechnern sind nur die `<details>`-Aufklapper verschwunden.

### Aufbau

- **Kategorien** in fester Reihenfolge: Transporter, 9-Sitzer, PKW, Low Budget.
  PKW steht schon da und meldet „noch keine Fahrzeuge" — sobald ein PKW-Rechner
  dazukommt, füllt sich die Zeile von selbst.
- **Ein Freigabe-Knopf** statt vorher drei.
- **Vergleich aller Fahrzeuge** auf Knopfdruck: eine Zeile je Fahrzeug,
  Staffelpreis Tag 1–7 und Tagessatz darunter, gruppiert nach Kategorie.
  Zusätzlich eine Kurzzeit-Tabelle, wo es welche gibt.
  Abstände unter 15 % zwischen zwei Klassen werden **gelb markiert**.
- Auf breiten Fenstern (ab 900 px) werden die Eingaberaster größer und luftiger.

### Neue Werte je Fahrzeug

Nur für die Preistabelle auf der Website, der Rechner rechnet nicht damit:

| Feld | Bedeutung |
|---|---|
| `kurzzeit` | Frei-km, 3 und 6 Std. je Mo–Do und Fr/Sa. Nur Transporter. |
| `ahk` | Zuschlag für Kurzzeit, Tag, Wochenende, Woche. **0 = keine AHK.** |
| `kaution` | Kurzzeittarife und Tag/Wochenende. 0 blendet die Zeile aus. |

Verschachtelte Werte werden über `data-pfad` im Eingabefeld adressiert
(z. B. `kurzzeit.moDo.0`) und in `onSettingInput` generisch aufgelöst.

### Fahrzeugstand

| Fahrzeug | AHK (Kurz/Tag/WE/Woche) | Kurzzeit | Kaution |
|---|---|---|---|
| Sprinter Tourer | 0 / 0 / 0 / 0 — **keine AHK** | — | 300 |
| Vito Tourer | 0 / 20 / 45 / 85 | — | 300 |
| Transporter M | 15 / 15 / 35 / 95 | 100 km, 50/65, 55/70 | 150 / 300 |
| Transporter XL | 20 / 20 / 45 / 95 | 100 km, 55/75, 60/80 | 150 / 300 |
| Low Budget | — | — | 300 |

Beim Sprinter Tourer stand im alten PDF „7 Tage (AHK 85,00 €)" — ein
Überbleibsel aus der Vito-Kopie. Der Wagen hat keine Kupplung, der Wert ist
auf 0 gesetzt.

### Beobachtung aus der Vergleichsansicht

Trafic und Sprinter Kasten liegen bei den **Kurzzeittarifen** unter 15 %
auseinander (50/55 und 65/75), beim Tagestarif dagegen bei 75 zu 110 € klar
getrennt. Wer drei Stunden mietet, hat kaum einen Grund zum kleineren Wagen.
Preisentscheidung, steht offen.

### Nachtrag Build 30

**Der Reiter heißt „Tarife".** Nicht „Kalkulation" — der Begriff gehört zum
Projekt Fuhrpark-Rentabilität und würde später kollidieren. Die interne Kennung
bleibt `preise`, damit die gespeicherte Reiter-Reihenfolge weiter passt.

**Volle Bildschirmbreite.** `.content` ist auf 520 px gedeckelt — das ist für
die Rechner am iPhone richtig, für die Tarifpflege am Mac aber viel zu schmal.
`showTool()` setzt jetzt die Klasse `breit` auf `.content`, sobald der
Tarife-Reiter aktiv ist:

| Fenster | Breite | Spalten im Editor |
|---|---|---|
| unter 1000 px | 520 px | eine, wie bisher |
| ab 1000 px | 1380 px | so viele wie bei 320 px Mindestbreite passen |
| ab 1500 px | 1620 px | Mindestbreite 370 px |

Die Klasse wird per JavaScript gesetzt, nicht über `:has()` — das ist in
älteren Safari-Fassungen nicht verlässlich.

**Blockbündelung.** `AVJ_EDITOR.bloecke(bodyId)` fasst nach jedem
`renderSettings` eine Beschriftung mit ihren Rastern in `<div class="pr-block">`
zusammen. Ohne das reißt das mehrspaltige Layout die Überschrift von ihren
Feldern. Beim Transporter entstehen so 16 Blöcke. Hinweis, Prozentfeld,
Kundenstand-Kasten und Knopfzeile bleiben über die volle Breite.

**Aufleuchten sichtbar gemacht.** Das alte `#EAF7EE` war praktisch weiß.
Jetzt kräftiges Markergrün `#8CF0A8` mit dunkler Schrift und grünem Rand,
2,2 Sekunden statt 1,7 — wie ein Textmarker über der Zahl.

---

## 16. Build 31 — Nacharbeit am Tarife-Reiter

Fünf Punkte aus dem Praxistest von Build 30. Alle Änderungen stecken in einem
CSS-Block **ganz am Ende des Stylesheets** (`/* Build 31 · Nacharbeit Reiter
"Tarife" */`). Bewusst dort: was unten steht, gewinnt gegen die Regeln weiter
oben, ohne dass an den gewachsenen Blöcken herumgeschnitten werden muss.

**Der eigentliche Fehler: Spezifität.** `#tool-preise .avj-set-body{display:grid}`
aus Build 30 hat auf breiten Schirmen *alle* Einstellungsbereiche aufgeklappt.
Eine ID im Selektor wiegt schwerer als `.pr-halter > div{display:none}` — die
Ausblendung lief ins Leere. Deshalb war Low Budget "immer offen" und darunter
stand auch noch der Sprinter Tourer. Jetzt hängt das Raster an
`.pr-halter > div.an`, also nur am gewählten Bereich.

**Zweiter Nebeneffekt derselben Umhängerei: die Farbvariablen.** `--blue-deep`,
`--line`, `--ink` und so weiter sind auf `.avj-calc` / `.avjt-calc` definiert.
Sobald `AVJ_EDITOR.umhaengen()` die Bereiche in den Tarife-Reiter zieht, hängen
sie nicht mehr darunter — die Variablen waren leer. Sichtbare Folge: der Knopf
*Anwenden* war weiß auf hellgrau. Der neue Block definiert die Palette erneut auf
`#tool-preise .pr-halter`, `.pr-kopf` und `.pr-vgl` und setzt für den Knopf
zusätzlich eine feste Farbe als Sicherheitsnetz.

> **Falle für später:** Alles, was aus einem Rechner in den Tarife-Reiter
> umgehängt wird, verliert seine CSS-Variablen. Neue Bereiche also entweder
> unter `.pr-halter` mitdefinieren oder feste Farben verwenden.

**Zahlenfelder.** Die 15-px-Regel aus dem `min-width:900px`-Block hat die
13-px-Regel aus dem `min-width:1000px`-Block überstimmt (gleiche Spezifität,
stand aber später in der Datei) — bei sieben Spalten in einem 320-px-Block
wurden vierstellige Beträge abgeschnitten. Jetzt:

| Fenster | Spaltenbreite | Schrift im Feld |
|---|---|---|
| ab 1000 px | mind. 360 px | 13 px, Abstand 5 px |
| 1000–1180 px | mind. 360 px | 12 px, Abstand 4 px |
| ab 1500 px | mind. 400 px | 14 px |

Dazu sind die Pfeilchen von `type=number` im Tarife-Reiter abgeschaltet
(`-webkit-appearance:none`) — sie fressen in Safari Platz und werden nicht
gebraucht. Geprüft wird das automatisch: das Testskript misst je Feld die
Textbreite im Canvas gegen den verfügbaren Platz.

**Alle Preise verschieben.** Die Zeile ist jetzt
`106px minmax(150px,290px) auto` statt `88px 1fr auto` — das Auswahlfeld zog
sich vorher über die ganze Breite.

**Vorschau der Verschiebung.** Statt Fließtext (`45→50 85→90 …`) jetzt Chips:
alter Wert grau durchgestrichen, neuer Wert im selben Markergrün wie das
Aufleuchten der Felder. So gehören Vorschau und Ergebnis sichtbar zusammen.
Das Aufleuchten selbst steht 3,2 Sekunden statt 2,2.

**Prüfung.** Ab Build 31 wird zusätzlich zum jsdom-Lauf mit echtem Chromium
gemessen (`/tmp/sicht.js`): vier Fensterbreiten (1440, 1180, 1024, 430),
je Durchgang wird geprüft, dass genau *ein* Bereich sichtbar ist, der Knopf
*Anwenden* eine Hintergrundfarbe hat, keine Zahl breiter ist als ihr Feld,
die Vorschau Chips erzeugt und nach *Anwenden* Felder aufleuchten.
Build 30 fällt in diesem Test an drei Stellen durch, Build 31 besteht ihn.

---

## 17. Build 32 — Richtung der Preisänderung sichtbar machen

**Bezugspunkt ist der Kundenstand, nicht der Wert von eben.** Ein Feld leuchtet
nach jeder Änderung auf, die Farbe sagt aber nicht "ist gestiegen", sondern
"liegt über bzw. unter dem, was Kunden gerade sehen":

| Farbe | Bedeutung |
|---|---|
| Grün `#7CEF9C` | teurer als der zuletzt veröffentlichte Preis |
| Rot `#FFA6A6` | günstiger als der zuletzt veröffentlichte Preis |
| Grau `#DCE4EC` | genau auf dem Kundenstand (z. B. nach *Auf Kundenstand zurück*) |

Beispiel: 500 € stehen, Kundenstand ist 400 €, ich gehe auf 480 € runter — das
Feld bleibt **grün**, weil 480 immer noch über dem veröffentlichten Preis liegt.
Rot kommt erst unterhalb von 400.

**Technisch.** Neu ist die globale Ablage `AVJ_BASIS`. Jeder Rechner trägt sich
dort mit einer Funktion ein, die das gerade offene Fahrzeug aus `_kundenstand`
liefert — gelesen wird erst beim Aufruf, damit ein nachträglich eintreffender
Serverstand mitzählt. `avjBasisWert(auto, el)` liest zu einem Eingabefeld den
passenden Wert aus diesem Stand.

> **Falle:** `avjBasisWert` ist das Spiegelbild von `onSettingInput`. Wer dort
> eine neue Feldart ergänzt (`data-set`, `data-rate`, `data-sbwe`, `data-pfad`),
> muss sie auch hier ergänzen — sonst bleibt die Markierung farblos statt
> falsch, das ist gewollt: keine Farbe ist besser als eine erfundene.

Die CSS-Klassen heißen bewusst `avj-hoch` / `avj-runter` / `avj-gleich` und
nicht `avj-blitz-rot` — die Aufräumroutine entfernt `avj-blitz` per
Zeichenkette, ein gemeinsamer Namensanfang hätte Reste stehen lassen.

**Vorschau der Verschiebung** nutzt dieselben drei Farben, ebenfalls gegen den
Kundenstand gerechnet. So sieht man vor dem Klick auf *Anwenden*, ob man unter
den veröffentlichten Preis rutscht.

**Aufleuchten jetzt auch für verschachtelte Felder.** `avjFeldName` kannte
`data-pfad` nicht — Kurzzeit, AHK und Kaution haben deshalb nie aufgeleuchtet.
Nachgetragen.

**Pfeile am Prozentfeld.** Build 31 hatte die Spinner pauschal für alle
Zahlenfelder im Reiter abgeschaltet. In den engen Rasterfeldern ist das richtig
(Platzgewinn), beim Prozentfeld nicht — dort sind sie wieder an.

**Knopf "Preisdatei erzeugen".** Steht im Kundenstand-Kasten, wenn nichts
abweicht, und war unerklärt. Jetzt mit Kurzbeschreibung darunter: lädt
`preise.json` mit dem aktuellen Stand herunter, dieselbe Datei, die der
Kundenrechner auf der Website liest — hier nur als Sicherung oder wenn die
Datei auf dem Server fehlt.

**Prüfung** (`/tmp/sicht32.js`, `/tmp/sicht32b.js`): je Fahrzeug einmal +8 %
und einmal −30 %, danach *Auf Kundenstand zurück*. Erwartet wird, dass alle
markierten Felder in genau einer Kategorie landen und keines farblos bleibt.
Alle vier Fahrzeuge bestehen das, Vorschau und Felder stimmen überein.

---

## 18. Offene Punkte (Stand 18.08.2026)

- **Fahrzeuge selbst anlegen** — siehe `PLAN-fahrzeuge.md`. Ausgelöst durch die
  DirectCar-PKW, die alle sechs Monate wechseln. Enthält den Vorschlag für die
  Richtpreise (Vorlage skalieren statt Formel, fünf Ankerwerte) und die
  Umbauten, die dafür nötig sind. Wichtigster davon: die drei fast identischen
  Rechner-Blöcke zu einem zusammenführen, bevor eine vierte Kategorie dazukommt.
- ~~Tariftabelle in die Onepage-Popups~~ — erledigt in v38, siehe Abschnitt 24.
- **Hash-Links für die Kundenrechner** (`#rechner=vito`), damit man einem Kunden
  direkt das richtige Fahrzeug schicken kann.

---

## 19. Build 33 — drei Rechner werden einer

**Von außen ändert sich nichts.** Das ist der Zweck: Schritt 2 aus
`PLAN-fahrzeuge.md`, die Voraussetzung dafür, dass PKW dazukommen können,
ohne eine vierte Kopie anzulegen.

### Vorher / nachher

| | Build 32 | Build 33 |
|---|---|---|
| Zeilen im Dokument | 6.664 | 4.479 |
| Dateigröße | 634 KB | 547 KB |
| Rechnerlogik | 3× fast gleich | 1× `AVJ_RECHNER(CFG)` |

Aus drei Blöcken von je rund 1.200 Zeilen (`avj-` 9-Sitzer, `avjt-`
Transporter, `avjL-` Low Budget) wurde eine Fabrik plus drei
Konfigurationen von je zwölf Zeilen. Ein Fehler ist ab jetzt einmal zu
beheben, nicht dreimal.

### Wie die Fabrik aufgebaut ist

```js
AVJ_RECHNER({
  p:          "avjT",          // Vorsilbe der Element-Kennungen im HTML
  kategorie:  "Transporter",   // Anzeigename, geht auch in die GA4-Ereignisse
  schluessel: "transporter",   // Abschnitt in preise.json
  titel:      "Transporter",   // Überschrift im Freigabe-Dialog
  start:      "m",             // Fahrzeug, das beim Öffnen ausgewählt ist
  speicher:   "avjT_preise_v1",// Schlüssel im localStorage
  autoKlasse: ".avjt-car",     // Fahrzeugknöpfe im festen HTML
  langzeit:   "monat",         // nur Low Budget: ab Tag 8 zum Monatsanker
  autos: { … }                 // die Tarifdaten
});
```

> **Wichtigste Regel innerhalb der Fabrik:** `$("Km")` heißt „das Element
> mit der Kennung P + Km". Kennungen werden dort **immer ohne Vorsilbe**
> geschrieben. Wer das vergisst, spricht das Feld eines anderen Rechners an.

**Tarifarten hängen an den Daten, nicht am Code.** Kein `weekend` im
Datensatz → kein Wochenendtarif. Kein `dayMoDo` → keine Tagespakete. Keine
`sb`-Liste → keine Haftungsstufen, weder im Rechner noch in den
Einstellungen. Genau darüber kommt später PKW dazu: neue Kategorie =
Konfiguration plus Daten, kein neuer Code.

Einzige Ausnahme ist `langzeit`. Über sieben Tage rechnet der Standard mit
`Wochenpreis / 7 × 0,92` weiter; Low Budget interpoliert stattdessen zum
Monatsanker. Das ließe sich auch aus `monthPrice` ableiten — bleibt aber
bewusst eine bewusste Entscheidung je Kategorie und keine Nebenwirkung
eines gesetzten Feldes.

### Nebenbei gefundener Fehler

`document.querySelectorAll(".avjt-car")` suchte **dokumentweit**.
Transporter und Low Budget teilen sich diese Klasse — ein Klick auf ein
Low-Budget-Fahrzeug hat also auch den Transporter umgeschaltet, auf einen
Schlüssel, den er nicht kennt. Sichtbar war das nie, weil nie beide Rechner
gleichzeitig offen sind; in der Konsole standen dafür Fehler. Jetzt sucht
jeder Rechner nur in seinem eigenen Container
(`$("Km").closest('[class*="-calc"]')`) und über `[data-car]` statt über die
Klasse.

Zweite Kleinigkeit: der Kasten „Deine Preise stimmen mit dem Kundenstand
überein" wurde nach einer Eingabe nicht neu gezeichnet — er behauptete
weiter, alles sei in Ordnung, bis irgendetwas anderes ein Neuzeichnen
auslöste. Der Freigabe-Dialog hat die Abweichung immer richtig erkannt, es
war nur die Anzeige. Besteht seit Build 26.

### Sichtbare Änderung im Quelltext

Die Einstellungsfelder des 9-Sitzers tragen jetzt die Klassen `avjt-*`
statt `avj-*`. Beide Sätze sind im Stylesheet gleich definiert — der
Transporter nutzt sie seit jeher. Nachgemessen: die Darstellung ist
pixelgleich.

### Der Goldstandard

Für diesen Umbau ist ein Prüfstand entstanden (`/tmp/gold.js`), der vor dem
Eingriff einmal läuft und danach noch einmal:

- 3 Rechner × alle Fahrzeuge × alle SB-Stufen × 13 Zeiträume × 4 km-Werte
- 13 Zeiträume decken ab: 1/2/3/7/10/30/44 Tage, Wochenende Fr 12→Mo 10,
  Fr→Sa, Sa→Mo, 3 und 6 Stunden, krumme 5,5 Tage
- aufgezeichnet werden Preis, Tariflabel, Badge, Dauerzeile und die
  komplette Aufstellung als HTML
- macht **676 Fälle**, rund 500 KB Vergleichstext

Der Umbau lief in drei Schritten, nach jedem musste der Goldstandard
**Zeile für Zeile identisch** sein: erst Transporter auf die Fabrik, dann
Low Budget, dann 9-Sitzer. Ergebnis: identisch, und die Konsole ist jetzt
fehlerfrei (vorher drei Fehler durch die Fahrzeugknopf-Sache).

> **Für den nächsten Umbau:** `gold.js` vor dem ersten Eingriff laufen
> lassen und die Ausgabe aufheben. Ohne diesen Vergleich ist ein Eingriff
> dieser Größe in der Rechenlogik nicht verantwortbar.

### Was als Nächstes ansteht

Schritte 3 bis 7 aus `PLAN-fahrzeuge.md`: Einstellungsbereich als eigener
Menüpunkt, Fahrzeugliste dynamisch zeichnen (steht intern **und** auf der
Website noch als festes HTML da), Speicherformat und `preise.json` für neue
Fahrzeuge öffnen, dann der Dialog „Neues Fahrzeug" mit Klassen, Ankern und
Ampel.

---

## 20. Build 34 — Fahrzeuge selbst anlegen

Der Punkt, auf den die Builds 33 und 34 hinausliefen: **eine neue Kategorie
ist eine Konfiguration, ein neues Fahrzeug ein Dialog.** Kein HTML, kein Code.

### Auch das HTML-Gerüst wird erzeugt

Bis Build 33 stand das Gerüst jedes Rechners dreimal fest im Dokument —
rund 90 Zeilen je Kategorie, jede Kennung von Hand umbenannt. Jetzt baut
`AVJ_RECHNER` es selbst (`geruest()`), gesteuert über drei neue Angaben:

```js
  k:       "avjt",        // Vorsilbe der CSS-Klassen
  ziel:    "wrapTrans",   // Behälter im Dokument, der gefüllt wird
  frage:   "Was kostet dein Transporter?",
  haftung: false          // nur Low Budget: keine SB-Stufen im Gerüst
```

Auch die **Fahrzeugknöpfe** kommen jetzt aus den Daten (`renderCars()`) statt
aus festem HTML. Ohne das könnte ein selbst angelegtes Fahrzeug gar nicht in
der Auswahl auftauchen. Die Kurzbeschreibung unter dem Namen steht dafür neu
als `example` in den Tarifdaten (beim 9-Sitzer nachgetragen, Text unverändert).

> **Reihenfolge-Falle:** `renderCars()` läuft beim Aufbau — da ist eine
> Kategorie mit ausschließlich selbst angelegten Fahrzeugen noch leer. Die
> kommen erst mit `loadCfg()` aus dem localStorage. Deshalb wird nach
> `loadCfg()` das Startfahrzeug neu bestimmt und die Knopfreihe noch einmal
> gezeichnet. Ohne das war der PKW-Rechner nach dem Neuladen leer.

### PKW-Kategorie

Ein Reiter, ein leerer Behälter, zwölf Zeilen Konfiguration. Neu ist nur,
dass eine Kategorie **leer** sein kann — bis hierher gab es immer mindestens
ein Fahrzeug, also griff nirgends eine Prüfung. `hatAuto()` fängt das jetzt
in `quote()`, `renderSb()`, `renderSettings()` und `render()` ab.

### „+ Neues Fahrzeug"

Im Reiter Tarife neben dem Vergleich. Fünf Anker:

| Feld | wird daraus abgeleitet |
|---|---|
| Tagespreis Mo–Do | Anfang der Staffel |
| Wochenpreis (7 Tage) | Ende der Staffel |
| Wochenendpreis Fr–Mo | die Wochenendstufen |
| Frei-km pro Tag | die Frei-km-Staffel |
| Mehrkilometer ungeplant | geplant folgt im Verhältnis der Vorlage |

**Die Staffel entsteht aus der Formkurve** `[0, 0,220, 0,430, 0,614, 0,776,
0,906, 1]` — dem Anteil des Wegs von Tag 1 zu Tag 7, gemittelt über den
eigenen Bestand. Gegen die echten Preise gehalten liegt sie im schlechtesten
Fall 7,5 % daneben (Vito, Tag 3), beim Transporter M 1,4 %. Wählt man ein
Fahrzeug als Vorlage, wird stattdessen dessen eigene Kurve genommen.

**Alles Übrige behält das Verhältnis der Vorlage:** Preise werden mit dem
Preisfaktor skaliert, Kilometer mit dem km-Faktor. Tagespakete,
Wochenendstufen, Kurzzeittarife, AHK, Monatsanker. **Haftungsstufen und
Kaution werden unverändert übernommen** — sie hängen am Schadenrisiko, nicht
am Mietpreis. (Das war eine offene Frage aus `PLAN-fahrzeuge.md`; sollte es
anders sein, ist es eine Zeile in `AVJ_NEUFZ.baue()`.)

Felder, die die Zielkategorie nicht liest, werden entfernt — ein Monatsanker
aus einer Low-Budget-Vorlage landet nicht im PKW, sonst stünde er als tote
Angabe in `preise.json` und tauchte als Abweichung auf.

**Die Ampel vergleicht mit dem eigenen Bestand**, nicht mit erfundenen
Branchenwerten: grün innerhalb der Spanne der Kategorie (±10 %), gelb bis
±25 %, rot darüber. Ist die Kategorie leer, wird der ganze Fuhrpark
herangezogen; gibt es nichts zu vergleichen, bleibt die Ampel grau und sagt
das auch. Angezeigt werden Wochenfaktor, Wochenende je Tagespreis und Preis
je Frei-km.

### Vierte Markierungsfarbe: blau

Bei einem noch nicht veröffentlichten Fahrzeug gibt es keinen Kundenstand,
gegen den sich „teurer" oder „günstiger" bestimmen ließe — die Felder
leuchteten trotzdem grün, als lägen sie über dem Kundenpreis. Dafür gibt es
jetzt Blau `#CFE0FF`:

| Farbe | Bedeutung |
|---|---|
| Grün | teurer als der veröffentlichte Preis |
| Rot | günstiger als der veröffentlichte Preis |
| Grau | genau auf dem Kundenstand |
| **Blau** | **noch nicht veröffentlicht — kein Vergleichswert** |

### Prüfung der Preisdatei gelockert

`pruefe()` verlangte von **jedem** Fahrzeug Tagespakete, Wochenende und
Haftungsstufen. Ein selbst angelegtes Fahrzeug ohne diese Raster hätte die
**ganze Datei** ungültig gemacht — und Kunden hätten still die alten Preise
weitergesehen. Jetzt sind nur `tier` und `tierKm` Pflicht (je sieben endliche
Zahlen ≥ 0); alles Weitere wird geprüft, **wenn es da ist**. Ein Fahrzeug ohne
Wochenendraster ist erlaubt, ein kaputtes nicht.

> **Noch offen:** die beiden Kundenrechner auf der Website haben eine eigene,
> noch strenge `pruefe()`. Solange die nicht nachgezogen ist, darf in
> `neunsitzer` oder `transporter` kein Fahrzeug ohne Wochenendraster
> veröffentlicht werden — sonst weisen die Kundenrechner die Datei ab und
> fallen auf ihre eingebauten Preise zurück. Für PKW gilt das nicht, den
> Abschnitt lesen sie gar nicht.

### Speicherformat

Hat schon gepasst: `diffGegen()` legt ein Fahrzeug, das der Kundenstand nicht
kennt, vollständig ab; `legeAuf()` baut es beim Laden wieder auf. Ein neues
Fahrzeug erscheint dadurch mit allen Feldern als Abweichung — richtig so, es
ist ja noch nicht veröffentlicht.

### Geprüft

- Goldstandard (676 Fälle) nach jedem Schritt **identisch** zu Build 32
- Reiter vorher/nachher pixelweise verglichen: gleich bis auf die Build-Nummer
- PKW von Hand durchgespielt: anlegen → Auswahl → eigener Rechner → Neuladen →
  Preisverschiebung → Freigabe-Dialog. Keine Konsolenfehler.

### Was noch fehlt

- Kundenrechner auf der Website: Fahrzeugliste ist dort weiter festes HTML,
  ein neues Fahrzeug taucht für Kunden also noch nicht auf. Dazu die
  gelockerte `pruefe()`.
- Einstellungsbereich als eigener Menüpunkt (Klassen, Korridore, Rundung)
- Größenklasse × Bauform für PKW
- Stilllegen statt löschen

---

## 21. Build 35 — PKW-Tarifstruktur, Merkmale, Bearbeiten, Archiv

### Die PKW rechnen anders

Aus den Tariflisten Golf 8 und Golf 8 Variant (Stand 06.2026) — der Rechner
hatte zwei Annahmen, die für PKW nicht stimmen:

| | Transporter / 9-Sitzer | PKW |
|---|---|---|
| Tagespakete | getrennt Mo–Do und Fr/Sa | **ein einziges Raster** |
| Wochenendstufen | 3 bis 4 | **2** (600 und 900 km) |

Beides hängt jetzt an den Daten: `paketRaster(car, frSa)` nimmt `dayFrSa`
nur, wenn es das gibt, sonst `dayMoDo`. Ohne zweites Raster entfällt auch
die Kennzeichnung „Mo-Do" / „Fr/Sa" — es gibt ja nichts zu unterscheiden.
Die Rasterbreite in den Einstellungen richtet sich nach der Anzahl der
Stufen (neue Klasse `p2`).

### Golf und Golf Variant sind drin

Was in den Listen steht, ist eingetragen und **exakt nachgerechnet**:
Tagestarife 100/300/600/900 km, Wochenpreis, beide Wochenendstufen und
alle drei SB-Stufen für Tag, Wochenende und Woche — 14 Werte je Fahrzeug,
alle stimmen auf den Euro.

> **Abgeleitet, weil in den Listen nicht veröffentlicht:**
> * Staffel Tag 2 bis 6 — aus Tages- und Wochenpreis über die Formkurve
> * Frei-km Tag 2 bis 6 — Raster der Transporter (gleiche Spanne 100→1500)
> * SB-Zwischenwerte Tag 2 bis 6 — Form der vorhandenen SB-Staffeln
> * `planKm = overKm`, weil die Listen nur **einen** km-Satz nennen
>
> Diese Werte sind meine Konstruktion, nicht deine Preise. Wenn dir einer
> nicht passt, im Tarife-Reiter überschreiben.

### Merkmale statt Freitext

Vier feste Felder — **Klasse, Karosserie, Kraftstoff, Getriebe** — plus ein
freier Zusatz. Die Beschriftung unter dem Fahrzeugnamen entsteht daraus, in
immer derselben Reihenfolge. Alle sieben Fahrzeuge sind umgestellt:

| Fahrzeug | Beschriftung |
|---|---|
| Sprinter Tourer | 9-Sitzer · Bus · Diesel · Handschaltung · 214 kurz |
| Vito Tourer | 9-Sitzer · Bus · Diesel · Automatik · 119 extralang |
| Transporter M/XL | Transporter bis 3,5 t · Kastenwagen · Diesel · Handschaltung · … |
| Low-Budget | Kleinwagen · Limousine · Benzin · Handschaltung · z. B. Toyota Yaris |
| Golf | Kompaktklasse · Limousine · Benzin · Automatik |
| Golf Variant | Kompaktklasse · Kombi · Benzin · Automatik |

Die Auswahllisten stehen **nicht im Code**, sondern im Browser
(`avj_merkmale_v1`). Über „+ neuer Eintrag …" am Ende jeder Liste kommt
etwas dazu und steht beim nächsten Fahrzeug wieder zur Wahl. Startwerte
werden ergänzt, aber nie etwas entfernt, was du angelegt hast.

### Bearbeiten

Knopfzeile unter der Fahrzeugauswahl: **Bearbeiten** und **Ins Archiv**.
Bearbeiten ändert Name und Merkmale — bewusst **keine Preise**. Die werden
weiter in den Feldern gepflegt; sie hier ein zweites Mal anzubieten würde
nur die Frage aufwerfen, welcher Stand denn gilt.

### Archiv statt Löschen

Ein Fahrzeug wird nie gelöscht. Es verschwindet aus Auswahl, Rechner und
Preisdatei, bleibt aber vollständig erhalten und steht unten im Archiv mit
einem Knopf „Zurückholen". Gespeichert wird es im selben localStorage-Satz
(`{__diff:1, aenderungen:{…}, archiv:{…}}`).

> **Falle:** Ein archiviertes **eingebautes** Fahrzeug steht weiter im
> Kundenstand — `diffGegen` sieht ein Entfernen nicht. Deshalb führt
> `loadCfg()` die Archivliste getrennt und streicht die Fahrzeuge nach dem
> Zusammenbauen wieder aus `CARS`.

### Zwei Fehler, die erst durch die Merkmale sichtbar wurden

**1. Beschreibungen gingen beim Serverabgleich verloren.** Die Merkmale
stehen neu im Code, in `preise.json` vom 16.08. noch nicht — beim Abgleich
gewann die Datei und überschrieb sie still. Preise sollen vom Server
kommen, Beschreibungen nicht. Jetzt gilt: `name`, `example` und `merkmale`
aus dem Code schlagen die ältere Datei, eigene Änderungen aus dem
Bearbeiten-Dialog schlagen beides. Sie tauchen dann als Abweichung auf und
gehen beim nächsten Freigeben mit raus.

**2. Die Fahrzeugknöpfe wurden nach dem Serverabgleich nicht neu
gezeichnet.** Fiel nie auf, weil sich an Namen nie etwas änderte.

### Beim Bauen aufgefallen

Das Ersetzen der Beschriftungen suchte das Ende eines Datensatzes über den
Text `"\n    },"`. Das **letzte Fahrzeug eines Blocks hat kein Komma** —
der Schnitt lief dann über tausende Zeilen weiter und räumte an ganz
anderer Stelle auf. Jetzt wird die Grenze über Klammernzählen bestimmt.
Für künftige Umbauten: bei verschachtelten Literalen nie über Suchtext
abgrenzen.

### Geprüft

- Goldstandard (676 Fälle) **identisch** zu Build 32
- Golf gegen die Tarifliste: 8 Tarif- und 6 SB-Fälle, alle exakt
- Bearbeiten, Archivieren, Neuladen, Zurückholen, Freigabe-Datei ohne
  archiviertes Fahrzeug — durchgespielt, keine Konsolenfehler
- „+ neuer Eintrag" bei den Merkmalen: angelegt, gespeichert, nach dem
  Neuöffnen wieder da

### Weiterhin offen

- Kundenrechner auf der Website: Fahrzeugliste ist dort festes HTML, die
  `pruefe()` dort noch streng. Ein PKW taucht für Kunden also nicht auf.
- Einstellungsbereich als eigener Menüpunkt (Klassen, Korridore, Rundung)
- Größenklasse × Bauform als Preislogik (bisher nur als Beschriftung)

---

## 22. Build 36 — Vorlagenauswahl im Dialog

**Kern der Sache:** die PKW-Vorlage fehlte, weil die Kategorie leer war.
Seit Build 35 stehen Golf und Golf Variant drin — damit man sie auch
findet, ist die Liste jetzt nach Kategorien gruppiert.

| | vorher | jetzt |
|---|---|---|
| Kategorie hat Fahrzeuge | **nur diese**, sonst nichts | eigene oben, andere darunter |
| Kategorie ist leer | alle, ungruppiert | alle unter „andere Kategorien" |
| ohne Vorlage | „nur Mittelwertkurve, sonst nichts" | eigene Gruppe, „nur Staffel und Frei-km" |

Vorausgewählt ist das erste Fahrzeug der eigenen Kategorie. Beides vorher
war zu starr: mit eigenen Fahrzeugen kam man gar nicht mehr an eine fremde
Vorlage heran, und beim ersten Fahrzeug einer neuen Klasse gibt es nun mal
nichts Eigenes.

Kommt die Vorlage aus einer anderen Kategorie, steht das jetzt als Hinweis
unter der Vorschau — keine Warnung, nur damit man es nicht übersieht.

**Beschriftung.** „Vorlage für alles Übrige" heißt jetzt „Vorlage" mit dem
Zusatz „liefert Stufen, Haftung und Kaution".

**Anker folgen der Vorlage.** Sie waren mit den Werten der Vorlage
vorbelegt — aber nur beim ersten Zeichnen. Wechselte man Kategorie oder
Vorlage, blieben die alten Zahlen stehen (in der PKW-Kategorie standen die
Werte des Transporters). Jetzt gehen sie mit, **ohne** zu überschreiben,
was von Hand eingetippt wurde: gemerkt wird, was zuletzt vorbelegt war —
steht das noch unverändert im Feld, darf es weichen.

### Gegenprobe: Golf als Vorlage, Anker des Variant

| | 1 T | 2 T | 3 T | 4 T | 5 T | 6 T | 7 T |
|---|---|---|---|---|---|---|---|
| echt | 100 | 180 | 255 | 320 | 375 | 420 | 455 |
| erzeugt | 100 | 175 | 250 | 320 | 375 | 420 | 455 |

Fünf Euro Abweichung an zwei Stufen, Frei-km exakt, Tagespakete,
Wochenendstufen und alle drei Haftungsstufen aus der Vorlage. Alle drei
Ampeln grün, weil sich die Korridore inzwischen aus den beiden echten
PKW speisen.

### Geprüft

Goldstandard identisch, Golf gegen die Tarifliste (8 Tarif- und 6
SB-Fälle), Bearbeiten/Archiv/Neuladen, Sichtprüfung in vier Breiten —
keine Konsolenfehler.

---

## 23. Build 37 — die PKW gehen online

Die Kundenrechner auf rent-in-nom.de sind auf denselben Stand gebracht und
es gibt einen dritten Block: **PKW**.

### Vier Sachen fehlten auf der Website

1. **Die Fahrzeugknöpfe standen fest im HTML-Feld.** Ein in AVJ Tools neu
   angelegtes Fahrzeug wäre für Kunden unsichtbar geblieben. Sie werden
   jetzt aus den Tarifdaten gezeichnet (`renderCars()`), im HTML steht nur
   noch der leere Behälter.
2. **Der Serverabgleich nahm nur bekannte Fahrzeuge:**
   `for(var k in d.transporter){ if(CARS[k]) … }` — ein neues fiel durch,
   ein archiviertes verschwand nie. Jetzt wird die ganze Gruppe übernommen
   und `carKey` nachgezogen, falls das gewählte Fahrzeug weg ist.
3. **`quote()` setzte voraus**, dass jedes Fahrzeug Fr/Sa-Pakete, ein
   Wochenendraster und Haftungsstufen hat. Jetzt datengesteuert, wortgleich
   mit der App seit Build 35.
4. **Es gab keinen PKW-Rechner.** Der neue Block ist ein Klon des
   Transporters mit den Vorsilben `avjP…` / `avjp-…`, Abschnitt `pkw`,
   Golf und Golf Variant als eingebaute Rückfallebene.

### Die Prüfung der Preisdatei — in allen vier Dateien gleich

`if(!d.neunsitzer || !d.transporter) return false;` war zu eng: sobald ein
Rechner eine andere Gruppe liest, hängt die Gültigkeit der ganzen Datei an
zwei fremden Abschnitten. Jetzt reicht **mindestens eine Gruppe mit
mindestens einem Fahrzeug**; alles Weitere wird geprüft, wenn es da ist.
Das steht jetzt identisch in der App und in allen drei Onepage-Feldern.

> **Falle:** Die drei Blöcke teilen sich auf der Seite EINE Instanz von
> `AVJ_PREISE` (das `window.AVJ_PREISE ||` davor). Welcher Block sie anlegt,
> hängt an der Reihenfolge auf der Seite. Das Lademodul muss deshalb in
> allen drei JS-Feldern **wortgleich** sein — sonst hängt das Verhalten
> davon ab, welcher Rechner zufällig zuerst geladen wird. Das Bauskript
> prüft das und bricht ab, wenn die drei auseinanderlaufen.

### Beschriftungen der Rückfalldaten

Die Werte oben in den JS-Feldern gelten nur, wenn `preise.json` nicht
erreichbar ist. Trotzdem sollen die Knöpfe dann nicht anders aussehen —
beim 9-Sitzer stand die Beschriftung bisher ausschließlich im HTML-Feld.
Alle sechs Fahrzeuge tragen jetzt dieselbe Merkmalzeile wie in der App.

Beim Einbauen wieder dieselbe Falle wie in Build 35: `example` steht nicht
bei jedem Fahrzeug direkt hinter `name`. Nur einzufügen erzeugt zwei Zeilen,
und die alte weiter unten gewinnt. Der Datensatz wird deshalb per
Klammernzählen abgegrenzt und darin aufgeräumt.

### Geprüft — auf einer nachgebauten Fahrzeugseite

Alle drei Blöcke zusammen auf einer Seite, wie bei Onepage:

- `preise.json` wird **einmal** geholt, nicht dreimal ✓
- Golf gegen die Tarifliste: 1 Tag bei 100/300/900 km, 7 Tage, beide
  Wochenendstufen, Freitag als Tagesmiete — alle exakt ✓
- Golf Variant 7 Tage / 1500 km = 455 € ✓
- Kautionshinweis steht im Ergebnis ✓
- **Ein drittes Transporter-Fahrzeug in `preise.json` eingefügt** → taucht
  in der Kundenauswahl auf und rechnet richtig ✓
- **`preise.json` weggenommen** → alle drei fallen auf die eingebauten
  Werte zurück, keine Fehler ✓
- Goldstandard der App (676 Fälle) unverändert ✓

### Noch zu tun beim ersten Mal

`preise.json` auf dem Server hat noch **keinen `pkw`-Abschnitt**. Bis der
da ist, rechnen die PKW auf der Website mit ihren eingebauten Werten —
richtig, aber nicht zentral pflegbar. Einmal *Für Kunden freigeben* im
Reiter Tarife und `Kundenpreise aktualisieren.command` laufen lassen, dann
kommen auch die PKW-Preise aus der Datei.

---

## 24. Onepage v38 — Tariftabellen aus preise.json, Notfallhinweis, 404

Zwei Punkte aus dem Betrieb, beide kundenseitig.

### 24.1 Die Preistabellen waren JPGs

In den Fahrzeug-Popups auf `rent-in-nom.de/fahrzeuge` lagen die Tarifblätter
als hochgeladene Bilder. Jede Preisänderung hieß: Bild bauen, Bild
hochladen, Bild austauschen — und zwar zusätzlich zu `preise.json`. Zwei
Wege für dieselbe Zahl, und der eine hängt an der Hand.

Jetzt baut der Browser die Tabelle aus **derselben** `preise.json`, aus der
auch die Rechner ihre Preise holen. Preis im Tool ändern → *Für Kunden
freigeben* → `Kundenpreise aktualisieren.command`, und Rechner **und**
Tabelle stimmen.

Grundlage ist `entwurf3-tariftabelle.html` aus Build 32 — pixeltreu
übernommen, aber datengetrieben statt abgetippt: Farben `#0018C4`,
`#FDFA61`, `#FF7F7F`, `#DCDCDC`, weiße Lücken statt Rahmen, Logo als
base64, Stand-Datum aus `preise.json`.

**Aufbau:** ein Motorfeld pro Seite, eine Zeile pro Popup.

```html
<div class="avjtab" data-fz="neunsitzer.vito"
     data-titel="Kleinbus Mercedes-Benz *Vito Tourer* 119 (9-Sitzer, extralang, AHK)"></div>
```

`data-fz` ist `gruppe.fahrzeug`, `*Sternchen*` machen den Modellnamen rot.
Ohne `data-titel` kommt der Titel aus `name` und `example`. Das Motorfeld
zeichnet alles, was es findet — beim Laden, wenn die Preise eintreffen, und
per `MutationObserver` für alles, was Onepage nachträglich in die Seite
hängt. Ein neu angelegtes Fahrzeug braucht deshalb nur seine eine Zeile.

**Was gezeigt wird, richtet sich nach den Daten:** Kurzzeittarife nur mit
`kurzzeit`, Wochenende nur mit `weekend`, Haftung nur mit `sb`, AHK-Zeilen
nur mit `ahk`. Low Budget hat kein Tagespaketraster und bekommt stattdessen
die Staffel 1–7 Tage plus Monatspreis. Damit deckt ein Bauplan alle vier
Gruppen ab.

**Eigene Vorsilbe `avjtab-`.** Wichtig, weil `avjp-` seit Build 37 dem
PKW-Rechner gehört — der Entwurf benutzte genau diese Vorsilbe. Ohne
Umbenennung hätten sich Tabelle und PKW-Rechner das CSS zerschossen.

**Fallstrick, der beim Ansehen auffiel:** `.avjtab-z` ist ein
Spalten-Flexbox. Ein `<span>` im Titel wird darin zu einem eigenen
Flex-Element — die Kopfzeile brach dreifach um, statt eine Zeile zu sein
wie auf den JPGs. `display:block` auf `.avjtab-blau` behebt es.

**Nachtrag für ältere Preisdateien:** `kurzzeit`, `ahk` und `kaution`
braucht nur die Tabelle. Fehlen sie beim Fahrzeug in `preise.json`, nimmt
die Tabelle diese drei aus dem Code — sonst wären Kurzzeittarife und
AHK-Zeilen still verschwunden. Preise nie: `tier`, `tierKm`, `dayMoDo`,
`dayFrSa`, `weekend`, `sb` kommen immer vom Server. In der Datei vom 16.08.
(Build 29) sind die drei bei 9-Sitzer und Transporter schon drin, der
Nachtrag greift dort also gar nicht.

### 24.2 „Was, wenn GitHub ausfällt?"

Die Frage war berechtigt, die Antwort ist unspektakulär: die Website liegt
bei Onepage, von GitHub kommt nur `preise.json`. Ist die nicht erreichbar,
nehmen Rechner und Tabellen die eingebauten Werte vom letzten Hochladen —
der Kunde sieht Preise vom vorletzten Stand statt gar nichts. **Ein
Störungshinweis wäre da falsch**, er würde jemanden vertreiben, der einen
gültigen Preis vor sich hat.

Was wirklich weh tut, ist ein Feld, das nicht durchläuft: Skript blockiert,
Browser zu alt, ein Feld bei Onepage versehentlich gelöscht. Dann steht da
ein leerer Kasten. Dafür der **Notfallhinweis** (`stoerung-1/2/3`), ein Feld
pro Seite. Er zeigt normalerweise nichts. Bleibt nach 7 Sekunden ein Rechner
oder eine Tabelle leer, steht dort `05551-54545` und der WhatsApp-Knopf.
Dazu ein `<noscript>` für abgeschaltetes JavaScript.

**Woran er erkennt, dass ein Rechner läuft:** an `avjVer` und `avjSbRow` —
zwei Stellen, die im HTML-Feld leer sind und erst vom JS-Feld gefüllt
werden. Der erste Versuch prüfte die Fahrzeugknöpfe; die stehen aber fest
im HTML-Feld und sind auch dann da, wenn nichts läuft. Der Test schlug
deshalb zu Recht fehl.

**`404.html`** liegt neben `index.html` und `CNAME`. GitHub Pages zeigt sie
bei jeder Adresse auf `avj-tools.rent-in-nom.de`, die es nicht gibt:
„Technische Störung", Nummer, WhatsApp, Link zur Startseite. Ist GitHub
Pages selbst weg, wird auch sie nicht ausgeliefert — dagegen hülfe nur ein
zweiter Anbieter, was sich für eine Datei, die nur Niran benutzt, nicht
lohnt.

### 24.3 Offen zum Entscheiden

Ganz oben in `tariftabelle-2-JS.txt`:

```js
var AVJTAB_GEPLANT = false;
```

Auf `false` zeigt „je extra km" nur den ungeplanten Satz — genau wie die
bisherigen JPGs. Der Rechner unterscheidet aber zwei Sätze: vorab geplante
Mehrkilometer sind günstiger (Vito 0,22 statt 0,37). Auf `true` stehen
beide in der Tabelle. Preisaussage, keine Technikfrage — deshalb erstmal
unverändert gelassen.

### Geprüft

Alles auf einer nachgebauten Fahrzeugseite, drei Rechner plus sieben
Tabellen nebeneinander:

- Jede Zahl in jeder Tabelle gegen die Tarifdaten des Tools abgeglichen —
  sieben Fahrzeuge, 21 bis 24 Werte je Fahrzeug ✓
- `preise.json` wird weiterhin **einmal** geholt, trotz vier Feldern, die
  denselben Lader mitbringen ✓
- Der Lader ist in allen vier JS-Feldern wortgleich (das Bauskript bricht
  sonst ab) ✓
- `preise.json` weggenommen → Rückfall auf die eingebauten Werte, keine
  Konsolenfehler ✓
- Ein nur auf dem Server angelegtes Fahrzeug erscheint in der Tabelle ✓
- Ein unbekanntes `data-fz` → Störungsbox mit Telefonnummer statt leerem
  Kasten ✓
- Serverdatei **ohne** `kurzzeit`/`ahk`/`kaution`, dafür mit geändertem
  Wochenpreis: Kurzzeittarife und AHK-Zeilen bleiben, der Preis kommt vom
  Server ✓
- Notfallhinweis: heile Seite → kein Hinweis; Rechner-JS zerschossen →
  Hinweis mit Nummer; Motorfeld der Tabelle fehlt → Hinweis mit Nummer ✓

### Dateien

| Datei | wohin |
|---|---|
| `onepage/tariftabelle-1-CSS.txt` | Motorfeld, CSS-Kasten |
| `onepage/tariftabelle-2-JS.txt` | Motorfeld, JS-Kasten |
| `onepage/tariftabelle-3-EINBAU.txt` | Anleitung + fertige Zeilen für alle sieben Popups |
| `onepage/stoerung-1-HTML.txt` `-2-CSS` `-3-JS` | Notfallhinweis, ein Feld pro Seite |
| `404.html` | Ordner `avj-tools`, geht mit `hochladen.command` mit |

Bauskripte: `/tmp/bautabelle.js` (zieht die Fahrzeugdaten per
Klammernzählung aus `index.html`, damit nichts abgetippt wird),
`/tmp/bau404.js`. Tests: `/tmp/prueftab.js`, `/tmp/pruefnot.js`,
`/tmp/pruefnachtrag.js`.

---

## 25. Build 38 — die Popup-Zeile kommt aus dem Tool

Nirans Frage nach dem ersten geglückten Einbau: *„woher kommt dann die eine
HTML-Zeile? Musst du die schreiben oder entsteht die selbst?"*

Ehrliche Antwort war: geschrieben, von mir, für die sieben vorhandenen
Fahrzeuge. Das ist genau die Abhängigkeit, die der Dialog *Neues Fahrzeug*
aus Build 34 beseitigen sollte — legt er selbst ein Fahrzeug an, müsste er
mich wieder fragen, wie der interne Schlüssel heißt. Also erzeugt das Tool
die Zeile jetzt selbst.

**Im Reiter Tarife**, in der Knopfzeile neben *Bearbeiten* und *Ins Archiv*,
ein dritter Knopf: **Popup-Zeile**. Er öffnet ein kleines Fenster mit

- einem Feld für die blaue Kopfzeile, vorbelegt aus Name und Merkmalen,
- der fertigen Zeile darunter, die beim Tippen mitläuft,
- *In die Zwischenablage*.

Der Vorschlag lautet z. B. `*Vito Tourer* 119 extralang (9-Sitzer, Bus,
Automatik)`. Er trifft nie das, was im Verkauf draufstehen soll — dafür
immer die Fakten. Überschreiben ist der Normalfall.

Neues Modul `AVJ_ZEILE` mit `zeige(bereich, key)`, `bauen(gruppe, key,
titel)` und `vorschlag(auto, key)`. Es kennt die Onepage-Dateien nicht,
sondern nur die Form der Zeile — ändert sich drüben etwas, ändert sich hier
eine Zeichenkette.

**Zwei Wege in die Zwischenablage:** `navigator.clipboard` braucht eine
sichere Herkunft und fällt aus, wenn `index.html` per Doppelklick aus dem
Finder geöffnet wird. Dann greift `execCommand("copy")` über die
Textauswahl. Schlägt auch das fehl, ist der Text markiert und der Hinweis
sagt ⌘C.

### Ein Fehler, den erst der Test gefunden hat

Anführungszeichen in der Kopfzeile hätten das `data-titel`-Attribut
vorzeitig geschlossen und die Zeile zerrissen. Mein erster Anlauf
maskierte sie mit `\u0022` — was im Browser wieder ein `"` ist, also
nichts tut. Der Test prüft seitdem die Anzahl der Anführungszeichen in
der erzeugten Zeile. Richtig ist `&quot;`.

### Geprüft — der Kreis schließt sich

`pruefzeile.js` fährt beides zusammen: Tool auf einem Server, Fahrzeugseite
auf einem zweiten. Für Vito, Transporter M und Golf Variant je:

1. Fahrzeug im Reiter Tarife wählen, *Popup-Zeile* klicken
2. Kopfzeile eintippen, *In die Zwischenablage*
3. die erzeugte Zeile auf die Fahrzeugseite setzen und nachsehen

Jedes Mal steht die richtige Tabelle da, mit der eingetippten Kopfzeile,
`data-fertig="1"`, ohne Skriptfehler. Dazu der Anführungszeichen-Fall.

Goldstandard: 1.666 Zeilen, identisch mit Build 37.

### Versionsstände auseinandergehalten

- **App:** Build 38
- **Rechner auf Onepage:** v37, unverändert — an ihnen hat sich nichts
  geändert, deshalb kein Neueinsetzen nötig
- **Tariftabellen und Notfallhinweis:** v38

### Beobachtung von der Fahrzeugseite

`rent-in-nom.de/fahrzeuge` führt mehr Fahrzeuge als das Tool kennt: Touran
7-Sitzer, Skoda Octavia Combi TDI, Trafic L2H1 in zwei Motorisierungen,
MAN TGE lang, dazu den Autotrailer. Eine Tariftabelle kann es nur für
Fahrzeuge geben, die im Tool stehen — das ist der nächste Schritt, und mit
*Neues Fahrzeug* plus *Popup-Zeile* geht er ohne mich.
