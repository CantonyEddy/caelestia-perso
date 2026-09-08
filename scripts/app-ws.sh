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

# Détection insensible aux espaces (hyprctl -j : "class":"x" ou "class": "x")
# ET à la casse (-i) : Obsidian a déjà changé la casse de sa classe 2 fois.
if hyprctl clients -j | tr -d '[:space:]' | grep -qiF "\"class\":\"$class\""; then
  caelestia toggle "$ws"
else
  "$@"
  # Lancement async : "$@" rend la main avant que la fenêtre existe. On attend
  # qu'une fenêtre de <class> soit née ET routée dans special:<ws> avant de
  # révéler le workspace, sinon on toggle un ws VIDE — et close_special_on_empty
  # (misc.lua) peut le refermer aussitôt, la fenêtre décroche alors sur le ws
  # courant. Poll ~8 s max (apps lentes type Electron/Obsidian).
  for _ in $(seq 1 80); do
    if hyprctl clients -j | jq -e --arg c "$class" --arg w "special:$ws" \
        '[.[] | select((.class | ascii_downcase) == ($c | ascii_downcase)
                        and .workspace.name == $w)] | length > 0' >/dev/null 2>&1; then
      break
    fi
    sleep 0.1
  done
  caelestia toggle "$ws"
fi
