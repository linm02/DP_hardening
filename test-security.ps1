





$SecDataFile = "sec-data.inf"
$SecExportFile = "sec-export92.inf"

mkdir "blabla"
cd "blabla"

secedit /export /cfg "$SecExportFile"

mv ".\$SecExportFile" "..\backups\security\$SecExportFile"

cp "..\data\sec\$SecDataFile" .

echo y | C:\Windows\System32\secedit.exe /configure /db .\secedit.sdb /cfg ".\$SecDataFile" /overwrite

cd ..
rm -r "blabla"




# cp .\sec-export3.inf C:\Windows\System32


# cd C:\Windows\System32

# echo y | secedit /configure /db secedit.sdb /cfg sec-export3.inf /overwrite

# rm .\secedit.jfm
# rm .\secedit.sdb

# cd C:\git\DP_hardening