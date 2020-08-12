@echo Prepping VM for distribution
vssadmin delete shadows /All /Quiet
del c:\Windows\SoftwareDistribution\Download\*.* /f /s /q
del %windir%\$NT* /f /s /q /a:h
del c:\Windows\Prefetch\*.* /f /s /q
c:\windows\system32\cleanmgr /sagerun:1
wevtutil el 1>cleaneventlog.txt
for /f %%x in (cleaneventlog.txt) do wevtutil cl %%x
del cleaneventlog.txt
del %APPDATA%\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt
del c:\tools\hashcat-4.1.0\hashcat.potfile
ipconfig /flushdns
reg delete HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU /f
reg delete HKCU\Software\Microsoft\Windows\CurrentVersion\Applets\Regedit /v LastKey /f
defrag c: /U /V /X
sdelete64 /z c: