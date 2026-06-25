-- user/input.lua — clavier FR, touchpad, curseur (converti depuis l'ancien .conf)
-- Doc : https://wiki.hypr.land/Configuring/Variables/ (section input)

hl.config({
    input = {
        kb_layout = "fr,us",
        kb_options = "grp:alt_shift_toggle",
        numlock_by_default = true,
        repeat_delay = 250,
        repeat_rate = 35,

        focus_on_close = 1,

        touchpad = {
            natural_scroll = true,
            -- Anciennes variables Caelestia $touchpadDisableTyping / $touchpadScrollFactor :
            -- en Lua elles vivent dans la table `vars` de Caelestia. Pour réutiliser
            -- leurs valeurs : local vars = require("variables") puis vars.touchpadScrollFactor
            disable_while_typing = true,
            scroll_factor = 0.3,
        },
    },

    binds = {
        scroll_event_delay = 0,
    },

    cursor = {
        hotspot_padding = 1,
    },
})
