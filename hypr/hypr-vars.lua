-- ~/.config/caelestia/hypr-vars.lua
-- Table de données (PAS du code Hyprland). Caelestia fait require("hypr-vars"),
-- vérifie que c'est une table, et fusionne tes clés dans ses variables.
-- Équivalent du vieux hypr-vars.conf. Doit être un `return { ... }`.
--
-- Les clés disponibles = celles de leur hyprland/variables.lua
-- (ex. apps par défaut, gaps, comportements touchpad...).

return {
    browser           = "uwsm app -- zen-browser",
    -- terminal = "kitty",
    editor            = "uwsm app -- zeditor",
    kbSystemMonitorWs = "SUPER + B",
    -- touchpadDisableTyping = true,
    -- touchpadScrollFactor = 0.3,
    -- Curseur Bibata (override de sweet-cursors)
    cursorTheme       = "Bibata-Modern-Classic",
    cursorSize        = 24,

    -- ---- Parité QWERTY -> AZERTY (bind à VARIABLE) ----
    -- Caelestia écrit ce raccourci pour QWERTY avec '\' (backslash), INJOIGNABLE en
    -- AZERTY (= AltGr+8). Comme Caelestia binde via hl.bind(vars.kbWindowPip), le
    -- redéfinir ici REMPLACE proprement le bind (aucun résidu keysym). On rebind par
    -- KEYCODE physique (= keycode Linux + 8) :
    --   code:51 = touche '\' QWERTY (KEY_BACKSLASH 43) -> touche '*µ' en AZERTY FR
    kbWindowPip       = "SUPER + ALT + code:51", -- ex "SUPER + ALT + backslash"
    -- NB : kbToggleGroup ("SUPER + Comma") N'est PAS réécrit. Le keysym ',' est déjà
    -- joignable en AZERTY (touche libellée ',') et sans conflit. Le passer en
    -- code:59 (KEY_COMMA physique) collisionnerait avec "SUPER + semicolon" (emoji).
}
