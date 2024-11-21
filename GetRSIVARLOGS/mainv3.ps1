Set-ExecutionPolicy Unrestricted -Force -Scope CurrentUser

Import-Module Posh-SSH

# Read the IP addresses from a CSV.
# the format is IP as header and next 
# line starts with IP addresses in the 
# following format.
# 1.1.1.1,
# 2.2.2.2,
$CSV = Import-Csv Switches.csv

# Create a new directory with today's date and time.
# 
# 
# 

#$folderName = (Get-Date).tostring("dd-MM-yyyy-hh-mm-ss")
$output_filename = (Get-Date).tostring("dd_MM_yyyy-hh-mm")

$FolderName = "JuniperNetworks"

if (Test-Path "c:\temp\$FolderName") {
 
  Write-Host "Folder Already Exists"
}
else
{
  Write-Host "Folder Doesn't Exists, Creating!"
	New-Item -ItemType Directory -Path "c:\temp" -Name $FolderName
}

# get credentials
$Creds = Get-Credential

# loop through all the IPs

foreach ($Switch in $CSV)
{

  $SwitchIP = $Switch.IP | Out-String
  $SwitchIP = $SwitchIP  -replace '\s','' -replace '\n','' -replace '\s+',''

  Write-Host -ForegroundColor Yellow "Connecting to $SwitchIP"

  Get-SSHTrustedHost | Remove-SSHTrustedHost

  New-SSHSession -ComputerName $Switch.IP -Credential $Creds -AcceptKey 

  $sess = Get-SSHSession

  #Write-Host $sess.Session.IsConnected -ForegroundColor Yellow

  if ($sess.Session.IsConnected) {

    $SSHStream = New-SSHShellStream -Index 0 -Columns 150
    Start-Sleep -s 5
    Write-Host -ForegroundColor Yellow "Sending 'request support information | save /var/tmp/$output_filename.rsi'"
    $SSHStream.WriteLine("")
    $SSHStream.WriteLine("request support information | save /var/tmp/$output_filename.rsi")
    
    $cmd_output = $SSHStream.read()
    Write-Host -ForegroundColor Yellow $cmd_output
	Start-Sleep -s 30
	$cmd_output = $SSHStream.read()
	
	Write-Host "printing output recieved after 30 seconds"
	
	if (!$cmd_output) {
		Write-Host "no output"
	}
	Write-Host -ForegroundColor Yellow $cmd_output
	
	
	# zip the RSI
	Write-Host -ForegroundColor Yellow "Sending 'file compress file /var/tmp/$output_filename.rsi'"
    $SSHStream.WriteLine("")
	$SSHStream.WriteLine("file compress file /var/tmp/$output_filename.rsi")
    Start-Sleep -s 30
    $cmd_output = $SSHStream.read()
	Write-Host $cmd_output
	
	# Get-SCPItem -SFTPSession $sess -RemoteFile "/var/tmp/$output_filename.rsi.gz" -LocalPath "C:\$FolderName\$output_filename.rsi.gz"
	
	# file archive compress source /var/log/* destination /var/tmp/varlog-28-09-2020.tgz
	# 
	Write-Host -ForegroundColor Yellow "Sending 'file archive compress source /var/log/* destination /var/tmp/$output_filename.tgz'"
    $SSHStream.WriteLine("")
	$SSHStream.WriteLine("file archive compress source /var/log/* destination /var/tmp/$output_filename.tgz")
    Start-Sleep -s 30
    $cmd_output = $SSHStream.read()
	Write-Host $cmd_output
	
    $start_recording=0
    $flag=0
    $parsed_output = ""
    Write-Host -ForegroundColor Yellow "Disconnecting"
	
    Remove-SSHSession -Index 0
  }
	$final_rsi_local_fname = $Switch.IP+"_"+$output_filename + ".rsi.gz"
	Write-Host "Copying RSI to local computer $final_local_fname"
	Get-SCPItem -ComputerName $Switch.IP  -Credential $Creds -Path "/var/tmp/$output_filename.rsi.gz" -PathType File -Destination c:\temp\$FolderName\ -NewName $final_rsi_local_fname
	
	# remove the; Remove-SFTPItem
	
	Write-Host "Copying VARLOG to local computer "+$output_filename.tgz
	$final_varlog_file = $Switch.IP+"_"+$output_filename+".varlog.tgz"
	Get-SCPItem -ComputerName $Switch.IP  -Credential $Creds -Path "/var/tmp/$output_filename.tgz" -PathType File -Destination c:\temp\$FolderName\ -NewName $final_varlog_file
}


#.rsiCompress-Archive -Path c:\temp\$folderName -DestinationPath C:\temp\$FolderName.zip -Force