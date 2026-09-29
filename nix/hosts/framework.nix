# Framework 16 (portable) — écrans : eDP-1 (interne) + HDMI-A-1
{ config, ... }:
let
  link = p: config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/.local/share/caelestia-perso/${p}";
in {
  xdg.configFile."caelestia/monitors/eDP-1/shell.json".source    = link "shell/monitors/eDP-1/shell.json";
  xdg.configFile."caelestia/monitors/HDMI-A-1/shell.json".source = link "shell/monitors/HDMI-A-1/shell.json";
}
