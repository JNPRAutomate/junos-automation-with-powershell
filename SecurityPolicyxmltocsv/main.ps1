
# Author: Shabbir; email: shahmed@juniper.net
# this script takes show configuration security | display xml or show configuration | display xml 
# as input and generates a csv of the security policies, in file 'policies.csv' in the same folder
# as of the script running.

param(
    [Parameter(Mandatory)]
    [String]$inputxml
)
if ($inputxml) {

    $outputcsv = '.\policies.csv'

    if (Test-Path $outputcsv) {
        Write-Host "File already exists!"
        Remove-Item $outputcsv -verbose
    }

    Write-Host "Reading XML file..."
    $xmlData = [xml](Get-Content -Path $inputxml)

    Write-Host "Parsing XML..."
    foreach ($policies in $xmlData.'rpc-reply'.configuration.security.policies.policy) {
        $s_zone = $policies.'from-zone-name'
        $d_zone = $policies.'to-zone-name'

        foreach ($innerpolicy in $policies.policy) {
            
            $policy_name = $innerpolicy.Name
            # Write-Host "PolicyName: $policy_name"
            $s_addr = $innerpolicy.match.'source-address'
            #Write-Host "source-address: $s_addr"
            $d_addr = $innerpolicy.match.'destination-address'
            # Write-Host "destination-address: $d_addr"
            $app = $innerpolicy.match.application
            # Write-Host "App: $app"

            $then = $innerpolicy.then

            # Write-Host "$s_zone,$d_zone,$policy_name,$s_addr,$d_addr,$app"
            $s_addr = $s_addr | Out-String
            $d_addr = $d_addr | Out-String
            $then = $then | Out-String
            $app = $app | Out-String
            $s_addr = $s_addr.Trim()
            $d_addr = $d_addr.Trim()
            $then = $then.Trim()
            $app = $app.Trim()
            
            $data = [ordered]@{
                source_zone = $s_zone
                destination_zone = $d_zone
                policy_name = $policy_name
                source_address = $s_addr
                destination_address = $d_addr.ToString()
                app= $app.ToString()
                then=$then
            } #; 's_addr'= $s_addr;'d_addr'= $d_addr; 'app'= $app}
            
            # $obj = New-Object PSObject -Property $data
            [PSCustomObject]$data | Export-CSV -path $outputcsv -NoTypeInformation -Append
            # Export-Csv $data -Append -Path 'data.csv' -NoTypeInformation 

        }
    }
    Write-Host "output csv generated $outputcsv"
    
}
else {

    Write-Output "Please provide input XML file!"
   
}