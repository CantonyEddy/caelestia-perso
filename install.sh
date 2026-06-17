#!/usr/bin/env bash
# install.sh — symlinke mes fichiers perso dans ~/.config/caelestia/
# Idempotent. Ne touche JAMAIS au repo caelestia lui-même.
#
# Pour chaque cible :
#  - déjà le bon symlink   -> ne fait rien
#  - fichier réel existant  -> sauvegarde en .bak-AAAAMMJJ-HHMMSS puis symlink
#  - absent                 -> symlink direct
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST="${XDG_CONFIG_HOME:-$HOME/.config}/caelestia"
STAMP="$(date +%Y%m%d-%H%M%S)"

link() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [[ -L "$dst" && "$(readlink -f "$dst")" == "$(readlink -f "$src")" ]]; then
    echo "  = $dst (déjà à jour)"
    return
  fi
  if [[ -e "$dst" || -L "$dst" ]]; then
    mv "$dst" "$dst.bak-$STAMP"
    echo "  ~ sauvegarde : $dst.bak-$STAMP"
  fi
  ln -sfn "$src" "$dst"
  echo "  → $dst"
}

echo "Linking fichiers perso depuis $REPO :"
link "$REPO/hypr/hypr-vars.conf"                "$DEST/hypr-vars.conf"
link "$REPO/hypr/hypr-user.conf"                "$DEST/hypr-user.conf"
link "$REPO/fish/user-config.fish"             "$DEST/user-config.fish"
link "$REPO/shell/shell.json"                   "$DEST/shell.json"
link "$REPO/shell/monitors/eDP-1/shell.json"    "$DEST/monitors/eDP-1/shell.json"
link "$REPO/shell/monitors/HDMI-A-1/shell.json" "$DEST/monitors/HDMI-A-1/shell.json"

echo "Terminé. Recharge Hyprland avec : hyprctl reload"
