# Completion for traverse command (gummi_traverse)
complete -c traverse -f -a "(git branch --format='%(refname:short)' 2>/dev/null | string trim)" -d "🌍 World to traverse to"