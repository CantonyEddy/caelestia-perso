#!/usr/bin/env bash
# keybinds-menu.sh — cheat-sheet des raccourcis, façon Omarchy.
#
# Lancé par HYPER+K (hypr/user/keybinds.lua). Deux temps :
#   1. sans argument  -> calcule 55x70 % du moniteur focus et ouvre une fenêtre
#      foot (app-id « caelestia-keybinds », flottée+centrée par hypr/user/rules.lua),
#      fond OPAQUE (colors.alpha=1.0), qui se relance en mode --view ;
#   2. avec --view    -> tourne DANS foot : liste groupée par catégorie + fzf.
#
# Dimensionnement via foot (--window-size-pixels), pas via la window rule (les
# tailles en % n'y sont pas appliquées de façon fiable ici).
#
# Couleurs : fzf en INDICES ANSI (0-15), pas en hex — comme le prompt Starship.
# caelestia remappe la palette ANSI en direct -> le menu se recolore avec le
# scheme. Le fond `bg:-1` = fond thémé de foot : on garde l'alpha normal de foot
# (pas d'override) pour conserver le translucide + le flou de Caelestia, comme le
# terminal.
#
# Purement informatif : la sélection ne déclenche rien ; Échap/Entrée referme.
set -euo pipefail

repo="$HOME/.local/share/caelestia-perso"
data="$repo/scripts/keybinds.tsv"

if [[ "${1:-}" == "--view" ]]; then
  # Liste groupée : un en-tête coloré (ANSI -> --ansi) par catégorie, puis les
  # lignes « TOUCHES   action » alignées. TSV = CATÉGORIE <TAB> TOUCHES <TAB> action.
  list="$(awk -F'\t' '
    /^[[:space:]]*#/ { next }
    NF < 3           { next }
    { c++; cat[c] = $1; key[c] = $2; act[c] = $3; if (length($2) > w) w = length($2) }
    END {
      for (i = 1; i <= c; i++) {
        if (cat[i] != prev) {
          if (prev != "") print ""
          printf "\033[1;34m%s\033[0m\n", cat[i]
          prev = cat[i]
        }
        printf "  %-*s   %s\n", w, key[i], act[i]
      }
    }' "$data")"

  printf '%s\n' "$list" \
    | fzf --ansi --prompt 'Rechercher  ' \
          --header 'Raccourcis — Échap pour fermer' \
          --layout reverse --info inline --cycle --no-mouse \
          --color 'fg:-1,bg:-1,fg+:-1,bg+:8,hl:5,hl+:13,prompt:4,pointer:5,marker:6,header:6,info:8,spinner:5,gutter:-1' \
    >/dev/null || true
  exit 0
fi

# Taille = 55x70 % du moniteur focus (px logiques). Fallback si jq/hyprctl KO.
w=1000 h=700
if command -v jq >/dev/null 2>&1; then
  read -r mw mh < <(hyprctl monitors -j 2>/dev/null \
    | jq -r 'map(select(.focused))[0] | "\((.width/.scale)|floor) \((.height/.scale)|floor)"' 2>/dev/null) || true
  if [[ "${mw:-}" =~ ^[0-9]+$ && "${mh:-}" =~ ^[0-9]+$ ]]; then
    w=$(( mw * 55 / 100 )); h=$(( mh * 70 / 100 ))
  fi
fi

# Pas d'override d'alpha : foot garde son fond translucide -> le flou de Caelestia
# s'applique (comme le terminal). blur = décoration Hyprland sur la fenêtre flottante.
exec foot --window-size-pixels="${w}x${h}" \
  -a caelestia-keybinds -T Keybindings \
  bash "$repo/scripts/keybinds-menu.sh" --view
