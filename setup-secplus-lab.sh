#!/bin/bash

set -euo pipefail

echo "========================================"
echo " Security+ Blue Team Lab Configuration"
echo "========================================"

if [[ $EUID -ne 0 ]]; then
    echo "Run this script as root."
    exit 1
fi

LABUSER="analyst"
LABPASS="Password123!"
TTYD_PORT="7681"

echo
echo "[1/15] Updating system..."
dnf -y update

echo
echo "[2/15] Installing packages..."
dnf install -y \
    vim \
    git \
    wget \
    curl \
    firewalld \
    audit \
    aide \
    openssl \
    httpd \
    cronie \
    sudo \
    policycoreutils-python-utils \
    fail2ban \
    epel-release

# Install ttyd
if ! command -v ttyd >/dev/null 2>&1; then
    dnf install -y ttyd || true
fi

if ! command -v ttyd >/dev/null 2>&1; then
    ARCH=$(uname -m)

    case "$ARCH" in
        x86_64)
            URL="https://github.com/tsl0922/ttyd/releases/latest/download/ttyd.x86_64"
            ;;
        aarch64)
            URL="https://github.com/tsl0922/ttyd/releases/latest/download/ttyd.aarch64"
            ;;
        *)
            echo "Unsupported architecture: $ARCH"
            exit 1
            ;;
    esac

    curl -L "$URL" -o /usr/local/bin/ttyd
    chmod +x /usr/local/bin/ttyd
fi

echo
echo "[3/15] Enabling services..."
systemctl enable firewalld --now
systemctl enable auditd --now
systemctl enable crond --now
systemctl enable httpd --now

echo
echo "[4/15] Creating users..."

useradd analyst 2>/dev/null || true
useradd intern 2>/dev/null || true
useradd contractor 2>/dev/null || true

echo "analyst:${LABPASS}" | chpasswd
echo "intern:Password123!" | chpasswd
echo "contractor:Password123!" | chpasswd

usermod -aG wheel analyst

echo
echo "[5/15] Configuring password policy..."

chage -M 99999 intern
chage -M 90 analyst
chage -M 60 contractor

echo
echo "[6/15] Creating vulnerable resources..."

mkdir -p /opt/company

echo "Payroll Data" > /opt/company/payroll.xlsx
echo "VPN Secrets" > /opt/company/vpn.txt
echo "Quarterly Reports" > /opt/company/reports.doc

chmod 777 /opt/company
chmod 666 /opt/company/vpn.txt

mkdir -p /shared
chmod 777 /shared

echo
echo "[7/15] Configuring web portal..."

cat >/var/www/html/index.html <<EOF
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<title>Security+ Blue Team Lab</title>

<style>

body{
    font-family:Arial,Helvetica,sans-serif;
    background:#f4f4f4;
    margin:40px;
}

.container{
    max-width:900px;
    margin:auto;
    background:#fff;
    padding:30px;
    border-radius:8px;
}

h1{
    color:#1e3a5f;
}

a.button{
    display:inline-block;
    padding:12px 24px;
    background:#0069d9;
    color:white;
    text-decoration:none;
    border-radius:5px;
}

code{
    background:#eee;
    padding:2px 5px;
}

</style>

</head>

<body>

<div class="container">

<h1>Security+ Blue Team Lab</h1>

<p>This lab is completed entirely from your browser.</p>

<h2>Login</h2>

<p>
Username:
<strong>${LABUSER}</strong>
</p>

<p>
Password:
<strong>${LABPASS}</strong>
</p>

<p>
<a class="button" href="http://$(hostname -I | awk '{print $1}'):${TTYD_PORT}">
Launch Browser Terminal
</a>
</p>

<h2>Objectives</h2>

<ol>

<li>Audit local users</li>
<li>Review sudo permissions</li>
<li>Review password aging</li>
<li>Secure SSH configuration</li>
<li>Disable root SSH login</li>
<li>Correct insecure permissions</li>
<li>Review firewall rules</li>
<li>Review logs</li>
<li>Review audit rules</li>
<li>Verify AIDE</li>
<li>Review cron jobs</li>
<li>Inventory services</li>
<li>Secure shared directories</li>
<li>Review SELinux</li>
<li>Identify unnecessary software</li>

</ol>

</div>

</body>

</html>
EOF

echo
echo "[8/15] Creating self-signed certificate..."

mkdir -p /etc/pki/tls/private

openssl req \
-x509 \
-newkey rsa:2048 \
-days 365 \
-nodes \
-keyout /etc/pki/tls/private/lab.key \
-out /etc/pki/tls/certs/lab.crt \
-subj "/CN=training.lab"

echo
echo "[9/15] Configuring firewall..."

firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-port=${TTYD_PORT}/tcp
firewall-cmd --reload

echo
echo "[10/15] Creating cron job..."

cat >/etc/cron.d/system_cleanup <<EOF
0 * * * * root echo cleanup >/dev/null
EOF

echo
echo "[11/15] Creating log entries..."

logger "Failed login for user admin"
logger "Privilege escalation attempt detected"
logger "USB device connected"
logger "Firewall configuration modified"

echo
echo "[12/15] Creating audit rules..."

cat >/etc/audit/rules.d/secplus.rules <<EOF
-w /etc/passwd -p wa
-w /etc/shadow -p wa
-w /etc/sudoers -p wa
-w /etc/ssh/sshd_config -p wa
EOF

augenrules --load || true

echo
echo "[13/15] Initializing AIDE..."

aide --init || true

if [[ -f /var/lib/aide/aide.db.new.gz ]]; then
    mv /var/lib/aide/aide.db.new.gz \
       /var/lib/aide/aide.db.gz
fi

echo
echo "[14/15] Enabling Fail2Ban..."

systemctl enable fail2ban --now || true

echo
echo "[15/15] Configuring browser terminal..."

cat >/etc/systemd/system/ttyd.service <<EOF
[Unit]
Description=Browser Terminal
After=network.target

[Service]
User=${LABUSER}
WorkingDirectory=/home/${LABUSER}
ExecStart=/usr/bin/ttyd --port ${TTYD_PORT} --writable /bin/bash
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable ttyd --now

cat >/usr/local/bin/lab-score <<'EOF'
#!/bin/bash

score=0
total=5

grep -q "^PermitRootLogin no" /etc/ssh/sshd_config && ((score++))
grep -q "^PasswordAuthentication no" /etc/ssh/sshd_config && ((score++))
[[ "$(stat -c %a /shared)" != "777" ]] && ((score++))
[[ "$(stat -c %a /opt/company/vpn.txt)" != "666" ]] && ((score++))
firewall-cmd --list-services | grep -q ssh || ((score++))

echo
echo "Lab Score: ${score}/${total}"
echo
EOF

chmod +x /usr/local/bin/lab-score

IP=$(hostname -I | awk '{print $1}')

echo
echo "========================================"
echo "Lab Ready"
echo "========================================"
echo
echo "Open:"
echo
echo "    http://${IP}"
echo
echo "Click 'Launch Browser Terminal'"
echo
echo "Username: ${LABUSER}"
echo "Password: ${LABPASS}"
echo
echo "Students complete every task from the browser."
echo
