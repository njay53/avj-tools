# Plan: Fahrzeuge selbst anlegen (Notiz für später)

**Angestoßen am 18.08.2026, Stand Build 32. Noch nichts davon gebaut.**
Zweite Fassung — die erste enthielt eine Fehlanalyse, siehe Kasten unten.

## Das Problem

Bei DirectCar wechseln die PKW alle sechs Monate. Heute heißt ein neues
Fahrzeug: Code ändern, neuen Rechner-Block anlegen, Build bauen, hochladen.
Das ist für einen halbjährlichen Vorgang zu umständlich — und für die
PKW-Kategorie, die es im Werkzeug noch gar nicht gibt, sowieso.

Ziel: **Neues Fahrzeug** anklicken, Klasse wählen, ein paar Richtpreise
eintippen, fertig. Danach lässt sich alles genauso pflegen wie bisher.

---

## Teil 1 — Richtpreise: zwei Anker reichen

> **Korrektur zur ersten Fassung.** Ich hatte behauptet, deine Staffel sei
> nicht sauber degressiv (Sprung Tag 2→3 größer als 1→2) und deshalb nicht
> berechenbar. Das war falsch — die Zahlen stammten aus einem Screenshot
> *nach* einer Testverschiebung um +10 %, nicht aus deinen echten Preisen.
> Die echten Kurven sind sauber. Damit sieht die Lösung deutlich besser aus.

### Was in deinen Preisen tatsächlich steckt

Wenn man jede Staffel auf ihren eigenen Anfang und ihr eigenes Ende
normiert — also fragt „welcher Anteil des Wegs von Tag 1 zu Tag 7 ist an
Tag n zurückgelegt?" — sehen alle fünf Fahrzeuge fast gleich aus:

| Fahrzeug | 1 T | 2 T | 3 T | 4 T | 5 T | 6 T | 7 T |
|---|---|---|---|---|---|---|---|
| Sprinter Tourer | 0,000 | 0,240 | 0,471 | 0,663 | 0,817 | 0,933 | 1,000 |
| Vito Tourer | 0,000 | 0,196 | 0,386 | 0,557 | 0,722 | 0,867 | 1,000 |
| Transporter M | 0,000 | 0,214 | 0,429 | 0,614 | 0,786 | 0,914 | 1,000 |
| Transporter XL | 0,000 | 0,206 | 0,411 | 0,598 | 0,766 | 0,907 | 1,000 |
| Low-Budget | 0,000 | 0,242 | 0,455 | 0,636 | 0,788 | 0,909 | 1,000 |
| **Mittel** | **0,000** | **0,220** | **0,430** | **0,614** | **0,776** | **0,906** | **1,000** |

Die größte Streuung liegt bei Tag 4 mit 0,106 — über fünf Fahrzeuge aus drei
Kategorien, vom Yaris bis zum Sprinter. Das ist eine erstaunlich stabile
Handschrift.

### Der Vorschlag

**Zwei Anker: Tagespreis und Wochenpreis. Der Rest kommt aus der
Mittelwert-Form, gerundet auf 5 €.**

Formel: `Tag n = Tagespreis + Form[n] × (Wochenpreis − Tagespreis)`

Gegen die echten Preise gehalten:

| Fahrzeug | größte Abweichung | wo |
|---|---|---|
| Transporter M | 1,4 % | Tag 5 |
| Transporter XL | 4,5 % | Tag 2 |
| Low-Budget | 5,9 % | Tag 2 |
| Sprinter Tourer | 5,3 % | Tag 3/4 |
| Vito Tourer | 7,5 % | Tag 3/4 |

Schlechtester Fall über alle Fahrzeuge und Stufen: **7,5 %**. Für einen
Startwert, den du danach ohnehin anfasst, ist das gut genug — und deutlich
besser als eine Potenzkurve, die ich vorher durchgerechnet hatte (die liegt
in der Mitte 11–12 % zu tief, weil sie die Degression zu früh ansetzt).

