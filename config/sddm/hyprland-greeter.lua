-- hyprland-greeter.lua — config Hyprland du greeter SDDM, version LUA.
--
-- Config ACTIVE du greeter : 20-wayland.conf pointe ici. Hyprland 0.57 supprime
-- le format .conf (upstream a9902ea6) -> le Lua est obligatoire à partir de là.
-- install.sh valide ce fichier (Hyprland --verify-config) avant de basculer, et
-- retombe sur hyprland-greeter.conf (toujours déployé) en cas d'échec.
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
