HOW TO RUN THE SCRIPT


This script is based on Posh-SSH, the user must install the library if not already installed.
to install Posh-SSH
If the module is not installed we can install it by the following command, open powershell in administrator mode.


Install-Module -Name Posh-SSH


if script gives error user restricted error. please run the following command in powershell once 
before running the script. 


Set-ExecutionPolicy Unrestricted -Force -Scope CurrentUser


The script inputs a CSV file provided in the same folder, 

Add device IP in the same file with the following format.
1.1.1.1,
2.2.2.2,

open powershell 
cd into the directory where the script is saved.

Then execute the following command.


powershell.exe .\GetDeviceOutputs.ps1

The script creates a zip file in C:\temp\ named JuniperNetworks.zip
The zip contains 2 files, show_chassis_hardware.txt and show_version.txt.
Customer has to share the same file with Juniper Networks.

