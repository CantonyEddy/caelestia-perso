# caelestia-perso

Mes modifs perso par-dessus [caelestia-dots](https://github.com/caelestia-dots/caelestia),
**sans jamais toucher à leur repo**. Tout passe par les fichiers d'override que
Caelestia source déjà dans `~/.config/caelestia/`.

## Comment ça marche

Caelestia source ces fichiers (que tu possèdes, pas eux) :

| Fichier dans `~/.config/caelestia/` | Sourcé par | Usage |
|---|---|---|
| `hypr-vars.conf` | `hypr/hyprland.conf` | Redéfinir variables (apps, keybinds, gaps, blur…) |
| `hypr-user.conf` | `hypr/hyprland.conf` (en dernier) | Input, binds, règles, exec-once, monitors |
| `user-config.fish` | `fish/config.fish` (en dernier) | Alias, abbr, env, fonctions fish |
| `shell.json` | shell Quickshell | Barre, apparence, wallpaper, widgets |
| `monitors/<écran>/shell.json` | shell Quickshell | Surcharges par écran (vides par défaut) |

Leurs fichiers ne sont jamais modifiés → `git pull` chez eux reste propre à vie.

## Contenu déjà repris de ma config

- `hypr-user.conf` : clavier FR, numlock, repeat rate, touchpad naturel.
- `shell.json` : config complète de la barre / launcher / services.
- `monitors/eDP-1` et `monitors/HDMI-A-1` : vides, prêts à surcharger par écran.

## Installation

```sh
git clone <ton-repo> ~/.local/share/caelestia-perso
~/.local/share/caelestia-perso/install.sh
hyprctl reload
```

L'installeur sauvegarde tout fichier existant en `.bak-<date>` avant de
symlinker, et ne refait rien si le lien est déjà bon.

## Override d'un keybind existant

- S'il utilise une variable (`$kbTerminal`, etc. — voir leur `variables.conf`) :
  redéfinis la variable dans `hypr-vars.conf`.
- S'il est posé en dur : `unbind` puis `bind` dans `hypr-user.conf`.
