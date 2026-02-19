# Kingdom Hearts Interactive Command Menu
# Triggered by F2. Navigate with arrows, Enter to select, Left/Escape to go back.
# Uses Fish bind modes for modal input capture.

# ── State Globals ──
set -g __kh_menu_open 0
set -g __kh_menu_cursor 1
set -g __kh_menu_ids
set -g __kh_menu_labels
set -g __kh_menu_types
set -g __kh_menu_commands
set -g __kh_menu_stack
set -g __kh_menu_lines_drawn 0
set -g __kh_menu_title 'COMMAND'
set -g __kh_menu_current_id 'root'
set -g __kh_menu_scroll_offset 0

# Cached dynamic data
set -g __kh_menu_magic_scripts
set -g __kh_menu_magic_labels
set -g __kh_menu_branches
set -g __kh_menu_stashes
set -g __kh_menu_stash_labels

# Search/filter state
set -g __kh_menu_filter ''
set -g __kh_menu_searchable 0
set -g __kh_menu_unfiltered_ids
set -g __kh_menu_unfiltered_labels
set -g __kh_menu_unfiltered_types
set -g __kh_menu_unfiltered_commands

# ── Public Toggle ──
function kh_menu --description "Toggle the KH interactive command menu"
    if test "$__kh_menu_open" = 1
        __kh_menu_dismiss
    else
        __kh_menu_init
    end
end

# ── Initialize & Open ──
function __kh_menu_init
    # Gather dynamic data
    __kh_menu_gather_data

    # Load root menu
    __kh_menu_load_root

    # Reset state
    set -g __kh_menu_open 1
    set -g __kh_menu_cursor 1
    set -g __kh_menu_stack
    set -g __kh_menu_scroll_offset 0
    set -g __kh_menu_lines_drawn 0

    # Enter menu bind mode first (so Fish knows we're in khmenu)
    set -g fish_bind_mode khmenu

    # Hide cursor and render
    printf '\033[?25l'
    __kh_menu_render
end

# ── Gather Dynamic Data ──
function __kh_menu_gather_data
    # Magic: npm/pnpm scripts from package.json
    set -g __kh_menu_magic_scripts
    set -g __kh_menu_magic_labels
    if test -f package.json
        set -l scripts (command node -e 'try{console.log(Object.keys(require("./package.json").scripts||{}).join("\n"))}catch(e){}' 2>/dev/null)
        if test -n "$scripts"
            set -g __kh_menu_magic_scripts $scripts
            set -g __kh_menu_magic_labels $scripts
        end
    end

    # Branches for traverse picker
    set -g __kh_menu_branches
    if command git rev-parse --git-dir >/dev/null 2>&1
        set -g __kh_menu_branches (command git branch --format='%(refname:short)' 2>/dev/null)
    end

    # Stashes
    set -g __kh_menu_stashes
    set -g __kh_menu_stash_labels
    if command git rev-parse --git-dir >/dev/null 2>&1
        set -l stash_lines (command git stash list --format='%gd: %s' 2>/dev/null)
        set -l stash_count (count $stash_lines)
        if test $stash_count -gt 0
            for i in (seq 1 $stash_count)
                set -a __kh_menu_stashes (math $i - 1)
                # Truncate long stash descriptions
                set -l label $stash_lines[$i]
                if test (string length -- "$label") -gt 28
                    set label (string sub -l 25 -- "$label")"..."
                end
                set -a __kh_menu_stash_labels "$label"
            end
        end
    end
end

# ── Dismiss & Clean Up ──
function __kh_menu_dismiss
    __kh_menu_erase
    printf '\033[?25h'
    set -g __kh_menu_open 0
    set -g __kh_menu_stack
    set -g __kh_menu_lines_drawn 0
    set -g __kh_menu_filter ''
    set -g __kh_menu_searchable 0
    set -g fish_bind_mode default
    commandline -f repaint
end

# ── Erase Drawn Menu Lines ──
# Only used by dismiss. During live re-renders, render handles its own cleanup.
function __kh_menu_erase
    if test "$__kh_menu_lines_drawn" -le 0
        return
    end
    # Output blank lines to reach the drawn area, clear each, move back
    set -l total_lines (math $__kh_menu_lines_drawn + 1)
    for i in (seq 1 $total_lines)
        printf '\n\033[2K'
    end
    printf '\033[%dA' $total_lines
    set -g __kh_menu_lines_drawn 0
    set -g __kh_menu_max_lines_drawn 0
