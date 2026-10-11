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
  donc ces réglages gagnent — **sauf les keybinds** (voir ci-dessous).

### ⚠️ Keybinds : pas de « dernier gagne »

Vérifié dans le source de Hyprland 0.56 (`CKeybindManager::handleKeybinds`) :
quand plusieurs `hl.bind` correspondent à la même combinaison, **ils se
déclenchent tous**. Ajouter dans `user/keybinds.lua` un bind sur une touche déjà
prise par Caelestia ne la remplace donc pas : les deux actions partent.

Règle du repo :
- raccourci **Caelestia à modifier** → redéfinir sa variable `kb*` dans
  `hypr-vars.lua` (le bind d'origine n'est alors jamais créé). Depuis Caelestia
  `f6d5250` (juil. 2026) quasiment tous leurs binds sont pilotés par variable ;
- `user/keybinds.lua` → **uniquement des combinaisons libres** chez Caelestia ;
- apps lancées par les toggles Caelestia (`SUPER+D`, `SUPER+M`…) →
  `config/caelestia/cli.json`, section `toggles` (lue par la fonction Lua
  `fn.toggle` et par `caelestia toggle`).

Bugs que ça corrigeait (oct. 2026) : `SUPER+6` (= `-` en AZERTY) allait au bureau 6
**et** rétrécissait la fenêtre ; `Ctrl+SUPER+6` changeait de groupe **et** passait
au morceau précédent ; `SUPER+D`/`SUPER+M` faisaient le toggle **et** relançaient
l'app.

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
fish/plugins/autopair/ # plugin autopair.fish vendorisé (MIT), chargé par user-config.fish
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
├── solaar/rules.yaml (symlink) + config.yaml (graine copiée)  # souris Logitech, optionnel
└── caelestia/cli.json                # -> ~/.config/caelestia/cli.json (toggles SUPER+D/M)
```

(Spicetify n'est PAS dans cette liste : `config-xpui.ini` n'est plus versionné —
voir « Portabilité » ci-dessus. Ses préférences sont appliquées par `install.sh`
via `spicetify config`.)

### Pourquoi ce périmètre restreint (analyse Caelestia)

Caelestia maintient un clone de ses dotfiles dans
`~/.local/state/caelestia/dots/` (source de son CLI) et **déploie ses fichiers
par copie** (voir `manifest.toml`). Comparaison faite :

| App                        | Statut                          | Décision            |
|----------------------------|---------------------------------|---------------------|
| foot, fish, fastfetch, micro | identiques au défaut Caelestia | **non versionnés**  |
| btop                       | perso mais géré par Caelestia   | **non versionné**   |
| fuzzel, cava, htop, zed    | absents du clone → 100% perso   | **versionnés**      |
| solaar                     | absent du clone → 100% perso    | **versionné**       |
| spicetify/config-xpui.ini  | réécrit par spicetify (état machine) | **non versionné** (`spicetify config` dans install.sh) |

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

### Portabilité (conf partagée) : pas de chemin home en dur

Ce dépôt est **partagé** : tout fichier versionné doit éviter les chemins absolus
`/home/<toi>/…` (l'utilisateur n'existe pas chez les autres). Ex. corrigé :
`shell/shell.json` → `paths.wallpaperDir = "~/Pictures/Wallpapers"` (le shell
développe le `~` par utilisateur), au lieu de `/home/ryu/Pictures/Wallpapers` qui
cassait le picker chez les autres. Préférer `~`, `$HOME`, ou un chemin relatif
partout où c'est possible.

**Spicetify** est un cas à part : `config-xpui.ini` exige des chemins **absolus**
(spicetify n'expanse pas `~`) ET spicetify **réécrit** ce fichier à chaque `apply`
(`prefs_path`/`spotify_path` auto-détectés + `[Backup] version` = version locale de
Spotify). Le symlinker polluait donc le repo avec de l'état machine, partagé aux
autres. On **ne le versionne plus** : `install.sh` applique les **préférences
portables** via `spicetify config … ; spicetify apply` (spicetify écrit les bons
chemins locaux), et retire un éventuel ancien symlink pour que spicetify régénère
un fichier local.

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

## Prompt Starship perso (couleurs ANSI, recolorées en direct)

Caelestia gère son propre `~/.config/starship.toml` (composant `starship`, déployé
par copie). Le symlinker créerait un conflit (écrasé à chaque `caelestia update`).
On contourne sans toucher à leur fichier :

- **`STARSHIP_CONFIG`** — Starship lit cette variable pour choisir son fichier. On
  la pointe sur `config/starship.toml` depuis `fish/user-config.fish`. Caelestia
  garde le sien, nous le nôtre : zéro croisement.

- **Couleurs = indices de palette ANSI** (`16`/`17`/`18` = primary/secondary/
  tertiary ; `0` = term0 sombre pour le texte ; `1` = red). Caelestia **remappe la
  palette en direct** (séquences OSC 4 — voir « couleurs terminal » plus haut).
  Donc le prompt — ligne active **et scrollback** — se recolore tout seul au
  changement de scheme, comme le reste du terminal. **Config STATIQUE** : aucune
  dynamique à gérer côté prompt (ni template, ni `postHook`). Contrepartie : pas de
  dégradé tonal d'une seule teinte (la palette n'a que des couleurs distinctes) —
  chaque bloc a SA couleur (choix assumé).

  Note historique : une version antérieure utilisait des **hex** issus des rôles
  Material You (moteur de templates caelestia + un `postHook` SIGWINCH pour forcer
  le redraw) → vrai dégradé tonal, mais le scrollback ne se recolorait pas (hex
  truecolor = pixels figés). On a tranché pour l'ANSI (recolore partout, plus simple).

- **Style « capsules »** : segments arrondis (demi-cercles Nerd Font `CAP_L`/`CAP_R`,
  JetBrains Mono Nerd), chaque bloc sur un fond de couleur ANSI, texte sombre (`0`).
  - gauche : `OS > dossier > durée` (capsule connectée) ; `$fill` (ligne double `=`)
    relie les 2 groupes ; `❯` en ligne 2 (tout le reste sur la ligne 1 via `$fill`,
    pas `right_format`). Durée en **ms** (`min_time = 0`, `show_milliseconds = true`).
  - droite : `(status(git_status(branch+logo(heure)` en dépôt, `(status(heure)`
    sinon. Chaque jonction est un demi-cercle `(` (le segment courant « mord » dans
    le précédent : CAP_L, sa couleur sur le fond du précédent). `status` (code de
    sortie, ✓ / ✗+code) est l'**ancre permanente** (`disabled = false` +
    `success_symbol` → visible aussi en succès). Il a la même couleur que la branche
    → l'heure porte son `(` de jonction en **statique**, valable que le voisin soit
    la branche (dépôt) ou le status (hors dépôt). Aucun module conditionnel.

### Build / runtime

`scripts/gen-starship.py` est un **outil de build** (pas runtime) : il écrit
`config/starship.toml` depuis une seule définition (`SYMBOLS`, couleurs `C1/C2/C3`,
layout). `user-config.fish` (déjà symlinké) pointe juste `STARSHIP_CONFIG` dessus.
Rien à symlinker ni à faire rendre par caelestia. Personnaliser :

```sh
# édite scripts/gen-starship.py (couleurs C1/C2/C3/TXT, SYMBOLS, CAP_*), puis :
python3 ~/.local/share/caelestia-perso/scripts/gen-starship.py   # régénère config/starship.toml
exec fish                                                        # recharge le prompt
```

## Config SDDM (`config/sddm/conf.d/`)

La config **fonctionnelle** de SDDM est versionnée en drop-ins. ⚠️ SDDM lit
**tous les fichiers** de `/etc/sddm.conf.d/` — **sans filtre d'extension** —
par ordre alphabétique, puis `/etc/sddm.conf` ; pour une même clé, **le dernier
lu gagne** (vérifié dans `ConfigReader.cpp` de SDDM). Un `20-wayland.conf.bak`
est donc lu APRÈS `20-wayland.conf` et l'écrase.

```
config/sddm/
├── conf.d/                    (INI démon SDDM -> /etc/sddm.conf.d/)
│   ├── 10-general.conf     [General]   DisplayServer=wayland, Numlock=on
│   ├── 20-wayland.conf     [Wayland]   CompositorCommand=… hyprland-greeter.lua
│   ├── 30-autologin.conf   [Autologin] (placeholder commenté)
│   └── 40-users.conf       [Users]     (placeholder commenté)
├── hyprland-greeter.lua       (Lua -> /etc/sddm/)      ← CONFIG ACTIVE
└── hyprland-greeter.conf      (hyprlang -> /etc/sddm/) ← filet de secours
```

`hyprland-greeter.lua` est la config **Hyprland** du compositeur lancé derrière
l'écran de login (`kb_layout = fr`, numlock, fond noir…), référencée par le
`CompositorCommand` de `20-wayland.conf`. Les deux greeters sont déployés dans
`/etc/sddm/` (hors de `sddm.conf.d/`, que SDDM parse comme du INI).

Ces fichiers sont **copiés** (pas symlinkés) vers `/etc` via `sudo` (`copy_root`) :
`/etc` reste indépendant du home. Après toute modif, **relancer `install.sh`**.

### Ce que fait `install.sh` (ordre important, chemin de boot)

1. `purge_dropin_baks` : déplace tout `*.bak*` / `*.save` / `*~` de
   `/etc/sddm.conf.d/` vers `/var/backups/caelestia-perso/<date>/`.
2. Dépose **les deux** greeters (`.lua` et `.conf`) dans `/etc/sddm/`.
3. Déploie les drop-ins. Pour `20-wayland.conf` : si
   `Hyprland --verify-config --config /etc/sddm/hyprland-greeter.lua` échoue (ou
   Hyprland absent), il déploie une variante pointant sur le `.conf` → on ne
   pointe **jamais** vers un fichier absent ou invalide.
4. Affiche le `CompositorCommand` effectif.

`copy_root` ne crée **plus jamais** de `.bak` à côté de la cible : les sauvegardes
vont dans `/var/backups/caelestia-perso/<date>/<chemin complet>`.

### Post-mortem de l'écran noir (août 2026) — cause établie en oct. 2026

Ce n'était **pas** le Lua. Chronologie reconstituée depuis `/etc/sddm.conf.d/` :

1. 4 août 16h37 : `install.sh` déploie `20-wayland.conf` → `.lua` et sauvegarde
   l'ancien en `20-wayland.conf.bak-20260804-163721` (→ `.conf`) **dans le même
   dossier**. SDDM lit ce `.bak` en dernier → le greeter reste en réalité sur le
   `.conf`. L'AZERTY + numlock au login (présents dans les deux fichiers) a fait
   croire que le `.lua` était chargé.
2. 17h30 : le `.conf` est supprimé. `start-hyprland -- --config …greeter.conf`
   vise un fichier absent → Hyprland quitte immédiatement (`main.cpp`, « Config
   file is invalid ») → écran noir.
3. 11 août : la restauration redéploie `20-wayland.conf` → `.conf` et sauvegarde
   la version `.lua` en `20-wayland.conf.bak-20260811-171237`… lue en dernier.
   **Depuis le 11 août, le greeter tourne donc très probablement déjà en Lua**
   (à confirmer : `journalctl -b -u sddm | grep -i greeter`).

### Hyprland 0.57

0.57 **supprime le format `.conf`** (upstream `a9902ea6`, sur `main`, absent de
0.56.x) : tout `--config` est lu en Lua. Le greeter en `.lua` est donc requis ;
le `.conf` ne sert plus de secours qu'en ≤ 0.56. Avant la 0.57, vérifier que
`install.sh` affiche bien `Greeter actif : … hyprland-greeter.lua`.

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
Claude (`HYPER+C`), Thunderbird (`HYPER+T`), Signal (`HYPER+S`), KeePassXC (`HYPER+A`).

**Source de vérité unique : `hypr/user/special.lua`** (oct. 2026). Une table
`APPS` (`key`, `ws`, `class`, `cmd`) génère pour chaque app :

1. la règle de **tag** (`class` → `ws_<ws>`) ;
2. après tous les taguages, la règle de **routage** (`ws_<ws>` → `special:<ws>`)
   — schéma imposé par la réécriture des window rules (Hyprland 0.53+) ;
3. le **raccourci** → `scripts/app-ws.sh <class> <ws> <cmd>`.

Avant, la classe était recopiée à trois endroits (`keybinds.lua` + 2 règles dans
`rules.lua`) : un écart suffisait à faire décrocher l'app (Obsidian a changé de
classe deux fois). La classe est maintenant convertie en regex **exacte et
insensible à la casse** (`(?i)` + échappement) ; Hyprland compare les règles en
`FullMatch` (RE2), donc `steam` ne capture **pas** les jeux `steam_app_123`.

`scripts/app-ws.sh` (inchangé, testé) : si une fenêtre de la classe existe →
`caelestia toggle <ws>` ; sinon il lance l'app, **attend** (≤ 8 s) qu'une fenêtre
de la classe soit routée dans `special:<ws>`, puis toggle (anti-race avec
`close_special_on_empty`). Le toggle passe par `caelestia toggle` et jamais par
`hyprctl dispatch` (évalué comme du Lua dans cette config).

Pourquoi pas les toggles natifs `cli.json` de Caelestia (utilisés pour SUPER+D/M) :
leur détection est une **sous-chaîne sensible à la casse** (`string.find` /
`in` Python) → `steam` capturerait les jeux et les y déplacerait, et la casse
d'Obsidian casserait la détection. Ils montrent aussi le workspace vide AVANT
la naissance de la fenêtre (la race qu'`app-ws.sh` évite).

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

## Souris Logitech MX Master 3 (Solaar)

**Pourquoi Solaar et pas Piper.** Piper/libratbag écrit dans la **mémoire
onboard** de la souris (profils). La G502 en a une → Piper fonctionne ; la MX
Master 3 **n'en a pas** → libratbag échoue (« The device has been reset to a
previous state »). Solaar, lui, applique les réglages **côté logiciel** à chaque
connexion de l'appareil : c'est un **service qui doit tourner en permanence**.
Répartition : Piper → G502, Solaar → MX Master 3. **logiops exclu** (deux démons
qui pilotent la même souris via HID++ se marchent dessus) ; `install.sh` prévient
si `logid` est actif.

**Lancement.** `hypr/user/execs.lua` (activé dans `hypr-user.lua`) :

```lua
hl.on("hyprland.start", function()
    hl.exec_cmd("command -v solaar >/dev/null && uwsm app -- solaar --window=hide")
end)
```

Équivalent Lua de `exec-once` (même mécanisme que `hyprland/execs.lua` de
Caelestia) : le callback ne tourne qu'au démarrage du compositeur, **pas à
chaque `hyprctl reload`**. Le paquet Arch `solaar` ne fournit **pas** d'entrée
XDG autostart (`/etc/xdg/autostart`) → pas de double lancement par uwsm.

**Fichiers versionnés** (`config/solaar/` → `~/.config/solaar/`) — `rules.yaml` symlinké, `config.yaml` = graine copiée si absente :

- `config.yaml` : réglages par appareil (liste YAML, 1 entrée par souris,
  identifiée par `_modelId`/`_unitId`). Pour la MX Master 3 : `divert-keys`
  `{195: 1}` = CID `0x00C3` (*Mouse Gesture Button*) **diverted** vers Solaar,
  `dpi`, `smart-shift`, `scroll-ratchet`, molette hi-res…
- `rules.yaml` : règles du Rule Editor (documents YAML séparés par `---`) :

  ```yaml
  - Key: [Mouse Gesture Button, pressed]
  - KeyPress: [Super_L, depress]
  ---
  - Key: [Mouse Gesture Button, released]
  - KeyPress: [Super_L, release]
  ```

  → bouton pouce **maintenu = Super maintenu** → `Super + clic-glisser` Hyprland.

**Pourquoi `config.yaml` n'est plus symlinké (oct. 2026).** Solaar sauvegarde
avec `open(path, "w")` → il suit un symlink et écrit dans le repo. Or
`config.yaml` contient de l'**état machine** réécrit en continu (`_battery`,
`_config_cookie`, `_absent`, `_unitId`, appareils détectés…) : le repo était
perpétuellement « modifié » et poussait cet état aux autres utilisateurs. Même
traitement que `spicetify/config-xpui.ini` : `install.sh` copie une **graine** si
le fichier est absent (et convertit un ancien symlink en copie locale). Seul
`rules.yaml` (portable) reste symlinké. Solaar est aussi passé de dépendance
obligatoire à **appli optionnelle** (sélecteur d'`install.sh`).

**uinput (Wayland).** La simulation de touches (`KeyPress`) passe par
`/dev/uinput` (pas de XTest sous Wayland). Accès donné par la règle udev du
paquet (`/usr/lib/udev/rules.d/42-logitech-unify-permissions.rules`, `uaccess`),
effective **après reconnexion de session**. Rien à versionner côté `/etc`.

**Nix.** Le paquet reste sur **pacman** (les règles udev doivent être installées
au niveau système, ce que Home Manager ne fait pas sur Arch) ; seuls les deux
symlinks sont dans `nix/home.nix`.

## Fonctionnement d'`install.sh`

Idempotent. Pour chaque cible : symlink déjà correct → rien ; fichier/dossier réel
→ sauvegarde `.bak-<date>` puis symlink ; absent → symlink direct. Deux fonctions :

- `link()` : symlink dans le home (Hyprland, configs `~/.config`).
- `copy_root()` : copie via `sudo` vers `/etc` (SDDM et keyd), avec backup et
  idempotence (`cmp` avant recopie).

Une cible déjà posée par Home Manager (lien vers `/nix/store`) est laissée telle
quelle (`hm_managed`). Voir « Intégration Nix / Home Manager ».

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

## Intégration Nix / Home Manager (optionnelle)

Deuxième façon de déployer, **à côté** d'`install.sh` (qui reste la référence :
un utilisateur sans Nix ne voit aucune différence).

```
flake.nix              # inputs : nixpkgs, home-manager, caelestia-dots/shell
nix/home.nix           # module commun = équivalent de la section link d'install.sh
nix/hosts/fixe.nix     # overrides par écran de chaque machine
nix/hosts/framework.nix
```

**Périmètre (hybride).** Caelestia ne fournit officiellement pour Nix que le
**shell + CLI** (`homeManagerModules.default` → `programs.caelestia`). Les
dotfiles de base (Hyprland Lua…) restent déployés par copie par le CLI
(`caelestia install`), comme sans Nix. Répartition :

| Géré par        | Quoi |
|-----------------|------|
| pacman / paru   | Hyprland, SDDM, keyd, uwsm, pilotes GPU, apps graphiques |
| Home Manager    | caelestia-shell + CLI, symlinks de l'override, outils CLI (fuzzel, fzf, jq, cava, htop) |
| CLI Caelestia   | dotfiles de base (`~/.local/state/caelestia/dots/` → copie) |
| `install.sh`    | /etc (keyd, SDDM), dépendances pacman/AUR, applis |

**Choix techniques.**

- `mkOutOfStoreSymlink` : HM pose `~/.config/… → /nix/store/…-hm_… → repo`. On
  édite le repo, l'effet est immédiat (pas de rebuild), comme avec `install.sh`.
  Conséquence : le repo **doit** être cloné dans `~/.local/share/caelestia-perso`.
- `programs.caelestia.settings` **non utilisé** : `shell.json` reste le fichier du
  repo (le module n'écrit `shell.json` que si `settings` est non vide).
- `systemd.enable = false` : la conf Hyprland de Caelestia lance déjà le shell
  (évite deux instances).
- `targets.genericLinux.enable` : Arch n'est pas NixOS → pilotes GPU pour les
  apps Qt/OpenGL de Nix (lancer une fois le `sudo …/non-nixos-gpu-setup` que HM
  indique ; NVIDIA : renseigner `targets.genericLinux.gpu.nvidia.{version,sha256}`).
- PATH : `systemd.user.sessionVariables` (→ `environment.d`, session uwsm) +
  `fish_add_path` gardé par `test -d` dans `user-config.fish` (sans effet sans Nix).

**Cohabitation avec les scripts.** `install.sh` et `uninstall.sh` détectent un
lien Home Manager (cible directe dans `/nix/store`) et le **laissent** (`⌂`).
Donc : Home Manager d'abord, puis `./install.sh` pour la partie système. Tout
nouveau symlink doit être ajouté **aux deux endroits** (`install.sh` + `nix/home.nix`).

**Pièges.**

- Un flake ne voit que les fichiers **suivis par git** : `git add` avant `switch`.
- Écran de verrouillage : le PAM compilé par Nix peut échouer hors NixOS → tester
  le lock après le 1er switch.
- `caelestia update` ne met plus à jour le shell : c'est `nix flake update` +
  `home-manager switch`.

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
hl.window_rule({ match = { class = "com.saivert.pwvucontrol" }, float = true })

-- changer un bind Caelestia : PAS de hl.bind en double (les deux partent),
-- on redéfinit la variable dans hypr-vars.lua :  kbEmoji = "SUPER + semicolon"
```
