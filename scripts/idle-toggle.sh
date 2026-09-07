#!/usr/bin/env bash
# idle-toggle.sh — active/désactive la mise en veille (verrou d'écran auto).
#
# Pose (ou retire) un verrou Wayland "idle-inhibit". Hyprland respecte ce
# protocole : tant que le verrou est posé, AUCUN démon d'idle ne se déclenche
# (ni hypridle, ni le lock intégré au shell Caelestia). Idéal pour regarder
# une vidéo sans voir apparaître le verrou + mot de passe.
#
# Usage : idle-toggle.sh          -> bascule ON/OFF
# Lié à SUPER + I dans user/keybinds.lua.
#
# Dépendance : wlinhibit (AUR).  Installe-le avec :  paru -S wlinhibit
#   (ou yay -S wlinhibit).  Sans lui, le script te le rappelle.

INHIBITOR="wlinhibit"

notify() {
  command -v notify-send >/dev/null 2>&1 && \
    notify-send -a "Veille" -e -h "string:x-canonical-private-synchronous:idle-toggle" "$@"
}

if ! command -v "$INHIBITOR" >/dev/null 2>&1; then
  notify -u critical "wlinhibit manquant" "Installe-le : paru -S wlinhibit"
  exit 1
fi

if pgrep -x "$INHIBITOR" >/dev/null 2>&1; then
  # Verrou présent -> on l'enlève, la veille redevient normale.
  pkill -x "$INHIBITOR"
  notify " Veille réactivée" "L'écran se verrouillera après inactivité."
else
  # Pas de verrou -> on l'active, plus de mise en veille.
  setsid -f "$INHIBITOR" >/dev/null 2>&1
  notify "󰅶 Veille désactivée" "L'écran ne se verrouillera plus."
fi
