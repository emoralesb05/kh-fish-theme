# Completions for load command (Load Save Point — git stash pop/apply/list)
complete -c load -f -a "list" -d "📋 List all save points"
complete -c load -f -a "(seq 0 (math (command git stash list 2>/dev/null | wc -l | string trim) - 1) 2>/dev/null)" -d "💾 Load save point by index"
