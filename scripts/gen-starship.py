#!/usr/bin/env python3
"""Construit le prompt Starship « capsules » pour caelestia.

⚠️ Outil de BUILD (pas de runtime). Il produit deux fichiers depuis UNE seule
définition de layout :

  1. config/caelestia-templates/starship.toml  → le TEMPLATE caelestia, avec des
     placeholders `{{ role.hex }}`. Symlinké dans ~/.config/caelestia/templates/
     par install.sh. caelestia le rend vers ~/.local/state/caelestia/theme/
     starship.toml à CHAQUE changement de scheme (propagation native, live).
  2. config/starship.toml  → un FALLBACK statique (mêmes capsules, couleurs par
     défaut caelestia figées), utilisé si le fichier rendu n'existe pas encore.

Les couleurs viennent DIRECTEMENT des rôles Material You de caelestia (pas
d'interpolation) : le dégradé bord→centre = rôles tonals du primary
  onPrimary (foncé) → primaryContainer (moyen) → primary (clair).
N'utiliser QUE des rôles de base (présents dans le scheme dynamique) : les rôles
*Fixed n'existent que dans le scheme statique → placeholder non remplacé → cassé.
Quand le wallpaper change, caelestia régénère la palette : le dégradé suit.

Usage : python3 gen-starship.py        # écrit les deux fichiers dans le repo
Régénère après avoir modifié SYMBOLS, les rôles (ROLES) ou le layout.
"""

from __future__ import annotations

from pathlib import Path

# ─────────────────────────── Réglages ───────────────────────────

# Glyphes Nerd Font (JetBrains Mono Nerd, fournie par caelestia).
SYMBOLS = {
    "os_arch": "\uf303",   # nf-linux-archlinux (logo Arch)
    "os_linux": "\uf17c",  # nf-fa-linux (Tux, fallback)
    "dir": "\uf07b",       # nf-fa-folder (dossier)
    "git": "\ue725",       # nf-dev-git_branch (branche)
    "duration": "\uf252",  # nf-fa-hourglass_end (duree)
    "time": "\uf017",      # nf-fa-clock_o (heure)
    "bat_full": "\uf240",       # nf-fa-battery_full
    "bat_charging": "\uf0e7",   # nf-fa-bolt (en charge)
    "bat_discharging": "\uf242",# nf-fa-battery_half
    "bat_low": "\uf244",        # nf-fa-battery_empty
    "user": "\uf007",           # nf-fa-user
    "prompt": "\u276f",    # ❯
}
CAP_L = "\ue0b6"   # nf-pl-left_soft_divider  (demi-cercle gauche)
CAP_R = "\ue0b4"   # nf-pl-right_soft_divider (demi-cercle droit)

# Rôles caelestia (Material You) pour le dégradé bord(foncé)→centre(clair).
# IMPORTANT : uniquement des rôles M3 « de base » présents dans le scheme DYNAMIQUE
# (les *Fixed n'existent que dans le scheme statique → placeholder non remplacé →
# couleur invalide → segment cassé). En mode sombre : onPrimary(foncé) <
# primaryContainer(moyen) < primary(clair) par luminosité.
ROLES = {
    "c1": "onPrimary",          # segment foncé (bords : OS, heure)
    "c2": "primaryContainer",   # segment moyen (dossier, branche)
    "c3": "primary",            # segment clair (durée, git status : centre)
    "t1": "onPrimaryContainer", # texte sur c1 (clair)
    "t2": "onPrimaryContainer", # texte sur c2 (clair)
    "t3": "onPrimary",          # texte sur c3 (foncé)
    "ok": "primary",            # ❯ succès
    "err": "error",             # ❯ erreur
    "vim": "primaryContainer",  # ❯ mode vi
}

# Palette par défaut caelestia (hypr/scheme/default.lua) pour le fallback figé.
# Ne mettre QUE des rôles utilisés par ROLES (rôles de base, présents partout).
DEFAULT_HEX = {
    "onPrimary": "2a2a60",
    "primaryContainer": "7171ac",
    "primary": "c2c1ff",
    "onPrimaryContainer": "ffffff",
    "error": "ffb4ab",
}


# ─────────────────────────── Rendu ───────────────────────────

