# Kingdom Hearts Interactive Menu — Keybinding Setup
# Called once at shell startup to register all menu-related keybindings.

function kh_menu_bindings --description "Register KH interactive menu keybindings"
    # Ensure we're in default mode (safety reset after source/reload)
    set -g fish_bind_mode default
    set -g __kh_menu_open 0

    # ── Clear any stale catch-all binding from previous versions ──
    bind -M default -e '' 2>/dev/null

    # ── Trigger: Option+Space (macOS) / Ctrl+Space (Linux) ──
    # Option+Space sends non-breaking space (U+00A0 = \xc2\xa0 in UTF-8)
    bind -M default \xc2\xa0 kh_menu
    bind -M insert \xc2\xa0 kh_menu 2>/dev/null

    # ── khmenu mode: navigation ──
    bind -M khmenu \e\[A  __kh_menu_up       # Up arrow
    bind -M khmenu \e\[B  __kh_menu_down     # Down arrow
    bind -M khmenu \r     __kh_menu_select   # Enter
    bind -M khmenu \e\[C  __kh_menu_select   # Right arrow → enter submenu
    bind -M khmenu \e\[D  __kh_menu_back     # Left arrow → go back
    bind -M khmenu \e\e   __kh_menu_dismiss  # double-Escape → close
    bind -M khmenu \cc    __kh_menu_dismiss  # Ctrl+C → close

    # ── khmenu mode: letters → filter (searchable) or noop/dismiss (non-searchable) ──
    for char in a b c d e f g h i j k l m n o p q r s t u v w x y z \
                A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
        bind -M khmenu $char "__kh_menu_filter_key $char"
    end
    # Digits
    for char in 0 1 2 3 4 5 6 7 8 9
        bind -M khmenu $char "__kh_menu_filter_key $char"
    end
    # Common chars in branch/script names
    bind -M khmenu -      "__kh_menu_filter_key -"
    bind -M khmenu .      "__kh_menu_filter_key ."
    bind -M khmenu /      "__kh_menu_filter_key /"
    bind -M khmenu _      "__kh_menu_filter_key _"
    bind -M khmenu ':'    "__kh_menu_filter_key :"

    # Backspace → remove last filter char (or noop)
    bind -M khmenu \x7f   __kh_menu_filter_backspace

    # ── khmenu mode: block everything else ──
    bind -M khmenu \t     __kh_menu_noop   # Tab
    bind -M khmenu \cd    __kh_menu_noop   # Ctrl+D
    bind -M khmenu ' '    __kh_menu_noop   # Space
    bind -M khmenu ,      __kh_menu_noop
    bind -M khmenu =      __kh_menu_noop
    bind -M khmenu \'     __kh_menu_noop
    bind -M khmenu '"'    __kh_menu_noop
    bind -M khmenu ';'    __kh_menu_noop
    bind -M khmenu '['    __kh_menu_noop
    bind -M khmenu ']'    __kh_menu_noop
    bind -M khmenu '('    __kh_menu_noop
    bind -M khmenu ')'    __kh_menu_noop
    bind -M khmenu '`'    __kh_menu_noop
    bind -M khmenu '~'    __kh_menu_noop
    bind -M khmenu '!'    __kh_menu_noop
    bind -M khmenu '@'    __kh_menu_noop
    bind -M khmenu '#'    __kh_menu_noop
    bind -M khmenu '$'    __kh_menu_noop
    bind -M khmenu '%'    __kh_menu_noop
    bind -M khmenu '^'    __kh_menu_noop
    bind -M khmenu '&'    __kh_menu_noop
    bind -M khmenu '*'    __kh_menu_noop
    bind -M khmenu +      __kh_menu_noop
    bind -M khmenu '|'    __kh_menu_noop
    bind -M khmenu '\\'   __kh_menu_noop
    bind -M khmenu '<'    __kh_menu_noop
    bind -M khmenu '>'    __kh_menu_noop
    bind -M khmenu '?'    __kh_menu_noop
    bind -M khmenu '{'    __kh_menu_noop
    bind -M khmenu '}'    __kh_menu_noop
end
