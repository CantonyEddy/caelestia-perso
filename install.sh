#!/usr/bin/env bash
# install.sh — symlinke mes fichiers perso dans ~/.config/caelestia/
# Version Lua (Caelestia >= migration Hyprland 0.55 / CLI v1.1.0).
# Idempotent. Ne touche JAMAIS au repo caelestia lui-même.
#
# Deux modes, détectés automatiquement (aucun flag) :
#  - SANS Nix (défaut)   : pose tous les symlinks + /etc + dépendances.
#  - AVEC Home Manager   : un symlink déjà posé par HM (lien vers /nix/store,
#    cf. nix/home.nix) est laissé tel quel ; le script ne fait plus que les
#    dépendances pacman/AUR, /etc (keyd, SDDM) et les applis. Lancer HM AVANT.
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

# Outils installés par Home Manager visibles pour check_deps (sans effet sans Nix)
for p in "$HOME/.nix-profile/bin" "/etc/profiles/per-user/$USER/bin"; do
  [[ -d "$p" && ":$PATH:" != *":$p:"* ]] && PATH="$p:$PATH"
done

# Dépendances nécessaires aux configs versionnées, au format "binaire:paquet".
# Installées automatiquement si manquantes. Les paquets AUR nécessitent paru/yay.
DEPS=(
  "uwsm:uwsm"                         # requis : lancement des apps (uwsm app -- …)
  "keyd:keyd"                         # requis : couche HYPER (Caps Lock)
  "fuzzel:fuzzel"                     # launcher
  "fzf:fzf"                           # recherche floue (cheat-sheet HYPER+K)
  "jq:jq"                             # calcul taille fenêtre cheat-sheet (55x70 %)
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
  "solaar:solaar"                     # souris Logitech (MX Master 3) — optionnel
)

