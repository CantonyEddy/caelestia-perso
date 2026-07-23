# Architecture & choix techniques — caelestia-perso

Doc technique du dépôt. Pour l'usage courant (installer, mettre à jour), voir
[README.md](README.md).

## Principe fondateur

Superposer mes overrides **par-dessus** [caelestia-dots](https://github.com/caelestia-dots/caelestia)
**sans jamais toucher à leur repo**. `install.sh` symlinke mes fichiers dans
`~/.config/caelestia/` (Hyprland Lua) et `~/.config/<app>/` (configs pur perso).
Corollaire : **on ne versionne que MES modifs**, jamais un défaut Caelestia.

## Comment Caelestia charge mes fichiers Hyprland

Depuis la migration Hyprland 0.55 / Caelestia CLI v1.1.0, la config Hyprland est
en **Lua** (plus en hyprlang `.conf`). D'après `~/.config/hypr/hyprland.lua` :

- ligne ~45 : `local overrides = require("hypr-vars")` → **hypr-vars.lua** est une
  TABLE de données (`return { ... }`), fusionnée dans leurs variables.
- ligne ~76 : `require("hypr-user")` (tout à la fin) → **hypr-user.lua** est du
  VRAI code Lua Hyprland (`hl.config`, `hl.bind`…), chargé après tout le reste,
  donc mes réglages gagnent.

`package.path` inclut `~/.config/caelestia/?.lua`, donc depuis hypr-user.lua,
`require("user.input")` charge `~/.config/caelestia/user/input.lua` (le dossier
`user/` est symlinké là par install.sh).

### Deux natures à ne pas confondre

- `hypr-vars.lua` = **données** : `return { browser = "firefox" }`.
- `hypr-user.lua` et `user/*.lua` = **code** : `hl.config{...}`, `hl.bind(...)`.

### Règle d'or : on ne référence que les fichiers remplis

En Lua, `require("user.xxx")` vers un fichier inexistant ou invalide lève une
erreur. Donc `hypr-user.lua` ne `require` QUE les thèmes réellement utilisés
(aujourd'hui : `input`, `keybinds`). Les autres `.lua` existent (structure
intacte) mais leur ligne `require` est commentée. Pour activer un thème : remplis
le fichier, décommente sa ligne dans `hypr-user.lua`, puis `hyprctl reload`.
Les templates renvoient `return true` pour être chargeables sans erreur même vides.

## Arborescence Hyprland

```
hypr/
├── hypr-vars.lua      # TABLE de données (return {...}) — overrides de variables
├── hypr-user.lua      # AIGUILLEUR Lua — require() les fichiers user/ utilisés
└── user/              # mes overrides Hyprland en Lua, par thème
    ├── input.lua      # clavier FR + touchpad (REMPLI, activé)
    ├── keybinds.lua   # mes raccourcis (REMPLI, activé)
    ├── rules.lua      # (template, désactivé)
    └── …              # env, general, misc, animations, decoration, group,
                       #   execs, gestures, scrolling (templates désactivés)
fish/user-config.fish  # alias/env fish, sourcé par Caelestia (hook officiel)
shell/shell.json       # config Quickshell (JSON, hors Lua)
shell/monitors/<écran>/shell.json  # surcharges par écran
```

## Configs `~/.config` versionnées (dossier `config/`)

On versionne **uniquement les apps que Caelestia NE gère PAS** (pur perso),
symlinkées dans `~/.config/<app>/` par `install.sh` (backup `.bak-<date>` de
l'existant, puis symlink, idempotent) :

```
config/
├── fuzzel/fuzzel.ini
├── cava/config
├── htop/htoprc
├── zed/settings.json + keymap.json
└── spicetify/config-xpui.ini
```

### Pourquoi ce périmètre restreint (analyse Caelestia)

Caelestia maintient un clone de ses dotfiles dans
`~/.local/state/caelestia/dots/` (source de son CLI) et **déploie ses fichiers
par copie** (voir `manifest.toml`). Comparaison faite :

| App                        | Statut                          | Décision            |
|----------------------------|---------------------------------|---------------------|
| foot, fish, fastfetch, micro | identiques au défaut Caelestia | **non versionnés**  |
| btop                       | perso mais géré par Caelestia   | **non versionné**   |
| fuzzel, cava, htop, zed    | absents du clone → 100% perso   | **versionnés**      |
| spicetify/config-xpui.ini  | absent du clone → perso         | **versionné**       |

Versionner un fichier géré par Caelestia créerait un conflit : au prochain
`caelestia update`, Caelestia recopie son fichier vers `~/.config/<app>/` et
écraserait notre symlink (voire écrirait sa version *dans* notre repo en suivant
le lien). On laisse donc Caelestia gérer ces apps entièrement.

### Les couleurs : c'est Caelestia qui gère

Caelestia génère un **scheme de couleurs dynamique** (adapté au wallpaper,
stocké dans `~/.local/state/caelestia/scheme.json`) et l'applique **sans écrire
dans les fichiers de config des apps** :

- **terminaux** (foot, fish) : via séquences ANSI dans
  `~/.local/state/caelestia/sequences.txt` (sourcé au démarrage du shell) ;
- **btop / zed / spicetify** : via des fichiers de thème séparés
  (`btop/themes/…`, `zed/themes/…`, `spicetify/Themes/…`) régénérés par Caelestia.

Ces fichiers de thème générés sont **exclus du repo** (`.gitignore`). Les couleurs
Caelestia visibles dans `fuzzel.ini` / `cava/config` ont été posées **à la main**
une fois (Caelestia n'a pas de template pour ces apps) : elles ne bougent donc
pas toutes seules et peuvent être versionnées sans risque.

### Fichiers isolés à la racine de `~/.config`

`mimeapps.list` (associations d'apps par défaut) est pur perso et versionnable ;
`starship.toml` en revanche est géré par Caelestia (présent dans son clone) — ne
le versionner que s'il a été réellement personnalisé. Comme ils sont à la racine
de `~/.config` (pas dans un sous-dossier), il faut les copier une fois dans le
repo avant de les symlinker :

```sh
cp ~/.config/mimeapps.list ~/.local/share/caelestia-perso/config/mimeapps.list
~/.local/share/caelestia-perso/install.sh   # détecte et symlinke
```

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
via `sudo` (fonction `copy_root` d'`install.sh`) : `/etc` reste indépendant du
home (pas de fichier lu par root pointant vers un home utilisateur). Contrepartie :
après toute modif d'un drop-in, **relancer `install.sh`** pour resynchroniser `/etc`.

**L'esthétique reste hors repo** : `theme.conf` (`Current=nier-automata`) n'est
jamais versionné ni écrasé par `install.sh`.

## Fonctionnement d'`install.sh`

Idempotent. Pour chaque cible : symlink déjà correct → rien ; fichier/dossier réel
→ sauvegarde `.bak-<date>` puis symlink ; absent → symlink direct. Deux fonctions :

- `link()` : symlink dans le home (Hyprland, configs `~/.config`).
- `copy_root()` : copie via `sudo` vers `/etc` (SDDM), avec backup et idempotence
  (`cmp` avant recopie).

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
