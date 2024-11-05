#!/bin/bash

# Fungsi untuk instalasi dan konfigurasi Fail2ban
install_fail2ban() {
    echo "Installing Fail2ban..."
    sudo apt update
    sudo apt install fail2ban -y

    echo "Backing up default Fail2ban config..."
    sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local

    echo "Configuring Fail2ban for SSH brute force protection..."
    sudo cat <<EOL >> /etc/fail2ban/jail.local

[DEFAULT]
bantime = 10m
findtime = 10m
maxretry = 5

[sshd]
enabled = true
port = 22
logpath = %(sshd_log)s
backend = auto

EOL

    echo "Restarting Fail2ban..."
    sudo systemctl restart fail2ban
    sudo systemctl enable fail2ban
    echo "Fail2ban installed and configured successfully!"
}

# Fungsi untuk instalasi dan konfigurasi Portsentry
install_portsentry() {
    echo "Installing Portsentry..."
    sudo apt update
    sudo apt install portsentry -y

    echo "Backing up default Portsentry config..."
    sudo cp /etc/portsentry/portsentry.conf /etc/portsentry/portsentry.conf.backup

    echo "Configuring Portsentry for port scanning protection..."
    sudo sed -i 's/TCP_MODE="tcp"/TCP_MODE="atcp"/g' /etc/portsentry/portsentry.conf
    sudo sed -i 's/UDP_MODE="udp"/UDP_MODE="audp"/g' /etc/portsentry/portsentry.conf

    sudo sed -i 's/#BLOCK_UDP="1"/BLOCK_UDP="1"/g' /etc/portsentry/portsentry.conf
    sudo sed -i 's/#BLOCK_TCP="1"/BLOCK_TCP="1"/g' /etc/portsentry/portsentry.conf

    echo "127.0.0.1" | sudo tee -a /etc/portsentry/portsentry.ignore

    echo "Restarting Portsentry..."
    sudo systemctl restart portsentry
    sudo systemctl enable portsentry
    echo "Portsentry installed and configured successfully!"
}

# Fungsi untuk melihat log IP yang diblokir oleh Fail2ban
view_fail2ban_log() {
    echo "Displaying Fail2ban ban logs..."
    sudo cat /var/log/fail2ban.log | grep 'Ban'
}

# Fungsi untuk melihat log Portsentry
view_portsentry_log() {
    echo "Displaying Portsentry logs..."
    sudo cat /var/lib/portsentry/portsentry.history
}

# Menu pilihan
while true; do
    echo "====================================="
    echo "Keamanan Dasar Jaringan"
    echo "1. Amankan Brute Force dengan Fail2ban"
    echo "2. Amankan Port Scanning dengan Portsentry"
    echo "3. Lihat Log IP yang Kena Banned oleh Fail2ban"
    echo "4. Lihat Log Portsentry"
    echo "5. Keluar"
    echo "====================================="
    read -p "Pilih opsi (1-5): " choice

    case $choice in
        1)
            install_fail2ban
            ;;
        2)
            install_portsentry
            ;;
        3)
            view_fail2ban_log
            ;;
        4)
            view_portsentry_log
            ;;
        5)
            echo "Keluar dari program..."
            exit 0
            ;;
        *)
            echo "Pilihan tidak valid. Silakan coba lagi."
            ;;
    esac
done
