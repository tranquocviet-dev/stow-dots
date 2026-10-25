# Enable case-insensitive and substring/partial completion (from earlier)
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' menu select


# Where to save the history file
HISTFILE=~/.zsh_history

# Number of commands to keep in memory (history command)
HISTSIZE=10000

# Number of commands to save in the history file
SAVEHIST=10000

# Share history between multiple active terminal sessions
setopt SHARE_HISTORY

# Append to history file rather than overwriting it completely
setopt APPEND_HISTORY

# Write the history file in the format : start:elapsed;command
setopt EXTENDED_HISTORY

# Expel duplicate lines from history
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS

# Do not store history lines that start with a space (useful for sensitive commands)
setopt HIST_IGNORE_SPACE

# Remove superfluous blanks from each command line being added to the history list
setopt HIST_REDUCE_BLANKS

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

zinit light zsh-users/zsh-completions

