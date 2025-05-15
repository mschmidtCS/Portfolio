# Local Administrator Account Hardening Script

This PowerShell script is designed to enhance endpoint security by disabling all default and unmanaged local administrator accounts, then creating a secure, configured local admin account with a known password.

## 🛡️ Purpose

To reduce attack surface and enforce standard administrative access policies across workstations and servers by:
- Disabling all built-in and legacy local administrator accounts
- Creating a single, managed local admin account that adheres to company security standards

## 🔧 Features

- Identifies and disables:
  - Built-in Administrator account (`Administrator`)
  - Any other local accounts in the Administrators group (except the one you configure)
- Creates a new local administrator account:
  - Custom username (defined in script or passed as parameter)
  - Secure password (from a vault, encrypted file, or script input)
  - Added to the local Administrators group
- Optional logging for audit tracking

## 🖥️ Usage

Run the script as **Local System** or with **elevated privileges** on each target device:

```powershell
.\Configure-LocalAdmin.ps1 -Username "ManagedAdmin" -Password "YourSecurePassword123!"
```

### Optional Parameters:
- `-Username` — Desired username for the new local admin account
- `-Password` — Password to assign to the new account (consider using a secure string or vault)

## 📁 Logging

Logs are created in:

```
C:\Scripts\AdminHardeningLogs\admin-config-yyyyMMdd-HHmmss.log
```

Each log entry includes:
- Disabled accounts
- Created account details (excluding password)
- Time and hostname

## ✅ Requirements

- PowerShell 5.1+
- Administrative privileges on the endpoint
- Script must not be blocked by antivirus or local policy

## ⚠️ Warnings

- This script **permanently disables** local administrator accounts. Ensure you have physical or remote recovery access.
- If deployed via automation (e.g., RMM, Intune), test thoroughly before wide deployment.
- For password security, avoid hardcoding plain text passwords in production environments.

## 📌 Future Enhancements

- Password pulled securely from Azure Key Vault or Credential Manager
- LAPS (Local Administrator Password Solution) integration
- Centralized logging to SIEM or syslog

