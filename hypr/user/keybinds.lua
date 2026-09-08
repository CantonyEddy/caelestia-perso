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
hl.bind("SUPER + O", hl.dsp.exec_cmd(appws .. " md.obsidian.Obsidian obsidian uwsm app -- obsidian"))

-- Override des toggles Caelestia : musique (Super+M) et communication (Super+D)
hl.bind("SUPER + D", hl.dsp.exec_cmd("uwsm app -- vesktop")) -- ex-$kbCommunication
hl.bind("SUPER + M", hl.dsp.exec_cmd("uwsm app -- spotify")) -- ex-$kbMusic

-- Sélecteur d'emoji : tue une instance existante de fuzzel sinon lance caelestia emoji
hl.bind("SUPER + semicolon", hl.dsp.exec_cmd("pkill fuzzel || caelestia emoji -p"))

-- Anti-veille : bascule un verrou Wayland idle-inhibit (respecté par Hyprland,
-- donc stoppe la mise en veille / le verrou d'écran auto). Pour les vidéos.
-- Dépend de wlinhibit (AUR) : paru -S wlinhibit
hl.bind("SUPER + I", hl.dsp.exec_cmd("bash $HOME/.local/share/caelestia-perso/scripts/idle-toggle.sh"))

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

-- HYPER + K : cheat-sheet des raccourcis (façon Omarchy). keyd envoie K en F23
-- (code:201). On ouvre une fenêtre foot 'caelestia-keybinds' qui lance fzf sur
-- scripts/keybinds.tsv ; une window rule (user/rules.lua) la flotte/centre à 55x70 %.
--   F23 -> Linux 193 -> code:201
-- Le script calcule la taille (55x70 % du moniteur) et lance foot lui-même ;
-- la window rule ne fait que flotter/centrer (les tailles en % n'y passent pas).
hl.bind("code:201", hl.dsp.exec_cmd("bash $HOME/.local/share/caelestia-perso/scripts/keybinds-menu.sh"))

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

-- ============================================================
-- Binds SYMBOLES réécrits en KEYCODE (parité QWERTY -> AZERTY)
-- ============================================================
-- Caelestia écrit ces raccourcis pour un clavier QWERTY. En AZERTY (kb_layout=fr)
-- les keysyms -, =, \, "," tombent ailleurs, voire sont injoignables :
--   backslash = AltGr+8  -> les binds "Center window", "PiP" et "resize 55x70"
--   étaient donc IMPOSSIBLES à déclencher en AZERTY.
-- On rebind par KEYCODE physique pour retrouver la POSITION du QWERTY documenté
-- (le screenshot des raccourcis), quelle que soit la disposition. Chargé après
-- leur keybinds.lua : nos combos identiques écrasent les leurs ; les anciens
-- binds keysym qui subsistent tombent sur des touches AZERTY inoffensives ou
-- injoignables (donc sans effet parasite).
--
-- Rappel : code:<n> = keycode Linux + 8.
--   code:20 = '-' QWERTY (KEY_MINUS 12)     -> ')' en AZERTY FR
--   code:21 = '=' QWERTY (KEY_EQUAL 13)     -> '=' en AZERTY FR (même position)
--   code:51 = '\' QWERTY (KEY_BACKSLASH 43) -> '*µ' en AZERTY FR
--   code:59 = ',' QWERTY (KEY_COMMA 51)     -> ';' en AZERTY FR
--
-- NB drag fenêtre (SUPER+Z / SUPER+X) : NON réécrits. "X" est déjà à la même
-- position physique en AZERTY, et la position QWERTY de "Z" est occupée par la
-- touche "W" (= SUPER + W, navigateur) en AZERTY -> un rebind par keycode
-- entrerait en collision. Ces binds fonctionnent déjà comme lettres, et le drag
-- souris (SUPER + LMB/RMB) marche quelle que soit la disposition.

-- Redimensionnement fenêtre : on ne réécrit QUE le côté '-' (rétrécir).
-- '=' (agrandir) est à la MÊME position physique en AZERTY (KEY_EQUAL) : le keysym
-- "SUPER + Equal" de Caelestia marche déjà -> ajouter code:21 DOUBLERAIT l'action.
-- '-' en revanche : le keysym "minus" tombe sur KEY_6 en AZERTY ; code:20 (KEY_MINUS)
-- remet le rétrécir juste à gauche de l'agrandir (paire adjacente, comme en QWERTY).
hl.bind("SUPER + code:20", fn.resize_active_window(-10, 0), { repeating = true })         -- largeur -
hl.bind("SUPER + SHIFT + code:20", fn.resize_active_window(0, -10), { repeating = true }) -- hauteur -

-- Média précédent (ex CTRL + SUPER + Minus). "suivant" (CTRL+SUPER+Equal) est déjà
-- bien placé (KEY_EQUAL) -> pas de code:21 (sinon double déclenchement).
hl.bind("CTRL + SUPER + code:20", hl.dsp.global("caelestia:mediaPrev"), { locked = true })

-- Centrer / redim. 55x70 + centrer (ex CTRL + SUPER + \ et CTRL + SUPER + ALT + \)
hl.bind("CTRL + SUPER + code:51", hl.dsp.window.center())
hl.bind("CTRL + SUPER + ALT + code:51", hl.dsp.window.resize(fn.resize_by_screen(55, 70)))
hl.bind("CTRL + SUPER + ALT + code:51", hl.dsp.window.center())

-- NB : group toggle/lock ("SUPER [+SHIFT] + Comma") NON réécrits : le keysym ','
-- est déjà joignable et sans conflit en AZERTY (cf. hypr-vars.lua). Un code:59
-- collisionnerait avec "SUPER + semicolon" (emoji).

-- ============================================================
-- Groupes de fenêtres (onglets) : fusion + navigation
-- ============================================================
-- Caelestia ne fournit AUCUN bind pour faire entrer une fenêtre DÉJÀ ouverte dans
-- un groupe (SUPER+SHIFT+flèches = movewindow, déplace juste la tuile). On ajoute
-- donc la fusion et la navigation d'onglets via l'API Lua NATIVE de Hyprland
-- (hl.dsp.*). NB : surtout PAS `hyprctl dispatch ...` ici — dans une config Lua,
-- hyprctl repasse par le pont Lua (hl.dispatch) et échoue avec la syntaxe conf.
--
-- IMPORTANT :
--  * "SUPER + SHIFT + flèches" (déplacer la tuile) et "SUPER + ALT + flèches"
--    (resize) sont CONSERVÉS tels quels (on ne les touche pas).
--  * On ÉVITE tout combo "SHIFT + ALT" (réservé à grp:alt_shift_toggle = bascule
--    de disposition clavier, cf. input.lua).
--  * Fusion = SUPER + couche HYPER (Caps Lock, via keyd) + flèches, routées en
--    F18-F21 -> zéro conflit (cf. bloc HYPER + keyd) :
--      F18 -> Linux 188 -> code:196   (SUPER + HYPER + gauche)
--      F19 -> Linux 189 -> code:197   (SUPER + HYPER + droite)
--      F20 -> Linux 190 -> code:198   (SUPER + HYPER + haut)
--      F21 -> Linux 191 -> code:199   (SUPER + HYPER + bas)

-- Fusionner la fenêtre active dans le groupe voisin (into_or_create_group : crée
-- le groupe si la fenêtre voisine n'en est pas encore un -> pas besoin de Super+,)
hl.bind("SUPER + code:196", hl.dsp.window.move({ into_or_create_group = "left" }))  -- SUPER + HYPER + gauche
hl.bind("SUPER + code:197", hl.dsp.window.move({ into_or_create_group = "right" })) -- SUPER + HYPER + droite
hl.bind("SUPER + code:198", hl.dsp.window.move({ into_or_create_group = "up" }))    -- SUPER + HYPER + haut
hl.bind("SUPER + code:199", hl.dsp.window.move({ into_or_create_group = "down" }))  -- SUPER + HYPER + bas

-- Naviguer entre les onglets du groupe :
--   SUPER + Tab         -> onglet suivant  (group.next = membre suivant)
--   SUPER + Shift + Tab -> onglet précédent (group.prev = membre précédent)
hl.bind("SUPER + Tab", hl.dsp.group.next(), { repeating = true })
hl.bind("SUPER + SHIFT + Tab", hl.dsp.group.prev(), { repeating = true })

return true
