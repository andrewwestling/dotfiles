# zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_DISABLE_COMPFIX=true
ZSH_THEME="robbyrussell"
plugins=(git)
source $ZSH/oh-my-zsh.sh

# Homebrew
[ -s "/opt/homebrew/bin/brew" ] && eval "$(/opt/homebrew/bin/brew shellenv)" # (Apple Silicon)

# Aliases
alias chrome="open -a 'Google Chrome'"
alias brewme="sudo chown -R $USER $(brew --prefix)"

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
