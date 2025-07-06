# 🌟 Kingdom Hearts Fish Theme

A magical fish shell configuration inspired by the Kingdom Hearts universe! Transform your terminal into a realm of light and darkness with themed prompts, git navigation, and spell casting.

![Kingdom Hearts Terminal](https://img.shields.io/badge/Theme-Kingdom%20Hearts-purple?style=for-the-badge&logo=terminal)
![Fish Shell](https://img.shields.io/badge/Shell-Fish-blue?style=for-the-badge&logo=terminal)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

## ✨ Features

### 🗝️ Themed Prompt

- Kingdom Hearts styled prompt with user info and path
- Git branch display with world status indicators
- Color-coded status (Light/Darkness) based on command success
- Dynamic pre-execution messages with KH quotes

### 🚀 Gummi Ship Navigation

- **`ship`** - Display available worlds (branches) and navigation options
- **`traverse <branch>`** - Travel to a specific world (git checkout)
- **`unlock <branch>`** - Unlock a new world (create branch)
- **`explore`** - Explore current world's status (git status)
- **`home`** - Return to main world (main/master branch)
- **`purify`** - Purify all worlds except main (delete branches)

### 🔮 Magic Casting

- **`cast <script>`** - Cast npm scripts with Kingdom Hearts theming
- Tab completion for available scripts
- Custom error messages for missing spells

### 🌊 Dive Command

- **`dive`** - Comprehensive system status with KH theming
- Git status with "corrupted memories" and "restored memories"
- Node.js and npm version display
- System information in Kingdom Hearts style

## 📋 Prerequisites

- [Fish Shell](https://fishshell.com/) (3.0+)
- [Git](https://git-scm.com/)
- [Node.js](https://nodejs.org/) (for `cast` command)

### Optional Dependencies

- [ASDF](https://asdf-vm.com/) (for version management)
- [Homebrew](https://brew.sh/) (macOS package manager)
- [Go](https://golang.org/) (for Go development)

## 🚀 Installation

### Method 1: Clone and Install (Recommended)

```bash
# Clone the repository
git clone https://github.com/yourusername/kingdom-hearts-fish.git ~/.config/fish-theme

# Backup your current fish config (optional)
cp -r ~/.config/fish ~/.config/fish-backup

# Install the theme
cp -r ~/.config/fish-theme/* ~/.config/fish/

# Reload fish configuration
source ~/.config/fish/config.fish
```

### Method 2: Manual Installation

1. **Download the files** to your `~/.config/fish/` directory:

   - `config.fish`
   - `conf.d/kh_aliases.fish`
   - `conf.d/kh_env.fish`
   - `functions/` directory
   - `completions/` directory

2. **Reload your fish configuration**:
   ```bash
   source ~/.config/fish/config.fish
   ```

### Method 3: Using Fisher (Plugin Manager)

```bash
# Install fisher if you haven't already
curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher

# Add this repository as a plugin (when published)
fisher add yourusername/kingdom-hearts-fish
```

## 🎮 Usage

### Basic Navigation

```bash
# See available commands
ship

# Navigate to a branch
traverse feature/new-world

# Create a new branch
unlock feature/amazing-feature

# Check current status
explore

# Return to main branch
home
```

### Magic Casting

```bash
# Cast a development spell
cast dev

# Cast a build spell
cast build

# See available spells (Tab completion)
cast [Tab]
```

### System Exploration

```bash
# Dive into system depths
dive
```

## 🎨 Customization

### Colors

The theme uses Kingdom Hearts inspired colors:

- **Light Blue** (`#00d7ff`) - Primary commands
- **Pink** (`#ff00ff`) - Borders and highlights
- **Green** (`#00ff9f`) - Success and positive states
- **Red** (`#ff005f`) - Errors and darkness
- **Yellow** (`#ffff00`) - Warnings and important info

### Adding Custom Commands

Add your own Kingdom Hearts themed commands to `conf.d/kh_aliases.fish`:

```fish
# Example: Custom KH command
function heartless
    echo "🌑 Heartless detected! Engaging combat mode..."
    # Your command here
end
```

## 🔧 Troubleshooting

### Fish Shell Not Found

```bash
# Install fish shell
# macOS
brew install fish

# Ubuntu/Debian
sudo apt install fish

# Arch Linux
sudo pacman -S fish
```

### Commands Not Working

```bash
# Reload configuration
source ~/.config/fish/config.fish

# Check if functions are loaded
functions | grep gummi
```

### Tab Completion Not Working

```bash
# Ensure completions directory is in fish function path
echo $fish_function_path | grep completions

# Reload completions
fish_config theme reload
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`unlock feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Inspired by the Kingdom Hearts series by Square Enix
- Built with [Fish Shell](https://fishshell.com/)
- Thanks to the fish shell community for the amazing shell experience

---

**May your heart be your guiding key! 🗝️**

---

## 📸 Screenshots

_Add screenshots of your terminal here to showcase the theme_

## 🔗 Links

- [Fish Shell Documentation](https://fishshell.com/docs/current/)
- [Kingdom Hearts Wiki](https://kingdomhearts.fandom.com/)
- [Git Documentation](https://git-scm.com/doc)

---

**Star this repository if you love Kingdom Hearts! ⭐**