end

# ── Compute Visible Window ──
function __kh_menu_visible_range
    set -l total (count $__kh_menu_labels)
    set -l max_items $KH_MENU_MAX_ITEMS
    if test -z "$max_items"
        set max_items 15
    end

    if test $total -le $max_items
        set -g __kh_menu_vis_start 1
        set -g __kh_menu_vis_end $total
        set -g __kh_menu_has_scroll_up 0
        set -g __kh_menu_has_scroll_down 0
        return
    end

    # Adjust scroll offset to keep cursor visible
    if test $__kh_menu_cursor -le $__kh_menu_scroll_offset
        set -g __kh_menu_scroll_offset (math $__kh_menu_cursor - 1)
    end
    if test $__kh_menu_cursor -gt (math $__kh_menu_scroll_offset + $max_items)
        set -g __kh_menu_scroll_offset (math $__kh_menu_cursor - $max_items)
    end

    # Clamp
    if test $__kh_menu_scroll_offset -lt 0
        set -g __kh_menu_scroll_offset 0
    end
    set -l max_offset (math $total - $max_items)
    if test $__kh_menu_scroll_offset -gt $max_offset
        set -g __kh_menu_scroll_offset $max_offset
    end

    set -g __kh_menu_vis_start (math $__kh_menu_scroll_offset + 1)
    set -g __kh_menu_vis_end (math $__kh_menu_scroll_offset + $max_items)

    if test $__kh_menu_scroll_offset -gt 0
        set -g __kh_menu_has_scroll_up 1
    else
        set -g __kh_menu_has_scroll_up 0
    end
    if test $__kh_menu_vis_end -lt $total
        set -g __kh_menu_has_scroll_down 1
    else
        set -g __kh_menu_has_scroll_down 0
    end
end

