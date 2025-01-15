# Set zinit and plugins directory
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

if [ -f /usr/bin/fastfetch ]; then
	fastfetch
fi

# Set zcompdump location
export ZSH_COMPDUMP="$HOME/.cache/zsh/.zcompdump"


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
# zinit light nvbn/thefuck 
# zinit install for thefuck doesn't work
# Functional install commands for thefuck (Python3.11)
# sudo add-apt-repository ppa:deadsnakes/ppa
# sudo apt install python3.11-distutils
# pipx install --python python3.11 thefuck

# Load OMZ snippets (won't work with custom plugins)
zinit snippet OMZP::colored-man-pages
zinit snippet OMZP::cp
zinit snippet OMZP::extract
zinit snippet OMZP::command-not-found # not sure if this is doing anything
# zinit snippet OMZP::sudo

# Load completions
autoload -U compinit && compinit

zinit cdreplay -q

# Shell integrations
export STARSHIP_CONFIG=~/.config/gruvbox_rainbow_zsh.toml

# Set up fzf key bindings and fuzzy completion, fzf needs to be installed separately
source /usr/share/doc/fzf/examples/key-bindings.zsh
source /usr/share/doc/fzf/examples/completion.zsh

# Init zoxide and thefuck
eval "$(zoxide init --cmd cd zsh)"
eval $(thefuck --alias) # running in a Python3.11 venv. seems UNBELIEVABLY slow, not sure if worth using
# works but is so slow, maybe WSL but prolly not worth using

# Keybindings
# bindkey '^f' autosuggest-accept
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
# bindkey -s '\e\e' "fuck --yeah\n" #still prints to terminal

# THE FUCK SETUP
# Create cache directory if it doesn't exist
[[ -d $HOME/.cache/zsh ]] || mkdir -p $HOME/.cache/zsh

# Register alias if cache doesn't exist
[[ ! -a $HOME/.cache/zsh/thefuck ]] && thefuck --alias > $HOME/.cache/zsh/thefuck
source $HOME/.cache/zsh/thefuck

# Define the function #inputs corrected command to CLI, could be modified to auto-execute it without showing
# Additionally, the function's response is fairly slow, could be WSL or old laptop but might not be worth it
fuck-command-line() {
    local FUCK="$(THEFUCK_REQUIRE_CONFIRMATION=0 thefuck $(fc -ln -1 | tail -n 1) 2> /dev/null)"
    [[ -z $FUCK ]] && echo -n -e "\a" && return
    BUFFER=$FUCK
    zle end-of-line
}

# Create the widget and bind keys
zle -N fuck-command-line
bindkey '\e\e' fuck-command-line

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

COMPLETION_WAITING_DOTS="true"

# Init starship as last item
eval "$(starship init zsh)"