#!/bin/bash
# =============================================================================
# Minerva V3 — Install Script
# =============================================================================
# Deploys the rice configuration to ~/.config
# Creates backups of existing configs before overwriting.
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"
BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"

echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║           Minerva V3 — Installation Script                       ║"
echo "║                  Dual-Mode Hyprland Rice                          ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""

# === VALIDATE SOURCE FILES ===
echo "🔍 Validating source files..."
MISSING_FILES=0

check_exists() {
    if [[ ! -e "$1" ]]; then
        echo "  ✗ Missing: $1"
        MISSING_FILES=1
    fi
}

check_exists "$SCRIPT_DIR/colors/arcana.sh"
check_exists "$SCRIPT_DIR/colors/ghost.sh"
check_exists "$SCRIPT_DIR/templates"
check_exists "$SCRIPT_DIR/shared/hyprland"
check_exists "$SCRIPT_DIR/themes/arcana/hyprland.conf"
check_exists "$SCRIPT_DIR/themes/ghost/hyprland.conf"
check_exists "$SCRIPT_DIR/scripts"
check_exists "$SCRIPT_DIR/shared/rofi/config.rasi"
check_exists "$SCRIPT_DIR/shared/wezterm/wezterm.lua"
check_exists "$SCRIPT_DIR/generate-themes.sh"

if [[ $MISSING_FILES -eq 1 ]]; then
    echo ""
    echo "❌ Some source files are missing. Please check your Minerva V3 installation."
    exit 1
fi
echo "  ✓ All source files present"

# === BACKUP EXISTING CONFIGS ===
echo ""
echo "📦 Backing up existing configs to $BACKUP_DIR..."
mkdir -p "$BACKUP_DIR"

for dir in hypr waybar rofi swaync wezterm yazi micro starship.toml; do
    if [[ -e "$CONFIG_DIR/$dir" ]]; then
        cp -r "$CONFIG_DIR/$dir" "$BACKUP_DIR/" 2>/dev/null || true
        echo "  ✓ Backed up $dir"
    fi
done

# === Install Packages ===
echo ""
echo "📦 Installing required packages..."

# Pacman packages (official repos)
PACMAN_PKGS=(
    # Core Hyprland
    hyprland xdg-desktop-portal-hyprland
    # Terminal & Shell
    wezterm zsh starship
    # Launcher & Menus
    rofi-wayland
    # File Managers
    yazi
    # Clipboard
    wl-clipboard cliphist
    # Authentication
    polkit-gnome
    # Audio
    pipewire wireplumber pavucontrol
    # Network
    networkmanager nm-connection-editor
    # System Utilities
    brightnessctl qt6ct
    # Text Editor
    micro
    # Fonts
    ttf-jetbrains-mono ttf-font-awesome nerd-fonts
    # Build utilities
    gettext
    # command-not-found support
    pkgfile
)

# AUR packages
AUR_PKGS=(
    # Bar & Notifications
    waybar swaync
    # Wallpaper
    swww
    # Lock & Idle
    hyprlock hypridle
    # Screenshots
    hyprshot swappy
    # Zsh plugins
    zsh-autosuggestions zsh-syntax-highlighting
)

# Optional packages (prompt user)
AUR_OPTIONAL=(
    protonvpn-cli   # VPN for Ghost mode
    burpsuite       # Pentesting for Ghost mode
)

# Install pacman packages
echo ""
echo "📥 Installing official packages..."
for pkg in "${PACMAN_PKGS[@]}"; do
    if ! pacman -Qi "$pkg" &>/dev/null; then
        echo "  → Installing $pkg..."
        sudo pacman -S --noconfirm --needed "$pkg" || echo "  ⚠ Failed to install $pkg"
    else
        echo "  ✓ $pkg already installed"
    fi
done

# Install AUR packages
echo ""
echo "📥 Installing AUR packages..."
for pkg in "${AUR_PKGS[@]}"; do
    if ! pacman -Qi "$pkg" &>/dev/null; then
        echo "  → Installing $pkg..."
        yay -S --noconfirm --needed "$pkg" || echo "  ⚠ Failed to install $pkg"
    else
        echo "  ✓ $pkg already installed"
    fi
