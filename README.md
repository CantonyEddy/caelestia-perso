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

## Configs `~/.config` versionnées (dossier `config/`)

En plus d'Hyprland, on versionne les configs CLI/rice éditées à la main. Elles
vivent dans `config/` et sont symlinkées dans `~/.config/<app>/` par `install.sh`
(même logique : sauvegarde `.bak-<date>` de l'existant, puis symlink, idempotent).

```
config/
├── fish/config.fish + functions/fish_greeting.fish
├── foot/foot.ini
├── fuzzel/fuzzel.ini
├── btop/btop.conf
├── cava/config
├── fastfetch/config.jsonc
├── htop/htoprc
├── micro/settings.json
├── zed/settings.json + keymap.json
├── spicetify/config-xpui.ini
├── starship.toml        # à seeder (voir plus bas)
└── mimeapps.list        # à seeder (voir plus bas)
```

**Règle : on ne versionne QUE mes fichiers, pas le généré par Caelestia.** Les
thèmes de couleurs (`btop/themes/`, `zed/themes/`, `spicetify/Themes/`) sont
régénérés par Caelestia à chaque changement de scheme — ils sont exclus via
`.gitignore` et restent gérés par Caelestia. Pour `fuzzel`, `cava` et `htop`,
Caelestia injecte ses couleurs *dans* le fichier : un changement de scheme peut
donc y créer des diffs git (à ignorer ou committer selon l'envie).

## Config SDDM (`config/sddm/conf.d/`)

La config **fonctionnelle** de SDDM est versionnée en drop-ins (SDDM lit tous les
`*.conf` de `/etc/sddm.conf.d/` par ordre alpha, fusionnés par section ; le
préfixe numérique gère la priorité) :

```
config/sddm/conf.d/
├── 10-general.conf     [General]   DisplayServer=wayland, Numlock=on
├── 20-wayland.conf     [Wayland]   CompositorCommand=...
├── 30-autologin.conf   [Autologin] (placeholder commenté)
└── 40-users.conf       [Users]     (placeholder commenté)
```

Contrairement au reste, ces fichiers sont **copiés** (pas symlinkés) vers `/etc`
via `sudo` par `install.sh` — `/etc` reste indépendant de ton home. `install.sh`
te demandera ton mot de passe sudo. Après toute modif d'un drop-in, **relance
`install.sh`** pour resynchroniser `/etc`.

**L'esthétique reste hors repo** : `theme.conf` (`Current=nier-automata`) n'est
jamais versionné ni écrasé par `install.sh`.

### Seeder les fichiers racine (`starship.toml`, `mimeapps.list`)

Ils sont à la racine de `~/.config` (pas dans un sous-dossier), donc à copier une
fois dans le repo avant de pouvoir les symlinker :

```sh
cp ~/.config/starship.toml ~/.local/share/caelestia-perso/config/starship.toml
cp ~/.config/mimeapps.list  ~/.local/share/caelestia-perso/config/mimeapps.list
~/.local/share/caelestia-perso/install.sh   # les détecte et les symlinke
```

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
