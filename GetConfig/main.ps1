# dev: Shabbir
# email: shahmed@juniper.net, shabbir.ahmed@yahoo.com
# version: 3

Set-ExecutionPolicy Unrestricted -Force -Scope CurrentUser

Import-Module Posh-SSH
# version 2, changes
# pick configurations without password/secret data.

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
$output_filename = (Get-Date).tostring("dd_MM_yyyy")

$FolderName = "ConfigBackup_" + $output_filename

if (Test-Path "$FolderName") {
 
  Write-Host "Folder Already Exists"
  Remove-Item $FolderName -Force -Recurse
	New-Item -ItemType Directory -Name $FolderName
}
else
{
  Write-Host "Folder Doesn't Exists, Creating!"
	New-Item -ItemType Directory -Name $FolderName
}

# get credentials
#$Creds = Get-Credential

# set the username variable, the user name must not be root. it can be any user with rights to read configurations. 

$user = "stadmin"

# put the password here put password "" after -String.

$pass = ConvertTo-SecureString -String "pppict@123" -AsPlainText -Force

$creds = new-object -typename System.Management.Automation.PSCredential -argumentlist $user,$pass
# loop through all the IPs

foreach ($Switch in $CSV)
{

  $SwitchIP = $Switch.IP | Out-String
  $SwitchIP = $SwitchIP  -replace '\s','' -replace '\n','' -replace '\s+',''

  Get-SSHTrustedHost | Remove-SSHTrustedHost

  Write-Host -ForegroundColor Yellow "Connecting to $SwitchIP"
  New-SSHSession -ComputerName $Switch.IP -Credential $creds -AcceptKey 

  $sess = Get-SSHSession
  $parsed_output = ""
  $prompt_hostname = ""
  $cmd_output=""

  if ($sess.Session.IsConnected) {
    Write-Host -ForegroundColor Yellow "Connected to $SwitchIP"
    $SSHStream = New-SSHShellStream -Index 0 -Columns 200
    Start-Sleep -s 5
    Write-Host -ForegroundColor Yellow "Sending 'show configuration | display set | except encrypted-password | no-more'"
    $SSHStream.WriteLine("")
    $SSHStream.WriteLine("show configuration | display set | except encrypted-password | no-more")
    Start-Sleep -s 15
    $cmd_output = $SSHStream.read()
    #Write-Host -ForegroundColor Yellow $cmd_output
    # create a new file if it does not exists
    $start_recording=0
    
    ForEach ($current_line in $($cmd_output -split "`n"))
    {

      if($current_line -like '*> show configuration | display set*') {
            #Write-Host $current_line
            $prompt_hostname = $current_line.Split(">")[0]
            $prompt_hostname = $prompt_hostname.Split("@")[1]
            #$parsed_output = $parsed_output + $current_line
            $start_recording=1
      }

      if($current_line -like '{master}' -And $start_recording -eq 1) {
            #Write-Host $current_line
            #$parsed_output = $parsed_output + $current_line + "`n"
            #Write-Host ""
            $start_recording=0
            
      }

      if($start_recording -eq 1) {
            #Write-Host $current_line
            $parsed_output = $parsed_output + $current_line
            
      }
    }

    Write-Host -ForegroundColor Red "Saving outputs to file."
    Write-Host -ForegroundColor Yellow $prompt_hostname

    if (!(Test-Path "$folderName\$prompt_hostname.txt"))
    {
      #New-Item -path $folderName\ -name $output_filename -type "file"
      #Write-Host "Created new file and text content added"
      $parsed_output | Out-File -FilePath $folderName\$prompt_hostname.txt -Encoding ASCII
    }
    else
    {
      #Add-Content -path $folderName\$output_filename.txt -value $cmd_output
      $parsed_output | Out-File -FilePath $folderName\$prompt_hostname.txt -Encoding ASCII -Append
      #Write-Host "File already exists and new text content added adding value"
    }
  }
  Write-Host -ForegroundColor Yellow "Disconnecting"

  Remove-SSHSession -Index 0
}

Compress-Archive -Path $folderName -DestinationPath $FolderName -Force