-- user/rules.lua — règles fenêtres perso
-- Doc : https://wiki.hypr.land/Configuring/Window-Rules/
-- API alignée sur celle de Caelestia : hl.window_rule({ match = {...}, ... }).
-- Le champ `class` est traité comme une regex (d'où l'échappement des points).

-- Special workspaces perso : chaque app est épinglée à son scratchpad.
-- Le toggle "lance-ou-montre/cache" est géré par scripts/app-ws.sh (voir keybinds.lua).
hl.window_rule({ match = { class = "steam" },                   workspace = "special:steam" })
hl.window_rule({ match = { class = "obsidian" },                workspace = "special:obsidian" })
hl.window_rule({ match = { class = "com\\.anthropic\\.Claude" }, workspace = "special:claude" })
hl.window_rule({ match = { class = "org\\.mozilla\\.Thunderbird" }, workspace = "special:thunderbird" })
hl.window_rule({ match = { class = "signal" }, workspace = "special:signal" })

return true
