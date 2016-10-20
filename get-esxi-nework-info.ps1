Get-VMHostNetworkAdapter | select VMhost, Name, IP, SubnetMask, Mac, PortGroupName, vMotionEnabled, mtu, FullDuplex, BitRatePerSec | Export-Csv C:\VMHostNetworkDetails.csv