done

# Optional packages prompt
echo ""
read -p "🔧 Install optional packages (ProtonVPN, Burpsuite)? [y/N] " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    for pkg in "${AUR_OPTIONAL[@]}"; do
        if ! pacman -Qi "$pkg" &>/dev/null; then
            echo "  → Installing $pkg..."
            yay -S --noconfirm --needed "$pkg" || echo "  ⚠ Failed to install $pkg"
        else
            echo "  ✓ $pkg already installed"
        fi
    done
fi

echo ""
echo "✅ Package installation complete!"

# Update pkgfile database (for command-not-found plugin)
echo ""
echo "📦 Updating pkgfile database..."
sudo pkgfile --update
echo "  ✓ pkgfile database updated"

# === INSTALL OH-MY-ZSH ===
echo ""
echo "🐚 Setting up Zsh with Oh-My-Zsh..."

if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    echo "  → Installing Oh-My-Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    echo "  ✓ Oh-My-Zsh installed"
else
    echo "  ✓ Oh-My-Zsh already installed"
fi

# Link zsh plugins (they install to /usr/share, oh-my-zsh looks in custom/plugins)
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
mkdir -p "$ZSH_CUSTOM/plugins"

if [[ -d "/usr/share/zsh/plugins/zsh-autosuggestions" ]]; then
    ln -sfn "/usr/share/zsh/plugins/zsh-autosuggestions" "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    echo "  ✓ Linked zsh-autosuggestions"
fi

if [[ -d "/usr/share/zsh/plugins/zsh-syntax-highlighting" ]]; then
    ln -sfn "/usr/share/zsh/plugins/zsh-syntax-highlighting" "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
    echo "  ✓ Linked zsh-syntax-highlighting"
fi

# Deploy zshrc
echo "  → Installing .zshrc..."
if [[ -f "$HOME/.zshrc" ]]; then
    cp "$HOME/.zshrc" "$BACKUP_DIR/zshrc.backup"
    echo "  ✓ Backed up existing .zshrc"
fi
cp "$SCRIPT_DIR/shared/zshrc" "$HOME/.zshrc"
echo "  ✓ Installed .zshrc"

# Change default shell to zsh
if [[ "$SHELL" != *"zsh"* ]]; then
    echo "  → Setting zsh as default shell..."
    chsh -s $(which zsh)
    echo "  ✓ Default shell changed to zsh"
else
    echo "  ✓ Zsh is already default shell"
fi

# === CREATE CONFIG DIRECTORIES ===
echo ""
echo "📁 Creating config directories..."
mkdir -p "$CONFIG_DIR/hypr/themes/arcana/waybar"
mkdir -p "$CONFIG_DIR/hypr/themes/arcana/rofi"
mkdir -p "$CONFIG_DIR/hypr/themes/arcana/swaync"
mkdir -p "$CONFIG_DIR/hypr/themes/ghost/waybar"
mkdir -p "$CONFIG_DIR/hypr/themes/ghost/rofi"
mkdir -p "$CONFIG_DIR/hypr/themes/ghost/swaync"
mkdir -p "$CONFIG_DIR/hypr/shared"
mkdir -p "$CONFIG_DIR/hypr/scripts"
mkdir -p "$CONFIG_DIR/waybar"
mkdir -p "$CONFIG_DIR/rofi/scripts"
mkdir -p "$CONFIG_DIR/swaync"
mkdir -p "$CONFIG_DIR/wezterm"
mkdir -p "$CONFIG_DIR/micro"
mkdir -p "$CONFIG_DIR/yazi"
mkdir -p "$CONFIG_DIR/minerva-v3/colors"
mkdir -p "$CONFIG_DIR/minerva-v3/templates"
mkdir -p "$CONFIG_DIR/minerva-v3/notes"
mkdir -p "$HOME/Pictures/Wallpapers"
echo "  ✓ Config directories created"

# === COPY MINERVA V3 CORE FILES ===
echo ""
echo "🎨 Installing Minerva V3 core files..."

