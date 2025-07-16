#!/bin/bash
apt update && apt install squid apache2-utils -y

htpasswd -bc /etc/squid/passwd squiduser rahasia123
cp /etc/squid/squid.conf /etc/squid/squid.conf.bak

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

echo "Squid HTTP proxy aktif di port 3128"
echo "Login: squiduser / rahasia123"
