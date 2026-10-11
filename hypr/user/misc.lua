-- user/misc.lua — section misc

-- Referme automatiquement un special workspace quand sa dernière fenêtre se
-- ferme (au lieu de rester dans le scratchpad vide). Option native Hyprland.
-- NB : c'est déjà la valeur par défaut de Hyprland 0.56 ; gardé explicite car
-- scripts/app-ws.sh en dépend (cf. son anti-race).
hl.config({ misc = { close_special_on_empty = true } })

return true
