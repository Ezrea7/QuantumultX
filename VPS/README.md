sudo ./rm-snap.sh

VPS网卡一键写入DNS
IF=$(ip route | awk '/default/ {print $5; exit}'); cat > /etc/systemd/network/99-dns.network <<EOF
[Match]
Name=$IF

[Network]
DNS=1.1.1.1
DNS=8.8.8.8
DNS=2606:4700:4700::1111
DNS=2001:4860:4860::8888
Domains=~.
EOF
networkctl reload && networkctl reconfigure "$IF"