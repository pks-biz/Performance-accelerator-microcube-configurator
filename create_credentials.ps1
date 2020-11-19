<#
	Author: Praveen Sam - Biztory
	Purpose: Create credentials for TSM access using Windows Data Protection API
	Change the file path to match your machine
	NOTE: It is important to have this script within the "Users" folder for security purposes.
#>

$file_path = "C:\Users\prave\cred.sec"

$cred = Get-Credential

$cred.Password | ConvertFrom-SecureString | Set-Content $file_path