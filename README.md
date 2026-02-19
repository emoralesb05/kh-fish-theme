# Kingdom Hearts Fish Theme

A Fish shell configuration inspired by the Kingdom Hearts universe. Features a KH Command Menu prompt, HP/MP gauge bars, world detection, party member display, Heartless encounters, and themed git navigation.

![Kingdom Hearts Terminal](https://img.shields.io/badge/Theme-Kingdom%20Hearts-purple?style=for-the-badge&logo=terminal)
![Fish Shell](https://img.shields.io/badge/Shell-Fish-blue?style=for-the-badge&logo=terminal)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

## Prompt

The prompt has 3 configurable modes. Switch between them with:

```fish
set -g KH_PROMPT_MODE full      # Command Menu box (default)
set -g KH_PROMPT_MODE compact   # Inline menu
set -g KH_PROMPT_MODE minimal   # 2-line minimal
```

### Full Mode

```
  ~/Github/myproject  main ↑2 +1 ~3 ?2 ≡1       Node 20.11 · Python 3.12 · Docker
 ╭──────────────╮
 │▶ Attack      │
 │  Magic       │
 │  Items       │
 │  Save        │
 ╰──────────────╯
  ⚔ Traverse Town  ❯ _                              1.2s HP▕████████━━▏ MP▕█████━━━━━▏
```

Path and git status appear above the menu box, with party members right-aligned. The selected menu row gets a highlight background with a `▶` cursor. Unselected rows have a dark panel background. The cursor position changes randomly each prompt. The right prompt shows command duration and gauge bars.

### Compact Mode

```
  ▶Attack  Magic Items Save  ~/Github/myproject  main ↑2 +1 ~3       Node · Docker
  ⚔ Traverse Town  ❯ _                              1.2s HP▕████████━━▏ MP▕█████━━━━━▏
```

### Minimal Mode

```
  ~/Github/myproject  main ↑2 +1 ~3
  ⚔ Traverse Town  ❯ _                              1.2s HP▕████████━━▏ MP▕█████━━━━━▏
```

## Prompt Elements

### Menu Cursor

The `▶` cursor highlights a random eligible menu item each prompt, making the menu feel alive like in the game. The `❯` input cursor on the world line changes color based on the last command's exit status:
- **Cyan** — command succeeded
- **Red** — command failed

### Git Status

Shown inline after the path when inside a git repository:

| Symbol | Meaning | Color |
|--------|---------|-------|
| `main` | Current branch | Cyan |
| `↑2` | 2 commits ahead of remote | Gold |
| `↓3` | 3 commits behind remote | Mauve |
| `+1` | 1 staged file | Green |
| `~3` | 3 modified files | Red |
| `?2` | 2 untracked files | Gold |
| `!1` | 1 merge conflict | Red |
| `≡1` | 1 stash entry | Mauve |
| `✓` | Clean working tree | Green |

### 4th Menu Slot (Context-Sensitive)

The bottom menu item changes based on your current state, just like in the game:

| Slot | Condition |
|------|-----------|
| **Save** | Uncommitted changes exist |
| **Drive** | Unpushed commits (momentum to push) |
| **Summon** | Not in a git repository |
| **Defend** | Clean and in sync with remote |

### Party Members

Detected runtimes show on the path line (full mode) or inline (compact mode). Detection is based on project files in the current directory:

| Runtime | Detected by |
|---------|-------------|
| Node.js | `package.json`, `.nvmrc`, `.node-version` |
| Python | `requirements.txt`, `pyproject.toml`, `Pipfile`, `setup.py` |
| Go | `go.mod` |
| Rust | `Cargo.toml` |
| Java | `pom.xml`, `build.gradle` |
| Ruby | `Gemfile` |
| Docker | `Dockerfile`, `compose.yml`, `docker-compose.yml` |

### World Detection

The project type is mapped to a Kingdom Hearts world name, shown as a badge on the input line with a blue background:

| World | Detection |
|-------|-----------|
| **Traverse Town** | React project (`"react"` in package.json) |
| **Twilight Town** | JS/TS project (package.json, no React) |
| **Hollow Bastion** | Backend project (go.mod, Cargo.toml, requirements.txt) |
| **The World That Never Was** | Monorepo (pnpm-workspace.yaml, nx.json, lerna.json) |
| **Space Paranoids** | DevOps (Dockerfile + terraform/k8s/.github/workflows) |
| **Radiant Garden** | Documentation (docs/ directory) |
| **Destiny Islands** | Default / no project detected |

## Gauge Bars (Right Prompt)

Two gauge bars in the right prompt represent meaningful dev metrics:

```
1.2s HP▕████████━━▏ MP▕█████━━━━━▏
```

### HP — Repo Cleanliness

Full when clean, depletes as your working tree gets dirty.

- Modified files: -8 per file
- Untracked files: -4 per file
- Merge conflicts: -20 per file
- Staged files: -2 per file
- Color: green (>60%) → gold (30-60%) → red (<30%)

### MP — Branch Focus

Full when changes are focused, depletes as changes spread across files and directories.

- Each changed file: -2
- Each directory touched: -6
- Color: teal → teal → pink (like MP recharging in KH)

### Command Duration

Shown as small text before the bars when a command takes >100ms. Format: `ms`, `s`, or `m`.

## Commands

### Gummi Ship Navigation (Git)

| Command | Description |
|---------|-------------|
| `ship` | List all branches as "worlds" |
| `traverse <branch>` | Switch to a branch |
| `unlock <branch>` | Create and switch to a new branch |
| `explore` | Detailed current branch status |
| `home` | Switch back to main/master |
| `sanctuary [branches]` | Delete branches except specified ones (keeps main, develop) |

### Save Points (Git Stash)

| Command | Description |
|---------|-------------|
| `save` | Stash changes with default message "Save Point" |
| `save "message"` | Stash changes with a custom message |
| `load` | Pop the latest stash |
| `load list` | List all save points with indices |
| `load <number>` | Apply a specific stash by index |

### Magic Casting (npm/pnpm)

```fish
cast dev          # Run the "dev" script
cast build        # Run the "build" script
cast [Tab]        # Tab completion for available scripts
```

Automatically detects pnpm (via `pnpm-lock.yaml`) or falls back to npm.

### System Status

| Command | Description |
|---------|-------------|
| `dive` | Deep status report (git + system info, KH themed) |
| `heartless` | Show Heartless encounter stats for this session |
| `kh_refresh` | Clear world/party detection caches |

### Heartless Encounters

When a command fails, a themed Heartless encounter appears based on the exit code:

| Exit Code | Heartless | Flavor |
|-----------|-----------|--------|
| 1 | Shadow | "A Shadow appeared!" |
| 2 | Soldier | "A Soldier heartless attacks!" |
| 126 | Large Body | "A Large Body blocks your path!" |
| 127 | Darkside | "Darkside rises from the darkness!" |
| 130 | Invisible | "You fled from the Invisible!" |
| 137 | Behemoth | "A Behemoth crushed your process!" |
| 139 | Guard Armor | "Guard Armor tore through memory!" |
| Other | Random | Neoshadow, Wyvern, Wizard, Defender, Angel Star, or Crimson Jazz |

Encounters are tracked per session — use the `heartless` command to see your defeat count and types.

### Pre-exec Quotes

Real Kingdom Hearts quotes appear occasionally (~33% of the time) before non-trivial commands. Quotes are attributed to characters from the series. They are skipped for trivial commands like `ls`, `cd`, `pwd`.

## Configuration

All settings use `set -g` and can be placed in your `config.fish` or set interactively:

```fish
set -g KH_PROMPT_MODE 'full'     # Prompt style: full | compact | minimal
set -g KH_SHOW_PARTY 'true'     # Show detected runtimes as party members
set -g KH_SHOW_WORLD 'true'     # Show project type as KH world name
set -g KH_SHOW_CLOCK 'true'     # Show clock in right prompt (on by default)
set -g KH_BAR_WIDTH 10          # Gauge bar width (auto-shrinks to 6 on narrow terminals)
set -g KH_HEARTLESS 'true'      # Show Heartless encounters on command failure
set -g KH_A11Y 'off'            # Accessibility: off | high-contrast | colorblind
```

### Accessibility Modes (`KH_A11Y`)

- **`off`** — Default palette with improved visibility for bar labels and empty gauge segments
- **`high-contrast`** — WCAG AA compliant (4.5:1+ contrast). Brightens all dim elements including borders, labels, and bar tracks
- **`colorblind`** — Replaces red/green with blue/orange to be safe for deuteranopia, protanopia, and tritanopia. Also includes the high-contrast readability improvements

## Color Palette

Authentic Kingdom Hearts colors sourced from the game UI:

| Variable | Hex | Usage |
|----------|-----|-------|
| `KH_BLUE` | `#2a6fc0` | Command menu borders (signature KH blue) |
| `KH_WHITE` | `#f9f9f9` | Menu text |
| `KH_GREEN` | `#00ff9f` | HP bar, success, staged files |
| `KH_RED` | `#ff2870` | HP critical, errors, modified files |
| `KH_GOLD` | `#f8c169` | Path display, golden yellow |
| `KH_CYAN` | `#00d7ff` | Branch names, commands |
| `KH_TEAL` | `#00b2d4` | MP bar |
| `KH_MAUVE` | `#dba8cd` | Behind count, stash, Kairi/Namine pink |
| `KH_SLATE` | `#8088a8` | Borders, dim text, comments |
| `KH_DARK` | `#3d3b6b` | Unselected row background, empty bar track |
| `KH_HILIGHT` | `#1f4290` | Selected row highlight background |
| `KH_SHADOW` | `#161a40` | Deep shadow for box depth |
| `KH_ICY` | `#c6e2f3` | Party members, world name, subtle text |
| `KH_LIME` | `#8ebc4f` | Valid paths |
| `KH_GLOW` | `#99f7ff` | Escape sequences, bright cyan |

## Installation

```bash
# Clone the repository
git clone https://github.com/emoralesb05/kh-fish-theme.git

# Backup your current fish config (optional)
cp -r ~/.config/fish ~/.config/fish-backup

# Copy theme files
cp -r kh-fish-theme/{config.fish,conf.d,functions,completions} ~/.config/fish/

# Reload
source ~/.config/fish/config.fish
```

## Prerequisites

- [Fish Shell](https://fishshell.com/) 3.0+
- [Git](https://git-scm.com/)
- [Node.js](https://nodejs.org/) (for `cast` command and party member detection)

## File Structure

```
├── config.fish                    # Main config: colors, prompt, right prompt, pre-exec
├── conf.d/
│   ├── kh_aliases.fish           # Aliases, dive, cast, kh_refresh
│   └── kh_env.fish               # Environment variables
├── functions/
│   ├── gummi_ship.fish           # Git branch management commands
│   ├── kh_heartless.fish         # Heartless encounter system
│   ├── kh_hud_helpers.fish       # HUD: git data, bars, party, world detection
│   ├── kingdom_hearts_welcome.fish # Welcome screen
│   ├── load.fish                 # Load Save Point (git stash pop/apply)
│   ├── sanctuary.fish            # Branch purification
│   └── save.fish                 # Save Point (git stash push)
└── completions/
    ├── cast.fish                 # Tab completion for cast
    ├── load.fish                 # Tab completion for load
    ├── sanctuary.fish            # Tab completion for sanctuary
    ├── save.fish                 # Tab completion for save
    ├── traverse.fish             # Tab completion for traverse
    └── unlock.fish               # Tab completion for unlock
```

## License

MIT

## Acknowledgments

- Inspired by the Kingdom Hearts series by Square Enix
- Colors sourced from KH1, KH2, and KH3 game UI
- Built with [Fish Shell](https://fishshell.com/)

---

**May your heart be your guiding key!**
