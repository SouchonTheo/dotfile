source /usr/share/cachyos-fish-config/cachyos-config.fish
set -gx PATH "$HOME/.local/bin" $PATH

set -gx EDITOR nvim
set -gx VISUAL nvim

alias v="nvim"
# remote hosts rarely know the ghostty terminfo
alias ssh="env TERM=xterm-256color ssh"
zoxide init fish | source
# Ctrl+R = historique, Ctrl+T = fichiers, Alt+C = cd
if type -q fzf
  fzf --fish | source
end
# env par projet (.envrc) — pacman -S direnv
if type -q direnv
  direnv hook fish | source
end

# pnpm
set -gx PNPM_HOME "/home/theo/.local/share/pnpm"
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end

# ZVM
set -gx ZVM_INSTALL "$HOME/.zvm/self"
set -gx PATH $PATH "$HOME/.zvm/bin"
set -gx PATH $PATH "$ZVM_INSTALL/"
