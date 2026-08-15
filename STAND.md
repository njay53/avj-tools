# AVJ Tools — Projektstand

**Stand: Build 25 · 15.08.2026**
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
3. **LB-Preis** — Low-Budget-Klasse (Yaris)
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
avj_preise_v1            Preise 9-Sitzer
avjT_preise_v1           Preise Transporter
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

- **Zentrale Preisliste**: `preise.json` im Repository, die auch die Kundenrechner
  abrufen. Damit würde eine Preisänderung an einer Stelle überall wirken.
  Bedenken: Netzabhängigkeit, Rückfallwerte nötig, Änderung sofort öffentlich.
- **PKW-Rechner** — Fahrzeuge wechseln ständig, deshalb erst sinnvoll mit
  zentraler Preisliste.
- **Onepage-MCP**: Könnte das Kopieren in sechs Felder ersparen. Die Anleitung
  beschreibt nur das Neuerstellen von Seiten, nicht das Bearbeiten von Custom-Code-
  Blöcken. Vor einem Anschluss an die Live-Seite erst an einem Testprojekt prüfen.
- **Vito-Wochenpreis** (950 €) fällt gegenüber dem Sprinter Tourer (650 €) auf:
  Der Tagessatz sinkt beim Vito über die Woche nur um 15 %, beim Sprinter um 28 %.
  Stammt so aus der Preisliste, könnte aber unbeabsichtigt sein.
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
