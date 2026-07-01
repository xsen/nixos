#!/usr/bin/env bash
# install.sh - Multi-host bootstrap script for NixOS configurations

set -euo pipefail

# Text formatting helper functions
info() { echo -e "\e[34m[INFO]\e[0m $*"; }
warn() { echo -e "\e[33m[WARN]\e[0m $*"; }
error() { echo -e "\e[31m[ERROR]\e[0m $*"; }
success() { echo -e "\e[32m[SUCCESS]\e[0m $*"; }

SCRIPT_DIR=$(dirname "$(realpath "$0")")
TARGET_LINK="$HOME/.nix-config"

echo "============================================="
echo "      NixOS xsen Multi-Host Bootstrap        "
echo "============================================="

# 1. Create/Verify Symlink
if [ -L "$TARGET_LINK" ]; then
    CURRENT_TARGET=$(readlink "$TARGET_LINK")
    if [ "$CURRENT_TARGET" = "$SCRIPT_DIR" ]; then
        info "Symlink $TARGET_LINK already correctly points to $SCRIPT_DIR."
    else
        warn "Symlink $TARGET_LINK exists but points to $CURRENT_TARGET."
        read -rp "Would you like to update it to point to $SCRIPT_DIR? [y/N]: " update_link
        update_link=${update_link:-N}
        if [[ "$update_link" =~ ^[Yy]$ ]]; then
            ln -sfn "$SCRIPT_DIR" "$TARGET_LINK"
            success "Updated symbolic link: $TARGET_LINK → $SCRIPT_DIR"
        fi
    fi
elif [ -e "$TARGET_LINK" ]; then
    warn "$TARGET_LINK exists but is not a symbolic link."
    read -rp "Would you like to backup and replace it with a symlink to $SCRIPT_DIR? [y/N]: " replace_link
    replace_link=${replace_link:-N}
    if [[ "$replace_link" =~ ^[Yy]$ ]]; then
        mv "$TARGET_LINK" "${TARGET_LINK}.backup-$(date +%s)"
        ln -sfn "$SCRIPT_DIR" "$TARGET_LINK"
        success "Replaced $TARGET_LINK with symbolic link to $SCRIPT_DIR."
    fi
else
    ln -sfn "$SCRIPT_DIR" "$TARGET_LINK"
    success "Created symbolic link: $TARGET_LINK → $SCRIPT_DIR"
fi

# 2. Scan for available hosts
HOSTS_DIR="$SCRIPT_DIR/hosts"
if [ ! -d "$HOSTS_DIR" ]; then
    mkdir -p "$HOSTS_DIR"
fi

# Find all directories inside hosts/ and sort them
mapfile -t AVAILABLE_HOSTS < <(find "$HOSTS_DIR" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort)

echo ""
echo "Select host configuration to deploy or configure:"
for i in "${!AVAILABLE_HOSTS[@]}"; do
    echo "  $((i+1))) ${AVAILABLE_HOSTS[i]}"
done
echo "  $(( ${#AVAILABLE_HOSTS[@]} + 1 ))) Create a new host configuration"

# Prompt for selection
read -rp "Enter choice [1-$(( ${#AVAILABLE_HOSTS[@]} + 1 ))] (default: 1): " choice
choice=${choice:-1}

# Validate choice input
if [[ ! "$choice" =~ ^[0-9]+$ ]]; then
    error "Invalid choice: must be a number."
    exit 1
fi

SELECTED_HOST=""
IS_NEW_HOST=false

if [ "$choice" -le "${#AVAILABLE_HOSTS[@]}" ]; then
    SELECTED_HOST="${AVAILABLE_HOSTS[$((choice-1))]}"
    info "Selected existing host config: $SELECTED_HOST"
