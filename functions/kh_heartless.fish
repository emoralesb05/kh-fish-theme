# Kingdom Hearts Heartless Encounters
# Themed error feedback when commands fail

# ── Session Initialization ──
function __fish_kh_heartless_init
    if not set -q __kh_heartless_defeated
        set -g __kh_heartless_defeated 0
    end
    if not set -q __kh_heartless_log
        set -g __kh_heartless_log
    end
end

# ── Post-Exec Heartless Encounter ──
function __fish_kh_heartless_encounter --on-event fish_postexec
    set -l exit_code $status

    # Skip if disabled or command succeeded
    if test "$KH_HEARTLESS" = 'false'
        return
    end
    if test $exit_code -eq 0
        return
    end

    set -l heartless_name ''
    set -l heartless_emoji ''
    set -l heartless_flavor ''
    set -l heartless_color $KH_RED

    switch $exit_code
        case 1
            set heartless_name "Shadow"
            set heartless_emoji "🖤"
            set heartless_flavor "A Shadow appeared!"
        case 2
            set heartless_name "Soldier"
            set heartless_emoji "⚔️"
            set heartless_flavor "A Soldier heartless attacks!"
        case 126
            set heartless_name "Large Body"
            set heartless_emoji "🛡️"
            set heartless_flavor "A Large Body blocks your path!"
        case 127
            set heartless_name "Darkside"
            set heartless_emoji "🌑"
            set heartless_flavor "Darkside rises from the darkness!"
        case 130
            set heartless_name "Invisible"
            set heartless_emoji "💨"
            set heartless_flavor "You fled from the Invisible!"
            set heartless_color $KH_GOLD
        case 137
            set heartless_name "Behemoth"
            set heartless_emoji "🦏"
            set heartless_flavor "A Behemoth crushed your process!"
        case 139
            set heartless_name "Guard Armor"
            set heartless_emoji "💀"
            set heartless_flavor "Guard Armor tore through memory!"
        case '*'
            set -l pool "Neoshadow" "Wyvern" "Wizard" "Defender" "Angel Star" "Crimson Jazz"
            set -l pool_emoji "🖤" "🐉" "🧙" "🛡️" "⭐" "🔴"
            set -l idx (random 1 (count $pool))
            set heartless_name $pool[$idx]
            set heartless_emoji $pool_emoji[$idx]
            set heartless_flavor "A $heartless_name heartless appeared! [exit $exit_code]"
    end

    # Track encounter
    set -g __kh_heartless_defeated (math $__kh_heartless_defeated + 1)
    set -g --append __kh_heartless_log "$heartless_name"

    # Display encounter
    set_color $heartless_color
    echo -n "  $heartless_emoji "
    set_color $KH_WHITE --bold
    echo -n "$heartless_name"
    set_color $heartless_color
    echo " — $heartless_flavor"
    set_color normal
end

# ── Heartless Stats Command ──
function heartless --description "Show heartless encounter stats for this session"
    set_color $KH_BLUE
    echo ' ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'
    set_color $KH_CYAN
    echo '     HEARTLESS ENCOUNTER LOG'
    set_color $KH_BLUE
    echo ' ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'
    echo

    set_color $KH_GOLD
    echo -n '  Encounters: '
    set_color $KH_WHITE
    echo $__kh_heartless_defeated

    if test (count $__kh_heartless_log) -gt 0
        echo
        set_color $KH_ICY
        echo '  Defeated:'

        # Tally each unique heartless type
        set -l unique_types
        for entry in $__kh_heartless_log
            if not contains -- "$entry" $unique_types
                set -a unique_types "$entry"
            end
        end

        for htype in $unique_types
            set -l hcount 0
            for entry in $__kh_heartless_log
                if test "$entry" = "$htype"
                    set hcount (math $hcount + 1)
                end
            end
            set_color $KH_RED
            echo -n "    $htype"
            set_color $KH_SLATE
            echo " x$hcount"
        end
    else
        echo
        set_color $KH_GREEN
        echo '  No heartless encountered yet. The light is strong!'
    end

    set_color normal
    echo
end
