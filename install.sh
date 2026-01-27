#!/usr/bin/env bash
set -euo pipefail

########################################
# CYBERXERO :: NEON SYSTEM INITIALIZER
########################################

REPO_DIR="$HOME/CyberXero-Theme-Repo"
BACKUP_DIR="$HOME/CyberXero-backup-$(date +%Y%m%d_%H%M%S)"

# ────────────────────────────────────────────────
# LOGGING
# ────────────────────────────────────────────────

log()  { printf "\033[1;36m[Ξ]\033[0m %s\n" "$1"; }
ok()   { printf "\033[1;32m[✔]\033[0m %s\n" "$1"; }
warn() { printf "\033[1;33m[!]\033[0m %s\n" "$1"; }
err()  { printf "\033[1;31m[✖]\033[0m %s\n" "$1" >&2; }

backup_file() {
    local target="$1"
    if [ -e "$target" ]; then
        mkdir -p "$BACKUP_DIR"
        cp -a "$target" "$BACKUP_DIR/"
        log "backup → $target"
    fi
}

# ────────────────────────────────────────────────
# FETCH REPOSITORY
# ────────────────────────────────────────────────

fetch_repo() {
    log "syncing CyberXero repository…"

    if [ ! -d "$REPO_DIR/.git" ]; then
        git clone https://github.com/MurderFromMars/CyberXero-Theme-Repo "$REPO_DIR"
        ok "repository cloned"
    else
        cd "$REPO_DIR"
        git pull --rebase
        cd ~
        ok "repository updated"
    fi
}

ensure_repo() {
    [ -d "$REPO_DIR" ] || { err "repository missing"; exit 1; }
}

# ────────────────────────────────────────────────
# DISTRO DETECTION
# ────────────────────────────────────────────────

DISTRO="unknown"

detect_distro() {
    log "scanning system architecture…"

    if command -v pacman >/dev/null 2>&1; then
        DISTRO="arch"
        ok "arch‑based system detected"
    elif command -v apt >/dev/null 2>&1; then
        DISTRO="debian"
        ok "debian‑based system detected"
    else
        err "unsupported distribution"
        exit 1
    fi
}

# ────────────────────────────────────────────────
# DEPENDENCIES
# ────────────────────────────────────────────────

install_arch_aur_pkg() {
    local pkg="$1"

    if command -v yay >/dev/null 2>&1; then
        yay -S --needed --noconfirm "$pkg"
        return
    fi

    if command -v paru >/dev/null 2>&1; then
        paru -S --needed --noconfirm "$pkg"
        return
    fi

    warn "AUR helper not found → $pkg skipped"
}

install_arch_dependencies() {
    log "installing arch dependencies…"

    sudo pacman -S --needed --noconfirm \
        git cmake extra-cmake-modules base-devel unzip

    install_arch_aur_pkg qt5-tools
    ok "arch dependencies installed"
}

install_debian_dependencies() {
    log "installing debian dependencies…"

    sudo apt update
    sudo apt install -y \
        git cmake g++ extra-cmake-modules kwin-dev unzip \
        qt6-base-private-dev qt6-base-dev-tools \
        libkf6kcmutils-dev libdrm-dev libplasma-dev

    ok "debian dependencies installed"
}

install_dependencies() {
    case "$DISTRO" in
        arch)   install_arch_dependencies ;;
        debian) install_debian_dependencies ;;
        *)      err "invalid distro state"; exit 1 ;;
    esac
}

# ────────────────────────────────────────────────
# BUILD FROM SOURCE
# ────────────────────────────────────────────────

build_panel_colorizer() {
    log "compiling plasma‑panel‑colorizer…"

    local tmp="$(mktemp -d)"
    git clone https://github.com/luisbocanegra/plasma-panel-colorizer "$tmp/src"

    cd "$tmp/src"
    chmod +x install.sh
    ./install.sh

    cd ~
    rm -rf "$tmp"
    ok "panel colorizer installed"
}

build_kurve() {
    log "compiling kurve…"

    local tmp="$(mktemp -d)"
    git clone https://github.com/luisbocanegra/kurve "$tmp/src"

    cd "$tmp/src"
    mkdir build && cd build
    cmake ..
    cmake --build . -j"$(nproc)"
    sudo make install

    cd ~
    rm -rf "$tmp"
    ok "kurve installed"
}

install_krohnkite() {
    log "checking krohnkite…"

    local dir="$HOME/.local/share/kwin/scripts/krohnkite"

    if [ -d "$dir" ]; then
        ok "krohnkite already present"
        return
    fi

    log "installing krohnkite…"

    local tmp="$(mktemp -d)"
    git clone https://codeberg.org/anametologin/Krohnkite "$tmp/src"

    cd "$tmp/src"
    chmod +x install.sh
    ./install.sh

    cd ~
    rm -rf "$tmp"
    ok "krohnkite installed"
}

build_kde_rounded_corners() {
    log "compiling kde‑rounded‑corners…"

    local tmp="$(mktemp -d)"
    git clone https://github.com/matinlotfali/KDE-Rounded-Corners "$tmp/src"

    cd "$tmp/src"
    mkdir build && cd build
    cmake ..
    cmake --build . -j"$(nproc)"
    sudo make install

    cd ~
    rm -rf "$tmp"
    ok "rounded corners installed"
}

