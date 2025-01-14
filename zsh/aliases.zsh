# need to optimize the ls commands, doesnt work with zoxide
alias ezsh='edit ~/.zshrc'
alias ls='ls -lah --color=tty'
alias cat='batcat'
alias da='date "+%Y-%m-%d %A %T %Z"'
alias ping='ping -c 10'
alias cls='clear'
alias bd='cd "$OLDPWD"'
alias f="find . | grep "

# alias chmod commands
alias mx='chmod a+x'
alias 000='chmod -R 000'
alias 600='chmod -R 600'
alias 644='chmod -R 644'
alias 666='chmod -R 666'
alias 755='chmod -R 755'
alias 777='chmod -R 777'