# ── Render Menu ──
function __kh_menu_render
    set -l total (count $__kh_menu_labels)
    if test $total -eq 0
        return
    end

    # Compute visible range
    __kh_menu_visible_range

    # Find max label width for box sizing
    set -l max_width 8
    for i in (seq $__kh_menu_vis_start $__kh_menu_vis_end)
        set -l len (string length -- "$__kh_menu_labels[$i]")
        if test $len -gt $max_width
            set max_width $len
        end
    end
    set -l inner_width (math $max_width + 6)
    if test $inner_width -lt 18
        set inner_width 18
    end

    # Build border strings — ensure inner_width accommodates the title
    set -l title_len (string length -- "$__kh_menu_title")
    # Title needs: 3 dashes + space + title + space + at least 1 dash
    set -l title_min (math 3 + 1 + $title_len + 1 + 1)
    if test $inner_width -lt $title_min
        set inner_width $title_min
    end
    set -l top_dashes_after (math $inner_width - 3 - 1 - $title_len - 1)
    if test $top_dashes_after -lt 1
        set top_dashes_after 1
    end
    set -l top_border (string repeat -n 3 '─')" $__kh_menu_title "(string repeat -n $top_dashes_after '─')
    set -l bottom_border (string repeat -n $inner_width '─')

    # Count lines this render will draw
    set -l visible_count (math $__kh_menu_vis_end - $__kh_menu_vis_start + 1)
    set -l line_count (math $visible_count + 2)
    if test "$__kh_menu_has_scroll_up" = 1
        set line_count (math $line_count + 1)
    end
    if test "$__kh_menu_has_scroll_down" = 1
        set line_count (math $line_count + 1)
    end
    if test "$__kh_menu_searchable" = 1 -a -n "$__kh_menu_filter"
        set line_count (math $line_count + 2)
    end

    # How many lines to output total (max of current and previous)
    set -l output_total $line_count
    if test "$__kh_menu_lines_drawn" -gt $output_total 2>/dev/null
        set output_total $__kh_menu_lines_drawn
    end

    # Track lines actually output for cursor movement
    set -l lines_output 0

    # Reserve space: print enough \n to trigger any terminal scrolling upfront,
    # then move cursor back to starting position. This prevents scroll-induced
    # ghost lines when the terminal is short.
    set -l reserve (math $output_total + 1)
    for i in (seq 1 $reserve)
        printf '\n'
    end
    printf '\033[%dA' $reserve

    # Move below commandline
    printf '\n'

    # Top border
    printf '\033[2K'
    set_color $KH_BLUE
    printf ' ╭%s╮\n' "$top_border"
    set lines_output (math $lines_output + 1)

    # Scroll-up indicator
    if test "$__kh_menu_has_scroll_up" = 1
        printf '\033[2K'
        set_color $KH_BLUE
        printf ' │'
        set_color $KH_SLATE
        set -l up_count (math $__kh_menu_scroll_offset)
        set -l indicator " ↑ $up_count more"
        set -l pad_len (math $inner_width - (string length -- "$indicator"))
        printf '%s%*s' "$indicator" $pad_len ''
        set_color $KH_BLUE
        printf '│\n'
        set lines_output (math $lines_output + 1)
    end

    # Menu items
    for i in (seq $__kh_menu_vis_start $__kh_menu_vis_end)
        printf '\033[2K'

        set -l label "$__kh_menu_labels[$i]"
        set -l item_type "$__kh_menu_types[$i]"
        set -l label_len (string length -- "$label")

        set -l indicator ''
        switch $item_type
            case submenu
                set indicator '▸'
            case input
                set indicator '…'
            case disabled
                set indicator '×'
        end

        set -l indicator_len 0
        if test -n "$indicator"
            set indicator_len 2
        end

        set -l pad_len (math $inner_width - 2 - $label_len - $indicator_len - 1)
        if test $pad_len -lt 0
            set pad_len 0
        end

        set_color $KH_BLUE
        printf ' │'

        if test $i -eq $__kh_menu_cursor
            set_color $KH_WHITE --bold --background=$KH_HILIGHT
            printf '▶ %s%*s' "$label" $pad_len ''
            if test -n "$indicator"
                printf ' %s' "$indicator"
            end
            printf ' '
            set_color normal
        else if test "$item_type" = disabled
            set_color $KH_SLATE --background=$KH_DARK
            printf '  %s%*s' "$label" $pad_len ''
            if test -n "$indicator"
                printf ' %s' "$indicator"
            end
            printf ' '
            set_color normal
        else
            set_color $KH_ICY --background=$KH_DARK
            printf '  %s%*s' "$label" $pad_len ''
            if test -n "$indicator"
                set_color $KH_SLATE --background=$KH_DARK
                printf ' %s' "$indicator"
            end
            set_color $KH_ICY --background=$KH_DARK
            printf ' '
            set_color normal
        end

        set_color $KH_BLUE
        printf '│\n'
        set lines_output (math $lines_output + 1)
    end

    # Scroll-down indicator
    if test "$__kh_menu_has_scroll_down" = 1
        printf '\033[2K'
        set_color $KH_BLUE
        printf ' │'
        set_color $KH_SLATE
        set -l down_count (math $total - $__kh_menu_vis_end)
        set -l indicator " ↓ $down_count more"
        set -l pad_len (math $inner_width - (string length -- "$indicator"))
        printf '%s%*s' "$indicator" $pad_len ''
        set_color $KH_BLUE
        printf '│\n'
        set lines_output (math $lines_output + 1)
    end

    # Search bar
    if test "$__kh_menu_searchable" = 1 -a -n "$__kh_menu_filter"
        printf '\033[2K'
        set_color $KH_BLUE
        printf ' ├'
        set_color $KH_SLATE
        printf '%s' (string repeat -n $inner_width '─')
        set_color $KH_BLUE
        printf '┤\n'

        printf '\033[2K'
        set_color $KH_BLUE
        printf ' │'
        set_color $KH_GLOW --background=$KH_DARK
        set -l search_text " /$__kh_menu_filter"
        set -l search_len (string length -- "$search_text")
        set -l search_pad (math $inner_width - $search_len)
        if test $search_pad -lt 0
            set search_pad 0
        end
        printf '%s%*s' "$search_text" $search_pad ''
        set_color normal
        set_color $KH_BLUE
        printf '│\n'
        set lines_output (math $lines_output + 2)
    end

    # Bottom border
    printf '\033[2K'
    set_color $KH_BLUE
    printf ' ╰%s╯\n' "$bottom_border"
    set lines_output (math $lines_output + 1)

    set_color normal

    # Clear any leftover lines from a previous taller render
    while test $lines_output -lt $output_total
        printf '\033[2K\n'
        set lines_output (math $lines_output + 1)
    end

    # Record and move cursor back up
    set -g __kh_menu_lines_drawn $lines_output
    printf '\033[%dA' (math $lines_output + 1)
