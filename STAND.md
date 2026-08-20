# AVJ Tools — Projektstand

**Stand: Build 57 · Onepage v54 · 20.08.2026**
Diese Datei zu Beginn eines neuen Chats hochladen. Sie enthält alles, was für die
Weiterarbeit nötig ist — Aufbau, Preisdaten, Fallstricke, Arbeitsablauf.

> ## Reihenfolge beim Ausliefern der Onepage-Felder
>
> Niran setzt die Felder immer in dieser Reihenfolge ein — Dateien also
> auch in dieser Reihenfolge übergeben und benennen:
>
> 1. **Kleinbus/Van** (`9sitzer-*`)
> 2. **PKW** (`pkw-*`)
> 3. **Transporter** (`transporter-*`)
> 4. **Tariftabelle** (`tariftabelle-*`)
>
> Danach `hochladen.command`.

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

> Seit Build 55 ist `tab-motor.js` zweigeteilt: ein **Kernblock**
> (`AVJ_TAB_KERN`, der reine Zeichner) und die Hülle drumherum, die nur
> die Website betrifft. `build55.js` schneidet den Kern heraus und setzt
> ihn zusammen mit `tariftabelle-1-CSS.txt` in `index.html` — so zeigt
> das Tool dieselbe Tabelle wie das Popup. Siehe Abschnitt 44.

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

---

## 26. Build 39 — Abweichungen verstehen und zurücknehmen

Niran meldet acht Abweichungen bei 9-Sitzern und Transportern, obwohl er
nichts geändert hat. Nachgerechnet, nicht geraten — Code aus `index.html`
gegen die veröffentlichte `preise.json` (Build 29, 16.08.) Feld für Feld:

| Abweichung | Ursache |
|---|---|
| 4 × `example` / `merkmale` | neu im Code seit Build 35, in der Datei vom 16.08. noch nicht. Erwartet. |
| Vito `dayMoDo` `dayFrSa` `weekend` `tier` | **Code und Datei sind identisch.** Also kommt die Abweichung aus dem gemerkten Stand auf seinem Gerät. |

Die zweite Gruppe ist der eigentliche Fund. `abweichungen()` vergleicht
`CARS` gegen `_kundenstand` — und `CARS` ist Kundenstand **plus** dem Diff
aus dem localStorage. Sehr wahrscheinlich der Testlauf mit *Alle Preise
verschieben* aus Build 32.

Und dagegen gab es keinen Weg. Ein Handler für `data-kzurueck` war da, aber
**kein Knopf, der ihn auslöst** — und er hätte den ganzen Speicher gelöscht,
also auch selbst angelegte Fahrzeuge und das Archiv.

### Was jetzt geht

Im Kundenstandkasten hat jede Zeile ein **zurücksetzen** — holt genau
diesen einen Wert auf den Stand zurück, den die Kunden sehen. Ab zwei
Werten zusätzlich **Alle zurücksetzen**, mit Rückfrage.

`verwirfAlle()` geht bewusst nur über `_kundenstand` und überspringt
archivierte Fahrzeuge. Selbst angelegte Fahrzeuge stehen dort nicht und
bleiben deshalb unangetastet — sie sind keine verrutschte Zahl, sondern
Arbeit. Statt `localStorage.removeItem` läuft das normale `saveCfg()`.

Ein neu angelegtes Fahrzeug erzeugte bisher **eine Zeile pro Feld** in der
Liste — bei fünfzehn Feldern eine Flut, die auch inhaltlich falsch gelesen
wird. Jetzt eine Zeile: *„Probefahrzeug · neu angelegt"*, mit dem Zusatz
„bei dir angelegt, beim Kunden noch nicht" und ohne Zurücksetzen-Knopf.
Wer es loswerden will, nimmt *Ins Archiv*.

### Reiter umbenannt

*Tarife* heißt jetzt **Tarif Config.** — auch in den drei Stellen im Text,
die auf den Reiter verweisen.

### Geprüft

`pruefverwirf.js`, fünfzehn Proben: Reitername, Ausgangslage ohne
Abweichung, Wert verstellen, Meldung, Knopf, Fahrzeug anlegen, eine Zeile
statt fünfzehn, zurücksetzen, Wert wieder auf Kundenstand, Vito aus dem
gemerkten Stand raus, Testfahrzeug überlebt, *Alle zurücksetzen* ab zwei
Werten, danach keine Abweichung, **Archiv überlebt**, keine Skriptfehler.

Dabei ein Fehler im Test, nicht im Code: `anlegen` und `insArchiv` wechseln
das ausgewählte Fahrzeug. Wer danach ohne neu zu wählen ins Tarifraster
greift, liest das falsche Auto. Der Test wählt jetzt vor jedem Zugriff
explizit.

Goldstandard: 1.666 Zeilen, identisch mit Build 37. Popup-Zeile aus Build
38 unverändert grün.

### Offen, auf Wunsch später

Anhängertarife (Tag / Woche / Wochenende) bekommen eine eigene, einfache
Tabelle für das Popup — ohne km-Stufen und ohne Haftungsraster. Nicht
dringend, wird von Hand gepflegt.

---

## 27. Onepage v39 — der Freigabe-Weg war blockiert

Niran hat das erste Mal freigegeben und `Kundenpreise aktualisieren.command`
gestartet. Ergebnis: **„Die Datei ist kein gueltiges JSON und wurde NICHT
uebernommen."** Damit stand der ganze Weg zum Kunden.

### Die Datei war in Ordnung

Zugriff auf den Download-Ordner geholt und nachgesehen. Die Datei ist
13.648 Bytes, `AVJ Tools Build 39`, Stand 19.08., vier Gruppen, kein BOM,
kein `null`, `file` sagt „JSON data" und `json.load` liest sie ohne Murren.

Der Fehler lag im Skript: geprüft wurde mit **`plutil -lint`**. plutil ist
ein Property-List-Werkzeug; dass es JSON meistens mitliest, ist ein
Nebeneffekt, auf den kein Verlass ist. Warum es auf Nirans Mac abgelehnt
hat, lässt sich von hier aus nicht mehr feststellen — muss es auch nicht:
für JSON ist es schlicht das falsche Werkzeug.

**Jetzt prüft python3**, das weiter unten im Skript ohnehin gebraucht wird,
und die Meldung sagt, *wo* es klemmt statt nur *dass*:

```
✗ Die Datei ist kein gueltiges JSON und wurde NICHT uebernommen.
  Expecting value: line 20 column 17 (char 396)
```

plutil bleibt als Rückfall, falls python3 fehlt — dann aber mit dem
ehrlichen Hinweis, dass das die unzuverlässigere Prüfung ist, und mit der
Möglichkeit weiterzumachen.

### Zweiter Fund im selben Skript

Die inhaltliche Prüfung kannte nur `neunsitzer` und `transporter` und
verlangte dort von **jedem** Fahrzeug `dayMoDo`, `dayFrSa`, `weekend` und
`sb`. Seit den PKW stimmt das nicht mehr: die haben kein getrenntes
Fr/Sa-Raster, Low Budget weder Tagespakete noch Haftungsstufen. Das wäre
die nächste Sackgasse gewesen, sobald ein PKW in eine geprüfte Gruppe
wandert oder ein 9-Sitzer ohne Wochenendtarif dazukommt.

Jetzt gilt dieselbe Regel wie in der App seit Build 37: **`tier` und
`tierKm` sind Pflicht** (7 Werte, nicht fallend), alles andere wird
geprüft, wenn es da ist. Und geprüft werden alle Gruppen, nicht zwei.

Geprüft in einer Sandbox mit seiner echten Datei:

- altes Skript → Ablehnung (reproduziert) ✓
- neues Skript → 88 Änderungen, sauber aufgelistet ✓
- abgeschnittene Datei → Ablehnung mit Zeile und Spalte ✓
- gültiges JSON mit fallendem Staffelpreis → „vito: Staffelpreis faellt bei
  Tag 4 (465 -> 10)" ✓

### Der Rechner-Knopf in der Tabelle

Der Hinweis auf den Preisrechner stand als Fließtext mit Link unter der
Kopfzeile — ordentlich, aber niemand klickt das. Die Tabelle beantwortet
nur drei Mietdauern; alles dazwischen kann nur der Rechner. Jetzt ein
richtiger Knopf in Markenblau mit Untertitel, Fließtext von 13,5 auf 15 px.
Unter 640 px rutscht der Knopf unter den Text.

Der Klick-Handler hörte auf `a[data-rechner]` und musste auf
`[data-rechner]` gelockert werden, damit ein `<button>` auch zählt.

### Versionsstände

- App: **Build 39**
- Rechner auf Onepage: **v37**, unverändert
- Tariftabellen: **v39** — muss neu eingesetzt werden
- Notfallhinweis: **v39** — nur die Versionszeile im Kommentar hat sich
  geändert, Neueinsetzen nicht nötig

### Nebenbei repariert

`prueftab.js` hatte das Rückfall-Datum abgetippt und schlug bei jeder
Versionsänderung fehl. Es liest es jetzt aus dem gebauten Feld.

---

## 28. Build 40 — Zwischenwerte aus 1T und 7T

Niran legt den Touran an, hat aus seiner alten Tarifliste die Anker für
1 Tag, 7 Tage und Wochenende, tippt bei der Haftungsreduzierung 1T und 7T
von Hand ein — und die Tage 2 bis 6 bleiben auf den Werten der Vorlage.
Im Screenshot gut zu sehen:

```
SB 500 €   20   35   51   64   78   88   115
Sprünge       +15  +16  +13  +14  +10  +27   ← der letzte fällt raus
```

Beim **Anlegen** erledigt das der Dialog: aus Tagespreis und Wochenpreis
zieht er die Staffel über die Formkurve des Bestands. **Danach** gab es
das nicht mehr — wer später einen Endwert ändert, stand ohne da.

### Der Knopf

Jede Reihe mit sieben Werten hat jetzt ein kleines **„1T + 7T → Rest"**
in der Beschriftung: Staffelpreis, Frei-km und jede Haftungsstufe. Er
nimmt die beiden Endwerte, die dort stehen, und legt die fünf dazwischen
auf die mittlere Form des Bestands.

Nirans Fall danach:

```
SB 500 €   20   43   62   79   93  105   115
Sprünge       +23  +19  +17  +14  +12  +10   ← fällt gleichmäßig ab
```

### Drei Reihenarten, drei Kurven

Aus dem eigenen Bestand gerechnet, bei jedem Klick neu — sie wandern also
mit, wenn Fahrzeuge dazukommen:

| Art | Mittelkurve (Tag 2–6) | max. Streuung |
|---|---|---|
| `tier` Staffelpreis | 0,220 0,431 0,615 0,775 0,904 | 0,106 |
| `tierKm` Frei-km | 0,128 0,284 0,436 0,612 0,809 | 0,214 |
| `sb` Haftung | 0,248 0,452 0,629 0,786 0,910 | 0,292 |

**Die Haftung streut mit Abstand am stärksten** — kein Wunder, das sind
über Jahre von Hand gesetzte Aufschläge. Gegenprobe: die Mittelkurve auf
die zwölf vorhandenen SB-Reihen angewandt trifft acht davon auf unter
6 %, die Ausreißer sind Sprinter SB 500 (17,9 %, sehr steil) und
Transporter XL SB 500 (19,7 %, sehr flach). Der Knopf liefert also einen
sauberen Ausgangspunkt, keine Wahrheit — Nachtippen bleibt richtig.

