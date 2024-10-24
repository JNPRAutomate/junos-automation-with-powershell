HOW TO RUN THE SCRIPT

=======================================================
This script is based on Posh-SSH, the user must install the library if not already installed.
To install Posh-SSH
open powershell in administrator mode and run the following command.
=======================================================

Install-Module -Name Posh-SSH

=======================================================
if script gives error user restricted error. please run the following command in powershell once 
before running the script. 
=======================================================

Set-ExecutionPolicy Unrestricted -Force -Scope CurrentUser

=======================================================
The script reads a CSV file provided in the same folder, 

Add device IP in the same file with the following format.
1.1.1.1,
2.2.2.2,

How to run the script

open powershell 
cd into the directory where the script is saved.

Then execute the following command.
=======================================================

powershell.exe .\mainv3.ps1

**THE SCRIPT SHOULD ASK FOR USERNAME/PASSWORD***
**PLEASE DO NOT USE ROOT USER***

The script creates a zip file in C:\temp\ named JuniperNetworks.zip
The zip contains 2 files, show_chassis_hardware.txt and show_version.txt.
Customer has to share the same file with Juniper Networks.