end

# ── Navigation ──
function __kh_menu_up
    set -l total (count $__kh_menu_labels)
    if test $total -eq 0
        return
    end

    set -g __kh_menu_cursor (math $__kh_menu_cursor - 1)
    if test $__kh_menu_cursor -lt 1
        set -g __kh_menu_cursor $total
        # Jump scroll offset to bottom
        set -l max_items $KH_MENU_MAX_ITEMS
        if test -z "$max_items"; set max_items 15; end
        if test $total -gt $max_items
            set -g __kh_menu_scroll_offset (math $total - $max_items)
        end
    end

    __kh_menu_render
end

function __kh_menu_down
    set -l total (count $__kh_menu_labels)
    if test $total -eq 0
        return
    end

    set -g __kh_menu_cursor (math $__kh_menu_cursor + 1)
    if test $__kh_menu_cursor -gt $total
        set -g __kh_menu_cursor 1
        set -g __kh_menu_scroll_offset 0
    end

    __kh_menu_render
end

function __kh_menu_noop
    # Intentionally empty — blocks key input in menu mode
end

# ── Search / Filter ──
function __kh_menu_filter_key --argument-names char
    # Non-searchable menus: q dismisses, everything else blocked
    if test "$__kh_menu_searchable" != 1
        if test "$char" = q
            __kh_menu_dismiss
        end
        return
    end

    # Append character to filter and apply
    set -g __kh_menu_filter "$__kh_menu_filter$char"
    __kh_menu_apply_filter
    __kh_menu_render
end

function __kh_menu_filter_backspace
    if test "$__kh_menu_searchable" != 1
        return
    end
    if test -z "$__kh_menu_filter"
        return
    end

    # Remove last character
    set -l len (string length -- "$__kh_menu_filter")
    if test $len -le 1
        set -g __kh_menu_filter ''
    else
        set -g __kh_menu_filter (string sub -l (math $len - 1) -- "$__kh_menu_filter")
    end
    __kh_menu_apply_filter
    __kh_menu_render
end

function __kh_menu_apply_filter
    # Rebuild visible arrays from unfiltered backup
    set -g __kh_menu_ids
    set -g __kh_menu_labels
    set -g __kh_menu_types
    set -g __kh_menu_commands

    if test -z "$__kh_menu_filter"
        # No filter — restore everything
        set -g __kh_menu_ids $__kh_menu_unfiltered_ids
        set -g __kh_menu_labels $__kh_menu_unfiltered_labels
        set -g __kh_menu_types $__kh_menu_unfiltered_types
        set -g __kh_menu_commands $__kh_menu_unfiltered_commands
    else
        set -l query (string lower -- "$__kh_menu_filter")
        for i in (seq 1 (count $__kh_menu_unfiltered_labels))
            set -l label_lower (string lower -- "$__kh_menu_unfiltered_labels[$i]")
            if string match -q "*$query*" -- "$label_lower"
                set -a __kh_menu_ids $__kh_menu_unfiltered_ids[$i]
                set -a __kh_menu_labels $__kh_menu_unfiltered_labels[$i]
                set -a __kh_menu_types $__kh_menu_unfiltered_types[$i]
                set -a __kh_menu_commands $__kh_menu_unfiltered_commands[$i]
            end
        end

        # No matches — show disabled placeholder
        if test (count $__kh_menu_labels) -eq 0
            set -a __kh_menu_ids no_match
            set -a __kh_menu_labels 'No matches'
            set -a __kh_menu_types disabled
            set -a __kh_menu_commands ''
        end
    end

    set -g __kh_menu_cursor 1
    set -g __kh_menu_scroll_offset 0
end