Feste Kurven im Code greifen nur, wenn weniger als zwei brauchbare Reihen
zum Mitteln da sind.

### Details, die im Test aufgefallen sind

- Gerundet wird in der Schrittweite des Feldes: Staffelpreis auf 5 €,
  Frei-km auf 50 km, Haftung auf 1 €.
- Nach dem Runden kann es hinten eng werden. Deshalb erst von links
  monoton machen, dann von rechts nachziehen — und wenn dann immer noch
  kein Platz ist, wird gar nichts geschrieben statt einer flachen Reihe.
- Anker bleiben unangetastet, `takeSnapshot()` vorher: *Änderungen
  verwerfen* nimmt den Klick zurück.
- Unbrauchbare Anker (7T ≤ 1T) werden gemeldet, nicht gerechnet.
- Kein Knopf an den Tagespaketen — dort gibt es keine Mitte zu treffen.

### Geprüft

`prueffuell.js`, dreizehn Proben, Nirans Fall eins zu eins nachgestellt:
Touran nach Golf-Vorlage anlegen, SB 500 auf 20/115 setzen, Knopf, Reihe
prüfen. Dazu Rasterung, Widerruf und die Fehlermeldung.

Goldstandard: 1.666 Zeilen, identisch mit Build 37. Popup-Zeile und
Zurücksetzen aus 38/39 unverändert grün.

---

## 29. Build 41 / Onepage v41 — Langzeit bis vier Wochen, danach auf Anfrage

Niran: *„wenn ein Kunde 2 Wochen 3 oder 4 Wochen eingibt müsste der
Wochenpreis definitiv noch mehr fallen."* Nachgerechnet — er hat recht:

```
Vito, alte Rechnung   Woche 1: 950   Woche 4: 893
```

Ab Tag 8 kostete jeder weitere Tag 92 % des Wochen-Tagessatzes. Flach,
ohne Ende, ohne Mengenrabatt. Bei drei Monaten kam eine Zahl heraus, die
mit der Wirklichkeit nichts zu tun hatte.

### Die Entscheidung

Zwei Anker, wie überall sonst im Tool: **Woche** und **vier Wochen**,
dazwischen linear. Ab Tag 29 **kein Automatikpreis mehr**.

Ein Monat sind ab jetzt **28 Tage**. Bisher waren es beim Low Budget 30 —
zwei Monatsbegriffe im selben Tool wären eine Falle. Der Betrag dort
bleibt (620 €), nur die Dauer ändert sich; das Fahrzeug ist ohnehin noch
nicht da.

Ergebnis beim Vito:

| Tage | Preis | je Woche |
|---|---|---|
| 7 | 950 | 950 |
| 10 | 1.220 | 854 |
| 14 | 1.585 | 793 |
| 21 | 2.215 | 738 |
| 28 | 2.850 | 713 |
| 29+ | — | Preis auf Anfrage |

### Woher die Vorbelegung kommt

Kein geratener Faktor, sondern Nirans eigene Zahlen. Low Budget hatte als
einziges Fahrzeug schon einen Monatsanker: **620 € bei 210 € Wochenpreis
= 2,95** und **3.500 km bei 1.800 Wochen-km = 1,94**. Daraus:

- Preis fehlt → **3 × Wochenpreis**
- Frei-km fehlt → **2 × Wochen-km**
- Haftung fehlt → **3 × Wochensatz**

Alles überschreibbar, je Fahrzeug ein Feld. Das leere Feld zeigt den
geschätzten Wert als Platzhalter, damit sichtbar ist, womit gerechnet wird.

### Die Haftung wäre sonst der Bumerang gewesen

Sie lief ab Tag 8 stur linear weiter: Vito SB 500 kostete für vier Wochen
**600 €** gegenüber 150 € für eine Woche. Das hätte den Mengenrabatt beim
Preis wieder aufgefressen. Sie bekommt denselben Anker — jetzt 450 €.

### Vier Stellen, eine Regel

`LZ_TAGE`, `lzPreis`, `lzKm`, `lzSb`, `lzAnteil` stehen **wortgleich** in
`index.html`, in den drei Onepage-Rechnern und im Tariftabellen-Motor.
Das ist die gefährlichste Stelle des ganzen Projekts: rechnet die Website
anders als der Betrieb, fällt es erst auf, wenn ein Kunde anruft.

Deshalb ein eigener Test, `pruefweb41.js`: Tool und Website laufen in zwei
Tabs nebeneinander mit derselben `preise.json`, **240 Fälle** über drei
Kategorien, sechs Fahrzeuge, zwei SB-Stufen, zehn Mietdauern (1 bis 45
Tage) und zwei Kilometerstände. Jeder Preis muss auf den Euro
übereinstimmen. Ergebnis: identisch.

### Tariftabelle

Neuer Block **Langzeit** mit der Zeile „1 Monat · 4 Wochen · 28 Tage",
dem Hinweis *„Über vier Wochen: Preis auf Anfrage"* samt Nummer, und in
der Haftungstabelle eine Zeile **pro Monat (4 Wochen)**. Die Monatszeile
aus dem Low-Budget-Zweig ist entfallen — der neue Block gilt für alle.

### Goldstandard

Bewusst neu gesetzt. Auswertung der 832 Fälle gegen Build 37:

- **bis 7 Tage: 0 Änderungen** ✓ — der Kurzzeitbereich bleibt unangetastet
- über 7 Tage: 191 Fälle geändert, wie beabsichtigt

`gold-b41.txt` ist ab jetzt die Bezugsgröße.

### Was Niran noch tun muss

Die Vorbelegung ist eine Schätzung, kein Preis. Die vier-Wochen-Werte
gehören durchgesehen — er sagte selbst, die Mehrwochenpreise seien
generell noch zu hoch. Das Feld dafür steht in *Tarif Config.* unter
„Langzeit – vier Wochen (28 Tage)", die Haftung daneben unter „28 T".

---

## 30. Build 42 / Onepage v42 — Schalter: Langzeit zeigen oder auf Anfrage

v41 war schon hochgeladen, als Niran auffiel, dass die Vier-Wochen-Preise
noch zu niedrig sind. Er braucht sie also **sofort unsichtbar**, ohne die
eingegebenen Werte wegzuwerfen und ohne Zeit für eine Neukalkulation.

Ein Haken je Fahrzeug, direkt unter den Langzeitfeldern:

> **Langzeit nicht anzeigen — „Preis auf Anfrage"**

Ist er gesetzt, greift **ab Tag 8** dasselbe „Preis auf Anfrage", das es
bisher erst ab Tag 29 gab — im Tool, im Kundenrechner und in der
Tariftabelle. Die hinterlegten Werte bleiben stehen, sie werden nur nicht
gezeigt. Bis sieben Tage ändert sich nichts.

In der Tariftabelle tritt an die Stelle der Monatszeile eine Zeile
*„ab 8 Tagen · Langzeitmiete · Preis auf Anfrage"* mit Telefonnummer, und
die Haftungszeile *pro Monat* entfällt.

Der Haken heißt `lzAnfrage` und steht im Fahrzeugdatensatz — er geht also
mit *Für Kunden freigeben* raus, wie jeder andere Wert auch.

### Eine Kleinigkeit, die auffiel

`onSettingInput` fängt ganz oben mit `parseFloat(el.value)` an und steigt
bei `NaN` aus. Ein Kästchen hat keinen Zahlenwert und wäre nie
angekommen. Der Zweig für den Schalter steht deshalb **vor** der
Zahlenprüfung, und weil ein Kästchen sich über `change` meldet und nicht
über `input`, hängt daran ein zweiter Zuhörer.

### Geprüft

`pruefschalter.js`, sechzehn Proben über alle drei Stellen: im Tool Haken
setzen → 8/14/28 Tage auf Anfrage, 7 Tage unverändert, Haken raus →
Preise wieder da. Danach dieselbe Prüfung auf der Website, wo der Haken
aus `preise.json` kommt — Rechner und Tabelle. Zum Schluss die
Gegenprobe mit einer Datei ohne Haken: Monatsbetrag und Haftungszeile
sind wieder da.

Goldstandard: identisch mit Build 41 — ohne gesetzten Haken ändert sich
nichts.

---

## 31. ~~Offen~~ — Benennungen (erledigt in Build 43, siehe Abschnitt 32)

### 31.1 „Langzeit" erst ab 28 Tagen

Nirans Einwand nach Build 42: *„langzeit würde ich erst ab 28 tagen so
benennen nicht ab 8 tagen"*. Stimmt — acht Tage sind keine Langzeitmiete,
das ist etwas mehr als eine Woche.

Betroffen sind vier Textstellen, keine Rechenlogik:

| wo | heute | Vorschlag |
|---|---|---|
| Tariftabelle, Bandüberschrift | „Langzeit" | „Langzeit" nur über der Monatszeile lassen |
| Tariftabelle bei gesetztem Haken | „ab 8 Tagen · Langzeitmiete" | „ab 8 Tagen · Mehrwochentarif" |
| Rechner, `tarifLabel` bei `anfrage` | „Langzeitmiete" | ab 8 Tagen „Mehrwochentarif", ab 28 „Langzeitmiete" |
| Rechner, Hinweiszeile über 7 Tage | „Langzeittarif: je länger …" | „Mehrwochentarif: je länger …" |

Zu ändern in `index.html`, den drei Onepage-Rechnern und im
Tariftabellen-Motor. Reine Zeichenketten — der Goldstandard darf sich
dabei nicht bewegen, das ist die Probe.

