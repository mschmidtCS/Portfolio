##############################################################################################################################################################################
#
#   Name     : Welcome Email.ps1
#   Version  : 1.0
#   Authors  : Mike Schmidt
#   Date     : 03/05/2025
#
#   --This script is used with "welcome_email.html" to send an automated welcome email to new hires. 
#   --This ps1 file is what sends the email from **INTERNAL EMAIL ADDRESS**
#
##############################################################################################################################################################################
Import-Module ActiveDirectory

# Enable TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Set how far back to check for new accounts (Currently set to look back at the previous day at 00:00)
[string]$CheckDate = (Get-Date).AddDays(-1).Date

# Email configuration
$MsgFrom = **INTERNAL EMAIL ADDRESS**
$SmtpServer = "smtp.office365.com"
$SmtpPort = **PORT**
$BccRecipients = @(**INTERNAL EMAIL ADDRESS**)

# Fetch new users from AD
$Users = Get-ADUser -Filter * -Properties WhenCreated, EmailAddress, DisplayName, MemberOf | 
            Where-Object { 
                $_.WhenCreated -ge $CheckDate -and 
                $_.MemberOf -contains (Get-ADGroup -Filter { Name -eq "AD GROUP" }).DistinguishedName
            }

# Get HR Contacts
$Department = "Human Resources"
$HRUsers = Get-ADUser -Filter {Department -eq $Department} -Properties DisplayName, EmailAddress, Title | 
            Select-Object DisplayName, EmailAddress, Title

# Convert HR contacts to an HTML list
$HRList = ($HRUsers | ForEach-Object { "<li>$($_.DisplayName) ($($_.Title)) - <a href='mailto:$($_.EmailAddress)'>$($_.EmailAddress)</a></li>" }) -join "`n"

# Load the HTML email template
$EmailTemplatePath = "**NETWORK FILE LOCATION"
$EmailBodyTemplate = Get-Content -Path $EmailTemplatePath -Raw

# Email credentials
$Username = "**INTERNAL AUTOMATION EMAIL ADDRESS**"
$Password = "**PASSWORD**" | ConvertTo-SecureString -AsPlainText -Force
$Creds = New-Object System.Net.NetworkCredential($Username, $Password)

# Create SMTP client
$SMTP = New-Object System.Net.Mail.SmtpClient($SmtpServer, $SmtpPort)
$SMTP.EnableSsl = $true
$SMTP.Credentials = $Creds

# Loop through each new user and send an email
ForEach ($User in $Users) {
    try {
        $ADUser = Get-ADUser -Identity $User -Properties Department, Manager
        $Manager = if ($ADUser.Manager) { (Get-ADUser -Identity $ADUser.Manager).Name } else { "N/A" }
        $UserManager = if ($ADUser.Manager) { (Get-ADUser -Identity $ADUser.Manager).SamAccountName } else { "N/A" }

        if ($ADUser.EmailAddress) {
            $EmailRecipient = $ADUser.EmailAddress
        } else {
            # If no email address, create one based on the username and a domain
            $Domain = "**EMAIL DOMAIN**"  # Replace with your actual domain
            $EmailRecipient = "$($ADUser.SamAccountName)@$Domain"
            
            # Set the email address in Active Directory if needed
            Set-ADUser -Identity $ADUser.SamAccountName -EmailAddress $EmailRecipient
        }

        # Replace placeholders with user data
        $EmailBody = $EmailBodyTemplate -replace "{{UserName}}", $User.DisplayName `
                                        -replace "{{Department}}", $ADUser.Department `
                                        -replace "{{Manager}}", $Manager `
                                        -replace "{{UserManager}}", $UserManager `
                                        -replace "{{HRList}}", $HRList

        # Create MailMessage object
        $MailMessage = New-Object System.Net.Mail.MailMessage
        $MailMessage.From = $MsgFrom
        $MailMessage.To.Add($EmailRecipient)
        # Add multiple BCC recipients
        foreach ($Bcc in $BccRecipients) {
            $MailMessage.Bcc.Add($Bcc)
        }
        #$MailMessage.Bcc.Add($BccRecipients)
        $MailMessage.Subject = "Welcome to Walker Products"
        $MailMessage.Body = $EmailBody
        $MailMessage.IsBodyHtml = $true

        # Send email
        $SMTP.Send($MailMessage)
        Write-Host "Welcome email sent to $($User.DisplayName)"
    }
    catch {
        Write-Host "Error sending email to $($User.DisplayName): $_"
    }
}

# Dispose SMTP client
$SMTP.Dispose()
