# Enable case-insensitive and substring/partial completion (from earlier)
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' menu select

# Your custom aliases
alias ls="eza"
alias server-rebuild="nh os switch -H server --target-host root@server"

# Hook direnv if you use it
eval "$(direnv hook zsh)"

# Initialize starship prompt if you still want it
eval "$(starship init zsh)"

# Install zinit if not present
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [ ! -d "$ZINIT_HOME" ]; then
    mkdir -p "$(dirname $ZINIT_HOME)"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "$ZINIT_HOME/zinit.zsh"

# Load zsh-autosuggestions (ghost text)
zinit light zsh-users/zsh-autosuggestions

# Load syntax highlighting (optional but recommended)
zinit light zsh-users/zsh-syntax-highlighting
