# Loaded by every zsh invocation (interactive or not, login or not) — this is
# what makes node/npm available to non-interactive tooling (e.g. Conductor
# setup scripts), which never sources .zshrc.

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
