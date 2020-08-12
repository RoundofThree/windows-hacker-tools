@echo off
netsh int ip set address "Ethernet0" static 10.10.0.1 255.255.0.0 0.0.0.0 1
netsh interface ipv4 delete dnsserver "Ethernet0" all
netsh advfirewall set allprofiles state off