Zusatzoption: **„Form von Fahrzeug X übernehmen"** statt Mittelwert. Beim
Transporter XL bringt das die Abweichung von 4,5 auf rund 3 % runter, weil M
und XL fast dieselbe Kurve haben. Bei den 9-Sitzern hilft es *nicht* — Vito
und Sprinter unterscheiden sich echt voneinander, da ist der Mittelwert
besser. Also: Mittelwert als Vorgabe, Vorlage als Auswahl.

### Die weiteren Anker

Tages- und Wochenpreis erzeugen die Staffel. Für den Rest braucht es noch:

| Feld | steuert |
|---|---|
| **Wochenendpreis (Fr–Mo)** | die Wochenendstufen |
| **Frei-km pro Tag** | Frei-km-Staffel und die km-Stufen der Pakete |
| **Mehrkilometer ungeplant (€/km)** | geplant leitet sich als Anteil daraus ab |

Also **fünf Zahlen**. Alles Weitere — SB-Stufen, Fr/Sa-Zuschlag,
Paketabstufungen, Kaution, AHK — kommt aus der Vorlage der Kategorie,
mitskaliert oder unverändert übernommen.

---

## Teil 2 — Ampel beim Eintippen

Die Farbe soll nicht aus erfundenen Branchenwerten kommen, sondern aus
**deinem eigenen Fuhrpark**. Grün heißt: liegt im Korridor, in dem sich deine
anderen Fahrzeuge bewegen. Gelb: knapp daneben. Rot: weit draußen.

Die Korridore aus dem heutigen Bestand:

| Kennzahl | dein Bestand | Vorschlag grün | gelb |
|---|---|---|---|
| **Wochenfaktor** (7-Tage ÷ Tagespreis) | 4,67 – 5,94 | 4,8 – 6,0 | 4,3 – 6,5 |
| **Wochenende ÷ Tagespreis** | 1,72 – 2,33 | 1,7 – 2,4 | 1,5 – 2,7 |
| **geplant ÷ ungeplant km** | 0,55 – 0,70 | 0,50 – 0,75 | 0,40 – 0,85 |
| **Abstand zur Nachbarklasse** | — | ≥ 15 % | 10 – 15 % |

Einzelwerte je Fahrzeug: Sprinter 5,00 · Vito 5,94 · Transporter M 5,67 ·
XL 5,86 · Low-Budget 4,67.

Zwei Anmerkungen dazu:

- **Der Preis je Frei-km taugt nicht als kategorieübergreifender Korridor.**
  Er reicht von 0,11 €/km (Low-Budget) bis 1,10 €/km (Transporter XL) —
  das ist kein Ausreißer, sondern die Geschäftslogik: beim Low-Budget sind
  die km praktisch inklusive, beim Transporter sind sie das Produkt. Diese
  Kennzahl braucht also einen eigenen Korridor **je Kategorie**.
- **Low-Budget hat planKm = overKm = 0,15.** Bei allen anderen liegt geplant
  bei 55–70 % von ungeplant. Bewusst so, oder ein Überbleibsel? Wenn bewusst,
  ist Low-Budget beim Korridor auszunehmen.

Die Ampel ist ein Hinweis, keine Sperre. Rot verhindert das Speichern nicht —
du siehst nur sofort, dass der Wert aus der Reihe fällt.

---

## Teil 3 — Rundung und Barzahler

Deine Vorgabe: keine Krümel wie 243,87 €, und beim Bargeld möglichst kein
Kleingeld zurück.

**Die gute Nachricht: das ist schon gelöst, nur nicht überall.** Der kleinste
Schein ist 5 €. Solange jeder Preis ein Vielfaches von 5 ist, ist auch das
Rückgeld ein Vielfaches von 5 — also immer in Scheinen. Alle heutigen
Staffelpreise erfüllen das bereits, geprüft über alle fünf Fahrzeuge.

Wo es trotzdem krümelt:

