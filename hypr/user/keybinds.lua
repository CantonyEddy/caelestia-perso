-- user/keybinds.lua — mes raccourcis perso (migré depuis l'ancien keybinds.conf)
--
-- Notes de migration :
--  * app2unit a été supprimé par Caelestia -> on lance via "uwsm app -- <cmd>".
--  * Ce fichier est chargé APRÈS les binds de Caelestia (require hypr-user en
--    dernier), donc un hl.bind sur une touche déjà prise l'ÉCRASE (dernier gagne).
--    C'est ainsi qu'on réassigne Super+M / Super+D sans "unbind".
--  * $kbCommunication / $kbMusic (anciennes variables) = Super+D / Super+M chez
--    Caelestia. On les réassigne directement à nos apps.

-- Special workspaces perso : "lance si absente, sinon montre/cache".
-- app-ws.sh lance l'app si absente (une window rule l'envoie dans special:<nom>)
-- puis `caelestia toggle <nom>` affiche/cache le workspace (toggle compatible
-- avec le dispatch Lua de Caelestia, contrairement à `hyprctl dispatch`).
local appws = "bash $HOME/.local/share/caelestia-perso/scripts/app-ws.sh"
hl.bind("SUPER + G", hl.dsp.exec_cmd(appws .. " steam steam uwsm app -- steam"))
hl.bind("SUPER + O", hl.dsp.exec_cmd(appws .. " obsidian obsidian uwsm app -- obsidian"))

-- Override des toggles Caelestia : musique (Super+M) et communication (Super+D)
hl.bind("SUPER + D", hl.dsp.exec_cmd("uwsm app -- vesktop")) -- ex-$kbCommunication
hl.bind("SUPER + M", hl.dsp.exec_cmd("uwsm app -- spotify")) -- ex-$kbMusic

-- Sélecteur d'emoji : tue une instance existante de fuzzel sinon lance caelestia emoji
hl.bind("SUPER + semicolon", hl.dsp.exec_cmd("pkill fuzzel || caelestia emoji -p"))

-- ============================================================
-- Couche HYPER (Caps Lock maintenu, via keyd)
-- ============================================================
-- keyd (config/keyd/default.conf) transforme Caps Lock en touche double rôle :
--   * tap        -> Verr.Maj normal
--   * maintenu+X -> émet une touche F13/F14/… qu'on lie ici.
-- keyd ne peut pas créer un vrai modificateur "Hyper", donc on passe par des
-- F-keys (jamais émises par un clavier physique -> zéro conflit).
-- On lie par KEYCODE (code:xkb = keycode Linux + 8) et non par nom, car les
-- dispositions (fr…) ne mappent pas toujours un keysym pour F13-F24 :
--   F13 -> Linux 183 -> code:191
--   F14 -> Linux 184 -> code:192
--   F15 -> Linux 185 -> code:193
--   F16 -> Linux 186 -> code:194
--   F17 -> Linux 187 -> code:195
-- Correspondance lettre -> F-key définie dans config/keyd/default.conf.
hl.bind("code:191", hl.dsp.exec_cmd(appws .. " com.anthropic.Claude claude uwsm app -- claude-desktop")) -- HYPER + C : Claude (special ws)
hl.bind("code:192", hl.dsp.exec_cmd("uwsm app -- zennotes"))       -- HYPER + N : zennotes
hl.bind("code:193", hl.dsp.exec_cmd(appws .. " org.mozilla.Thunderbird thunderbird uwsm app -- thunderbird")) -- HYPER + T : Thunderbird (special ws)
hl.bind("code:194", hl.dsp.exec_cmd(appws .. " signal signal uwsm app -- signal-desktop")) -- HYPER + S : Signal (special ws)
hl.bind("code:195", hl.dsp.exec_cmd(appws .. " org.keepassxc.KeePassXC keepassxc uwsm app -- keepassxc")) -- HYPER + A : KeePassXC

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
local fn   = require("utils.functions") -- déplacé depuis hyprland.functions (update caelestia)

for i = 1, 10 do
    local kc = "code:" .. (9 + i) -- i=1 -> code:10 (touche 1), i=10 -> code:19 (touche 0)
    hl.bind(vars.kbGoToWs .. " + " .. kc, fn.wsaction("focus", "", i))
    hl.bind(vars.kbMoveWinToWs .. " + " .. kc, fn.wsaction("move", "", i))
    hl.bind(vars.kbGoToWsGroup .. " + " .. kc, fn.wsaction("focus", "group", i))
    hl.bind(vars.kbMoveWinToWsGroup .. " + " .. kc, fn.wsaction("move", "group", i))
end

return true
