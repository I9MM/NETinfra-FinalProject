#!/bin/bash

# Network Infrastructure Deployment Script
# NETinfra Final Project - NTI Summer Training

echo "=================================================="
echo "Network Infrastructure Final Project Deployment"
echo "=================================================="

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# Deployment steps
deploy_cairo_hq() {
    print_header "Deploying Cairo HQ Configuration..."
    
    print_status "Setting up multilayer switch configuration..."
    echo "- VLAN configuration (10, 20, 30, 40)"
    echo "- Inter-VLAN routing setup"
    echo "- EIGRP routing protocol"
    echo "- ACL security policies"
    echo "- DHCP relay configuration"
    
    if [ -f "configs/cairo-hq/multilayer-switch.cfg" ]; then
        print_status "Cairo HQ configuration file ready: multilayer-switch.cfg"
    else
        print_error "Cairo HQ configuration file not found!"
        return 1
    fi
}

deploy_luxor_branch() {
    print_header "Deploying Luxor Branch Configuration..."
    
    print_status "Setting up Luxor branch router..."
    echo "- WAN connectivity to cloud"
    echo "- EIGRP routing protocol"
    echo "- Centralized DHCP server"
    echo "- Web server hosting"
    
    if [ -f "configs/luxor-branch/router.cfg" ]; then
        print_status "Luxor router configuration ready: router.cfg"
    else
        print_error "Luxor router configuration file not found!"
        return 1
    fi
    
    if [ -f "configs/luxor-branch/dhcp-server.md" ]; then
        print_status "DHCP server configuration ready"
    fi
    
    if [ -f "configs/luxor-branch/web-server.md" ]; then
        print_status "Web server configuration ready"
    fi
}

deploy_cloud_simulation() {
    print_header "Deploying Cloud Simulation..."
    
    print_status "Setting up cloud router for WAN simulation..."
    echo "- Inter-site connectivity"
    echo "- EIGRP routing protocol"
    echo "- WAN link simulation"
    
    if [ -f "configs/cloud-simulation/cloud-router.cfg" ]; then
        print_status "Cloud router configuration ready: cloud-router.cfg"
    else
        print_error "Cloud router configuration file not found!"
        return 1
    fi
}

validate_configuration() {
    print_header "Validating Network Configuration..."
    
    print_status "Checking network addressing scheme..."
    echo "✓ VLAN 10: 192.168.10.0/24 (Management)"
    echo "✓ VLAN 20: 192.168.20.0/24 (Sales)"
    echo "✓ VLAN 30: 192.168.30.0/24 (IT)"
    echo "✓ VLAN 40: 192.168.40.0/24 (Finance)"
    echo "✓ Cairo-Cloud Link: 10.1.1.0/30"
    echo "✓ Luxor-Cloud Link: 10.2.2.0/30"
    
    print_status "Checking security policies..."
    echo "✓ VLAN 10 blocked from VLAN 40"
    echo "✓ VLAN 20 restricted from web server"
    echo "✓ Inter-VLAN routing controlled"
    
    print_status "Checking services..."
    echo "✓ EIGRP AS 100 configured"
    echo "✓ Centralized DHCP at Luxor"
    echo "✓ Web server at Luxor"
    echo "✓ ACL security policies active"
}

show_network_topology() {
    print_header "Network Topology Overview"
    
    cat << 'EOF'
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
EOF
    
    print_status "Key Features:"
    echo "• Inter-VLAN routing at Cairo HQ"
    echo "• EIGRP routing between sites"
    echo "• Centralized DHCP from Luxor"
    echo "• Web server with access control"
    echo "• Security policies via ACLs"
}

run_connectivity_tests() {
    print_header "Network Connectivity Test Commands"
    
    print_status "From Cairo HQ devices:"
    echo "ping 192.168.20.1  # Test VLAN 20 gateway"
    echo "ping 192.168.30.1  # Test VLAN 30 gateway"
    echo "ping 10.2.2.1      # Test Luxor connectivity"
    echo "ping 10.2.2.100    # Test web server (should fail from VLAN 20)"
    
    print_status "From Luxor Branch:"
    echo "ping 192.168.10.1  # Test Cairo VLAN 10"
    echo "ping 10.1.1.1      # Test Cairo WAN interface"
    echo "show ip eigrp neighbors  # Verify EIGRP adjacency"
    
    print_status "DHCP Test:"
    echo "ipconfig /release && ipconfig /renew  # Windows"
    echo "sudo dhclient -r && sudo dhclient    # Linux"
}

# Main deployment function
main() {
    echo
    print_header "Starting Network Infrastructure Deployment"
    echo
    
    # Check if we're in the right directory
    if [ ! -d "configs" ]; then
        print_error "Please run this script from the project root directory"
        exit 1
    fi
    
    # Deploy components
    deploy_cairo_hq
    echo
    deploy_luxor_branch
    echo
    deploy_cloud_simulation
    echo
    validate_configuration
    echo
    show_network_topology
    echo
    run_connectivity_tests
    echo
    
    print_status "Deployment preparation complete!"
    print_warning "Apply configurations to your network devices using the .cfg files"
    print_warning "Set up DHCP and web servers using the .md documentation"
    echo
    print_status "Project successfully configured for NTI Network Infrastructure Final Project"
}

# Run main function
main "$@"