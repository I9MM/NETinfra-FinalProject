# Network Topology Documentation

## Project Overview
This network infrastructure project connects Cairo HQ and Luxor branch through a simulated cloud environment, implementing enterprise-level networking features including VLANs, EIGRP routing, and security policies.

## Network Architecture

### Sites
1. **Cairo HQ** - Main headquarters with multilayer switch for inter-VLAN routing
2. **Luxor Branch** - Remote branch office with centralized services
3. **Cloud Simulation** - WAN connectivity between sites

### Network Addressing Scheme

#### VLAN Configuration
- **VLAN 10**: Management Network - 192.168.10.0/24
- **VLAN 20**: Sales Department - 192.168.20.0/24  
- **VLAN 30**: IT Department - 192.168.30.0/24
- **VLAN 40**: Finance Department - 192.168.40.0/24

#### WAN Links
- **Cairo HQ to Cloud**: 10.1.1.0/30
- **Luxor Branch to Cloud**: 10.2.2.0/30
- **Cloud Internal**: 172.16.0.0/16

### Device Roles

#### Cairo HQ
- **Multilayer Switch (L3)**: Inter-VLAN routing, VLAN configuration
- **Access Switches**: VLAN access ports for end devices

#### Luxor Branch  
- **Router**: WAN connectivity, EIGRP routing
- **DHCP Server**: Centralized DHCP for all VLANs
- **Web Server**: Internal web services

#### Cloud Simulation
- **Cloud Router**: Simulates ISP/WAN infrastructure

### Routing Protocol
- **EIGRP AS 100**: Used for dynamic routing between Cairo HQ and Luxor branch

### Security Policies
1. **VLAN Isolation**: VLAN10 (Management) blocked from accessing VLAN40 (Finance)
2. **Web Access Control**: VLAN20 (Sales) restricted from accessing web server
3. **Inter-VLAN Routing**: Controlled through multilayer switch at Cairo HQ

## Traffic Flow
1. Local traffic within VLANs stays local
2. Inter-VLAN traffic routes through Cairo HQ multilayer switch
3. WAN traffic between sites uses EIGRP routing through cloud
4. DHCP requests forwarded to Luxor centralized server
5. Web server access controlled via ACLs