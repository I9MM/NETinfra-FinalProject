#!/bin/bash

# Network Validation Script
# Tests network connectivity and validates security policies

echo "=================================================="
echo "Network Infrastructure Validation & Testing"
echo "=================================================="

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_test() {
    echo -e "${BLUE}[TEST]${NC} $1"
}

print_pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
}

print_fail() {
    echo -e "${RED}[FAIL]${NC} $1"
}

print_info() {
    echo -e "${YELLOW}[INFO]${NC} $1"
}

# Test EIGRP Configuration
test_eigrp() {
    print_test "Testing EIGRP Configuration..."
    
    echo "Expected EIGRP Networks:"
    echo "• AS 100 should include:"
    echo "  - 192.168.10.0/24 (VLAN 10)"
    echo "  - 192.168.20.0/24 (VLAN 20)"  
    echo "  - 192.168.30.0/24 (VLAN 30)"
    echo "  - 192.168.40.0/24 (VLAN 40)"
    echo "  - 10.1.1.0/30 (Cairo-Cloud)"
    echo "  - 10.2.2.0/30 (Luxor-Cloud)"
    
    print_info "Run on devices: show ip eigrp neighbors"
    print_info "Run on devices: show ip eigrp topology"
}

# Test VLAN Configuration
test_vlans() {
    print_test "Testing VLAN Configuration..."
    
    echo "Expected VLAN Setup:"
    echo "• VLAN 10: Management (192.168.10.0/24)"
    echo "• VLAN 20: Sales (192.168.20.0/24)"
    echo "• VLAN 30: IT (192.168.30.0/24)"
    echo "• VLAN 40: Finance (192.168.40.0/24)"
    
    print_info "Run on Cairo switch: show vlan brief"
    print_info "Run on Cairo switch: show ip interface brief"
}

# Test Security Policies
test_security_policies() {
    print_test "Testing Security Policies..."
    
    echo "Security Policy Tests:"
    echo
    echo "1. VLAN 10 to VLAN 40 blocking:"
    echo "   From 192.168.10.x: ping 192.168.40.x (should FAIL)"
    echo
    echo "2. VLAN 20 to Web Server restriction:"
    echo "   From 192.168.20.x: ping 10.2.2.100 (should FAIL)"
    echo "   From 192.168.20.x: curl http://10.2.2.100 (should FAIL)"
    echo
    echo "3. Allowed connectivity:"
    echo "   From 192.168.30.x: ping 192.168.40.x (should PASS)"
    echo "   From 192.168.30.x: curl http://10.2.2.100 (should PASS)"
    
    print_info "Check ACL hits: show access-lists"
    print_info "Check security logs: show logging | include %SEC"
}

# Test DHCP Functionality
test_dhcp() {
    print_test "Testing DHCP Functionality..."
    
    echo "DHCP Service Tests:"
    echo "• Clients in each VLAN should receive:"
    echo "  - IP address from correct range"
    echo "  - Default gateway (VLAN interface)"
    echo "  - DNS servers (8.8.8.8, 8.8.4.4)"
    echo "  - Domain name (netinfra.local)"
    
    echo
    echo "DHCP Ranges:"
    echo "• VLAN 10: 192.168.10.11 - 192.168.10.100"
    echo "• VLAN 20: 192.168.20.11 - 192.168.20.100"
    echo "• VLAN 30: 192.168.30.11 - 192.168.30.100"
    echo "• VLAN 40: 192.168.40.11 - 192.168.40.100"
    
    print_info "On DHCP server: sudo systemctl status isc-dhcp-server"
    print_info "Check leases: sudo cat /var/lib/dhcp/dhcpd.leases"
}

# Test Web Server
test_web_server() {
    print_test "Testing Web Server..."
    
    echo "Web Server Tests:"
    echo "• Server should be accessible at: http://10.2.2.100"
    echo "• From allowed VLANs (10, 30, 40): curl http://10.2.2.100"
    echo "• From restricted VLAN (20): should be blocked by ACL"
    
    print_info "On web server: sudo systemctl status apache2"
    print_info "Check access logs: sudo tail -f /var/log/apache2/access.log"
}

