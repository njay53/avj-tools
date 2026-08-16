#!/bin/bash
#
# Kundenpreise aktualisieren.command
#
# Nimmt die frisch heruntergeladene preise.json aus dem Download-Ordner,
# prueft sie, zeigt was sich fuer Kunden aendert, und laedt sie hoch.
#
# Vorher in der App: Einstellungen -> "Fuer Kunden freigeben".
#
# Im Finder doppelklicken.

cd "$(dirname "$0")" || exit 1

ende() {
  echo ""
  read -r -p "  Enter zum Schliessen "
  exit "${1:-0}"
}

echo ""
echo "  AVJ Tools — Kundenpreise aktualisieren"
echo "  ──────────────────────────────────────"
echo ""

if ! git --version >/dev/null 2>&1; then
  echo "  Auf diesem Mac fehlen die Entwicklerwerkzeuge, zu denen git gehoert."
  echo "  Terminal oeffnen und eingeben:   xcode-select --install"
  ende 1
fi

if [ ! -d .git ]; then
  echo "  Hier liegt kein Git-Repository."
  ende 1
fi

# ── Die neueste preise.json im Download-Ordner suchen ─────────
# Auch "preise (1).json" und aehnliche, die Safari beim zweiten Mal anlegt.
NEU=""
if [ -d "$HOME/Downloads" ]; then
  NEU="$(find "$HOME/Downloads" -maxdepth 1 -name 'preise*.json' -type f -print0 2>/dev/null \
        | xargs -0 ls -t 2>/dev/null | head -1)"
fi

if [ -z "$NEU" ]; then
  echo "  Im Download-Ordner liegt keine preise.json."
  echo ""
  echo "  So kommt sie dorthin:"
  echo "    1. App oeffnen  →  9-Sitzer oder Transporter  →  Einstellungen"
  echo "    2. Knopf »Fuer Kunden freigeben«"
  echo "    3. Werte gegenlesen, dann herunterladen"
  echo "    4. Dieses Skript nochmal starten"
  ende 1
fi

echo "  Gefunden: $(basename "$NEU")"
echo "  vom $(date -r "$NEU" '+%d.%m.%Y %H:%M')"
echo ""

# ── Ist es ueberhaupt lesbares JSON? ──────────────────────────
# plutil gehoert zu macOS und versteht JSON — kein Zusatzwerkzeug noetig.
if ! plutil -lint "$NEU" >/dev/null 2>&1; then
  echo "  ✗ Die Datei ist kein gueltiges JSON und wurde NICHT uebernommen."
  echo "    Bitte in der App neu freigeben."
  ende 1
fi

# ── Inhaltliche Pruefung und Vergleich ────────────────────────
if command -v python3 >/dev/null 2>&1; then
  python3 - "$NEU" "preise.json" <<'PY'
import json, sys, os

neu_pfad, alt_pfad = sys.argv[1], sys.argv[2]
neu = json.load(open(neu_pfad, encoding="utf-8"))

fehler = []
for gruppe in ("neunsitzer", "transporter"):
    if gruppe not in neu:
        fehler.append(f"Bereich '{gruppe}' fehlt"); continue
    for name, auto in neu[gruppe].items():
        for feld in ("tier", "tierKm"):
            w = auto.get(feld)
            if not isinstance(w, list) or len(w) != 7:
                fehler.append(f"{name}: {feld} hat nicht 7 Werte")
            elif any((not isinstance(x, (int, float))) or x < 0 for x in w):
                fehler.append(f"{name}: {feld} enthaelt ungueltige Werte")
        t = auto.get("tier")
        if isinstance(t, list) and len(t) == 7:
            for i in range(1, 7):
                if t[i] < t[i-1]:
                    fehler.append(f"{name}: Staffelpreis faellt bei Tag {i+1} ({t[i-1]} -> {t[i]})")
        for feld in ("dayMoDo", "dayFrSa", "weekend"):
            if not isinstance(auto.get(feld), list) or not auto[feld]:
                fehler.append(f"{name}: {feld} fehlt oder ist leer")
        if not auto.get("sb"):
            fehler.append(f"{name}: Haftungsstufen fehlen")

