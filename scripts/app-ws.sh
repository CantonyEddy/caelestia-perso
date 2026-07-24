#!/usr/bin/env bash
# app-ws.sh — "lance si absente, sinon montre/cache" pour un special workspace.
#
# Usage : app-ws.sh <class> <nom_ws> <commande de lancement...>
#   <class>  : classe EXACTE de la fenêtre (voir : hyprctl clients)
#   <nom_ws> : nom du special workspace (ex. steam -> special:steam)
#   reste    : commande pour lancer l'app (ex. uwsm app -- steam)
#
# Une window rule (user/rules.lua) doit envoyer <class> dans special:<nom_ws>.
# Comportement :
#   - app déjà lancée  -> on montre/cache son special workspace (toggle)
#   - app pas lancée   -> on la lance (la rule l'envoie dans special:<nom_ws>)
#                          puis on affiche le workspace pour la voir apparaître.

class="$1"
ws="$2"
shift 2

# Détection robuste : on retire tous les espaces du JSON avant de matcher,
# car hyprctl -j peut sortir "class":"x" ou "class": "x" selon la version.
if hyprctl clients -j | tr -d '[:space:]' | grep -qF "\"class\":\"$class\""; then
  hyprctl dispatch togglespecialworkspace "$ws"
else
  "$@"
  hyprctl dispatch togglespecialworkspace "$ws"
fi