# ── Select / Enter Submenu ──
function __kh_menu_select
    set -l total (count $__kh_menu_labels)
    if test $total -eq 0
        return
    end

    set -l item_type $__kh_menu_types[$__kh_menu_cursor]
    set -l item_id $__kh_menu_ids[$__kh_menu_cursor]
    set -l item_cmd $__kh_menu_commands[$__kh_menu_cursor]

    switch $item_type
        case submenu
            # Clear any active filter before entering submenu
            set -g __kh_menu_filter ''

            # Push current state onto stack
            set -g --append __kh_menu_stack "$__kh_menu_cursor:$__kh_menu_current_id:$__kh_menu_scroll_offset"

            # Load submenu
            switch $item_id
                case attack
                    __kh_menu_load_attack
                case magic
                    __kh_menu_load_magic
                case summon
                    __kh_menu_load_summon
                case traverse
                    __kh_menu_load_traverse
                case traverse_branches
                    __kh_menu_load_branches
                case config
                    __kh_menu_load_config
                case save_point
                    __kh_menu_load_save_point
                case load_point
                    __kh_menu_load_load_point
                case '*'
                    # Unknown submenu — treat as no-op
                    set -e __kh_menu_stack[-1]
                    return
            end

            set -g __kh_menu_cursor 1
            set -g __kh_menu_scroll_offset 0
            __kh_menu_render

        case action
            # Dismiss and execute
            __kh_menu_dismiss
            if test -n "$item_cmd"
                commandline -r "$item_cmd"
                commandline -f execute
            end

        case input
            # Dismiss and pre-fill commandline for user to complete
            __kh_menu_dismiss
            if test -n "$item_cmd"
                commandline -r "$item_cmd"
                commandline -C (string length -- "$item_cmd")
            end

        case disabled
            # Do nothing
    end
end

# ── Go Back ──
function __kh_menu_back
    # If filter is active, clear it first instead of navigating back
    if test "$__kh_menu_searchable" = 1 -a -n "$__kh_menu_filter"
        set -g __kh_menu_filter ''
        __kh_menu_apply_filter
        __kh_menu_render
        return
    end

    if test (count $__kh_menu_stack) -eq 0
        # At root — dismiss
        __kh_menu_dismiss
        return
    end

    # Pop from stack
    set -l entry $__kh_menu_stack[-1]
    set -e __kh_menu_stack[-1]

    set -l parts (string split ':' -- "$entry")
    set -l saved_cursor $parts[1]
    set -l saved_menu $parts[2]
    set -l saved_scroll 0
    if test (count $parts) -ge 3
        set saved_scroll $parts[3]
    end

    # Reload parent menu
    switch $saved_menu
        case root
            __kh_menu_load_root
        case attack
            __kh_menu_load_attack
        case magic
            __kh_menu_load_magic
        case summon
            __kh_menu_load_summon
        case traverse
            __kh_menu_load_traverse
        case config
            __kh_menu_load_config
        case save_point
            __kh_menu_load_save_point
        case load_point
            __kh_menu_load_load_point
    end

    set -g __kh_menu_cursor $saved_cursor
    set -g __kh_menu_scroll_offset $saved_scroll
    __kh_menu_render
end

# ── Menu Loaders ──

function __kh_menu_load_root
    set -g __kh_menu_title 'COMMAND'
    set -g __kh_menu_current_id 'root'
    set -g __kh_menu_searchable 0

    set -g __kh_menu_ids     attack  magic  summon  traverse  config
    set -g __kh_menu_labels  'Attack' 'Magic' 'Scan' 'Travel' 'Config'
    set -g __kh_menu_types   submenu submenu submenu submenu submenu
    set -g __kh_menu_commands '' '' '' '' ''
end

# ── Attack: Git workflow actions ──
function __kh_menu_load_attack
    set -g __kh_menu_title 'Attack'
    set -g __kh_menu_current_id 'attack'
    set -g __kh_menu_searchable 0

    set -g __kh_menu_ids
    set -g __kh_menu_labels
    set -g __kh_menu_types
    set -g __kh_menu_commands

    if command git rev-parse --git-dir >/dev/null 2>&1
        set -a __kh_menu_ids     stage_all
        set -a __kh_menu_labels  'Strike (stage)'
        set -a __kh_menu_types   action
        set -a __kh_menu_commands 'git add -A'

        set -a __kh_menu_ids     commit
        set -a __kh_menu_labels  'Combo (commit)...'
        set -a __kh_menu_types   input
        set -a __kh_menu_commands 'git commit -m "'

        set -a __kh_menu_ids     push
        set -a __kh_menu_labels  'Drive (push)'
        set -a __kh_menu_types   action
        set -a __kh_menu_commands 'git push'

        set -a __kh_menu_ids     pull
        set -a __kh_menu_labels  'Guard (pull)'
        set -a __kh_menu_types   action
        set -a __kh_menu_commands 'git pull'

        set -a __kh_menu_ids     sanctuary
        set -a __kh_menu_labels  'Sanctuary (clean)...'
        set -a __kh_menu_types   input
        set -a __kh_menu_commands 'sanctuary '
    else
        set -a __kh_menu_ids     no_git
        set -a __kh_menu_labels  'Not in a git repo'
        set -a __kh_menu_types   disabled
        set -a __kh_menu_commands ''
    end
