#!/bin/bash
set -euo pipefail

MOUNT_DIR="/tmp/serenity_mount"
BASE_IMG="whaleos_build/serenity_base.img"
OUTPUT_IMG="./whaleos.img"

echo "[*] Limpando processos..."
sudo killall -9 qemu-system-x86_64 websockify 2>/dev/null || true
sudo umount "$MOUNT_DIR" 2>/dev/null || true
mkdir -p "$MOUNT_DIR"

echo "[*] Recriando imagem de trabalho limpa..."
rm -f "$OUTPUT_IMG"
cp "$BASE_IMG" "$OUTPUT_IMG"

echo "[*] Montando sistema de arquivos..."
sudo mount -o loop,offset=1048576 "$OUTPUT_IMG" "$MOUNT_DIR"

echo "[*] Limpando configurações corrompidas do usuário..."
# Remove o Taskbar.ini antigo para forçar o sistema a usar o padrão nativo
sudo rm -f "$MOUNT_DIR/home/anon/.config/Taskbar.ini"

echo "[*] Aplicando Fundo Dark Estável..."
sudo mkdir -p "$MOUNT_DIR/etc"
sudo bash -c "cat << 'EOF' > $MOUNT_DIR/etc/WindowServer.ini
[Background]
Color=#1A1C1E
Wallpaper=

[Theme]
Theme=Default
EOF"

echo "[*] Hackeando o Nome do Sistema e Terminal..."
sudo bash -c "echo 'WhaleOS' > $MOUNT_DIR/etc/hostname"
sudo bash -c "cat << 'EOF' > $MOUNT_DIR/etc/motd
=========================================
        Bem-vindo ao WhaleOS Kernel      
=========================================
EOF"
sudo bash -c "cat << 'EOF' >> $MOUNT_DIR/home/anon/.shellrc
export PROMPT='WhaleOS:\w $ '
EOF"

echo "[*] HACK DE BAIXO NÍVEL: Patcheando o binário da Taskbar..."
# Substitui a string diretamente no binário usando sed
sudo sed -i 's/Serenity/WhaleOS /g' "$MOUNT_DIR/bin/Taskbar" 2>/dev/null || true

echo "[*] Substituindo os ícones do menu Iniciar..."
sudo cp -f "$MOUNT_DIR/res/icons/16x16/app-terminal.png" "$MOUNT_DIR/res/icons/16x16/ladybug.png" 2>/dev/null || true
sudo cp -f "$MOUNT_DIR/res/icons/16x16/app-terminal.png" "$MOUNT_DIR/res/icons/16x16/serenity.png" 2>/dev/null || true
sudo cp -f "$MOUNT_DIR/res/icons/16x16/app-terminal.png" "$MOUNT_DIR/res/icons/16x16/brand-logo.png" 2>/dev/null || true

sync
sudo umount "$MOUNT_DIR"

echo "=== WHALEOS KERNEL PATCHEADO COM SUCESSO ==="