# Colors
echo "  → Copying color definitions..."
cp "$SCRIPT_DIR/colors/arcana.sh" "$CONFIG_DIR/minerva-v3/colors/"
cp "$SCRIPT_DIR/colors/ghost.sh" "$CONFIG_DIR/minerva-v3/colors/"
if [[ -f "$SCRIPT_DIR/colors/colors.sh" ]]; then
    cp "$SCRIPT_DIR/colors/colors.sh" "$CONFIG_DIR/minerva-v3/colors/"
fi
echo "  ✓ Color definitions"

# Generator script
cp "$SCRIPT_DIR/generate-themes.sh" "$CONFIG_DIR/minerva-v3/"
chmod +x "$CONFIG_DIR/minerva-v3/generate-themes.sh"
echo "  ✓ Theme generator"

# Templates
echo "  → Copying templates..."
cp -r "$SCRIPT_DIR/templates/"* "$CONFIG_DIR/minerva-v3/templates/"
echo "  ✓ Templates"

# === COPY SHARED CONFIGS ===
echo ""
echo "📋 Installing shared configurations..."

# Shared Hyprland configs
echo "  → Copying shared Hyprland configs..."
cp "$SCRIPT_DIR/shared/hyprland/"*.conf "$CONFIG_DIR/hypr/shared/"
echo "  ✓ Hyprland shared configs (execs, input, keybinds, rules)"

# Rofi config
echo "  → Copying Rofi config..."
cp "$SCRIPT_DIR/shared/rofi/config.rasi" "$CONFIG_DIR/rofi/"
if [[ -d "$SCRIPT_DIR/shared/rofi/scripts" ]]; then
    cp -r "$SCRIPT_DIR/shared/rofi/scripts/"* "$CONFIG_DIR/rofi/scripts/" 2>/dev/null || true
    find "$CONFIG_DIR/rofi/scripts" -type f -exec chmod +x {} \; 2>/dev/null || true
fi
echo "  ✓ Rofi config and scripts"

# WezTerm config
echo "  → Copying WezTerm config..."
cp "$SCRIPT_DIR/shared/wezterm/wezterm.lua" "$CONFIG_DIR/wezterm/"
echo "  ✓ WezTerm config"

# Micro config (if exists)
if [[ -d "$SCRIPT_DIR/shared/micro" ]]; then
    echo "  → Copying Micro config..."
    cp -r "$SCRIPT_DIR/shared/micro/"* "$CONFIG_DIR/micro/"
    echo "  ✓ Micro config"
fi

# Yazi config (if exists)
if [[ -d "$SCRIPT_DIR/shared/yazi" ]]; then
    echo "  → Copying Yazi config..."
    cp -r "$SCRIPT_DIR/shared/yazi/"* "$CONFIG_DIR/yazi/"
    echo "  ✓ Yazi config"
fi

# Starship config (if exists)
if [[ -f "$SCRIPT_DIR/shared/starship.toml" ]]; then
    echo "  → Copying Starship config..."
    cp "$SCRIPT_DIR/shared/starship.toml" "$CONFIG_DIR/starship.toml"
    echo "  ✓ Starship config"
fi

# === COPY THEME-SPECIFIC CONFIGS ===
echo ""
echo "🎭 Installing theme configurations..."

# === ARCANA THEME ===
echo "  → Installing Arcana theme..."
cp "$SCRIPT_DIR/themes/arcana/hyprland.conf" "$CONFIG_DIR/hypr/themes/arcana/"

if [[ -f "$SCRIPT_DIR/themes/arcana/waybar/config.jsonc" ]]; then
    cp "$SCRIPT_DIR/themes/arcana/waybar/config.jsonc" "$CONFIG_DIR/hypr/themes/arcana/waybar/"
fi

if [[ -f "$SCRIPT_DIR/themes/arcana/swaync/config.json" ]]; then
    cp "$SCRIPT_DIR/themes/arcana/swaync/config.json" "$CONFIG_DIR/hypr/themes/arcana/swaync/"
fi

echo "  ✓ Arcana theme base files"

# === GHOST THEME ===
echo "  → Installing Ghost theme..."
cp "$SCRIPT_DIR/themes/ghost/hyprland.conf" "$CONFIG_DIR/hypr/themes/ghost/"

