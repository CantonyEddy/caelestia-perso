-- user/keybinds.lua — tes raccourcis perso
-- Syntaxe : hl.bind("SUPER + KEY", dispatcher [, flags])
-- Tu peux utiliser les variables Caelestia via : local vars = require("variables")

-- Exemples :
-- hl.bind("SUPER + G", hl.dsp.exec_cmd("gimp"))
-- hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd("grimblast copy area"))

-- Bind avec fonction (plusieurs actions) :
-- hl.bind("SUPER + Tab", function()
--     hl.dispatch(hl.dsp.window.cycle_next())
--     hl.dispatch(hl.dsp.window.bring_to_top())
-- end)

return true
