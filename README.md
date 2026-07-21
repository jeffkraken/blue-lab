# blue-lab

Browser-based Security+ Blue Team Lab for Rocky Linux

---

# Security+ Blue Team Lab

## Overview

This project provides a hands-on blue-team lab aligned with the CompTIA Security+ certification objectives. Students investigate and harden a Linux system by identifying common security misconfigurations and applying defensive best practices.

Unlike traditional labs that require SSH access, this lab is completed entirely through a web browser using an embedded Linux terminal. Students connect to the lab portal, launch the browser terminal, and perform all tasks directly from the web interface.

The lab intentionally includes insecure configurations for educational purposes. There is no malware or intentionally exploitable application. The objective is to perform security auditing and system hardening using standard Linux administration tools.

---

## Features

- Browser-based terminal (no SSH client required)
- Rocky Linux environment
- Apache-hosted lab portal
- Preconfigured security misconfigurations
- Auditd
- AIDE
- Fail2Ban
- Firewalld
- SELinux
- System logging
- Scheduled tasks
- Multiple user accounts
- Password policy review
- File permission auditing

---

## Learning Objectives

Students will learn how to:

- Audit local user accounts
- Review group memberships
- Apply the principle of least privilege
- Review password aging policies
- Secure SSH configuration
- Disable unnecessary root login
- Review authentication settings
- Identify insecure file permissions
- Secure shared directories
- Review firewall configuration
- Inventory running services
- Examine system logs
- Review Auditd rules
- Verify AIDE configuration
- Review scheduled cron jobs
- Review SELinux status
- Document security findings and remediation steps

---

## Lab Deployment

Run the installation script as root:

```bash
curl -fsSL https://raw.githubusercontent.com/jeffkraken/blue-lab/main/setup-secplus-lab.sh | bash
```

The installer will:

- Update the operating system
- Install required packages
- Configure Apache
- Install and configure ttyd
- Create lab users
- Configure intentional security weaknesses
- Configure Auditd
- Initialize AIDE
- Enable Fail2Ban
- Configure Firewalld
- Deploy the browser-based lab portal

---

## Accessing the Lab

After installation, the script displays the server IP address.

Open a browser and navigate to:

```
http://SERVER_IP
```

Click **Launch Browser Terminal**.

Login with:

```
Username: analyst
Password: Password123!
```

No SSH client is required.

---

## Lab Accounts

The installer creates the following users:

| Username | Purpose |
|-----------|----------|
| analyst | Primary student account |
| intern | Standard user |
| contractor | Standard user |

Default password:

```
Password123!
```

Instructors are encouraged to change passwords before classroom use.

---

## Student Tasks

Students should complete the following activities:

1. Identify all local user accounts.
2. Review group memberships.
3. Determine administrative privileges.
4. Audit password expiration policies.
5. Review SSH configuration.
6. Disable root SSH login.
7. Disable password authentication for SSH.
8. Identify insecure file permissions.
9. Secure shared directories.
10. Review firewall configuration.
11. Verify active network services.
12. Examine system logs.
13. Review Auditd rules.
14. Verify the AIDE database.
15. Review scheduled cron jobs.
16. Review SELinux configuration.
17. Identify unnecessary software or services.
18. Document all remediation steps.

---

## Useful Commands

List users:

```bash
cat /etc/passwd
```

Review group membership:

```bash
groups analyst
```

Review sudo access:

```bash
sudo -l
```

Password aging:

```bash
chage -l analyst
```

SSH configuration:

```bash
cat /etc/ssh/sshd_config
```

Firewall configuration:

```bash
firewall-cmd --list-all
```

Running services:

```bash
systemctl list-units --type=service
```

Recent system logs:

```bash
journalctl
```

Authentication logs:

```bash
journalctl -u sshd
```

Audit rules:

```bash
auditctl -l
```

Run an AIDE integrity check:

```bash
aide --check
```

Review cron jobs:

```bash
ls -la /etc/cron*
```

SELinux status:

```bash
getenforce
```

Listening network ports:

```bash
ss -tulpn
```

View lab score (if enabled):

```bash
lab-score
```

---

## Success Criteria

Students should be able to:

- Remove unnecessary administrative access
- Harden the SSH configuration
- Correct insecure permissions
- Secure shared directories
- Verify firewall settings
- Review system logs
- Understand Auditd monitoring
- Verify AIDE integrity checking
- Review password policies
- Reduce unnecessary attack surface
- Explain each remediation performed

---

## Instructor Notes

This lab intentionally includes several insecure configurations that students are expected to identify and correct.

Examples include:

- Weak SSH configuration
- Root SSH login enabled
- World-writable files and directories
- Weak password aging policies
- Overly permissive file permissions
- Security-relevant log entries
- Reviewable Auditd rules
- Scheduled system tasks

The lab is intended for isolated training environments and should not be exposed to production networks.

---

## Requirements

- Rocky Linux 9
- Root access
- Internet connection during installation
- Modern web browser (Chrome, Firefox, Edge, or Safari)

---

## License

This project is intended for educational and training purposes.
