# caelestia-perso

Mes modifs perso par-dessus [caelestia-dots](https://github.com/caelestia-dots/caelestia),
**sans jamais toucher à leur repo**. Tout passe par les fichiers d'override que
Caelestia source déjà dans `~/.config/caelestia/`.

## Arborescence

```
hypr-vars.conf            # variables (apps, keybinds, gaps…) — lu par Caelestia
hypr-user.conf            # AIGUILLEUR : source la sous-arbo user/ (lu par Caelestia)
user/                     # mes overrides Hyprland, découpés par thème
├── env.conf
├── general.conf
├── input.conf            # clavier FR, touchpad (déjà rempli)
├── misc.conf
├── animations.conf
├── decoration.conf
├── group.conf
├── execs.conf
├── rules.conf
├── gestures.conf
├── keybinds.conf
└── scrolling.conf
user-config.fish          # alias/env/fonctions fish — lu par Caelestia
shell.json                # config Quickshell complète — lu par le shell
monitors/<écran>/shell.json  # surcharges par écran (vides par défaut)
```

## Pourquoi un aiguilleur ?

Caelestia ne source QUE `hypr-vars.conf` et `hypr-user.conf` pour tes overrides.
Recréer leur arbo `hyprland/*.conf` côté caelestia ne servirait à rien : ces
fichiers-là sont lus depuis `~/.config/hypr/hyprland/`, pas ici.

Donc `hypr-user.conf` ne contient que des `source = …/user/*.conf` (ordre
explicite). Tu obtiens la même découpe thématique que l'original, via le seul
point d'entrée que Caelestia accepte de lire.

L'ordre des `source` compte : les dernières déclarations gagnent.

## Ce qui ne se découpe pas

- `shell.json` : un seul JSON (+ per-monitor). Le shell ne lit pas de
  sous-fichiers thématiques.
- `scheme/` et `scripts/` : internes à Caelestia, vivent dans `~/.config/hypr/`,
  pas ici — les recréer côté perso n'a aucun effet.

## Installation

```sh
git clone <ton-repo> ~/.local/share/caelestia-perso
~/.local/share/caelestia-perso/install.sh
hyprctl reload
```

L'installeur sauvegarde tout existant en `.bak-<date>` avant de symlinker, et
ne refait rien si le lien est déjà bon. Le dossier `user/` est symlinké en
entier : ajouter un `.conf` dedans ne nécessite pas de relancer le script
(mais pense à l'ajouter dans `hypr-user.conf` puis `hyprctl reload`).

## Override d'un keybind existant

- Bind via variable (`$kbTerminal`… voir leur `variables.conf`) :
  redéfinis la variable dans `hypr-vars.conf`.
- Bind posé en dur : `unbind` puis `bind` dans `user/keybinds.conf`.
