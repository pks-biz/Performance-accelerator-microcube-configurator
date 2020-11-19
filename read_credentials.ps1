<#
	Author: Praveen Sam - Biztory
	Purpose: Create credentials for TSM access using Windows Data Protection API
	Change the file path to match your machine
	NOTE: It is important to have this script within the "Users" folder for security purposes.
#>

$file_path = "C:\Users\prave\cred.sec"

$username = "praveen.sam@biztory.be"

$encrypted_cred = Get-Content $file_path | ConvertTo-SecureString

$cred = New-Object System.management.Automation.PsCredential($username, $encrypted_cred)

<#
	In any subsequent tsm command you can use the following as the password
    $cred.GetNetworkCredential().Password
#>

$pass = $cred.GetNetworkCredential().Password

return $cred

