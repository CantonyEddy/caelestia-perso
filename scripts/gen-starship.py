#!/usr/bin/env python3
"""Construit le prompt Starship « capsules » pour caelestia — couleurs ANSI.

Les couleurs sont des INDICES DE PALETTE ANSI, pas des hex : caelestia remappe la
palette en direct (séquences OSC). Conséquence : le prompt — ligne active ET
scrollback — se recolore tout seul au changement de scheme, comme le reste du
terminal. Pas besoin de template ni de postHook : un starship.toml STATIQUE
suffit, la dynamique vient de la palette.

Indices utilisés (tous remappés par caelestia) :
  16 = primary, 17 = secondary, 18 = tertiary (les 3 accents du scheme)
  0  = term0 (sombre) -> texte lisible sur les accents clairs (mode sombre)
  1  = red (erreur)
Contrepartie : pas de dégradé tonal d'une seule teinte (la palette n'a que des
couleurs distinctes) — chaque bloc a SA couleur, c'est le but.

Sortie : config/starship.toml (statique), pointé par STARSHIP_CONFIG
(fish/user-config.fish). On ne touche pas au starship.toml géré par caelestia.

Régénère après avoir modifié SYMBOLS / les couleurs / le layout :
  python3 gen-starship.py ; exec fish
"""

from pathlib import Path

# Glyphes Nerd Font (JetBrains Mono Nerd, fournie par caelestia).
SYMBOLS = {
    "os_arch": "",   # nf-linux-archlinux (logo Arch)
    "os_linux": "",  # nf-fa-linux (Tux, fallback)
    "dir": "",       # nf-fa-folder (dossier)
    "git": "",       # nf-dev-git_branch (branche)
    "duration": "",  # nf-fa-hourglass_end (duree)
    "time": "",      # nf-fa-clock_o (heure)
    "prompt": "❯",    # ❯
}
CAP_L = ""   # nf-pl-left_soft_divider  (demi-cercle gauche)
CAP_R = ""   # nf-pl-right_soft_divider (demi-cercle droit)

# Couleurs = indices de palette ANSI remappés par caelestia (recolore en direct).
C1 = "18"   # tertiary  — blocs "extérieurs" (OS, heure)
C2 = "16"   # primary   — blocs "milieu" (dossier, branche, status = ancre)
C3 = "17"   # secondary — blocs "centre" (durée, git status)
TXT = "0"   # texte sombre (term0) sur les accents clairs
OK = "17"   # ❯ succès
ERR = "1"   # ❯ erreur (red)
VIM = "16"  # ❯ mode vi


def build() -> str:
    S = SYMBOLS
    fmt = "$os$directory$cmd_duration$fill$status$git_status$git_branch$time$line_break$character"

    return f"""# GÉNÉRÉ par scripts/gen-starship.py — ne pas éditer à la main (édite le script).
# Couleurs ANSI (indices de palette remappés par caelestia) -> le prompt se
# recolore en direct au changement de scheme, scrollback inclus. Pas de dégradé
# tonal (palette = couleurs distinctes) : chaque bloc a sa couleur.

add_newline = false
continuation_prompt = "[▸▹ ](dimmed white)"

format = "{fmt}"

[fill]
symbol = "═"
style = "fg:{C2}"

[character]
success_symbol = "[{S['prompt']}](bold {OK})"
error_symbol = "[{S['prompt']}](bold {ERR})"
vimcmd_symbol = "[{S['prompt']}](bold {VIM})"

# ── Gauche : OS(C1) → dossier(C2) → durée(C3), capsule connectée ──
[os]
disabled = false
format = "[{CAP_L}](fg:{C1})[ $symbol ](fg:{TXT} bg:{C1})"
[os.symbols]
Arch = "{S['os_arch']}"
Linux = "{S['os_linux']}"

[directory]
home_symbol = "~"
truncation_length = 3
truncation_symbol = "…/"
read_only = " "
use_os_path_sep = true
format = "[{CAP_R}](fg:{C1} bg:{C2})[ {S['dir']} $path$read_only ](fg:{TXT} bg:{C2})"

[cmd_duration]
min_time = 0
show_milliseconds = true
format = "[{CAP_R}](fg:{C2} bg:{C3})[ {S['duration']} $duration ](fg:{TXT} bg:{C3})[{CAP_R}](fg:{C3})"

# ── Droite : (status(git_status(branch+logo(heure) — status = ancre (C2) ──
[status]
disabled = false
format = "[{CAP_L}](fg:{C2})[ $symbol$maybe_int ](fg:{TXT} bg:{C2})"
success_symbol = "✓"
symbol = "✗ "

[git_status]
format = "[{CAP_L}](fg:{C3} bg:{C2})[ $all_status$ahead_behind ](fg:{TXT} bg:{C3})"
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
format = "[{CAP_L}](fg:{C2} bg:{C3})[ {S['git']} $branch ](fg:{TXT} bg:{C2})"
symbol = ""
truncation_length = 20
truncation_symbol = "…"

[time]
disabled = false
format = "[{CAP_L}](fg:{C1} bg:{C2})[ {S['time']} $time ](fg:{TXT} bg:{C1})[{CAP_R}](fg:{C1})"
time_format = "%R"
utc_time_offset = "local"
"""


def main() -> int:
    out = Path(__file__).resolve().parent.parent / "config" / "starship.toml"
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(build())
    print(f"écrit : {out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
