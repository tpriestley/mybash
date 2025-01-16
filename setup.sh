#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default to live run
DRY_RUN=false

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Function to print status messages
print_status() {
    echo -e "${GREEN}[*]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[x]${NC} $1"
}

print_dryrun() {
    echo -e "${YELLOW}[WOULD RUN]${NC} $1"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to execute or simulate command
execute_command() {
    if [ "$DRY_RUN" = true ]; then
        print_dryrun "$1"
    else
        eval "$1"
    fi
}

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --dry-run) DRY_RUN=true ;;
        -h|--help) 
            echo "Usage: $0 [--dry-run]"
            echo
            echo "Options:"
            echo "  --dry-run    Show what would be done without making actual changes"
            echo "  -h, --help   Show this help message"
            exit 0
            ;;
        *) print_error "Unknown parameter: $1"; exit 1 ;;
    esac
    shift
done

# Check if script is run as root
if [ "$EUID" -ne 0 ]; then
    print_error "Please run as root"
    exit 1
fi

# Check for required files and directories
STARSHIP_THEMES_DIR="${SCRIPT_DIR}/starships"
ALIASES_FILE="${SCRIPT_DIR}/.aliases"

if [ ! -d "$STARSHIP_THEMES_DIR" ]; then
    print_error "Starship themes directory not found at: $STARSHIP_THEMES_DIR"
    exit 1
fi

if [ ! -f "$ALIASES_FILE" ]; then
    print_error "Aliases file not found at: $ALIASES_FILE"
    exit 1
fi

# Check if there are any .toml files in the starship themes directory
THEME_COUNT=$(find "$STARSHIP_THEMES_DIR" -name "*.toml" | wc -l)
if [ "$THEME_COUNT" -eq 0 ]; then
    print_error "No .toml theme files found in: $STARSHIP_THEMES_DIR"
    exit 1
fi

if [ "$DRY_RUN" = true ]; then
    print_status "Running in DRY RUN mode - no changes will be made"
fi

# Update package lists
print_status "Updating package lists..."
execute_command "apt update"

# Add fastfetch PPA
print_status "Adding fastfetch PPA..."
execute_command "add-apt-repository -y ppa:zhangsongcui3371/fastfetch"
execute_command "apt update"

# Install dependencies
print_status "Installing dependencies..."
PACKAGES=(
    "zsh"
    "git"
    "curl"
    "wget"
    "fzf"
    "fastfetch"
)

# Install packages
for package in "${PACKAGES[@]}"; do
    if ! command_exists "$package"; then
        print_status "Installing $package..."
        execute_command "apt install -y $package"
    else
        print_warning "$package is already installed"
    fi
done

# Install Starship
if ! command_exists starship; then
    print_status "Installing Starship..."
    if [ "$DRY_RUN" = true ]; then
        print_dryrun "Would download and install Starship"
    else
        curl -sS https://starship.rs/install.sh | sh
    fi
else
    print_warning "Starship is already installed"
fi

# Install Zoxide
if ! command_exists zoxide; then
    print_status "Installing Zoxide..."
    if [ "$DRY_RUN" = true ]; then
        print_dryrun "Would download and install Zoxide"
    else
        curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
    fi
else
    print_warning "Zoxide is already installed"
fi

# Create necessary directories
print_status "Creating necessary directories..."
DIRECTORIES=(
    "~/.config"
    "~/.cache/zsh"
    "~/.local/share/zinit"
)

for dir in "${DIRECTORIES[@]}"; do
    if [ ! -d "$(eval echo $dir)" ]; then
        execute_command "mkdir -p $(eval echo $dir)"
    else
        print_warning "Directory $dir already exists"
    fi
done

# Create symbolic links
print_status "Creating symbolic links for Starship themes..."
STARSHIP_CONFIG_DIR="~/.config/starships"
execute_command "mkdir -p $(eval echo $STARSHIP_CONFIG_DIR)"

for theme in "$STARSHIP_THEMES_DIR"/*.toml; do
    if [ -f "$theme" ]; then
        theme_name=$(basename "$theme")
        source="$theme"
        target="$(eval echo $STARSHIP_CONFIG_DIR)/$theme_name"
        execute_command "ln -sf $source $target"
    fi
done

# Create a symbolic link for the aliases file
print_status "Creating symbolic link for aliases file..."
ALIASES_TARGET="~/.config/.aliases"
execute_command "ln -sf $ALIASES_FILE $(eval echo $ALIASES_TARGET)"

# Set ZSH as default shell
print_status "Setting ZSH as default shell..."
execute_command "chsh -s \$(which zsh) \$SUDO_USER"

if [ "$DRY_RUN" = true ]; then
    print_status "Dry run complete. No changes were made."
    print_status "Run without --dry-run to make actual changes."
else
    print_status "Installation complete! Please log out and log back in to start using ZSH."
    print_warning "Don't forget to copy your .zshrc file to ~/.zshrc"
    print_warning "Some manual steps may be required:"
    echo "1. Review the starship themes in ~/.config/starships/"
    echo "2. Review the aliases in ~/.config/.aliases"
    echo "3. Install any additional ZSH plugins you may want"

    # List available themes
    echo -e "\nAvailable starship themes:"
    for theme in "$STARSHIP_THEMES_DIR"/*.toml; do
        if [ -f "$theme" ]; then
            echo "- $(basename "$theme")"
        fi
    done
fi
