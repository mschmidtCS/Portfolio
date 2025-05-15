# Local Administrator Account Hardening Script

This PowerShell script is designed to enhance endpoint security by disabling all default and unmanaged local administrator accounts, then creating a secure, configured local admin account with a known password.

## 🛡️ Purpose

To reduce attack surface and enforce standard administrative access policies across workstations and servers by:
- Disabling built-in and legacy local administrator accounts
- Creating a single, managed local admin account that adheres to company security standards

## 🔧 Features

- Identifies and disables:
  - Built-in Administrator account (`Administrator`)
  - Any other local accounts in the Administrators group (except the one you configure)
- Creates a new local administrator account:
  - Custom username (defined in script or passed as parameter)
  - Secure password (from a vault, encrypted file, or script input)
  - Added to the local Administrators group

## 🖥️ Usage

I have the script ran via a Workflow from our RMM (Kaseya VSA X). This workflow is set to run once a week to ensure complete coverage. 

### Optional Parameters:
- `-Username` — Desired username for the new local admin account
- `-Password` — Password to assign to the new account (consider using a secure string or vault)

## ✅ Requirements

- PowerShell 5.1+
- Administrative privileges on the endpoint
- Script must not be blocked by antivirus or local policy
- RMM workflow capabilities

## ⚠️ Warnings

- This script **permanently disables** local administrator accounts. Ensure you have physical or remote recovery access.
- If deployed via automation (e.g., RMM, Intune), test thoroughly before wide deployment.
- For password security, avoid hardcoding plain text passwords in production environments.

## 📌 Future Enhancements

- Password pulled securely from Azure Key Vault or Credential Manager
- LAPS (Local Administrator Password Solution) integration
- Centralized logging to SIEM or syslog

