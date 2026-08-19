#!/bin/bash
#
# hochladen.command — lädt den aktuellen Stand nach GitHub (njay53/avj-tools)
#
# Im Finder doppelklicken.
#
# Passwörter oder Zugangsdaten werden hier nirgends gespeichert — beim ersten
# Hochladen fragt macOS danach und legt sie im Schlüsselbund ab.

cd "$(dirname "$0")" || exit 1

ende() {
  echo ""
  read -r -p "  Enter zum Schliessen "
  exit "${1:-0}"
}

# Wartet, bis GitHub Pages die neue Fassung wirklich ausliefert.
# Gefragt wird version.json — dreissig Bytes statt 600 KB, und mit
# Zeitstempel in der Adresse, damit kein Zwischenspeicher antwortet.
online_pruefen() {
  local ZIEL="https://avj-tools.rent-in-nom.de/version.json"
  local I=0 GEFUNDEN=""
  echo "  Warte, bis GitHub Pages die neue Fassung ausliefert …"
  while [ $I -lt 30 ]; do
    GEFUNDEN="$(curl -s -m 8 -H 'Cache-Control: no-cache' \
                 "$ZIEL?t=$(date +%s)-$I" 2>/dev/null \
               | grep -o '"build"[^0-9]*[0-9]*' | grep -o '[0-9]*$')"
    if [ "$GEFUNDEN" = "$BUILD" ]; then
      echo ""
      echo "  ✓ Build $BUILD ist online."
      return 0
    fi
    I=$((I+1))
    printf "."
    sleep 4
  done
  echo ""
  echo "  Nach zwei Minuten liefert GitHub noch Build ${GEFUNDEN:-?} aus."
  echo "  Der Upload ist trotzdem durch — Pages ist manchmal langsamer."
  return 1
}

geschafft() {
  echo ""
  online_pruefen
  echo ""
  echo "    https://avj-tools.rent-in-nom.de"
  echo ""
  echo "  Zeigt die App trotz \"ist online\" eine aeltere Build-Nummer,"
  echo "  liegt es am Zwischenspeicher des Browsers und NICHT am Upload."
  echo "  Dann diese Adresse nehmen, die umgeht ihn:"
  echo "    https://avj-tools.rent-in-nom.de/?v=$BUILD"
  echo ""
  echo ""
  echo "  ACHTUNG, nicht mehr tun: Safari-Verlauf loeschen."
  echo "  Das entfernt auch den Speicher der App — Fahrzeuge, die noch"
  echo "  nicht freigegeben sind, das Archiv und den Zwischenspeicher der"
  echo "  Preisdatei. Die Adresse mit ?v= oben reicht voellig."
  echo ""
  echo "  Die App sagt seit Build 44 selbst Bescheid, wenn sie veraltet ist."
}

