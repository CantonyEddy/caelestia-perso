-- user/lid.lua — mode "clamshell" : capot fermé = écran interne éteint
--
-- Fermeture du capot -> on désactive l'écran interne (eDP-1), tout bascule
-- sur l'écran externe. Réouverture -> on le réactive.
-- La partie systemd-logind (HandleLidSwitchDocked/ExternalPower=ignore) est
-- gérée hors de ce repo : ici on ne touche qu'à Hyprland.
--
-- Notes :
--  * Config en Lua -> pas de `bindl = , switch:...` (hyprlang). Équivalent Lua :
--    hl.bind("switch:on:Lid Switch", fn, { locked = true }) ; locked = actif
--    même écran verrouillé.
--  * On appelle hl.monitor() directement plutôt que `hyprctl keyword monitor`
--    (pas de `keyword` fiable en config Lua).
--  * Pas de règle eDP-1 dédiée dans le repo ni chez Caelestia (seulement leur
--    règle par défaut output="" preferred/auto/1) -> on réactive avec ces valeurs.
--  * Fichier SÉPARÉ des règles monitor : les binds switch placés dans le même
--    fichier qu'une config monitor ne se déclenchent pas (hyprwm/Hyprland#14858).
--  * Limite : un `hyprctl reload` capot fermé réévalue la config et rallume
--    eDP-1 (la désactivation n'est pas persistée) -> rouvrir/refermer le capot.

local internal = "eDP-1"

-- Capot fermé : écran interne désactivé
hl.bind("switch:on:Lid Switch", function()
    hl.monitor({ output = internal, disabled = true })
end, { locked = true })

-- Capot ouvert : écran interne réactivé (mêmes valeurs que la règle par défaut)
hl.bind("switch:off:Lid Switch", function()
    hl.monitor({ output = internal, mode = "preferred", position = "auto", scale = 1 })
end, { locked = true })

return true
