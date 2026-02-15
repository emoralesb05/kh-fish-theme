# Kingdom Hearts HUD Helper Functions
# Centralized git data, gauge bars, party members, world detection

# ── Git Data Gatherer ──
# Runs ONCE per prompt cycle. Both fish_prompt and fish_right_prompt read from these globals.
function __fish_kh_git_data
    # Reset all globals
    set -g __kh_git_is_repo 0
    set -g __kh_git_branch ''
    set -g __kh_git_ahead 0
    set -g __kh_git_behind 0
    set -g __kh_git_staged 0
    set -g __kh_git_modified 0
    set -g __kh_git_untracked 0
    set -g __kh_git_conflicts 0
    set -g __kh_git_stash_count 0
    set -g __kh_git_dirty_total 0
    set -g __kh_git_files_changed 0
    set -g __kh_git_dirs_touched 0

    # Check if we're in a git repo
    if not command git rev-parse --git-dir >/dev/null 2>&1
        return
    end
    set -g __kh_git_is_repo 1

    # Branch name
    set -g __kh_git_branch (command git symbolic-ref --short HEAD 2>/dev/null)
    if test -z "$__kh_git_branch"
        set -g __kh_git_branch (command git rev-parse --short HEAD 2>/dev/null)
        if test -n "$__kh_git_branch"
            set -g __kh_git_branch "($__kh_git_branch)"
        end
    end

    # Ahead/behind
    set -l counts (command git rev-list --left-right --count HEAD...@{upstream} 2>/dev/null)
    if test -n "$counts"
        set -l parts (string split \t -- $counts)
        if test (count $parts) -ge 2
            set -g __kh_git_ahead $parts[1]
            set -g __kh_git_behind $parts[2]
        end
    end

    # Working tree status (parse porcelain output once)
    set -l porcelain (command git status --porcelain 2>/dev/null)
    set -l dirs
    set -l file_count 0

    for line in $porcelain
        set -l x (string sub -l 1 -- "$line")
        set -l y (string sub -s 2 -l 1 -- "$line")
        set -l filepath (string sub -s 4 -- "$line")

        # Count by type
        if test "$x" = "U" -o "$y" = "U" -o "$x$y" = "AA" -o "$x$y" = "DD"
            set -g __kh_git_conflicts (math $__kh_git_conflicts + 1)
        else if test "$x" = "?"
            set -g __kh_git_untracked (math $__kh_git_untracked + 1)
        else
            if test "$x" != " " -a "$x" != "?"
                set -g __kh_git_staged (math $__kh_git_staged + 1)
            end
            if test "$y" != " "
                set -g __kh_git_modified (math $__kh_git_modified + 1)
            end
        end

        # Track files and directories for MP calculation
        set file_count (math $file_count + 1)
        set -l dir (string replace -r '/[^/]*$' '' -- "$filepath")
        if test -n "$dir" -a "$dir" != "$filepath"
            if not contains -- "$dir" $dirs
                set -a dirs "$dir"
            end
        end
    end

    set -g __kh_git_files_changed $file_count
    set -g __kh_git_dirs_touched (count $dirs)
    set -g __kh_git_dirty_total (math $__kh_git_modified + $__kh_git_untracked + $__kh_git_conflicts)

    # Stash count
    set -g __kh_git_stash_count (command git stash list 2>/dev/null | wc -l | string trim)
end

# ── Git Info Renderer ──
# Reads cached globals, outputs colored branch/status text
function __fish_kh_git_prompt
    if test "$__kh_git_is_repo" -ne 1
        return
    end

    # Branch name
    set_color $KH_CYAN
    echo -n " $__kh_git_branch"

    # Ahead/behind
    if test "$__kh_git_ahead" -gt 0 2>/dev/null
        set_color $KH_GOLD
        echo -n " ↑$__kh_git_ahead"
    end
    if test "$__kh_git_behind" -gt 0 2>/dev/null
        set_color $KH_MAUVE
        echo -n " ↓$__kh_git_behind"
    end

    # Working tree status
    if test "$__kh_git_dirty_total" -gt 0 -o "$__kh_git_staged" -gt 0
        if test "$__kh_git_staged" -gt 0
            set_color $KH_GREEN
            echo -n " +$__kh_git_staged"
        end
        if test "$__kh_git_modified" -gt 0
            set_color $KH_RED
            echo -n " ~$__kh_git_modified"
        end
        if test "$__kh_git_untracked" -gt 0
            set_color $KH_GOLD
            echo -n " ?$__kh_git_untracked"
        end
        if test "$__kh_git_conflicts" -gt 0
            set_color $KH_RED
            echo -n " !$__kh_git_conflicts"
        end
    else
        set_color $KH_GREEN
        echo -n " ✓"
    end

    # Stash count
    if test "$__kh_git_stash_count" -gt 0
        set_color $KH_MAUVE
        echo -n " ≡$__kh_git_stash_count"
    end

    set_color normal
