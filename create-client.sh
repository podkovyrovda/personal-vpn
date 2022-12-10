SERVER_IP=$(dig ANY +short @resolver2.opendns.com myip.opendns.com)
SERVER_PUBLIC_KEY=$(cat /etc/wireguard/publickey)

CLIENT_ID=1
CLIENT_PRIVATE_KEY=$(wg genkey | tee /etc/wireguard/${CLIENT_ID}_privatekey)
CLIENT_PUBLIC_KEY=$(wg pubkey | tee /etc/wireguard/${CLIENT_ID}_publickey)

cat << EOF >> /etc/wireguard/wg0.conf

[Peer]
  PublicKey = $CLIENT_PUBLIC_KEY
  AllowedIPs = 10.0.0.2/32
EOF

systemctl restart wg-quick@wg0

cat << EOF > /etc/wireguard/clients/${CLIENT_ID}_wb.conf
[Interface]
  PrivateKey = $CLIENT_PRIVATE_KEY
  Address = 10.0.0.2/32
  DNS = 8.8.8.8

[Peer]
  PublicKey = $SERVER_PUBLIC_KEY
  Endpoint = $SERVER_IP:51830
  AllowedIPs = 0.0.0.0/0
  PersistentKeepalive = 20
EOF
