

$data = Import-Csv -Path .\data.csv


$data | ForEach-Object {
	$_.hive
	$_.path
	$_.value
	$_.type
	$_.data
	
	
	$RegPath = "$($_.hive):\$($_.path)"
	$RegPath
}
