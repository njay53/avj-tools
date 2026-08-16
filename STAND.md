# AVJ Tools — Projektstand

**Stand: Build 28 · 15.08.2026**
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
