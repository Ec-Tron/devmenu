#!/usr/bin/env bash

clear
set -e

INSTALL_DIR="/usr/local/share/devmenu"
BIN_PATH="/usr/local/bin/devmenu"

echo "Installing Dev Menu..."

if [ "$EUID" -ne 0 ]; then
	echo "Please run this installer with sudo:"
	echo "sudo ./install.sh"
	exit 1
fi

mkdir -p "$INSTALL_DIR"

cp dev-menu.sh "$INSTALL_DIR/"
cp -r plugins "$INSTALL_DIR/"

chmod +x "$INSTALL_DIR/dev-menu.sh"

cat > "$BIN_PATH" <<EOF
#!/usr/bin/env bash
exec "$INSTALL_DIR/dev-menu.sh" "\$@"
EOF

chmod +x "$BIN_PATH"

echo
echo "Installation complete!"
echo
echo "Run Dev Menu with:"
echo "devmenu"
