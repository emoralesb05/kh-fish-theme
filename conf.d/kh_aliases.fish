# Kingdom Hearts themed aliases and functions

# Navigation aliases with KH theme
alias ls='ls -la --color=auto'
alias ll='ls -lh'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

function dive
    echo "🌊 Diving into the depths..."
    set_color '#0066cc'
    echo "╔══════════════════════════════════════════════════════════════╗"
    set_color cyan
    echo "║                    DIVE TO THE HEART                         ║"
    set_color '#0066cc'
    echo "╚══════════════════════════════════════════════════════════════╝"
    set_color normal
    
    # Show system depth information
    set_color '#00aaff'
    echo "🌊 Current Depth: "(pwd)
    set_color normal
    
    # Git status (Kingdom Hearts themed)
    if git rev-parse --git-dir >/dev/null 2>&1
        set_color '#ff00ff'
        echo ""
        echo "╔══════════════════════════════════════════════════════════════╗"
        set_color yellow
        echo "║                    HEART'S MEMORY REPORT                     ║"
        set_color '#ff00ff'
        echo "╚══════════════════════════════════════════════════════════════╝"
        set_color normal
        
        # Branch info
        set_color '#00d7ff'
        echo "🌍 World: "(git symbolic-ref --short HEAD 2>/dev/null)
        set_color normal
        
        # Status summary
        set_color '#00ff9f'
        echo "💫 Memory Fragments: "(git status --porcelain 2>/dev/null | wc -l | string trim)" files changed"
        set_color normal
        
        # Modified files
        set modified_files (git diff --name-only 2>/dev/null)
        if test -n "$modified_files"
            set_color '#ff005f'
            echo "🌑 Corrupted Memories:"
            for file in $modified_files
                echo "    - $file"
            end
            set_color normal
        end
        
        # Staged files
        set staged_files (git diff --cached --name-only 2>/dev/null)
        if test -n "$staged_files"
            set_color '#ffff00'
            echo "🌟 Restored Memories:"
            for file in $staged_files
                echo "    - $file"
            end
            set_color normal
        end
        
        # Stashed files
        echo "🔮 Hidden Memories:"
        git stash list 2>/dev/null | head -3 | while read -l line
            echo "  🔮 $line"
        end
        
        # Untracked files
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
        set_color '#ff005f'
        echo ""
        echo "🌑 No heart's memory found in this realm"
        set_color normal
    end
    
    # Node.js status (Kingdom Hearts themed)
    set_color '#ff00ff'
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    set_color yellow
    echo "║                    MAGIC SYSTEM STATUS                       ║"
    set_color '#ff00ff'
    echo "╚══════════════════════════════════════════════════════════════╝"
    set_color normal
    
    # Global Node.js version
    if command -q node
        set_color '#00d7ff'
        echo "⚡ Node.js: "(node --version 2>/dev/null)
        set_color normal
    end
    
    # Global npm version
    if command -q npm
        set_color '#00ff9f'
        echo "🔥 npm: "(npm --version 2>/dev/null)
        set_color normal
    end
    
    set_color '#0066cc'
    echo ""
    echo "🌊 Dive complete. The heart's secrets revealed..."
    set_color normal
end

# Gummi Ship navigation commands
alias ship='gummi_ship'
alias traverse='gummi_traverse'
alias unlock='gummi_unlock'
alias explore='gummi_explore'
alias home='gummi_return'
alias purify='gummi_purify'


# Magic casting commands
function cast
    if not test -f package.json
        set_color '#ff005f'
        echo "🌑 No spellbook found! (package.json not found)"
        echo "   You must be in a realm with magic to cast spells."
        set_color normal
        return 1
    end
    
    # Detect package manager (prefer pnpm if lockfile exists, otherwise npm)
    set package_manager "npm"
    if test -f pnpm-lock.yaml
        set package_manager "pnpm"
    end
    
    # Check if the script exists in package.json
    set script_name $argv[1]
    if test -n "$script_name"
        set available_scripts (node -e 'console.log(Object.keys(require("./package.json").scripts || {}).join("\n"))' 2>/dev/null)
        if not contains $script_name $available_scripts
            set_color '#ff005f'
            echo "🌑 Spell '$script_name' not found in your spellbook!"
            echo "   Available spells:"
            for script in $available_scripts
                set_color '#00ff9f'
                echo "     🔮 $script"
                set_color normal
            end
            set_color normal
            return 1
        end
    end
    
    $package_manager run $argv
end


