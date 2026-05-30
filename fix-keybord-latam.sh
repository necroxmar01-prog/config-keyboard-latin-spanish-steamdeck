#!/bin/bash
# fix-keyboard-latam.sh
# Configura teclado LATAM persistente en SteamOS (gaming + escritorio)

set -e

echo "==> Configurando teclado LATAM en SteamOS..."

# --- 1. Modo gaming (Wayland) via /etc/environment ---
echo "[1/4] Configurando modo gaming (XKB_DEFAULT)..."

ENV_FILE="/etc/environment"

for VAR in XKB_DEFAULT_LAYOUT XKB_DEFAULT_MODEL; do
  sudo sed -i "/^${VAR}=/d" "$ENV_FILE"
done

echo "XKB_DEFAULT_LAYOUT=latam" | sudo tee -a "$ENV_FILE" > /dev/null
echo "XKB_DEFAULT_MODEL=pc105"  | sudo tee -a "$ENV_FILE" > /dev/null

# --- 2. Modo escritorio (Xorg/KDE) via localectl ---
echo "[2/4] Configurando modo escritorio (localectl)..."
sudo localectl set-x11-keymap latam pc105

# --- 3. Sesión X actual ---
echo "[3/4] Aplicando en sesión X actual..."
if command -v setxkbmap &> /dev/null; then
  setxkbmap -layout latam -model pc105
  echo "    Layout aplicado en esta sesión."
else
  echo "    setxkbmap no disponible (normal en Wayland puro)."
fi

# --- 4. Autostart para modo escritorio ---
echo "[4/4] Creando autostart para modo escritorio..."
AUTOSTART_DIR="$HOME/.config/autostart"
mkdir -p "$AUTOSTART_DIR"

cat > "$AUTOSTART_DIR/set-keyboard-latam.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Set LATAM Keyboard
Exec=setxkbmap -layout latam -model pc105
X-GNOME-Autostart-enabled=true
EOF

echo ""
echo "==> Listo. Verificando configuracion:"
echo ""
localectl status
echo ""
echo "==> Reinicia SteamOS para que todos los cambios surtan efecto."
