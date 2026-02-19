function gummi_ship
    set_color '#ff00ff'
    echo "╔══════════════════════════════════════════════════════════════╗"
    set_color yellow
    echo "║                    GUMMI SHIP NAVIGATOR                      ║"
    set_color '#ff00ff'
    echo "╚══════════════════════════════════════════════════════════════╝"
    set_color normal
    
    # Check if we're in a git repository
    if not git rev-parse --git-dir >/dev/null 2>&1
        set_color '#ff005f'
        echo "🌑 No world's heart found! You must be in a git repository to traverse worlds."
        set_color normal
        return 1
    end
    
    # Show current world
    set_color '#00d7ff'
    echo "🌍 Current World: "(git symbolic-ref --short HEAD 2>/dev/null)
    set_color normal
    
    # Show available worlds
    set_color '#00ff9f'
    echo "🗺️ Available Worlds:"
    git branch | while read -l branch
        set branch_name (echo $branch | string replace '*' '' | string trim)
        if echo $branch | grep -q '^\*'
            set_color '#ffff00'
            echo "  🌍 $branch_name (Current ⭐)"
        else
            set_color '#00ff9f'
            echo "  🌍 $branch_name"
        end
        set_color normal
    end
    set_color normal
    
    # Show navigation options
    echo ""
    set_color '#ff69b4'
    echo "🚀 Navigation Commands:"
    echo "  gummi_traverse / traverse <world>    - Travel to a specific world"
    echo "  gummi_unlock / unlock <world>        - Unlock a new world (create branch)"
    echo "  gummi_explore / explore              - Explore current world's status"
    echo "  gummi_return / home                  - Return to main world (main/master)"
    echo "  sanctuary <branches>                 - Purify all worlds except specified branches"
    set_color normal
end

function gummi_traverse
    if test (count $argv) -eq 0
        set_color '#ff005f'
        echo "🌑 Please specify a world to traverse to!"
        echo "Usage: gummi_traverse <branch_name>"
        set_color normal
        return 1
    end
    
    set target_world $argv[1]
    
    # Check if we're in a git repository
    if not git rev-parse --git-dir >/dev/null 2>&1
        set_color '#ff005f'
        echo "🌑 No world's heart found! You must be in a git repository."
        set_color normal
        return 1
    end
    
    set_color '#00d7ff'
    echo "🚀 Preparing Gummi Ship for traversal..."
    set_color normal
    
    # Check if branch exists locally
    if git show-ref --verify --quiet refs/heads/$target_world
        set_color '#00ff9f'
        echo "🌟 World found! Traversing to $target_world..."
        set_color normal
        
        if git checkout $target_world
            set_color '#ffff00'
            echo "✨ Successfully arrived at world: $target_world"
            set_color normal
            
            # Show world status
            gummi_explore
        else
            set_color '#ff005f'
            echo "🌑 Failed to traverse to world: $target_world"
            set_color normal
        end
    else
        # Check if branch exists remotely
        if git show-ref --verify --quiet refs/remotes/origin/$target_world
            set_color '#00ffff'
            echo "🌌 Remote world detected! Creating local connection..."
            set_color normal
            
            if git checkout -b $target_world origin/$target_world
                set_color '#ffff00'
                echo "✨ Successfully traversed to remote world: $target_world"
                set_color normal
                
                # Show world status
                gummi_explore
            else
                set_color '#ff005f'
                echo "🌑 Failed to traverse to remote world: $target_world"
                set_color normal
            end
        else
            set_color '#ff005f'
            echo "🌑 World '$target_world' not found in known realms!"
            echo "Use 'gummi_unlock $target_world' to unlock this new world."
            set_color normal
        end
    end
end

