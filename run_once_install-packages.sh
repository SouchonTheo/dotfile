#!/bin/bash
# Bootstrap: install user packages on a fresh CachyOS machine.
# Runs once per machine via chezmoi.
# Idempotent: --needed skips already-installed packages.

set -euo pipefail

paru -S --needed --noconfirm \
    `# Browsers & comms` \
    brave-bin signal-desktop vesktop \
    `# Terminal & CLI` \
    ghostty lazygit yazi btop ripgrep zoxide chezmoi \
    `# Editors` \
    neovim obsidian \
    `# Dev` \
    docker docker-compose claude-code \
    `# Media` \
    mpv obs-studio kdenlive ffmpegthumbnailer gpu-screen-recorder \
    `# Office` \
    libreoffice-still \
    `# Fonts (AUR)` \
    maplemono-nf
