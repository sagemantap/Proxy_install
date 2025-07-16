#!/bin/bash

# ==== Variabel konfigurasi ====
ALLOWED_IP="0.0.0.0/0"    # Ganti jika ingin membatasi IP tertentu

# ==== Update dan install ====
apt update && apt install dante-server squid apache2-utils ufw -y

# ==== Buat user untuk SOCKS5 dan HTTP ====
id proxyuser &>/dev/null || useradd -M proxyuser
echo "proxyuser:rahasia123" | chpasswd
htpasswd -bc /etc/squid/passwd squiduser rahasia123

# ==== Konfigurasi Danted ====
cat > /etc/danted.conf << EOF
logoutput: /var/log/danted.log
internal: eth0 port = 1080
external: eth0

method: username
user.notprivileged: nobody

client pass {
    from: ${ALLOWED_IP} to: 0.0.0.0/0
    log: connect disconnect error
    method: username
}

pass {
    from: ${ALLOWED_IP} to: 0.0.0.0/0
    protocol: tcp udp
    log: connect disconnect error
    method: username
}
EOF

systemctl restart danted
systemctl enable danted

# ==== Konfigurasi Squid ====
cat > /etc/squid/squid.conf << EOF
http_port 3128

auth_param basic program /usr/lib/squid/basic_ncsa_auth /etc/squid/passwd
auth_param basic realm Squid Proxy
acl authenticated proxy_auth REQUIRED
http_access allow authenticated
http_access deny all
EOF

systemctl restart squid
systemctl enable squid

# ==== UFW Firewall ====
ufw allow 22/tcp
ufw allow 1080/tcp
ufw allow 3128/tcp
ufw --force enable

echo "==================================="
echo "✅ SOCKS5 Proxy (Dante) aktif: port 1080"
echo "   Login: proxyuser / rahasia123"
echo "✅ HTTP Proxy (Squid) aktif: port 3128"
echo "   Login: squiduser / rahasia123"
echo "📌 Diizinkan dari IP: ${ALLOWED_IP}"
echo "==================================="
