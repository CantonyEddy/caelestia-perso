# ~/.config/caelestia/user-config.fish
# Sourcé à la fin de config.fish de Caelestia.
# Tes alias, abbr, env, fonctions perso.
# alias e "yazi"
alias w "wiki-tui"
alias lj "lazyjournal"
alias lg "lazygit"
alias h "tldr"
alias d "gdu"
alias install "sudo pacman -S"
alias install-aur "paru -S"
alias update "sudo pacman -Syu && paru -Syu"
alias v "nvim"

# --- Variables d'environnement ---
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
