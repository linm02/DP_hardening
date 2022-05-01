
#Set-ItemProperty -Path "$RegPath" -Name "$ValueName" -Value "$ValueData" 2>&1 1>>"$logfullpath"

# vypise services
# Get-Service



# TODO export !!!!!
$guid = New-Guid
$date = Get-Date -Format "dd-MM-yy"

$services = Import-Csv -Path ".\data\services\services_final.csv"

$services | ForEach-Object {
		
	$ServiceName = "$($_.Name)"
	$Status = "$($_.Status)"
	$StartupType = "$($_.StartType)"
	
	Get-Service "$ServiceName" 2>&1 1> $null
	$Exists = $?
	
	if ($Exists) { 	
		"zalohuji"
		Get-Service "$ServiceName" | select name,Status,StartType | Export-Csv -Path ".\backups\services\services_backup-$date-$guid.csv" -NoTypeInformation -Append
		
		#Set-Service -Name "$ServiceName" -Status "$Status" -StartupType "$StartupType"
		# Set-Service -Name "$ServiceName" -Status "$Status" -StartupType "$StartupType"
		
		if ("$StartupType" -eq "disabled") {
			Get-Service -Name "$ServiceName" | Stop-Service
			"zastavuji"
		} else {
			Set-Service -Name "$ServiceName" -Status "$Status" -StartupType "$StartupType"
			"zapinam"
		}
	}
}


# Set-Service -Name "$ServiceName " -Status "$Status" -StartupType "$StartupType"

#TODO doplnit dalsi services a pridat je do finalniho skriptu

# HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\Transcription	EnableInvocationHeader
