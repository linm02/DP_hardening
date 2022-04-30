
#### deletion MVP

#Počítač\HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\PowerShell\Transcription
#EnableInvocationHeader
Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\Transcription" -Name "EnableInvocationHeader"

#New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "DisableLGPOProcessing" -PropertyType "DWord" -Value "1"