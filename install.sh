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
CFG="${XDG_CONFIG_HOME:-$HOME/.config}"
DEST="$CFG/caelestia"
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

echo
echo "Linking configs ~/.config perso depuis $REPO/config :"
# Apps CLI/rice éditées à la main. On ne symlinke QUE mes fichiers ;
# les thèmes générés par Caelestia (btop/themes, zed/themes, spicetify/Themes)
# restent gérés par Caelestia et ne sont pas versionnés.
link "$REPO/config/fish/config.fish"                 "$CFG/fish/config.fish"
link "$REPO/config/fish/functions/fish_greeting.fish" "$CFG/fish/functions/fish_greeting.fish"
link "$REPO/config/foot/foot.ini"                    "$CFG/foot/foot.ini"
link "$REPO/config/fuzzel/fuzzel.ini"                "$CFG/fuzzel/fuzzel.ini"
link "$REPO/config/btop/btop.conf"                   "$CFG/btop/btop.conf"
link "$REPO/config/cava/config"                      "$CFG/cava/config"
link "$REPO/config/fastfetch/config.jsonc"           "$CFG/fastfetch/config.jsonc"
link "$REPO/config/htop/htoprc"                      "$CFG/htop/htoprc"
link "$REPO/config/micro/settings.json"              "$CFG/micro/settings.json"
link "$REPO/config/zed/settings.json"                "$CFG/zed/settings.json"
link "$REPO/config/zed/keymap.json"                  "$CFG/zed/keymap.json"
link "$REPO/config/spicetify/config-xpui.ini"        "$CFG/spicetify/config-xpui.ini"
# Fichiers isolés à la racine de ~/.config (seedés manuellement, voir README)
[[ -e "$REPO/config/starship.toml" ]] && link "$REPO/config/starship.toml" "$CFG/starship.toml"
[[ -e "$REPO/config/mimeapps.list" ]] && link "$REPO/config/mimeapps.list" "$CFG/mimeapps.list"

echo "Terminé. Recharge Hyprland avec : hyprctl reload"
