# bash-completion
[ -f /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion

# bash-git-prompt
if [ -f "/usr/local/opt/bash-git-prompt/share/gitprompt.sh" ]; then
  __GIT_PROMPT_DIR="/usr/local/opt/bash-git-prompt/share"
  source "/usr/local/opt/bash-git-prompt/share/gitprompt.sh"
fi

# thefuck
eval $(thefuck --alias)

################################################################################
# Shortcuts
alias chrome="open -a 'Google Chrome'"
alias github="open -a 'GitHub Desktop'"
alias subl="open -a 'Sublime Text'"
################################################################################
