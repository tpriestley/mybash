# Navigation
alias home='cd ~'
alias cd..='cd ..'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

#Listing
alias ls='ls --color=auto'
alias l='ls -A'
alias la='ls -lh'
alias ll='ls -lAh'
alias lsa='ls -lah'

alias cat='batcat'
alias grep='grep --color=auto'
alias md='mkdir -p'
alias rd='rmdir'
alias da='date "+%Y-%m-%d %A %T %Z"'
alias ping='ping -c 10'
alias cls='clear'
alias bd='cd "$OLDPWD"'
alias f="find . | grep "

# chmod commands
alias mx='chmod a+x'
alias 000='chmod -R 000'
alias 600='chmod -R 600'
alias 644='chmod -R 644'
alias 666='chmod -R 666'
alias 755='chmod -R 755'
alias 777='chmod -R 777'