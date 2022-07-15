#echo "reset iptables"
iptables -F
#echo "Block TCP-CONNECT scan attempts (SYN bit packets)"
iptables -A INPUT -p tcp --syn -i eth0 -m state --state NEW -m recent --update --seconds 1 --hitcount 1 -j DROP
#echo "Block TCP-SYN scan attempts (only SYN bit packets)"
iptables -A INPUT -m conntrack --ctstate NEW -p tcp --tcp-flags SYN,RST,ACK,FIN,URG,PSH SYN -i eth0 -m state --state NEW -m recent --update --seconds 1 --hitcount 1 -j DROP
#echo "Block TCP-FIN scan attempts (only FIN bit packets)"
iptables -A INPUT -m conntrack --ctstate NEW -p tcp --tcp-flags SYN,RST,ACK,FIN,URG,PSH FIN -i eth0 -m state --state NEW -m recent --update --seconds 1 --hitcount 1 -j DROP
#echo "Block TCP-ACK scan attempts (only ACK bit packets)"
iptables -A INPUT -m conntrack --ctstate NEW -p tcp --tcp-flags SYN,RST,ACK,FIN,URG,PSH ACK -i eth0 -m state --state NEW -m recent --update --seconds 1 --hitcount 1 -j DROP
#echo "Block TCP-NULL scan attempts (packets without flag)"
iptables -A INPUT -m conntrack --ctstate INVALID -p tcp --tcp-flags SYN,RST,ACK,FIN,URG,PSH SYN,RST,ACK,FIN,URG,PSH -j DROP
#echo "Block "Christmas Tree" TCP-XMAS scan attempts (packets with FIN, URG, PSH bits)"
iptables -A INPUT -m conntrack --ctstate NEW -p tcp --tcp-flags SYN,RST,ACK,FIN,URG,PSH FIN,URG,PSH -i eth0 -m state --state NEW -m recent --update --seconds 1 --hitcount 1 -j DROP
#echo "Block DOS - Ping of Death"
iptables -A INPUT -p ICMP --icmp-type echo-request -m length --length 60:65535 -j ACCEPT
#echo "Block DOS - Teardrop"
iptables -A INPUT -p UDP -f -j DROP
#echo "Block DDOS - Smurf"
iptables -A INPUT -j REJECT -p icmp --icmp-type echo-request
iptables -A INPUT -p icmp -j DROP --icmp-type echo-request
iptables -A OUTPUT -p icmp -j DROP --icmp-type echo-reply
#echo "Block DDOS - UDP-flood (Pepsi)"
iptables -A INPUT -p udp --dport 7777 -i eth0 -m state --state NEW -m recent --set
iptables -A INPUT -p udp --dport 7777 -i eth0 -m state --state NEW -m recent --update --seconds 1 --hitcount 1 -j DROP
iptables -N SAMP-DDOS
iptables -A INPUT -p udp --dport 7777 -m ttl --ttl-eq=128 -j SAMP-DDOS
iptables -A SAMP-DDOS -p udp --dport 7777 -m length --length 17:604 -j DROP
iptables -A INPUT -p udp -m ttl --ttl-eq=128 -j DROP
iptables -A INPUT -p udp --dport 7777 -m limit --limit 1/s --limit-burst 1 -j DROP
iptables -A INPUT -p udp --dport 7777 -j ACCEPT
#echo "Block DDOS - SMBnuke"
iptables -A INPUT -p UDP --dport 135:139 -j DROP
#echo "Block DDOS - Fraggle"
iptables -A INPUT -p UDP -m pkttype --pkt-type broadcast -j DROP
iptables -A INPUT -p UDP -m limit --limit 1/s -j ACCEPT
#echo "Block DDOS - Jolt"
iptables -A INPUT -p ICMP -j DROP
#echo "port 80 sama 443"
iptables -A INPUT -p tcp --dport 80 -i eth0 -m state --state NEW -m recent --update --seconds 1 --hitcount 1 -j DROP
iptables -A INPUT -p tcp --destination-port 80 -j DROP
iptables -A INPUT -p tcp --destination-port 443 -j DROP
iptables -A INPUT -p tcp --dport 443 -i eth0 -m state --state NEW -m recent --update --seconds 1 --hitcount 1 -j DROP
#echo "layer 7 GET & POST"
iptables -I INPUT -p tcp --dport 80 -m string --string 'GET / HTTP/1.1' --algo bm -j DROP
iptables -I INPUT -p tcp --dport 443 -m string --string 'POST / HTTP/1.1' --algo bm -j DROP
iptables -I INPUT -p udp --dport 7777 -m string --string 'POST / HTTP/1.1' --algo bm -j DROP
#echo "iptables show"
iptables -L
#print
echo "ANTIDDOS JetX#7327 IS READY"