-- user/rules.lua — règles fenêtres perso
-- Doc : https://wiki.hypr.land/Configuring/Window-Rules/
--
-- Depuis la réécriture des window rules (Hyprland 0.53+, déc. 2025), assigner
-- directement `workspace = "special:x"` par classe ne fonctionne plus de façon
-- fiable. On passe donc par un système de TAGS en deux temps, comme Caelestia :
--   (1) on tague chaque fenêtre par sa classe ;
--   (2) APRÈS tous les taguages, on envoie les fenêtres taguées vers leur
--       special workspace. L'ordre (défs de tags après les taguages) est imposé
--       par Hyprland.
-- Le champ `class` est traité comme une regex (d'où l'échappement des points).

-- (1) Taguer chaque app par sa classe ("+" ajoute le tag)
hl.window_rule({ match = { class = "steam" },                      tag = "+ws_steam" })
hl.window_rule({ match = { class = "md\\.obsidian\\.Obsidian" },   tag = "+ws_obsidian" })
hl.window_rule({ match = { class = "com\\.anthropic\\.Claude" },    tag = "+ws_claude" })
hl.window_rule({ match = { class = "org\\.mozilla\\.Thunderbird" }, tag = "+ws_thunderbird" })
hl.window_rule({ match = { class = "signal" },                     tag = "+ws_signal" })
hl.window_rule({ match = { class = "org\\.keepassxc\\.KeePassXC" }, tag = "+ws_keepassxc" })

-- (2) Envoyer les fenêtres taguées vers leur special workspace
--     (DOIT venir après tous les taguages ci-dessus)
hl.window_rule({ match = { tag = "ws_steam" },       workspace = "special:steam" })
hl.window_rule({ match = { tag = "ws_obsidian" },    workspace = "special:obsidian" })
hl.window_rule({ match = { tag = "ws_claude" },      workspace = "special:claude" })
hl.window_rule({ match = { tag = "ws_thunderbird" }, workspace = "special:thunderbird" })
hl.window_rule({ match = { tag = "ws_signal" },      workspace = "special:signal" })
hl.window_rule({ match = { tag = "ws_keepassxc" },   workspace = "special:keepassxc" })

-- Cheat-sheet des raccourcis (HYPER+K) : fenêtre foot 'caelestia-keybinds',
-- flottante et centrée. La TAILLE (55x70 %) est fixée par le script via
-- foot --window-size-pixels (les tailles en % de la window rule ne sont pas
-- appliquées de façon fiable ici). Voir keybinds.lua + scripts/keybinds-menu.sh.
hl.window_rule({ match = { class = "caelestia-keybinds" }, float = true, center = true })

return true
