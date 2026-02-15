# Kingdom Hearts Fish Theme

# Add functions directory to fish function path
set -g fish_function_path $fish_function_path $__fish_config_dir/functions

# ── Kingdom Hearts Color Palette ──
# Reusable color variables for prompt, welcome, and functions
set -g KH_BLUE    '#185fad'   # Royal blue — signature KH command menu
set -g KH_WHITE   '#f9f9f9'   # Near-white menu text
set -g KH_GREEN   '#00ff9f'   # HP full / success
set -g KH_RED     '#ff005f'   # HP critical / error
set -g KH_GOLD    '#f8c169'   # Golden yellow / Sora
set -g KH_CYAN    '#00d7ff'   # Sky blue / accent
set -g KH_TEAL    '#00b2d4'   # MP bar
set -g KH_MAUVE   '#dba8cd'   # Kairi/Naminé pink
set -g KH_SLATE   '#434d71'   # Borders / dim text
set -g KH_DARK    '#26244f'   # Dark panel background
set -g KH_ICY     '#c6e2f3'   # Icy blue / subtle
set -g KH_LIME    '#8ebc4f'   # HP secondary green
set -g KH_GLOW    '#99f7ff'   # Bright cyan glow

# Syntax highlighting colors — authentic KH palette
set -g fish_color_normal            $KH_WHITE      # Near-white (KH menu text)
set -g fish_color_command           $KH_CYAN       # Sky blue
set -g fish_color_param             $KH_ICY        # Icy blue (softer than magenta)
set -g fish_color_redirection       $KH_GOLD       # Golden yellow (Sora/light)
set -g fish_color_comment           $KH_SLATE      # Slate border
set -g fish_color_error             $KH_RED        # Critical red
set -g fish_color_escape            $KH_GLOW       # Bright cyan glow
set -g fish_color_operator          $KH_MAUVE      # Pink mauve (Kairi/Naminé)
set -g fish_color_end               $KH_GREEN      # HP green
set -g fish_color_quote             $KH_GOLD       # Golden yellow
set -g fish_color_autosuggestion    $KH_SLATE      # Slate (subtle)
set -g fish_color_valid_path        $KH_LIME       # Lime green (HP secondary)
set -g fish_color_history_current   $KH_CYAN       # Sky blue
set -g fish_color_search_match      $KH_GOLD       # Golden highlight
set -g fish_color_selection         $KH_DARK       # Dark purple-blue (panel bg)

# ── Configuration ──
# Prompt mode: 'full' (command menu box), 'compact' (inline menu), 'minimal' (2-line)
if not set -q KH_PROMPT_MODE
    set -g KH_PROMPT_MODE 'full'
end
# Feature toggles
if not set -q KH_SHOW_PARTY
    set -g KH_SHOW_PARTY 'true'
end
if not set -q KH_SHOW_WORLD
    set -g KH_SHOW_WORLD 'true'
end
if not set -q KH_SHOW_CLOCK
    set -g KH_SHOW_CLOCK 'false'
end
if not set -q KH_BAR_WIDTH
    set -g KH_BAR_WIDTH 10
end
if not set -q KH_HEARTLESS
    set -g KH_HEARTLESS 'true'
end

# ── Load HUD helpers ──
source $__fish_config_dir/functions/kh_hud_helpers.fish

# ── Load Heartless encounters ──
source $__fish_config_dir/functions/kh_heartless.fish
__fish_kh_heartless_init

# ── Helper: Path ──
function __fish_kh_path
    set -l current_path (pwd)
    set -l display_path (string replace $HOME "~" $current_path)
    # Truncate to last 3 components for deep paths
    set -l parts (string split '/' $display_path)
    if test (count $parts) -gt 4
        set display_path "…/"(string join '/' $parts[-3..-1])
    end
    echo $display_path
end

# ── Prompt ──
function fish_prompt
    set -l last_status $status

    # Gather git data ONCE (shared with right prompt via globals)
    __fish_kh_git_data

    set -l display_path (__fish_kh_path)
    set -l git_info (__fish_kh_git_prompt)
    set -l fourth_slot (__fish_kh_4th_slot)
    set -l party (__fish_kh_party_members)
    set -l world (__fish_kh_detect_world)
    set -l cursor_pos (__fish_kh_menu_cursor)

    switch $KH_PROMPT_MODE
        case full
            __fish_kh_prompt_full $last_status "$display_path" "$git_info" "$fourth_slot" "$party" "$world" $cursor_pos
        case compact
            __fish_kh_prompt_compact $last_status "$display_path" "$git_info" "$fourth_slot" "$party" "$world" $cursor_pos
        case minimal
            __fish_kh_prompt_minimal $last_status "$display_path" "$git_info" "$world"
        case '*'
            __fish_kh_prompt_full $last_status "$display_path" "$git_info" "$fourth_slot" "$party" "$world" $cursor_pos
    end
