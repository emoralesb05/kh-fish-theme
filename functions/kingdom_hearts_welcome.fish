function kingdom_hearts_welcome
    echo

    # Title — Station of Awakening style
    set_color $KH_BLUE
    echo '  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'
    set_color $KH_CYAN
    echo '       K I N G D O M   H E A R T S'
    set_color $KH_SLATE
    echo '          Station of Awakening'
    set_color $KH_BLUE
    echo '  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'
    echo

    # Party info
    set_color $KH_GOLD
    echo -n '  Wielder  '
    set_color $KH_WHITE
    echo (whoami)

    set_color $KH_GOLD
    echo -n '  World    '
    set_color $KH_WHITE
    echo (hostname -s 2>/dev/null; or hostname)

    set_color $KH_GOLD
    echo -n '  Time     '
    set_color $KH_WHITE
    echo (date '+%A, %B %d  %H:%M')

    set_color $KH_GOLD
    echo -n '  Journey  '
    set_color $KH_WHITE
    set -l up (uptime | string replace -r '.*up\s+' '' | string replace -r ',\s*\d+ user.*' '' | string trim)
    echo "$up"

    echo

    # Random opening quote
    set -l opening_quotes \
        "I've been having these weird thoughts lately..." \
        "Thinking of you, wherever you are." \
        "A scattered dream that's like a far-off memory..." \
        "Who am I? What am I here for?" \
        "The door is still shut." \
        "Don't be afraid. You hold the mightiest weapon of all." \
        "So much to do, so little time..."

    set -l idx (random 1 (count $opening_quotes))
    set_color $KH_MAUVE
    echo "  \"$opening_quotes[$idx]\""
    set_color normal
    echo

    # Hint
    set_color $KH_SLATE
    echo '  Type `dive` to enter the Station of Awakening'
    set_color normal
    echo
end
