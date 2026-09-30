-- user/execs.lua — lancement au démarrage (équivalent Lua de exec-once)
-- Même mécanisme que Caelestia (hyprland/execs.lua) : le callback
-- "hyprland.start" ne s'exécute qu'UNE fois, au lancement du compositeur —
-- pas à chaque `hyprctl reload` (un hl.exec_cmd au niveau du fichier, lui,
-- serait relancé à chaque rechargement de la config).
-- Lancer les apps via `uwsm app --` (convention du repo, cf. keybinds.lua).

hl.on("hyprland.start", function()
    -- Solaar : réglages Logitech MX Master 3 appliqués côté logiciel (pas de
    -- mémoire onboard) + règles bouton pouce → Super. Doit tourner en continu.
    -- Config : config/solaar/ (symlinkée dans ~/.config/solaar/).
    hl.exec_cmd("uwsm app -- solaar --window=hide")
end)

return true