elif [ "$choice" -eq "$(( ${#AVAILABLE_HOSTS[@]} + 1 ))" ]; then
    IS_NEW_HOST=true
    read -rp "Enter name for the new host: " new_host_name
    # Clean host name (lowercase, alphanumeric and hyphens only)
    SELECTED_HOST=$(echo "$new_host_name" | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9-')
    if [ -z "$SELECTED_HOST" ]; then
        error "Invalid host name specified."
        exit 1
    fi
    info "Creating new host config: $SELECTED_HOST"
else
    error "Invalid choice selection."
    exit 1
fi

HOST_DIR="$HOSTS_DIR/$SELECTED_HOST"
mkdir -p "$HOST_DIR"

# 3. Template copy process with safety prompts
TEMPLATE_SRC="$HOSTS_DIR/nix-desktop"
if [ -d "$TEMPLATE_SRC" ] && [ "$SELECTED_HOST" != "nix-desktop" ]; then
    # Determine if we should offer templates
    # (either new host, or existing directory missing configuration.nix or home-manager.nix)
    if [ "$IS_NEW_HOST" = true ] || [ ! -f "$HOST_DIR/configuration.nix" ] || [ ! -f "$HOST_DIR/home-manager.nix" ]; then
        echo ""
        read -rp "Would you like to copy configuration templates from 'nix-desktop'? [Y/n]: " copy_templates
        copy_templates=${copy_templates:-Y}
        if [[ "$copy_templates" =~ ^[Yy]$ ]]; then
            for file in "configuration.nix" "home-manager.nix"; do
                SRC_FILE="$TEMPLATE_SRC/$file"
                DST_FILE="$HOST_DIR/$file"
                
                if [ -f "$SRC_FILE" ]; then
                    if [ -f "$DST_FILE" ]; then
                        warn "$file already exists in $HOST_DIR."
                        read -rp "Overwrite existing $file? [y/N]: " overwrite_file
                        overwrite_file=${overwrite_file:-N}
                        if [[ ! "$overwrite_file" =~ ^[Yy]$ ]]; then
                            info "Skipped copying $file."
                            continue
                        fi
                    fi
                    cp "$SRC_FILE" "$DST_FILE"
                    success "Copied $file to $HOST_DIR."
                else
                    warn "Template source file $SRC_FILE not found."
                fi
            done
        fi
    fi
fi

# 4. Handle hardware-configuration.nix
HW_CONFIG_PATH="$HOST_DIR/hardware-configuration.nix"
GENERATE_HW=true

if [ -f "$HW_CONFIG_PATH" ]; then
    echo ""
    warn "hardware-configuration.nix already exists for host '$SELECTED_HOST'."
    read -rp "Do you want to overwrite it with this machine's hardware config? [y/N]: " overwrite_hw
    overwrite_hw=${overwrite_hw:-N}
    if [[ ! "$overwrite_hw" =~ ^[Yy]$ ]]; then
        GENERATE_HW=false
    fi
fi

if [ "$GENERATE_HW" = true ]; then
    if [ -f "/etc/nixos/hardware-configuration.nix" ]; then
        info "Copying hardware configuration from /etc/nixos/hardware-configuration.nix..."
        cp "/etc/nixos/hardware-configuration.nix" "$HW_CONFIG_PATH"
        success "Copied hardware configuration successfully."
    else
        info "Generating new hardware configuration using nixos-generate-config..."
        if command -v nixos-generate-config >/dev/null 2>&1; then
            nixos-generate-config --show-hardware-config > "$HW_CONFIG_PATH"
            success "Generated hardware configuration successfully."
        else
            error "nixos-generate-config not found and /etc/nixos/hardware-configuration.nix does not exist."
            error "Please manually place hardware-configuration.nix in $HOST_DIR."
            exit 1
        fi
    fi
fi

# 5. Git add (Vital for Flakes!)
echo ""
info "Registering configuration files in Git index..."
if git -C "$SCRIPT_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    # We use path relative to SCRIPT_DIR to be fully compatible with git worktrees/etc
    git -C "$SCRIPT_DIR" add -N "hosts/$SELECTED_HOST" || true
    success "Tracked files in hosts/$SELECTED_HOST using 'git add -N'."
else
    warn "Not a git repository. Remember that Nix Flakes require all files to be tracked in Git to build!"
fi

# 6. Success message and build instructions
echo ""
echo "============================================="
success "Configuration for host '$SELECTED_HOST' is ready!"
echo "============================================="
echo ""
echo "Next steps:"
echo "1. If this is a new host, ensure it is defined in flake.nix under outputs."
echo "   Example entry to add to flake.nix:"
echo "   --------------------------------------------------"
echo "   nixosConfigurations.\"$SELECTED_HOST\" = nixpkgs.lib.nixosSystem {"
echo "     specialArgs = { inherit inputs host; username = \"evgeny\"; };"
echo "     modules = ["
echo "       home-manager.nixosModules.home-manager"
echo "       catppuccin.nixosModules.catppuccin"
echo "       ./hosts/$SELECTED_HOST/configuration.nix"
echo "       { nixpkgs.pkgs = pkgs; }"
echo "     ];"
echo "   };"
echo "   --------------------------------------------------"
echo ""
echo "2. Build and apply the configuration by running:"
echo "   sudo nixos-rebuild switch --flake .#$SELECTED_HOST --extra-experimental-features \"nix-command flakes\""
echo ""
echo "Note: The configuration templates assume username 'evgeny'."
echo "If your target username is different, please update 'username' variable"
echo "in flake.nix and the host's configuration files before rebuilding."
echo ""