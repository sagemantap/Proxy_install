#!/bin/bash

# Hentikan service dan hapus danted
systemctl stop danted
apt-get remove --purge -y danted

# Bersihkan file konfigurasi lama
rm -f /etc/danted.conf
rm -f /var/log/danted.log

# Reinstall Dante
apt-get update
apt-get install -y dante-server

# Buat file konfigurasi baru
cat > /etc/danted.conf <<EOF
logoutput: /var/log/danted.log
internal: eth0 port = 1080
external: eth0

method: username
user.notprivileged: nobody

client pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
    log: connect disconnect error
    method: username
}

pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
    protocol: tcp udp
    log: connect disconnect error
    method: username
}
EOF

# Tambahkan user default
useradd proxyuser || true
echo 'proxyuser:rahasia123' | chpasswd

# Aktifkan dan jalankan
systemctl enable danted
systemctl restart danted
