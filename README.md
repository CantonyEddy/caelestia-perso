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

Matrice complète ci-dessous. **★ = perso** (override ou ajout de ce dépôt) ; le
reste est le **défaut Caelestia**. Les raccourcis sont donnés tels qu'on les tape
en **AZERTY (`fr`)**.

### La couche HYPER (Caps Lock)

Caps Lock a un **double rôle** (via keyd) :

- **appui bref** → Verr.Maj normal ;
- **maintenu + une touche** → raccourci de la couche « HYPER » (touches
  additionnelles envoyées en F13+ par keyd, donc sans conflit avec les applis).

### Applications & lanceurs

Certaines apps vivent dans un **special workspace** (`— ws` ci-dessous) : un seul
raccourci les **lance** si absentes, sinon **affiche/cache** leur fenêtre.

| Raccourci | Action | |
|-----------|--------|---|
| `SUPER+T` | Terminal (foot) | |
| `SUPER+W` | Navigateur (zen-browser) | ★ |
| `SUPER+C` | Éditeur (zed) | ★ |
| `SUPER+E` | Explorateur de fichiers (thunar) | |
| `SUPER+G` | Steam — ws | ★ |
| `SUPER+O` | Obsidian — ws | ★ |
| `HYPER+C` | Claude — ws | ★ |
| `HYPER+T` | Thunderbird — ws | ★ |
| `HYPER+S` | Signal — ws | ★ |
| `HYPER+A` | KeePassXC — ws | ★ |
| `HYPER+N` | zennotes | ★ |
| `HYPER+K` | Aide-mémoire des raccourcis (cette fiche) | ★ |
| `SUPER+D` | Discord (vesktop) | ★ |
| `SUPER+M` | Spotify | ★ |
| `SUPER+;` | Sélecteur d'emoji | ★ |
| `SUPER+V` | Presse-papiers (historique) | |
| `SUPER+Alt+V` | Presse-papiers (supprimer une entrée) | |
| `Ctrl+Alt+V` | Réglages audio (pavucontrol) | |

### Fenêtres — focus & déplacement

| Raccourci | Action | |
|-----------|--------|---|
| `SUPER + ←/→/↑/↓` | Déplacer le focus (direction) | |
| `SUPER+Shift + ←/→/↑/↓` | Déplacer la fenêtre (direction) | |
| `SUPER + clic gauche` glisser · `SUPER+Z` | Déplacer la fenêtre (souris) | |
| `SUPER + clic droit` glisser · `SUPER+X` | Redimensionner (souris) | |

### Fenêtres — taille & état

Touches AZERTY : `)` = à droite de `à` · `=` = bout de rangée · `*` = à droite de `ù`.

| Raccourci | Action | |
|-----------|--------|---|
| `SUPER + )` / `SUPER + =` | Largeur − / + | ★ (−) |
| `SUPER+Shift + )` / `SUPER+Shift + =` | Hauteur − / + | ★ (−) |
| `SUPER+Alt + ←/→/↑/↓` | Redimensionner (flèches) | |
| `Ctrl+Super + *` | Centrer la fenêtre | ★ |
| `Ctrl+Super+Alt + *` | Redim. 55×70 % + centrer | ★ |
| `SUPER+Alt + *` | Picture-in-picture | ★ |
| `SUPER+P` | Épingler (pin) | |
| `SUPER+F` | Plein écran | |
| `SUPER+Alt+F` | Plein écran bordé | |
| `SUPER+Alt+Espace` | Basculer flottant | |
| `SUPER+Q` | Fermer la fenêtre | |

