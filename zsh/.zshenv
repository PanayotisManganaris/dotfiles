declare -U PATH path
declare -U FPATH fpath

if [ -d "$HOME/.local/bin" ]; then
    export PATH="$HOME/.local/bin:$PATH"
fi