# ────────────────────────────────────────────────
# KYANITE INSTALLATION
# ────────────────────────────────────────────────

install_kyanite() {
    log "deploying kyanite kwinscript…"

    local script="$REPO_DIR/kyanite.kwinscript"
    local target="$HOME/.local/share/kwin/scripts/kyanite"

    if [ ! -f "$script" ]; then
        warn "kyanite.kwinscript missing in repo"
        return
    fi

    if [ -d "$target" ]; then
        ok "kyanite already installed"
        return
    fi

    mkdir -p "$target"
    unzip -q "$script" -d "$target"

    ok "kyanite installed → $target"
}

# ────────────────────────────────────────────────
# CONFIG DEPLOYMENT
# ────────────────────────────────────────────────

deploy_config_folders() {
    log "deploying configuration modules…"

    local folders=(btop kitty fastfetch)

    for f in "${folders[@]}"; do
        if [ -d "$REPO_DIR/$f" ]; then
            backup_file "$HOME/.config/$f"
            rm -rf "$HOME/.config/$f"
            cp -r "$REPO_DIR/$f" "$HOME/.config/$f"
            ok "config → $f"
        else
            warn "missing → $f"
        fi
    done
}

deploy_rc_files() {
    log "deploying plasma rc files…"

    local rc_files=(
        kwinrc
        plasmarc
        plasma-org.kde.plasma.desktop-appletsrc
    )

    for rc in "${rc_files[@]}"; do
        if [ -f "$REPO_DIR/$rc" ]; then
            backup_file "$HOME/.config/$rc"
            cp "$REPO_DIR/$rc" "$HOME/.config/$rc"
            ok "rc → $rc"
        else
            warn "missing → $rc"
        fi
    done
}

deploy_yamis_icons() {
    log "installing YAMIS icon theme…"

    mkdir -p "$HOME/.local/share/icons"

    if [ -d "$REPO_DIR/YAMIS" ]; then
        cp -r "$REPO_DIR/YAMIS" "$HOME/.local/share/icons/"
        ok "icons → YAMIS"
    else
        warn "YAMIS icon set missing"
    fi
}

deploy_color_scheme() {
    log "installing CyberXero color scheme…"

    mkdir -p "$HOME/.local/share/color-schemes"

    if [ -f "$REPO_DIR/CyberXero.colors" ]; then
        cp "$REPO_DIR/CyberXero.colors" "$HOME/.local/share/color-schemes/"
        ok "colors → CyberXero"
    else
        warn "CyberXero.colors missing"
    fi
}

# ────────────────────────────────────────────────
# THEME ACTIVATION
# ────────────────────────────────────────────────

apply_kde_theme_settings() {
    log "activating neon theme parameters…"

    local cfg="$HOME/.config/kdeglobals"
    backup_file "$cfg"
    touch "$cfg"

    # Color Scheme
    if grep -q "^ColorScheme=" "$cfg"; then
        sed -i "s/^ColorScheme=.*/ColorScheme=CyberXero/" "$cfg"
    else
        echo "ColorScheme=CyberXero" >> "$cfg"
    fi

    # Icons
    if ! grep -q "^

\[Icons\]

" "$cfg"; then
        {
            echo ""
            echo "[Icons]"
            echo "Theme=YAMIS"
        } >> "$cfg"
    else
        if grep -q "^Theme=" "$cfg"; then
            sed -i "s/^Theme=.*/Theme=YAMIS/" "$cfg"
        else
            sed -i "/^

\[Icons\]

/a Theme=YAMIS" "$cfg"
        fi
    fi

    ok "theme activated → CyberXero + YAMIS"
}

# ────────────────────────────────────────────────
# PLASMA RELOAD
# ────────────────────────────────────────────────

reload_plasmashell() {
    log "reloading plasma shell…"

    if command -v qdbus6 >/dev/null 2>&1; then
        qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.quit || true
    elif command -v qdbus >/dev/null 2>&1; then
        qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.quit || true
    else
        pkill plasmashell || true
    fi

    sleep 2

    if command -v kstart5 >/dev/null 2>&1; then
        kstart5 plasmashell >/dev/null 2>&1 & disown
    else
        plasmashell >/dev/null 2>&1 & disown
    fi

    ok "plasmashell restarted"
}

# ────────────────────────────────────────────────
# MAIN EXECUTION
# ────────────────────────────────────────────────

main() {
    printf "\n\033[1;35m┌──────────────────────────────────────────────┐\n"
    printf   "│   CYBERXERO :: NEON SYSTEM DEPLOYMENT        │\n"
    printf   "└──────────────────────────────────────────────┘\033[0m\n\n"

    fetch_repo
    ensure_repo
    detect_distro
    install_dependencies

    build_panel_colorizer
    build_kurve
    install_krohnkite
    build_kde_rounded_corners
    install_kyanite

    deploy_config_folders
    deploy_rc_files
    deploy_yamis_icons
    deploy_color_scheme
    apply_kde_theme_settings

    reload_plasmashell

    printf "\n\033[1;32m[✔] CYBERXERO DEPLOYMENT COMPLETE\033[0m\n"
    printf "\033[1;36mbackup archive → $BACKUP_DIR\033[0m\n\n"
}

main "$@"
