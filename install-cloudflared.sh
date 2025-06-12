#!/bin/bash

install_cloudflared_for_debian() {
    # Add cloudflare gpg key
    mkdir -p --mode=0755 /usr/share/keyrings
    curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | sudo tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null

    # Add this repo to your apt repositories
    echo 'deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared any main' | sudo tee /etc/apt/sources.list.d/cloudflared.list

    # install cloudflared
    apt-get update && apt-get install cloudflared -y
}

install_cloudflared_for_arch() {
    pacman -Sy --needed --noconfirm cloudflared
}

if [ -f /etc/os-release ]; then
    source /etc/os-release
    case "$ID" in
        arch*)
            install_cloudflared_for_arch
            ;;
        debian*|ubuntu*)
            install_cloudflared_for_debian
            ;;
        *)
            echo "Unsupported Linux release version"
            ;;
    esac
fi

CLOUDFLARE_TUNNEL_TOKEN=`cat /etc/cloudlfared/cfd.txt`
cloudflared service install $CLOUDFLARE_TUNNEL_TOKEN

touch /var/lib/cloudflared-installed

rm -f /install-cloudflare.sh
