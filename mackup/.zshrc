# zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_DISABLE_COMPFIX=true
ZSH_THEME="robbyrussell"
plugins=(git)
source $ZSH/oh-my-zsh.sh

# Homebrew
[ -s "/opt/homebrew/bin/brew" ] && eval "$(/opt/homebrew/bin/brew shellenv)" # (Apple Silicon)

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"

# Add Postgres.app CLI tools to path
path+=('/Applications/Postgres.app/Contents/Versions/latest/bin')

# Aliases
alias chrome="open -a 'Google Chrome'"
alias brewme="sudo chown -R $USER $(brew --prefix)"

# asdf
. /opt/homebrew/opt/asdf/asdf.sh