end

# ── Bar Renderer ──
# Renders a colored gauge bar: LABEL ████████░░
function __fish_kh_render_bar --argument-names label pct color_high color_mid color_low
    set -l width $KH_BAR_WIDTH
    if test "$COLUMNS" -lt 100 2>/dev/null
        set width 6
    end

    # Clamp pct to 0-100
    if test "$pct" -lt 0 2>/dev/null
        set pct 0
    end
    if test "$pct" -gt 100 2>/dev/null
        set pct 100
    end

    # Calculate filled blocks
    set -l filled (math "round($pct * $width / 100)")

    # Select color based on percentage
    set -l bar_color $color_high
    if test "$pct" -le 30
        set bar_color $color_low
    else if test "$pct" -le 60
        set bar_color $color_mid
    end

    # Render label
    set_color $bar_color
    echo -n "$label "

    # Render filled portion
    set_color $bar_color
    set -l i 0
    while test $i -lt $filled
        echo -n '█'
        set i (math $i + 1)
    end

    # Render empty portion
    set_color $KH_SLATE
    set -l empty (math $width - $filled)
    set i 0
    while test $i -lt $empty
        echo -n '░'
        set i (math $i + 1)
    end

    set_color normal
end

# ── HP Level: Repo Cleanliness ──
function __fish_kh_hp_level
    if test "$__kh_git_is_repo" -ne 1
        echo 100
        return
    end

    set -l penalty (math "$__kh_git_modified * 8 + $__kh_git_untracked * 4 + $__kh_git_conflicts * 20 + $__kh_git_staged * 2")
    set -l hp (math "max(0, 100 - $penalty)")
    echo $hp
end

# ── Drive Level: Commits Ahead / WIP Pressure ──
function __fish_kh_drive_level
    if test "$__kh_git_is_repo" -ne 1
        echo 0
        return
    end

    set -l drive (math "min($__kh_git_ahead, 10) * 10")
    echo $drive
end

# ── MP Level: Branch Focus / Change Spread ──
function __fish_kh_mp_level
    if test "$__kh_git_is_repo" -ne 1
        echo 100
        return
    end

    if test "$__kh_git_files_changed" -eq 0
        echo 100
        return
    end

    set -l spread (math "$__kh_git_dirs_touched * 6 + $__kh_git_files_changed * 2")
    set -l mp (math "max(0, 100 - $spread)")
    echo $mp
end

# ── Context-Sensitive 4th Menu Slot ──
function __fish_kh_4th_slot
    if test "$__kh_git_is_repo" -ne 1
        set -g __kh_4th_slot_color $KH_MAUVE
        echo 'Summon'
        return
    end

    if test "$__kh_git_dirty_total" -gt 0 -o "$__kh_git_staged" -gt 0
        set -g __kh_4th_slot_color $KH_GOLD
        echo 'Save'
        return
    end

    if test "$__kh_git_ahead" -gt 0
        set -g __kh_4th_slot_color $KH_CYAN
        echo 'Drive'
        return
    end

    set -g __kh_4th_slot_color $KH_WHITE
    echo 'Defend'
end

# ── Dynamic Menu Cursor Position ──
# Collects all applicable menu rows and randomly picks one each prompt.
# The ♥ cursor feels alive — shifting between relevant actions.
function __fish_kh_menu_cursor
    set -l candidates

    # Attack is always an option
    set -a candidates 1

    # Magic: when in a project with scripts
    if test -f package.json
        set -a candidates 2
    end

    # Items: when stashes exist
    if test "$__kh_git_is_repo" -eq 1
        if test "$__kh_git_stash_count" -gt 0
            set -a candidates 3
        end
    end

    # 4th slot: Save/Drive/Defend based on state
    if test "$__kh_git_is_repo" -eq 1
        if test "$__kh_git_dirty_total" -gt 0 -o "$__kh_git_staged" -gt 0
            set -a candidates 4  # Save
        end
        if test "$__kh_git_ahead" -gt 0
            set -a candidates 4  # Drive
        end
        if test "$__kh_git_behind" -gt 0
            set -a candidates 4  # Defend
        end
    end

    # Deduplicate (4 could be added multiple times)
    set -l unique
    for c in $candidates
        if not contains -- $c $unique
            set -a unique $c
        end
    end

    # Random pick from applicable options
    set -l idx (random 1 (count $unique))
    echo $unique[$idx]
end