def _colour(role: str, mode: str) -> str:
    """Renvoie la couleur d'un rôle : placeholder template ou hex figé."""
    if mode == "template":
        return "#{{ " + role + ".hex }}"
    return "#" + DEFAULT_HEX[role]


def build(mode: str) -> str:
    def c(key: str) -> str:
        return _colour(ROLES[key], mode)

    c1, c2, c3 = c("c1"), c("c2"), c("c3")
    t1, t2, t3 = c("t1"), c("t2"), c("t3")
    ok, err, vim = c("ok"), c("err"), c("vim")
    S = SYMBOLS

    header = (
        "# TEMPLATE caelestia — rendu par `apply_user_templates` à chaque scheme."
        if mode == "template"
        else "# FALLBACK statique (couleurs par défaut caelestia) si le rendu manque."
    )

    # Ligne 1 : gauche + $fill (espace extensible) + droite ; ❯ en ligne 2.
    fmt = "$os$directory$cmd_duration$fill$username$git_status$git_branch$time$line_break$character"

    return f"""{header}
# GÉNÉRÉ par scripts/gen-starship.py — ne pas éditer à la main (édite le script).
# Capsules connectées, dégradé bord(foncé)→centre(clair) via rôles Material You.

add_newline = false
continuation_prompt = "[▸▹ ](dimmed white)"

format = "{fmt}"

[fill]
symbol = " "

[character]
success_symbol = "[{S['prompt']}](bold {ok})"
error_symbol = "[{S['prompt']}](bold {err})"
vimcmd_symbol = "[{S['prompt']}](bold {vim})"

# ── Gauche : OS(c1 foncé) → dossier(c2) → durée(c3 clair) ──
[os]
disabled = false
format = "[{CAP_L}](fg:{c1})[ $symbol ](fg:{t1} bg:{c1})"
[os.symbols]
Arch = "{S['os_arch']}"
Linux = "{S['os_linux']}"

[directory]
home_symbol = "~"
truncation_length = 3
truncation_symbol = "…/"
read_only = " "
use_os_path_sep = true
format = "[{CAP_R}](fg:{c1} bg:{c2})[ {S['dir']} $path$read_only ](fg:{t2} bg:{c2})"

[cmd_duration]
min_time = 0
format = "[{CAP_R}](fg:{c2} bg:{c3})[ {S['duration']} $duration ](fg:{t3} bg:{c3})[{CAP_R}](fg:{c3})"

# ── Droite : (user(status(branch+logo(heure) en dépôt, (user(heure) sinon ──
# Chaque segment « mord » dans le précédent : CAP_L, SA couleur SUR le fond du
# précédent. username = ANCRE permanente (c2, même couleur que la branche) → le
# `(` de jonction de l'heure (c1 sur c2) est STATIQUE et marche dans les 2 cas.
# git_status/git_branch sont optionnels (disparaissent hors dépôt).
[git_status]
format = "[{CAP_L}](fg:{c3} bg:{c2})[ $all_status$ahead_behind ](fg:{t3} bg:{c3})"
conflicted = "!"
ahead = "⇡$count"
behind = "⇣$count"
diverged = "⇕⇡$ahead_count⇣$behind_count"
untracked = "?"
stashed = "≡"
modified = "●"
staged = "+$count"
renamed = "»"
deleted = "✘"

[git_branch]
only_attached = false
format = "[{CAP_L}](fg:{c2} bg:{c3})[ {S['git']} $branch ](fg:{t2} bg:{c2})"
symbol = ""
truncation_length = 20
truncation_symbol = "…"

# username : ANCRE permanente (show_always). Couleur branche (c2) → jonction
# statique de l'heure (voir plus haut). Remplace l'ancienne ancre batterie.
[username]
show_always = true
format = "[{CAP_L}](fg:{c2})[ {S['user']} $user ](fg:{t2} bg:{c2})"
[time]
disabled = false
format = "[{CAP_L}](fg:{c1} bg:{c2})[ {S['time']} $time ](fg:{t1} bg:{c1})[{CAP_R}](fg:{c1})"
time_format = "%R"
utc_time_offset = "local"
"""


def main() -> int:
    repo = Path(__file__).resolve().parent.parent
    targets = {
        "template": repo / "config" / "caelestia-templates" / "starship.toml",
        "fallback": repo / "config" / "starship.toml",
    }
    for mode, path in targets.items():
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(build(mode))
        print(f"écrit : {path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
