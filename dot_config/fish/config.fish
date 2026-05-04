source /usr/share/cachyos-fish-config/cachyos-config.fish
export PATH="$HOME/.local/bin:$PATH"
set -gx EDITOR nvim
set -gx VISUAL nvim

# overwrite greeting
# potentially disabling fastfetch
#function fish_greeting
#    # smth smth
#end

alias v="nvim"
zoxide init fish | source

# pnpm
set -gx PNPM_HOME "/home/theo/.local/share/pnpm"
if not string match -q -- $PNPM_HOME $PATH
    set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end