# ── Party Members: Runtime Detection ──
function __fish_kh_party_members
    if test "$KH_SHOW_PARTY" = 'false'
        return
    end

    # Cache per directory
    if test "$PWD" = "$__kh_party_cache_dir"
        echo $__kh_party_cache_result
        return
    end

    set -l members

    # Node.js
    if test -f package.json -o -f .nvmrc -o -f .node-version
        set -l ver ''
        if test "$__kh_node_path_cache" != (command -v node 2>/dev/null)
            set -g __kh_node_path_cache (command -v node 2>/dev/null)
            set -g __kh_node_ver_cache (command node --version 2>/dev/null | string replace 'v' '')
        end
        if test -n "$__kh_node_ver_cache"
            set -a members "Node $__kh_node_ver_cache"
        end
    end

    # Python
    if test -f requirements.txt -o -f pyproject.toml -o -f setup.py -o -f Pipfile -o -f .python-version
        if test "$__kh_python_path_cache" != (command -v python3 2>/dev/null)
            set -g __kh_python_path_cache (command -v python3 2>/dev/null)
            set -g __kh_python_ver_cache (command python3 --version 2>/dev/null | string replace 'Python ' '')
        end
        if test -n "$__kh_python_ver_cache"
            set -a members "Python $__kh_python_ver_cache"
        end
    end

    # Go
    if test -f go.mod
        if test "$__kh_go_path_cache" != (command -v go 2>/dev/null)
            set -g __kh_go_path_cache (command -v go 2>/dev/null)
            set -g __kh_go_ver_cache (command go version 2>/dev/null | string replace -r '.*go(\S+).*' '$1')
        end
        if test -n "$__kh_go_ver_cache"
            set -a members "Go $__kh_go_ver_cache"
        end
    end

    # Rust
    if test -f Cargo.toml
        if test "$__kh_rust_path_cache" != (command -v rustc 2>/dev/null)
            set -g __kh_rust_path_cache (command -v rustc 2>/dev/null)
            set -g __kh_rust_ver_cache (command rustc --version 2>/dev/null | string replace -r 'rustc (\S+).*' '$1')
        end
        if test -n "$__kh_rust_ver_cache"
            set -a members "Rust $__kh_rust_ver_cache"
        end
    end

    # Java
    if test -f pom.xml -o -f build.gradle -o -f build.gradle.kts
        if test "$__kh_java_path_cache" != (command -v java 2>/dev/null)
            set -g __kh_java_path_cache (command -v java 2>/dev/null)
            set -g __kh_java_ver_cache (command java --version 2>/dev/null | head -1 | string replace -r '.*"(\S+)".*' '$1' | string replace -r '.* (\S+)$' '$1')
        end
        if test -n "$__kh_java_ver_cache"
            set -a members "Java $__kh_java_ver_cache"
        end
    end

    # Ruby
    if test -f Gemfile
        if test "$__kh_ruby_path_cache" != (command -v ruby 2>/dev/null)
            set -g __kh_ruby_path_cache (command -v ruby 2>/dev/null)
            set -g __kh_ruby_ver_cache (command ruby --version 2>/dev/null | string replace -r 'ruby (\S+).*' '$1')
        end
        if test -n "$__kh_ruby_ver_cache"
            set -a members "Ruby $__kh_ruby_ver_cache"
        end
    end

    # Docker
    if test -f Dockerfile -o -f docker-compose.yml -o -f docker-compose.yaml -o -f compose.yml -o -f compose.yaml
        if command -q docker
            set -a members "Docker"
        end
    end

    set -l result (string join ' · ' -- $members)

    # Cache result
    set -g __kh_party_cache_dir $PWD
    set -g __kh_party_cache_result $result

    echo $result
end

# ── World Detection: Codebase Type ──
function __fish_kh_detect_world
    if test "$KH_SHOW_WORLD" = 'false'
        return
    end

    # Cache per directory
    if test "$PWD" = "$__kh_world_cache_dir"
        echo $__kh_world_cache_name
        return
    end

    set -l world 'Destiny Islands'

    # DevOps / Infra — Space Paranoids
    if test -f Dockerfile
        if test -d terraform -o -d k8s -o -d .github/workflows
            set world 'Space Paranoids'
        end
    end

    # Monorepo — The World That Never Was
    if test "$world" = 'Destiny Islands'
        if test -f pnpm-workspace.yaml -o -f lerna.json -o -f nx.json -o -f rush.json
            set world 'The World That Never Was'
        end
    end

    # Frontend/React — Traverse Town
    if test "$world" = 'Destiny Islands'
        if test -f package.json
            if command grep -q '"react"' package.json 2>/dev/null
                set world 'Traverse Town'
            end
        end
    end

    # Backend — Hollow Bastion
    if test "$world" = 'Destiny Islands'
        if test -f go.mod -o -f Cargo.toml -o -f requirements.txt -o -f pyproject.toml
            set world 'Hollow Bastion'
        end
    end

    # Documentation — Radiant Garden
    if test "$world" = 'Destiny Islands'
        if test -d docs
            set world 'Radiant Garden'
        end
    end

    # Generic JS/TS — Twilight Town
    if test "$world" = 'Destiny Islands'
        if test -f package.json
            set world 'Twilight Town'
        end
    end

    # Cache result
    set -g __kh_world_cache_dir $PWD
    set -g __kh_world_cache_name $world

    echo $world
end
