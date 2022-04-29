# $ErrorActionPreference= 'silentlycontinue'
# Get-ItemPropertyValue -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\System -Name DontDisplayNetworkSelectionUI
# Get-ItemPropertyValue -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\System -Name AllowDomainPINLogon -ErrorAction 'silentlycontinue'

# Get-ItemPropertyValue -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\System -Name DontDisplayNetworkSelectionUI -ErrorAction 'silentlycontinue'
#Get-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\System -Name DontDisplayNetworkSelectionUI -ErrorAction "SilentlyContinue"
# Get-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\System -Name DontDisplayNetworkSelectionUI 2>$null

# $files = ".\data.csv",".\test.csv",".\bigmoney.csv"
$files = ".\sec.csv"

# ForEach ($file in $files) {
$files | ForEach-Object {
	# $data = Import-Csv -Path .\data.csv
	$data = Import-Csv -Path "$_"

	$data | ForEach-Object {
		
		$RegPath = "$($_.hive):\$($_.path)"

		# $ValueName = "DontDisplayNetworkSelectionUIs"
		$ValueName = "$($_.value)"

		$ValueData = "$($_.data)"
		$ValueType = "$($_.type)"

		#TODO pridat check jestli ma srpavny registry type??

		if (Test-Path "$RegPath") {
			$LastKey = Get-Item -LiteralPath $RegPath
			
			$CurrentValueData = $LastKey.GetValue($ValueName)
			
			if ($CurrentValueData -ne $null) {
				"exists"
				if ($CurrentValueData -ne $ValueData) {
					"wrong value"
					Set-ItemProperty -Path "$RegPath" -Name "$ValueName" -Value "$ValueData"
				}
			} else {
				"does not exist - no value"
				New-ItemProperty -Path "$RegPath" -Name "$ValueName" -PropertyType "$ValueType" -Value "$ValueData"
			}
		} else {
			"Path does not exist"
			#create the path !!!
			New-Item -Path "$RegPath" -Force
			New-ItemProperty -Path "$RegPath" -Name "$ValueName" -PropertyType "$ValueType" -Value "$ValueData"
		}
	}
}


	

# if ($?) {
	# "Command successful"
# } else {
	# "Command failed"
# }