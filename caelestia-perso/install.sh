#!/usr/bin/env bash
# install.sh — symlinke mes fichiers perso dans ~/.config/caelestia/
# Version Lua (Caelestia >= migration Hyprland 0.55 / CLI v1.1.0).
# Idempotent. Ne touche JAMAIS au repo caelestia lui-même.
#
# Pour chaque cible :
#  - déjà le bon symlink    -> ne fait rien
#  - fichier/dossier réel    -> sauvegarde en .bak-AAAAMMJJ-HHMMSS puis symlink
#  - absent                  -> symlink direct
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

echo "Linking fichiers perso (version Lua) depuis $REPO :"
link "$REPO/hypr/hypr-vars.lua"                 "$DEST/hypr-vars.lua"
link "$REPO/hypr/hypr-user.lua"                 "$DEST/hypr-user.lua"
link "$REPO/hypr/user"                          "$DEST/user"
link "$REPO/fish/user-config.fish"              "$DEST/user-config.fish"
link "$REPO/shell/shell.json"                   "$DEST/shell.json"
link "$REPO/shell/monitors/eDP-1/shell.json"    "$DEST/monitors/eDP-1/shell.json"
link "$REPO/shell/monitors/HDMI-A-1/shell.json" "$DEST/monitors/HDMI-A-1/shell.json"

echo "Terminé. Recharge Hyprland avec : hyprctl reload"
