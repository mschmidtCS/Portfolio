# USB Storage Block Enforcement  

This documents the implementation of a USB storage device blocking policy across all managed devices using **Kaseya VSA X**. The solution enforces endpoint data loss prevention (DLP) by restricting access to removable storage, significantly reducing the risk of unauthorized data exfiltration.

## 🎯 Objectives

- Prevent unauthorized use of USB mass storage devices
- Reduce risk of data leakage and malicious device infections
- Centrally enforce and monitor USB security policy
- Maintain user productivity while securing endpoints

## 🔧 Solution Summary

The enforcement is accomplished using a custom PowerShell script combined with an automated workflow in **Kaseya VSA X**.

### ✅ Key Features

- Blocks USB mass storage access via Windows Registry settings
- Exceptions can be added for approved users/endpoints
- Compatible with Windows 10/11 endpoints
- Script auto-deploys during onboarding or on-demand
- Audit logs sent to Kaseya for reporting and visibility

## 🖥️ Deployment Method

| Step | Description                            |
|------|----------------------------------------|
| 1    | PowerShell script developed to modify registry |
| 2    | Workflow in VSA X configured to run script on all managed Windows machines |
| 3    | Scheduled automation for new device enrollment |
| 4    | Alerting for script failure or policy bypass detection |

## ⚙️ Script Highlights

- Disables `USBSTOR` service via registry
- Runs silently with no user disruption

## 🔐 Security Benefits

- Reduces insider threat vectors
- Ensures DLP compliance across managed environments
- Strengthens endpoint hardening policy
- Ensures uniform enforcement at scale

## 🛠️ Maintenance

- Review policy exceptions monthly
- Update device ID whitelist as needed
- Re-deploy to endpoints with altered registry permissions
- Monitor audit logs for attempted policy circumvention

## 📌 Future Enhancements

- Integrate with endpoint compliance dashboards
- Deploy user notification on USB block attempt
- Add reporting into executive security summaries

## 📂 Files and Documentation

This repository may include:
- PowerShell deployment script
- Workflow configuration
- Documentation for manual override (for IT staff only)

---

**Maintainer**: *Michael Schmidt*  
**Tools Used**: Kaseya VSA X, PowerShell, Windows Registry Policies
