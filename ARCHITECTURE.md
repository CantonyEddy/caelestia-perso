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
config/sddm/
├── conf.d/                    (INI démon SDDM -> /etc/sddm.conf.d/)
│   ├── 10-general.conf     [General]   DisplayServer=wayland, Numlock=on
│   ├── 20-wayland.conf     [Wayland]   CompositorCommand=...
│   ├── 30-autologin.conf   [Autologin] (placeholder commenté)
│   └── 40-users.conf       [Users]     (placeholder commenté)
└── hyprland-greeter.conf      (hyprlang -> /etc/sddm/)
```

`hyprland-greeter.conf` est la config **Hyprland** (format hyprlang, pas INI) du
compositeur lancé derrière l'écran de login — référencée par le
`CompositorCommand` de `20-wayland.conf`. Elle règle notamment `kb_layout = fr`
(clavier AZERTY au login). Elle est déployée vers `/etc/sddm/` (destination
distincte de `/etc/sddm.conf.d/`, car format et consommateur différents : SDDM
lit tout `sddm.conf.d/*.conf` comme du INI et planterait sur du hyprlang).

Contrairement au reste, ces fichiers sont **copiés** (pas symlinkés) vers `/etc`
via `sudo` (fonction `copy_root` d'`install.sh`) : `/etc` reste indépendant du
home (pas de fichier lu par root pointant vers un home utilisateur). Contrepartie :
après toute modif d'un drop-in, **relancer `install.sh`** pour resynchroniser `/etc`.

**L'esthétique reste hors repo** : `theme.conf` (`Current=nier-automata`) n'est
jamais versionné ni écrasé par `install.sh`.

## Keybinds : couche HYPER via keyd

Caelestia sature déjà `SUPER` (et `SUPER+SHIFT/CTRL/ALT`). Pour dégager un espace
perso propre, on ajoute une couche **HYPER** pilotée par **Caps Lock**, sans
casser Verr.Maj ni entrer en conflit avec les applis.

Mécanisme (`config/keyd/default.conf`, déployé dans `/etc/keyd/` via `copy_root`) :

- Caps Lock **tap** → Verr.Maj normal ;
- Caps Lock **maintenu + lettre** → couche `[hyper]` de keyd.

keyd n'a pas de vrai modificateur « Hyper » (ses modificateurs = Ctrl/Super/Alt/
Shift/AltGr). L'approche composite (Hyper = tous les modificateurs) collisionne
avec les combos `CTRL+SUPER+ALT` de Caelestia. On route donc `Caps + lettre` vers
des **F-keys (F13+)** qu'aucun clavier physique n'émet — zéro conflit — et Hyprland
lie ces F-keys aux actions (dans `hypr/user/keybinds.lua`). Bonus : l'action est
lancée **en tant qu'utilisateur** par Hyprland, pas en root comme le ferait
`command()` de keyd (ce qui casserait le lancement d'apps GUI Wayland).

Mapping actuel (`keyd` lettre→F-key, `keybinds.lua` F-key→app) :

| Combo       | keyd      | Action                        |
|-------------|-----------|-------------------------------|
| HYPER + C   | c → F13   | Claude (special workspace)    |
| HYPER + N   | n → F14   | zennotes                      |
| HYPER + T   | t → F15   | Thunderbird                   |

Prérequis machine : `paru -S keyd && sudo systemctl enable --now keyd`.
`install.sh` déploie la config et fait `keyd reload` si keyd est présent.

### Special workspaces "lance-ou-montre/cache"

Certaines apps vivent dans un **special workspace** (scratchpad Hyprland) plutôt
que dans les workspaces numérotés : Steam (`SUPER+G`), Obsidian (`SUPER+O`),
Claude (`HYPER+C`).

Le toggle passe par **`caelestia toggle <nom>`** (et non `hyprctl dispatch
togglespecialworkspace`, qui échoue ici : la config Hyprland est en Lua →
`hyprctl dispatch` est évalué comme du Lua). Mais `caelestia toggle` seul ne
**lance pas** l'app absente. Trois ingrédients :

- une **window rule** (`user/rules.lua`) épingle l'app à son scratchpad par classe :
  `hl.window_rule({ match = { class = "steam" }, workspace = "special:steam" })` ;
- le script **`scripts/app-ws.sh <class> <ws> <cmd>`** : si l'app tourne →
  `caelestia toggle <ws>` (montre/cache) ; sinon → il la lance (la rule la range
  dans `special:<ws>`) puis `caelestia toggle <ws>` pour l'afficher ;
- les **raccourcis** (`user/keybinds.lua`) appellent ce script.

Un seul raccourci fait donc tout : lancer si absente, montrer/cacher sinon.
(Une piste plus intégrée existe — les toggles `cli.json` de la CLI Caelestia —
mais son format exact n'a pas pu être fiabilisé, on s'en tient au script testé.)

Impact système : un special workspace ne coûte rien de plus qu'un workspace
normal (même conteneur logique). Seule l'app consomme (sa RAM) ; masquée, elle
n'est pas rendue (pas de coût GPU/compositing) et Hyprland cesse ses frame
callbacks → CPU au repos.

Réserve pour plus tard : des **submaps** Hyprland (leader + mode) pour de gros
groupes d'actions, non nécessaires tant que la couche HYPER suffit.

Les workspaces sont par ailleurs réécrits **par keycode** (`code:10..19`) pour
rester universels AZERTY/QWERTY, en réutilisant `fn.wsaction` de Caelestia.

## Fonctionnement d'`install.sh`

Idempotent. Pour chaque cible : symlink déjà correct → rien ; fichier/dossier réel
→ sauvegarde `.bak-<date>` puis symlink ; absent → symlink direct. Deux fonctions :

- `link()` : symlink dans le home (Hyprland, configs `~/.config`).
- `copy_root()` : copie via `sudo` vers `/etc` (SDDM et keyd), avec backup et
  idempotence (`cmp` avant recopie).

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
