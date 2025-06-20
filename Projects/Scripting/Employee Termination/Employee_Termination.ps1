##############################################################################################################################################################################
#
#   Name    : Employee Termination.ps1
#   Version : 3.5
#   Author  : Mike Schmidt
#   Date    : 1/13/2025
#
#   This powershell program is created to terminate a Walker Products Employee. 
#   
#   2.0 Update Notes: Added PS GUI updates 
#                     Updated error outputs
#                     Added removal of City, State and Manager attributes
#                     Added removal of M365 Licenses
#
#   3.0 Update Notes: Updated module versions
#                          -Found that ExchangeOnlineManagement module needed to be v3.4.0 for it to work correctly
#                          -Found that MSGraph module needed to be v2.23.0 for it to work correctly
#
#   3.1 Update Notes: Fixed issue with importing MSGraph module
#                          -Found that the MSGraph module needed to be imported before any other modules otherwise it would be overwrote by ExchangeOnlineManagement module
#
#   3.2 Update Notes: Fixed issues with removal of M365 Licenses
#
#   3.3 Update Notes: Added removal of Job Title and Department in AD
#
#   3.4 Update Notes: Added script logging to export all info to a .txt file located here: 
#                     **Fileserver Location**
#                     Added error handling for removal of AD Address attributes
#
#   3.5 Update Notes: Added search and removal of all direct reports (in AD) for the terminated user        
#
##############################################################################################################################################################################

Write-Host "Welcome to Employee Termination (v3.5)"
Write-Host "This script is actively in development. Reach out to Mike Schmidt if you notice any errors or inconsistancies." -ForegroundColor DarkYellow

Start-Sleep -Seconds 3

# Ensure you have the AzureAD module installed and imported
if (-not (Get-Module -ListAvailable -Name AzureAD)) {
    Install-Module -Name AzureAD -Force
}
# Ensure you have the Active Directory module installed and imported
if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
    Install-Module -Name ActiveDirectory -Force
}
# Ensure you have the ExchangeOnlineManagement module installed and imported
if (-not (Get-Module -ListAvailable -Name ExchangeOnlineManagement)) {
    Install-Module -Name ExchangeOnlineManagement -RequiredVersion 3.4.0 -Force
}
# Ensure you have the MSGraph module installed and imported
if (-not (Get-Module -ListAvailable -Name Microsoft.Graph)) {
    Install-Module Microsoft.Graph -RequiredVersion 2.23.0 -Force -AllowClobber
}

# -------------------------------------------------------------------------------------------------------------------------------

# Import the necessary modules
Import-Module Microsoft.Graph.Authentication
Import-Module AzureAD
Import-Module ActiveDirectory
Import-Module ExchangeOnlineManagement

# -------------------------------------------------------------------------------------------------------------------------------

# Connect to MS Graph
Write-host "`nConnecting to MS Graph..."
try {
	Connect-MgGraph -Scopes User.ReadWrite.All, Organization.Read.All
    Clear-Host
	Write-Host "Welcome to Employee Termination (v3.5)"
    Write-host "`nConnected to MS Graph"
} catch {
    Write-host "Failed to connect to MS Graph. Please relaunch the script and try again." -ForegroundColor Red
}
Start-Sleep -Seconds 2

# -------------------------------------------------------------------------------------------------------------------------------

# Connect to Exchange Online
Write-host "Connecting to Exchange..."
try {
    Connect-ExchangeOnline
    Clear-Host
	Write-Host "Welcome to Employee Termination (v3.5)"
    Write-host "`nConnected to MS Graph"
    Write-host "Connected to Exchange"
} catch {
    Write-host "Failed to connect to Exchange Online. Please relaunch the script and try again." -ForegroundColor Red
}
Start-Sleep -Seconds 2

# -------------------------------------------------------------------------------------------------------------------------------

# Connect to Azure AD
Write-Host "Connecting to Azure AD..."
try {
    Connect-AzureAD
    Clear-Host
	Write-Host "Welcome to Employee Termination (v3.5)"
    Write-host "`nConnected to MS Graph"
    Write-host "Connected to Exchange"
    Write-host "Connected to Azure AD"
} catch {
    Write-host "Failed to connect to Azure AD. Please relaunch the script and try again." -ForegroundColor Red
}

