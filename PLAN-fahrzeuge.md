# Plan: Fahrzeuge selbst anlegen (Notiz für später)

**Angestoßen am 18.08.2026, Stand Build 32. Noch nichts davon gebaut.**

## Das Problem

Bei DirectCar wechseln die PKW alle sechs Monate. Heute heißt ein neues
Fahrzeug: Code ändern, neuen Rechner-Block anlegen, Build bauen, hochladen.
Das ist für einen halbjährlichen Vorgang zu umständlich — und für die
PKW-Kategorie, die es im Werkzeug noch gar nicht gibt, sowieso.

Ziel: **Neues Fahrzeug** anklicken, Kategorie wählen, ein paar Richtpreise
eintippen, fertig. Danach lässt sich alles genauso pflegen wie bei den
bestehenden Fahrzeugen.

---

## Teil 1 — Richtpreise: was reicht als Eingabe?

Ein Fahrzeug hat heute rund 50 Zahlen (Staffel, Frei-km, Tagespakete,
Wochenende, Mehrkilometer, drei SB-Stufen, teils Kurzzeit, AHK, Kaution).
Die will niemand einzeln eintippen.

### Empfehlung: Vorlage + Anker, nicht Formel

Ich habe die vorhandenen Staffelpreise durchgerechnet. Beispiel Vito Tourer:

| Tage | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|---|---|---|---|---|---|---|
| Preis | 85 | 165 | 250 | 320 | 385 | 435 | 470 |
| Sprung | — | +80 | +85 | +70 | +65 | +50 | +35 |

Der Sprung von Tag 2 auf 3 ist **größer** als der von Tag 1 auf 2. Keine
saubere Degressionsformel bildet das ab — eine Potenzkurve durch 85 und 470
liefert für Tag 3 rund 222 statt 250, also gut 11 % daneben. Über die ganze
Staffel wäre der Vorschlag durchgehend zu billig.

Deshalb: **Die Kurvenform kommt aus einem vorhandenen Fahrzeug derselben
Kategorie, die Höhe aus deinen Ankerwerten.** Das neue Fahrzeug erbt eine
Form, die sich in der Praxis bewährt hat, und wird nur skaliert. Formeln
braucht es nur dort, wo es noch kein Vorbild gibt — anfangs also PKW.

### Die Anker, die ich vorschlagen würde

| Feld | steuert |
|---|---|
| **Tagespreis Mo–Do (1 Tag)** | Anfang der Staffel, Tagespakete, ggf. Kurzzeit |
| **Wochenpreis (7 Tage)** | Ende der Staffel — zusammen mit dem Tagespreis die Degression |
| **Wochenendpreis (Fr–Mo)** | die Wochenendstufen |
| **Frei-km pro Tag** | Frei-km-Staffel und die km-Stufen der Pakete |
| **Mehrkilometer ungeplant (€/km)** | geplant leitet sich als fester Anteil daraus ab |

Fünf Zahlen. Alles andere — SB-Stufen, Fr/Sa-Zuschlag, Paketabstufungen,
Kaution, AHK — kommt aus der Vorlage, prozentual mitskaliert oder unverändert
übernommen. Gerundet wird wie bisher auf 5 €.

Danach steht das Fahrzeug im Tarife-Reiter wie jedes andere und lässt sich Feld
für Feld nachziehen. Die Richtpreise sind ein **Startpunkt, keine Festlegung**.

### Offene Fragen an dich

- Skaliert der Wochenendpreis mit dem Tagespreis, oder setzt du den eher
  unabhängig an? Wenn unabhängig, bleibt er als eigener Anker; wenn er
  ohnehin ein fester Faktor ist, spart das eine Eingabe.
- Sollen die SB-Aufschläge mitskalieren oder als fester Euro-Betrag je Klasse
  gelten? Bei einem billigen PKW wären prozentual mitskalierte
  Haftungsreduzierungen sehr niedrig.
- Wollen wir eine „ab Werk"-Kurve für PKW definieren, bevor es dort ein erstes
  Fahrzeug gibt? Sonst braucht das erste PKW-Fahrzeug alle Werte von Hand.

---

## Teil 2 — Was dafür im Code passieren muss

Das ist der größere Teil und der Grund, warum das eine eigene Sitzung braucht.

**1. Fahrzeugliste wird heute nicht erzeugt, sondern steht als HTML da.**

```html
<button class="avj-car is-active" data-car="sprinter">…
<button class="avj-car" data-car="vito">…
```

Solange das so bleibt, taucht ein neues Fahrzeug in der Auswahl nicht auf.
Die Zeile muss aus `CARS` gezeichnet werden — im internen Werkzeug **und** in
beiden Kundenrechnern auf der Website.

**2. Drei fast identische Rechner-Blöcke.**

`avj-` (9-Sitzer), `avjt-` (Transporter), `avjL-` (Low Budget) sind
Kopien voneinander mit gleich benannten Funktionen. Für PKW eine vierte Kopie
anzulegen wäre der falsche Weg — dann gibt es vier Stellen, an denen jeder
künftige Fehler viermal behoben werden muss. Vorher zusammenführen: ein
Rechner, der die Kategorie als Parameter bekommt.

Das ist der eigentliche Brocken. Vorteil: danach ist eine neue Kategorie
Konfiguration statt Code.

**3. Speicherformat.**

`localStorage` hält heute nur *Abweichungen* zu bekannten Fahrzeugen
(`{__diff:1, aenderungen:{…}}`). Ein selbst angelegtes Fahrzeug ist keine
Abweichung, sondern neu — es braucht einen eigenen Abschnitt, sonst ist es beim
nächsten Serverabruf weg.

**4. `preise.json` und Freigabe.**

Die Datei muss neue Fahrzeuge tragen können, und `pruefe()` darf sie nicht
abweisen. Die Prüfung ist bewusst streng (7 Staffelwerte, keine negativen
Zahlen) — das soll sie bleiben, sie muss nur mit einer variablen Fahrzeugliste
umgehen. Ein halb ausgefülltes neues Fahrzeug darf nicht auf die Website.

**5. Löschen und Umbenennen.**

Wenn ein DirectCar-Fahrzeug nach sechs Monaten zurückgeht, muss es wieder raus
— aber nicht aus alten Angeboten. Vorschlag: **stilllegen statt löschen**.
Das Fahrzeug verschwindet aus dem Kundenrechner und der Preistabelle, bleibt im
Werkzeug aber sichtbar, damit man einen alten Vorgang nachrechnen kann.

---

## Reihenfolge, wenn wir es angehen

1. Anker und Skalierungsregeln festklopfen (die offenen Fragen oben)
2. Die drei Rechner zu einem zusammenführen — größter Schritt, rein intern,
   von außen darf sich nichts ändern
3. Fahrzeugliste dynamisch zeichnen, intern und auf der Website
4. Speicherformat und `preise.json` um neue Fahrzeuge erweitern
5. Dialog „Neues Fahrzeug" mit Kategorie, Vorlage und den fünf Ankern
6. Stilllegen

Schritt 2 lohnt sich unabhängig davon — auch ohne neue Fahrzeuge ist eine
Fehlerbehebung dann einmal statt dreimal zu machen.