end

# ── Magic: Project scripts (searchable) ──
function __kh_menu_load_magic
    set -g __kh_menu_title 'Magic'
    set -g __kh_menu_current_id 'magic'
    set -g __kh_menu_searchable 1
    set -g __kh_menu_filter ''

    set -g __kh_menu_ids
    set -g __kh_menu_labels
    set -g __kh_menu_types
    set -g __kh_menu_commands

    if test (count $__kh_menu_magic_scripts) -eq 0
        set -g __kh_menu_searchable 0
        set -a __kh_menu_ids     no_magic
        set -a __kh_menu_labels  'No spellbook found'
        set -a __kh_menu_types   disabled
        set -a __kh_menu_commands ''
        return
    end

    for script in $__kh_menu_magic_scripts
        set -a __kh_menu_ids     "magic_$script"
        set -a __kh_menu_labels  "$script"
        set -a __kh_menu_types   action
        set -a __kh_menu_commands "cast $script"
    end

    # Save unfiltered copies for search
    set -g __kh_menu_unfiltered_ids $__kh_menu_ids
    set -g __kh_menu_unfiltered_labels $__kh_menu_labels
    set -g __kh_menu_unfiltered_types $__kh_menu_types
    set -g __kh_menu_unfiltered_commands $__kh_menu_commands
end

# ── Summon: Info & status dashboards ──
function __kh_menu_load_summon
    set -g __kh_menu_title 'Scan'
    set -g __kh_menu_current_id 'summon'
    set -g __kh_menu_searchable 0

    set -g __kh_menu_ids
    set -g __kh_menu_labels
    set -g __kh_menu_types
    set -g __kh_menu_commands

    set -a __kh_menu_ids     dive
    set -a __kh_menu_labels  'Dive'
    set -a __kh_menu_types   action
    set -a __kh_menu_commands 'dive'

    set -a __kh_menu_ids     explore
    set -a __kh_menu_labels  'Explore'
    set -a __kh_menu_types   action
    set -a __kh_menu_commands 'explore'

    set -a __kh_menu_ids     heartless
    set -a __kh_menu_labels  'Enemies'
    set -a __kh_menu_types   action
    set -a __kh_menu_commands 'heartless'
end

# ── Travel: Branch navigation (searchable branch picker inside) ──
function __kh_menu_load_traverse
    set -g __kh_menu_title 'Travel'
    set -g __kh_menu_current_id 'traverse'
    set -g __kh_menu_searchable 0

    set -g __kh_menu_ids
    set -g __kh_menu_labels
    set -g __kh_menu_types
    set -g __kh_menu_commands

    if command git rev-parse --git-dir >/dev/null 2>&1
        if test (count $__kh_menu_branches) -gt 0
            set -a __kh_menu_ids     traverse_branches
            set -a __kh_menu_labels  'Traverse'
            set -a __kh_menu_types   submenu
            set -a __kh_menu_commands ''
        end

        set -a __kh_menu_ids     unlock
        set -a __kh_menu_labels  'Unlock...'
        set -a __kh_menu_types   input
        set -a __kh_menu_commands 'unlock '

        set -a __kh_menu_ids     home
        set -a __kh_menu_labels  'Home'
        set -a __kh_menu_types   action
        set -a __kh_menu_commands 'home'
    else
        set -a __kh_menu_ids     no_git
        set -a __kh_menu_labels  'Not in a git repo'
        set -a __kh_menu_types   disabled
        set -a __kh_menu_commands ''
    end
end

