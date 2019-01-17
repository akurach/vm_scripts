$Servername =
$Clustername =

Import-Module -Name VMware.VimAutomation.Core
Connect-ViServer $Servername
Get-Cluster $Clustername |Get-VM | Get-CDDrive | Where-Object {$_.ISOPath -ne $null} | Set-CDDrive -NoMedia -Confirm:$false
