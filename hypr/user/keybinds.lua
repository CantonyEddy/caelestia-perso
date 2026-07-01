-- user/keybinds.lua — mes raccourcis perso (migré depuis l'ancien keybinds.conf)
--
-- Notes de migration :
--  * app2unit a été supprimé par Caelestia -> on lance via "uwsm app -- <cmd>".
--  * Ce fichier est chargé APRÈS les binds de Caelestia (require hypr-user en
--    dernier), donc un hl.bind sur une touche déjà prise l'ÉCRASE (dernier gagne).
--    C'est ainsi qu'on réassigne Super+M / Super+D sans "unbind".
--  * $kbCommunication / $kbMusic (anciennes variables) = Super+D / Super+M chez
--    Caelestia. On les réassigne directement à nos apps.

-- Lancement d'apps (remplace app2unit -- <app>)
hl.bind("SUPER + G", hl.dsp.exec_cmd("uwsm app -- steam"))
hl.bind("SUPER + O", hl.dsp.exec_cmd("uwsm app -- obsidian"))
hl.bind("SUPER + I", hl.dsp.exec_cmd("uwsm app -- claude-desktop"))

-- Override des toggles Caelestia : musique (Super+M) et communication (Super+D)
hl.bind("SUPER + D", hl.dsp.exec_cmd("uwsm app -- vesktop")) -- ex-$kbCommunication
hl.bind("SUPER + M", hl.dsp.exec_cmd("uwsm app -- spotify")) -- ex-$kbMusic

-- Sélecteur d'emoji : tue une instance existante de fuzzel sinon lance caelestia emoji
hl.bind("SUPER + semicolon", hl.dsp.exec_cmd("pkill fuzzel || caelestia emoji -p"))

-- ============================================================
-- Workspaces par KEYCODE (compatible AZERTY + QWERTY, tout clavier)
-- ============================================================
-- Réécrit les 4 binds workspace de Caelestia en utilisant les KEYCODES
-- physiques (code:10..19 = touches 1..0 de la rangée du haut) au lieu des
-- symboles 1..0 (qui en AZERTY donnent & é " ...).
--
-- IMPORTANT : on réutilise LEUR fonction fn.wsaction pour préserver la logique
-- per-monitor (perMonitorWorkspaces). On ne change QUE la touche.
-- Chargé après leur keybinds.lua -> ces binds écrasent les leurs (même combo).

local vars = require("variables")
local fn   = require("hyprland.functions")

for i = 1, 10 do
    local kc = "code:" .. (9 + i) -- i=1 -> code:10 (touche 1), i=10 -> code:19 (touche 0)
    hl.bind(vars.kbGoToWs .. " + " .. kc, fn.wsaction("focus", "", i))
    hl.bind(vars.kbMoveWinToWs .. " + " .. kc, fn.wsaction("move", "", i))
    hl.bind(vars.kbGoToWsGroup .. " + " .. kc, fn.wsaction("focus", "group", i))
    hl.bind(vars.kbMoveWinToWsGroup .. " + " .. kc, fn.wsaction("move", "group", i))
end

return true
