# caelestia-perso (version Lua)

Mes modifs perso par-dessus [caelestia-dots](https://github.com/caelestia-dots/caelestia),
**sans toucher à leur repo**. Depuis la migration Hyprland 0.55 / CLI v1.1.0,
la config Hyprland est en **Lua** (plus en hyprlang `.conf`).

## Comment Caelestia charge mes fichiers

D'après `~/.config/hypr/hyprland.lua` :

- ligne ~45 : `local overrides = require("hypr-vars")` → **hypr-vars.lua** est une
  TABLE de données (`return { ... }`), fusionnée dans leurs variables.
- ligne ~76 : `require("hypr-user")` (tout à la fin) → **hypr-user.lua** est du
  VRAI code Lua Hyprland (`hl.config`, `hl.bind`…), chargé après tout le reste,
  donc mes réglages gagnent.

`package.path` inclut `~/.config/caelestia/?.lua`, donc depuis hypr-user.lua,
`require("user.input")` charge `~/.config/caelestia/user/input.lua` (le dossier
`user/` est symlinké là par install.sh).

## Arborescence

```
hypr-vars.lua          # TABLE de données (return {...}) — overrides de variables
hypr-user.lua          # AIGUILLEUR Lua — require() les fichiers user/ utilisés
user/                  # mes overrides Hyprland en Lua, par thème
├── input.lua          # clavier FR + touchpad (REMPLI, activé)
├── keybinds.lua       # (template, désactivé)
├── rules.lua          # (template, désactivé)
├── env.lua  
├── general.lua  
├── misc.lua  
├── animations.lua
├── decoration.lua  
├── group.lua  
├── execs.lua  
├── gestures.lua  
├── scrolling.lua
user-config.fish       # alias/env fish (inchangé)
shell.json             # config Quickshell (JSON, NON concerné par Lua)
monitors/<écran>/shell.json   # surcharges par écran (vides)
```

## Règle d'or : on ne référence que les fichiers remplis

En Lua, `require("user.xxx")` vers un fichier inexistant ou invalide lève une
erreur. Donc `hypr-user.lua` ne `require` QUE les thèmes réellement utilisés
(aujourd'hui : `input`). Les autres `.lua` existent (structure intacte) mais
leur ligne `require` est commentée. Pour activer un thème : remplis le fichier,
puis décommente sa ligne dans `hypr-user.lua`, puis `hyprctl reload`.

Les templates renvoient `return true` pour être chargeables sans erreur même
vides, si tu les actives avant de les remplir.

## Deux natures à ne pas confondre

- `hypr-vars.lua` = données : `return { browser = "firefox" }`.
- `hypr-user.lua` et `user/*.lua` = code : `hl.config{...}`, `hl.bind(...)`.

## Installation

```sh
git clone <ton-repo> ~/.local/share/caelestia-perso
~/.local/share/caelestia-perso/install.sh
hyprctl reload
```

Sauvegarde l'existant en `.bak-<date>` avant de symlinker ; ne refait rien si le
lien est déjà bon.

## Mémo syntaxe Lua Hyprland

```lua
-- variable / valeur
hl.config({ general = { gaps_in = 4 } })

-- keybind simple
hl.bind("SUPER + G", hl.dsp.exec_cmd("gimp"))

-- réutiliser les variables Caelestia
local vars = require("variables")
hl.bind("SUPER + Return", hl.dsp.exec_cmd(vars.terminal))

-- règle fenêtre
hl.windowrule({ "float" }, "class:^(pavucontrol)$")
```
