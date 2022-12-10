apt update && apt upgrade -y
apt install -y wireguard

SERVER_PRIVATE_KEY=$(wg genkey | tee /etc/wireguard/privatekey)
NETWORK_SERVICE_NAME=$(ip a)

chmod 600 /etc/wireguard/privatekey

cat <<EOF >/etc/wireguard/wg0.conf
[Interface]
  PrivateKey = $SERVER_PRIVATE_KEY
  Address = 10.0.0.1/24
  ListenPort = 51830
  PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -t nat -A POSTROUTING -o $NETWORK_SERVICE_NAME -j MASQUERADE
  PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -t nat -D POSTROUTING -o $NETWORK_SERVICE_NAME -j MASQUERADE
EOF

echo "net.ipv4.ip_forward=1" >>/etc/sysctl.conf
sysctl -p

systemctl enable wg-quick@wg0.service
systemctl start wg-quick@wg0.service
