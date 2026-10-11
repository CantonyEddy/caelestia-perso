-- user/lid.lua — mode "clamshell" : capot fermé = écran interne éteint
--
-- Fermeture du capot -> on désactive l'écran interne (eDP-*), tout bascule
-- sur l'écran externe. Réouverture -> on le réactive.
-- La partie systemd-logind (HandleLidSwitchDocked/ExternalPower=ignore) est
-- gérée hors de ce repo : ici on ne touche qu'à Hyprland.
--
-- Garde-fous (config partagée, utilisée sur plusieurs machines) :
--  * l'écran interne est DÉTECTÉ (premier moniteur dont le nom commence par
--    "eDP") au lieu d'être codé en dur : eDP-1 / eDP-2 selon la machine ;
--  * on ne l'éteint QUE s'il reste au moins un autre écran actif. Capot fermé
--    sans écran externe (logind en "ignore") -> on ne fait rien, sinon Hyprland
--    se retrouverait sans aucun écran.
--  * PC fixe (pas de capot) : les binds ne se déclenchent jamais.
--
-- Notes :
--  * Config en Lua -> pas de `bindl = , switch:...` (hyprlang). Équivalent Lua :
--    hl.bind("switch:on:Lid Switch", fn, { locked = true }) ; locked = actif
--    même écran verrouillé.
--  * Fichier SÉPARÉ des règles monitor : les binds switch placés dans le même
--    fichier qu'une config monitor ne se déclenchent pas (hyprwm/Hyprland#14858).
--  * Limite : un `hyprctl reload` capot fermé réévalue la config et rallume
--    l'écran interne (la désactivation n'est pas persistée) -> rouvrir/refermer.

local disabled_internal = nil -- nom de l'écran éteint par nous (pour le rallumer)

local function is_internal(name)
    return type(name) == "string" and name:sub(1, 3) == "eDP"
end

-- Capot fermé : écran interne désactivé, seulement si un autre écran existe
hl.bind("switch:on:Lid Switch", function()
    local internal, others = nil, 0
    for _, mon in ipairs(hl.get_monitors() or {}) do
        if is_internal(mon.name) then
            internal = internal or mon.name
        else
            others = others + 1
        end
    end
    if internal and others > 0 then
        disabled_internal = internal
        hl.monitor({ output = internal, disabled = true })
    end
end, { locked = true })

-- Capot ouvert : réactive l'écran qu'on a éteint (valeurs de la règle par défaut)
hl.bind("switch:off:Lid Switch", function()
    if disabled_internal then
        hl.monitor({ output = disabled_internal, mode = "preferred", position = "auto", scale = 1 })
        disabled_internal = nil
    end
end, { locked = true })

return true