Start-Sleep -Seconds 2

# -------------------------------------------------------------------------------------------------------------------------------

DO{
    # SPECIFY THE USER YOU WANT TO REMOVE FROM ALL GROUPS
	
	$User = Read-Host "`nEnter the username of the user you want to terminate (Ex. John Doe, UN = jdoe)"
    $UserEmail = $User + "@walkerproducts.com"
    $UserEmailPrimary = $User + "@walkerproducts.com"
    $UserEmailSecondary = $User + "@walkerproducts.onmicrosoft.com"
    $UserEmails = @($UserEmailPrimary, $UserEmailSecondary)
    Start-Sleep -Seconds 2

# -------------------------------------------------------------------------------------------------------------------------------

    # START LOGGING HERE

    # Define the output log file path
    $outputFilePath = "**Fileserver Location**\Employee Termination Export ($User).txt"

    # Log messages to the file
    function Log-Message {
        param (
            [string]$Message
        )
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        "$timestamp - $Message" | Out-File -FilePath $outputFilePath -Append
    }

    # Start logging
    Log-Message "Script execution started."

    Start-Sleep -Seconds 3

    # -------------------------------------------------------------------------------------------------------------------------------

    # ALL ACTIVE DIRECTORY CHANGES HAPPEN HERE

    # Check if the user exists in AD

    try {
        $ADUser = Get-ADUser -Identity $User -Properties Enabled -ErrorAction Stop
    
        if (-not $ADUser) {
            Write-Host "`nUser '$User' not found in Active Directory." -ForegroundColor Red  
            Log-Message "User '$User' not found in Active Directory."
        }else {
       
            # DISABLE USER'S AD ACCOUNT
            Write-Host "`nChecking the status of $User's AD account..."
            Start-Sleep -Seconds 2
        
            # Check if the account is already disabled
            if (-not $ADUser.Enabled) {
                Write-Host "$User is already disabled." -ForegroundColor Yellow
	            Log-Message "$User is already disabled in AD."
            } else {
                # Disable the account if it is not already disabled
                Disable-ADAccount -Identity $User -ErrorAction Stop
                Write-Host "The account for '$User' has been disabled." -ForegroundColor Green
	            Log-Message "The AD account for '$User' has been disabled."
            }
            Start-Sleep -Seconds 2

        # -------------------------------------------------------------------------------------------------------------------------------
        
            # MOVE THE USER TO THE 'PENDING DELETION' OU IN AD

            Write-Host "`nMoving $User to Pending Deletion OU in AD..."
            Start-Sleep -Seconds 2
    
            $PendingDeletionOU = "**AD OU LOCATION**" 

            try {    
                # Move the user to the "Pending Deletion" OU
                Move-ADObject -Identity $ADUser.DistinguishedName -TargetPath $PendingDeletionOU -ErrorAction Stop

                $CurrentDate = Get-Date -Format "MM-dd-yyyy"
                Set-ADUser -Identity $ADUser.SamAccountName -Description "Account disabled on $CurrentDate" -ErrorAction Stop
                Write-Host "$User has been moved to the 'Pending Deletion' OU and description has been updated." -ForegroundColor Green
                Log-Message "$User has been moved to the 'Pending Deletion' OU and description has been updated."

            } catch {
                Write-Host "Error moving $User to Pending Deletion OU: $_" -ForegroundColor Red
	            Log-Message "Error moving $User to Pending Deletion OU: $_"
            }
            Start-Sleep -Seconds 2

        # -------------------------------------------------------------------------------------------------------------------------------
        
            # REMOVE USER'S ADDRESS INFORMATION FROM AD

            try{
                Write-Host "`nRemoving $User's Address Information from AD..."
                Set-ADUser -Identity $User -Clear st,l,streetAddress,postalCode,postOfficeBox,c -ErrorAction Stop
                Write-Host "Address Information is now cleared." -ForegroundColor Green
	            Log-Message "AD Address Information is now cleared."

            } catch {
                Write-Host "Error removing address information from $User." -ForegroundColor Red
	            Log-Message "Error removing address information from $User."
            }
            Start-Sleep -Seconds 2

        # -------------------------------------------------------------------------------------------------------------------------------

            # REMOVE USER'S JOB TITLE, DEPARTMENT AND MANAGER FROM AD

            try{
                Write-Host "`nRemoving $User's Job Title, Department and Manager attributes from AD..."
                Set-ADUser -Identity $User -Clear Title,Department,manager -ErrorAction Stop
                Write-Host "Job Title, Department and Manager attributes are now cleared." -ForegroundColor Green
	            Log-Message "Job Title, Department and Manager AD attributes are now cleared."
        
            } catch {
                Write-Host "Error clearing Job Title, Department and Manager AD attributes from $User." -ForegroundColor Red
	            Log-Message "Error clearing Job Title, Department and Manager AD attributes from $User." 
            }
        
            Start-Sleep -Seconds 2

        # -------------------------------------------------------------------------------------------------------------------------------

            # RETRIEVE AND LIST THE DIRECT REPORTS

            Write-Host "`nSearching to see if $User has any direct reports..."

            Start-Sleep -Seconds 2

            try{

                $UserDN = $ADUser.DistinguishedName

                $DirectReports = Get-ADUser -Filter "Manager -eq '$UserDN'" -Properties DisplayName |
                    Select-Object -ExpandProperty DisplayName

                # Output the direct reports
                if ($DirectReports) {
                    Write-Host "`nThis is the list of $User's direct reports:"
                    Log-Message "This is the list of $User's direct reports:"

                    $DirectReports | ForEach-Object { Write-Host $_ -ForegroundColor Yellow
                                                  Log-Message $_}

                    Start-Sleep -Seconds 2

                    #Get list of direct reports with $User as their manager
                    $directReports = Get-ADUser -Filter "Manager -eq '$userDN'" -Properties Manager

                    # Loop through each direct report and clear the Manager attribute
                    Write-Host "`nRemoving $User's direct reports..."

                    Start-Sleep -Seconds 2
            
                    try{
                        foreach ($report in $directReports) {
                            Set-ADUser -Identity $report.DistinguishedName -Clear Manager
                            Write-Host "Removed Manager attribute for: $($report.Name)" -ForegroundColor Green
                            Log-Message "Removed Manager attribute for: $($report.Name)"
                        }
                    } catch {
                        Write-Host "Unable to remove manager from $DirectReports" -ForegroundColor Red
                        Log-Message "Unable to remove manager from $DirectReports"
                    }
                
                    Start-Sleep -Seconds 2
                 
                } else {
                    Write-Host "No direct reports found for $User."  -ForegroundColor Yellow
                    Log-Message "No direct reports found for $User."

                    Start-Sleep -Seconds 2
                }
            } catch {
                Write-Host "Error gettng $User's direct reports, please relaunch script or manually remove reports from AD..." -ForegroundColor Red
                Log-Message "Error gettng $User's direct reports."
            }

        # -------------------------------------------------------------------------------------------------------------------------------
            
            # REMOVE USER FROM ALL ACTIVE DIRECTORY GROUPS

            Write-Host "`nChecking if $User is a member of any Active Directory Groups..."
            Start-Sleep -Seconds 2

            try {
                # Get the user's group memberships
                $userGroups = (Get-ADUser -Identity $User -Properties MemberOf).MemberOf

                # Check if the user is a member of any groups
                if ($userGroups.Count -eq 0) {
                    Write-Host "$User is not a member of any Active Directory Groups." -ForegroundColor Yellow
		            Log-Message "$User is not a member of any Active Directory Groups."
                } else {
                    # Loop through each group and remove the user
                    foreach ($groupDN in $userGroups) {
                        $group = Get-ADGroup $groupDN -ErrorAction Stop
                        Remove-ADGroupMember -Identity $group -Members $UserDN -Confirm:$false -ErrorAction Stop
                        Write-Host "Removed $User from Active Directory Group: $($group.Name)" -ForegroundColor Green
		                Log-Message "Removed $User from Active Directory Group: $($group.Name)"
                    }
                }
            } catch {
                Write-Host "Error removing $User from Active Directory Groups: $_" -ForegroundColor Red
	            Log-Message "Error removing $User from Active Directory Groups: $_"
            }

        }

    # -------------------------------------------------------------------------------------------------------------------------------

    } catch {
        Write-Host "$User is not found in Acitve Directory." -ForegroundColor Red
        Log-Message "$User is not found in Acitve Directory."
        Write-Host "Skipping all steps involving Active Directory." -ForegroundColor Red
        Log-Message "Skipping all steps involving Active Directory."
    }

# -------------------------------------------------------------------------------------------------------------------------------

    # ALL M365 CHANGES HAPPEN HERE

    # CHECK IF USER HAS A M365 ACCOUNT

    Write-Host "`nChecking if $User has a M365 account..."
	Start-Sleep -Seconds 2

    # Find the exact user using Get-AzureADUser to avoid ambiguity
    $UserObject = Get-AzureADUser -Filter "UserPrincipalName eq '$UserEmailPrimary' or UserPrincipalName eq '$UserEmailSecondary'"

    if ($UserObject -eq $null) {
        Write-Host "No M365 account found for $User" -ForegroundColor Red
        Log-Message "No M365 account found for $User"
        Write-Host "Therefore, $User is not assigned any M365 licenses." -ForegroundColor Red
        Write-Host "Therefore, $User is not a member of any any M365 groups." -ForegroundColor Red
	    Write-Host "Therefore, $User is not a member of any Distribution Lists." -ForegroundColor Red
	    Write-Host "Therefore, $User is not a deligate on any Shared Mailboxes." -ForegroundColor Red
	    Start-Sleep -Seconds 2

	} elseif ($UserObject.Count -gt 1) {
        Write-Host "Multiple users found with the given email addresses. Please specify a unique identifier." -ForegroundColor Red
        Log-Message "Multiple users found with the given email addresses. Please specify a unique identifier."
		Start-Sleep -Seconds 2
    } else {
        $UserObjectID = $UserObject.ObjectId
        Write-Host "Found a M365 account for $($UserObject.DisplayName)" -ForegroundColor Green
		Start-Sleep -Seconds 1

    # -------------------------------------------------------------------------------------------------------------------------------

        # REMOVE USER FROM ALL MICROSOFT 365 GROUPS (UNIFIED GROUPS)

		Write-Host "`nChecking if $User is a member of any M365 groups..."

		Get-UnifiedGroup -ResultSize Unlimited | ForEach-Object {
            $GroupMembers = Get-UnifiedGroupLinks -Identity $_.Alias -LinkType Members

            # Check if the user is in the group by either primary or secondary email
            if ($GroupMembers | Where-Object { $UserEmails -contains $_.PrimarySmtpAddress }) {
                Remove-UnifiedGroupLinks -Identity $_.Alias -LinkType Members -Links $UserEmails -Confirm:$false
                Write-Host "Removed $User from Microsoft 365 Group: $($_.DisplayName)" -ForegroundColor Green
                Log-Message "Removed $User from Microsoft 365 Group: $($_.DisplayName)"
			    }
		}
		Start-Sleep -Seconds 2

    # -------------------------------------------------------------------------------------------------------------------------------
        
        # REMOVE ALL M365 LICENSES FROM THE USER

        Write-Host "`nChecking if $User has any M365 licenses assigned to them..."
        Start-Sleep -Seconds 2

        # Get the available licenses for the tenant (both SkuId and Display Name)
        $licenses = Get-MgSubscribedSku | Select SkuId, SkuPartNumber

        # Get the user's currently assigned licenses
        $userLicenses = (Get-MgUserLicenseDetail -UserId $UserEmail).SkuId

        # Loop through the licenses and remove them only if the user has them
        foreach ($license in $licenses) {
            if ($userLicenses -contains $license.SkuId) {
                Write-Host "Removed license: $($license.SkuPartNumber) from $User" -ForegroundColor Green
                Log-Message "Removed license: $($license.SkuPartNumber) from $User"
                Set-MgUserLicense -UserId $UserEmail -RemoveLicenses @($license.SkuId) -AddLicenses @{}
            } else {

            }
        }
        Start-Sleep -Seconds 2

	# -------------------------------------------------------------------------------------------------------------------------------

		 # REMOVE USER FROM ALL DISTRIBUTION LISTS
		 
		Write-Host "`nChecking if $User is a member of any Distribution Lists..."

		$distributionGroups = Get-DistributionGroup -ResultSize Unlimited

		foreach ($group in $distributionGroups) {
			# Get members of the current distribution group
			$members = Get-DistributionGroupMember -Identity $group.Identity -ResultSize Unlimited

			# Filter members based on the keyword
			$membersToRemove = $members | Where-Object {
				$_.PrimarySmtpAddress -like "*$User*" -or $_.DisplayName -like "*$User*"
			}

			foreach ($member in $membersToRemove) {
				# Remove the member from the distribution group
				Remove-DistributionGroupMember -Identity $group.Identity -Member $member.PrimarySmtpAddress -Confirm:$false
				Write-Host "Removed $User from distribution group: $($group.DisplayName)" -ForegroundColor Green
                		Log-Message "Removed $User from distribution group: $($group.DisplayName)"
			}

		}
		Start-Sleep -Seconds 2
		
    # -------------------------------------------------------------------------------------------------------------------------------
        # REMOVE USER FROM ALL SHARED MAILBOXES
		
		Write-Host "`nChecking if $User is a member of any Shared Mailboxes..."

		# Get all shared mailboxes
		$sharedMailboxes = Get-Mailbox -ResultSize Unlimited -RecipientTypeDetails SharedMailbox

		# Loop through each shared mailbox and remove the user
		foreach ($mailbox in $sharedMailboxes) {
    
			# Get the current 'Full Access' permissions for the shared mailbox
			$permissions = Get-MailboxPermission -Identity $mailbox.Alias | Where-Object { $_.User -like $UserEmail }
            
			foreach ($permission in $permissions) {
				# Remove the user from the shared mailbox
				if ($permission.AccessRights -contains "FullAccess") {
					Remove-MailboxPermission -Identity $mailbox.Alias -User $UserEmail -AccessRights FullAccess -Confirm:$false
					Write-Host "$User has been removed from 'Full Access' permission on $($mailbox.Alias)'s shared mailbox" -ForegroundColor Green
                     			Log-Message "$User has been removed from 'Full Access' permission on $($mailbox.Alias)'s shared mailbox"
				}
			}
        }
            $sharedMailboxes = Get-Mailbox -RecipientTypeDetails SharedMailbox | 
            ForEach-Object {
                $mailbox = $_
                $sendAsPermissions = Get-RecipientPermission -Identity $mailbox.Identity | Where-Object {
                    $_.Trustee -like $UserEmail -and $_.AccessRights -contains "SendAs"
                }
                if ($sendAsPermissions) {
            
                    # Remove 'Send As' permission
                    Remove-RecipientPermission -Identity $mailbox.Identity -Trustee $UserEmail -AccessRights SendAs -Confirm:$false
                    Write-Host "$User has been removed from 'Send As' permission on $($mailbox.Alias)'s shared mailbox" -ForegroundColor Green
                    Log-Message "$User has been removed from 'Send As' permission on $($mailbox.Alias)'s shared mailbox"
                }
            }
		Start-Sleep -Seconds 2
    }

# -------------------------------------------------------------------------------------------------------------------------------

	$userChoice = Read-Host "`nIs there another user you would like to terminate? (y/n)"
    Clear-Host

# -------------------------------------------------------------------------------------------------------------------------------

} WHILE ($userChoice -eq "y")
Start-Sleep -Seconds 2

Write-Host "Termination Completed"
Log-Message "Termination Completed"

Start-Sleep -Seconds 2

Write-Host "`nTo view the output logs, you can find them here: "
Write-Host "**Fileserver Location**\Employee Termination Export ($User).txt"

Start-Sleep -Seconds 3

Write-Host "`nClosing session..."

Disconnect-ExchangeOnline -Confirm:$false

Start-Sleep -Seconds 10

return
