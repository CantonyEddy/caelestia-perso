-- user/rules.lua — règles fenêtres perso
-- Doc : https://wiki.hypr.land/Configuring/Window-Rules/
--
-- Les règles des apps à special workspace (tag + routage) sont générées par
-- user/special.lua à partir d'une table unique.

-- Cheat-sheet des raccourcis (HYPER+K) : fenêtre foot 'caelestia-keybinds',
-- flottante et centrée. La TAILLE (55x70 %) est fixée par le script via
-- foot --window-size-pixels (les tailles en % de la window rule ne sont pas
-- appliquées de façon fiable ici). Voir keybinds.lua + scripts/keybinds-menu.sh.
hl.window_rule({ match = { class = "caelestia-keybinds" }, float = true, center = true })

return true
