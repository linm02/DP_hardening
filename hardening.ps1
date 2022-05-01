
#============================================
# Functions
#============================================

Function LogStd {
	Param ($message)
	echo "$message" 1>>"$logfullpath"
}

Function Print-Options {
	echo "ANO - 1"
	echo "NE - 2"
}

Function Print-PromptText {
	Param ($question)
	echo "Nespravny vstup!"
	echo "$question"
	Print-Options
}



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
# $files += ,".\sec.csv"
$files += ,".\multistring.csv"

$runSuccessful = $true


### Otazka 1
echo "Prejete si pridata data? - Zvolte cislo"
Print-Options

$prompt = Read-Host "Vlozte cislo"

while (!($prompt -eq "1" -Or $prompt -eq "2")) {
	Print-PromptText "Prejete si pridata data? - Zvolte cislo"
	$prompt = Read-Host "Vlozte cislo"
}

if ($prompt -eq "1") {
	$files += ,".\data.csv"
}


### Otazka 2
echo "Prejete si pridat bigmoney? - Zvolte cislo"
Print-Options

$prompt = Read-Host "Vlozte cislo"

while (!($prompt -eq "1" -Or $prompt -eq "2")) {
	Print-PromptText  "Prejete si pridat bigmoney? - Zvolte cislo"
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
	echo ">  Aplikuji klice registru ze souboru $_, muze to chvili trvat..."
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
					LogStd "Nastavuji klic $RegPath $ValueName typu $ValueType na hodnotu $ValueData"
					
					Set-ItemProperty -Path "$RegPath" -Name "$ValueName" -Value "$ValueData" 2>&1 1>>"$logfullpath"
					$runSuccessful = $?
				}
			} else {
				"does not exist - no value"
				LogStd "Vytvarim klic $RegPath $ValueName typu $ValueType s hodnotou $ValueData"
				
				New-ItemProperty -Path "$RegPath" -Name "$ValueName" -PropertyType "$ValueType" -Value "$ValueData" 2>&1 1>>"$logfullpath"
				$runSuccessful = $?
			}
		} else {
			"Path does not exist"
			LogStd "Vytvarim cestu $RegPath"
			LogStd "Vytvarim klic $RegPath $ValueName typu $ValueType s hodnotou $ValueData"
			
			New-Item -Path "$RegPath" -Force 2>&1 1>>"$logfullpath"
			$runSuccessful = $?
			New-ItemProperty -Path "$RegPath" -Name "$ValueName" -PropertyType "$ValueType" -Value "$ValueData" 2>&1 1>>"$logfullpath"
			$runSuccessful = $?
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

if ($runSuccessful) {
	echo "#####################################"
	echo ">  Skript uspesne dokoncen, dekujeme za pouziti, zaznam o behu najdete v souboru .\logs\$logfilename"
} else {
	echo "#####################################"
	echo ">  Pri behu skriptu se vyskytly chyby, detaily najdete v souboru .\logs\$logfilename"
}


# Function Set-RunStatus {
	# Param ($LastCmdResult)
	# if (!$LastCmdResult) {
		# $runSuccessful = $false
	# }
# }

