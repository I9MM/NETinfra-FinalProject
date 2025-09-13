# Security Policies and Access Control Lists (ACLs)

## Overview
This document outlines the security policies implemented in the network infrastructure to control traffic flow between VLANs and access to network resources.

## Security Requirements
1. **VLAN 10 (Management)** must be blocked from accessing **VLAN 40 (Finance)**
2. **VLAN 20 (Sales)** must be restricted from accessing the web server
3. Inter-VLAN routing must be controlled and monitored

## ACL Implementation

### 1. Management to Finance Blocking (MGMT_FINANCE_BLOCK)

**Purpose:** Prevent management network from accessing sensitive finance network

**Configuration:** Applied on Cairo HQ multilayer switch
```cisco
ip access-list extended MGMT_FINANCE_BLOCK
 deny ip 192.168.10.0 0.0.0.255 192.168.40.0 0.0.0.255 log
 permit ip any any
```

**Application:**
```cisco
interface Vlan10
 ip access-group MGMT_FINANCE_BLOCK out
```

**Traffic Flow:**
- **DENIED:** 192.168.10.x → 192.168.40.x (Management to Finance)
- **ALLOWED:** 192.168.10.x → 192.168.20.x, 192.168.30.x (Management to Sales/IT)
- **ALLOWED:** All other traffic

### 2. Sales to Web Server Restriction (SALES_WEB_BLOCK)

**Purpose:** Restrict sales department from accessing internal web server

**Configuration:** Applied on Cairo HQ multilayer switch
```cisco
ip access-list extended SALES_WEB_BLOCK
 deny ip 192.168.20.0 0.0.0.255 host 10.2.2.100 log
 deny ip 192.168.20.0 0.0.0.255 host 10.2.2.10 log
 permit ip any any
```

**Application:**
```cisco
interface Vlan20
 ip access-group SALES_WEB_BLOCK out
```

**Traffic Flow:**
- **DENIED:** 192.168.20.x → 10.2.2.100 (Sales to Web Server)
- **DENIED:** 192.168.20.x → 10.2.2.10 (Sales to Luxor Services)
- **ALLOWED:** All other traffic

## Additional Security Measures

### 3. Finance Network Protection

**Enhanced ACL for Finance VLAN:**
```cisco
ip access-list extended FINANCE_PROTECTION
 deny ip 192.168.10.0 0.0.0.255 192.168.40.0 0.0.0.255 log
 permit ip 192.168.30.0 0.0.0.255 192.168.40.0 0.0.0.255
 permit ip 192.168.40.0 0.0.0.255 any
 deny ip any 192.168.40.0 0.0.0.255 log
 permit ip any any
```

### 4. Administrative Access Control

**Management VLAN ACL:**
```cisco
ip access-list extended MANAGEMENT_ACCESS
 permit tcp 192.168.10.0 0.0.0.255 any eq ssh
 permit tcp 192.168.10.0 0.0.0.255 any eq telnet
 permit tcp 192.168.10.0 0.0.0.255 any eq 80
 permit tcp 192.168.10.0 0.0.0.255 any eq 443
 permit icmp 192.168.10.0 0.0.0.255 any
 deny ip 192.168.10.0 0.0.0.255 192.168.40.0 0.0.0.255 log
 permit ip any any
```

## Monitoring and Logging

### ACL Logging Configuration
```cisco
! Enable logging for security events
logging buffered 16384
logging console critical
logging monitor informational
logging facility local0
logging source-interface Vlan10

! Log ACL hits
access-list log-update threshold 1
```

### Monitoring Commands
```cisco
! View ACL hit counts
show access-lists

! View logged events
show logging | include %SEC

! Clear ACL counters
clear access-list counters

! Debug ACL (use cautiously)
debug ip packet [access-list number] detail
```

## Traffic Matrix

| Source VLAN | Destination VLAN | Web Server Access | Status |
|-------------|------------------|-------------------|--------|
| VLAN 10 (Management) | VLAN 20 (Sales) | ✅ Allowed | ✅ Allowed |
| VLAN 10 (Management) | VLAN 30 (IT) | ✅ Allowed | ✅ Allowed |
| VLAN 10 (Management) | VLAN 40 (Finance) | ✅ Allowed | ❌ **BLOCKED** |
| VLAN 20 (Sales) | VLAN 10 (Management) | ❌ **BLOCKED** | ✅ Allowed |
| VLAN 20 (Sales) | VLAN 30 (IT) | ❌ **BLOCKED** | ✅ Allowed |
| VLAN 20 (Sales) | VLAN 40 (Finance) | ❌ **BLOCKED** | ✅ Allowed |
| VLAN 30 (IT) | VLAN 10 (Management) | ✅ Allowed | ✅ Allowed |
| VLAN 30 (IT) | VLAN 20 (Sales) | ✅ Allowed | ✅ Allowed |
| VLAN 30 (IT) | VLAN 40 (Finance) | ✅ Allowed | ✅ Allowed |
| VLAN 40 (Finance) | All VLANs | ✅ Allowed | ✅ Allowed |

## Security Policy Summary

### Implemented Controls:
1. ✅ **VLAN Segmentation** - Traffic isolated by VLANs
2. ✅ **Management Isolation** - VLAN 10 blocked from Finance
3. ✅ **Web Access Control** - Sales restricted from web server
4. ✅ **Centralized Routing** - All inter-VLAN traffic through multilayer switch
5. ✅ **Logging & Monitoring** - Security events logged
6. ✅ **Administrative Access** - SSH/Console access controlled

### Compliance Status:
- ✅ VLAN 10 → VLAN 40 blocking: **ACTIVE**
- ✅ VLAN 20 → Web Server restriction: **ACTIVE**
- ✅ Inter-VLAN routing control: **ACTIVE**
- ✅ Centralized DHCP: **ACTIVE**
- ✅ Security monitoring: **ACTIVE**

This security framework ensures controlled access while maintaining necessary business connectivity between the Cairo HQ and Luxor Branch offices.