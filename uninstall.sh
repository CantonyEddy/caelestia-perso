#!/usr/bin/env bash
# uninstall.sh — retire la surcouche perso (l'inverse de install.sh).
# Ne restaure PAS les .bak : une fois le symlink retiré, Caelestia régénère
# ses défauts au prochain reload (ou l'app repart sur ses réglages par défaut).
# Ne touche JAMAIS au repo caelestia lui-même, ni aux paquets installés.
#
# Zones traitées :
#   1. Symlinks perso dans ~/.config/ (retirés seulement s'ils pointent vers CE repo)
#   2. /etc/keyd/default.conf                (retiré si identique à la version du repo)
#   3. SDDM /etc/…  -> NON par défaut (chemin de boot/login critique).
#      Activer explicitement avec --sddm. Chaque fichier est sauvegardé en .bak
#      avant suppression, quoi qu'il arrive.
#
# Usage :
#   ./uninstall.sh              # config utilisateur + keyd
#   ./uninstall.sh --sddm       # + retire aussi la config SDDM /etc (DANGER, voir plus bas)
#   ./uninstall.sh --dry-run    # montre ce qui serait fait, ne touche à rien
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CFG="${XDG_CONFIG_HOME:-$HOME/.config}"
DEST="$CFG/caelestia"
STAMP="$(date +%Y%m%d-%H%M%S)"

DO_SDDM=0
DRY=0
for arg in "$@"; do
  case "$arg" in
    --sddm)    DO_SDDM=1 ;;
    --dry-run) DRY=1 ;;
    *) echo "Argument inconnu : $arg" >&2; exit 2 ;;
  esac
done

run() { if (( DRY )); then echo "    [dry-run] $*"; else eval "$@"; fi; }

# unlink_repo : retire la cible UNIQUEMENT si c'est un symlink pointant dans ce repo.
# Un fichier réel (non-symlink) ou un lien vers ailleurs est laissé intact.
unlink_repo() {
  local dst="$1" target
  if [[ -L "$dst" ]]; then
    target="$(readlink -f "$dst" 2>/dev/null || true)"
    if [[ "$target" == "$REPO"/* ]]; then
      run "rm -f '$dst'"
      echo "  ✗ $dst (symlink retiré)"
    else
      echo "  = $dst (symlink hors-repo → laissé)"
    fi
  elif [[ -e "$dst" ]]; then
    echo "  = $dst (fichier réel, pas un symlink → laissé)"
  else
    echo "  · $dst (absent)"
  fi
}

# remove_root_if_ours : retire un fichier /etc SEULEMENT s'il est identique à la
# version du repo (donc bien celui qu'install.sh a posé). Sauvegarde toujours avant.
remove_root_if_ours() {
  local src="$1" dst="$2"
  if ! sudo test -e "$dst"; then
    echo "  · $dst (absent)"
    return
  fi
  if sudo cmp -s "$src" "$dst" 2>/dev/null; then
    run "sudo cp -a '$dst' '$dst.bak-$STAMP'"
    run "sudo rm -f '$dst'"
    echo "  ✗ $dst (retiré, sauvegarde .bak-$STAMP)"
  else
    echo "  = $dst (diffère du repo → laissé, à vérifier à la main)"
  fi
}

echo "Repo   : $REPO"
echo "Config : $CFG"
(( DRY )) && echo "MODE DRY-RUN : rien ne sera modifié."
echo

echo "1) Symlinks perso dans ~/.config/caelestia/ :"
unlink_repo "$DEST/hypr-vars.lua"
unlink_repo "$DEST/hypr-user.lua"
unlink_repo "$DEST/user"
unlink_repo "$DEST/user-config.fish"
unlink_repo "$DEST/shell.json"
unlink_repo "$DEST/monitors/eDP-1/shell.json"
unlink_repo "$DEST/monitors/HDMI-A-1/shell.json"

echo
echo "2) Symlinks apps perso dans ~/.config/ :"
unlink_repo "$CFG/fuzzel/fuzzel.ini"
unlink_repo "$CFG/cava/config"
unlink_repo "$CFG/htop/htoprc"
unlink_repo "$CFG/zed/settings.json"
unlink_repo "$CFG/zed/keymap.json"
# (spicetify/config-xpui.ini n'est plus symlinké : géré localement par spicetify)
unlink_repo "$CFG/mimeapps.list"
# environment.d/ : liens éventuels vers config/env.d/*.conf
if [[ -d "$CFG/environment.d" ]]; then
  for l in "$CFG/environment.d/"*.conf; do
    [[ -L "$l" ]] || continue
    unlink_repo "$l"
  done
fi

echo
echo "3) keyd (/etc/keyd/default.conf, via sudo) :"
if [[ -f "$REPO/config/keyd/default.conf" ]]; then
  remove_root_if_ours "$REPO/config/keyd/default.conf" "/etc/keyd/default.conf"
  if command -v keyd >/dev/null 2>&1; then
    run "sudo keyd reload 2>/dev/null" && echo "  ↻ keyd rechargé"
  fi
else
  echo "  (pas de fichier keyd dans le repo)"
fi

echo
echo "4) SDDM (/etc/…) :"
if (( DO_SDDM )); then
  echo "  ⚠️  Retrait de la config SDDM du chemin de login. Garde un TTY prêt"
  echo "     (Ctrl+Alt+F3) au cas où le prochain boot ne présenterait plus SDDM."
  if [[ -d "$REPO/config/sddm/conf.d" ]]; then
    for f in "$REPO/config/sddm/conf.d/"*.conf; do
      [[ -e "$f" ]] || continue
      remove_root_if_ours "$f" "/etc/sddm.conf.d/$(basename "$f")"
    done
  fi
  [[ -f "$REPO/config/sddm/hyprland-greeter.conf" ]] && \
    remove_root_if_ours "$REPO/config/sddm/hyprland-greeter.conf" "/etc/sddm/hyprland-greeter.conf"
else
  echo "  (ignoré — relancer avec --sddm pour l'inclure)"
  echo "  Rappel : le greeter tourne via /etc/sddm/hyprland-greeter.conf référencé"
  echo "  par CompositorCommand de 20-wayland.conf. Le retirer peut casser le login."
fi

echo
echo "Terminé.$( (( DRY )) && echo ' (dry-run)')"
echo "Les .bak-<date> créés par install.sh sont laissés en place : à supprimer à la main quand tu es sûr."
(( DO_SDDM == 0 )) && echo "Config SDDM non touchée. Recharge Hyprland si besoin : hyprctl reload"
