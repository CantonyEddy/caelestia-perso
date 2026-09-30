# Module Home Manager commun à toutes les machines.
# Équivalent Nix de la section "link" de install.sh : MÊMES cibles, MÊMES sources.
# Si tu ajoutes un symlink dans install.sh, ajoute-le aussi ici (et inversement).
{ config, pkgs, caelestia-shell, user, ... }:
let
  # Le repo DOIT être cloné à cet emplacement (comme pour install.sh).
  repo = "${config.home.homeDirectory}/.local/share/caelestia-perso";
  # Symlink HORS du store : on édite le repo, l'effet est immédiat (pas de rebuild),
  # exactement comme les liens posés par install.sh.
  link = p: config.lib.file.mkOutOfStoreSymlink "${repo}/${p}";
in {
  imports = [ caelestia-shell.homeManagerModules.default ];

  home.username = user;
  home.homeDirectory = "/home/${user}";
  home.stateVersion = "25.11"; # NE PLUS JAMAIS CHANGER après le 1er switch
  programs.home-manager.enable = true;

  # Arch (non-NixOS) : intégration XDG + pilotes GPU pour les apps Nix (Qt/OpenGL).
  # Au 1er switch, HM demande de lancer une fois : sudo …/non-nixos-gpu-setup
  targets.genericLinux.enable = true;

  # Binaires Nix visibles dans la session Hyprland/uwsm (~/.config/environment.d/)
  systemd.user.sessionVariables.PATH = "${config.home.profileDirectory}/bin:$PATH";

  # --- Caelestia shell + CLI (flake upstream caelestia-dots/shell) ---
  # Remplace les paquets AUR caelestia-shell / caelestia-cli / quickshell :
  # NE PAS les installer en parallèle via paru.
  programs.caelestia = {
    enable = true;
    cli.enable = true;
    systemd.enable = false; # la config Hyprland de Caelestia lance déjà le shell
    # Pas de `settings` : shell.json vient du repo (symlink ci-dessous).
  };

  # --- Overrides Caelestia (~/.config/caelestia/) ---
  xdg.configFile = {
    "caelestia/hypr-vars.lua".source    = link "hypr/hypr-vars.lua";
    "caelestia/hypr-user.lua".source    = link "hypr/hypr-user.lua";
    "caelestia/user".source             = link "hypr/user";
    "caelestia/user-config.fish".source = link "fish/user-config.fish";
    "caelestia/shell.json".source       = link "shell/shell.json";

    # --- Apps pur perso (~/.config/<app>/) ---
    "fuzzel/fuzzel.ini".source   = link "config/fuzzel/fuzzel.ini";
    "cava/config".source         = link "config/cava/config";
    "htop/htoprc".source         = link "config/htop/htoprc";
    "zed/settings.json".source   = link "config/zed/settings.json";
    "zed/keymap.json".source     = link "config/zed/keymap.json";
    # Solaar : le paquet reste sur pacman (règles udev /dev/uinput système)
    "solaar/config.yaml".source  = link "config/solaar/config.yaml";
    "solaar/rules.yaml".source   = link "config/solaar/rules.yaml";
  };

  # Outils CLI des dépendances (les apps graphiques/GPU restent sur pacman).
  home.packages = with pkgs; [ fuzzel fzf jq cava htop ];
}
