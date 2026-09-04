#!/usr/bin/env bash
# install.sh — symlinke mes fichiers perso dans ~/.config/caelestia/
# Version Lua (Caelestia >= migration Hyprland 0.55 / CLI v1.1.0).
# Idempotent. Ne touche JAMAIS au repo caelestia lui-même.
#
# Pour chaque cible :
#  - déjà le bon symlink     -> ne fait rien
#  - fichier/dossier réel    -> sauvegarde en .bak-AAAAMMJJ-HHMMSS puis symlink
#  - absent                  -> symlink direct
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CFG="${XDG_CONFIG_HOME:-$HOME/.config}"
DEST="$CFG/caelestia"
STAMP="$(date +%Y%m%d-%H%M%S)"

# Dépendances nécessaires aux configs versionnées, au format "binaire:paquet".
# Installées automatiquement si manquantes. Les paquets AUR nécessitent paru/yay.
DEPS=(
  "uwsm:uwsm"                         # requis : lancement des apps (uwsm app -- …)
  "keyd:keyd"                         # requis : couche HYPER (Caps Lock)
  "fuzzel:fuzzel"                     # launcher
  "cava:cava"                         # visualiseur audio
  "htop:htop"                         # moniteur système
  "zeditor:zed"                       # éditeur Zed (le binaire s'appelle zeditor)
  "spicetify:spicetify-cli"           # thème Spotify (AUR)
  "sddm:sddm"                         # display manager
)

# Applications lancées par les raccourcis (binaire:paquet). Proposées à
# l'installation via un sélecteur (choix total ou partiel), pas imposées.
# Édite/complète librement (noms de paquets AUR à ajuster selon ton helper).
APPS=(
  "steam:steam"                       # SUPER+G
  "obsidian:obsidian"                 # SUPER+O
  "claude-desktop:claude-desktop"     # HYPER+C (AUR)
  "thunderbird:thunderbird"           # HYPER+T
  "signal-desktop:signal-desktop"     # HYPER+S
  "zennotes:zennotes"                 # HYPER+N (AUR)
  "vesktop:vesktop"                   # SUPER+D (AUR : vesktop ou vesktop-bin)
  "spotify:spotify"                   # SUPER+M (AUR)
  "keepassxc:keepassxc"               # HYPER+A
)

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

# copy_root : copie un fichier vers une cible root-owned (ex. /etc) via sudo.
# Idempotent (ne recopie pas si identique), sauvegarde l'existant en .bak-<date>.
# Ne touche JAMAIS aux fichiers non listés (ex. theme.conf de SDDM).
copy_root() {
  local src="$1" dst="$2"
  if sudo cmp -s "$src" "$dst" 2>/dev/null; then
    echo "  = $dst (déjà à jour)"
    return
  fi
  sudo mkdir -p "$(dirname "$dst")"
  if sudo test -e "$dst"; then
    sudo cp -a "$dst" "$dst.bak-$STAMP"
    echo "  ~ sauvegarde : $dst.bak-$STAMP"
  fi
  sudo install -m 0644 "$src" "$dst"
  echo "  → $dst"
}

