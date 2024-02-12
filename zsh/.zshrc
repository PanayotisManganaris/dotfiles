# configure interactive shell environment and features
# history
HISTFILE=~/.zhistory
HISTSIZE=1000
SAVEHIST=10000

# line editing behavior
bindkey -e
autoload -U select-word-style
select-word-style bash
