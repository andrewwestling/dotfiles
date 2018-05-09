# bash-completion
[ -f /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion

# bash-git-prompt
if [ -f "/usr/local/opt/bash-git-prompt/share/gitprompt.sh" ]; then
  __GIT_PROMPT_DIR="/usr/local/opt/bash-git-prompt/share"
  source "/usr/local/opt/bash-git-prompt/share/gitprompt.sh"
fi

# rbenv
eval "$(rbenv init -)"

# thefuck
eval $(thefuck --alias)

# Yarn
export PATH="$PATH:$(yarn global bin)"

# Go
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

################################################################################
# Shortcuts
alias chrome="open -a 'Google Chrome'"
alias subl="open -a 'Sublime Text'"
alias dcp="docker-compose"
alias lsm="source ~/.virtualenvs/lifestack.me/bin/activate && cd ~/Code/lifestack.me"
################################################################################
