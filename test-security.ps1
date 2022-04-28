
echo y | C:\Windows\System32\secedit.exe /configure /db .\secedit.sdb /cfg .\sec-export3.inf /overwrite

rm .\secedit.jfm
rm .\secedit.sdb






# cp .\sec-export3.inf C:\Windows\System32


# cd C:\Windows\System32

# echo y | secedit /configure /db secedit.sdb /cfg sec-export3.inf /overwrite

# rm .\secedit.jfm
# rm .\secedit.sdb

# cd C:\git\DP_hardening