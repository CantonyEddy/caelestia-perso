# ~/.config/caelestia/user-config.fish
# Sourcé à la fin de config.fish de Caelestia.
# Tes alias, abbr, env, fonctions perso.
# alias e "yazi"
alias w "wiki-tui"
alias lj "lazyjournal"
alias lg "lazygit"
alias h "tldr"
alias d "gdu"
alias i "paru -S"
alias u "caelestia update"
alias v "nvim"

# --- Variables d'environnement ---
# Prompt Starship perso « capsules », en couleurs ANSI : caelestia remappe la
# palette en direct, donc le prompt (ligne active ET scrollback) se recolore tout
# seul au changement de scheme. Config STATIQUE versionnée, pointée par
# STARSHIP_CONFIG. On ne touche pas au starship.toml géré par caelestia.
set -gx STARSHIP_CONFIG $HOME/.local/share/caelestia-perso/config/starship.toml
# set -gx EDITOR nvim
# set -gx PATH $HOME/.local/bin $PATH

# --- Abréviations / alias ---
# abbr v nvim
# abbr dc 'docker compose'

# --- Fonctions ---
# function mkcd
#     mkdir -p $argv[1] && cd $argv[1]
# end

function e
	set tmp (mktemp -t "yazi-cwd.XXXXXX")
	command yazi $argv --cwd-file="$tmp"
	if read -z cwd < "$tmp"; and [ "$cwd" != "$PWD" ]; and test -d "$cwd"
		builtin cd -- "$cwd"
	end
	command rm -f -- "$tmp"
end
