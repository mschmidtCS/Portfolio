🛑 Employee Termination Script

This powershell script automates the offboarding process for terminated employees, helping IT and security teams efficiently disable access and ensure proper cleanup of user accounts and resources.

---

📌 Purpose

Designed to streamline and standardize the employee termination process by:
- Disabling user accounts
- Revoking access to systems and applications
- Logging actions for auditing purposes

---

⚙️ Features

- ✅ Disable Active Directory and cloud accounts
- ✅ Remove City, State, Job Title and Department attributes from their AD account 
- ✅ Remove direct reports and manager from AD account
- ✅ Send user to our "Pending Deletion" AD OU and update their user descrition to the date they were terminated.
- ✅ Remove user from all Distribution Lists they are a member of
- ✅ Remove user from all M365, Security, and AD groups they are a member of
- ✅ Remove user from all Shared Mailboxes they have permissions on 
- ✅ Remove user from application licensing.
- ✅ Generate log/report of all actions taken
- ✅ See additional features in the 

---

🛠️ Technologies Used

- Script Language: PowerShell
- Integrations: [Active Directory, Azure AD, Microsoft 365, Exchange Online]
- Logging: Writes to a log file located on a network file server

---

📥 How to Use

1. **Clone or copy the Script file