1. **Mehrkilometer.** 0,33 €/km × 47 km = 15,51 €. Sobald das in eine
   Barrechnung läuft, ist das Kleingeld wieder da.
2. **Zusammengesetzte Rechnungen.** Solange jeder Baustein ein
   Fünfer-Vielfaches ist, bleibt auch die Summe eines — Mehrkilometer sind
   der einzige Bruch in der Kette.

Vorschläge, zu entscheiden:

- **Endsumme auf 5 € runden**, bei Barzahlung abwärts. Kostet dich im Schnitt
  gut 2 €, spart jedes Mal die Münzsuche. Wäre eine Einstellung, kein Zwang.
- **Rundungsschritt je Kategorie**: 5 € als Vorgabe, ab 200 € auf 10 €
  hochsetzen. Macht die Staffel oben ruhiger (470 statt 467,50) ohne unten
  grob zu werden.
- Bei den Ankern selbst nur Fünfer zulassen — dann kann aus einem krummen
  Anker gar nichts Krummes entstehen.

Was „stimmig aussehen" darüber hinaus heißt, sollten wir festhalten: die
Sprünge sollen von Stufe zu Stufe kleiner werden (bei dir überall der Fall),
und keine zwei Fahrzeuge sollen enger als 15 % beieinanderliegen. Beides kann
das Werkzeug nach dem Erzeugen prüfen und melden.

---

## Teil 4 — PKW-Klassen

Du bist bei der Einordnung nicht allein — die offiziellen Systeme taugen für
deinen Zweck nur bedingt.

**KBA-Segmente** (Kraftfahrt-Bundesamt: Minis, Kleinwagen, Kompaktklasse,
Mittelklasse, Obere Mittelklasse, Oberklasse, dazu SUVs, Geländewagen,
Sportwagen, Mini-Vans, Großraum-Vans, Utilities). Die ersten sechs richten
sich nach der Größe. **Das Problem: alle SUV landen in einem einzigen Topf** —
ein T-Cross steht dort neben einem Q7. Für die Statistik reicht das, für einen
Mietpreis nicht.

**ACRISS-Code** ist der Standard der Mietwagenbranche: vier Buchstaben für
Kategorie, Bauart, Getriebe, Kraftstoff/Klima. Genau für dein Problem gemacht
und gut, um Wettbewerbspreise zu vergleichen — aber für deine Kunden
unverständlich. Die genaue Buchstabenliste holen wir uns beim ACRISS-Verband,
wenn wir es einbauen.

### Mein Vorschlag: zwei Ebenen, eigene Namen

Nicht eine lange Liste, sondern **Größenklasse × Bauform**:

| Größenklasse | Beispiele |
|---|---|
| Kleinstwagen | Aygo, Up |
| Kleinwagen | Yaris, Polo, Fiesta |
| Kompaktklasse | Golf, Corolla, Astra |
| Mittelklasse | Passat, Octavia, Mondeo |
| Obere Mittelklasse | Superb, 5er |

| Bauform | Aufschlag |
|---|---|
| Limousine | Grundpreis |
| Kombi | + x % |
| SUV / Crossover | + y % |
| Van / Hochdach | + z % |

**Damit löst sich dein T-Roc/T-Cross-Problem:** Nicht „ist das ein SUV?"
fragen, sondern *welcher normale PKW steckt darunter*. Der T-Roc steht auf der
Golf-Plattform → **Kompaktklasse + SUV**. Der T-Cross steht auf der
Polo-Plattform → **Kleinwagen + SUV**. Die Faustregel „welches Modell derselben
Marke ist gleich lang" trägt quer durch alle Hersteller und ist genau die
Frage, die auch den Preis bestimmt.

Der Preis hängt dann an der Größenklasse, die Bauform ist ein Aufschlag. Ein
neues Fahrzeug einzuordnen heißt: zwei Klicks statt Grübeln.

---

## Teil 5 — Einstellungsbereich

Das wird zu viel für den Tarife-Reiter. Eigener Menüpunkt, wie beim
Schadenmanager. Hinein gehören:

