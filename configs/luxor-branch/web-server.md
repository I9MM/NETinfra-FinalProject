# Web Server Configuration
# Internal web server running on Luxor Branch

## Apache Web Server Setup

### Install Apache Web Server
```bash
sudo apt-get update
sudo apt-get install apache2
```

### Basic Configuration

#### Main Configuration File (/etc/apache2/apache2.conf)
```apache
# Basic Apache configuration
ServerRoot /etc/apache2
PidFile ${APACHE_PID_FILE}
Timeout 300
KeepAlive On
MaxKeepAliveRequests 100
KeepAliveTimeout 5

# Server identification
ServerTokens Prod
ServerSignature Off

# Document root
DocumentRoot /var/www/html

# Directory permissions
<Directory />
    Options FollowSymLinks
    AllowOverride None
    Require all denied
</Directory>

<Directory /var/www/html>
    Options Indexes FollowSymLinks
    AllowOverride None
    Require all granted
</Directory>

# Log configuration
ErrorLog ${APACHE_LOG_DIR}/error.log
CustomLog ${APACHE_LOG_DIR}/access.log combined
LogLevel warn
```

#### Virtual Host Configuration (/etc/apache2/sites-available/netinfra.conf)
```apache
<VirtualHost *:80>
    ServerName netinfra.local
    ServerAlias www.netinfra.local
    DocumentRoot /var/www/html/netinfra
    
    # Logging
    ErrorLog ${APACHE_LOG_DIR}/netinfra_error.log
    CustomLog ${APACHE_LOG_DIR}/netinfra_access.log combined
    
    # Security headers
    Header always set X-Content-Type-Options nosniff
    Header always set X-Frame-Options DENY
    Header always set X-XSS-Protection "1; mode=block"
    
    # Access control based on network policies
    <Directory /var/www/html/netinfra>
        # Allow access from all networks except VLAN 20 (Sales)
        # This will be enforced at the network level via ACLs
        Options Indexes FollowSymLinks
        AllowOverride None
        Require all granted
    </Directory>
</VirtualHost>
```

### Sample Web Content

#### Main Page (/var/www/html/netinfra/index.html)
```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>NETinfra Final Project - Internal Portal</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 20px;
            background-color: #f4f4f4;
        }
        .container {
            max-width: 800px;
            margin: 0 auto;
            background-color: white;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }
        .header {
            text-align: center;
            color: #333;
            border-bottom: 2px solid #007bff;
            padding-bottom: 10px;
        }
        .vlan-info {
            margin: 20px 0;
            padding: 15px;
            border-left: 4px solid #007bff;
            background-color: #f8f9fa;
        }
        .network-status {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
            margin: 20px 0;
        }
        .status-card {
            padding: 15px;
            border-radius: 5px;
            text-align: center;
        }
        .vlan10 { background-color: #d4edda; }
        .vlan20 { background-color: #f8d7da; }
        .vlan30 { background-color: #d1ecf1; }
        .vlan40 { background-color: #fff3cd; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>NETinfra Final Project</h1>
            <h2>Network Infrastructure Portal</h2>
        </div>
        
        <div class="vlan-info">
            <h3>Network Architecture Overview</h3>
            <p>This internal portal serves the network infrastructure connecting Cairo HQ and Luxor Branch via EIGRP routing with VLAN segmentation and security policies.</p>
        </div>
        
        <div class="network-status">
            <div class="status-card vlan10">
                <h4>VLAN 10</h4>
                <p>Management Network</p>
                <small>192.168.10.0/24</small>
            </div>
            <div class="status-card vlan20">
                <h4>VLAN 20</h4>
                <p>Sales Department</p>
                <small>192.168.20.0/24</small>
                <br><strong>Web Access: RESTRICTED</strong>
            </div>
            <div class="status-card vlan30">
                <h4>VLAN 30</h4>
                <p>IT Department</p>
                <small>192.168.30.0/24</small>
            </div>
            <div class="status-card vlan40">
                <h4>VLAN 40</h4>
                <p>Finance Department</p>
                <small>192.168.40.0/24</small>
                <br><strong>Protected from VLAN 10</strong>
            </div>
        </div>
        
        <div class="vlan-info">
            <h3>Security Policies Active</h3>
            <ul>
                <li>VLAN 10 (Management) blocked from accessing VLAN 40 (Finance)</li>
                <li>VLAN 20 (Sales) restricted from accessing this web server</li>
                <li>Inter-VLAN routing controlled via multilayer switch</li>
                <li>Centralized DHCP services from Luxor Branch</li>
            </ul>
        </div>
        
        <div class="vlan-info">
            <h3>System Status</h3>
            <p>Server Location: Luxor Branch (10.2.2.100)</p>
            <p>DHCP Server: Active on Luxor Branch</p>
            <p>Routing Protocol: EIGRP AS 100</p>
            <p>Last Updated: <span id="timestamp"></span></p>
        </div>
    </div>
    
    <script>
        document.getElementById('timestamp').textContent = new Date().toLocaleString();
    </script>
</body>
</html>
```

### Enable and Start Web Server
```bash
# Create document directory
sudo mkdir -p /var/www/html/netinfra

# Enable site
sudo a2ensite netinfra
sudo a2dissite 000-default

# Enable required modules
sudo a2enmod headers
sudo a2enmod rewrite

# Test configuration
sudo apache2ctl configtest

# Start and enable service
sudo systemctl enable apache2
sudo systemctl start apache2
sudo systemctl status apache2
```

### Web Server Security
The web server security is primarily enforced through network-level ACLs configured on the Cairo HQ multilayer switch, which blocks VLAN 20 (Sales) from accessing the web server IP address (10.2.2.100).