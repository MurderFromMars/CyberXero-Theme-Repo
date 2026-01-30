# CyberXero

A Neon Cyberpunk Tiling Experience for KDE Plasma 6

CyberXero began as the official KDE tiling theme I created for XeroLinux. After completing the design, DarkXero approved the final version, but the theme was complex enough that no simple installer existed for it. I took it upon myself to build that installation script, and in the process the project evolved far beyond a theme.

Today, CyberXero is a complete Plasma 6 transformation engine. It reshapes KDE into a cohesive tiling window manager experience with a neon cyberpunk aesthetic, dynamic GNOME‑style workspaces, and a fully automated setup process that rebuilds your desktop from the ground up.
What CyberXero Is

## CyberXero is not a theme pack
---.
It is a behavior‑driven desktop environment initializer that:

• Converts Plasma into a dynamic tiling environment
• Adds true GNOME‑style dynamic workspaces
• Applies a unified neon cyberpunk visual identity
• Installs and configures all required components automatically
• Backs up your existing configuration before making changes

The result is a Plasma experience that feels more like a modern TWM than a traditional desktop.
Quick Install
```
curl -fsSL https://raw.githubusercontent.com/MurderFromMars/CyberXero/main/install.sh  | bash
```
# Core Features
---

## Dynamic Workspaces (Kyanite)

Kyanite brings GNOME‑style dynamic workspaces to Plasma 6:

• Workspaces appear when needed
• Empty workspaces disappear
• One empty workspace is always available
• Workspace lifecycle is driven entirely by window movement

Kyanite is built specifically for Plasma 6 and is a core part of CyberXero.
Repository: https://github.com/MurderFromMars/Kyanite
Dynamic Tiling (Krohnkite)

## Krohnkite provides automatic tiling inside each workspace:

• Clean, predictable tiling behavior
• Layout cycling
• Window movement and focus navigation
• Works seamlessly with Kyanite

CyberXero includes my personal configuration for Krohnkite.
users may need to adjust gaps depending on screen resolution to their liking.

## CyberXero applies a cohesive neon cyberpunk aesthetic using:

• plasma‑panel‑colorizer for dynamic panel theming
• kurve for Cava‑powered audio visualization
• KDE Rounded Corners for smooth edges and shadows
• YAMIS icon theme
• CyberXero color scheme

The result is a unified, glowing, futuristic interface.
Supported Systems

# CyberXero supports:
---

• Arch Linux and Arch‑based distributions
• Debian and Ubuntu‑based distributions

KDE Plasma 6 is required.
What the Installer Does

# The CyberXero initializer:

---

• Clones or updates the repository
• Detects your distribution
• Installs all required dependencies
• Builds KDE components when needed
• Deploys KWin scripts and enables them
• Installs themes, icons, and color schemes
• Applies curated configuration files
• Restarts Plasma Shell to apply changes

All existing configuration is backed up automatically.


# Dependencies Installed
---

## Arch Linux

• git
• cmake
• extra‑cmake‑modules
• base‑devel
• unzip
• qt5‑tools (via yay or paru when available)

## Debian / Ubuntu

• git
• cmake
• g++
• extra‑cmake‑modules
• kwin‑dev
• qt6 base and development tools
• KDE Frameworks 6 development libraries
Configuration Applied
Directories (to ~/.config)

• kitty
• btop
• fastfetch
• cava

Existing directories are backed up before replacement.
KDE Configuration Files (to ~/.config)

• kwinrc
• plasmarc
• plasma‑org.kde.plasma.desktop‑appletsrc
• kwinrulesrc
• breezerc
Themes

• Color Scheme: CyberXero
• Icon Theme: YAMIS (installed to ~/.local/share/icons)
KWin Scripts Enabled

• Krohnkite for tiling
• Kyanite for dynamic workspaces

KWin is reloaded automatically.
Backups

Before any changes are made, CyberXero creates a timestamped backup:

~/CyberXero‑backup‑YYYYMMDD_HHMMSS


# Configure Keybindings (Required)

---

CyberXero does not install keybindings.
Set them manually under:

System Settings → Shortcuts

I recommend at minimum setting keybinds for  close, minimiz, and maximize windows

