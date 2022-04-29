
##############################################
### CLI Dialog
##############################################

# $ErrorActionPreference= 'silentlycontinue'
# Get-ItemPropertyValue -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\System -Name DontDisplayNetworkSelectionUI
# Get-ItemPropertyValue -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\System -Name AllowDomainPINLogon -ErrorAction 'silentlycontinue'

# Get-ItemPropertyValue -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\System -Name DontDisplayNetworkSelectionUI -ErrorAction 'silentlycontinue'
#Get-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\System -Name DontDisplayNetworkSelectionUI -ErrorAction "SilentlyContinue"
# Get-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\System -Name DontDisplayNetworkSelectionUI 2>$null

# $files = ".\data.csv",".\test.csv",".\bigmoney.csv"
# $files = ".\data.csv",".\test.csv"

$files = @()
$files += ,".\sec.csv"

$runSuccessful = "true"


### Otazka 1
echo "Prejete si pridata data? - Zvolte cislo"
echo "ano - 1"
echo "ne - 2"

$prompt = Read-Host "Vlozte cislo"

while (!($prompt -eq "1" -Or $prompt -eq "2")) {

	echo "Nespravny vstup!"
	
	echo "Prejete si pridata data? - Zvolte cislo"
	echo "ano - 1"
	echo "ne - 2"

	$prompt = Read-Host "Vlozte cislo"
}

if ($prompt -eq "1") {
	$files += ,".\data.csv"
}


### Otazka 2
echo "Prejete si pridat bigmoney? - Zvolte cislo"
echo "ano - 1"
echo "ne - 2"

$prompt = Read-Host "Vlozte cislo"

while (!($prompt -eq "1" -Or $prompt -eq "2")) {

	echo "Nespravny vstup!"
	
	echo "Prejete si pridat bigmoney? - Zvolte cislo"
	echo "ano - 1"
	echo "ne - 2"

	$prompt = Read-Host "Vlozte cislo"
}

if ($prompt -eq "1") {
	$files += ,".\bigmoney.csv"
}


# ### Otazka 3
# echo "Prejete si zabezpecit PowerShell? - Zvolte cislo"
# echo "ano - 1"
# echo "ne - 2"

# $prompt = Read-Host "Vlozte cislo"

# while (!($prompt -eq "1" -Or $prompt -eq "2")) {

	# echo "Nespravny vstup!"
	
	# echo "Prejete si zabezpecit PowerShell? - Zvolte cislo"
	# echo "ano - 1"
	# echo "ne - 2"

	# $prompt = Read-Host "Vlozte cislo"
# }

# if ($prompt -eq "1") {
	# $files += ".\bigmoney.csv"
# } else {
	# $files += ".\smallmoney.csv"
# }


# ### Otazka 4
# echo "Prejete si zabezpecit PowerShell? - Zvolte cislo"
# echo "ano - 1"
# echo "ne - 2"

# $prompt = Read-Host "Vlozte cislo"

# while (!($prompt -eq "1" -Or $prompt -eq "2")) {

	# echo "Nespravny vstup!"
	
	# echo "Prejete si zabezpecit PowerShell? - Zvolte cislo"
	# echo "ano - 1"
	# echo "ne - 2"

	# $prompt = Read-Host "Vlozte cislo"
# }

# if ($prompt -eq "1") {
	# $files += ".\bigmoney.csv"
# } else {
	# $files += ".\smallmoney.csv"
# }




##############################################
### Nastaveni regsitry klicu
##############################################

### logfile
$guid = New-Guid
$date = Get-Date -Format "dd-MM-yy"

$logfilename = "log-$date-$guid.txt"
$logfullpath = "./logs/log-$date-$guid.txt"

# ForEach ($file in $files) {
$files | ForEach-Object {
	# $data = Import-Csv -Path .\data.csv
	$data = Import-Csv -Path "$_"

	echo "#####################################"
	echo ">  Aplikuji klíče registrů ze souboru $_, muze to chvili trvat..."
	echo "#####################################"
	echo "..."

	$data | ForEach-Object {
		
		$RegPath = "$($_.hive):\$($_.path)"
		$ValueName = "$($_.value)"
		$ValueData = "$($_.data)"
		$ValueType = "$($_.type)"

		#TODO pridat check jestli ma spravny registry type??

		if (Test-Path "$RegPath") {
			$LastKey = Get-Item -LiteralPath $RegPath
			
			$CurrentValueData = $LastKey.GetValue($ValueName)
			
			if ($CurrentValueData -ne $null) {
				"exists"
				if ($CurrentValueData -ne $ValueData) {
					"wrong value"
					echo "Nastavuji klic $RegPath $ValueName typu $ValueType na hodnotu $ValueData" 1>>"$logfullpath"
					
					Set-ItemProperty -Path "$RegPath" -Name "$ValueName" -Value "$ValueData" 2>&1 1>>"$logfullpath"
					if (!$?) {
						$runSuccessful = "false"
					}
				}
			} else {
				"does not exist - no value"
				echo "Vytvarim klic $RegPath $ValueName typu $ValueType s hodnotou $ValueData" 1>>"$logfullpath"
				
				New-ItemProperty -Path "$RegPath" -Name "$ValueName" -PropertyType "$ValueType" -Value "$ValueData" 2>&1 1>>"$logfullpath"
				if (!$?) {
					$runSuccessful = "false"
				}
			}
		} else {
			"Path does not exist"
			echo "Vytvarim cestu $RegPath" 1>>"$logfullpath"
			echo "Vytvarim klic $RegPath $ValueName typu $ValueType s hodnotou $ValueData" 1>>"$logfullpath"
			
			New-Item -Path "$RegPath" -Force 2>&1 1>>"$logfullpath"
			if (!$?) {
				$runSuccessful = "false"
			}
			New-ItemProperty -Path "$RegPath" -Name "$ValueName" -PropertyType "$ValueType" -Value "$ValueData" 2>&1 1>>"$logfullpath"
			if (!$?) {
				$runSuccessful = "false"
			}
		}
	}
}

##############################################
### Aplikace audit policy
##############################################

echo "#####################################"
echo ">  Aplikuji audit policy"
echo "#####################################"
echo "..."

# if ($?) {
	# "Command successful"
# } else {
	# "Command failed"
# }

##############################################
### Aplikace security policy
##############################################

echo "#####################################"
echo ">  Aplikuji bezpecnostni nastaveni"
echo "#####################################"
echo "..."

if ($runSuccessful -eq "true") {
	
	echo "#####################################"
	echo ">  Skript dokoncen, dekujeme za pouziti, zaznam o behu najdete v souboru $logfilename"
} else {
	echo "run failed"
}