if [[ -f "$SCRIPT_DIR/themes/ghost/waybar/config.jsonc" ]]; then
    cp "$SCRIPT_DIR/themes/ghost/waybar/config.jsonc" "$CONFIG_DIR/hypr/themes/ghost/waybar/"
fi

if [[ -f "$SCRIPT_DIR/themes/ghost/swaync/config.json" ]]; then
    cp "$SCRIPT_DIR/themes/ghost/swaync/config.json" "$CONFIG_DIR/hypr/themes/ghost/swaync/"
fi

if [[ -d "$SCRIPT_DIR/themes/ghost/waybar/scripts" ]]; then
    cp -r "$SCRIPT_DIR/themes/ghost/waybar/scripts" "$CONFIG_DIR/hypr/themes/ghost/waybar/"
    find "$CONFIG_DIR/hypr/themes/ghost/waybar/scripts" -type f -exec chmod +x {} \; 2>/dev/null || true
fi

echo "  ✓ Ghost theme base files"

# === SCRIPTS ===
echo ""
echo "⚡ Installing scripts..."
cp "$SCRIPT_DIR/scripts/"*.sh "$CONFIG_DIR/hypr/scripts/"
chmod +x "$CONFIG_DIR/hypr/scripts/"*.sh
echo "  ✓ Scripts installed and made executable"

# === SET DEFAULT MODE & GENERATE THEMES ===
echo ""
echo "🔮 Setting default mode to Arcana..."
echo "arcana" > "$HOME/.current-mode"
cp "$CONFIG_DIR/minerva-v3/colors/arcana.sh" "$CONFIG_DIR/minerva-v3/colors/colors.sh"
echo "  ✓ Default mode set"

# === GENERATE THEMES ===
echo ""
echo "🎨 Generating theme files from templates..."
cd "$CONFIG_DIR/minerva-v3"
if ./generate-themes.sh; then
    echo "  ✓ Themes generated successfully"
else
    echo "  ⚠ Theme generation had issues, trying to continue..."
fi

# === ALSO GENERATE GHOST THEME ===
echo ""
echo "🎨 Generating Ghost theme..."
cp "$CONFIG_DIR/minerva-v3/colors/ghost.sh" "$CONFIG_DIR/minerva-v3/colors/colors.sh"
if ./generate-themes.sh; then
    echo "  ✓ Ghost theme generated"
else
    echo "  ⚠ Ghost theme generation had issues"
fi

# Restore arcana as active
cp "$CONFIG_DIR/minerva-v3/colors/arcana.sh" "$CONFIG_DIR/minerva-v3/colors/colors.sh"
echo "arcana" > "$HOME/.current-mode"

# === VERIFY GENERATED FILES ===
echo ""
echo "🔍 Verifying generated theme files..."
VERIFY_PASS=1

verify_file() {
    if [[ -f "$1" ]]; then
        echo "  ✓ $2"
    else
        echo "  ✗ Missing: $2"
        VERIFY_PASS=0
    fi
}

verify_file "$CONFIG_DIR/hypr/themes/arcana/waybar/style.css" "Arcana Waybar CSS"
verify_file "$CONFIG_DIR/hypr/themes/arcana/rofi/colors.rasi" "Arcana Rofi colors"
verify_file "$CONFIG_DIR/hypr/themes/arcana/swaync/style.css" "Arcana swaync CSS"
verify_file "$CONFIG_DIR/hypr/themes/ghost/waybar/style.css" "Ghost Waybar CSS"
verify_file "$CONFIG_DIR/hypr/themes/ghost/rofi/colors.rasi" "Ghost Rofi colors"
verify_file "$CONFIG_DIR/hypr/themes/ghost/swaync/style.css" "Ghost swaync CSS"

if [[ $VERIFY_PASS -eq 0 ]]; then
    echo ""
    echo "⚠️  Some theme files were not generated. Check generate-themes.sh output above."
fi

# === CREATE SYMLINKS ===
echo ""
echo "🔗 Creating symlinks for active theme (Arcana)..."

