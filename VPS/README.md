sudo ./rm-snap.sh

VPS网卡一键写入DNS
cat > /etc/systemd/network/ens17 <<'EOF'
[Match]
Name=ens17

[Network]
DNS=1.1.1.1
DNS=8.8.8.8
DNS=2606:4700:4700::1111
DNS=2001:4860:4860::8888
Domains=~.
EOF
networkctl reload && networkctl reconfigure ens17