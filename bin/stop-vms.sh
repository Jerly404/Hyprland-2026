#!/bin/bash
echo "Deteniendo servicios de VM..."

# Matar contenedores docker
docker ps -q 2>/dev/null | xargs -r docker stop 2>/dev/null
killall -9 dockerd containerd 2>/dev/null

# Matar VMs de qemu
virsh list --all 2>/dev/null | grep running | awk '{print $2}' | xargs -r virsh shutdown 2>/dev/null
killall -9 qemu-system-x86 2>/dev/null

# Matar ollama
killall -9 ollama ollama-agent 2>/dev/null

echo "VM services stopped"