function gummi_unlock
    if test (count $argv) -eq 0
        set_color '#ff005f'
        echo "🌑 Please specify a world name to unlock!"
        echo "Usage: gummi_unlock <new_branch_name>"
        set_color normal
        return 1
    end
    
    set new_world $argv[1]
    
    # Check if we're in a git repository
    if not git rev-parse --git-dir >/dev/null 2>&1
        set_color '#ff005f'
        echo "🌑 No world's heart found! You must be in a git repository."
        set_color normal
        return 1
    end
    
    set_color '#ff00ff'
    echo "🗝️ Unlocking new world: $new_world"
    set_color normal
    
    # Check if branch already exists
    if git show-ref --verify --quiet refs/heads/$new_world
        set_color '#ff005f'
        echo "🌑 World '$new_world' already exists!"
        set_color normal
        return 1
    end
    
    # Create and switch to new branch
    if git checkout -b $new_world
        set_color '#ffff00'
        echo "✨ New world '$new_world' unlocked successfully!"
        echo "🌟 You are now in the newly discovered realm."
        set_color normal
        
        # Show world status
        gummi_explore
    else
        set_color '#ff005f'
        echo "🌑 Failed to unlock world: $new_world"
        set_color normal
    end
end

function gummi_explore
    # Check if we're in a git repository
    if not git rev-parse --git-dir >/dev/null 2>&1
        set_color '#ff005f'
        echo "🌑 No world's heart found! You must be in a git repository."
        set_color normal
        return 1
    end
    
    set_color '#ff00ff'
    echo "╔══════════════════════════════════════════════════════════════╗"
    set_color yellow
    echo "║                    WORLD EXPLORATION                         ║"
    set_color '#ff00ff'
    echo "╚══════════════════════════════════════════════════════════════╝"
    set_color normal
    
    # Current world info
    set_color '#00d7ff'
    echo "🌍 Current World: "(git symbolic-ref --short HEAD 2>/dev/null)
    set_color normal
    
    # World status
    set git_status (git status --porcelain 2>/dev/null)
    if test -n "$git_status"
        set_color '#ff005f'
        echo "🌑 World Status: Corrupted (has uncommitted changes)"
        set_color normal
        
        # Show modified files
        set modified_files (git diff --name-only 2>/dev/null)
        if test -n "$modified_files"
            set_color '#ff005f'
            echo "🌑 Corrupted Memories:"
            for file in $modified_files
                echo "    - $file"
            end
            set_color normal
        end
        
        # Show staged files
        set staged_files (git diff --cached --name-only 2>/dev/null)
        if test -n "$staged_files"
            set_color '#ffff00'
            echo "🌟 Restored Memories:"
            for file in $staged_files
                echo "    - $file"
            end
            set_color normal
        end
        
        # Show untracked files
        set untracked_files (git ls-files --others --exclude-standard 2>/dev/null)
        if test -n "$untracked_files"
            set_color '#ff00ff'
            echo "💎 New Discoveries:"
            for file in $untracked_files
                echo "    - $file"
            end
            set_color normal
        end
    else
        set_color '#00ff9f'
        echo "✨ World Status: Pure (no uncommitted changes)"
        set_color normal
    end
    
    # Recent commits
    set_color '#00ffff'
    echo "📜 Recent World History:"
    git log --oneline -2 2>/dev/null | while read -l commit
        echo "  📖 $commit"
    end
    set_color normal
end

function gummi_return
    # Check if we're in a git repository
    if not git rev-parse --git-dir >/dev/null 2>&1
        set_color '#ff005f'
        echo "🌑 No world's heart found! You must be in a git repository."
        set_color normal
        return 1
    end
    
    set_color '#00d7ff'
    echo "🏠 Returning to main world..."
    set_color normal
    
    # Try to find main branch (KH_HOME_BRANCH overrides auto-detect)
    if test -n "$KH_HOME_BRANCH"
        if git show-ref --verify --quiet "refs/heads/$KH_HOME_BRANCH"
            set main_branch "$KH_HOME_BRANCH"
        else
            set_color '#ff005f'
            echo "🌑 No main world found! ($KH_HOME_BRANCH branch does not exist)"
            set_color normal
            return 1
        end
    else if git show-ref --verify --quiet refs/heads/main
        set main_branch "main"
    else if git show-ref --verify --quiet refs/heads/master
        set main_branch "master"
    else
        set_color '#ff005f'
        echo "🌑 No main world found! (main or master branch)"
        set_color normal
        return 1
    end
    
    if git checkout $main_branch
        set_color '#ffff00'
        echo "✨ Successfully returned to main world: $main_branch"
        set_color normal
        
        # Show world status
        gummi_explore
    else
        set_color '#ff005f'
        echo "🌑 Failed to return to main world"
        set_color normal
    end
end

