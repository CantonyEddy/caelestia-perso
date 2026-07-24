# caelestia-perso

Mes personnalisations par-dessus [caelestia-dots](https://github.com/caelestia-dots/caelestia)
(rice Hyprland / Quickshell sur Arch Linux), **sans jamais modifier leur dépôt**.

L'idée : Caelestia fournit la base ; ce dépôt ne contient que **mes** overrides
(clavier, raccourcis, quelques apps) et les déploie par symlinks. Je peux ainsi
mettre à jour Caelestia sans perdre mes réglages, et versionner ma config perso.

## Ce que ça contient

- **Hyprland** (en Lua) : variables, raccourcis, layout clavier FR, règles…
- **Quelques apps** que Caelestia ne gère pas : fuzzel, cava, htop, zed, spicetify.
- **SDDM** : la config fonctionnelle (Wayland, numlock…), pas le thème visuel.

Les apps et couleurs gérées par Caelestia (foot, fish, btop, scheme dynamique du
wallpaper…) sont **laissées à Caelestia**. Détails dans [ARCHITECTURE.md](ARCHITECTURE.md).

## Installation

```sh
git clone git@github.com:CantonyEddy/caelestia-perso.git ~/.local/share/caelestia-perso
~/.local/share/caelestia-perso/install.sh
hyprctl reload
```

Pour la couche de raccourcis **HYPER** (Caps Lock), installe keyd une fois :

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

Après un `caelestia update`, relancer `./install.sh` réapplique mes overrides si
Caelestia a redéployé ses propres fichiers.

## Modifier ma config

- **Hyprland** : édite les fichiers dans `hypr/` (voir le mémo Lua dans
  [ARCHITECTURE.md](ARCHITECTURE.md)), puis `hyprctl reload`.
- **Apps** (`config/…`) : les fichiers sont symlinkés, donc toute modif est
  immédiatement active.
- **SDDM** (`config/sddm/conf.d/…`) : après modif, relance `./install.sh` (copie
  vers `/etc`).

## Liens utiles

- Caelestia (upstream) : https://github.com/caelestia-dots/caelestia
- Wiki Hyprland (config) : https://wiki.hypr.land/Configuring/
- Détails techniques de ce dépôt : [ARCHITECTURE.md](ARCHITECTURE.md)
