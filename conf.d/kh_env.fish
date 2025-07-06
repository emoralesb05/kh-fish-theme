# Kingdom Hearts Environment Variables

# Editor preferences
set -gx EDITOR 'nano'
set -gx VISUAL 'nano'
set -gx PAGER 'less'

# Language and locale
set -gx LANG 'en_US.UTF-8'
set -gx LC_ALL 'en_US.UTF-8'

# Fish specific settings
set -g fish_greeting ''
set -g fish_autosuggestion_enabled 1
set -g fish_autosuggestion_highlight_color '#444466'

# Development environment
set -gx GOPATH "$HOME/go"
set -gx PATH "$GOPATH/bin" $PATH

# Kingdom Hearts terminal settings
set -gx TERM 'xterm-256color'
set -gx CLICOLOR 1
set -gx LSCOLORS 'ExGxBxDxCxEgEdxbxgxcxd'

# Network and security
set -gx SSH_AUTH_SOCK "$HOME/.ssh/agent.sock"
set -gx GPG_TTY (tty)

# Custom paths for Kingdom Hearts tools
set -gx PATH "$HOME/.local/bin" $PATH
set -gx PATH "$HOME/.npm-global/bin" $PATH

# Add missing paths for iTerm2 compatibility
set -gx PATH "/opt/homebrew/bin" $PATH
set -gx PATH "/opt/homebrew/sbin" $PATH
set -gx PATH "/usr/local/bin" $PATH
set -gx PATH "$HOME/.asdf/shims" $PATH
set -gx PATH "$HOME/.asdf/bin" $PATH

# FZF settings for Kingdom Hearts theme (if installed later)
# set -gx FZF_DEFAULT_OPTS '--height 40% --layout=reverse --border --color=fg:#e0e0e0,bg:#000000,hl:#00ff9f,fg+:#ffffff,bg+:#222244,hl+:#00d7ff,info:#ff00ff,prompt:#ffff00,pointer:#ff005f,marker:#00ffff,spinner:#ff00ff,header:#444466'

# Z settings for smart directory jumping (if installed later)
# set -gx _Z_DATA "$HOME/.z"
# set -gx _Z_CMD 'z'

# Git settings
set -gx GIT_PAGER 'less -R'
set -gx GIT_EDITOR 'nano'

# Docker settings
set -gx DOCKER_BUILDKIT 1
set -gx COMPOSE_DOCKER_CLI_BUILD 1

# Python settings
set -gx PYTHONUNBUFFERED 1
set -gx PIP_DISABLE_PIP_VERSION_CHECK 1

# Custom Kingdom Hearts variables
set -gx KINGDOM_HEARTS_MODE 'enabled'
set -gx KINGDOM_HEARTS_THEME 'active' 