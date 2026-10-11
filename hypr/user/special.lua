-- user/special.lua — apps dédiées à un special workspace (« lance-ou-toggle »)
--
-- UNE SEULE TABLE = source de vérité. Chaque entrée génère :
--   (1) la window rule de TAG   (classe -> tag ws_<ws>)
--   (2) la window rule de ROUTAGE (tag -> special:<ws>), après tous les taguages
--   (3) le raccourci -> scripts/app-ws.sh <classe> <ws> <commande>
-- Avant : la classe était recopiée à 3 endroits (keybinds.lua, rules.lua ×2) ;
-- un écart = l'app décroche de son workspace (cf. Obsidian, renommé 2 fois).
--
-- Ajouter une app = ajouter une ligne ici (+ la touche keyd si HYPER).
-- Trouver la classe : hyprctl clients -j | jq -r '.[].class'
--
-- Champs :
--   key   : combinaison Hyprland (HYPER+x = F-key émise par keyd, liée par keycode)
--   ws    : nom du special workspace (special:<ws>)
--   class : classe EXACTE (comparée sans tenir compte de la casse, partout)
--   cmd   : commande de lancement (convention : uwsm app -- …)
--
-- Keycodes HYPER (code = keycode Linux + 8, cf. config/keyd/default.conf) :
--   c->F13 = code:191 · t->F15 = code:193 · s->F16 = code:194 · q(A azerty)->F17 = code:195

local APPS = {
    { key = "SUPER + G", ws = "steam",       class = "steam",                   cmd = "uwsm app -- steam" },
    { key = "SUPER + O", ws = "obsidian",    class = "md.obsidian.Obsidian",    cmd = "uwsm app -- obsidian" },
    { key = "code:191",  ws = "claude",      class = "com.anthropic.Claude",    cmd = "uwsm app -- claude-desktop" }, -- HYPER + C
    { key = "code:193",  ws = "thunderbird", class = "org.mozilla.Thunderbird", cmd = "uwsm app -- thunderbird" },    -- HYPER + T
    { key = "code:194",  ws = "signal",      class = "signal",                  cmd = "uwsm app -- signal-desktop" }, -- HYPER + S
    { key = "code:195",  ws = "keepassxc",   class = "org.keepassxc.KeePassXC", cmd = "uwsm app -- keepassxc" },      -- HYPER + A
}

local APPWS = "bash $HOME/.local/share/caelestia-perso/scripts/app-ws.sh"

-- Classe -> regex RE2 exacte et insensible à la casse. Hyprland compare les
-- règles en FullMatch : "steam" ne capture donc PAS les jeux "steam_app_123".
local function class_regex(class)
    return "(?i)" .. class:gsub("[%^%$%(%)%%%.%[%]%*%+%-%?%{%}|\\]", "\\%0")
end

-- (1) taguage — DOIT précéder toutes les règles qui utilisent ces tags
for _, app in ipairs(APPS) do
    hl.window_rule({ match = { class = class_regex(app.class) }, tag = "+ws_" .. app.ws })
end

-- (2) routage des fenêtres taguées vers leur special workspace
for _, app in ipairs(APPS) do
    hl.window_rule({ match = { tag = "ws_" .. app.ws }, workspace = "special:" .. app.ws })
end

-- (3) raccourcis : lance si absente, sinon montre/cache (logique + anti-race
--     dans scripts/app-ws.sh, appelle `caelestia toggle`, jamais hyprctl dispatch)
for _, app in ipairs(APPS) do
    hl.bind(app.key, hl.dsp.exec_cmd(table.concat({ APPWS, app.class, app.ws, app.cmd }, " ")))
end

return true
