# Kingdom Hearts Fish Theme

# Add functions directory to fish function path
set -g fish_function_path $fish_function_path $__fish_config_dir/functions

# Syntax highlighting colors
set -g fish_color_normal            '#e0e0e0'
set -g fish_color_command           '#00d7ff'
set -g fish_color_param             '#ff00ff'
set -g fish_color_redirection       '#ffff00'
set -g fish_color_comment           '#444466'
set -g fish_color_error             '#ff005f'
set -g fish_color_escape            '#00ffff'
set -g fish_color_operator          '#ff00ff'
set -g fish_color_end               '#00ff9f'
set -g fish_color_quote             '#ffff00'
set -g fish_color_autosuggestion    '#444466'
set -g fish_color_valid_path        '#00ff9f'
set -g fish_color_history_current   '#00d7ff'
set -g fish_color_search_match      '#ffff00'
set -g fish_color_selection         '#222244'

function __fish_git_branch
    # Check if we're in a git repository and it's valid
    if git rev-parse --git-dir >/dev/null 2>&1
        set branch (command git symbolic-ref --short HEAD 2>/dev/null)
        if test -n "$branch"
            set_color '#00ff9f'
            echo -n " 🌍 $branch"
            
            # Git status indicators
            set git_status (git status --porcelain 2>/dev/null)
            if test -n "$git_status"
                set_color '#ff005f'
                echo -n " 󰈈"  # Modified indicator
            else
                set_color '#00ff9f'
                echo -n " 󰗡"  # Clean indicator
            end
            set_color normal
        end
    end
end

function __fish_kingdom_hearts_path
    set_color '#ffff00'
    set current_path (pwd)
    set home_path (echo $HOME)
    set display_path (string replace $home_path "~" $current_path)
    echo -n (string join '/' (string split -r -m 2 '/' $display_path))
    set_color normal
end

function fish_right_prompt
    # Show command duration with Kingdom Hearts styling
    if test $CMD_DURATION
        set_color '#00ff9f'
        echo -n " 󰔛 $CMD_DURATION ms"
    end
    
    # Show current time
    set_color '#ff00ff'
    echo -n " 󰅐 "(date '+%H:%M:%S')
    set_color normal
end

# Enhanced Kingdom Hearts Prompt
function fish_prompt
    # Check status FIRST (before any other commands)
    if test $status -ne 0
        set show_error true
    else
        set show_error false
    end
    # Top line with user info and path
    set_color '#ff00ff'
    echo -n '╭─['
    set_color '#00d7ff'
    echo -n ' 👑 '(whoami)
    set_color '#ff00ff'
    echo -n ']─['
    __fish_kingdom_hearts_path
    __fish_git_branch
    set_color '#ff00ff'
    echo -n ']'
    if test $show_error = true
        set_color '#ff005f'
        echo -n ' 🌑 DARKNESS'
    else
        set_color '#00ff9f'
        echo -n ' ✨ LIGHT'
    end
    echo
    
    # Bottom line with prompt
    set_color '#ff00ff'
    echo -n '╰─'
    set_color '#00d7ff'
    echo -n '🗝️ '
    set_color normal
end

function fish_preexec --on-event fish_preexec
    set -l messages \
        "A NEW JOURNEY BEGINS..." \
        "THE KEYBLADE SHINES BRIGHT..." \
        "UNLOCKING NEW PATHS..." \
        "THE DOOR TO LIGHT OPENS..." \
        "THE HEART’S STRENGTH AWAKENS..." \
        "READY YOURSELF, HERO OF LIGHT..." \
        "THE NEXT CHALLENGE AWAITS..." \
        "STEPPING INTO THE UNKNOWN..." \
        "THE POWER OF FRIENDSHIP GUIDES YOU..." \
        "THE ADVENTURE CONTINUES..." \
        "THE LIGHT WILL GUIDE YOUR WAY..." \
        "THE DESTINED PATH UNFOLDS..." \
        "THE DOOR TO NEW WORLDS UNLOCKS..."
    set -l idx (random 1 (count $messages))
    set -l msg $messages[$idx]
    set -l realm_emoji "🌌"
    set_color cyan
    printf "$msg $realm_emoji\n"
    set_color normal
end

# Optional: Set a cool greeting
set fish_greeting "Welcome back, Keyblade Wielder! 🗝️"

# Load gummi ship functions
source $__fish_config_dir/functions/gummi_ship.fish

# Run Kingdom Hearts welcome on startup
kingdom_hearts_welcome