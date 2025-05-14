🛑 New Hire Welcome Email Automation

This project automates the process of sending a personalized Welcome Email to new hires using a combination of PowerShell and an HTML email template.

---

📋 Features

Automatically sends a personalized HTML-formatted email to new hires.
Uses a clean and professional HTML email template.
Can be integrated with onboarding workflows or triggered manually.
Supports customization of subject, sender, and body content.

---

🛠️ Files

Welcome_Email.ps1 – PowerShell script that sends the welcome email.
Welcome_Email.html – HTML file used as the body of the welcome email.
README.md – This file.

---

🚀 How It Works

The PowerShell script imports the HTML file.
Replaces placeholders like {{FirstName}}, {{StartDate}}, etc.
Sends the email via SMTP (e.g., Office 365, Exchange).

---

✅ Requirements

PowerShell 5.1+ (Windows)
SMTP server access (Office 365, Exchange, etc.)
HTML email rendering in recipient’s email client

---

🔐 Security Note
Avoid hardcoding sensitive information like passwords or API keys. Use secure credential storage (e.g., Windows Credential Manager or encrypted config files).
