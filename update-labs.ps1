# Update-Lab.ps1
# Created by Mick Douglas (@BetterSafetyNet) 20190324 for SANS SEC504
# Updates by Joshua Wright (@joswr1ght) 20190809

# About this script:
# When run, this will update the labs in the current VM.
# This allows an update of the labs without distributing a new VM

function Check-NetConnection {
    $ProgressPreference = 'SilentlyContinue'
    $OnlineCheckResult = Test-NetConnection 8.8.8.8
    if ($OnlineCheckResult.PingSucceeded -eq $FALSE) {
        
        # Try again using 4.4.4.4
        $OnlineCheckResult = Test-NetConnection 4.4.4.4
        if ($OnlineCheckResult.PingSucceeded -eq $FALSE) {

            # This failed, so try and revert network connection settings back to static
            netsh int ip set address "Ethernet0" static 10.10.0.1 255.255.0.0 0.0.0.0 1
            netsh interface ipv4 show config "Ethernet0"

            Write-Error "It looks like your system isn't connected to the Internet. Please see the lab"
            Write-Error "manual for steps to connect this virtual machine to the network." 
            Write-Error "If you continue to have trouble, please contact an instructor or email " 
            Write-Error "virtual-labs-support@sans.org. Thank you!"
            exit
        }
    }
}

function Check-AdminStatus {
    $IsRunningAsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if ( -not $IsRunningAsAdmin) {
        Write-Host -ForegroundColor red "Please run this script as Administrator. Exit your PowerShell prompt and run again with Administrator privileges."
        exit 1
    }
}


# Check admin status
Check-AdminStatus

# Change to DHCP, obtain IP
Write-Host "Resetting IP Address and Subnet Mask For DHCP"
netsh int ip set address name = "Ethernet0" source = dhcp | Out-Null

Write-Host "Resetting DNS For DHCP"
netsh int ip set dns name = "Ethernet0" source = dhcp | Out-Null

Write-Host "Resetting Windows Internet Name Service (WINS) For DHCP"
netsh int ip set wins name = "Ethernet0" source = dhcp | Out-Null

Start-Sleep 3

# Check network status
Check-NetConnection

Write-Host "Running update.`n"

# Download and run the update script
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-Expression (New-Object Net.Webclient).downloadstring("https://joswr1ght.github.io/update-labs/sec504/update-labs-504.20.1.ps1")

# Restore static IP
Write-Host "`nRestoring static IP for lab use."
netsh int ip set address "Ethernet0" static 10.10.0.1 255.255.0.0 0.0.0.0 1 | Out-Null

Write-Host "Done."
