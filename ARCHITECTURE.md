# Architecture & choix techniques — caelestia-perso

Doc technique du dépôt. Pour l'usage courant (installer, mettre à jour), voir
[README.md](README.md).

## Principe fondateur

Superposer des overrides **par-dessus** [caelestia-dots](https://github.com/caelestia-dots/caelestia)
**sans jamais toucher à leur repo**. `install.sh` symlinke les fichiers du dépôt dans
`~/.config/caelestia/` (Hyprland Lua) et `~/.config/<app>/` (configs pur perso).
Corollaire : **on ne versionne que les personnalisations**, jamais un défaut Caelestia.

## Comment Caelestia charge les fichiers Hyprland

Depuis la migration Hyprland 0.55 / Caelestia CLI v1.1.0, la config Hyprland est
en **Lua** (plus en hyprlang `.conf`). D'après `~/.config/hypr/hyprland.lua` :

- ligne ~45 : `local overrides = require("hypr-vars")` → **hypr-vars.lua** est une
  TABLE de données (`return { ... }`), fusionnée dans leurs variables.
- ligne ~76 : `require("hypr-user")` (tout à la fin) → **hypr-user.lua** est du
  VRAI code Lua Hyprland (`hl.config`, `hl.bind`…), chargé après tout le reste,
  donc ces réglages gagnent.

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
└── user/              # les overrides Hyprland en Lua, par thème
    ├── input.lua      # clavier FR + touchpad (REMPLI, activé)
    ├── keybinds.lua   # raccourcis (REMPLI, activé)
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
écraserait le symlink (voire écrirait sa version *dans* le dépôt en suivant
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
`starship.toml` en revanche est géré par Caelestia (présent dans son clone) — **on
ne le symlinke donc PAS** (voir la section « Prompt Starship perso » plus bas, qui
contourne le conflit via `STARSHIP_CONFIG`). Comme `mimeapps.list` est à la racine
de `~/.config` (pas dans un sous-dossier), il faut le copier une fois dans le
repo avant de le symlinker :

```sh
cp ~/.config/mimeapps.list ~/.local/share/caelestia-perso/config/mimeapps.list
~/.local/share/caelestia-perso/install.sh   # détecte et symlinke
```

## Prompt Starship perso (propagation native caelestia)

Caelestia gère son propre `~/.config/starship.toml` (composant `starship` de son
`manifest.toml`, déployé **par copie**). Le symlinker créerait le conflit
habituel (recopié/écrasé à chaque `caelestia update`, voire écriture *à travers*
le lien jusque dans ce repo). On contourne **sans jamais toucher** à leur fichier :

- **`STARSHIP_CONFIG`** — Starship lit cette variable d'env pour choisir son
  fichier (défaut : `~/.config/starship.toml`). On la pointe ailleurs depuis
  `fish/user-config.fish` (hook officiel Caelestia). Caelestia garde son fichier,
  nous le nôtre : zéro croisement.

- **Couleurs = propagation NATIVE caelestia (moteur de templates).** La CLI
  (`caelestia/utils/theme.py` → `apply_user_templates`) rend **tout** fichier de
  `~/.config/caelestia/templates/` vers `~/.local/state/caelestia/theme/<nom>` à
  **chaque changement de scheme**, en remplaçant les `{{ role.form }}` par la
  vraie couleur (`role` = rôle Material You de `scheme.json` ; `form` = `hex`,
  `rgb`, `hsl`…). On dépose donc un template `starship.toml` : les couleurs sont
  **littéralement celles de caelestia**. Nuance importante : notre prompt utilise
  des **hex en dur** (truecolor), pas la palette ANSI. Au changement de scheme, il
  ne se recolore donc PAS en direct comme le reste du terminal (que caelestia
  remappe via la palette ANSI, OSC 4) : la ligne déjà affichée reste figée, et le
  prompt prend les nouvelles couleurs **au prochain affichage** (Entrée) — car
  Starship relit alors le fichier que caelestia vient de régénérer. C'est le prix
  du **vrai dégradé tonal** (les noms ANSI se recoloreraient en direct mais ne
  donnent que 16 couleurs discrètes). Le dégradé bord(foncé)→centre(clair) utilise
  des rôles tonals réels du primary :
  `onPrimary` → `primaryContainer` → `primary` (aucune interpolation). **Piège
  vérifié** : n'utiliser que des rôles M3 *de base* (présents dans le scheme
  DYNAMIQUE) — les rôles `*Fixed` n'existent que dans le scheme statique, donc
  leur placeholder reste non remplacé → couleur invalide → segment sans fond.

- **Style « capsules powerline »** au lieu du texte coloré par défaut : segments
  arrondis (demi-cercles Nerd Font ``/``, fournis par JetBrains Mono
  Nerd) avec fond coloré.
  **Capsules connectées** (segments collés ; seuls les bouts extérieurs sont
  arrondis, transition arrondie powerline entre segments). Dégradé bord→centre.
  - gauche : `( OS › dossier › durée )` puis `$fill` (espace extensible) ; `❯`
    en ligne 2. **Tout est sur la ligne 1** grâce à `$fill` — on n'utilise PAS
    `right_format`, qui s'alignerait sur la ligne du `❯`.
  - un connecteur **`$fill`** (ligne double `═`, couleur c2) relie visuellement le
    groupe gauche et le groupe droit (les bouts des capsules restent inchangés).
  - droite : `(status(gitstatus(branch+logo(heure)` en dépôt, `(status(heure)`
    hors dépôt. Chaque jonction est UN demi-cercle `(` (le segment courant « mord »
    dans le précédent : CAP_L, sa couleur SUR le fond du précédent).
    **Le module `status` (code de sortie) est l'ancre permanente** : `disabled =
    false` + `success_symbol` → il s'affiche AUSSI en cas de succès (✓), pas
    seulement sur erreur (✗ + code). Comme il a la MÊME couleur que la branche
    (c2), l'heure porte son `(` de jonction en **statique** (bg c2), ce qui marche
    que le voisin de gauche soit la branche (dépôt) ou le status (hors dépôt) —
    donc tout est statique, **sans module `custom` conditionnel** (essayé, ne se
    rendait pas de façon fiable). Pour changer l'ancre (mémoire, hostname…), garder
    la couleur c2 ; si le module choisi n'est pas naturellement permanent, le forcer
    à s'afficher toujours (comme `status` via `success_symbol`).
  - durée de commande en **ms** (`cmd_duration` : `min_time = 0`,
    `show_milliseconds = true`).

### Chaîne (build + runtime)

```
scripts/gen-starship.py   (OUTIL DE BUILD — 1 layout → 2 fichiers)
   ├─▶ config/caelestia-templates/starship.toml   TEMPLATE ({{ role.hex }})
   │        │  symlink par install.sh
   │        ▼
   │   ~/.config/caelestia/templates/starship.toml
   │        │  rendu par caelestia à chaque scheme (apply_user_templates)
   │        ▼
   │   ~/.local/state/caelestia/theme/starship.toml   ◀── STARSHIP_CONFIG
   │
   └─▶ config/starship.toml   FALLBACK statique (couleurs par défaut figées)
            ▲  STARSHIP_CONFIG si le rendu n'existe pas encore
       fish/user-config.fish
```

- `gen-starship.py` n'est **pas** exécuté au runtime : c'est un outil de dev qui
  produit les deux fichiers depuis une seule définition (`SYMBOLS`, `ROLES`,
  layout). On le relance à la main après avoir modifié le style, puis on commit.
- `user-config.fish` (déjà symlinké) fait juste : `STARSHIP_CONFIG` = fichier
  rendu par caelestia s'il existe, sinon `config/starship.toml` (fallback).
- `install.sh` symlinke le template puis **force un premier rendu** via
  `caelestia scheme set -n (caelestia scheme get -n)` (sinon le fichier rendu
  n'apparaît qu'au prochain changement de scheme).
- Le fichier rendu est hors repo (`~/.local/state`) → rien à `.gitignore`. Le
  dossier `config/caelestia-templates/` **est** versionné (c'est notre template).

### Personnaliser le style

Tout est dans `scripts/gen-starship.py` (en tête) : `ROLES` (quels rôles
caelestia pour le dégradé), `SYMBOLS` (glyphes OS/dossier/git/heure/prompt),
`CAP_L`/`CAP_R` (demi-cercles), `DEFAULT_HEX` (palette du fallback). Après
édition :

```sh
python3 ~/.local/share/caelestia-perso/scripts/gen-starship.py    # régénère les 2 fichiers
caelestia scheme set -n (caelestia scheme get -n)                 # re-rend le template
exec fish                                                         # recharge le prompt
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
| HYPER + S   | s → F16   | Signal (special workspace)    |
| HYPER + A   | a → F17   | KeePassXC (special workspace) |

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

- des **window rules par tags** (`user/rules.lua`) épinglent l'app à son scratchpad.
  Depuis la réécriture des window rules (Hyprland 0.53+), l'assignation directe
  `workspace = "special:x"` par classe ne marche plus ; on tague donc la fenêtre
  par classe (`tag = "+ws_steam"`) puis, **après tous les taguages**, on envoie les
  fenêtres taguées vers leur workspace (`match = { tag = "ws_steam" }, workspace = "special:steam"`) — même schéma que Caelestia ;
- le script **`scripts/app-ws.sh <class> <ws> <cmd>`** : si l'app tourne →
  `caelestia toggle <ws>` (montre/cache) ; sinon → il la lance (la rule la range
  dans `special:<ws>`) puis `caelestia toggle <ws>` pour l'afficher ;
- les **raccourcis** (`user/keybinds.lua`) appellent ce script.

Un seul raccourci fait donc tout : lancer si absente, montrer/cacher sinon.
(Une piste plus intégrée existe — les toggles `cli.json` de la CLI Caelestia —
mais son format exact n'a pas pu être fiabilisé, on s'en tient au script testé.)

Quand la dernière fenêtre d'un special workspace se ferme, il se **referme tout
seul** (au lieu de laisser un scratchpad vide affiché) grâce à l'option native
`misc:close_special_on_empty` posée dans `user/misc.lua`.

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

## Fonctionnement d'`uninstall.sh`

Miroir d'`install.sh`, sans restaurer les `.bak` (Caelestia régénère ses défauts).
Deux fonctions symétriques des précédentes :

- `unlink_repo()` : retire une cible **uniquement** si c'est un symlink dont la
  résolution (`readlink -f`) tombe dans ce dépôt — un fichier réel ou un lien
  externe est laissé intact (protège contre une suppression accidentelle).
- `remove_root_if_ours()` : supprime un fichier `/etc` **seulement** s'il est
  identique à la version du dépôt (`cmp`, donc bien celui posé par `install.sh`),
  après une sauvegarde `.bak-<date>`. S'il diffère, il est laissé et signalé.

Le retrait SDDM est **opt-in** (`--sddm`) car il touche au chemin de boot/login :
retirer `/etc/sddm/hyprland-greeter.conf` et les drop-ins `/etc/sddm.conf.d/` peut
supprimer l'écran de login. Un `--dry-run` liste ce qui serait fait sans rien
modifier. Les `.bak-<date>` d'`install.sh` ne sont pas nettoyés (choix manuel).

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
