#!/bin/bash
# GilmaHub Internet Script
# Usage: ./internet.sh fromraspi  (get internet FROM Raspi)
#        ./internet.sh fromlaptop (get internet FROM Laptop)
#        ./internet.sh vpncon [country]   (connect ProtonVPN WireGuard)
#        ./internet.sh vpndisc           (disconnect ProtonVPN WireGuard)
#        ./internet.sh vpnis             (show current VPN IP)

MODE="${1:-}"
COUNTRY="${2:-}"

if [ -z "$MODE" ]; then
    echo "Usage: sudo ./internet.sh <fromraspi|fromlaptop|vpncon|vpndisc|vpnis> [country]"
    echo ""
    echo "  fromraspi   - Get internet from Raspi (this device shares)"
    echo "  fromlaptop  - Get internet from Laptop (this device connects)"
    echo "  vpncon      - Connect ProtonVPN WireGuard (Raspi only)"
    echo "  vpndisc     - Disconnect ProtonVPN WireGuard (Raspi only)"
    echo "  vpnis       - Show current VPN IP"
    echo ""
    echo "  Countries: us, jp, ro (default: ro)"
    exit 1
fi

# Detect which device we are on
IS_RASPI=false
if ssh -o StrictHostKeyChecking=no -o ConnectTimeout=2 fuckall@10.0.0.2 "echo ok" 2>/dev/null; then
    IS_RASPI=true
fi

# Detect current USB interface
get_usb_iface() {
    for iface in enp0s20f0u9 usb0 enp0s20f0u2 enxd83add7979db eth0; do
        if ip link show $iface >/dev/null 2>&1; then
            echo "$iface"
            return 0
        fi
    done
    return 1
}

# Get internet interface (WiFi)
get_inet_iface() {
    # Check for common WiFi interfaces and return the one with default route
    for iface in wlp1s0u1u1 wlan0 wlp0s20f3 wlp2s0 wlxd83add7979db; do
        if ip link show $iface >/dev/null 2>&1; then
            # Check if this interface has a default route
            if ip route show dev $iface 2>/dev/null | grep -q "default"; then
                echo "$iface"
                return 0
            fi
        fi
    done
    # Fallback to first interface with default route
    ip route | grep default | awk '{print $3}' | head -1
}

