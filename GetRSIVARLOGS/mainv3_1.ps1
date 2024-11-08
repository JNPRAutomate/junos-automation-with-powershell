# dev: Shabbir
# email: shahmed@juniper.net, shabbir.ahmed@yahoo.com
# version: 3

# Set-ExecutionPolicy Unrestricted -Force -Scope CurrentUser

Import-Module Posh-SSH

function main {
	
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
	  write-host -ForegroundColor Yellow "Files will be copied to c:\temp\$FolderName\$output_filename on local computer"
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

	  
		
	try {
		
	  New-SSHSession -ComputerName $Switch.IP -Credential $Creds -AcceptKey 
	  $sess = Get-SSHSession

	  #Write-Host $sess.Session.IsConnected -ForegroundColor Yellow

	  if ($sess.Session.IsConnected) {

		$SSHStream = New-SSHShellStream -Index 0 -Columns 150
		
		Start-Sleep -s 5
		# $SSHStream.WriteLine("set cli timestamp")
		
		#execute_cmd($SSHStream)
		$cmd_output = $SSHStream.read()
		# Write-Host -ForegroundColor Yellow $cmd_output
		# Write-Host "last char is " $cmd_output[-2]
		
		# declare hostname varilable
		
		$hostname = ""
		# extract the host-Name
		
		if ($cmd_output[-2] -eq '>') {
			
			$hostname = ($cmd_output -split "`n")[-1]
			$hostname = $hostname.split(">")[0]
			$hostname = $hostname.split("@")[1]
			write-host "Device host-name is " $hostname
			
		}
		
		$cmds = @(
		("request support information | save /var/tmp/"+$output_filename+".rsi"),
		("file compress file /var/tmp/"+$output_filename+".rsi"),
		("file archive compress source /var/log/* destination /var/tmp/"+$output_filename+ ".tgz")
		)
		
		foreach($cmd in $cmds) {
			
			if ($cmd_output[-2] -eq '>') {
		
				Write-Host -ForegroundColor Yellow "Sending $cmd"
				# $SSHStream.WriteLine("")
				$SSHStream.WriteLine($cmd)
				
				# $cmd_output = $SSHStream.read()
				# Write-Host -ForegroundColor Yellow $cmd_output
				$check = 1
				Write-Host -NoNewline "Progress..."
				while ($check -eq 1) {
					Start-Sleep -s 5
					$cmd_output = $SSHStream.read()
					
					if ($cmd_output[-2] -eq '>') {
						$check = 0
						Write-Host ""
						Write-Host -ForegroundColor Yellow $cmd_output
						Write-Host "Command completed!"
					} else {
						Write-Host -NoNewline "."
						# if ($cmd_output[-2] -eq '>') { Write-Host $cmd_output }
					}
					
				}
			}
		}
			}	
		
		}
	  catch { write-host "Error Connecting Device: $SwitchIP " }
	  
	  finally {
		Write-host -NoNewline "Disconnecting Device: "
		Remove-SSHSession -Index 0
	  }
	  
		$final_rsi_local_fname = $hostname+"_"+$output_filename + ".rsi.gz"
		Write-Host "Copying RSI to local computer c:\temp\$FolderName\$final_rsi_local_fname"
		Get-SCPItem -ComputerName $Switch.IP  -Credential $Creds -Path "/var/tmp/$output_filename.rsi.gz" -PathType File -Destination c:\temp\$FolderName\ -NewName $final_rsi_local_fname
		
		# remove the; Remove-SFTPItem
		
		
		$final_varlog_file = $hostname+"_"+$output_filename+".varlog.tgz"
		Write-Host "Copying VARLOG to local computer c:\temp\$FolderName\$final_varlog_file"
		Get-SCPItem -ComputerName $Switch.IP  -Credential $Creds -Path "/var/tmp/$output_filename.tgz" -PathType File -Destination c:\temp\$FolderName\ -NewName $final_varlog_file
	  }
}


# main
main