# PC fixe — overrides par écran : à remplir après `hyprctl monitors`.
# 1. créer shell/monitors/<NOM>/shell.json dans le repo
# 2. décommenter/adapter la ligne ci-dessous, puis home-manager switch
{ config, ... }:
let
  link = p: config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/.local/share/caelestia-perso/${p}";
in {
  # xdg.configFile."caelestia/monitors/DP-1/shell.json".source = link "shell/monitors/DP-1/shell.json";
}
