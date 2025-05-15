# Welcome Email Automation Script

This PowerShell and HTML-based solution is designed to automatically send a customized welcome email to newly created Active Directory users and their respective managers.

## 📋 Overview

The system includes two components:

- `Welcome_Email.ps1` – A PowerShell script that:
  - Searches Active Directory for newly created accounts.
  - Retrieves user and manager details.
  - Retrieves Human Resource contacts based on Active Directory group assignment.
  - Sends a personalized welcome email using a pre-defined HTML template.

- `Welcome_Email.html` – An HTML file used as the template for the welcome message.

## 🔧 Features

- Detects new AD user accounts (based on date of creation of the user account).
- Builds a customized welcome email using user attributes.
- Sends email to:
  - The new employee
  - Their direct manager
- Email includes:
  - Welcome message
  - Important onboarding links
  - Company resources

## 🖥️ Usage

Run the PowerShell script manually or on a schedule (e.g., via Task Scheduler):

```powershell
.\Welcome_Email.ps1
```

I have the .ps1 and .html files stored on a VM that is used for automation. This server has a scheduled task in place to run every morning at 6am whether there was a newly created user or not.

The script:
1. Scans Active Directory for users created within a configurable timeframe.
2. Loads the `Welcome_Email.html` template.
3. Replaces placeholders with actual user data.
4. Sends the formatted email via your SMTP server.

## ✉️ HTML Email Template

The `Welcome_Email.html` file should include placeholders such as:

```html
<p>Hello {{FirstName}},</p>
<p>Welcome to the company!</p>
<p>Your manager is {{ManagerName}}.</p>
```

These are dynamically replaced using PowerShell before sending the email.

## ✅ Requirements

- PowerShell 5.1+
- Active Directory module
- SMTP relay or mail server
- Permissions to query AD and send mail

## ⚠️ Notes

- Ensure your SMTP server allows relaying.
- Customize the HTML template for your branding and content.
- Test with dummy users before going live.

## 📌 Future Enhancements

- Web-based configuration dashboard
- Integration with HR systems
- Multilingual email templates
