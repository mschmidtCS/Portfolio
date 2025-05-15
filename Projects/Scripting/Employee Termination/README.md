# Employee Termination Automation Script

This interactive PowerShell script is designed to automate the offboarding process for terminated employees in Active Directory and Microsoft 365 environments.

## 🔧 Features

Upon execution, the script performs the following actions for a specified user:

1. **Disables the user's AD account**
2. **Clears sensitive AD attributes:**
   - City
   - State
   - Job Title
   - Department
   - Manager
   - Direct Reports  
   *(Clearing these attributes triggers removal from Dynamic Groups during the next AD Connect sync cycle.)*
3. **Appends the disable date to the user's AD Description field**
4. **Removes the user from all Active Directory groups**
5. **Removes all assigned Microsoft 365 licenses**
6. **Removes the user from all Distribution Lists**
7. **Removes the user from all Microsoft 365 and security groups**
8. **Revokes access to Shared Mailboxes**
9. **Logs all actions taken**  
   *(Logs include timestamps, actions performed, and what objects/permissions were removed.)*

## 🖥️ Usage

> 💡 Run the script with elevated privileges on a machine with RSAT tools, Exchange Online, and MSOnline/Graph modules installed.

```powershell
.\Terminate-Employee.ps1
```

The script will prompt you for the username (SAMAccountName or UPN) and confirm before making changes.

## 📁 Logging

A detailed log file is generated for each terminated user and saved to:

```
C:\Scripts\TerminationLogs\username-yyyyMMdd-HHmmss.log
```

Logs include:
- Pre-removal attributes
- Groups and licenses removed
- Errors (if any)

## ✅ Requirements

- PowerShell 5.1+
- Active Directory Module
- MSOnline and/or Microsoft Graph PowerShell SDK
- Exchange Online PowerShell Module
- Appropriate admin privileges

## ⚠️ Warnings

- This script **modifies user accounts permanently**.
- Always run this script in a **test environment first** before deploying to production.
- It is highly recommended to **back up user attributes and group memberships** before deletion.

## 📌 Future Enhancements

- GUI version with checkbox options
- Integration with ticketing systems
- Optional email notification to HR/Manager