# ── Travel > Traverse (searchable branch picker) ──
function __kh_menu_load_branches
    set -g __kh_menu_title 'Traverse'
    set -g __kh_menu_current_id 'traverse_branches'
    set -g __kh_menu_searchable 1
    set -g __kh_menu_filter ''

    set -g __kh_menu_ids
    set -g __kh_menu_labels
    set -g __kh_menu_types
    set -g __kh_menu_commands

    set -l current_branch (command git symbolic-ref --short HEAD 2>/dev/null)

    if test (count $__kh_menu_branches) -eq 0
        set -g __kh_menu_searchable 0
        set -a __kh_menu_ids     no_branches
        set -a __kh_menu_labels  'No branches found'
        set -a __kh_menu_types   disabled
        set -a __kh_menu_commands ''
        return
    end

    for branch in $__kh_menu_branches
        set -l label "$branch"
        if test "$branch" = "$current_branch"
            set label "★ $branch"
        end
        set -a __kh_menu_ids     "branch_$branch"
        set -a __kh_menu_labels  "$label"
        if test "$branch" = "$current_branch"
            set -a __kh_menu_types   disabled
        else
            set -a __kh_menu_types   action
        end
        set -a __kh_menu_commands "traverse $branch"
    end

    # Save unfiltered copies for search
    set -g __kh_menu_unfiltered_ids $__kh_menu_ids
    set -g __kh_menu_unfiltered_labels $__kh_menu_labels
    set -g __kh_menu_unfiltered_types $__kh_menu_types
    set -g __kh_menu_unfiltered_commands $__kh_menu_commands
end

# ── Config: Save points, load points, utilities ──
function __kh_menu_load_config
    set -g __kh_menu_title 'Config'
    set -g __kh_menu_current_id 'config'
    set -g __kh_menu_searchable 0

    set -g __kh_menu_ids
    set -g __kh_menu_labels
    set -g __kh_menu_types
    set -g __kh_menu_commands

    if command git rev-parse --git-dir >/dev/null 2>&1
        set -a __kh_menu_ids     save_point
        set -a __kh_menu_labels  'Save Point'
        set -a __kh_menu_types   submenu
        set -a __kh_menu_commands ''

        set -a __kh_menu_ids     load_point
        set -a __kh_menu_labels  'Load Point'
        set -a __kh_menu_types   submenu
        set -a __kh_menu_commands ''
    end

    set -a __kh_menu_ids     refresh
    set -a __kh_menu_labels  'Refresh HUD'
    set -a __kh_menu_types   action
    set -a __kh_menu_commands 'kh_refresh'
end

# ── Config > Save Point ──
function __kh_menu_load_save_point
    set -g __kh_menu_title 'Save Point'
    set -g __kh_menu_current_id 'save_point'
    set -g __kh_menu_searchable 0

    set -g __kh_menu_ids
    set -g __kh_menu_labels
    set -g __kh_menu_types
    set -g __kh_menu_commands

    set -a __kh_menu_ids     save_quick
    set -a __kh_menu_labels  'Save'
    set -a __kh_menu_types   action
    set -a __kh_menu_commands 'save'

    set -a __kh_menu_ids     save_msg
    set -a __kh_menu_labels  'Save As...'
    set -a __kh_menu_types   input
    set -a __kh_menu_commands 'save '
end

# ── Config > Load Point ──
function __kh_menu_load_load_point
    set -g __kh_menu_title 'Load Point'
    set -g __kh_menu_current_id 'load_point'
    set -g __kh_menu_searchable 0

    set -g __kh_menu_ids
    set -g __kh_menu_labels
    set -g __kh_menu_types
    set -g __kh_menu_commands

    set -a __kh_menu_ids     load_latest
    set -a __kh_menu_labels  'Load Latest'
    set -a __kh_menu_types   action
    set -a __kh_menu_commands 'load'

    # Individual stashes
    if test (count $__kh_menu_stashes) -gt 0
        for i in (seq 1 (count $__kh_menu_stashes))
            set -l stash_num $__kh_menu_stashes[$i]
            set -l stash_lbl $__kh_menu_stash_labels[$i]
            set -a __kh_menu_ids     "stash_$stash_num"
            set -a __kh_menu_labels  "$stash_lbl"
            set -a __kh_menu_types   action
            set -a __kh_menu_commands "load $stash_num"
        end
    else
        set -a __kh_menu_ids     no_stashes
        set -a __kh_menu_labels  'No save points'
        set -a __kh_menu_types   disabled
        set -a __kh_menu_commands ''
    end
end

# ── Terminal Resize Handler ──
function __kh_menu_on_resize --on-signal WINCH
    if test "$__kh_menu_open" = 1
        __kh_menu_dismiss
    end
end
