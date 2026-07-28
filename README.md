# AVJ Tools

Interne Rechner-Sammlung für Autovermietung Jansen.
Eine einzelne HTML-Datei, läuft komplett im Browser — kein Server, keine Datenbank, keine Abhängigkeiten.

**Live:** https://avj-tools.rent-in-nom.de

---

## Enthaltene Tools

| Tab | Zweck |
|---|---|
| **Mietdauer** | Tage zwischen zwei Terminen, angefangene Tage werden aufgerundet |
| **Rabatt** | Prozentwert für rentsoft, 5 Nachkommastellen, mit Kopierfunktion |
| **LB-Preis** | Low-Budget-Klasse (Yaris), Staffelpreise und Frei-km |
| **9-Sitzer** | Sprinter Tourer / Vito Tourer |
| **Transporter** | Transporter M (Trafic) / Transporter XL (Sprinter, MAN TGE) |

---

## Aktualisieren

1. Neue Datei bei Bedarf lokal `index.html` nennen
2. Im Repository: **Add file → Upload files**
3. Datei reinziehen, GitHub überschreibt die alte automatisch
4. **Commit changes**

Nach ein bis zwei Minuten ist die Änderung live. Auf dem iPhone einmal neu laden.

⚠️ **Die Datei `CNAME` nicht löschen** — darin steht die Domain. Ohne sie fällt die Seite auf die GitHub-Adresse zurück.

---

## Preise ändern

Zwei Wege, je nach Tool:

**9-Sitzer und Transporter** haben unten im Tab einen Bereich *Preise anpassen*.
Änderungen dort werden im Browser gespeichert und bleiben nach dem Schließen erhalten —
allerdings **pro Gerät**. Eine Änderung am Mac ist auf dem iPhone nicht sichtbar.
Der Knopf *Auf Standard zurücksetzen* stellt die Werte aus dem Code wieder her.

**Dauerhaft für alle Geräte** ändert man die Werte direkt im Code.
Im `<script>`-Bereich unter `var CARS = {` stehen pro Fahrzeug:

```
tier      Staffelpreis je Mietdauer, Tag 1–7
tierKm    Frei-Kilometer je Mietdauer, Tag 1–7
dayMoDo   Tagespakete Mo–Do als [km, Preis]
dayFrSa   Tagespakete Fr/Sa
weekend   Wochenendpakete (Fr 12:00 bis Mo 10:00)
planKm    Mehrkilometer, vorab geplant (€/km)
overKm    Mehrkilometer, ungeplant bei Rückgabe (€/km)
frSaPlus  Zuschlag je Tag bei Abholung Fr oder Sa, nur 1–2 Tage
sb        Haftungsreduzierung je Stufe
```

Zwischenstufen zwischen den Paketen (z. B. 250 km zwischen 100 und 400)
werden automatisch als Mittelwert berechnet — nicht von Hand eintragen.

---

## Wie gerechnet wird

**1–2 Tage** laufen über die Tagespakete. Der Rechner wählt die günstigste Variante:
entweder das nächstgrößere Paket, oder ein kleineres plus geplante Mehrkilometer.

**Ab 3 Tagen** greift die Staffel, die auf den Wochenpreis zuläuft.
Der Tagessatz fällt dabei durchgehend, der Gesamtpreis steigt monoton.

**Wochenende** wird automatisch erkannt: Abholung Freitag ab 12:00 oder Samstag,
Rückgabe bis Montag 10:00. Dann gilt der Wochenendtarif statt der Staffel.

**Zusatzposten** sind freie Zeilen für Dinge ohne feste Regel —
Zusatzfahrer, AHK, Auslandsfahrt. Ein Minusbetrag funktioniert ebenfalls.

---

## Öffnungszeiten

Hinterlegt als `HOURS` im Script, getrennt pro Rechner:

```
Mo–Fr   8:00 – 18:00
Sa      8:00 – 13:00
So      geschlossen
```

In dieser internen Version sind alle Uhrzeiten wählbar;
Zeiten außerhalb sind mit *· ausserhalb* markiert.
Die Kundenversion auf der Website erlaubt bei der Abholung nur Öffnungszeiten
und weist bei der Rückgabe auf den Schlüsseltresor hin.

---

## Verwandte Dateien

Die Kundenversionen der beiden Rechner liegen **nicht** hier, sondern
als Custom Code direkt in Onepage (Fahrzeugseite, je ein Abschnitt).
Sie teilen die Rechenlogik, unterscheiden sich aber:

- Popup statt Tab, mit rotem Auslöse-Button
- WhatsApp-Button am Ende
- keine Einstellungsebene, keine Zusatzposten
- GA4-Tracking
- Abholung nur zu Öffnungszeiten

**Preisänderungen müssen dort separat gepflegt werden.**

---

## Domain

Registrar ist IONOS, die DNS-Zone liegt aber bei Onepage
(Nameserver `ns1.onepage.io` / `ns2.onepage.io`).
DNS-Einträge deshalb **in Onepage** pflegen, nicht bei IONOS —
dort sind sie wirkungslos.

Nötig waren:

```
CNAME   avj-tools   njay53.github.io
CAA     @           0 issue "letsencrypt.org"
```

Der CAA-Eintrag ist Pflicht: ohne ihn erlaubt die Domain nur Sectigo,
GitHub braucht aber Let's Encrypt.
