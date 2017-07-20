#add-pssnapin VMware.VimAutomation.Core
#connect-viserver v -user USERNAME -password PASSWORD
$datastores = get-datastore | get-view
$datastores | select -expandproperty summary | select name, @{N=”Capacity (GB)”; E={[math]::round($_.Capacity/1GB,2)}}, @{N=”FreeSpace (GB)”;E={[math]::round($_.FreeSpace/1GB,2)}}, @{N=”Provisioned (GB)”; E={[math]::round(($_.Capacity – $_.FreeSpace + $_.Uncommitted)/1GB,2) }}| sort -Property Name | export-csv -Path C:\path\to\file.csv