end

# ── Prompt Mode: Full Command Menu ──
function __fish_kh_prompt_full
    set -l last_status $argv[1]
    set -l display_path $argv[2]
    set -l git_info $argv[3]
    set -l fourth_slot $argv[4]
    set -l party $argv[5]
    set -l world $argv[6]
    set -l cursor_pos $argv[7]

    if test $last_status -ne 0
        set heart_color $KH_RED
    else
        set heart_color $KH_GREEN
    end

    # Pad 4th slot text to fit 8-char interior
    set -l slot_padded (printf '%-8s' "$fourth_slot")

    # Menu item labels and their colors
    set -l labels 'Attack  ' 'Magic   ' 'Items   ' "$slot_padded"
    set -l label_colors $KH_WHITE $KH_WHITE $KH_WHITE $__kh_4th_slot_color

    # Menu box top
    set_color $KH_BLUE
    echo ' ┌──────────┐'

    # Render 4 menu rows with dynamic ♥ cursor
    for i in 1 2 3 4
        set_color $KH_BLUE
        echo -n ' │'

        if test "$i" -eq "$cursor_pos"
            set_color $heart_color
            echo -n '♥'
            set_color $label_colors[$i] --bold
        else
            set_color $KH_SLATE
            echo -n ' '
            set_color $label_colors[$i]
        end

        echo -n " $labels[$i]"
        set_color $KH_BLUE
        echo -n '│'

        # Right-side info on specific rows
        if test $i -eq 1
            set_color normal
            echo -n '  '
            set_color $KH_GOLD
            echo -n "$display_path"
            if test -n "$git_info"
                echo -n " $git_info"
            end
        else if test $i -eq 2
            if test -n "$party"
                set_color normal
                echo -n '  '
                set_color $KH_ICY
                echo -n "$party"
            end
        end
        echo
    end

    # Menu box bottom
    set_color $KH_BLUE
    echo ' └──────────┘'

    # Input line with world name
    set_color $KH_CYAN
    echo -n ' 🗝️  '
    if test -n "$world"
        set_color $KH_SLATE
        echo -n '⚔ '
        set_color $KH_ICY
        echo -n "$world"
        echo -n ' '
    end
    set_color normal
end

# ── Prompt Mode: Compact ──
function __fish_kh_prompt_compact
    set -l last_status $argv[1]
    set -l display_path $argv[2]
    set -l git_info $argv[3]
    set -l fourth_slot $argv[4]
    set -l party $argv[5]
    set -l world $argv[6]
    set -l cursor_pos $argv[7]

    if test $last_status -ne 0
        set heart_color $KH_RED
    else
        set heart_color $KH_GREEN
    end

    # Line 1: menu items inline with dynamic ♥ cursor + path + git
    set -l compact_labels 'Attack' 'Magic' 'Items' "$fourth_slot"
    set -l compact_colors $KH_WHITE $KH_WHITE $KH_WHITE $__kh_4th_slot_color

    echo -n ' '
    for i in 1 2 3 4
        if test $i -gt 1
            set_color $KH_SLATE
            echo -n ' │ '
        end
        if test "$i" -eq "$cursor_pos"
            set_color $heart_color
            echo -n '♥ '
            set_color $compact_colors[$i] --bold
        else
            set_color $compact_colors[$i]
        end
        echo -n "$compact_labels[$i]"
        if test "$i" -eq "$cursor_pos"
            set_color normal
        end
    end
    echo -n '   '
    set_color $KH_GOLD
    echo -n "$display_path"
    if test -n "$git_info"
        echo -n " $git_info"
    end
    echo

    # Line 2: separator with party and world
    set_color $KH_BLUE
    echo -n ' ────────────────────'
    if test -n "$party"
        set_color normal
        echo -n ' '
        set_color $KH_ICY
        echo -n "$party"
    end
    if test -n "$world"
        set_color $KH_SLATE
        echo -n ' │ ⚔ '
        set_color $KH_ICY
        echo -n "$world"
    end
    echo

    # Input line
    set_color $KH_CYAN
    echo -n ' 🗝️  '
    set_color normal
