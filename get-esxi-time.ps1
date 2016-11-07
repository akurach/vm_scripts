foreach($esxcli in get-vmhost|get-esxcli){""|select @{n='Time';e={$esxcli.system.time.get()}},@{n='hostname';e={$esxcli.system.hostname.get().hostname}}}
