function sanctuary --description "Purify all worlds except the sanctuaries (keep specified branches)"
    set --local keep_branches main develop
    set --local force_delete false
    
    # Parse arguments
    for arg in $argv
        switch $arg
            case -f --force
                set force_delete true
            case '*'
                # Split comma-separated branches and add to keep list
                set --local additional_branches (string split ',' -- $arg)
                for branch in $additional_branches
                    set --local trimmed (string trim -- $branch)
                    if test -n "$trimmed"
                        set --append keep_branches $trimmed
                    end
                end
        end
    end
    
    # Check if we're in a git repository
    if not git rev-parse --git-dir >/dev/null 2>&1
        set_color '#ff005f'
        echo "🌑 No world's heart found! You must be in a git repository."
        set_color normal
        return 1
    end
    
    # Get current branch
    set --local current_branch (git branch --show-current 2>/dev/null)
    
    if test -z "$current_branch"
        set_color '#ff005f'
        echo "🌑 Unable to determine current world!"
        set_color normal
        return 1
    end
    
    # Add current branch to keep list
    set --append keep_branches $current_branch
    
    # Get all local branches
    set --local all_branches (git branch --format='%(refname:short)' 2>/dev/null)
    
    if test -z "$all_branches"
        set_color '#ff005f'
        echo "🌑 No worlds found!"
        set_color normal
        return 1
    end
    
    # Filter branches to delete
    set --local branches_to_delete
    for branch in $all_branches
        if not contains -- $branch $keep_branches
            set --append branches_to_delete $branch
        end
    end
    
    if test (count $branches_to_delete) -eq 0
        set_color '#00ff9f'
        echo "✨ All worlds are already in sanctuary!"
        echo "🌟 Protected worlds: "(string join ', ' -- $keep_branches)
        set_color normal
        return 0
    end
    
    # Show header
    set_color '#ff00ff'
    echo "╔══════════════════════════════════════════════════════════════╗"
    set_color yellow
    echo "║                    SANCTUARY PURIFICATION                    ║"
    set_color '#ff00ff'
    echo "╚══════════════════════════════════════════════════════════════╝"
    set_color normal
    echo ""
    
    # Show what will be deleted
    set_color '#ff005f'
    echo "🌑 Worlds to purify (remove from darkness):"
    for branch in $branches_to_delete
        echo "  💀 $branch"
    end
    set_color normal
    echo ""
    
    # Show what will be kept
    set_color '#00ff9f'
    echo "✨ Sanctuaries (worlds to protect):"
    for branch in $keep_branches
        if test "$branch" = "$current_branch"
            echo "  🌟 $branch (Current World ⭐)"
        else
            echo "  🌟 $branch"
        end
    end
    set_color normal
    echo ""
    
    # Confirm deletion
    set_color '#ffff00'
    echo "⚠️  This will permanently purify these worlds!"
    set_color normal
    read --prompt-str "🗝️  Proceed with purification? [y/N] " --local confirm
    
    if test "$confirm" = "y" -o "$confirm" = "Y"
        set --local delete_flag -d
        if test "$force_delete" = true
            set delete_flag -D
            set_color '#ff005f'
            echo "⚔️  Force purification enabled!"
            set_color normal
        end
        
        echo ""
        set_color '#00d7ff'
        echo "✨ Beginning purification ritual..."
        set_color normal
        
        set --local success_count 0
        set --local failed_count 0
        
        for branch in $branches_to_delete
            if git branch $delete_flag $branch 2>/dev/null
                set_color '#00ff9f'
                echo "  ✨ Purified: $branch"
                set_color normal
                set success_count (math $success_count + 1)
            else
                set_color '#ff005f'
                echo "  🌑 Failed to purify: $branch (use -f/--force to force purification)"
                set_color normal
                set failed_count (math $failed_count + 1)
            end
        end
        
        echo ""
        set_color '#ffff00'
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "✨ Purification complete!"
        echo "   Purified: $success_count world(s)"
        if test $failed_count -gt 0
            echo "   Failed: $failed_count world(s)"
        end
        echo "🌟 Only the sanctuaries remain in the light."
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        set_color normal
    else
        set_color '#ff005f'
        echo "🌑 Purification ritual cancelled. Worlds remain in darkness."
        set_color normal
        return 1
    end
end
