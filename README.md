# blue-lab
Security+ Blue-team lab WIP

# Security+ Blue Team Lab

## Overview

This lab is designed to provide hands-on experience with common host security tasks covered in the CompTIA Security+ certification. Students will analyze a Linux server, identify security issues, and apply security best practices to harden the system.

This is a blue-team lab. There are no intentionally exploitable services or malware. The objective is to identify and remediate security findings through system administration and security auditing.

---

## Learning Objectives

Students will learn how to:

* Audit user accounts and permissions
* Apply the principle of least privilege
* Secure SSH configuration
* Configure and review firewall rules
* Investigate system logs
* Review scheduled tasks
* Monitor system activity with Auditd
* Verify file integrity using AIDE
* Manage password policies
* Inventory running services
* Review SELinux status
* Document security findings

---

## Lab Accounts

The following user accounts are created during setup:

* analyst
* intern
* contractor

Each account is assigned a default password during installation. Instructors may change these passwords before distributing the lab.

---

## Student Tasks

Complete the following activities:

1. Identify all local user accounts.
2. Review group memberships.
3. Determine which users have administrative privileges.
4. Audit password expiration policies.
5. Review the SSH configuration.
6. Disable unnecessary root access.
7. Review authentication settings.
8. Identify insecure file permissions.
9. Secure shared directories.
10. Review firewall configuration.
11. Verify active network services.
12. Examine system logs.
13. Review Auditd rules.
14. Verify the AIDE database.
15. Review scheduled cron jobs.
16. Identify unnecessary services.
17. Review SELinux configuration.
18. Document all findings and remediation steps.

---

## Helpful Commands

View users:

```
cat /etc/passwd
```

View sudo privileges:

```
sudo -l
```

Review password aging:

```
chage -l username
```

Review SSH configuration:

```
cat /etc/ssh/sshd_config
```

Check firewall rules:

```
firewall-cmd --list-all
```

View running services:

```
systemctl list-units --type=service
```

Review logs:

```
journalctl
```

View authentication logs:

```
journalctl -u sshd
```

Search recent log messages:

```
journalctl -xe
```

Review Auditd rules:

```
auditctl -l
```

Run an AIDE integrity check:

```
aide --check
```

Review cron jobs:

```
ls -la /etc/cron*
```

Check SELinux status:

```
getenforce
```

List listening ports:

```
ss -tulpn
```

---

## Success Criteria

Students should be able to:

* Remove unnecessary administrative access.
* Harden the SSH configuration.
* Correct insecure file permissions.
* Verify firewall settings.
* Understand system logging.
* Review audit policies.
* Verify file integrity.
* Improve password policies.
* Reduce unnecessary attack surface.
* Explain each security improvement made.

---

## Instructor Notes

This lab is intended for educational use only. It demonstrates common security misconfigurations that students are expected to identify and remediate as part of a defensive security exercise. It is recommended that this lab be deployed in an isolated training environment or otherwise restricted to authorized participants.

---

End of README
