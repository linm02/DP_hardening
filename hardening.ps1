
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
	Param ($questions)
	echo "!!! Nespravny vstup !!!"
	echo ""
	$questions | ForEach-Object {
		echo "$_"
	}
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

$q1PromptA = "Pouzivate aktivne PowerShell ke tvorbe skriptu nebo pouzivat jine vyvojarske nastroje? - Zvolte cislo"
$q1PromptB = "Pokud zvolite ano, bude nastavena volnejsi politika pro spousteni skriptu"
$q2PromptA = "Je toto zarizeni samostatnou jednoucelovou pracovni stanici? - Zvolte cislo"
$q2PromptB = "Pokud zvolite ano, bude zakazan mikrofon, kamera a vsechna prenosna zarizeni"



$path = pwd
$workdir = $path.Path

$RegistryAddPath = ".\data\registry\add\"
$SecAddPath = ".\data\registry\add\"
$AuditAddPath = ".\data\audit\"
$RegistryAddPath = ".\data\registry\add\"
$RegistryDeletePath = ".\data\registry\delete\"

$files = @()
$files += ,"sec.csv"
# $files += ,"multistring.csv"

$runSuccessful = $true


### Otazka 1
echo "$q1PromptA"
echo "$q1PromptB"
Print-Options

$prompt = Read-Host "Vlozte cislo"

while (!($prompt -eq "1" -Or $prompt -eq "2")) {
	Print-PromptText "$q1PromptA","$q1PromptB"
	$prompt = Read-Host "Vlozte cislo"
}

if ($prompt -eq "1") {
	$files += ,"data.csv"
}


### Otazka 2
echo "$q2PromptA"
echo "$q2PromptB"
Print-Options

$prompt = Read-Host "Vlozte cislo"

while (!($prompt -eq "1" -Or $prompt -eq "2")) {
	Print-PromptText "$q2PromptA","$q2PromptB"
	$prompt = Read-Host "Vlozte cislo"
}

if ($prompt -eq "1") {
	$files += ,"bigmoney.csv"
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


### logfile
$guid = New-Guid
$date = Get-Date -Format "dd-MM-yy"

$logfilename = "log-$date-$guid.txt"
$logfullpath = "$workdir/logs/log-$date-$guid.txt"


##############################################
### Smazani regsitry klicu
##############################################

$deleteFile = "test.csv"

$data = Import-Csv -Path "$RegistryDeletePath$deleteFile"

	echo "#####################################"
	echo ">  Mazu klice registru ze souboru $_"
	echo "#####################################"
	echo "..."

$data | ForEach-Object {
	
	$RegPath = "$($_.hive):\$($_.path)"
	$ValueName = "$($_.value)"

	if (Test-Path "$RegPath") {
		$LastKey = Get-Item -LiteralPath $RegPath
		
		$CurrentValueData = $LastKey.GetValue($ValueName)
		
		if ($CurrentValueData -ne $null) {
			"exists"
			LogStd "Mazu klic $RegPath $ValueName"
			Remove-ItemProperty -Path "$RegPath" -Name "$ValueName" 2>&1 1>>"$logfullpath"
			$runSuccessful = $?
		} else {
			LogStd "Klic $RegPath $ValueName neexistuje"
			"Klic $RegPath $ValueName uz neexistuje"
		}
	}
}

##############################################
### Nastaveni regsitry klicu
##############################################


# ForEach ($file in $files) {
$files | ForEach-Object {
	# $data = Import-Csv -Path .\data.csv
	$data = Import-Csv -Path "$RegistryAddPath$_"

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

$auditFile = "test.csv"
$AuditBackupFilename = "backup-$date-$guid.txt"

$data = Import-Csv -Path "$AuditAddPath$auditFile"

	echo "#####################################"
	echo ">  Aplikuji audit policy"
	echo "#####################################"
	echo "..."

 auditpol /get /category:* /r > ".\backups\audit\$AuditBackupFilename"
 echo "> Vytvarim zalohu aktualnich konfiguraci auditu do: .\backups\audit\$AuditBackupFilename"
 LogStd "Vytvarim zalohu aktualnich konfiguraci auditu do: .\backups\audit\$AuditBackupFilename"

$data | ForEach-Object {
	
	$Subcategory = "$($_.subcategory)"
	$Failure = "$($_.failure)"
	$Success = "$($_.success)"

	auditpol /set /subcategory:"$Subcategory" /success:"$Success" /failure:"$Failure" 2>&1 1>>"$logfullpath"
	$runSuccessful = $?

	LogStd "Nastavuji audit pro subkategorii: $Subcategory"
}


##############################################
### Nastaveni systemovych sluzeb
##############################################

echo "#####################################"
echo ">  Nastavuji systemove sluzby"
echo "#####################################"
echo "..."

$ServicesBackupFilename = ".\backups\services\services_backup-$date-$guid.csv"

$services = Import-Csv -Path ".\data\services\services.csv"

$services | ForEach-Object {
		
	$ServiceName = "$($_.Name)"
	$Status = "$($_.Status)"
	$StartupType = "$($_.StartType)"
	
	LogStd "Vytvarim zalohu stavu sluzby $ServiceName do: $ServicesBackupFilename"
	echo "> Vytvarim zalohu stavu sluzby $ServiceName do: $ServicesBackupFilename"
	Get-Service "$ServiceName" | select name,Status,StartType | Export-Csv -Path "$ServicesBackupFilename" -NoTypeInformation -Append
	$runSuccessful = $?
	
	LogStd "Nastavuji startup typ sluzby $ServiceName na $StartupType"
	Set-Service -Name "$ServiceName" -Status "$Status" -StartupType "$StartupType"
	$runSuccessful = $?
}


##############################################
### Aplikace security policy
##############################################


echo "#####################################"
echo ">  Aplikuji bezpecnostni nastaveni"
echo "#####################################"
echo "..."

$SecDataFile = "sec-data.inf"
$SecExportFile = "sec-backup-$date-$guid.inf"
$TmpDir = "tmp-$date-$guid"

mkdir "$TmpDir" 2>&1 1>>"$logfullpath"
cd "$TmpDir" 2>&1 1>>"$logfullpath"

echo "> Vytvarim zalohu security nastaveni do souboru: $SecExportFile"
LogStd "Vytvarim zalohu security nastaveni do souboru: $SecExportFile"

secedit /export /cfg "$SecExportFile" 2>&1 1>>"$logfullpath"
$runSuccessful = $?

mv ".\$SecExportFile" "..\backups\security\$SecExportFile" 2>&1 1>>"$logfullpath"

cp "..\data\sec\$SecDataFile" . 2>&1 1>>"$logfullpath"

echo y | C:\Windows\System32\secedit.exe /configure /db .\secedit.sdb /cfg ".\$SecDataFile" /overwrite 2>&1 1>> "$logfullpath"
$runSuccessful = $?

cd ..
rm -r "$TmpDir"

###################################################
# Zakonceni
###################################################

if ($runSuccessful) {
	echo "#####################################"
	echo ">  Skript uspesne dokoncen, dekujeme za pouziti, zaznam o behu najdete v souboru .\logs\$logfilename"
	echo ">  Pro aplikovani vsech nastaveni by mel byt pocitac nyni restartovan"
	echo "#####################################"
} else {
	echo "#####################################"
	echo ">  Pri behu skriptu se vyskytly chyby, detaily najdete v souboru .\logs\$logfilename"
	echo "#####################################"
}
