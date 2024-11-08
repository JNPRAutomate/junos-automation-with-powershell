# INTRODUCTION

The script is used to collect the install base in customer environments.

It accepts a list of Device IP addresses from a CSV file 'Switches.csv' saved in the same folder, script collects `show chassis hardware detail | display xml | no-more` and `show version | no-more` from each device. The output is then saved into two saperates files each for it's respective outputs inside c:\temp\JuniperNetworks folder. At the end of the script the folder is zipped to c:\temp\JuniperNetworks.zip.

# PRE-REQ

The script is based on a Posh-SSH PowerShell Lib, which can be installed by using the following command (if not installed).

## INSTALL Posh-SSH

open powershell in administrator mode and run the following command.
`Install-Module -Name Posh-SSH`

## SCRIPT PERMISSIONS

if script generates the following error 'user restricted error'. please run the following command in powershell once 
before running the script. 

`Set-ExecutionPolicy Unrestricted -Force -Scope CurrentUser` in powershell terminal.

## DEVICE IP ADDRESSES

The script reads a CSV file provided in the same folder, 
Add device IP in the same file in the following format which is 1 IP per line.
1.1.1.1,
2.2.2.2,

## RUNNING THE SCRIPT

1. open powershell 
2. cd into the directory where the script is saved.
3. RUN THE FOLLOWING COMMAND

`powershell.exe .\mainv3.ps1`

**THE SCRIPT SHOULD ASK FOR USERNAME/PASSWORD***
**PLEASE DO NOT USE ROOT USER***

The script creates a zip file in C:\temp\ named JuniperNetworks.zip
The zip contains 2 files, show_chassis_hardware.txt and show_version.txt.
Customer has to share the same file with Juniper Networks.