- **Klassen und Bauformen** — anlegen, umbenennen, sortieren, Aufschläge je
  Bauform
- **Kategorien** — Transporter, 9-Sitzer, PKW, Low Budget; erweiterbar
- **Ampel-Korridore** — die Werte aus Teil 2, je Kategorie überschreibbar
- **Rundung** — Schritt je Kategorie, Endsummenrundung bei Barzahlung
- **Vorlagen** — welches Fahrzeug ist Formgeber je Kategorie
- **Standardwerte** — Kaution, SB-Stufen, Fr/Sa-Zuschlag für neue Fahrzeuge

---

## Teil 6 — Was im Code passieren muss

**1. Die Fahrzeugliste steht als festes HTML da**, nicht erzeugt:

```html
<button class="avj-car is-active" data-car="sprinter">…
<button class="avj-car" data-car="vito">…
```

Solange das so bleibt, taucht ein neues Fahrzeug in der Auswahl nicht auf —
weder intern noch in den beiden Kundenrechnern auf der Website. Muss aus
`CARS` gezeichnet werden.

**2. Drei fast identische Rechner-Blöcke.** `avj-` (9-Sitzer), `avjt-`
(Transporter), `avjL-` (Low Budget) sind Kopien voneinander mit gleich
benannten Funktionen. Für PKW eine vierte Kopie anzulegen wäre der falsche
Weg — dann ist jeder künftige Fehler viermal zu beheben. Vorher zusammen­
führen: ein Rechner, der die Kategorie als Parameter bekommt. Das ist der
eigentliche Brocken, lohnt sich aber unabhängig von allem anderen.

**3. Speicherformat.** `localStorage` hält heute nur *Abweichungen* zu
bekannten Fahrzeugen (`{__diff:1, aenderungen:{…}}`). Ein selbst angelegtes
Fahrzeug ist keine Abweichung, sondern neu — braucht einen eigenen Abschnitt,
sonst ist es beim nächsten Serverabruf weg.

**4. `preise.json` und Freigabe.** Die Datei muss neue Fahrzeuge tragen, und
`pruefe()` darf sie nicht abweisen. Die Prüfung bleibt streng — sie muss nur
mit einer variablen Fahrzeugliste umgehen. Ein halb ausgefülltes Fahrzeug darf
nicht auf die Website.

**5. Stilllegen statt löschen.** Geht ein DirectCar-Fahrzeug nach sechs
Monaten zurück, verschwindet es aus Kundenrechner und Preistabelle, bleibt im
Werkzeug aber sichtbar — damit ein alter Vorgang nachrechenbar bleibt.

---

## Offene Fragen an dich

1. Ist `planKm = overKm` beim Low-Budget Absicht?
2. Endsumme bei Barzahlung auf 5 € abrunden — willst du das?
3. Skaliert der Wochenendpreis mit dem Tagespreis, oder setzt du ihn
   unabhängig? (Dein Bestand: Faktor 1,72 bis 2,33 — spricht eher für
   unabhängig, also eigener Anker.)
4. SB-Aufschläge bei neuen Fahrzeugen prozentual mitskalieren oder feste
   Euro-Beträge je Klasse? Bei einem billigen PKW würden mitskalierte
   Aufschläge sehr niedrig.
5. Bauform-Aufschläge: welche Prozentsätze hältst du für richtig?

## Reihenfolge, wenn wir es angehen

1. Offene Fragen klären, Klassen und Korridore festklopfen
2. Die drei Rechner zu einem zusammenführen — rein intern, von außen darf
   sich nichts ändern
3. Einstellungsbereich als eigener Menüpunkt
4. Fahrzeugliste dynamisch zeichnen, intern und auf der Website
5. Speicherformat und `preise.json` um neue Fahrzeuge erweitern
6. Dialog „Neues Fahrzeug" mit Klasse, Vorlage, fünf Ankern und Ampel
7. Stilllegen
