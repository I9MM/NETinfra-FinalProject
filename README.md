# NETinfra-FinalProject
**Final Project of Network Infrastructure Summer Training at NTI**

## Project Overview

This project implements a comprehensive network infrastructure that connects Cairo HQ and Luxor branch via a simulated cloud environment. The design features EIGRP routing, VLAN segmentation, centralized DHCP services, and robust security policies to ensure scalable and secure connectivity between branches.

## Network Architecture

### Key Features
- **Two-Site Connectivity**: Cairo HQ ↔ Cloud ↔ Luxor Branch
- **EIGRP Routing**: Dynamic routing protocol (AS 100) for inter-site communication
- **VLAN Segmentation**: Four VLANs (10, 20, 30, 40) for traffic isolation
- **Inter-VLAN Routing**: Multilayer switch at Cairo HQ for local routing
- **Centralized Services**: DHCP and web server hosted at Luxor branch
- **Security Policies**: ACLs enforce controlled access between networks

### Network Layout
```
                    ┌─────────────────┐
                    │   Cloud Router  │
                    │   172.16.0.1    │
                    └─────────┬───────┘
                              │
                ┌─────────────┴─────────────┐
                │                           │
        ┌───────▼────────┐         ┌───────▼────────┐
        │  Cairo HQ      │         │  Luxor Branch  │
        │  Multilayer    │◄───────►│  Router        │
        │  Switch        │  EIGRP  │  + DHCP Server │
        │                │  AS 100 │  + Web Server  │
        └────────────────┘         └────────────────┘
                │
        ┌───────┼───────┐
        │       │       │
    ┌───▼───┬───▼───┬───▼───┬───▼───┐
    │VLAN10 │VLAN20 │VLAN30 │VLAN40 │
    │ Mgmt  │ Sales │  IT   │Finance│
    │  .10  │  .20  │  .30  │  .40  │
    └───────┴───────┴───────┴───────┘
```

## VLAN Configuration

| VLAN | Purpose | Network | Gateway | DHCP Range |
|------|---------|---------|---------|------------|
| 10 | Management | 192.168.10.0/24 | 192.168.10.1 | .11-.100 |
| 20 | Sales | 192.168.20.0/24 | 192.168.20.1 | .11-.100 |
| 30 | IT | 192.168.30.0/24 | 192.168.30.1 | .11-.100 |
| 40 | Finance | 192.168.40.0/24 | 192.168.40.1 | .11-.100 |

## Security Policies

### Implemented Access Controls
1. **VLAN 10 (Management) → VLAN 40 (Finance)**: **BLOCKED**
   - Prevents management network from accessing sensitive finance data
2. **VLAN 20 (Sales) → Web Server**: **RESTRICTED**
   - Sales department cannot access internal web server (10.2.2.100)
3. **Inter-VLAN Routing**: Controlled through Cairo HQ multilayer switch
4. **Centralized DHCP**: All VLAN DHCP requests routed to Luxor branch

## Quick Start

### 1. Deploy Configuration
```bash
# Run deployment script
./scripts/deploy.sh
```

### 2. Apply Device Configurations
- **Cairo HQ**: Apply `configs/cairo-hq/multilayer-switch.cfg`
- **Luxor Branch**: Apply `configs/luxor-branch/router.cfg`
- **Cloud**: Apply `configs/cloud-simulation/cloud-router.cfg`

### 3. Set Up Services
- **DHCP Server**: Follow `configs/luxor-branch/dhcp-server.md`
- **Web Server**: Follow `configs/luxor-branch/web-server.md`

### 4. Validate Installation
```bash
# Run validation tests
./scripts/validate.sh
```

## Project Structure

```
NETinfra-FinalProject/
├── configs/
│   ├── cairo-hq/
│   │   └── multilayer-switch.cfg      # Main switch configuration
│   ├── luxor-branch/
│   │   ├── router.cfg                 # Branch router configuration
│   │   ├── dhcp-server.md            # DHCP service setup
│   │   └── web-server.md             # Web server setup
│   └── cloud-simulation/
│       └── cloud-router.cfg          # Cloud router configuration
├── docs/
│   ├── network-topology.md           # Detailed network documentation
│   └── security-policies.md          # Security implementation details
├── scripts/
│   ├── deploy.sh                     # Deployment automation
│   └── validate.sh                   # Network validation tests
└── README.md                         # This file
```

## Technical Implementation

### Routing Protocol
- **EIGRP AS 100** configured on all routers
- Automatic route advertisement for all network segments
- Load balancing and fast convergence

### Services
- **Centralized DHCP**: All VLANs receive IP configuration from Luxor
- **Web Server**: Apache HTTP server with access controls
- **DNS**: Public DNS servers (8.8.8.8, 8.8.4.4) configured

### Security Features
- **Access Control Lists (ACLs)**: Network-level traffic filtering
- **VLAN Isolation**: Broadcast domain separation
- **Logging & Monitoring**: Security event tracking
- **SSH Access**: Secure device management

## Testing & Validation

### Connectivity Tests
```bash
# Test inter-VLAN routing
ping 192.168.20.1    # From any VLAN to Sales gateway

# Test WAN connectivity  
ping 10.2.2.1        # Cairo to Luxor
ping 10.1.1.1        # Luxor to Cairo

# Test DHCP
ipconfig /release && ipconfig /renew   # Windows
sudo dhclient -r && sudo dhclient     # Linux
```

### Security Tests
```bash
# Should FAIL - Management to Finance
ping 192.168.40.x    # From 192.168.10.x

# Should FAIL - Sales to Web Server
curl http://10.2.2.100   # From 192.168.20.x

# Should PASS - IT to all networks
ping 192.168.40.x    # From 192.168.30.x
```

## Troubleshooting

### Common Commands
```bash
# EIGRP Status
show ip eigrp neighbors
show ip eigrp topology

# VLAN Status
show vlan brief
show ip interface brief

# Security Monitoring
show access-lists
show logging | include %SEC

# DHCP Status
show ip dhcp binding
show ip dhcp conflict
```

## Project Requirements Compliance

✅ **Network Links**: Cairo HQ and Luxor branch connected via simulated cloud  
✅ **EIGRP Routing**: Dynamic routing implemented with AS 100  
✅ **VLAN Segmentation**: Four VLANs (10, 20, 30, 40) configured  
✅ **Inter-VLAN Routing**: Multilayer switch at Cairo HQ  
✅ **Centralized DHCP**: Service hosted at Luxor branch  
✅ **Web Server**: Internal portal hosted at Luxor  
✅ **Security Policies**: ACLs enforce VLAN10→VLAN40 blocking and VLAN20→Web restriction  
✅ **Scalability**: Modular design supports additional sites and VLANs  
✅ **Documentation**: Comprehensive setup and validation guides  

## Author
**Network Infrastructure Summer Training - NTI**

This project demonstrates enterprise-level network design principles including segmentation, routing, security, and centralized services management.
