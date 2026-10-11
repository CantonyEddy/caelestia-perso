-- hyprland-greeter.lua — config Hyprland du greeter SDDM, version LUA.
--
-- ⚠️  PAS ENCORE DÉPLOYÉ. install.sh ne copie toujours QUE le .conf, et
-- 20-wayland.conf pointe toujours sur le .conf. Ce fichier est la migration
-- PRÉPARÉE pour Hyprland 0.57, qui supprime le format .conf (commit upstream
-- a9902ea6 « config: remove legacy config support ») : à partir de la 0.57, tout
-- --config est lu comme du Lua -> le .conf actuel ne chargera plus.
--
-- Bascule UNIQUEMENT après la procédure de test d'ARCHITECTURE.md § Config SDDM
-- (verify-config en tant qu'utilisateur sddm + test imbriqué), snapshot pris.
--
-- Traduction 1:1 de hyprland-greeter.conf. Volontairement autonome : aucun
-- require(), aucune dépendance au HOME (le greeter tourne sous l'utilisateur sddm).

hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })

hl.config({
    misc = {
        force_default_wallpaper  = 0,
        disable_hyprland_logo    = true,
        disable_splash_rendering = true,
        background_color         = "rgb(000000)",
    },

    input = {
        kb_layout          = "fr",
        numlock_by_default = true,
    },

    animations = {
        enabled = false,
    },

    decoration = {
        blur = {
            enabled = false,
        },
    },
})