hochladen() {
  echo "  Lade hoch nach $(git remote get-url origin) …"
  echo ""
  echo "  Falls nach Benutzername und Passwort gefragt wird:"
  echo "    Username = njay53"
  echo "    Password = das Token (beginnt mit github_pat_), NICHT das Kontopasswort"
  echo "    Beim Einfügen bleibt die Zeile leer — das ist normal."
  echo "    Nur EINMAL einfügen, dann Enter."
  echo ""

  local LOG
  # Vorlage mit X'en: ohne die legt nur das mktemp von macOS eine Datei an,
  # jedes andere bricht ab — und die Fehlererkennung unten greift dann nie.
  LOG="$(mktemp "${TMPDIR:-/tmp}/avjpush.XXXXXX")"

  git push -u origin main 2>&1 | tee "$LOG"
  local STATUS=${PIPESTATUS[0]}

  if [ "$STATUS" -eq 0 ]; then
    rm -f "$LOG"
    geschafft
    return 0
  fi

  # ------------------------------------------------------------------
  # Auf GitHub liegt etwas, das hier fehlt — etwa weil eine Datei über die
  # Weboberfläche hochgeladen wurde. Git verweigert dann, um nichts zu
  # überschreiben.
  # ------------------------------------------------------------------
  if grep -qiE "fetch first|non-fast-forward|rejected" "$LOG"; then
    echo ""
    echo "  Auf GitHub liegt bereits etwas, das hier fehlt."
    echo "  Meist, weil eine Datei über die Weboberfläche hochgeladen wurde."
    echo ""
    echo "  Ich kann den Stand von GitHub holen und deinen daraufsetzen."
    echo "  Deine Dateien bleiben dabei erhalten."
    echo ""
    read -r -p "  Zusammenführen und nochmal versuchen? [j/n] " ANTWORT
    case "$ANTWORT" in
      j|J|ja|Ja|y|Y)
        echo ""
        if git pull --rebase origin main; then
          echo ""
          echo "  Zusammengeführt. Zweiter Versuch …"
          echo ""
          if git push -u origin main; then
            rm -f "$LOG"
            geschafft
            return 0
          fi
        else
          git rebase --abort 2>/dev/null
          echo ""
          echo "  Zusammenführen nicht möglich — dieselbe Datei wurde auf beiden"
          echo "  Seiten geändert."
          echo ""
          echo "  Das liegt derzeit auf GitHub:"
          git fetch -q origin main 2>/dev/null
          git log --oneline origin/main 2>/dev/null | sed 's/^/    /' | head -10
          echo ""
          git diff --name-only HEAD origin/main 2>/dev/null | sed 's/^/    /' | head -20
          echo ""

          # Dateien, die es NUR auf GitHub gibt, verschwinden beim Überschreiben.
          # Besonders heikel: CNAME — die eigene Domain.
          NUR_DORT="$(git diff --name-only --diff-filter=A HEAD origin/main 2>/dev/null)"
          if [ -n "$NUR_DORT" ]; then
            echo "  ACHTUNG — diese Dateien gibt es NUR auf GitHub und sie gehen verloren:"
            echo "$NUR_DORT" | sed 's/^/    · /'
            echo ""
            if echo "$NUR_DORT" | grep -qx "CNAME"; then
              echo "  Darunter CNAME — das ist deine eigene Domain. Ohne sie ist die App"
              echo "  danach nur noch unter njay53.github.io/avj-tools erreichbar."
              echo "  Besser abbrechen und die Datei hier anlegen:"
              echo "    echo \"avj-tools.rent-in-nom.de\" > CNAME"
              echo ""
            fi
          fi

          echo "  Wenn dort nichts Wichtiges liegt, kannst du deinen Stand"
          echo "  durchsetzen. Alles Obige wird auf GitHub ersetzt."
          echo "  Deine Dateien hier bleiben unangetastet."
          echo ""
          read -r -p "  Stand auf GitHub mit deinem überschreiben? [j/n] " HART
          case "$HART" in
            j|J|ja|Ja|y|Y)
              echo ""
              if git push -u origin main --force; then
                rm -f "$LOG"
                geschafft
                return 0
              fi
              ;;
            *)
              echo "  Abgebrochen. Auf GitHub wurde nichts verändert."
              ;;
          esac
        fi
        ;;
      *)
        echo "  Abgebrochen. Es wurde nichts verändert."
        ;;
    esac
    rm -f "$LOG"
    return 1
  fi

  # ------------------------------------------------------------------
  # 403 — angemeldet, aber kein Schreibrecht auf dieses Repo.
  # ------------------------------------------------------------------
  if grep -qiE "403|permission.*denied" "$LOG"; then
    rm -f "$LOG"
    echo ""
    echo "  GitHub hat das Schreiben verweigert (403)."
    echo ""
    echo "  Der Token ist wahrscheinlich in Ordnung, aber avj-tools steht nicht"
    echo "  auf seiner Repo-Liste. Bei einem fine-grained Token:"
    echo "    github.com → Settings → Developer settings → Personal access tokens"
    echo "    → Fine-grained tokens → Token öffnen → Repository access"
    echo "    → avj-tools dazunehmen (Contents: Read and write) → Save"
    echo ""
    echo "  Der Token-String ändert sich dabei nicht, im Schlüsselbund ist"
    echo "  also nichts zu tun. Danach dieses Skript erneut starten."
    echo ""
    echo "  Nur falls es ein classic Token ist: neuen mit repo-Scope anlegen und"
    echo "  den gemerkten Eintrag löschen:"
    echo "    printf \"protocol=https\\nhost=github.com\\n\\n\" | git credential-osxkeychain erase"
    return 1
  fi

  rm -f "$LOG"
  echo ""
  echo "  Hochladen fehlgeschlagen. Häufigste Gründe:"
  echo ""
  echo "    · Keine Internetverbindung."
  echo "    · Token falsch oder unvollständig eingefügt."
  echo "      Gemerkten Eintrag löschen und neu versuchen:"
  echo "        printf \"protocol=https\\nhost=github.com\\n\\n\" | git credential-osxkeychain erase"
  echo ""
  echo "  Der Commit bleibt erhalten. Dieses Skript einfach erneut starten —"
  echo "  es lädt dann den vorhandenen Stand hoch, ohne dass etwas verloren geht."
  return 1
}

echo ""
echo "  AVJ Tools — Hochladen nach GitHub"
echo "  ─────────────────────────────────"
echo ""

# ---------------------------------------------------------------- git vorhanden?
# Auf dem Mac existiert /usr/bin/git auch ohne Entwicklerwerkzeuge — es ist nur
# eine Hülle, die den Installationsdialog auslöst. Deshalb ein echter Aufruf.
if ! git --version >/dev/null 2>&1; then
  echo "  Auf diesem Mac fehlen noch die Entwicklerwerkzeuge, zu denen git gehört."
  echo ""
  echo "  Terminal öffnen und eingeben:   xcode-select --install"
  echo "  Danach dieses Skript erneut doppelklicken."
  ende 1
