# Completions for sanctuary command

# Complete with git branch names (for specifying sanctuaries)
complete -c sanctuary -f -a "(git branch --format='%(refname:short)' 2>/dev/null)" -d "🌟 World to protect"

# Add force flag completion
complete -c sanctuary -s f -l force -d "⚔️  Force purification (delete unmerged branches)"
