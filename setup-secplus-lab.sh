#!/bin/bash

set -e

echo "========================================"
echo " Security+ Blue Team Lab Configuration"
echo "========================================"

if [ "$EUID" -ne 0 ]; then
    echo "Run as root."
    exit 1
fi

##############################################
# Update System
##############################################

dnf -y update

##############################################
# Install Packages
##############################################

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
    openssh-server \
    cronie \
    sudo \
    policycoreutils-python-utils \
    fail2ban

systemctl enable firewalld --now
systemctl enable auditd --now
systemctl enable crond --now
systemctl enable sshd --now
systemctl enable httpd --now

##############################################
# Users
##############################################

useradd analyst || true
useradd intern || true
useradd contractor || true

echo "analyst:Password123!" | chpasswd
echo "intern:Password123!" | chpasswd
echo "contractor:Password123!" | chpasswd

##############################################
# Sudo Configuration
##############################################

usermod -aG wheel analyst

##############################################
# Password Aging
##############################################

chage -M 99999 intern
chage -M 90 analyst
chage -M 60 contractor

##############################################
# Create Sensitive Files
##############################################

mkdir -p /opt/company

echo "Payroll Data" > /opt/company/payroll.xlsx
echo "VPN Secrets" > /opt/company/vpn.txt
echo "Quarterly Reports" > /opt/company/reports.doc

chmod 777 /opt/company
chmod 666 /opt/company/vpn.txt

##############################################
# World Writable Directory
##############################################

mkdir -p /shared
chmod 777 /shared

##############################################
# SSH Banner
##############################################

cat >/etc/issue.net <<EOF
Authorized Users Only
EOF

##############################################
# Intentionally Weak SSH Config
##############################################

cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

sed -i 's/^#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/^#PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config

grep -q "^Banner" /etc/ssh/sshd_config || \
echo "Banner /etc/issue.net" >> /etc/ssh/sshd_config

systemctl restart sshd

##############################################
# HTTP Site
##############################################

cat >/var/www/html/index.html <<EOF
<html>
<h1>Company Intranet</h1>

<p>Security+ Blue Team Lab</p>

<p>Students should audit this server.</p>

</html>
EOF

##############################################
# Self Signed Certificate
##############################################

mkdir -p /etc/pki/tls/private

openssl req -x509 \
-newkey rsa:2048 \
-days 365 \
-nodes \
-keyout /etc/pki/tls/private/lab.key \
-out /etc/pki/tls/certs/lab.crt \
-subj "/CN=training.lab"

##############################################
# Firewalld
##############################################

firewall-cmd --permanent --add-service=ssh
firewall-cmd --permanent --add-service=http
firewall-cmd --reload

##############################################
# Cron Job
##############################################

cat >/etc/cron.d/system_cleanup <<EOF
0 * * * * root echo "cleanup" >/dev/null
EOF

##############################################
# Suspicious Log Entries
##############################################

logger "Failed login for user admin"
logger "Privilege escalation attempt detected"
logger "USB device connected"
logger "Firewall configuration modified"

##############################################
# Audit Rules
##############################################

cat >/etc/audit/rules.d/secplus.rules <<EOF
-w /etc/passwd -p wa
-w /etc/shadow -p wa
-w /etc/sudoers -p wa
-w /etc/ssh/sshd_config -p wa
EOF

augenrules --load

##############################################
# AIDE
##############################################

aide --init || true

if [ -f /var/lib/aide/aide.db.new.gz ]; then
    mv /var/lib/aide/aide.db.new.gz \
       /var/lib/aide/aide.db.gz
fi

##############################################
# Fail2Ban
##############################################

systemctl enable fail2ban --now || true

##############################################
# Lab Notes
##############################################

cat >/root/LAB-README.txt <<EOF

=============================
Security+ Blue Team Lab
=============================

Objectives

1. Audit users

2. Review sudo permissions

3. Review password aging

4. Secure SSH

5. Remove unnecessary root login

6. Find insecure permissions

7. Review firewall

8. Examine logs

9. Review audit rules

10. Verify AIDE

11. Review cron jobs

12. Inventory running services

13. Lock down shared directories

14. Correct file permissions

15. Review SELinux status

16. Identify unnecessary software

EOF

echo
echo "======================================"
echo "Lab Ready"
echo "======================================"
echo
echo "Read:"
echo
echo "/root/LAB-README.txt"
echo