Niran hat es vorerst zurückgestellt („erstmal reicht das so").

### 31.2 Kennzeichnung beim Wochenendtarif

Im Ergebniskasten steht oben rechts als Kennzeichnung **„FR-MO"**. Das ist
die technische Beschreibung des Zeitfensters, nicht der Tarifname. Niran
möchte dort **„WE-Tarif"**.

Die Stelle: in `quote()` setzt der Wochenendzweig `badge = "Fr-Mo"`. Zu
ändern in `index.html` und in den drei Onepage-Rechnern — vier Mal
dieselbe Zeichenkette, keine Rechenlogik.

Zu bedenken: über der Zahl steht bereits „WOCHENENDTARIF" als
`tarifLabel`. Mit „WE-Tarif" daneben stünde es doppelt. Vielleicht besser
die Kennzeichnung ganz weglassen, wenn ohnehin „Wochenendtarif" darüber
steht — oder dort das Zeitfenster ausschreiben („Fr 12:00 – Mo 10:00").
Beim Umsetzen einmal kurz abstimmen.

**Der Goldstandard enthält die Kennzeichnung** — er wird sich also
bewegen. Das ist bei dieser Änderung erwartet und kein Fehler; die Probe
ist, dass sich ausschließlich das Feld `badge` unterscheidet und keine
einzige Zahl.

---

## 32. Build 43 / Onepage v43 — die zwei Benennungen

Beide offenen Punkte aus Abschnitt 31 abgearbeitet. Reine Zeichenketten,
keine Rechenlogik.

### 32.1 „Langzeit" erst ab vier Wochen

Der Schalter aus Build 42 kann schon ab Tag 8 greifen, die harte Grenze
ab Tag 29 — beides landete im selben Zweig und hieß dort pauschal
**Langzeitmiete**. Acht Tage sind aber keine Langzeitmiete.

Jetzt entscheidet die Dauer:

| Dauer | Tarifname |
|---|---|
| 8–27 Tage | **Mehrwochentarif** |
| ab 28 Tagen | **Langzeitmiete** |

Der Begleittext geht mit: unter vier Wochen *„Für diese Mietdauer machen
wir dir ein persönliches Angebot"*, ab vier Wochen *„Ab vier Wochen …"*.
In den Onepage-Rechnern heißt die Hinweiszeile über sieben Tagen jetzt
ebenfalls „Mehrwochentarif". In der Tariftabelle heißt das Band bei
gesetztem Schalter **„Mehrwochen- und Langzeitmiete"** statt „Langzeit",
und die Zeile *„ab 8 Tagen · Langzeitmiete"* wurde zu *„ab 8 Tagen ·
länger als eine Woche"*.

### 32.2 Kennzeichnung beim Wochenendtarif

Stand **„FR-MO"** — über der Zahl steht aber ohnehin schon
WOCHENENDTARIF. Die Kennzeichnung wiederholte also den Tarifnamen,
statt etwas beizutragen. Jetzt steht dort der Zeitrahmen:

> **Fr 12:00 – Mo 10:00**

Das ist deutlich länger als „Fr-Mo". Die Kennzeichnung ist normalerweise
in Großbuchstaben mit weiter Sperrung gesetzt — so hätte sie auf dem
Telefon den Preis weggeschoben. Ab zwölf Zeichen schaltet
`setzeKennzeichnung()` deshalb auf normale Schreibung, engere Sperrung
und 11 px.

**Bewusst als Inline-Stil, nicht als CSS-Klasse.** Eine Klasse hätte
bedeutet, dass Niran auch die drei CSS-Felder der Rechner bei Onepage neu
einsetzen muss. So genügen die JS-Felder. Gemessen bei 390 px Breite:
Kennzeichnung 124 px, passt neben „WOCHENENDTARIF".

### Geprüft

**Goldstandard, 832 Fälle gegen Build 42:**

- **Preise geändert: 0** ✓
- Tarifnamen geändert: 0 — im Goldstandard greift der Schalter nirgends,
  und ab 28 Tagen bleibt es „Langzeitmiete"
- Kennzeichnungen geändert: 120 × `Fr-Mo → Fr 12:00 – Mo 10:00` ✓

Genau das war die Probe: es durfte sich ausschließlich die Kennzeichnung
bewegen.

`pruefnamen.js` prüft zusätzlich die Fälle, die der Goldstandard nicht
abdeckt — mit gesetztem Schalter: Wochenende, 14 Tage, 29 Tage, jeweils
im Tool **und** auf der Website, plus die Schriftumschaltung und die
beiden Textstellen in der Tariftabelle. Alles grün, Tool und Website
identisch.

`pruefweb41.js` (240 Fälle Tool gegen Website) und `pruefschalter.js`
unverändert grün.

---

## 33. Build 44 / Onepage v44 — vier Sachen aus dem Skoda-Durchgang

Niran hat den Skoda Octavia angelegt und dabei vier Dinge gefunden.

### 33.1 Der Kraftstoff fehlte in der Kopfzeile

`AVJ_ZEILE.vorschlag()` baute Klasse, Karosserie und Getriebe zusammen —
**Diesel fiel hinten runter**. In der Kurzbeschreibung unter dem Namen
stand er, in der Kopfzeile der Tabelle nicht. Jetzt dieselbe Reihenfolge
wie in der Kurzbeschreibung.

**Der eigentliche Fallstrick liegt aber tiefer:** `data-titel` steht fest
bei Onepage. Ändert Niran im Tool eine Angabe, wandert das *nicht* mit —
die Zeile müsste neu kopiert werden. Deshalb baut die Tabelle die
Kopfzeile ohne `data-titel` jetzt **im gleichen Stil selbst**, mit rotem
Modellnamen:

```
*Skoda Octavia* (Kompaktklasse · Kombi · Diesel · Automatik)
```

Wer `data-titel` weglässt, hat eine Kopfzeile, die dauerhaft aus
`preise.json` kommt und mitwandert. Wer eine eigene Verkaufszeile will,
setzt `data-titel` und pflegt sie von Hand.

### 33.2 Wochenende mit zwei km-Stufen sah schief aus

Vier Wertspalten stehen zur Verfügung. Die Aufteilung war „erste Stufe
kriegt den Rest": bei zwei Stufen also **3 + 1**. Jetzt gleichmäßig,
Rest nach vorn:

| Stufen | vorher | jetzt |
|---|---|---|
| 2 | 3 + 1 | **2 + 2** |
| 3 | 2 + 1 + 1 | 2 + 1 + 1 |
| 4 | 1 + 1 + 1 + 1 | 1 + 1 + 1 + 1 |

Nur der Zwei-Stufen-Fall ändert sich, drei und vier bleiben wie sie
waren — an den Transportern also nichts.

### 33.3 Der Wochenendanker sagte nicht, welche Stufe gemeint ist

Es ist immer die **kleinste**. Steht jetzt unter der Beschriftung, mit
der km-Zahl der gewählten Vorlage: *„kleinste Stufe, bei der Vorlage
600 km"*. Beim Frei-km-Anker entsprechend *„am ersten Tag"*.

### 33.4 Geplante Mehrkilometer waren nicht setzbar

Bisher gab man nur den **ungeplanten** Satz an; der geplante wurde aus
dem Verhältnis der Vorlage abgeleitet (`planKm / overKm`, ersatzweise
0,62). Jetzt ein zweites, **freiwilliges** Feld daneben. Leer heißt
weiterhin: abgeleitet — und der abgeleitete Wert steht als Platzhalter
im Feld, man sieht also, womit gerechnet würde.

### Geprüft

`pruefanker.js`: Octavia nach Golf-Vorlage anlegen, Merkmale setzen,
geplanten Satz von Hand auf 0,22 — acht Proben, alle grün. Dazu die
Tabellenbilder bei zwei und drei Wochenendstufen gegengesehen.

Goldstandard: **identisch mit Build 43**. Die Änderungen betreffen nur
neu angelegte Fahrzeuge und Beschriftungen, keine bestehende Rechnung.

### Offen — von Niran angesprochen

**Weitere km-Stufe beim Wochenende hinzufügen.** Niran: *„eigentlich
könnte man da auch ein drittes Paket mit 1200 km dazu packen."* Die
Tabelle kann drei Stufen längst darstellen, aber im Tool lässt sich
**keine Stufe hinzufügen oder entfernen** — weder beim Wochenende noch
bei den Tagespaketen. Das wäre ein eigener kleiner Umbau im Reiter
*Tarif Config.*: je Raster ein „+ Stufe" und ein „−" an der letzten.
Noch nicht gebaut.

---

## 34. Build 45 — „hängt einen hinterher"

Niran: *„Ich habe Build 43 hochgeladen, er zeigt mir 42. Jetzt 44
hochgeladen, jetzt zeigt er 43."*

### Erst nachgesehen, dann gebaut

Im Repository auf seinem Mac geprüft — nicht geraten:

```
Arbeitsdatei      var AVJ_BUILD = 44;
HEAD              var AVJ_BUILD = 44;
git status        sauber
HEAD == origin    12a221d == 12a221d
```

**Der Upload ist einwandfrei.** Es liegt am Ausliefern, und dort kommen
zwei Schichten zusammen:

- GitHub Pages baut nach dem Push **ein bis zwei Minuten**.
- Safari behält `index.html` laut Kopfzeile **bis zu zehn Minuten**
  (`Cache-Control: max-age=600`, von GitHub gesetzt, nicht änderbar).

Wer direkt nach dem Skript nachsieht, bekommt zwangsläufig die vorherige
Fassung. Beides ist harmlos — aber man sieht es nicht, man rät. Genau
einmal zu früh geschaut und man hält den Upload für kaputt.

### version.json

`hochladen.command` legt vor dem Commit eine winzige Datei an:

```json
{"build":45,"stand":"19.08.2026 12:04"}
```

Damit lässt sich die Frage beantworten, statt sie zu vertagen — an
beiden Enden:

**Im Skript.** Nach dem Push fragt es alle vier Sekunden bei GitHub
nach, bis dort wirklich die neue Nummer steht, höchstens zwei Minuten.
Danach steht schwarz auf weiß `✓ Build 45 ist online.` Zeigt der Browser
dann etwas anderes, ist es sein Zwischenspeicher — und das sagt der Text
jetzt auch so.

**In der App.** Beim Start holt sie `version.json` mit Zeitstempel in
der Adresse und vergleicht mit der eigenen Nummer. Ist die online-Nummer
höher, erscheint unten ein Streifen:

> **Du siehst Build 45 — online steht Build 99.** Dein Browser zeigt eine
> gemerkte Fassung (hochgeladen 19.08.2026 12:04). **[Neu laden]**

Der Knopf lädt mit `?v=<build>-<zeitstempel>` — ein bloßes Neuladen holt
in Safari häufig wieder die gemerkte Fassung.

Bewusst leise: kein Sperrbildschirm, wegklickbar, und **nur** wenn die
Datei erreichbar ist und eine höhere Nummer nennt. Beim Öffnen per
Doppelklick aus dem Finder passiert gar nichts (`location.protocol`).

### Geprüft

`pruefversion.js`, neun Proben: höhere Nummer → Streifen mit beiden
Nummern und Zeitpunkt; Knopf führt auf eine Adresse mit Zeitstempel;
gleiche Nummer, ältere Nummer, fehlende Datei und kaputtes JSON → jeweils
kein Streifen und **kein Skriptfehler**.

`version.json` ist nicht von `.gitignore` erfasst — geprüft mit
`git check-ignore`.

Goldstandard: identisch mit Build 44.

### Beim ersten Mal

`version.json` entsteht erst beim nächsten `hochladen.command`. Bis
dahin bekommt die App eine 404 und schweigt — genau wie vorgesehen.

---

## 35. Build 46 / Onepage v46 — der Schalter versteckt nur noch den Monat

### Was falsch war

Niran, nach dem Hochladen von Build 45:

> „wenn ich es deaktiviere für den Kunden steht da immer noch ab 8 Tage.
> ich weiß das hatten wir gemacht weil wenn ich keinen monatspreis habe
> der bezug fehlt. hm das heißt ich müsste echt immer erstmal den
> monatspreis angeben. … im tarif rechner sollten 2 und 3 wochen auch
> rechenbar sein."

Der Haken `lzAnfrage` griff ab Tag 8. Das war zu breit. Zwei und drei
Wochen sind gängige Anfragen, und sie hängen **nicht** davon ab, ob der
Vier-Wochen-Preis schon feststeht: fehlt er, wird er geschätzt (Preis
3 × Woche, Frei-km 2 × Woche, Haftung 3 × Wochensatz), und der Wert
dient nur als Zielpunkt der Interpolation — gezeigt wird er nie.

Die Schätzung ist auch nicht daneben. Nirans eigene Zahlen:

| er sagt | die Regel rechnet |
|---|---|
| 450 €/Woche → 14 Tage „eher 730 bis 800" | **750 €** |
| 730 € für 14 Tage → 28 Tage „1.460, vielleicht 50–100 weniger" | **1.350 €** |

Beim Vito (950 €/Woche) kommen 1.585 € für 14 Tage heraus, also Faktor
1,67 statt 2,0 — genau der Korridor, den Niran beschreibt.

### Was jetzt gilt

| Dauer | ohne Haken | mit Haken |
|---|---|---|
| 1–7 Tage | Preis | Preis |
| 8–27 Tage | Preis | **Preis** (vorher: auf Anfrage) |
| 28 Tage | Preis | auf Anfrage |
| ab 29 Tagen | auf Anfrage | auf Anfrage |

Der Haken heißt jetzt **„Vier-Wochen-Preis nicht anzeigen"**, nicht mehr
„Langzeit nicht anzeigen".

### Tariftabelle

Der Block heißt in beiden Fällen **Langzeitmiete** und fängt bei vier
Wochen an. Die Zeile „ab 8 Tagen / länger als eine Woche" gibt es nicht
mehr:

* ohne Haken — „1 Monat · 4 Wochen · 28 Tage" mit Betrag und Frei-km
* mit Haken — „ab 4 Wochen · 28 Tage" mit *Preis auf Anfrage*

Darunter in beiden Fällen der Verweis auf den Preisrechner für alles
zwischen einer und vier Wochen. Die Haftungszeile „pro Monat" entfällt
mit Haken wie bisher.

### Kennzeichnung im Rechner

| Dauer | Kennzeichnung |
|---|---|
| 7 Tage | Wochentarif |
| 8–27 Tage | **Mehrwochentarif** (neu) |
| 28 Tage | Monatstarif |
| ab 29 Tagen / mit Haken ab 28 | Tarifname „Langzeitmiete", Kennzeichnung die Dauer |

Bis Build 45 war „Mehrwochentarif" der **Tarifname** eines Fahrzeugs
ohne Preis. Jetzt ist es eine Kennzeichnung neben einem echten Betrag —
der Tarifname ist dort die Dauer („14 Tage").

### Vorschau im Einstellungsteil

Unter den beiden Langzeitfeldern steht eine Tafel mit vier Punkten:
7 / 14 / 21 / 28 Tage, je mit Betrag, umgerechnetem Wochenpreis und
Frei-km. Sie beantwortet die Frage, die vorher nur der Rechner
beantworten konnte: *was bedeuten diese zwei Anker für die Wochen
dazwischen?*

* ohne Monatspreis steht dabei „Vier-Wochen-Preis geschätzt (3 × Woche)"
* mit Haken bleibt der Betrag stehen und darunter steht „Kunde: auf
  Anfrage" — der Wert wird ja gerade nachkalkuliert, ihn zu verstecken
  wäre unbrauchbar

Sie zieht bei jeder Eingabe mit (`zeichneLzVorschau()` hängt an
`renderSettings` und an beiden Wegen von `onSettingInput`).

### Geändert

| Datei | was |
|---|---|
| `index.html` | Grenze Tag 8 → Tag 28, Kennzeichnung, Vorschau, CSS |
| `9sitzer-3-JS` `transporter-3-JS` `pkw-3-JS` | dieselbe Grenze, dieselbe Kennzeichnung |
| `tariftabelle-2-JS` | `langzeit(c)` neu — ein Block statt zwei Zweigen |

Der Langzeit-Helferblock (`LZ_TAGE`, `lzPreis`, `lzKm`, `lzSb`,
`lzAnteil`) ist **unverändert** und steht weiter wortgleich an fünf
Stellen.

### Geprüft

| Test | Ergebnis |
|---|---|
| `gold.js` | einziger Unterschied zu Build 45: die neue Kennzeichnung „Mehrwochentarif" bei 10 Tagen. **Kein Preis weicht ab.** |
| `pruefweb41.js` | 240 Fälle, Tool und Website auf den Euro gleich, auch bei 8 / 14 / 21 / 27 / 28 / 29 Tagen |
| `pruefschalter46.js` | 37 Proben: 7–27 Tage mit und ohne Haken **identisch**, 28 und 29 auf Anfrage, Tabelle sagt „ab 4 Wochen" und nicht mehr „ab 8 Tagen", Gegenprobe ohne Haken |
| `pruefnamen.js` | auf die neuen Benennungen nachgezogen |
| `prueftab` `prueflangzeit` `pruefzeile` `prueffuell` `pruefanker` `pruefnot` `pruefverwirf` `pruefnachtrag` `pruefversion` | unverändert grün |

`pruefversion.js` liest die Build-Nummer jetzt aus der gebauten Datei,
statt sie abzutippen — sonst fällt der Test bei jedem Build um, ohne
dass etwas kaputt ist.

### Noch offen

* Die Vier-Wochen-Preise selbst will Niran nachrechnen („4 wochen sind
  doch bisschen zu gering"). Der Haken ist genau dafür da.
* Anhängertabelle (Tag / Woche / WE, keine km-Stufen, keine Haftung).
* km-Stufen hinzufügen oder entfernen — z. B. ein drittes
  Wochenendpaket mit 1.200 km für PKW — geht im Tool weiterhin nicht.

---

## 36. Build 47 / Onepage v47 — der verschwundene Touran, das Archiv, Kleinbus/Van

### Der Touran

Niran: *„nach dem update ist aus der tool app der angelegte VW touran
raus."*

Nachgestellt mit `pruefneufz46.js`: Fahrzeug in Build 45 anlegen, Build
46 laden — es überlebt. Auch ein neuer Serverstand, der es nicht kennt,
nimmt es nicht weg. Am Update lag es also **nicht**.

Schuldig ist **„Auf Kundenstand zurücksetzen"**. Der Knopf machte:

```js
window.localStorage.removeItem(_storeKey);
```

Das wirft nicht nur die Preisabweichungen weg, sondern alles, was im
Kundenstand gar nicht steht: **selbst angelegte Fahrzeuge und das
komplette Archiv**. Im Fenster sah man davon nichts — `CARS` behielt die
Schlüssel, das Fahrzeug stand weiter in der Liste. Erst beim nächsten
Laden war es fort. Deshalb wirkte es wie ein Fehler des Updates.

**Jetzt:** nur die Tarife der bekannten Fahrzeuge zurücksetzen, dann
`saveCfg()`. Eigene Fahrzeuge und Archiv bleiben. Dazu eine Rückfrage,
denn der Knopf wirft ja weiterhin alle nicht freigegebenen
Preisänderungen der Kategorie weg.

**Der Touran selbst ist nicht wiederherstellbar** — der Speichereintrag
ist gelöscht. Er muss einmal neu angelegt werden.

### Archiv

Der Kasten war `hidden`, solange nichts drin lag — also genau dann, wenn
man ihn zum ersten Mal sucht. Einen Knopf „ins Archiv gehen" gibt es
nicht, **die Liste ist das Archiv**. Sie steht jetzt immer da, mit
Anzahl bzw. „leer" und einem Satz, wie man hineinkommt.

Die Rückfrage beim Knopf **„Ins Archiv"** gab es schon seit Build 38 —
Niran hatte sie nur nie ausgelöst.

**Fahrzeug auf der Website abschalten:** genau so. Archivieren nimmt es
aus Auswahl, Rechner **und** Preisdatei. Nach *Für Kunden freigeben* →
`Kundenpreise aktualisieren.command` ist es im Kundenrechner weg. Was
**nicht** automatisch geht: der Tariftabellen-Block im Fahrzeug-Popup.
Der steht als `<div class="avjtab" data-fz="…">` bei Onepage und muss
dort raus (in aller Regel ohnehin mitsamt dem Popup).

### Kleinbus/Van

Überall, wo es Beschriftung ist: Reiter im Tool, Kategorie in der
Fahrzeugliste, Frage im Rechner, Knopf und Überschrift auf der Website,
Kategorie in der Auswertung.

**Unverändert bleiben:** Abschnitt `neunsitzer` in `preise.json`,
Element-Kennungen `avj…`, CSS-Klassen `avj-…`, `data-fz="neunsitzer.…"`
in allen Popup-Zeilen. Sonst wären alle Daten und alle Onepage-Felder
ungültig.

Die **Größenklasse je Fahrzeug** bleibt frei: ein Sprinter Tourer 214 ist
weiter ein 9-Sitzer, eine V-Klasse wäre ein Van. Beide stehen jetzt in
der Klassenliste (`START.klasse`).

### Unterzeile am Knopf

`Golf & Golf Variant` → `Alle PKW-Modelle`, dazu `Alle Kleinbusse &
Vans` und `Alle Größen`. Im selben Zug sind die fest eingetragenen
Fahrzeugknöpfe aus `9sitzer-1-HTML` und `transporter-1-HTML` raus — das
JS-Feld baut sie ohnehin aus den Tarifdaten (`renderCars`), die festen
waren nur ein Aufblitzen womöglich falscher Namen und wären bei einem
neuen Fahrzeug stehengeblieben.

**Damit sind erstmals seit v37 auch die HTML-Kästen neu.**

### Geprüft

| Test | Ergebnis |
|---|---|
| `pruefarchiv47.js` | 19 Proben: Zurücksetzen und Neuladen lassen ein selbst angelegtes Fahrzeug stehen, Archiv überlebt das Zurücksetzen, archiviert = raus aus der Preisdatei, Zurückholen, leerer Kasten sichtbar, Rückfragen erscheinen |
| `pruefneufz46.js` | die Reproduktion des Fehlers (gegen Build 45/46) |
| `gold.js` | **identisch mit Build 46**, einziger Unterschied die Build-Nummer |
| alle übrigen Tests | grün, Reiterbeschriftung in den Skripten auf „Kleinbus/Van" nachgezogen |

### Noch offen

* Vier-Wochen-Preise nachrechnen.
* Anhängertabelle.
* km-Stufen hinzufügen oder entfernen (z. B. drittes Wochenendpaket
  1.200 km für PKW).
* Ein archiviertes Fahrzeug räumt seinen Tabellen-Block im Popup nicht
  selbst weg — bewusst so, aber es wäre denkbar, dass die Tabelle bei
  einem Fahrzeug, das der Server nicht mehr kennt, still verschwindet
  statt den Störungshinweis zu zeigen.

---

## 37. Build 48 / Onepage v48 — feste Rollen für die zwei Felder über dem Preis

### Was falsch war

Niran: *„wenn jmd tage, wochenende oder woche oder mehrwochen anklickt,
dass das über dem Preis auch als gelber Button steht. und bei
Tagestarifen rechts dann Tagestarif, so wie bei Woche dann
Wochentarif."*

Es war gemischt:

| Fall | links | rechts (gelb) |
|---|---|---|
| 7 Tage | 7 Tage | **Wochentarif** |
| Wochenende | **Wochenendtarif** | Fr 12:00 – Mo 10:00 |
| 4 Tage | 4 Tage | *(leer)* |
| 1 Tag | **Tagestarif** | Mo-Do |
| ab 29 Tagen | **Langzeitmiete** | 29 Tage |

Mal stand der Tarifname links, mal rechts, mal nirgends. Man konnte
nicht ablesen, nach welchem Tarif gerechnet wurde, ohne zu wissen, wo
man gerade hinschauen muss.

### Was jetzt gilt

**links** die Dauer · **rechts, gelb** die Tarifart. Ausnahmslos.

| Dauer | links | rechts |
|---|---|---|
| 1 Tag (mit Fr/Sa-Raster) | 1 Tag · Mo–Do | Tagestarif |
| 2 Tage | 2 Tage · Mo–Do | Tagestarif |
| 3–6 Tage | 4 Tage | Tagestarif |
| Wochenende | **Fr 12:00 – Mo 10:00** | Wochenendtarif |
| 7 Tage | 7 Tage | Wochentarif |
| 8–27 Tage | 14 Tage | Mehrwochentarif |
| 28 Tage | 28 Tage | Monatstarif |
| ab 29 Tagen | 29 Tage | Langzeitmiete |

Einzige Ausnahme links: beim Wochenende der Zeitrahmen statt „3 Tage
und 21 Std." — das ist die Angabe, die der Kunde sonst nachfragen
müsste. Die Mo–Do/Fr–Sa-Angabe wandert zur Dauer, denn sie sagt etwas
über den Zeitraum, nicht über die Tarifart.

`setzeKennzeichnung()` hat keine Sonderbehandlung für lange Texte mehr
(vorher: ab 13 Zeichen Kleinschreibung). Es bleibt durchgehend bei
Versalien, nur die Schriftgröße gibt nach: ab 12 Zeichen 11,5 px, ab 14
Zeichen 10,5 px.

### Nebenbei

Vor **„auf Anfrage"** stand ein Eurozeichen — „€ auf Anfrage" — und der
Text brach auf dem iPhone in Preisgröße um. Jetzt kein Eurozeichen und
0,6 em. Fiel beim Durchsehen der Kennzeichnungen auf.

### Geprüft

| Test | Ergebnis |
|---|---|
| `gold.js` | 676 Fälle, **kein einziger Preis geändert**. 572 Zeilen unterscheiden sich, alle nur in der Beschriftung — die Zuordnung alt→neu wurde einzeln aufgelistet und stimmt mit der Tabelle oben überein |
| `pruefnamen.js` | 8 Dauern × links und rechts, Tool und Website identisch, kein Feld bleibt leer, Versalien durchgehend |
| `bildbadge.js` | Bilder bei 390 px (iPhone) und 900 px: alle Kennzeichnungen einzeilig, auch „MEHRWOCHENTARIF" und „WOCHENENDTARIF" |
| übrige Tests | grün, drei Erwartungen auf die neue Aufteilung nachgezogen (`pruefnamen`, `pruefschalter46`, `prueflangzeit`) |

### Neues Werkzeug

`bildbadge.js` fährt den Kundenrechner über sechs Mietdauern und zwei
Bildschirmbreiten, macht von jedem Ergebniskasten ein Bild und meldet,
ob die Kennzeichnung umbricht. Nützlich bei jeder Textänderung an dieser
Stelle.

---

## 38. Onepage v49 / Build 49 — WhatsApp nimmt die Eingaben mit

### Die Frage

Niran: *„was könnten wir machen dass wenn der Kunde im Rechner auf
Whatsapp klickt das dann gleich seine im rechner eingegebene Daten
rüber geschickt werden? das ist bestimmt nicht möglich oder?"*

Doch. `wa.me` kennt einen Parameter `?text=`. WhatsApp legt den Text dem
Kunden ins Eingabefeld; abgeschickt wird er erst mit seinem Fingertipp.
Es geht nichts heimlich raus, und er kann vorher noch etwas
dazuschreiben. iPhone, Android und web.whatsapp.com verhalten sich
gleich.

### Die Nachricht

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

Bewusst **nur, was ohnehin im Rechner steht**. Nach Name oder
Telefonnummer wird nicht gefragt — das würde die Nachricht zu einem
Formular machen, und beides steht in WhatsApp ohnehin dran.

| Fall | Nachricht |
|---|---|
| nichts eingetragen | nur „Hallo, ich interessiere mich für ein Fahrzeug bei euch." |
| Rückgabe vor Abholung | dasselbe — kein Gerüst mit Lücken |
| ab 29 Tagen | kein Preis, sondern „bitte um ein Angebot"; Zeitraum und Kilometer bleiben drin |

### Umsetzung

In jedem der drei Rechnerfelder:

* `WA_NUMMER`, `waDatum()`, `waText(r)`, `waLink(r)` direkt vor
  `render()`
* `waLink(r)` steht unmittelbar hinter `var r = quote();` — also **vor**
  allen Abzweigungen, damit der Knopf in jedem Zustand stimmt
* die Nummer steht an genau einer Stelle je Feld

**Build 49 im Tool** ändert nur eine Kleinigkeit: der Rückgabewert im
Anfrage-Fall führt jetzt `km` mit. Ohne das fehlte in der
WhatsApp-Nachricht ausgerechnet bei Langzeit die Kilometerangabe. Die
Regel „Tool und Website geben dasselbe zurück" ist damit wieder
hergestellt; sichtbar ändert sich im Tool nichts.

### Geprüft

| Test | Ergebnis |
|---|---|
| `pruefwa49.js` | 26 Proben: Fahrzeug, Zeitraum, Dauer, km, SB und Preis stehen drin; **Preis in der Nachricht = Preis im Kasten**; Fahrzeug- und SB-Wechsel schlagen durch; leeres Formular und 29 Tage verhalten sich wie beschrieben; alle drei Rechner gefüllt und mit verschiedenen Fahrzeugen |
| `gold.js` | identisch mit Build 48 |
| übrige Tests | grün |

### Was das Tool (noch) nicht hat

Der interne Rechner hat keinen WhatsApp-Knopf — er kennt ja keine
Kundennummer. Denkbar wäre dort ein **„Text kopieren"**, um dieselbe
Zusammenfassung in rentsoft oder eine Mail zu setzen. Nicht gebaut,
nicht besprochen.

---

## 39. Build 50 / Onepage v50 — Hinweis am WhatsApp-Knopf, „Text kopieren" im Tool

### 1. Der Kunde muss es vorher wissen

Niran: *„Nur der Kunde weiß es natürlich noch nicht, wenn er den
whatsapp button noch nicht gedrückt hat. … und auch deutlich genug, das
sie es gleich checken. auch erst eintragen und dann anklicken."*

Ein Hinweis direkt über dem Knopf, gelb auf dem dunklen Ergebniskasten,
der mit dem Zustand wechselt:

| Zustand | Text |
|---|---|
| nichts eingetragen | **Erst oben Zeitraum und Kilometer eintragen.** Dann gehen deine Angaben mit der WhatsApp-Nachricht direkt an uns — ohne Abtippen. |
| alles da | **Deine Angaben werden mitgeschickt.** Fahrzeug, Zeitraum, Kilometer und der Richtpreis stehen fertig in der Nachricht — du musst nichts abtippen. Abgeschickt wird sie erst von dir. |

Dazu die Unterzeile im Knopf: „über WhatsApp" → **„über WhatsApp · mit
deinen Angaben"**, sobald etwas zu übertragen ist.

Der Hinweis wird vom JS erzeugt und inline gestylt — HTML- und
CSS-Kästen bleiben unangetastet, es sind wieder nur die drei JS-Felder
zu tauschen. Der Kasten wird genau einmal angelegt und danach nur noch
befüllt (im Test geprüft: `document.querySelectorAll('#avjWaHin').length === 1`
auch nach mehrfachem Umrechnen).

### 2. „Text kopieren" im internen Rechner

Unter der Aufstellung steht jetzt ein Knopf **Text kopieren** — in allen
vier internen Rechnern. Er legt eine fertige Zusammenfassung in die
Zwischenablage, für rentsoft, eine Mail oder eine Antwort per WhatsApp:

```
Vito Tourer — 9-Sitzer · Bus · Diesel · Automatik · 119 extralang
Abholung: Mo 17.08.2026, 09:00 Uhr
Rückgabe: Mo 24.08.2026, 09:00 Uhr
Dauer: 7 Tage · Wochentarif

Mietpreis Vito Tourer: 950 €
Frei-Kilometer inklusive: 1.800 km
Geplante Fahrleistung: 800 km
Haftungsreduzierung auf 1.000 €: 100 €
Richtpreis gesamt: 1.050 €

Kaution: 300 € — wird bei der Übergabe hinterlegt und nach schadenfreier
Rückgabe erstattet. Sie ist nicht Teil des Mietpreises.
Ungeplante Mehrkilometer bei Rückgabe: 0,37 €/km.

Alle Preise inkl. 19 % MwSt., zzgl. Kraftstoff. Richtwert vorbehaltlich
Verfügbarkeit — maßgeblich ist die Reservierungsbestätigung bzw. der Mietvertrag.
```

**Der entscheidende Kniff:** die Geldzeilen werden aus der *angezeigten*
Aufstellung gelesen (`#…Lines li` mit `.k` und `.v`), nicht ein zweites
Mal gerechnet. Dadurch

* kann der kopierte Text nicht vom Bildschirm abweichen,
* gehen **Zusatzposten und Rabatt automatisch mit**, ohne dass die
  Rechnung hier ein zweites Mal steht,
* bleibt der Textbauer klein.

Ab 29 Tagen steht statt einer Summe „Preis auf Anfrage — ab vier Wochen
wird individuell kalkuliert", Zeitraum und Kilometer bleiben drin.

Neu dafür: `AVJ_KOPIE.text(s, fertig)` — ein Helfer mit den zwei
bekannten Wegen (`navigator.clipboard`, sonst `execCommand` über eine
kurz eingehängte Textauswahl), damit es auch beim Öffnen per
Doppelklick aus dem Finder funktioniert.

### Geprüft

| Test | Ergebnis |
|---|---|
| `pruefkopie50.js` | 20 Proben gegen die **echte Zwischenablage**: jede Geldzeile der Anzeige steht im Text, Gesamtpreis stimmt, Rabatt schlägt durch, 29 Tage ohne erfundenen Preis, Knopf in allen Rechnern |
| `pruefwa49.js` | um den Hinweis erweitert: beide Zustände, Unterzeile, und dass der Kasten nur einmal existiert |
| `gold.js` | identisch mit Build 49 |
| übrige Tests | grün |

### Bekannte Kleinigkeit

`bildkopie.js` (Bildschirmfoto des Knopfes) läuft in dieser Umgebung in
einen Zeitablauf beim Warten auf Schriftarten. Für die Prüfung
unerheblich — `pruefkopie50.js` deckt die Sache ab.

---

## 40. Build 51 — warum in der Tarifpflege Fahrzeuge fehlten

### Die Frage

Niran: *„nach einem update fehlen immer die nachträglich hinzugefügten
autos in der Tarif config. warum ist das so, wo du dann letztes mal
gesagt hast du änderst was und ich muss sie dann aber wieder hinzufügen,
waren sie plötzlich wieder da"*

### Erst nachgesehen, dann geraten

Im Repository steht, seit wann welches Fahrzeug in `preise.json` ist:

| Commit | Zeit | pkw |
|---|---|---|
| 4af5327 | 19.08. 01:25 | golf, golfvariant, **vwtouran** |
| a6ec139 | 19.08. 10:33 | + **skodaoctavia** |
| c02c69e | 19.08. 18:00 | unverändert |

Die beiden waren also **nie weg**. Sie wurden nur nicht angezeigt.

### Der Grund

Reihenfolge beim Laden:

1. Jeder Rechner baut `CARS` aus den eingebauten Werten plus dem, was auf
   diesem Gerät abweicht (`loadCfg`).
2. `AVJ_EDITOR.start()` zeichnet daraus die Fahrzeugliste der
   Tarifpflege.
3. **Danach erst** trifft `preise.json` ein. Die Rechner zeichnen sich im
   Rückruf selbst neu (`renderCars`) — **die Tarifpflege nicht**.

Damit fehlte in der Tarifpflege genau eine Sorte Fahrzeug: die, die es
nur auf dem Server gibt. Und das sind ausgerechnet die freigegebenen —
beim Freigeben löst sich der örtliche Unterschied ja auf, das Fahrzeug
steht danach nur noch in `preise.json`.

Im Rechner-Reiter waren sie die ganze Zeit da. Nur die Liste unter
*Tarif Config.* kannte sie nicht.

**Und das „plötzlich wieder da":** sobald Niran ein Fahrzeug erneut
anlegte oder etwas daran änderte, stand es wieder im örtlichen
Unterschied — und war damit schon vor dem Server bekannt.

### Behoben

`AVJ_EDITOR.aufDatenstand()` zeichnet die Liste neu, sobald die
Preisdatei da ist, und hält die gewählte Zeile fest. Angemeldet wird der
Rückruf **nach** `AVJ_EDITOR.start()`, also nach den vier Rechnern — die
Rückrufe laufen in der Reihenfolge ihrer Anmeldung, so ist `CARS` fertig,
bevor die Tarifpflege es abliest.

### Zweiter Fall: gar keine Preisdatei

Kommt sie nicht an (kein Server **und** kein Zwischenspeicher — frischer
Browser, gelöschter Verlauf, anderes Gerät, dazu ein langsames GitHub
direkt nach dem Hochladen), bleibt nur der eingebaute Stand. Dann fehlen
die Fahrzeuge tatsächlich — unvermeidlich, sie stehen ja nur in der
Datei. Es darf aber nicht stillschweigend passieren:

> **Die Preisdatei konnte nicht geladen werden.** Hier stehen gerade nur
> die Fahrzeuge, die fest im Programm sind — alles, was du selbst
> angelegt und freigegeben hast, fehlt. **Nichts ändern, sondern neu
> laden.** … [Neu laden]

Der Knopf lädt mit Zeitstempel in der Adresse.

### Dritter Punkt: ein Fußangel im hochladen.command

Nach jedem Upload stand dort der Rat *„Einstellungen → Safari → Verlauf
löschen"*. Das löscht auch den Speicher der App: **nicht freigegebene
Fahrzeuge, das Archiv und den Zwischenspeicher der Preisdatei** — also
genau das, was den Ausfall oben auffängt. Der Rat ist raus, stattdessen
steht dort eine Warnung. Die `?v=`-Adresse reicht ohnehin.

### Geprüft

| Test | Ergebnis |
|---|---|
| `pruefquelle51.js` | **neu.** Fahrzeuge nur in `preise.json`, drei Fälle: schneller Server → sie sind da (mit Build 50 **nicht** — der Fehler ist damit belegt); langsamer Server ohne Zwischenspeicher → sie fehlen, aber mit Warnung; mit Zwischenspeicher → sie überstehen auch den langsamen Server |
| `gold.js` | identisch mit Build 50 |
| übrige Tests | grün |

### Eigener Fehler bei den Tests

`pruefarchiv47.js` und `pruefkopie50.js` kopierten ihren eigenen Build
nach `/tmp/srv/index.html` und ließen ihn dort liegen. Ein danach
gestarteter `gold.js` maß dann den **falschen Build** — die Läufe für
Build 49 und 50 waren dadurch wertlos (sie verglichen zweimal Build 47).
Beide Tests nehmen jetzt, was in `/tmp/srv/index.html` liegt; der
Aufrufer legt den zu prüfenden Build hin. Nachgeholt: Build 50 gegen
Build 51 sauber verglichen, 0 Unterschiede.

### Onepage

**Unverändert bei v50.** Diese Runde betrifft nur `index.html` und
`hochladen.command`.

---

## 41. Build 52 / Onepage v51 — die Kopfzeile kommt aus dem Tool

### Was Niran sah

| | |
|---|---|
| im Tool benannt | VW Golf 8 Energy Variant |
| Rechner-Knopf | VW Golf 8 Energy Variant jetzt berechnen |
| blaue Kopfzeile | PKW Volkswagen **Golf Variant** 8 (Kombi, Automatik) |

Dazu: *„was macht er eigentlich immer rot?"* und *„woher holt die Tabelle
das? sind das noch die Sachen, die du von meinen alten Vorlagen
übernommen hast?"*

**Ja.** Beim Umstieg von den JPG-Tabellen habe ich seine alten
Überschriften übernommen und als `data-titel` in jede Popup-Zeile
geschrieben. Die steht seitdem fest bei Onepage. Und rot wurde, was
zwischen `*Sternchen*` stand — mal „Golf Variant", mal nur „M". Daher
wirkte es willkürlich.

### Behoben

Der Motor kann die Kopfzeile längst selbst bauen. Nur erzeugte der Knopf
*Popup-Zeile* **immer** eine Zeile mit `data-titel`. Das dreht sich um:

| | |
|---|---|
| Normalfall | `<div class="avjtab" data-fz="pkw.golfvariant"></div>` |
| Kopfzeile | Name + Kurzbeschreibung aus `preise.json`, **Name rot** |
| Ausnahme | Haken „Eigene Kopfzeile schreiben" → wieder mit `data-titel` |

Im Dialog steht jetzt eine **Vorschau der blauen Kopfzeile**, inklusive
Rotfärbung — damit muss niemand raten, was die Sternchen tun.

Wer das Rot gar nicht will: `var AVJTAB_ROT = false;` ganz oben in
`tariftabelle-2-JS.txt`. Die Sternchen verschwinden in beiden Fällen.

`AVJ_ZEILE.autoTitel()` im Tool und der Titelbau in `tab-motor.js` sind
**wortgleich** — sonst zeigt die Vorschau etwas anderes als die Seite.

### Beim Testen gefunden: das Tool zeigte selbst den alten Namen

Auf einem frischen Browser stand im Tool weiter „Golf Variant", obwohl in
`preise.json` längst „VW Golf 8 Energy Variant" steht.

Schuld war eine Regel aus Build 35:

```js
var BESCHREIBEND = ["name", "example", "merkmale"];
// … für eingebaute Fahrzeuge IMMER aus dem Programmtext,
//    solange der Nutzer das Feld auf diesem Gerät nicht angefasst hat
```

Der Gedanke damals: liefere ich in einem neuen Build eine bessere
Beschreibung mit, soll sie nicht von einer alten `preise.json`
überschrieben werden. Inzwischen pflegt Niran die Beschreibungen im Tool
und gibt sie frei — die Datei ist damit per Definition der neuere Stand.
Die Regel ist raus, die Datei gewinnt. Eigene, noch nicht freigegebene
Änderungen stehen weiter im Diff und haben Vorrang (`legeAuf`).

### Zu tun bei Onepage

In allen sieben Fahrzeug-Popups das ` data-titel="…"` aus der Zeile
löschen. Die fertigen Zeilen stehen in `tariftabelle-3-EINBAU.txt`.

### Geprüft

| Test | Ergebnis |
|---|---|
| `pruefkopf52.js` | **neu**, 15 Proben: Kopfzeile = Name aus `preise.json`; **rot ist genau der Name**; Kopfzeile und Rechner-Knopf nennen dasselbe Fahrzeug; Umbenennen schlägt in beide durch; `AVJTAB_ROT=false` färbt nichts und lässt den Text vollständig; `data-titel` wird weiterhin beachtet; die Vorschau im Tool stimmt Zeichen für Zeichen mit der Seite überein |
| `pruefzeile.js` | auf den Haken nachgezogen — prüft jetzt gezielt den Ausnahmefall |
| `gold.js` | identisch mit Build 51 |
| übrige Tests | grün |

### Geändert

| Datei | was |
|---|---|
| `index.html` | `autoTitel`, Haken + Vorschau im Popup-Zeilen-Dialog, `BESCHREIBEND` raus |
| `tariftabelle-2-JS.txt` | `AVJTAB_ROT`, Kommentar am automatischen Titel |
| `tariftabelle-3-EINBAU.txt` | Zeilen ohne `data-titel`, Abschnitt zur Kopfzeile |

Die drei Rechner-Felder sind **unverändert** (v50) — nur die
Tariftabellen-Dateien sind neu.

---

## 42. Build 53 / Onepage v52 — Mehrkilometer nur für Kurzzeit

### Die Frage

Niran: *„übersehe ich es oder gibt es kein feld wo ich die mehrkilometer
nur für kz bearbeiten kann? ich will nämlich die frei km auf nur 50 km
begrenzen und die mehrkilometer hoch setzen und den 3 und 6 std. preis
bisschen verringern damit sich M und XL so ein wenig mehr
unterscheiden."*

Er übersieht nichts — das Feld gab es nicht. Die Kurzzeitzeile hat den
allgemeinen Satz des Fahrzeugs mitbenutzt. Bei 50 Frei-km auf drei
Stunden ist das zu billig: wer die Freigrenze eng zieht, muss den Satz
danebenlegen können.

Vorhanden waren schon: Frei-km (`kurzzeit.km`) und die vier Preise
(3 / 6 Std., Mo–Do und Fr/Sa).

### Neu

`kurzzeit.overKm`, freiwillig. Feld **Mehr-km bei KZ** im Abschnitt
Kurzzeittarife. Leer = Satz des Fahrzeugs, der Platzhalter zeigt welcher.

Wirkt **nur** in der Kurzzeitzeile der Tariftabelle. Tages-, Wochenend-
und Langzeitzeilen behalten den Fahrzeugsatz. Der Kundenrechner ist
nicht betroffen — er rechnet keine Stundenmieten.

### Nebenbei: freiwillige Felder ließen sich nicht leeren

`onSettingInput` stieg bei leerem Feld aus (`parseFloat("")` ist `NaN`),
der alte Wert blieb also stehen — ein einmal gesetzter Monatspreis war
nicht mehr auf „geschätzt" zurückzustellen. Felder mit `data-leer="weg"`
räumen sich jetzt auf:

* `kurzzeit.overKm`
* `monthPrice`, `monthKm`
* `sb.N.monat`

Bewusst **ohne** `renderSettings()` — sonst springt der Fokus weg, sobald
man ein Feld zum Neutippen leert.

**Bekannte Kleinigkeit:** wird ein Feld geleert, das im Kundenstand noch
steht, taucht das nicht in der Abweichungsliste auf (`diffGegen` läuft
über die Felder des Ist-Stands). Die erzeugte `preise.json` ist trotzdem
richtig — sie wird aus `CARS` gebaut, und dort ist das Feld weg. Nur die
Anzeige verschweigt es.

### Geprüft

| Test | Ergebnis |
|---|---|
| `pruefkz53.js` | **neu**, 10 Proben: ohne eigenen Satz erbt Kurzzeit den Fahrzeugsatz; mit 0,65 € ändert sich **nur** die Kurzzeitzeile (Tag / Wochenende / Langzeit bleiben bei 0,30 €); Feld vorhanden mit Platzhalter; Eintippen landet in `kurzzeit.overKm`; Leeren entfernt es wieder; der Fahrzeugsatz bleibt unangetastet |
| `gold.js` | identisch mit Build 52 |
| übrige Tests | grün |

### Geändert

`index.html` und `tariftabelle-2-JS.txt`. Die drei Rechner-Felder sind
weiterhin unverändert (v50).

---

## 43. Build 54 / Onepage v53 — Frei-km für 3 und 6 Stunden getrennt

Niran: *„kannst du aber bei den transporter KZ zu den neuen km preis noch
die frei km für 3 und 6 std. seperieren? aktuell ist ja nur eine km stufe
drin für beide kz tarife."*

Stimmt — `kurzzeit.km` galt für beide Spalten. Sechs Stunden mit
denselben Frei-km wie drei ist auch schwer zu begründen.

**Neu:** `kurzzeit.km6`, freiwillig.

| Feld | gilt für | leer heißt |
|---|---|---|
| `kurzzeit.km` | 3 Std. | — (Pflicht) |
| `kurzzeit.km6` | 6 Std. | wie 3 Std. |
| `kurzzeit.overKm` | beide | wie beim Fahrzeug |

Damit bleiben alle bisher erzeugten `preise.json` gültig: ohne `km6`
sieht die Tabelle aus wie vorher.

Der Abschnitt im Tool ist jetzt zweizeilig — oben Frei-km 3 Std.,
Frei-km 6 Std., 3 Std. Mo–Do, 6 Std. Mo–Do; unten 3 Std. Fr/Sa,
6 Std. Fr/Sa, Mehr-km bei KZ.

### Geprüft

`pruefkz53.js` um sechs Proben erweitert: ohne `km6` zeigen beide
Spalten dieselben Frei-km; mit `km6 = 100` steht in der 3-Std.-Spalte
weiter 50 und in der 6-Std.-Spalte 100; das Feld hat die 3-Std.-km als
Platzhalter, Eintippen landet in `km6`, Leeren entfernt es wieder, und
`kurzzeit.km` bleibt dabei unangetastet.

`gold.js` identisch mit Build 53, alle übrigen Tests grün.

### Geändert

`index.html` und `tariftabelle-2-JS.txt`. Rechner-Felder weiterhin v50.

---

## 44. Build 55 / Onepage v54 — die Preistabelle steht jetzt auch im Tool

Niran: *„eine idee noch weil ich die preis tabelle auch gerne nutze um
einen kunden schnell etwas zu sagen, kannst du die in den internen
rechner auch anzeigen am besten unter den rechner setzen, so das man es
auch schnell auf dem iphone auf einen blick sehen kann. also jeweils für
die aktuell drei rechner. meinetwegen auch schon für LB"*

Umgesetzt für **alle vier** Rechner: Kleinbus/Van, Transporter, PKW und
LB-Preis. Die Tabelle sitzt ganz unten im Rechner — unter der Tarif
Config., damit die nicht dahinter verschwindet.

### Der Punkt: eine Quelle, zwei Ausgaben

Den Zeichner ein zweites Mal abzutippen wäre der sichere Weg in zwei
Tabellen, die nach drei Builds verschiedene Preise zeigen. Stattdessen
ist `tab-motor.js` in zwei Teile zerlegt:

```
/* ═══ AVJ-TAB-KERN · ANFANG ═══ */
var AVJTAB_GEPLANT = false;
var AVJTAB_ROT     = true;
window.AVJ_TAB_KERN = … { blatt, stoerung, titelHtml, autoTitel, esc, eur }
/* ═══ AVJ-TAB-KERN · ENDE ═══ */

window.AVJ_TABELLE = …   ← nur noch Website: preise.json, data-fz, Rechnerknopf
```

Im **Kern** steht alles, was aus einem Fahrzeugobjekt HTML macht:
`eur`, `kmTxt`, `esc`, `titelHtml`, `ahkTxt`, `zelle`, `wert`, die
Langzeit-Helfer (`LZ_TAGE`, `lzPreis`, `lzKm`, `lzSb`), `kzKm`,
`kzExtraKm`, `extraKm`, `kopf`, `kurzzeit`, `staffel`, `tagestarife`,
`wochenende`, `langzeit`, `haftung`, `kaution`, `fuss`, `stoerung` — und
neu `autoTitel(c, key)` und `blatt(c, opt)`.

Draußen bleibt, was mit der Website zu tun hat: `hole(pfad)`,
`hinweisRechner()`, `zeichne(el)`, `alle()`, `start()`, der Klickfänger
für den Rechnerknopf.

`blatt(c, opt)` kennt drei Schalter:

| `opt` | Website | Tool |
|---|---|---|
| `titel` | `data-titel` oder `null` | `null` (immer `autoTitel`) |
| `zwischen` | `hinweisRechner(…)` — der blaue Knopf | leer, der Rechner steht ja schon darüber |
| `stand` / `logo` | aus `preise.json` / `LOGO` | `AVJ_PREISE.stand()` / `AVJ_TAB_LOGO` |

`fuss(stand, logo)` bekommt das Logo als Parameter — das war die einzige
Stelle im Zeichner, die etwas von der Website wusste.

> **Wichtig für den nächsten Umbau:** Der Kernblock steht **zweimal** —
> in `tab-motor.js` und in `index.html`. Von Hand geändert wird er nur in
> `tab-motor.js`; `build55.js` schneidet ihn zwischen den beiden Marken
> heraus und setzt ihn vor `function AVJ_RECHNER(CFG){`. Wer ihn direkt
> in `index.html` bearbeitet, hat beim nächsten Build wieder zwei
> Fassungen. Ebenso wird `tariftabelle-1-CSS.txt` (das Aussehen der
> Tabelle) beim Bauen in den `<style>`-Block von `index.html` kopiert.

### Was das Tool anders macht als die Website

Die Tabelle im Tool rechnet mit **`CARS`** — dem Stand im Tool,
einschließlich dessen, was noch nicht freigegeben ist. Wer gerade am
Preis geschraubt hat und dem Kunden etwas sagt, sieht seinen neuen Preis
und nicht den alten des Kunden. Die Zeile *„Stand …"* im Fuß bleibt das
Datum aus `preise.json` — sie sagt, worauf der Kunde schaut.

Neu gezeichnet wird nur, wenn sich wirklich etwas geändert hat
(`_tabSig` = Fahrzeugschlüssel + Stand + `JSON.stringify(car)`);
`render()` läuft bei jedem Tastendruck.

### Auf dem iPhone: schrumpfen statt schieben

Das Blatt ist für 600–1000 px Rasterbreite gebaut, das Telefon hat 390.
Auf der Website scrollt die Tabelle deshalb seitwärts. Im Tool wäre das
genau das Gegenteil von „auf einen Blick":

- Der Kasten tritt aus der 520-px-Spalte heraus und nimmt sich die volle
  Fensterbreite (`width:100vw` bzw. `min(94vw,1040px)` am Bildschirm).
- Die Entwurfsbreite richtet sich nach dem Platz:
  unter 480 px → **560** (das Raster darf laut CSS bis 540 zusammengehen,
  je schmaler entworfen, desto größer bleibt die Schrift),
  bis 640 px → **640**, darüber → so breit wie der Kasten, höchstens 1000.
- Passt es nicht, wird per `transform: scale()` heruntergerechnet und die
  Höhe des Kastens mitgerechnet. Auf einem iPhone 14 sind das ≈ 0,69 —
  Schrift ~10 px, lesbar.
- Zwei Knöpfe in der Kopfzeile: **100 %** schaltet auf Lesegröße mit
  seitwärts scrollen (wie im Popup), **zuklappen** blendet sie ganz aus.
- Neu gemessen wird bei Fensterwechsel, Drehung und wenn der Reiter
  sichtbar wird (`ResizeObserver`). Breite 0 heißt „Reiter ist versteckt"
  — dann wird nichts gerechnet, sonst käme `scale(0)` heraus.

### Geprüft

| Test | Ergebnis |
|---|---|
| `prueftabkern.js` | **neu.** Rendert alle sieben Popup-Fahrzeuge einmal mit Onepage **v53** und einmal mit **v54** und vergleicht Zeichen für Zeichen — inklusive Rechnerknopf und Fußleiste. **Alle identisch.** Der Umbau ist reines Verschieben. |
| `prueftabtool.js` | **neu**, 30 Proben. Tabelle unter allen vier Rechnern; **zeichengleich mit der Tabelle im Popup** für alle 8 Fahrzeuge (auch `transporter.testl`), abzüglich des Rechnerknopfs; Fahrzeugwechsel zieht die Tabelle mit; `overKm` = 9,99 € steht sofort drin (ohne Freigeben); zuklappen/aufklappen; 100 % / einpassen; auf 390 px wird geschrumpft und nichts ragt heraus; auf 1440 px 1:1 |
| `gold.js` | identisch mit Build 54 — 1.354 Zeilen, einziger Unterschied die Buildnummer |
| übrige 18 Tests | grün |

`prueftab.js` schlug zunächst fehl (*Stand 19.08. statt 20.08.*): die
Testseite `/tmp/srv/seite2.html` war noch die alte. `macheseite2.js` neu
laufen lassen, dann grün. **Fürs nächste Mal:** nach jedem
`bautabelle.js` auch `macheseite2.js` laufen lassen, sonst prüft
`prueftab.js` eine veraltete Seite.

### Geändert

`index.html`, `tariftabelle-2-JS.txt`, `-1-CSS.txt` und `-3-EINBAU.txt`
(die beiden letzten nur die Versionszeile im Kopf). Die drei
Rechner-Felder sind unverändert (**v50**) — beim Einsetzen reicht also
das Tabellen-Feld.

Bauskripte: `/tmp/fixmotor55.js` (zerlegt `tab-motor.js` in Kern und
Hülle, einmalig), `/tmp/build55.js`, `/tmp/bautabelle.js`.

---

## 45. Build 56 — Anker sichtbar, Kennzahlen auch im Bestand

Niran: *„hier dieser bereich ist doch nur dafür da damit ich zwischen 1
Tag und 7 tage die zwischenschritte rechne richtig? es geht da nicht
sooo hervor welche die anker zahlen sind so wie wenn ich ein neues
fahrzeug anlege … und beim anlegen sieht man ja auch den faktor dann,
das fehlt hier im bestand dann alles"*

Die Frage zuerst, weil sie eine halbe Fehlvorstellung enthält: Die Reihe
ist **nicht nur** Rechenhilfe für die Zwischenschritte. `tier[i]` **ist**
der Preis für i+1 Tage — bei 3 Tagen zahlt der Kunde `tier[2]`, direkt
aus dem Feld. Der Knopf *1T + 7T → Rest* verteilt nur die fünf
dazwischen neu. Und die beiden Anker hängen weiter dran als man denkt:

| Anker | wird außerdem gebraucht für |
|---|---|
| `tier[0]` | Ausgangspunkt aller Ampeln, Vergleichsbasis im Anlegen-Dialog |
| `tier[6]` | Zeile „7 Tage" in der Tariftabelle · Interpolation ab Tag 8 · Langzeit-Schätzung (`tier[6] × 3`, wenn kein Monatsanker gesetzt ist) |
| `tierKm[6]` | Frei-km der 7-Tage-Zeile · km-Schätzung für 28 Tage (`× 2`) |

### 1. Anker sind jetzt zu sehen

In jeder Reihe mit sieben Werten (Staffelpreis, Frei-km, **und** jede
Haftungsstufe) tragen Feld 1 und Feld 7 die Beschriftung **ANKER**,
blauen Rahmen und fetten Wert. Die fünf dazwischen sind gedämpft.

Die leere Beschriftung bei den mittleren Feldern ist Absicht — sie hält
die Zeile hoch, damit alle sieben Eingaben auf einer Höhe stehen
(`.ank.leer{visibility:hidden}`). Reihen mit vier oder drei Werten
(Tagespakete, Wochenende) bekommen keine Markierung: dort gibt es keine
Mitte zu treffen, und genau deshalb hat auch nur die Sieben-Reihe den
Füllknopf.

### 2. Kennzahlen — dieselben Ampeln wie beim Anlegen

Neu ganz oben in der Tarif Config., über *Alle Preise verschieben*:

| Kennzahl | Rechnung |
|---|---|
| Wochenfaktor | `tier[6] / tier[0]` |
| Wochenende je Tagespreis | `weekend[0][1] / tier[0]` (nur wo es Wochenendstufen gibt) |
| Preis je Frei-km | `tier[0] / tierKm[0]` |
| km-Faktor Woche | `tierKm[6] / tierKm[0]` |

Gerechnet wird in `AVJ_NEUFZ.kennzahlen(auto, kat, ausser)` — **dieselbe
Funktion, die auch der Anlegen-Dialog benutzt**, mit `ampel()` und
`korridor()`. Kein zweiter Satz Grenzwerte.

**Ein Unterschied zum Anlegen war nötig:** das Fahrzeug selbst muss aus
dem Vergleichskorridor heraus (`ausser`). Sonst wandern `min`/`max` mit
dem eigenen Wert mit und die Ampel steht immer auf grün — ein Korridor,
der den Prüfling enthält, prüft nichts. Bleibt in der eigenen Kategorie
danach weniger als ein Vergleichsfahrzeug übrig, wird der ganze Bestand
genommen; ein Korridor aus einem einzigen Fahrzeug wäre keiner.

Die Ampeln rechnen beim Tippen mit — sie hängen in `updateDeltas()`,
nicht in `renderSettings()`, sonst würde bei jedem Tastendruck der Fokus
wegspringen.

### Was dabei gleich auffiel (Transporter M, Stand 20.08.)

| Kennzahl | M | Korridor ohne M |
|---|---|---|
| Wochenfaktor | 5,67× | 5,63 – 5,86 ✓ |
| Wochenende je Tagespreis | **2,33×** | 1,84 – 2,05 ⚠ |
| Preis je Frei-km | **0,75 €** | 0,95 – 1,10 ⚠ |
| km-Faktor Woche | 15,00× | 15,00 ✓ |

Heißt: der M hat im Verhältnis das teuerste Wochenende und die
großzügigsten Frei-km der Klasse. Beides kann so gewollt sein —
angeschaut werden sollte es. (Im Korridor steckt auch das Testfahrzeug
`testl`; wer es löscht, bekommt engere Werte.)

### Geprüft

| Test | Ergebnis |
|---|---|
| `pruefanker56.js` | **neu**, 18 Proben: Markierungsmuster `A.....A` in allen vier Sieben-Reihen, kürzere Reihen unmarkiert, alle sieben Felder auf einer Höhe (±1 px); Wochenfaktor und km-Faktor stimmen rechnerisch; WE-Kennzahl nur wo es Wochenendstufen gibt; Wochenpreis auf 4.000 € → Ampel springt auf **rot** (Beweis, dass das Fahrzeug nicht im eigenen Korridor steckt) und danach zurück; Füllknopf lässt beide Anker stehen, Reihe steigt durchgehend, Markierung überlebt das Neuzeichnen; LB (ohne Wochenendstufen) bekommt drei Kennzahlen und ebenfalls Anker |
| `gold.js` | identisch mit Build 55 |
| übrige 20 Tests | grün |

### Geändert

Nur `index.html`. Die Onepage-Felder bleiben **v54** — hier ändert sich
nichts, was der Kunde sieht.

Bauskript: `/tmp/build56.js`.

---

## 46. Build 57 — welches Feld gilt wofür, und der Abgleich mit dem Tagespaket

Niran: *„wenn ich unten bei den tagestarifen einen preis ändere im
beispiel auf 80, dann bleibt es bei der 7 tages zeile bei tag 1 noch auf
75. auf der webseite in der tabelle ist die 80 zu sehen. das heißt ich
weiß nicht ohne ausprobieren was wo hochgeladen wird."*

Er hat einen echten Fallstrick gefunden, keinen Anzeigefehler.

### Die Sache dahinter

In `quote()` steht:

```js
} else if(hatPkt && d.days <= 2){
  var stD = pickStep(gridFor(car, paketRaster(car, frSa)), perDayKm, car.planKm);
  base = stD.price * d.days;
```

Bei Fahrzeugen **mit** Tagespaketen rechnen ein und zwei Tage
ausschließlich über `dayMoDo`/`dayFrSa`. **`tier[0]` und `tier[1]`
werden dort nie angefasst.** Ab drei Tagen greift `tier[i]`.

Wertlos sind sie trotzdem nicht:

| Feld | wofür es zählt |
|---|---|
| `tier[0]` | Anker, aus dem *1T + 7T → Rest* die Werte 2T–6T füllt; Bezugsgröße der Kennzahlen |
| `tier[2]`…`tier[6]` | Preis für 3–7 Tage, direkt |
| `dayMoDo[0][1]` | **der Preis, den der Kunde für einen Tag zahlt** — und der, der in der Tariftabelle unter *Tagestarife* steht |
| `sb[x].tier[0]`, `[1]` | zählen sehr wohl — die Haftungsreduzierung rechnet auch bei 1–2 Tagen über die Staffel |

Bei **Low Budget** (kein `dayMoDo`) ist es andersherum: dort ist
`tier[i]` der Preis für i+1 Tage, auch für den ersten.

Solange beide Zahlen gleich sind — und im Bestand waren sie es überall
außer beim Testfahrzeug `testl` (tier[0] = 95, Paket = 75) — fällt das
niemandem auf. Sobald man eine von beiden ändert, steht im Tool eine
Zahl, die beim Kunden nie ankommt.

### 1. Jede Reihe sagt jetzt, wofür sie gilt

`numRow()` hat einen siebten Parameter `hinweis` bekommen; er wird als
`.avjt-shint` unter die Überschrift gezeichnet.

| Reihe | Hinweis |
|---|---|
| Staffelpreis **mit** Paketen | „Gilt für **3 bis 7 Tage**. Ein und zwei Tage rechnet das **Tagespaket** weiter unten — **1T** und **2T** sind hier nur Anker … In der Tariftabelle taucht aus dieser Reihe nur **7 Tage** auf." |
| Staffelpreis **ohne** Pakete | „Jeder Wert ist der Preis für genau diese Mietdauer, **1 bis 7 Tage**. In der Tariftabelle: der Block **Mietdauer**." |
| Tagespaket – Preis | „Gilt für **1 und 2 Tage** … Das ist der Preis, den der Kunde für einen Tag zahlt — in der Tariftabelle der Block **Tagestarife**." |
| Wochenende – Preis | „Gilt bei Abholung **Freitag ab 12:00** und Rückgabe bis **Montag 10:00** — nicht nach Tagen." |
| Haftung | „Hier zählen **alle sieben** Werte — auch 1T und 2T, anders als beim Staffelpreis." |

**Nebenwirkung, die auffiel:** `AVJ_EDITOR.bloecke()` fasst Überschrift
und Raster zu einem `.pr-block` zusammen und beendet den Block bei jedem
unbekannten Element. Der Hinweis dazwischen hätte das Raster aus seiner
eigenen Überschrift herauskippen lassen. `bloecke()` nimmt jetzt auch
`-shint` in den Block.

### 2. Der Abgleich

Weicht `tier[0]` von `dayMoDo[0][1]` ab (oder `tierKm[0]` von
`dayMoDo[0][0]`), erscheint unter den beiden Reihen ein Kasten:

> **1T Staffelpreis** steht auf **75 €**, gerechnet und in der Tabelle
> gezeigt werden aber **80 €** aus dem Tagespaket. Der Wert oben ist nur
> der Anker der Staffel.  · [ auf 80 € angleichen ]

`gleicheAn(feld)` zieht den Anker auf den Paketwert — **außer** die
Staffel verlöre dadurch ihre Ordnung (`soll >= reihe[1]`). Dann passiert
nichts und es kommt ein Hinweis; lieber ehrlich als eine stillschweigend
verbogene Staffel. Der Kasten hängt in `updateDeltas()`, rechnet also
beim Tippen mit.

### 3. Die Kennzahlen aus Build 56 nachgezogen

Wochenfaktor und *Preis je Frei-km* rechneten gegen `tier[0]` — also
gegen eine Zahl, die der Kunde bei Fahrzeugen mit Tagespaketen nie
zahlt. Damit hätte Build 56 denselben Fallstrick in die neue Anzeige
eingebaut. Neu in `AVJ_NEUFZ`:

```js
function tagPreis(c){
  if(c.dayMoDo && c.dayMoDo.length) return c.dayMoDo[0][1];
  return (c.tier && c.tier.length) ? c.tier[0] : 0;
}
function tagKm(c){ … dayMoDo[0][0] … tierKm[0] … }
```

Beide Stellen — `kennzahlen()` **und** `rechne()` im Anlegen-Dialog —
benutzen sie jetzt, sonst hätten Anlegen und Bestand zwei verschiedene
Korridore.

> **Für den nächsten Umbau:** Wer eine neue Kennzahl auf „Tagespreis"
> baut, nimmt `AVJ_NEUFZ.tagPreis(car)`, nicht `car.tier[0]`.

### Geprüft

| Test | Ergebnis |
|---|---|
| `pruefgilt57.js` | **neu**, 18 Proben. Zuerst die Behauptung selbst, mit dem Rechner statt mit dem Auge: Paketpreis auf 80 gesetzt, `tier[0]` bleibt 75 → **1 Tag Mo–Di kostet 80** (Tagestarif), **3 Tage kosten `tier[2]`**, und bei LB kostet 1 Tag `tier[0]`. Dann die Anzeige: Warnung erscheint mit beiden Beträgen, Knopf nennt das Ziel, Angleichen setzt `tier[0] = 80`, Staffel bleibt geordnet, Warnung verschwindet; Wochenfaktor rechnet gegen 80 statt 75; jede Reihe trägt den richtigen Hinweis, LB einen anderen als der Transporter; ohne Tagespakete gibt es keinen Abgleich |
| `gold.js` | identisch mit Build 56 |
| übrige 21 Tests | grün |

### Geändert

Nur `index.html`. Onepage bleibt **v54**.

Bauskript: `/tmp/build57.js`.
