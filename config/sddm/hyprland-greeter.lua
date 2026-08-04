-- hyprland-greeter.lua — config Hyprland du greeter SDDM, en Lua.
-- Remplace hyprland-greeter.conf (hyprlang), dont le support est retiré dans
-- Hyprland 0.57 (d'où le warning « You are using the .conf config format… »).
-- `hl` est fourni nativement par Hyprland, aucun require nécessaire ici.
-- Déployée dans /etc/sddm/ ; référencée par le CompositorCommand de 20-wayland.conf.

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