# hm_managed : vrai si la cible est un symlink posé par Home Manager (→ /nix/store).
hm_managed() { [[ -L "$1" && "$(readlink "$1")" == /nix/store/* ]]; }

link() {
  local src="$1" dst="$2"
  if hm_managed "$dst"; then
    echo "  ⌂ $dst (géré par Home Manager, laissé)"
    return
  fi
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

# Sauvegardes des fichiers /etc remplacés : HORS des dossiers de config.
# ⚠️ JAMAIS de .bak à côté de la cible : SDDM lit TOUS les fichiers de
# /etc/sddm.conf.d/ (aucun filtre sur l'extension, tri alphabétique, le dernier
# gagne) -> un "20-wayland.conf.bak-…" y écrasait silencieusement le
# 20-wayland.conf déployé. C'est la vraie cause de l'écran noir d'août 2026.
ROOT_BACKUP="/var/backups/caelestia-perso/$STAMP"

# copy_root : copie un fichier vers une cible root-owned (ex. /etc) via sudo.
# Idempotent (ne recopie pas si identique), sauvegarde l'existant dans
# $ROOT_BACKUP/<chemin complet>. Ne touche JAMAIS aux fichiers non listés
# (ex. theme.conf de SDDM).
copy_root() {
  local src="$1" dst="$2"
  if sudo cmp -s "$src" "$dst" 2>/dev/null; then
    echo "  = $dst (déjà à jour)"
    return
  fi
  sudo mkdir -p "$(dirname "$dst")"
  if sudo test -e "$dst"; then
    sudo mkdir -p "$ROOT_BACKUP$(dirname "$dst")"
    sudo cp -a "$dst" "$ROOT_BACKUP$dst"
    echo "  ~ sauvegarde : $ROOT_BACKUP$dst"
  fi
  sudo install -m 0644 "$src" "$dst"
  echo "  → $dst"
}

# purge_dropin_baks : sort de /etc/sddm.conf.d/ les sauvegardes laissées par les
# anciennes versions d'install.sh (*.bak*, *.save, *~) -> $ROOT_BACKUP. Elles
# étaient lues par SDDM comme de la config active.
purge_dropin_baks() {
  local dir="$1" f found=0
  sudo test -d "$dir" || return 0
  while IFS= read -r -d '' f; do
    found=1
    sudo mkdir -p "$ROOT_BACKUP$dir"
    sudo mv "$f" "$ROOT_BACKUP$dir/"
    echo "  ~ sauvegarde parasite déplacée : $f -> $ROOT_BACKUP$dir/"
  done < <(sudo find "$dir" -maxdepth 1 -type f \( -name '*.bak*' -o -name '*.save' -o -name '*~' \) -print0)
  (( found )) || echo "  = $dir : aucune sauvegarde parasite"
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

if hm_managed "$DEST/hypr-user.lua"; then
  echo "Mode Home Manager détecté : les symlinks gérés par HM ne sont pas touchés."
  # caelestia-shell/cli viennent du flake Nix : pas de doublon AUR/pacman.
  dup="$(pacman -Qq caelestia-shell caelestia-cli quickshell quickshell-git 2>/dev/null || true)"
  [[ -n "$dup" ]] && echo "  ! Doublon avec Nix, à retirer : sudo pacman -Rns $(echo $dup)"
  echo
fi

echo "Vérification des dépendances :"
check_deps

echo
echo "Linking fichiers perso (version Lua) depuis $REPO :"
link "$REPO/hypr/hypr-vars.lua"                 "$DEST/hypr-vars.lua"
link "$REPO/hypr/hypr-user.lua"                 "$DEST/hypr-user.lua"
link "$REPO/hypr/user"                          "$DEST/user"
link "$REPO/fish/user-config.fish"              "$DEST/user-config.fish"
link "$REPO/shell/shell.json"                   "$DEST/shell.json"
# Config CLI Caelestia : toggles SUPER+D (vesktop) / SUPER+M (spotify), lue à la
# fois par la fonction Lua fn.toggle et par `caelestia toggle`.
link "$REPO/config/caelestia/cli.json"          "$DEST/cli.json"
link "$REPO/shell/monitors/eDP-1/shell.json"    "$DEST/monitors/eDP-1/shell.json"
link "$REPO/shell/monitors/HDMI-A-1/shell.json" "$DEST/monitors/HDMI-A-1/shell.json"
# Prompt Starship perso : rien à symlinker ici. La config (config/starship.toml,
# couleurs ANSI, statique) est pointée par STARSHIP_CONFIG dans user-config.fish
# (déjà symlinké ci-dessus). caelestia remappe la palette → recolore en direct.

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
# Solaar (souris Logitech, optionnel) :
#  - rules.yaml (règles du Rule Editor, portables) -> symlink ;
#  - config.yaml = ÉTAT MACHINE (n° d'unité, cookie, batterie… réécrits en
#    continu par Solaar) -> PAS de symlink (polluait le repo), seulement une
#    graine copiée si absente. Même logique que spicetify/config-xpui.ini.
link "$REPO/config/solaar/rules.yaml"                "$CFG/solaar/rules.yaml"
scfg_solaar="$CFG/solaar/config.yaml"
if [[ -L "$scfg_solaar" && "$(readlink -f "$scfg_solaar")" == "$REPO"/* ]]; then
  cp --remove-destination "$(readlink -f "$scfg_solaar")" "$scfg_solaar"
  echo "  ~ $scfg_solaar : ancien symlink remplacé par une copie locale"
elif [[ ! -e "$scfg_solaar" ]] && ! hm_managed "$scfg_solaar"; then
  mkdir -p "$(dirname "$scfg_solaar")"
  cp "$REPO/config/solaar/config.yaml" "$scfg_solaar"
  echo "  → $scfg_solaar (graine copiée)"
else
  echo "  = $scfg_solaar (local, laissé)"
fi
# logiops (logid) et Solaar se disputent la souris : un seul des deux.
if systemctl is-enabled --quiet logid 2>/dev/null || pgrep -x logid >/dev/null 2>&1; then
  echo "  ! logiops (logid) actif : conflit avec Solaar → sudo systemctl disable --now logid"
fi
# Spicetify : on ne symlinke PAS config-xpui.ini. spicetify le réécrit à chaque
# `apply` (prefs_path/spotify_path auto-détectés + [Backup] version = ÉTAT MACHINE,
# non portable) → via un symlink ça polluerait le repo. On applique juste les
# PRÉFÉRENCES portables via `spicetify config` (spicetify gère les chemins locaux).
if command -v spicetify >/dev/null 2>&1; then
  scfg="$CFG/spicetify/config-xpui.ini"
  # retire un ancien symlink repo pour que spicetify écrive un fichier LOCAL
  if [[ -L "$scfg" && "$(readlink -f "$scfg")" == "$REPO"/* ]]; then
    rm -f "$scfg"; echo "  ~ ancien symlink spicetify retiré (fichier local régénéré)"
  fi
  spicetify config \
    current_theme caelestia color_scheme caelestia \
    inject_css 1 replace_colors 1 inject_theme_js 1 \
    home_config 1 experimental_features 1 custom_apps marketplace \
    >/dev/null 2>&1 && echo "  → préférences spicetify appliquées (thème caelestia + options)"
  spicetify apply >/dev/null 2>&1 || echo "  ! spicetify apply à relancer à la main (Spotify lancé au moins une fois ?)"
fi
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
echo "Config SDDM (/etc/sddm.conf.d/ + /etc/sddm/, copie via sudo) :"
# Ordre IMPORTANT (chemin de boot) :
#  1. purge des .bak parasites de sddm.conf.d (lus par SDDM comme de la config) ;
#  2. dépôt des DEUX configs du greeter (.lua ET .conf) dans /etc/sddm/ — le
#     .conf reste en filet de secours, jamais supprimé ;
#  3. seulement ensuite les drop-ins. 20-wayland.conf pointe sur le .lua ; s'il
#     n'est pas validé par `Hyprland --verify-config`, on déploie à la place une
#     variante qui pointe sur le .conf (toujours bootable en Hyprland <= 0.56).
# theme.conf (esthétique) est volontairement ignoré et jamais écrasé.
GREETER_DIR="/etc/sddm"
purge_dropin_baks "/etc/sddm.conf.d"
for g in hyprland-greeter.lua hyprland-greeter.conf; do
  [[ -f "$REPO/config/sddm/$g" ]] && copy_root "$REPO/config/sddm/$g" "$GREETER_DIR/$g"
done

greeter_lua_ok() {
  sudo test -s "$GREETER_DIR/hyprland-greeter.lua" || return 1
  command -v Hyprland >/dev/null 2>&1 || return 1
  timeout 15 Hyprland --verify-config --config "$GREETER_DIR/hyprland-greeter.lua" >/dev/null 2>&1
}

if [[ -d "$REPO/config/sddm/conf.d" ]]; then
  for f in "$REPO/config/sddm/conf.d/"*.conf; do
    [[ -e "$f" ]] || continue
    if [[ "$(basename "$f")" == "20-wayland.conf" ]] && ! greeter_lua_ok; then
      echo "  ! hyprland-greeter.lua NON validé par Hyprland --verify-config :"
      echo "    le greeter reste sur hyprland-greeter.conf (OK jusqu'à Hyprland 0.56)."
      tmp="$(mktemp)"
      sed 's#/etc/sddm/hyprland-greeter\.lua#/etc/sddm/hyprland-greeter.conf#' "$f" > "$tmp"
      copy_root "$tmp" "/etc/sddm.conf.d/20-wayland.conf"
      rm -f "$tmp"
      continue
    fi
    copy_root "$f" "/etc/sddm.conf.d/$(basename "$f")"
  done
else
  echo "  (aucun fichier SDDM dans le repo, ignoré)"
fi
echo "  Greeter actif : $(grep -h '^CompositorCommand' /etc/sddm.conf.d/*.conf 2>/dev/null | tail -1)"

echo
echo "Applications des raccourcis :"
select_apps

echo "Terminé. Recharge Hyprland avec : hyprctl reload"
