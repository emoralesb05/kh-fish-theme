# Load Save Point — KH-themed git stash pop/apply/list
function load --description "Load saved progress (git stash pop/apply/list)"
    if not command git rev-parse --git-dir >/dev/null 2>&1
        set_color $KH_RED
        echo "🌑 No world found! You must be in a git repository to load."
        set_color normal
        return 1
    end

    switch "$argv[1]"
        case list
            # Show all save points
            set_color $KH_BLUE
            echo ' ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'
            set_color $KH_CYAN
            echo '         SAVE POINTS'
            set_color $KH_BLUE
            echo ' ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'
            echo

            set -l stashes (command git stash list 2>/dev/null)
            if test -z "$stashes"
                set_color $KH_SLATE
                echo "  No save points found."
                echo "  Use 'save' or 'save \"message\"' to create one."
                set_color normal
                return
            end

            set -l idx 0
            for stash in $stashes
                set_color $KH_GOLD
                echo -n "  [$idx] "
                set_color $KH_ICY
                echo "💾 $stash"
                set idx (math $idx + 1)
            end
            set_color normal
            echo

        case ''
            # No arguments: pop latest stash
            set -l stash_count (command git stash list 2>/dev/null | wc -l | string trim)
            if test "$stash_count" -eq 0
                set_color $KH_SLATE
                echo "💾 No save points to load."
                set_color normal
                return 1
            end

            set_color $KH_CYAN
            echo "💾 Loading save data..."
            set_color normal

            if command git stash pop
                set_color $KH_GREEN
                echo "✨ Progress restored! Continue your journey."
                set_color normal
            else
                set_color $KH_RED
                echo "🌑 Failed to load save data! There may be conflicts."
                set_color normal
                return 1
            end

        case '*'
            # Numeric argument: apply specific stash
            if string match -qr '^\d+$' -- "$argv[1]"
                set -l stash_idx $argv[1]

                # Validate index exists
                set -l stash_count (command git stash list 2>/dev/null | wc -l | string trim)
                if test "$stash_idx" -ge "$stash_count"
                    set_color $KH_RED
                    echo "🌑 Save point #$stash_idx not found! Only $stash_count save points exist."
                    set_color normal
                    return 1
                end

                set_color $KH_CYAN
                echo "💾 Loading save point #$stash_idx..."
                set_color normal

                if command git stash apply "stash@{$stash_idx}"
                    set_color $KH_GREEN
                    echo "✨ Save point #$stash_idx restored!"
                    set_color normal
                else
                    set_color $KH_RED
                    echo "🌑 Failed to load save point #$stash_idx!"
                    set_color normal
                    return 1
                end
            else
                set_color $KH_RED
                echo "🌑 Unknown command: $argv[1]"
                set_color normal
                echo
                set_color $KH_SLATE
                echo "   Usage:"
                set_color $KH_ICY
                echo "     load           — restore latest save"
                echo "     load list      — list all save points"
                echo "     load <number>  — restore specific save"
                set_color normal
                return 1
            end
    end
end
