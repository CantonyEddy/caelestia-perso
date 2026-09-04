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
# Prompt Starship perso « capsules ». Les couleurs viennent de la propagation
# NATIVE de caelestia : le template ~/.config/caelestia/templates/starship.toml
# est rendu par caelestia vers ~/.local/state/caelestia/theme/starship.toml à
# chaque changement de scheme. On pointe STARSHIP_CONFIG dessus (fallback sur la
# version statique versionnée si le rendu n'existe pas encore).
set -l _cp_state (test -n "$XDG_STATE_HOME"; and echo $XDG_STATE_HOME; or echo $HOME/.local/state)
set -l _cp_theme $_cp_state/caelestia/theme/starship.toml
if test -f "$_cp_theme"
    set -gx STARSHIP_CONFIG "$_cp_theme"
else
    set -gx STARSHIP_CONFIG $HOME/.local/share/caelestia-perso/config/starship.toml
end
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