Le `−`/`\*`/PiP sont **rebindés par keycode** pour rester joignables en AZERTY
(le `\` d'origine de Caelestia = `AltGr+8`, inatteignable).

### Groupes de fenêtres (onglets)

| Raccourci | Action | |
|-----------|--------|---|
| `SUPER+,` | Créer / dissoudre un groupe | |
| `SUPER + HYPER + ←/→/↑/↓` | Fusionner dans le groupe voisin (le crée si besoin) | ★ |
| `SUPER + Tab` / `SUPER+Shift+Tab` | Onglet suivant / précédent | ★ |
| `SUPER+U` | Sortir la fenêtre du groupe | |
| `SUPER+Shift+,` | Verrouiller le groupe (stoppe l'ajout auto) | |
| `Alt+Tab` · `Ctrl+Alt+Tab` | Cycler (défaut Caelestia) | |

### Bureaux (workspaces)

Rebindés **par keycode** (rangée du haut) → mêmes touches physiques en AZERTY et QWERTY.

| Raccourci | Action | |
|-----------|--------|---|
| `SUPER + 1…0` | Aller au bureau | ★ |
| `SUPER+Alt + 1…0` | Envoyer la fenêtre au bureau | ★ |
| `Ctrl+Super + 1…0` | Aller au groupe de bureaux | ★ |
| `Ctrl+Super+Alt + 1…0` | Envoyer la fenêtre au groupe | ★ |
| `Ctrl+Super + ←/→` | Bureau précédent / suivant | |
| `SUPER + molette` | Bureau − / + | |
| `SUPER+Alt + Pg↑/Pg↓` | Envoyer la fenêtre bureau − / + | |
| `Ctrl+Super+Shift + ↑/↓` | Envoyer vers special / vider | |

### Special workspaces (bascules)

| Raccourci | Action | |
|-----------|--------|---|
| `SUPER+S` | Scratchpad générique | |
| `SUPER+B` | Moniteur système (défaut : `Ctrl+Shift+Échap`) | ★ |
| `SUPER+R` | Todo | |

### Captures & enregistrement

| Raccourci | Action | |
|-----------|--------|---|
| `Impr.écran` | Capture | |
| `SUPER+Shift+S` | Capture (gel de l'écran) | |
| `SUPER+Shift+Alt+S` | Capture (sélection) | |
| `SUPER+Shift+C` | Pipette de couleur | |
| `Ctrl+Alt+R` | Enregistrer l'écran | |
| `SUPER+Alt+R` | Enregistrer (avec son) | |
| `SUPER+Shift+Alt+R` | Enregistrer (région) | |

### Shell & système

| Raccourci | Action | |
|-----------|--------|---|
| `SUPER` (appui bref) | Launcher | |
| `SUPER+N` | Barre latérale (sidebar) | |
| `SUPER+K` | Afficher les panneaux | |
| `SUPER+L` | Verrouiller la session | |
| `SUPER+Alt+L` | Restaurer le verrou | |
| `Ctrl+Alt+Suppr` | Menu de session | |
| `Ctrl+Alt+C` | Effacer les notifications | |
| `SUPER+Shift+L` | Veille | |
| `SUPER+Shift+M` | Couper le son | |
| `Ctrl+Super+Espace` | Média lecture/pause | |
| `Ctrl+Super + =` / `Ctrl+Super + )` | Média suivant / précédent | ★ (préc.) |
| `SUPER+I` | Anti-veille (idle inhibit) | ★ |
| `Ctrl+Super+Shift+R` | Tuer le shell | |
| `Ctrl+Super+Alt+R` | Relancer le shell caelestia | |

> **Caveat AZERTY connu** : `SUPER+6` (bureau 6) déclenche aussi le rétrécissement,
> et `Ctrl+Super+6` (groupe 6) le média précédent — car en AZERTY la touche `6`
> émet le keysym `-` utilisé par Caelestia. Non corrigé à ce jour.

### Aide-mémoire des raccourcis (`HYPER+K`)

`HYPER+K` ouvre une **cheat-sheet** de tous les raccourcis dans une fenêtre
flottante centrée (55×70 %), avec une **barre de recherche** (fzf) pour filtrer.
C'est purement informatif : `Échap` (ou `Entrée`) referme la fenêtre.

- la liste vit dans [`scripts/keybinds.tsv`](scripts/keybinds.tsv)
  (format `CATÉGORIE <TAB> TOUCHES <TAB> action`) et s'affiche **groupée par catégories**
  (en-têtes colorés) — pour l'éditer, il suffit de modifier ce fichier ;
- fond **translucide + flou** de Caelestia, comme le terminal (aucun override d'alpha) ;
- le rendu est fait par [`scripts/keybinds-menu.sh`](scripts/keybinds-menu.sh) (foot + fzf) ;
- une window rule dans `hypr/user/rules.lua` **flotte + centre** la fenêtre (app-id
  `caelestia-keybinds`), et le script fixe la **taille** à 55×70 % du moniteur focus
  via `foot --window-size-pixels` (les tailles en % de la window rule ne passent pas
  ici de façon fiable). keyd envoie `K` de la couche HYPER en `F23`.
- les **couleurs** de fzf sont en **indices ANSI** (pas en hex), comme le prompt
  Starship : caelestia remappe la palette en direct, donc le menu **se recolore**
  avec le scheme (ton wallpaper).

Dépend de **fzf** et **jq** (ajoutés aux dépendances d'`install.sh`) et de foot
(fourni par Caelestia).

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
