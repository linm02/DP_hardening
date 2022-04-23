
#(Get-WinUserLanguageList)[1].LocalizedName

#auditpol /list /subcategory:* /r

/Windows/System32/auditpol.exe /set /subcategory:"{0CCE921D-69AE-11D9-BED3-505054503030}" /success:disable /failure:disable