fi

if [ ! -d .git ]; then
  echo "  Hier liegt kein Git-Repository."
  echo "  Einmalig einrichten:"
  echo "    cd '/Users/niran/Documents/Claude Cowork/avj programme'"
  echo "    git clone https://github.com/njay53/avj-tools.git"
  ende 1
fi

# ---------------------------------------------------------------- Datei prüfen
if [ ! -f index.html ]; then
  echo "  index.html fehlt in $(pwd)"
  ende 1
fi

if ! grep -q '</html>' index.html; then
  echo "  index.html wirkt unvollständig — kein </html> gefunden."
  echo "  Sicherheitshalber wird nichts hochgeladen."
  ende 1
fi

BUILD=$(grep -o 'AVJ_BUILD = [0-9]*' index.html | head -1 | grep -o '[0-9]*')
[ -z "$BUILD" ] && BUILD="?"
GROESSE=$(( $(wc -c < index.html) / 1024 ))

echo "  Build $BUILD · ${GROESSE} KB"
echo ""

# Dreissig Bytes, die sagen, was online steht. Die App liest sie beim
# Start und meldet sich, wenn der Browser eine aeltere Fassung zeigt —
# das war lange ein Raten.
printf '{"build":%s,"stand":"%s"}\n' \
  "$BUILD" "$(date '+%d.%m.%Y %H:%M')" > version.json

# ---------------------------------------------------------------- Änderungen
#
# Der Rückgabewert von "git add" wird ausgewertet: schlägt es fehl, ist nichts
# vorgemerkt — und die Prüfung darunter meldete sonst seelenruhig "Alles aktuell".
if ! git add -A; then
  echo ""
  echo "  Die Änderungen liessen sich nicht vormerken — hochgeladen wurde NICHTS."
  echo ""
  if [ -f .git/index.lock ]; then
    echo "  Es liegt eine Sperrdatei herum: .git/index.lock"
    echo ""
    echo "  Die entsteht, wenn ein git-Vorgang mittendrin abgebrochen wurde."
    echo "  Sie zu entfernen ist gefahrlos, solange gerade kein anderes git läuft"
    echo "  — also kein zweites Fenster, in dem dieses Skript offen ist."
    echo ""
    read -r -p "  Sperrdatei entfernen und nochmal versuchen? [j/n] " ANTWORT
    case "$ANTWORT" in
      j|J|ja|Ja|y|Y)
        rm -f .git/index.lock
        echo ""
        if ! git add -A; then
          echo "  Klappt immer noch nicht. Hier hilft ein Blick ins Terminal:"
          echo "    cd \"$(pwd)\" && git status"
          ende 1
        fi
        echo "  Sperrdatei entfernt, weiter geht's."
        echo ""
        ;;
      *)
        echo "  Abgebrochen. Es wurde nichts verändert."
        ende 1
        ;;
    esac
  else
    echo "  Ursache steht oben. Nichts wurde verändert."
    ende 1
  fi
fi

if git diff --cached --quiet 2>/dev/null; then
  # Keine neuen Änderungen — aber vielleicht liegt hier ein fertiger Commit,
  # dessen Upload beim letzten Mal gescheitert ist. Der darf nicht liegenbleiben.
  OFFEN=0
  if git rev-parse HEAD >/dev/null 2>&1; then
    if git rev-parse --abbrev-ref --symbolic-full-name '@{u}' >/dev/null 2>&1; then
      OFFEN="$(git rev-list --count '@{u}'..HEAD 2>/dev/null || echo 0)"
    else
      OFFEN="$(git rev-list --count HEAD 2>/dev/null || echo 0)"
    fi
  fi

  if [ "${OFFEN:-0}" -gt 0 ]; then
    echo "  Keine neuen Änderungen — aber ${OFFEN} Commit(s) warten noch auf den Upload."
    echo ""
    hochladen
    ende 0
  fi

  echo "  Alles aktuell — es gibt nichts hochzuladen."
  echo "  Online ist Build $BUILD."
  ende 0
fi

echo "  Diese Dateien haben sich geändert:"
git diff --cached --name-status | sed 's/^/    /'
echo ""

read -r -p "  Kurze Beschreibung (Enter für \"Build $BUILD\"): " NACHRICHT
[ -z "$NACHRICHT" ] && NACHRICHT="Build $BUILD"

if ! git commit -q -m "$NACHRICHT"; then
  echo "  Commit fehlgeschlagen."
  echo "  Falls git nach Name und E-Mail fragt, einmal im Terminal setzen:"
  echo "    git config --global user.name \"Dein Name\""
  echo "    git config --global user.email \"deine@mail.de\""
  ende 1
fi

echo ""
hochladen
ende 0
