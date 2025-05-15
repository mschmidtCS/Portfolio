# Disable Administrator account if it exists
$adminUser = Get-LocalUser -Name "Administrator" -ErrorAction SilentlyContinue
if ($adminUser) {
    if ($adminUser.Enabled) {
        Disable-LocalUser -Name "Administrator"
        Write-Host "Administrator has been disabled." -ForegroundColor Yellow
    } else {
        Write-Host "Administrator is already disabled." -ForegroundColor Green
    }
} else {
    Write-Host "Administrator does not exist." -ForegroundColor Red
}

# Disable walkeradmin account if it exists
$walkerAdmin = Get-LocalUser -Name "**INSERT OTHER LOCAL ADMIN ACCOUNT HERE**" -ErrorAction SilentlyContinue
if ($walkerAdmin) {
    if ($walkerAdmin.Enabled) {
        Disable-LocalUser -Name "LOCAL ADMIN"
        Write-Host "LOCAL ADMIN has been disabled." -ForegroundColor Yellow
    } else {
        Write-Host "LOCAL ADMIN is already disabled." -ForegroundColor Green
    }
} else {
    Write-Host "LOCAL ADMIN does not exist." -ForegroundColor Red
}

# Define password for WPAdmin (NOTE: Plaintext, not secure)
$Password = "**INSERT PASSWORD HERE**"

# Check if WPAdmin exists
$wpAdmin = Get-LocalUser -Name "NEWADMIN" -ErrorAction SilentlyContinue
if ($wpAdmin) {
    Write-Host "NEWADMIN already exists. Updating password and permissions..." -ForegroundColor Yellow
    Set-LocalUser -Name "NEWADMIN" -Password (ConvertTo-SecureString -AsPlainText $Password -Force)
    Set-LocalUser -Name "NEWADMIN" -PasswordNeverExpires $true
} else {
    Write-Host "Creating NEWADMIN user..." -ForegroundColor Cyan
    New-LocalUser -Name "NEWADMIN" -Password (ConvertTo-SecureString -AsPlainText $Password -Force) -FullName "NEWADMIN" -Description "NEW LOCAL ADMIN" -PasswordNeverExpires $true
}

# Ensure WPAdmin is in the Administrators and Users groups
Add-LocalGroupMember -Group "Users" -Member "NEWADMIN" -ErrorAction SilentlyContinue
Add-LocalGroupMember -Group "Administrators" -Member "NEWADMIN" -ErrorAction SilentlyContinue
Write-Host "NEWADMIN now has the correct password, set to never expire, and is in the Administrators Group." -ForegroundColor Green
