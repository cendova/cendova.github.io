#!/bin/sh
# CendovaPlan - Installation auf dem Mac per Terminal-Einzeiler:
#
#   curl -fsSL https://cendova.de/install-mac.sh | bash
#
# Hintergrund: Aus dem Browser geladene Dateien versieht macOS mit einem
# Quarantaene-Attribut; unsignierte Skripte blockiert Gatekeeper dann beim
# Doppelklick ("... nicht geoeffnet"). Per curl geladene Dateien erhalten
# dieses Attribut nicht - dieser Weg funktioniert daher ohne Signatur und
# ohne dass Sicherheitsabfragen ausgehebelt werden muessen.
#
# Dieses Skript laedt nur den eigentlichen Installer aus dem oeffentlichen
# Repository und fuehrt ihn mit bash aus. Quelle (einsehbar):
#   https://github.com/cendova/cendova-plan/blob/main/installer/install-mac.command
set -u

URL="https://raw.githubusercontent.com/cendova/cendova-plan/main/installer/install-mac.command"

if [ "$(uname -s)" != "Darwin" ]; then
  echo 'Dieses Skript ist fuer macOS gedacht.' >&2
  echo 'Windows: Installer-ZIP auf https://cendova.de laden (Installieren.cmd).' >&2
  exit 1
fi

TMP="$(mktemp "${TMPDIR:-/tmp}/cendova-install.XXXXXX")" || exit 1
trap 'rm -f "$TMP"' EXIT

echo 'CendovaPlan: Installer wird geladen ...'
if ! curl -fsSL "$URL" -o "$TMP"; then
  echo 'FEHLER: Installer konnte nicht geladen werden (Internet? Firewall?).' >&2
  exit 1
fi

# Eingaben (z. B. die Branch-Abfrage) kommen explizit vom Terminal, damit
# der Installer auch bei `curl ... | bash` interaktiv bleibt.
if [ -r /dev/tty ]; then
  /bin/bash "$TMP" < /dev/tty
else
  /bin/bash "$TMP"
fi
