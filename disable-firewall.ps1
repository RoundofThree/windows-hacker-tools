# Disable-Firewall.ps1
# Mick Douglas (@BetterSafetyNet) 20190731

#  Windows Defender Firewall will sometimes re-enable when the NIC changes state
#  This most often happens when the VM is changed from "Host Only" to "Bridged" network mode.
#  When this happens, it can cause labs to fail.
#  To combat this, this script will be triggered on a Firwall Event ID of 2003. It will:
#  	1) Check to see if Windows Defender Firewall is running
#	2) Check to see if any NIC is using an IP address range used in class (10.10.0.0/16)
#  If these two conditions are met, the firewall will be disabled.



# Gather Windows Defender Firewall state.
$FirewallState = Get-NetFirewallProfile | Where-Object Enabled -EQ $TRUE

# If there's no value (meaning no profiles are enabled, the firewall is not running... $FirewallState will be NULL and we can exit)
if ($FirewallState) {
    # If the script has got to this point, there is a firewall profile enabled. 
    # We now have to test to see if this system is in an IP range where firewall should be disabled.

    # Gather NICs that have IP addresses enabled and in the 10.10.0.0/16 range.
    $NICs = Get-CIMInstance -ClassName Win32_NetworkAdapterConfiguration | Where-Object IPEnabled -eq $TRUE | Where-Object IPAddress -ILike "10.10.*"

    # If there are any NICs in the "no firewall IP" range, disable all profiles of Windows Defender Firewall.
    if ($NICs) {
        Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
    }
}





