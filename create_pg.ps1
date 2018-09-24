#Requires -module VMware.VimAutomation.Core, VMware.VimAutomation.Vds
param(
[string]$Net,
[string]$VRF,
[string]$VLANID
)

if (!$Net -or !$VRF -or !$VLANID)    
{ 
Write-host "Input params not provided! Please check params -Net -VRF -VLANID! EMERGENCY EXIT" -ForegroundColor "RED"; 
    Exit; 
} 
else 
{ 
Write-Host "Creating port group with params: `n Network: $net `n VRF: $vrf `n VLAN ID: $vlanid" -ForegroundColor "GREEN"
}
$vc1 = ""
$vc2 = ""

try { $KR01_Server = Connect-VIServer -Server vc1 -WarningAction SilentlyContinue -ErrorAction Stop }
Catch {  Write-Host "Connect to VC Server vc1 - FAILED" -ForegroundColor "RED"; Exit; }
try {  $SDC_Server = Connect-VIServer -Server vc2 -WarningAction SilentlyContinue -ErrorAction Stop }
Catch {  Write-Host "Connect to VC Server vc2 - FAILED" -ForegroundColor "RED"; Exit; }


$source_dvs = "KR01-DvSwitch"
$KR01_DVS = "KR01-DSwitch01"
$KR01_DVS_uplink = "kr01-lag1"
$SDC_DVS_uplink = "sdc-lag1"
$SDC_DVS = "SDC-DSwitch01"

$Netconfig = $Net + " (" + $VRF + " " + $VLANID + ")"
$NetLike =  " (" + $VRF + " " + $VLANID + ")"
Write-Host "`nI will try to create port group named: $Netconfig `n" -ForegroundColor "green"
Write-Host "Before I began, I'll check the existing port groups, just for case... `n" -ForegroundColor "Green"

#Searching PG by VLAN ID

$SearchNetworkKR01 = Get-VDSwitch -Name $KR01_DVS -Server $KR01_Server | Get-VDPortgroup | where {$_.Extensiondata.Config.DefaultPortCOnfig.Vlan.VlanId -eq $VLANID} | select Name
    If ($SearchNetworkKR01.Name -gt "")
        {
            Write-Host "KR01: Found existing network called:" $SearchNetworkKR01.Name -ForegroundColor "red"
            Write-Host "KR01: Please check VDS config, misconfiguration was detected `n" -ForegroundColor "red"
            $SearchNetworkKR01 = 1;
        }
    else
        {
            Write-Host "KR01: No network was found with vlan id $VLANID" -ForegroundColor "green"
        }

$SearchNetworkSDC = Get-VDSwitch -Name $SDC_DVS -Server $SDC_Server | Get-VDPortgroup | where {$_.Extensiondata.Config.DefaultPortCOnfig.Vlan.VlanId -eq $VLANID} | select Name
    If ($SearchNetworkSDC.Name -gt "")
        {
            Write-Host "SDC: Found some existing network called:" $SearchNetworkSDC.Name -ForegroundColor "red"
            Write-Host "SDC: Please check VDS config, misconfiguration was detected `n" -ForegroundColor "red"
            $SearchNetworkSDC = 1;
        }
    else
        {
            Write-Host "SDC: No network was found with vlan id $VLANID" -ForegroundColor "green"
        }

    if ($SearchNetworkKR01 -eq 1 -or $SearchNetworkSDC -eq 1) { Write-host "`n Application closing, please check VDS configuration!" -ForegroundColor "red"; exit; }


Try 
{
Write-Host "Creating new port group $Netconfig on server $KR01_Server" -ForegroundColor "Green"
$KR01_NPG = Get-VDSwitch -Name $KR01_DVS -Server $KR01_Server | New-VDPortgroup -Name $Netconfig -VLanId $VLANID -ErrorAction Stop
$KR01_PGNAME = Get-VDPortgroup -Server $KR01_Server -VDSwitch $KR01_DVS | where {$_.Name -like "*$NetLike*"} | Select Name 
write-host $KR01_PGNAME.Name
    for ($i=1; $i -ne 9; $i++)
    {
    $UnSetUplink = Get-VDPortgroup -Server $KR01_Server -VDSwitch $KR01_DVS -Name $KR01_PGNAME.Name | Get-VDUplinkTeamingPolicy | Set-VDUplinkTeamingPolicy -UnusedUplinkPort "Uplink $i"
    }
Get-VDPortgroup -Server $KR01_Server -VDSwitch $KR01_DVS -Name $KR01_PGNAME.Name | Get-VDUplinkTeamingPolicy | Set-VDUplinkTeamingPolicy -ActiveUplinkPort $KR01_DVS_uplink
} 
Catch
{
Write-Host "Please, check DVS config in vmware 6.0 infrastructure, seems that target portgroup is not configured" -ForegroundColor "Red"
Write-Host "Stopping migration! validation was not successful! Please check network configuration on the target infrastructure" -ForegroundColor "red"  
exit;
}

Try 
{
Write-Host "Creating new port group $Netconfig on server $SDC_Server" -ForegroundColor "Green"
$SDC_NPG = Get-VDSwitch -Name $SDC_DVS -Server $SDC_Server | New-VDPortgroup -Name $Netconfig -VLanId $VLANID -ErrorAction Stop
$SDC_PGNAME = Get-VDPortgroup -Server $SDC_Server -VDSwitch $SDC_DVS | where {$_.Name -like "*$NetLike*"} | Select Name 
write-host $PGNAME.Name
for ($i=1; $i -ne 9; $i++)
{
 $UnSetUplink = Get-VDPortgroup -Server $SDC_Server -VDSwitch $SDC_DVS -Name $SDC_PGNAME.Name | Get-VDUplinkTeamingPolicy | Set-VDUplinkTeamingPolicy -UnusedUplinkPort "Uplink $i"
}

Get-VDPortgroup -Server $SDC_Server -VDSwitch $SDC_DVS -Name $SDC_PGNAME.Name | Get-VDUplinkTeamingPolicy | Set-VDUplinkTeamingPolicy -ActiveUplinkPort $SDC_DVS_uplink
} 
Catch [System.Exception]
{
Write-Host "Please, check DVS config in vmware 6.0 infrastructure, seems that target portgroup is not configured" -ForegroundColor "Red"
Write-Host "Stopping migration! validation was not successful! Please check network configuration on the target infrastructure" -ForegroundColor "red"  
exit;
}
