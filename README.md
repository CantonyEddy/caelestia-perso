# caelestia-perso

Surcouche de personnalisations par-dessus [caelestia-dots](https://github.com/caelestia-dots/caelestia)
(rice Hyprland / Quickshell sur Arch Linux), **sans modifier leur dépôt**.

Caelestia fournit la base ; ce dépôt ne contient que des **overrides** (clavier,
raccourcis, quelques apps) déployés par symlinks. On peut ainsi mettre à jour
Caelestia sans perdre ces réglages, et versionner la config.

## Ce que ça contient

- **Hyprland** (en Lua) : variables, raccourcis, layout clavier FR, règles…
- **Quelques apps** que Caelestia ne gère pas : fuzzel, cava, htop, zed, spicetify.
- **SDDM** : la config fonctionnelle (Wayland, numlock…), pas le thème visuel.

Les apps et couleurs gérées par Caelestia (foot, fish, btop, scheme dynamique du
wallpaper…) sont **laissées à Caelestia**. Détails dans [ARCHITECTURE.md](ARCHITECTURE.md).

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

`install.sh` sauvegarde tout fichier existant en `.bak-<date>` avant de créer le
symlink, et ne refait rien si le lien est déjà bon (idempotent). Il demande le
**mot de passe sudo** pour déployer la config SDDM vers `/etc/sddm.conf.d/`.

## Mise à jour

```sh
cd ~/.local/share/caelestia-perso
git pull
./install.sh          # réapplique les symlinks (+ SDDM via sudo)
hyprctl reload        # recharge Hyprland
```

Après un `caelestia update`, relancer `./install.sh` réapplique les overrides si
Caelestia a redéployé ses propres fichiers.

## Modifier la config

- **Hyprland** : éditer les fichiers dans `hypr/` (voir le mémo Lua dans
  [ARCHITECTURE.md](ARCHITECTURE.md)), puis `hyprctl reload`.
- **Apps** (`config/…`) : les fichiers sont symlinkés, donc toute modif est
  immédiatement active.
- **SDDM** (`config/sddm/conf.d/…`) : après modif, relancer `./install.sh` (copie
  vers `/etc`).

## Liens utiles

- Caelestia (upstream) : https://github.com/caelestia-dots/caelestia
- Wiki Hyprland (config) : https://wiki.hypr.land/Configuring/
- Détails techniques de ce dépôt : [ARCHITECTURE.md](ARCHITECTURE.md)
