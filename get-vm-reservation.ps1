$startdir = "E:\mem"
$csvfile = "$startdir\memlimits.csv"
$myCol = @()
foreach ($VM in (Get-VM)){
$vmview = Get-VM -Name $VM | Get-View
$VMInfo = "" |select-Object VMName,CPUReservation,CPULimit,CPUShares,NumCPU,MEMSize,MEMReservation,MEMLimit,MEMShares
$VMInfo.VMName = $vmview.Name
$VMInfo.CPUReservation = $vmview.Config.CpuAllocation.Reservation
If ($vmview.Config.CpuAllocation.Limit-eq "-1"){$VMInfo.CPULimit = "Unlimited"}
Else{$VMInfo.CPULimit = $vmview.Config.CpuAllocation.Limit}
$VMInfo.CPUShares = $vmview.Config.CpuAllocation.Shares.Shares
$VMInfo.NumCPU = $VM.NumCPU
$VMInfo.MEMSize = $vmview.Config.Hardware.MemoryMB
$VMInfo.MEMReservation = $vmview.Config.MemoryAllocation.Reservation
If ($vmview.Config.MemoryAllocation.Limit-eq "-1"){$VMInfo.MEMLimit = "Unlimited"}
Else{$VMInfo.MEMLimit = $vmview.Config.MemoryAllocation.Limit}
$myCol += $VMInfo
}
$myCol |Export-csv -NoTypeInformation $csvfile
