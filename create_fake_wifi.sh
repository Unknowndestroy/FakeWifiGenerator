#!/data/data/com.termux/files/usr/bin/bash

# Rastgele bir sayı üretme
RANDOM_NUMBER=$(( RANDOM % 1000 ))  # 0-999 arasında rastgele bir sayı
SSID="FakeWifi_$RANDOM_NUMBER"

# Wi-Fi adaptörünü ayarlama
IFACE="wlan0"  # Wi-Fi adaptörünüzün adı (genellikle wlan0 olur)

# Wi-Fi adaptörünü durdurma
ifconfig $IFACE down

# Access point oluşturma
iw dev $IFACE interface add ap0 type __ap
ifconfig ap0 192.168.10.1 netmask 255.255.255.0 up

# DHCP sunucusu ayarlama
echo "interface ap0" > /etc/dnsmasq.conf
echo "dhcp-range=192.168.10.2,192.168.10.20,255.255.255.0,24h" >> /etc/dnsmasq.conf

# Hostapd yapılandırma dosyası oluşturma (şifresiz)
cat <<EOL > /etc/hostapd/hostapd.conf
interface=ap0
driver=nl80211
ssid=$SSID
hw_mode=g
channel=6
wmm_enabled=0
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=0  # Şifresiz
EOL

# Dnsmasq'ı başlatma
dnsmasq -C /etc/dnsmasq.conf &

# Hostapd'yi başlatma
hostapd /etc/hostapd/hostapd.conf &
