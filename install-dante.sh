#!/bin/bash
apt update && apt install dante-server -y

id proxyuser &>/dev/null || useradd -M proxyuser
echo "proxyuser:rahasia123" | chpasswd

cat > /etc/danted.conf << EOF
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

systemctl restart danted
systemctl enable danted

echo "Dante SOCKS5 proxy aktif di port 1080"
echo "Login: proxyuser / rahasia123"
