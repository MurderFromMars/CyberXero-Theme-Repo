# CYBERXERO — Neon KDE Experience

CyberXero is a complete KDE Plasma customization suite designed to deliver a cohesive, cyberpunk‑inspired desktop environment. It applies a unified visual style across Plasma, KWin, icons, color schemes, and terminal tools, all deployed through an automated installer.

CyberXero includes:

• CyberXero KDE color scheme  
• YAMIS monochrome icon theme  
• Custom Plasma layout and widgets  
• KWin rules, effects, and rounded corners  
• Kyanite dynamic workspaces script  
• Krohnkite tiling script  
• Kurve window decoration  
• Plasma Panel Colorizer  
• Themed configurations for btop, kitty, and fastfetch  
• A fully automated install.sh deployment script

## Quick Install

Run this command in any shell:

```
bash <(curl -fsSL https://raw.githubusercontent.com/MurderFromMars/CyberXero-Theme-Repo/main/install.sh)
```

The installer will:

• Clone or update the CyberXero repository  
• Detect whether the system is Arch‑based or Debian‑based  
• Install required dependencies  
• Build and install Plasma Panel Colorizer, Kurve, KDE Rounded Corners, and Krohnkite  
• Install and extract the Kyanite dynamic workspace script  
• Deploy configuration folders for btop, kitty, and fastfetch  
• Deploy kwinrc, plasmarc, plasma‑appletsrc, and kwinrulesrc  
• Install the YAMIS icon theme and CyberXero color scheme  
• Apply theme settings to KDE  
• Restart Plasma  
• Create a timestamped backup of all replaced configuration files

## Repository Structure

```
CyberXero-Theme-Repo/
│
├── btop/
├── kitty/
├── fastfetch/
│
├── YAMIS/
├── CyberXero.colors
│
├── kyanite.kwinscript
│
├── kwinrc
├── kwinrulesrc
├── plasmarc
├── plasma-org.kde.plasma.desktop-appletsrc
│
└── install.sh
```

## Features

### Visual Theme
A dark, neon‑accented cyberpunk aesthetic applied consistently across Plasma and KWin.

### Plasma Layout
Custom panel layout, widget configuration, and dynamic panel coloring via Plasma Panel Colorizer.

### Window Management
Krohnkite tiling, KDE Rounded Corners, and KWin rules tuned for the CyberXero environment.

## Kyanite — Dynamic Workspaces for KDE

Kyanite is a custom KWin script created specifically for CyberXero. It introduces dynamic workspaces to KDE Plasma by automatically adding or removing workspaces based on window usage.

Kyanite provides:

• Automatic creation of new workspaces  
• Automatic cleanup of empty workspaces  
• A fluid, adaptive workflow  
• Zero manual configuration  
• Automatic installation through the CyberXero installer

Kyanite is extracted into:

```
~/.local/share/kwin/scripts/kyanite/
```

## Terminal Configuration
