# INTRODUCTION

The script is used to backup configurations from devices.

It accepts a list of Device IP addresses from a CSV file 'Switches.csv' saved in the same folder, script collects `show configuration | display set | no-more` from each device and saves it to individual files with host-name of the device as filename. The script creates a folder in the same folder as of script with a prefix 'ConfigBackup_' and script execution date as postfix, example 'ConfigBackup_25_10_2024'.

Script prompts for credintitials at the script's execution.

The output folder is zipped at the end of the execution.

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

`powershell.exe .\main.ps1`

**THE SCRIPT SHOULD ASK FOR USERNAME/PASSWORD***
**PLEASE DO NOT USE ROOT USER***

