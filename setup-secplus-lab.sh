#!/bin/bash

set -euo pipefail

echo "========================================"
echo " Security+ Blue Team Lab Configuration"
echo "========================================"

[[ $EUID -eq 0 ]] || { echo "Run as root."; exit 1; }

LABUSER="analyst"
LABPASS="Password123!"
TTYD_PORT="7681"

echo "[1/15] Updating system..."
dnf -y update

echo "[2/15] Installing packages..."

# ERROR FIX:
# fail2ban is in EPEL on CentOS Stream 9.
# Install EPEL before looking for fail2ban.

dnf install -y epel-release

dnf install -y \
vim git wget curl firewalld audit aide openssl \
httpd cronie sudo policycoreutils-python-utils

# ERROR FIX:
# Some CentOS installations may not have fail2ban available.
# Do not stop the lab if it cannot be installed.

dnf install -y fail2ban || echo "Fail2Ban unavailable - skipping."

# Install ttyd
if ! command -v ttyd >/dev/null; then

    # ERROR FIX:
    # ttyd is not normally in CentOS repositories.

    curl -L \
    https://github.com/tsl0922/ttyd/releases/latest/download/ttyd.x86_64 \
    -o /usr/local/bin/ttyd

    chmod +x /usr/local/bin/ttyd
fi

TTYD_BIN=$(command -v ttyd)


echo "[3/15] Starting services..."

systemctl enable --now firewalld auditd crond httpd


echo "[4/15] Creating users..."

# ERROR FIX:
# -m ensures home directories exist for ttyd.

for u in analyst intern contractor; do
    id "$u" >/dev/null 2>&1 || useradd -m "$u"
done

echo "analyst:${LABPASS}" | chpasswd
echo "intern:Password123!" | chpasswd
echo "contractor:Password123!" | chpasswd

usermod -aG wheel analyst


echo "[5/15] Password policy..."

chage -M 90 analyst
chage -M 99999 intern
chage -M 60 contractor


echo "[6/15] Creating lab files..."

mkdir -p /opt/company /shared

echo "Payroll Data" > /opt/company/payroll.xlsx
echo "VPN Secrets" > /opt/company/vpn.txt
echo "Quarterly Reports" > /opt/company/reports.doc

chmod 777 /opt/company /shared
chmod 666 /opt/company/vpn.txt


echo "[7/15] Creating web portal..."

cat >/var/www/html/index.html <<EOF
<html>
<head><title>Security+ Blue Team Lab</title></head>
<body>
<h1>Security+ Blue Team Lab</h1>

<p>Browser Terminal:</p>

<a href="http://$(hostname -I | awk '{print $1}'):${TTYD_PORT}">
Launch Terminal
</a>

<p>
Username: ${LABUSER}<br>
Password: ${LABPASS}
</p>

<h3>Objectives</h3>
<ul>
<li>User auditing</li>
<li>Password policies</li>
<li>Sudo review</li>
<li>SSH security</li>
<li>Firewall review</li>
<li>Logs and audit rules</li>
<li>AIDE verification</li>
<li>SELinux review</li>
</ul>

</body>
</html>
EOF


echo "[8/15] Creating certificate..."

openssl req -x509 -newkey rsa:2048 \
-days 365 -nodes \
-keyout /etc/pki/tls/private/lab.key \
-out /etc/pki/tls/certs/lab.crt \
-subj "/CN=training.lab"


echo "[9/15] Firewall..."

firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-port=${TTYD_PORT}/tcp
firewall-cmd --reload


echo "[10/15] Cron..."

echo "0 * * * * root echo cleanup >/dev/null" \
>/etc/cron.d/system_cleanup


echo "[11/15] Logs..."

logger "Failed login for user admin"
logger "Privilege escalation attempt detected"
logger "USB device connected"


echo "[12/15] Audit rules..."

cat >/etc/audit/rules.d/secplus.rules <<EOF
-w /etc/passwd -p wa
-w /etc/shadow -p wa
-w /etc/sudoers -p wa
-w /etc/ssh/sshd_config -p wa
EOF

augenrules --load || true


echo "[13/15] AIDE..."

mkdir -p /var/lib/aide

aide --init || true

[[ -f /var/lib/aide/aide.db.new.gz ]] &&
mv /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz


echo "[14/15] Fail2Ban..."

# ERROR FIX:
# Do not fail if Fail2Ban was unavailable.

systemctl enable --now fail2ban 2>/dev/null || \
echo "Fail2Ban not installed."


echo "[15/15] Browser terminal..."

cat >/etc/systemd/system/ttyd.service <<EOF
[Unit]
Description=Browser Terminal
After=network.target

[Service]
User=${LABUSER}
WorkingDirectory=/home/${LABUSER}
ExecStart=${TTYD_BIN} --port ${TTYD_PORT} --writable /bin/bash
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now ttyd


cat >/usr/local/bin/lab-score <<'EOF'
#!/bin/bash

score=0
total=5

grep -q "PermitRootLogin no" /etc/ssh/sshd_config && ((score++))
grep -q "PasswordAuthentication no" /etc/ssh/sshd_config && ((score++))
[[ "$(stat -c %a /shared)" != "777" ]] && ((score++))
[[ "$(stat -c %a /opt/company/vpn.txt)" != "666" ]] && ((score++))
firewall-cmd --list-services | grep -q ssh || ((score++))

echo "Lab Score: $score/$total"
EOF

chmod +x /usr/local/bin/lab-score


IP=$(hostname -I | awk '{print $1}')

echo
echo "========================================"
echo "Lab Ready"
echo "========================================"
echo
echo "Open: http://${IP}"
echo "Username: ${LABUSER}"
echo "Password: ${LABPASS}"
