#!/usr/bin/env bash
# app-ws.sh — "lance si absente, sinon montre/cache" pour un special workspace.
#
# Usage : app-ws.sh <class> <nom_ws> <commande de lancement...>
#   <class>  : classe EXACTE de la fenêtre (voir : hyprctl clients)
#   <nom_ws> : nom du special workspace Caelestia (ex. steam -> special:steam)
#   reste    : commande pour lancer l'app (ex. uwsm app -- steam)
#
# Une window rule (user/rules.lua) envoie <class> dans special:<nom_ws>.
# Le toggle passe par `caelestia toggle` (compatible avec le dispatch Lua de
# Caelestia ; `hyprctl dispatch togglespecialworkspace` échoue dans cet env).
#
# Comportement :
#   - app déjà lancée  -> caelestia toggle (montre/cache son special workspace)
#   - app pas lancée   -> on la lance (la rule l'envoie dans special:<nom_ws>)
#                          puis caelestia toggle pour l'afficher.

class="$1"
ws="$2"
shift 2

# Détection insensible aux espaces (hyprctl -j : "class":"x" ou "class": "x").
if hyprctl clients -j | tr -d '[:space:]' | grep -qF "\"class\":\"$class\""; then
  caelestia toggle "$ws"
else
  "$@"
  caelestia toggle "$ws"
fi
