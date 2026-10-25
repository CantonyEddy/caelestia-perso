-- user/keybinds.lua — mes raccourcis perso (migré depuis l'ancien keybinds.conf)
--
-- Notes :
--  * app2unit a été supprimé par Caelestia -> on lance via "uwsm app -- <cmd>".
--  * ⚠️ Hyprland déclenche TOUS les binds qui correspondent à une combinaison
--    (pas de « dernier gagne »). Ne JAMAIS rebinder ici une combinaison déjà prise
--    par Caelestia : redéfinir sa variable kb* dans hypr-vars.lua à la place.
--    Ce fichier ne contient donc que des combinaisons LIBRES chez Caelestia.
--  * SUPER+D / SUPER+M = toggles natifs Caelestia (communication / music) ; les
--    apps (vesktop, spotify) sont déclarées dans config/caelestia/cli.json.

-- Apps à special workspace (SUPER+G/O, HYPER+C/T/S/A) : voir user/special.lua.

-- Anti-veille : bascule un verrou Wayland idle-inhibit (respecté par Hyprland,
-- donc stoppe la mise en veille / le verrou d'écran auto). Pour les vidéos.
-- Dépend de wlinhibit (AUR) : paru -S wlinhibit
hl.bind("SUPER + I", hl.dsp.exec_cmd("bash $HOME/.local/share/caelestia-perso/scripts/idle-toggle.sh"))

-- Lanceur fuzzel (config perso : config/fuzzel/fuzzel.ini). Bind par LETTRE (keysym)
-- comme SUPER+I : suit la touche « A » quelle que soit la disposition. Combo libre
-- chez Caelestia (vérifié upstream). "pkill fuzzel ||" = re-appuyer ferme le menu
-- (même pattern que les binds clipboard/emoji de Caelestia).
hl.bind("SUPER + A", hl.dsp.exec_cmd("pkill fuzzel || uwsm app -- fuzzel"))

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
hl.bind("code:192", hl.dsp.exec_cmd("uwsm app -- zennotes"))       -- HYPER + N : zennotes

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
-- des groupes de bureaux. On ne change QUE la touche.
-- Les binds keysym de Caelestia ("SUPER + 1"…) restent actifs (non pilotables par
-- variable) : injoignables en AZERTY (1 = Shift+&), et en disposition US les deux
-- se déclenchent avec la MÊME action -> sans effet visible.

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
-- les keysyms -, \, "." tombent ailleurs, voire sont injoignables
-- (backslash = AltGr+8 ; "Minus" = touche 6 -> collision avec le bureau 6).
-- On les rebind par KEYCODE physique pour retrouver la POSITION du QWERTY
-- documenté. Depuis Caelestia f6d5250 (juil. 2026) ces binds sont tous pilotés
-- par variables kb* -> on les redéfinit dans hypr-vars.lua (aucun résidu).
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

-- Resize « − », média précédent, centrer, 55x70, PiP et emoji : désormais
-- redéfinis par VARIABLES dans hypr-vars.lua (kbWindowDecreaseWidth/Height,
-- kbMediaPrev, kbCenterWindow, kbNormalizeWindow, kbWindowPip, kbEmoji).
-- Plus aucun hl.bind ici -> plus de double déclenchement avec la touche 6.

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
