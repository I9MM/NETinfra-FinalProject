# DHCP Server Configuration
# Centralized DHCP service running on Luxor Branch

## DHCP Service Configuration (Linux-based)

### Install DHCP Server
```bash
sudo apt-get update
sudo apt-get install isc-dhcp-server
```

### DHCP Configuration File (/etc/dhcp/dhcpd.conf)

```
# Global DHCP Configuration
default-lease-time 86400;
max-lease-time 604800;
option domain-name "netinfra.local";
option domain-name-servers 8.8.8.8, 8.8.4.4;

# VLAN 10 - Management Network
subnet 192.168.10.0 netmask 255.255.255.0 {
    range 192.168.10.11 192.168.10.100;
    option routers 192.168.10.1;
    option broadcast-address 192.168.10.255;
    option subnet-mask 255.255.255.0;
    # Reserved addresses for network devices
    host cairo-switch {
        hardware ethernet 00:1a:2b:3c:4d:5e;
        fixed-address 192.168.10.2;
    }
}

# VLAN 20 - Sales Department
subnet 192.168.20.0 netmask 255.255.255.0 {
    range 192.168.20.11 192.168.20.100;
    option routers 192.168.20.1;
    option broadcast-address 192.168.20.255;
    option subnet-mask 255.255.255.0;
}

# VLAN 30 - IT Department  
subnet 192.168.30.0 netmask 255.255.255.0 {
    range 192.168.30.11 192.168.30.100;
    option routers 192.168.30.1;
    option broadcast-address 192.168.30.255;
    option subnet-mask 255.255.255.0;
}

# VLAN 40 - Finance Department
subnet 192.168.40.0 netmask 255.255.255.0 {
    range 192.168.40.11 192.168.40.100;
    option routers 192.168.40.1;
    option broadcast-address 192.168.40.255;
    option subnet-mask 255.255.255.0;
}

# Luxor Branch Local Network
subnet 10.2.2.0 netmask 255.255.255.0 {
    range 10.2.2.50 10.2.2.99;
    option routers 10.2.2.1;
    option broadcast-address 10.2.2.255;
    option subnet-mask 255.255.255.0;
}
```

### DHCP Server Interface Configuration (/etc/default/isc-dhcp-server)
```
INTERFACES="eth0"
```

### Start DHCP Service
```bash
sudo systemctl enable isc-dhcp-server
sudo systemctl start isc-dhcp-server
sudo systemctl status isc-dhcp-server
```

### DHCP Relay Configuration on Cairo HQ Switch
The DHCP helper-address commands in the switch configuration will forward DHCP requests from all VLANs to the centralized DHCP server at Luxor:

```
interface Vlan10
 ip helper-address 10.2.2.2

interface Vlan20
 ip helper-address 10.2.2.2

interface Vlan30
 ip helper-address 10.2.2.2

interface Vlan40
 ip helper-address 10.2.2.2
```

### Monitoring DHCP
```bash
# View DHCP leases
sudo cat /var/lib/dhcp/dhcpd.leases

# Monitor DHCP logs
sudo tail -f /var/log/syslog | grep dhcp

# Check DHCP status
sudo systemctl status isc-dhcp-server
```