# Ping Tests
run_ping_tests() {
    print_test "Running Connectivity Tests..."
    
    echo "Basic Connectivity Tests:"
    echo
    echo "Inter-VLAN Connectivity (should work):"
    echo "ping 192.168.10.1  # VLAN 10 gateway"
    echo "ping 192.168.20.1  # VLAN 20 gateway"
    echo "ping 192.168.30.1  # VLAN 30 gateway"
    echo "ping 192.168.40.1  # VLAN 40 gateway"
    echo
    echo "WAN Connectivity:"
    echo "ping 10.1.1.2      # Cloud router from Cairo"
    echo "ping 10.2.2.2      # Cloud router from Luxor"
    echo "ping 10.2.2.1      # Luxor router from Cairo"
    echo "ping 10.1.1.1      # Cairo switch from Luxor"
    echo
    echo "Blocked Connectivity (should fail):"
    echo "From 192.168.10.x: ping 192.168.40.x"
    echo "From 192.168.20.x: ping 10.2.2.100"
}

# Configuration Validation
validate_configs() {
    print_test "Validating Configuration Files..."
    
    local error_count=0
    
    # Check Cairo config
    if [ -f "configs/cairo-hq/multilayer-switch.cfg" ]; then
        print_pass "Cairo HQ multilayer switch configuration exists"
        if grep -q "router eigrp 100" configs/cairo-hq/multilayer-switch.cfg; then
            print_pass "EIGRP AS 100 configured in Cairo"
        else
            print_fail "EIGRP AS 100 not found in Cairo config"
            ((error_count++))
        fi
    else
        print_fail "Cairo HQ configuration file missing"
        ((error_count++))
    fi
    
    # Check Luxor config
    if [ -f "configs/luxor-branch/router.cfg" ]; then
        print_pass "Luxor branch router configuration exists"
        if grep -q "ip dhcp pool" configs/luxor-branch/router.cfg; then
            print_pass "DHCP pools configured in Luxor"
        else
            print_fail "DHCP pools not found in Luxor config"
            ((error_count++))
        fi
    else
        print_fail "Luxor branch configuration file missing"
        ((error_count++))
    fi
    
    # Check Cloud config
    if [ -f "configs/cloud-simulation/cloud-router.cfg" ]; then
        print_pass "Cloud router configuration exists"
    else
        print_fail "Cloud router configuration file missing"
        ((error_count++))
    fi
    
    # Check documentation
    if [ -f "docs/security-policies.md" ]; then
        print_pass "Security policies documentation exists"
    else
        print_fail "Security policies documentation missing"
        ((error_count++))
    fi
    
    return $error_count
}

# Performance and monitoring
monitor_network() {
    print_test "Network Monitoring Commands..."
    
    echo "Performance Monitoring:"
    echo "show ip route eigrp        # EIGRP routes"
    echo "show ip eigrp neighbors    # EIGRP adjacencies"
    echo "show ip eigrp topology     # EIGRP topology"
    echo "show vlan brief           # VLAN status"
    echo "show interfaces status    # Interface status"
    echo "show ip arp               # ARP table"
    echo "show access-lists         # ACL hit counts"
    echo "show logging | include %SEC  # Security events"
    echo
    echo "Troubleshooting:"
    echo "debug ip eigrp            # EIGRP debugging"
    echo "debug ip packet 101       # Packet debugging"
    echo "show ip dhcp binding      # DHCP leases"
    echo "show ip dhcp conflict     # DHCP conflicts"
}

# Main function
main() {
    echo
    print_test "Starting Network Infrastructure Validation"
    echo
    
    # Validate configuration files
    validate_configs
    local config_errors=$?
    
    echo
    test_eigrp
    echo
    test_vlans
    echo
    test_security_policies
    echo
    test_dhcp
    echo
    test_web_server
    echo
    run_ping_tests
    echo
    monitor_network
    echo
    
    if [ $config_errors -eq 0 ]; then
        print_pass "All configuration files validated successfully!"
    else
        print_fail "Found $config_errors configuration issues"
    fi
    
    echo
    print_info "Run this script after deploying configurations to network devices"
    print_info "Use the test commands above to validate network functionality"
}

# Run main function
main "$@"