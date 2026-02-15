# Save Point — KH-themed git stash push
function save --description "Save progress at a Save Point (git stash)"
    if not command git rev-parse --git-dir >/dev/null 2>&1
        set_color $KH_RED
        echo "🌑 No world found! You must be in a git repository to save."
        set_color normal
        return 1
    end

    set -l message "Save Point"
    if test (count $argv) -gt 0
        set message (string join ' ' -- $argv)
    end

    set_color $KH_CYAN
    echo "💾 Saving progress..."
    set_color normal

    if command git stash push -m "$message" 2>/dev/null
        set_color $KH_GREEN
        echo "✨ Progress saved at Save Point!"
        set_color $KH_ICY
        echo "   📋 \"$message\""
        set_color $KH_SLATE
        echo "   Use 'load' to restore your progress."
        set_color normal
    else
        set_color $KH_GOLD
        echo "🌟 Nothing to save! Your progress is already up to date."
        set_color normal
    end
end
