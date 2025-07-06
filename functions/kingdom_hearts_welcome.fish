function kingdom_hearts_welcome
    set_color '#ffd700'
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                  KINGDOM HEARTS TERMINAL 👑                  ║"
    echo "║            May your heart be your guiding key!               ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    set_color normal
    echo
    set_color '#00bfff'
    echo "  🗝️  WIELDER: "(whoami)
    set_color '#ffff00'
    echo "  ⏰  TIME: "(date '+%Y-%m-%d %H:%M:%S')
    set_color '#00ff9f'
    set uptime_info (uptime | sed 's/.*up \([^,]*\), .*/\1/')
    if test -n "$uptime_info"
        echo "  💫  JOURNEY: $uptime_info"
    else
        echo "  💫  JOURNEY: Unknown"
    end
    set_color normal
    echo
    set_color '#00bfff'
    echo "  Type 'dive' to enter the Station of Awakening!"
    set_color normal
    echo
end 