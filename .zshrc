# Dependencies: zsh, fastfetch, starship, zoxide, fzf
# Symbolic links need to be placed in:
# ~/.config/starships/[THEME_NAME].toml #one for each theme
# ~/.config/.aliases
# ~/.zshrc

# Set zcompdump location
export ZSH_COMPDUMP="${HOME}/.cache/zsh/.zcompdump"

# Set zinit and plugins directory
ZINIT_HOME="${HOME}/.local/share/zinit/zinit.git"

# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

if [ -f /usr/bin/fastfetch ]; then
	fastfetch
fi

# Download zinit if not installed
if [[ ! -d $ZINIT_HOME ]]; then
    mkdir -p "$(dirname $ZINIT_HOME)"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/load zinit
source "${ZINIT_HOME}/zinit.zsh"
# Removes built-in zi alias
unalias zi 2>/dev/null

# Load plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab
zinit light djui/alias-tips

# Load OMZ snippets
zinit snippet OMZP::colored-man-pages
zinit snippet OMZP::cp
zinit snippet OMZP::extract
zinit snippet OMZP::command-not-found # not sure if this is doing anything
zinit snippet OMZP::sudo

# Load completions
autoload -Uz compinit && compinit

zinit cdreplay -q

# Shell integrations
# Change starship prompt theme here
export STARSHIP_CONFIG=~/.config/starships/pure_minimalist.toml

# Set up fzf key bindings and fuzzy completion, fzf needs to be installed separately
source /usr/share/doc/fzf/examples/key-bindings.zsh
source /usr/share/doc/fzf/examples/completion.zsh

# Init zoxide
eval "$(zoxide init --cmd cd zsh)"

# Keybindings
# bindkey -L to show all existing key bindings
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

# History
HISTSIZE=5000
HISTFILE=~/.cache/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_dups
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' menu no
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:z:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:zi:*' fzf-preview 'ls --color $realpath'

# Aliases
source $HOME/.config/.aliases

export VISUAL='nano'
export EDITOR=$VISUAL


# Functions

# utilizes zsh's chpwd (which is called after a succesful directory change) to execute the ls command
chpwd() {
		ls
}

# Create and go to directory
mkdirg() {
	mkdir -p "$1"
	cd "$1"
}

# Show the current version of the operating system
ver() {
	local dtype
	dtype=$(distribution)

	case $dtype in
		"redhat")
			if [ -s /etc/redhat-release ]; then
				cat /etc/redhat-release
			else
				cat /etc/issue
			fi
			uname -a
			;;
		"suse")
			cat /etc/SuSE-release
			;;
		"debian")
			lsb_release -a
			;;
		"gentoo")
			cat /etc/gentoo-release
			;;
		"arch")
			cat /etc/os-release
			;;
		"slackware")
			cat /etc/slackware-version
			;;
		*)
			if [ -s /etc/issue ]; then
				cat /etc/issue
			else
				echo "Error: Unknown distribution"
				exit 1
			fi
			;;
	esac
}

COMPLETION_WAITING_DOTS="true" # Unsure if this works without oh-my-zsh

# Init starship as last item
eval "$(starship init zsh)"