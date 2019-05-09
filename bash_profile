# PATH things (Homebrew, pyenv)
export PATH=/usr/local/bin:/usr/local/sbin:$PATH:$HOME/.pyenv/bin

# bash-completion
[ -f /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion

# bash-git-prompt
if [ -f "/usr/local/opt/bash-git-prompt/share/gitprompt.sh" ]; then
  __GIT_PROMPT_DIR="/usr/local/opt/bash-git-prompt/share"
  source "/usr/local/opt/bash-git-prompt/share/gitprompt.sh"
fi

# rbenv
eval "$(rbenv init -)"

# pyenv
eval "$(pyenv init -)"

# Go
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

################################################################################
# Shortcuts
alias chrome="open -a 'Google Chrome'"
alias subl="open -a 'Sublime Text'"
alias lsm="source ~/.virtualenvs/lifestack.me/bin/activate && cd ~/Code/lifestack.me"
################################################################################
