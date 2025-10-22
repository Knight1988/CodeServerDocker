#!/usr/bin/env bash
set -e

echo "==================== Code-Server Entrypoint ===================="
echo "Starting code-server initialization..."

CONFIG_DIR="/config/.config/code-server"
CONFIG_FILE="${CONFIG_DIR}/config.yaml"

echo "Configuration directory: $CONFIG_DIR"
echo "Configuration file: $CONFIG_FILE"

# Ensure config directory exists
echo "Creating configuration directory..."
mkdir -p "$CONFIG_DIR"
echo "Configuration directory created successfully."

# Create or update config.yaml with password
if [ -n "$PASSWORD" ]; then
    echo "Password environment variable detected."
    echo "Setting password for code-server..."
    if command -v yq >/dev/null 2>&1; then
        echo "Using yq to update configuration..."
        yq eval -i ".password = \"$PASSWORD\"" "$CONFIG_FILE" 2>/dev/null || \
        (echo "Fallback: Writing password directly to config file..." && echo "password: \"$PASSWORD\"" > "$CONFIG_FILE")
    else
        echo "yq not found, writing password directly to config file..."
        echo "password: \"$PASSWORD\"" > "$CONFIG_FILE"
    fi
    echo "Password configuration completed."
else
    echo "WARNING: PASSWORD environment variable not set!"
    echo "Starting code-server without password authentication."
fi

echo "Configuration setup completed."
echo "================================================================"
echo ""

# Install extensions if not already installed
EXTENSIONS_DIR="/config/.local/share/code-server/extensions"
EXTENSION_SRC_DIR="/usr/local/share/code-server-extensions"

echo "Checking extensions..."
if [ -d "$EXTENSION_SRC_DIR" ]; then
    echo "Installing extensions from $EXTENSION_SRC_DIR..."
    for vsix in "$EXTENSION_SRC_DIR"/*.vsix; do
        if [ -f "$vsix" ]; then
            echo "Installing extension: $(basename "$vsix")"
            code-server --user-data-dir /config/.local/share/code-server --install-extension "$vsix" || echo "Warning: Failed to install $(basename "$vsix")"
        fi
    done
    echo "Extension installation completed."
else
    echo "No extension directory found, skipping extension installation."
fi

echo ""
echo "Starting code-server with the following settings:"
echo "  - Bind address: 0.0.0.0:8443"
echo "  - User data directory: /config/.local/share/code-server"
echo "  - Authentication: password"
echo ""
echo "================================================================"

# Start code-server
exec code-server --bind-addr 0.0.0.0:8443 --user-data-dir /config/.local/share/code-server --auth password