end

# ── Prompt Mode: Minimal ──
function __fish_kh_prompt_minimal
    set -l last_status $argv[1]
    set -l display_path $argv[2]
    set -l git_info $argv[3]
    set -l world $argv[4]

    if test $last_status -ne 0
        set heart_color $KH_RED
    else
        set heart_color $KH_GREEN
    end

    # Line 1: heart + path + git
    set_color $heart_color
    echo -n ' ♥'
    set_color normal
    echo -n ' '
    set_color $KH_GOLD
    echo -n "$display_path"
    if test -n "$git_info"
        echo -n " $git_info"
    end
    echo

    # Input line with world name
    set_color $KH_CYAN
    echo -n ' 🗝️  '
    if test -n "$world"
        set_color $KH_SLATE
        echo -n '⚔ '
        set_color $KH_ICY
        echo -n "$world"
        echo -n ' '
    end
    set_color normal
end

# ── Right Prompt — HP/DR/MP Gauge Bars ──
function fish_right_prompt
    # Compute bar levels from cached git data
    set -l hp (__fish_kh_hp_level)
    set -l drive (__fish_kh_drive_level)
    set -l mp (__fish_kh_mp_level)

    # Render bars
    __fish_kh_render_bar 'HP' $hp $KH_GREEN $KH_GOLD $KH_RED
    echo -n '  '
    __fish_kh_render_bar 'DR' $drive $KH_CYAN $KH_MAUVE $KH_SLATE
    echo -n '  '
    __fish_kh_render_bar 'MP' $mp $KH_TEAL $KH_TEAL $KH_MAUVE

    # Command duration (small text after bars)
    if test "$CMD_DURATION" -gt 100 2>/dev/null
        set -l duration_str
        if test "$CMD_DURATION" -gt 60000
            set duration_str (math -s1 $CMD_DURATION / 60000)"m"
        else if test "$CMD_DURATION" -gt 1000
            set duration_str (math -s1 $CMD_DURATION / 1000)"s"
        else
            set duration_str "$CMD_DURATION""ms"
        end
        echo -n '  '
        set_color $KH_SLATE
        echo -n "$duration_str"
    end

    # Optional clock
    if test "$KH_SHOW_CLOCK" = 'true'
        echo -n '  '
        set_color $KH_SLATE
        echo -n (date '+%H:%M')
    end

    set_color normal
end

# ── Pre-exec: Real KH Quotes ──
function fish_preexec --on-event fish_preexec
    set -l cmd (string split ' ' -- $argv[1])[1]

    # Skip trivial/navigation commands
    set -l skip ls ll la l cd .. ... .... ..... cat echo pwd clear \
        head tail less more true false test set printf which type
    if contains -- $cmd $skip
        return
    end

    # Only show 1 in 3 times
    if test (random 1 3) -ne 1
        return
    end

    set -l quotes \
        "Don't ever forget: wherever you go, I'm always with you. —Kairi" \
        "My friends are my power! —Sora" \
        "The heart may be weak, but deep down there's a light that never goes out. —Sora" \
        "Got it memorized? —Axel" \
        "May your heart be your guiding key. —Master Aqua" \
        "There are many worlds, but they share the same sky. —Kairi" \
        "Strength of heart will carry you through the hardest of trials. —Terra" \
        "This world has been connected. —Ansem" \
        "The closer you get to the light, the greater your shadow becomes. —???" \
        "One who knows nothing can understand nothing. —Ansem" \
        "We don't need a weapon. My friends are my power! —Sora" \
        "Giving up already? Come on, I thought you were stronger than that. —Riku" \
        "Even in the deepest darkness, there will always be a light to guide you. —King Mickey" \
        "You're wrong. I know now, without a doubt. Kingdom Hearts is light! —Sora" \
        "A scattered dream that's like a far-off memory... —Sora" \
        "Thinking of you, wherever you are. —Kairi" \
        "The door is still shut. —Ansem"

    set -l idx (random 1 (count $quotes))
    set_color $KH_SLATE
    echo -n '  '
    set_color $KH_ICY
    printf '%s\n' $quotes[$idx]
    set_color normal
end

# Suppress default greeting (kingdom_hearts_welcome handles the welcome)
set -g fish_greeting ''

# Load gummi ship functions
source $__fish_config_dir/functions/gummi_ship.fish

# Run Kingdom Hearts welcome on startup
kingdom_hearts_welcome