if fehler:
    print("  ✗ Die Preisdatei ist nicht schluessig — NICHTS wurde uebernommen:")
    for f in fehler[:12]:
        print("     · " + f)
    sys.exit(3)

def blaetter(o, pfad=""):
    if isinstance(o, dict):
        for k, v in o.items():
            yield from blaetter(v, f"{pfad}.{k}" if pfad else k)
    elif isinstance(o, list) and o and isinstance(o[0], (dict, list)):
        for i, v in enumerate(o):
            yield from blaetter(v, f"{pfad}[{i}]")
    else:
        yield pfad, o

if os.path.exists(alt_pfad):
    alt = json.load(open(alt_pfad, encoding="utf-8"))
    a, n = dict(blaetter(alt)), dict(blaetter(neu))
    aend = [(k, a.get(k), n[k]) for k in n if k not in ("stand", "erzeugtVon") and a.get(k) != n[k]]
    weg  = [k for k in a if k not in n and k not in ("stand", "erzeugtVon")]
    if not aend and not weg:
        print("  • Keine Preisaenderung gegenueber dem, was Kunden schon sehen.")
        sys.exit(4)
    print(f"  Das aendert sich fuer Kunden ({len(aend)} Wert(e)):")
    print("")
    for k, v_alt, v_neu in aend[:25]:
        print(f"     {k}")
        print(f"        bisher: {v_alt}")
        print(f"        neu:    {v_neu}")
    if len(aend) > 25:
        print(f"     … und {len(aend)-25} weitere")
    for k in weg[:10]:
        print(f"     ENTFAELLT: {k}")
else:
    print("  Erste Preisdatei — bisher lag noch keine im Repository.")
print("")
sys.exit(0)
PY
  ERG=$?
  case "$ERG" in
    3) ende 1 ;;
    4) echo ""
       read -r -p "  Trotzdem hochladen? [j/n] " EGAL
       case "$EGAL" in j|J|ja|Ja|y|Y) ;; *) echo "  Abgebrochen."; ende 0 ;; esac ;;
  esac
else
  echo "  (python3 fehlt — es wird ohne Vergleich weitergemacht.)"
  echo ""
fi

read -r -p "  Diese Preise fuer Kunden uebernehmen? [j/n] " ANTWORT
case "$ANTWORT" in
  j|J|ja|Ja|y|Y) ;;
  *) echo "  Abgebrochen. Es wurde nichts veraendert."; ende 0 ;;
esac

# ── Sicherungskopie, damit ein Rueckweg bleibt ────────────────
if [ -f preise.json ]; then
  cp preise.json ".preise-vorher.json"
fi

cp "$NEU" preise.json || { echo "  ✗ Kopieren fehlgeschlagen."; ende 1; }
echo ""
echo "  Uebernommen. Lade hoch …"
echo ""

git add preise.json
if git diff --cached --quiet preise.json; then
  echo "  Keine Aenderung gegenueber dem letzten Stand — nichts hochzuladen."
  ende 0
fi

STAND="$(date '+%d.%m.%Y %H:%M')"
if ! git commit -q -m "Kundenpreise $STAND"; then
  echo "  ✗ Commit fehlgeschlagen."
  ende 1
fi

if git push -q; then
  echo "  ✓ Kundenpreise sind uebertragen."
  echo ""
  echo "    In ein bis zwei Minuten rechnen die Rechner auf der Website"
  echo "    mit den neuen Preisen:  https://rent-in-nom.de"
  echo ""
  echo "    Zum Gegenpruefen:  https://avj-tools.rent-in-nom.de/preise.json"
  echo ""
  echo "    Die vorherige Fassung liegt als .preise-vorher.json daneben."
else
  echo "  ✗ Uebertragung fehlgeschlagen. Der Commit liegt bereit,"
  echo "    ein erneuter Aufruf genuegt."
  echo ""
  echo "    Bei »403 / Permission denied«: Token-Freigabe fuer avj-tools pruefen"
  echo "    (github.com → Settings → Developer settings → Personal access tokens)."
  ende 1
fi

ende 0