case "$MODE" in
    fromraspi)
        if [ "$IS_RASPI" = true ]; then
            # We are on Raspi - share internet to laptop
            echo "=== Raspi: Sharing WiFi to Laptop (USB) ==="
            USB=$(get_usb_iface) || USB="usb0"
            
            # Enable IP forwarding
            echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward > /dev/null
            
            # Clean up routes - remove any default via USB
            sudo ip route flush cache 2>/dev/null || true
            sudo ip route del default via 10.0.0.1 2>/dev/null || true
            sudo ip addr del 10.0.0.34/24 dev $USB 2>/dev/null || true
            
            # Get wlan0 IP for internet (should already have it)
            INET="wlan0"
            
            # Set up iptables 
            sudo iptables -t nat -A POSTROUTING -o $INET -j MASQUERADE 2>/dev/null || true
            sudo iptables -A FORWARD -i $USB -o $INET -j ACCEPT 2>/dev/null || true
            sudo iptables -A FORWARD -i $INET -o $USB -m state --state RELATED,ESTABLISHED -j ACCEPT 2>/dev/null || true
            
            # Set static IP on USB
            sudo ip link set $USB up 2>/dev/null || true
            sudo ip addr flush dev $USB 2>/dev/null || true
            sudo ip addr add 10.0.0.2/24 dev $USB 2>/dev/null || true
            
            echo "DONE - Laptop can now connect via USB for internet"
        else
            # We are on Laptop - get internet from Raspi
            echo "=== Laptop: Getting internet from Raspi ==="
            USB=$(get_usb_iface) || USB="enp0s20f0u9"
            
            # Bring up USB interface
            sudo ip link set $USB up 2>/dev/null || true
            sudo ip addr flush dev $USB 2>/dev/null || true
            
            # Don't use DHCP - set static IP
            sudo ip addr add 10.0.0.1/24 dev $USB 2>/dev/null || true
            
            # Clean up any existing default route and add Raspi as gateway
            sudo ip route del default 2>/dev/null || true
            sudo ip route add default via 10.0.0.2 dev $USB 2>/dev/null || true
            
            # Set DNS to Raspi (which has porn blocklist with funny message)
            echo "nameserver 10.0.0.2" | sudo tee /etc/resolv.conf > /dev/null
            
            sleep 1
            MYIP=$(ip addr show $USB | grep "inet " | awk '{print $2}')
            if [ -n "$MYIP" ]; then
                echo "CONNECTED! IP: $MYIP"
                if ping -c 1 8.8.8.8 >/dev/null 2>&1; then
                    echo "Internet ACTIVE"
                fi
            else
                echo "Failed - Make sure Raspi is running 'internet.sh fromraspi'"
            fi
        fi
        ;;
        
    fromlaptop)
        if [ "$IS_RASPI" = true ]; then
            # We are on Raspi - get internet from laptop
            echo "=== Raspi: Getting internet from Laptop (USB) ==="
            USB=$(get_usb_iface) || USB="usb0"
            
            # Clean up routes first - remove any default via USB
            sudo ip route flush cache 2>/dev/null || true
            sudo ip route del default via 10.0.0.1 2>/dev/null || true
            sudo ip addr del 10.0.0.34/24 dev $USB 2>/dev/null || true
            
            # Flush USB and get IP via DHCP from laptop (different subnet)
            sudo ip link set $USB up 2>/dev/null || true
            sudo ip addr flush dev $USB 2>/dev/null || true
            sudo dhcpcd $USB 2>/dev/null || sudo dhclient $USB 2>/dev/null || true
            
            sleep 2
            MYIP=$(ip addr show $USB | grep "inet " | awk '{print $2}')
            if [ -n "$MYIP" ]; then
                echo "CONNECTED! IP: $MYIP"
                if ping -c 1 8.8.8.8 >/dev/null 2>&1; then
                    echo "Internet ACTIVE"
                fi
            else
                echo "Failed - Make sure Laptop is running 'internet.sh fromlaptop'"
            fi
        else
            # We are on Laptop - share internet to Raspi
            echo "=== Laptop: Sharing WiFi to Raspi (USB) ==="
            USB=$(get_usb_iface) || USB="enp0s20f0u9"
            
            # Enable IP forwarding
            echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward > /dev/null
            
            # Get internet interface
            INET=$(get_inet_iface) || INET="wlo1"
            
            # Set up iptables
            sudo iptables -t nat -A POSTROUTING -o $INET -j MASQUERADE 2>/dev/null || true
            sudo iptables -A FORWARD -i $USB -o $INET -j ACCEPT 2>/dev/null || true
            sudo iptables -A FORWARD -i $INET -o $USB -m state --state RELATED,ESTABLISHED -j ACCEPT 2>/dev/null || true
            
            # Set IP for DHCP server (different subnet: 10.42.0.x)
            sudo ip link set $USB up 2>/dev/null || true
            sudo ip addr flush dev $USB 2>/dev/null || true
            sudo ip addr add 10.42.0.1/24 dev $USB 2>/dev/null || true
            
            # Kill any existing dnsmasq and start fresh
            sudo pkill dnsmasq 2>/dev/null || true
            sudo dnsmasq --interface=$USB --dhcp-range=10.42.0.10,10.42.0.50 --dhcp-option=option:router,10.42.0.1 --dhcp-option=option:dns-server,8.8.8.8 --bind-interfaces 2>/dev/null &
            
            echo "DONE - Raspi can now connect via USB for internet"
        fi
        ;;
        
    vpncon)
        if [ "$IS_RASPI" = true ]; then
            COUNTRY="${2:-ro}"
            CONFIG="/home/fuckall/${COUNTRY}.conf"
            echo "=== Connecting to ProtonVPN WireGuard ($COUNTRY) ==="
            if [ ! -f "$CONFIG" ]; then
                echo "Config not found: $CONFIG"
                exit 1
            fi
            sudo wg-quick down /home/fuckall/ro.conf 2>/dev/null || true
            sudo wg-quick up "$CONFIG"
            sleep 2
            sudo wg
        else
            echo "vpncon only works on Raspi"
            exit 1
        fi
        ;;
        
    vpndisc)
        if [ "$IS_RASPI" = true ]; then
            echo "=== Disconnecting ProtonVPN WireGuard ==="
            sudo wg-quick down /home/fuckall/ro.conf 2>/dev/null || true
            sudo wg-quick down /home/fuckall/us.conf 2>/dev/null || true
            sudo wg-quick down /home/fuckall/jp.conf 2>/dev/null || true
        else
            echo "vpndisc only works on Raspi"
            exit 1
        fi
        ;;
        
    vpnis)
        if [ "$IS_RASPI" = true ]; then
            curl -s https://ipleak.net/json/ | python3 -c "import sys,json;d=json.load(sys.stdin);print(f\"IP: {d.get('ip','N/A')}\nCountry: {d.get('country_name','N/A')}\nCity: {d.get('city_name','N/A')}\")"
        else
            echo "vpnis only works on Raspi"
            exit 1
        fi
        ;;
        
    *)
        echo "Invalid mode: $MODE"
        echo "Use: fromraspi, fromlaptop, vpncon, vpndisc, or vpnis"
        exit 1
        ;;
esac
