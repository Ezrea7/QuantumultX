sudo ./rm-snap.sh

VPS网卡一键写入DNS
python3 -c 'p="/etc/netplan/50-network.yaml";s=open(p).read();a=s.index("            nameservers:");s=s[:a]+"""            nameservers:\n                addresses:\n                - 1.1.1.1\n                - 8.8.8.8\n                - 2606:4700:4700::1111\n                - 2001:4860:4860::8888\n""";open(p,"w").write(s)' && netplan generate && netplan apply