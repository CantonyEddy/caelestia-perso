-- ~/.config/caelestia/hypr-vars.lua
-- Table de données (PAS du code Hyprland). Caelestia fait require("hypr-vars"),
-- vérifie que c'est une table, et fusionne tes clés dans ses variables
-- (vars[k] = v : une clé REMPLACE entièrement la valeur Caelestia, tableaux compris).
-- Doit être un `return { ... }`. Clés dispo = celles de hypr/variables.lua de Caelestia.
--
-- ⚠️ RÈGLE (vérifiée dans le source Hyprland 0.56, KeybindManager::handleKeybinds) :
-- deux hl.bind sur la même combinaison se déclenchent TOUS LES DEUX — il n'y a
-- PAS de « dernier gagne ». Pour changer un raccourci Caelestia, on redéfinit sa
-- variable kb* ICI (le bind d'origine n'est alors jamais créé) plutôt que
-- d'ajouter un hl.bind dans user/keybinds.lua.

return {
    browser                = "uwsm app -- zen-browser",
    editor                 = "uwsm app -- zeditor",
    -- touchpadDisableTyping = true,
    -- touchpadScrollFactor  = 0.3,

    -- Curseur Bibata (override de sweet-cursors)
    cursorTheme            = "Bibata-Modern-Classic",
    cursorSize             = 24,

    kbSystemMonitorWs      = "SUPER + B",

    -- ---- Parité QWERTY -> AZERTY (rebind par KEYCODE physique) ----
    -- code:<n> = keycode Linux + 8. Garde la POSITION du QWERTY documenté.
    --   code:20 = '-' QWERTY (KEY_MINUS)     -> ')' en AZERTY FR
    --   code:51 = '\' QWERTY (KEY_BACKSLASH) -> '*µ' en AZERTY FR
    --
    -- '-' : le keysym "Minus" de Caelestia tombe sur la touche 6 en AZERTY
    -- -> SUPER+6 faisait « bureau 6 » ET « rétrécir », Ctrl+SUPER+6 « groupe 6 »
    -- ET « morceau précédent ». Redéfinir la variable supprime ce double effet.
    -- '=' (agrandir / suivant) est à la même position en AZERTY : inchangé.
    kbWindowDecreaseWidth  = { "SUPER + code:20", "SUPER + ALT + Left" },
    kbWindowDecreaseHeight = { "SUPER + SHIFT + code:20", "SUPER + ALT + Up" },
    kbMediaPrev            = "CTRL + SUPER + code:20",

    -- '\' = AltGr+8 en AZERTY, injoignable avec SUPER -> keycode.
    kbCenterWindow         = "CTRL + SUPER + code:51",
    kbNormalizeWindow      = "CTRL + SUPER + ALT + code:51", -- 55x70 % + centrer (calculé à l'appui)
    kbWindowPip            = "SUPER + ALT + code:51",

    -- '.' = Shift+; en AZERTY (SUPER+Period injoignable) -> emoji sur SUPER+;
    kbEmoji                = "SUPER + semicolon",

    -- NB : kbToggleGroup ("SUPER + Comma") N'est PAS réécrit. Le keysym ',' est déjà
    -- joignable en AZERTY (touche libellée ',') et sans conflit. Le passer en
    -- code:59 (KEY_COMMA physique) collisionnerait avec kbEmoji (SUPER + ;).
    --
    -- NB : SUPER+D / SUPER+M restent les toggles Caelestia (kbCommunicationWs /
    -- kbMusicWs). Les apps lancées (vesktop, spotify) sont configurées dans
    -- config/caelestia/cli.json (section "toggles"), pas ici.
}
