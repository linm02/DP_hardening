
# $files = ".\data.csv",".\test.csv",".\bigmoney.csv"
$files = ".\data.csv",".\test.csv"


echo "Prejete si zabezpecit PowerShell? - Zvolte cislo"
echo "ano - 1"
echo "ne - 2"

$prompt = Read-Host "Vlozte cislo"

while (!($prompt -eq "1" -Or $prompt -eq "2")) {

	echo "Nespravny vstup!"
	
	echo "Prejete si zabezpecit PowerShell? - Zvolte cislo"
	echo "ano - 1"
	echo "ne - 2"

	$prompt = Read-Host "Vlozte cislo"
}

if ($prompt -eq "1") {
	$files += ".\bigmoney.csv"
} else {
	$files += ".\smallmoney.csv"
}

echo $files