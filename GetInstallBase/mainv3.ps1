# dev: Shabbir
# email: shahmed@juniper.net, shabbir.ahmed@yahoo.com
# version: 3

Set-ExecutionPolicy Unrestricted -Force -Scope Process

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
$output_filename = (Get-Date).tostring("dd_MM_yyyy")

$FolderName = "JuniperNetworks"

if (Test-Path "c:\temp\$FolderName") {
 
  Write-Host "Folder Already Exists"
  Remove-Item c:\temp\$FolderName -Force -Recurse
	New-Item -ItemType Directory -Path "c:\temp" -Name $FolderName
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
    Write-Host -ForegroundColor Yellow "Sending 'show chassis hardware detail | display xml | no-more'"
    $SSHStream.WriteLine("")
    $SSHStream.WriteLine("show chassis hardware detail | display xml | no-more")
    Start-Sleep -s 15
    $cmd_output = $SSHStream.read()
    #Write-Host -ForegroundColor Yellow $cmd_output

    $start_recording=0
    $flag=0
    $parsed_output = ""
    ForEach ($current_line in $($cmd_output -split "`n"))
    {
      if($current_line -like '*> show chassis hardware detail*') {
            #Write-Host $current_line
            $parsed_output = $parsed_output + $current_line
            $flag=1
      }
      if($current_line -like '<rpc-reply*' -And $flag -eq 1) {
            $start_recording=1
      }

      if($current_line -like '</rpc-reply*' -And $flag -eq 1) {
            #Write-Host $current_line
            $parsed_output = $parsed_output + $current_line + "`n"
            #Write-Host ""
            $start_recording=0
            
      }

      if($start_recording -eq 1 -And $flag -eq 1) {
            #Write-Host $current_line
            $parsed_output = $parsed_output + $current_line
            
      }
    }

    Write-Host -ForegroundColor Red "Saving outputs to file."

    # create a new file if it does not exists

    if (!(Test-Path "c:\temp\$folderName\show_chassis_hardware.txt"))
    {
      #New-Item -path C:\temp\$folderName\ -name $output_filename -type "file"
      #Write-Host "Created new file and text content added"
      $parsed_output | Out-File -FilePath c:\temp\$folderName\show_chassis_hardware.txt -Encoding ASCII
    }
    else
    {
      #Add-Content -path C:\temp\$folderName\$output_filename.txt -value $cmd_output
      $parsed_output | Out-File -FilePath c:\temp\$folderName\show_chassis_hardware.txt -Encoding ASCII -Append
      #Write-Host "File already exists and new text content added adding value"
    }

    $parsed_output = ""

    ### send the show version command to the device to get the output.
    Write-Host -ForegroundColor Yellow "Sending 'show version | no-more'"
    $SSHStream.WriteLine("")
    $SSHStream.WriteLine("")
    $SSHStream.WriteLine("show version | no-more")
    Start-Sleep -s 15
    $cmd_sh_ver = $SSHStream.read()
    #Write-Host -ForegroundColor Yellow $cmd_sh_ver

    $start_recording=0
    $flag=0
    $parsed_output = ""
    $prompt_hostname = ""

    ForEach ($current_line in $($cmd_sh_ver -split "`n")) {

      if($current_line -like '*@*> show version*') {
          #Write-Host $current_line
          #$parsed_output = $current_line
          $flag=1
          $start_recording=1
          # record the hostname
          #write-host "Finding host-name"
          $prompt_hostname = $current_line.Split(">")[0]
          #write-host $prompt_hostname
          #$prompt_hostname = $prompt_hostname.split("@")[1]
          #write-host $prompt_hostname
          $flag=1
      }
      $match_prompt_hostname = $prompt_hostname + "> "
      if ($current_line -like $match_prompt_hostname) {
        $start_recording = 0
        write-host "inside matching prompt again!"
      }

      if($current_line -like '*master*' -or $current_line -like '*primary*' -Or $current_line -like '*secondary*' -Or $current_line -like '*backup*' ) {
        continue
      }
    
      if($start_recording -eq 1) {
        #Write-Host $current_line

        $parsed_output = $parsed_output + $current_line
      }
    }

    # create a new file if it does not exists

    if (!(Test-Path "c:\temp\$folderName\show_version.txt"))
    {
      #New-Item -path C:\temp\$folderName\ -name $output_filename -type "file"
      #Write-Host "Created new file and text content added"
      Write-Host -ForegroundColor Red "Saving outputs to file."
      $parsed_output | Out-File -FilePath c:\temp\$folderName\show_version.txt -Encoding ASCII
    }
    else
    {
      #Add-Content -path C:\temp\$folderName\$output_filename.txt -value $cmd_output
      $parsed_output | Out-File -FilePath c:\temp\$folderName\show_version.txt -Encoding ASCII -Append
    }

    $cmd_sh_ver =""

    #$cmd_output | Out-File -FilePath c:\temp\$folderName\$SwitchIP.txt -Encoding ASCII

    Write-Host -ForegroundColor Yellow "Disconnecting"

    Remove-SSHSession -Index 0
  }


}

Compress-Archive -Path c:\temp\$folderName -DestinationPath C:\temp\$FolderName.zip -Force 