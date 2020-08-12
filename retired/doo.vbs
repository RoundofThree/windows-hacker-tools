' doo - A *very* stupid VMware fingerprint script
' tk, 2003 [www.trapkit.de]

Set WSHShell = WScript.CreateObject("WScript.Shell")

WScript.Echo "If you encounter the string 'VMware' in one of the next MSG boxes, you are probably inside VMware."
WScript.Echo WSHShell.RegRead("HKEY_LOCAL_MACHINE\HARDWARE\DEVICEMAP\Scsi\Scsi Port 0\Scsi Bus 0\Target Id 0\Logical Unit Id 0\Identifier")
WScript.Echo WSHShell.RegREAD("HKEY_LOCAL_MACHINE\HARDWARE\DEVICEMAP\Scsi\Scsi Port 1\Scsi Bus 0\Target Id 0\Logical Unit Id 0\Identifier")
WScript.Echo WSHShell.RegREAD("HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\Class\{4D36E968-E325-11CE-BFC1-08002BE10318}\0000\DriverDesc")
WScript.Echo WSHShell.RegREAD("HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\Class\{4D36E968-E325-11CE-BFC1-08002BE10318}\0000\ProviderName")
