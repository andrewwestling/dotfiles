# Loaded by every zsh invocation (interactive or not, login or not) — this is
# what makes node/npm available to non-interactive tooling (e.g. Conductor
# setup scripts), which never sources .zshrc.

# Some launchers (e.g. Conductor) spawn zsh with a minimal PATH that doesn't
# yet include the standard system dirs, so tools like nvm.sh (which shells
# out to `tr`) fail below. Guarantee the baseline PATH first.
export PATH="/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