# Remove old symlinks/files first
rm -f "$CONFIG_DIR/hypr/hyprland.conf"
rm -f "$CONFIG_DIR/waybar/config.jsonc"
rm -f "$CONFIG_DIR/waybar/style.css"
rm -f "$CONFIG_DIR/rofi/colors.rasi"
rm -f "$CONFIG_DIR/swaync/style.css"

# Create new symlinks
ln -sf "$CONFIG_DIR/hypr/themes/arcana/hyprland.conf" "$CONFIG_DIR/hypr/hyprland.conf"
echo "  ✓ Hyprland config → arcana"

if [[ -f "$CONFIG_DIR/hypr/themes/arcana/waybar/config.jsonc" ]]; then
    ln -sf "$CONFIG_DIR/hypr/themes/arcana/waybar/config.jsonc" "$CONFIG_DIR/waybar/config.jsonc"
    echo "  ✓ Waybar config → arcana"
fi

if [[ -f "$CONFIG_DIR/hypr/themes/arcana/waybar/style.css" ]]; then
    ln -sf "$CONFIG_DIR/hypr/themes/arcana/waybar/style.css" "$CONFIG_DIR/waybar/style.css"
    echo "  ✓ Waybar style → arcana"
fi

if [[ -f "$CONFIG_DIR/hypr/themes/arcana/rofi/colors.rasi" ]]; then
    ln -sf "$CONFIG_DIR/hypr/themes/arcana/rofi/colors.rasi" "$CONFIG_DIR/rofi/colors.rasi"
    echo "  ✓ Rofi colors → arcana"
fi

if [[ -f "$CONFIG_DIR/hypr/themes/arcana/swaync/style.css" ]]; then
    ln -sf "$CONFIG_DIR/hypr/themes/arcana/swaync/style.css" "$CONFIG_DIR/swaync/style.css"
    echo "  ✓ swaync style → arcana"
fi

# Copy swaync config (not symlink - it's shared)
if [[ -f "$CONFIG_DIR/hypr/themes/arcana/swaync/config.json" ]]; then
    cp "$CONFIG_DIR/hypr/themes/arcana/swaync/config.json" "$CONFIG_DIR/swaync/config.json"
    echo "  ✓ swaync config installed"
fi

# === WALLPAPER PLACEHOLDER ===
echo ""
echo "🖼️  Checking wallpapers..."
if [[ ! -f "$HOME/Pictures/Wallpapers/arcana-wallpaper.jpg" ]]; then
    echo "  ⚠️  No arcana-wallpaper.jpg found. Add one to ~/Pictures/Wallpapers/"
else
    echo "  ✓ Arcana wallpaper found"
fi
if [[ ! -f "$HOME/Pictures/Wallpapers/ghost-wallpaper.jpg" ]]; then
    echo "  ⚠️  No ghost-wallpaper.jpg found. Add one to ~/Pictures/Wallpapers/"
else
    echo "  ✓ Ghost wallpaper found"
fi

echo ""
echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║                    Installation Complete!                          ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""
echo "📋 Next steps:"
echo "   1. Add wallpapers to ~/Pictures/Wallpapers/"
echo "      • arcana-wallpaper.jpg"
echo "      • ghost-wallpaper.jpg"
echo "   2. Log out and select Hyprland from your display manager"
echo "   3. Use Super+Shift+G to switch between Arcana and Ghost modes"
echo ""
echo "📁 Config locations:"
echo "   • Colors:    ~/.config/minerva-v3/colors/"
echo "   • Hyprland:  ~/.config/hypr/"
echo "   • Themes:    ~/.config/hypr/themes/{arcana,ghost}/"
echo "   • Notes:     ~/.config/minerva-v3/notes/"
echo ""
echo "🎮 Keybinds:"
echo "   • Super+Return   → Terminal (WezTerm)"
echo "   • Super+Tab      → App Launcher (Rofi)"
echo "   • Super+X        → Power Menu"
echo "   • Super+N        → Quick Notes"
echo "   • Super+Shift+G  → Switch Mode"
echo ""
echo "🔧 To regenerate themes after color changes:"
echo "   cd ~/.config/minerva-v3 && ./generate-themes.sh"
echo ""
