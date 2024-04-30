# configure interactive shell environment and features
# history
HISTFILE=~/.zhistory
HISTSIZE=1000
SAVEHIST=10000

# line editing behavior
bindkey -e
autoload -U select-word-style
select-word-style bash

# session-specific variables
export GPG_TTY=$(tty)
export EDITOR=ec

# options
unsetopt beep

if [[ -x $commands[direnv] ]]; then
    eval "$(direnv hook zsh)"
fi
