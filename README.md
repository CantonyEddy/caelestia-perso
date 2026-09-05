# caelestia-perso

Surcouche de personnalisations par-dessus [caelestia-dots](https://github.com/caelestia-dots/caelestia)
(rice Hyprland / Quickshell sur Arch Linux), **sans modifier leur dépôt**.

Caelestia fournit la base ; ce dépôt ne contient que des **overrides** (clavier,
raccourcis, quelques apps) déployés par symlinks. On peut ainsi mettre à jour
Caelestia sans perdre ces réglages, et versionner la config.

## Ce que ça contient

- **Hyprland** (en Lua) : variables, raccourcis, layout clavier FR, règles…
- **Quelques apps** que Caelestia ne gère pas : fuzzel, cava, htop, zed (configs
  symlinkées) ; les préférences **spicetify** sont appliquées par `install.sh`
  (`spicetify config`), pas via un fichier partagé (il contient des chemins machine).
- **SDDM** : la config fonctionnelle (Wayland, numlock…), pas le thème visuel.
- **Prompt Starship** : un prompt « capsules » perso dont les couleurs suivent le
  scheme caelestia (donc ton fond d'écran). Voir la section dédiée plus bas.

Les apps et couleurs gérées par Caelestia (foot, fish, btop, scheme dynamique du
wallpaper…) sont **laissées à Caelestia**. Détails dans [ARCHITECTURE.md](ARCHITECTURE.md).

## Prompt Starship

Le prompt de fish est un prompt **Starship** perso, en « capsules » arrondies. Ses
couleurs sont des **indices de palette ANSI** que caelestia remappe en direct :
le prompt (ligne active **et** scrollback) se recolore tout seul au changement de
scheme, comme le reste du terminal. On ne touche pas au `starship.toml` géré par
caelestia : le nôtre est branché via `STARSHIP_CONFIG` (dans `fish/user-config.fish`).

- gauche : `OS › dossier › durée` (en ms), puis `❯` en 2ᵉ ligne ;
- une ligne double `═` relie les deux groupes ;
- droite : `status › (git) › heure` — le code de sortie de la dernière commande
  (✓ / ✗+code) est l'ancre toujours présente, git n'apparaît que dans un dépôt.

Chaque bloc a sa couleur (pas de dégradé d'une seule teinte : la palette ANSI n'a
que des couleurs distinctes — c'est le compromis pour recolorer aussi le scrollback).

Le style est produit par `scripts/gen-starship.py` (outil de build) qui écrit
`config/starship.toml`. Pour le changer (glyphes, couleurs, disposition), édite le
script puis régénère (fish) :

```fish
python3 ~/.local/share/caelestia-perso/scripts/gen-starship.py  # régénère config/starship.toml
exec fish                                                        # recharge le prompt
```

Détails techniques (jonctions arrondies, rôles Material You…) dans [ARCHITECTURE.md](ARCHITECTURE.md).

## Raccourcis clavier

### La couche HYPER (Caps Lock)

Caps Lock a un **double rôle** (via keyd) :

- **appui bref** → Verr.Maj normal ;
- **maintenu + une touche** → raccourci de la couche « HYPER » (raccourcis
  additionnels, sans conflit avec les applis).

### Special workspaces : lancer / afficher / cacher

Certaines apps vivent dans un **special workspace** : une fenêtre qu'on fait
apparaître par-dessus l'écran courant, puis disparaître, sans encombrer les
bureaux numérotés. **Un seul raccourci fait tout** : si l'app est fermée, elle se
**lance** ; si elle est déjà ouverte, on **affiche/cache** sa fenêtre.

| Raccourci | Application  |
|-----------|--------------|
| `SUPER+G` | Steam        |
| `SUPER+O` | Obsidian     |
| `HYPER+C` | Claude       |
| `HYPER+T` | Thunderbird  |
| `HYPER+S` | Signal       |
| `HYPER+A` | KeePassXC    |

### Autres raccourcis

| Raccourci | Action                        |
|-----------|-------------------------------|
| `HYPER+N` | zennotes                      |
| `SUPER+D` | Discord (vesktop)             |
| `SUPER+M` | Spotify                       |
| `SUPER+;` | Sélecteur d'emoji             |

Les bureaux se changent avec `SUPER+<chiffre>` (touches de la rangée du haut,
compatibles AZERTY comme QWERTY).

### Ajouter un special workspace

1. Récupérer la **classe** de la fenêtre (app ouverte) : `hyprctl clients | grep -iE "class|title"`.
2. Ajouter une règle dans `hypr/user/rules.lua` :
   `hl.window_rule({ match = { class = "<classe>" }, workspace = "special:<nom>" })`.
3. Ajouter un raccourci dans `hypr/user/keybinds.lua` qui appelle le script
   `scripts/app-ws.sh <classe> <nom> <commande de lancement>`.
4. `hyprctl reload`.

Voir des exemples concrets dans ces deux fichiers, et le détail dans [ARCHITECTURE.md](ARCHITECTURE.md).

## Installation

```sh
git clone git@github.com:CantonyEddy/caelestia-perso.git ~/.local/share/caelestia-perso
~/.local/share/caelestia-perso/install.sh
hyprctl reload
```

Pour la couche de raccourcis **HYPER** (Caps Lock), installer keyd une fois :

```sh
paru -S keyd
sudo systemctl enable --now keyd
```

`install.sh` :

- **installe les dépendances** manquantes (keyd, uwsm, fuzzel, cava, htop, zed,
  spicetify, sddm) via `paru`/`yay` ;
- **propose d'installer les applis des raccourcis** (Steam, Obsidian, Claude,
  Thunderbird, Signal, Spotify, Discord, zennotes) via un petit **sélecteur** —
  tu choisis tout, rien, ou une partie (par numéros) ;
- **symlinke** les configs (sauvegarde de l'existant en `.bak-<date>`, idempotent) ;
- demande le **mot de passe sudo** pour déployer keyd (`/etc/keyd/`) et SDDM
  (`/etc/sddm.conf.d/`).

## Wallpapers

Les images **ne sont pas incluses** dans ce dépôt. Le picker caelestia les lit
dans **`~/Pictures/Wallpapers`** (chemin portable dans `shell/shell.json`,
développé par utilisateur — pas de `/home/<toi>` en dur, pour que la conf marche
chez tout le monde). Mets-y tes fonds d'écran (un sous-dossier est OK, le scan est
récursif), puis change de wallpaper via le launcher (`>wallpaper`) ou
`caelestia wallpaper`. Après avoir modifié `shell.json`, redémarre le shell :
`caelestia shell -k; and sleep 1; and caelestia shell -d` (ou `Ctrl+Super+Alt+R`).

## Mise à jour

```sh
cd ~/.local/share/caelestia-perso
git pull
./install.sh          # réapplique les symlinks (+ SDDM via sudo)
hyprctl reload        # recharge Hyprland
```

Après un `caelestia update`, relancer `./install.sh` réapplique les overrides si
Caelestia a redéployé ses propres fichiers.

## Désinstallation

`uninstall.sh` fait l'inverse d'`install.sh` : il retire les symlinks perso et les
fichiers déployés dans `/etc`. Il **ne restaure pas** les `.bak` — Caelestia
régénère ses défauts au prochain reload.

```sh
cd ~/.local/share/caelestia-perso
./uninstall.sh --dry-run   # aperçu, ne touche à rien
./uninstall.sh             # retire les symlinks ~/.config + keyd
./uninstall.sh --sddm      # inclut aussi la config SDDM /etc
hyprctl reload
```

Sûreté intégrée :

- un symlink n'est retiré **que** s'il pointe vers ce dépôt (un fichier réel ou un
  lien externe est laissé intact) ;
- un fichier `/etc` (keyd, SDDM) n'est supprimé **que** s'il est identique à la
  version du dépôt, avec sauvegarde `.bak-<date>` avant retrait ;
- **SDDM est exclu par défaut** (chemin de login critique) — il faut le flag
  `--sddm`. Le retirer peut faire disparaître l'écran de login au boot : garde un
  TTY prêt (`Ctrl+Alt+F3`) si tu l'utilises.

Les `.bak-<date>` laissés par `install.sh` ne sont pas supprimés automatiquement :
à nettoyer à la main une fois que tout est vérifié.

## Modifier la config

- **Hyprland** : éditer les fichiers dans `hypr/` (voir le mémo Lua dans
  [ARCHITECTURE.md](ARCHITECTURE.md)), puis `hyprctl reload`.
- **Apps** (`config/…`) : les fichiers sont symlinkés, donc toute modif est
  immédiatement active.
- **SDDM** (`config/sddm/conf.d/…`) : après modif, relancer `./install.sh` (copie
  vers `/etc`).
- **Prompt Starship** : éditer `scripts/gen-starship.py`, puis régénérer (voir la
  section « Prompt Starship »).

## Liens utiles

- Caelestia (upstream) : https://github.com/caelestia-dots/caelestia
- Wiki Hyprland (config) : https://wiki.hypr.land/Configuring/
- Détails techniques de ce dépôt : [ARCHITECTURE.md](ARCHITECTURE.md)
