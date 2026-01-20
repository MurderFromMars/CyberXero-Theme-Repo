# CyberXero Theme

A futuristic tiling‑inspired setup for KDE Plasma on XeroLinux.  
CyberXero delivers a dark, high‑contrast interface with vibrant cyan and magenta accents, blending the efficiency of a tiling window manager with the flexibility of Plasma.

## Features
- A tiling workflow powered by Krohnkite and Kyanite
- A cohesive neon‑infused visual style
- Rounded corners, panel colorization, and audio‑reactive elements
- Custom Plasma configuration for a ready‑to‑use layout
- Integrated icon and color schemes

## Installation Instructions

### 1. Extract the Theme Files
Unzip the archive. Move all folders except YAMIS into:
~/.config

Move the YAMIS icon pack into:
~/.local/share/icons

Move CyberXero.colors into:
~/.local/share/color-schemes

Create any missing folders as needed.

### 2. Install Dependencies Before Copying RC Files
Do not overwrite your Plasma RC files yet.  
Install all required scripts and effects listed in the Dependencies section.

After everything is installed and working, replace:
kwinrc  
kwinrulesrc  
Plasma applet rc files  

Then reboot to apply the full CyberXero layout.

You may need to reassign the application launcher icon.  
Right click the launcher area, open Configure, and set your preferred icon.

### 3. Fastfetch Logo Path
If you use Fastfetch, update the logo path in your config to match your user directory and chosen image.

## Dependencies

### Krohnkite
Tiling manager for KWin  
Install through KDE Settings → KWin Scripts → Get New Scripts

### Kyanite
Dynamic workspace script for Plasma 6  
Included in the repository  
Install through KDE Settings → KWin Scripts → Install from Local File

### KDE Rounded Corners
Adds smooth rounded corners to windows  
https://github.com/matinlotfali/KDE-Rounded-Corners  
Can be built from source or installed from the AUR  
Requires rebuilding after KWin updates

### Panel Colorizer
Customizes Plasma panel colors  
https://github.com/luisbocanegra/plasma-panel-colorizer  
Install from source or through Add Widgets

### Kurve
Audio visualizer for the Plasma panel  
https://github.com/luisbocanegra/kurve  
Install from source or through Add Widgets

## Final Notes
Special thanks to DarkXero for the opportunity to build and share this theme, and appreciation to the respective projects listed above whose work makes CyberXero possible.