# check_deps : vérifie chaque binaire, installe les paquets manquants via paru/yay.
# Non bloquant : un échec d'install n'interrompt pas le reste du script.
check_deps() {
  local helper="" missing=() pair bin pkg
  if command -v paru >/dev/null 2>&1; then helper="paru"
  elif command -v yay  >/dev/null 2>&1; then helper="yay"; fi
  for pair in "${DEPS[@]}"; do
    bin="${pair%%:*}"; pkg="${pair##*:}"
    if command -v "$bin" >/dev/null 2>&1; then
      echo "  ✓ $bin"
    else
      echo "  ✗ manquant : $bin (paquet $pkg)"
      missing+=("$pkg")
    fi
  done
  if (( ${#missing[@]} == 0 )); then
    echo "  Toutes les dépendances sont présentes."
    return
  fi
  if [[ -n "$helper" ]]; then
    echo "  Installation via $helper : ${missing[*]}"
    "$helper" -S --needed --noconfirm "${missing[@]}" \
      || echo "  ! Échec d'installation de certaines dépendances — à installer à la main : ${missing[*]}"
  else
    echo "  ! Ni paru ni yay trouvé. Installe manuellement : ${missing[*]}"
  fi
}

# select_apps : liste les applis des raccourcis non installées et propose de les
# installer (toutes, aucune, ou une sélection). Interactif ; sauté hors terminal.
select_apps() {
  local helper="" pair bin pkg mbins=() mpkgs=() i ans n to=()
  if command -v paru >/dev/null 2>&1; then helper="paru"
  elif command -v yay  >/dev/null 2>&1; then helper="yay"; fi
  for pair in "${APPS[@]}"; do
    bin="${pair%%:*}"; pkg="${pair##*:}"
    if ! command -v "$bin" >/dev/null 2>&1; then mbins+=("$bin"); mpkgs+=("$pkg"); fi
  done
  if (( ${#mpkgs[@]} == 0 )); then
    echo "  Toutes les applis des raccourcis sont installées."
    return
  fi
  if [[ ! -t 0 ]]; then
    echo "  Applis manquantes (mode non interactif, à installer à la main) : ${mpkgs[*]}"
    return
  fi
  echo "  Applis des raccourcis non installées :"
  for i in "${!mbins[@]}"; do
    printf "    %2d) %-16s (paquet %s)\n" "$((i+1))" "${mbins[$i]}" "${mpkgs[$i]}"
  done
  echo "  Lesquelles installer ? [a=toutes, n=aucune, ou n° séparés par des espaces]"
  read -rp "  > " ans || ans="n"
  case "$ans" in
    a|A) to=("${mpkgs[@]}") ;;
    n|N|"") echo "  Aucune installation."; return ;;
    *)
      for n in $ans; do
        if [[ "$n" =~ ^[0-9]+$ ]] && (( n >= 1 && n <= ${#mpkgs[@]} )); then
          to+=("${mpkgs[$((n-1))]}")
        fi
      done
      ;;
  esac
  if (( ${#to[@]} == 0 )); then
    echo "  Aucune sélection valide, rien d'installé."
    return
  fi
  if [[ -n "$helper" ]]; then
    echo "  Installation via $helper : ${to[*]}"
    "$helper" -S --needed "${to[@]}" \
      || echo "  ! Échec sur certaines applis — à installer à la main : ${to[*]}"
  else
    echo "  ! Ni paru ni yay trouvé. Installe manuellement : ${to[*]}"
  fi
}

echo "Vérification des dépendances :"
check_deps

echo
echo "Linking fichiers perso (version Lua) depuis $REPO :"
link "$REPO/hypr/hypr-vars.lua"                 "$DEST/hypr-vars.lua"
link "$REPO/hypr/hypr-user.lua"                 "$DEST/hypr-user.lua"
link "$REPO/hypr/user"                          "$DEST/user"
link "$REPO/fish/user-config.fish"              "$DEST/user-config.fish"
link "$REPO/shell/shell.json"                   "$DEST/shell.json"
link "$REPO/shell/monitors/eDP-1/shell.json"    "$DEST/monitors/eDP-1/shell.json"
link "$REPO/shell/monitors/HDMI-A-1/shell.json" "$DEST/monitors/HDMI-A-1/shell.json"
# Template Starship (prompt perso) : caelestia le rend vers
# ~/.local/state/caelestia/theme/starship.toml à chaque changement de scheme.
link "$REPO/config/caelestia-templates/starship.toml" "$DEST/templates/starship.toml"

# Force un premier rendu du template (sinon il n'apparaît qu'au prochain scheme).
if command -v caelestia >/dev/null 2>&1; then
  cur="$(caelestia scheme get -n 2>/dev/null || true)"
  if [[ -n "$cur" ]] && caelestia scheme set -n "$cur" >/dev/null 2>&1; then
    echo "  ↻ scheme réappliqué → template starship rendu"
  fi
fi

echo
echo "Linking configs ~/.config perso depuis $REPO/config :"
# On ne versionne QUE les apps que Caelestia NE gère PAS (pur perso).
# Les apps gérées par Caelestia (foot, fish, fastfetch, micro, btop, starship...)
# sont laissées à Caelestia : il les déploie et applique ses couleurs dynamiques
# (scheme adapté au wallpaper). Les thèmes générés (zed/themes, spicetify/Themes)
# ne sont pas versionnés non plus.
link "$REPO/config/fuzzel/fuzzel.ini"                "$CFG/fuzzel/fuzzel.ini"
link "$REPO/config/cava/config"                      "$CFG/cava/config"
link "$REPO/config/htop/htoprc"                      "$CFG/htop/htoprc"
link "$REPO/config/zed/settings.json"                "$CFG/zed/settings.json"
link "$REPO/config/zed/keymap.json"                  "$CFG/zed/keymap.json"
link "$REPO/config/spicetify/config-xpui.ini"        "$CFG/spicetify/config-xpui.ini"
# Fichiers isolés à la racine de ~/.config (seedés manuellement, voir README)
[[ -e "$REPO/config/mimeapps.list" ]] && link "$REPO/config/mimeapps.list" "$CFG/mimeapps.list"

# Env de session machine-locale (~/.config/environment.d/), gitignoré : symlinké
# seulement si présent (donc absent chez les autres utilisateurs du repo).
if [[ -d "$REPO/config/env.d" ]]; then
  for f in "$REPO/config/env.d/"*.conf; do
    [[ -e "$f" ]] || continue
    link "$f" "$CFG/environment.d/$(basename "$f")"
  done
fi

echo
echo "Config keyd (/etc/keyd/, copie via sudo) :"
# Couche HYPER (Caps Lock double rôle). Nécessite le paquet 'keyd' :
#   paru -S keyd  &&  sudo systemctl enable --now keyd
if [[ -f "$REPO/config/keyd/default.conf" ]]; then
  copy_root "$REPO/config/keyd/default.conf" "/etc/keyd/default.conf"
  if command -v keyd >/dev/null 2>&1; then
    sudo keyd reload 2>/dev/null && echo "  ↻ keyd rechargé"
  else
    echo "  ! keyd non installé : 'paru -S keyd && sudo systemctl enable --now keyd'"
  fi
else
  echo "  (aucun fichier keyd dans le repo, ignoré)"
fi

echo
echo "Config SDDM (/etc/sddm.conf.d/, copie via sudo) :"
# On COPIE (pas symlink) chaque drop-in vers /etc. theme.conf (esthétique) est
# volontairement ignoré et jamais écrasé. Demande sudo une fois si besoin.
if [[ -d "$REPO/config/sddm/conf.d" ]]; then
  for f in "$REPO/config/sddm/conf.d/"*.conf; do
    [[ -e "$f" ]] || continue
    copy_root "$f" "/etc/sddm.conf.d/$(basename "$f")"
  done
else
  echo "  (aucun fichier SDDM dans le repo, ignoré)"
fi
# Config Hyprland du greeter (format hyprlang, PAS du INI) -> /etc/sddm/ .
# Destination distincte car référencée par CompositorCommand de 20-wayland.conf.
[[ -f "$REPO/config/sddm/hyprland-greeter.conf" ]] && \
  copy_root "$REPO/config/sddm/hyprland-greeter.conf" "/etc/sddm/hyprland-greeter.conf"

echo
echo "Applications des raccourcis :"
select_apps

echo "Terminé. Recharge Hyprland avec : hyprctl reload"
