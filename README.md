Bla bla bla

get-esxi-time.ps1
-------------
So what we are actually doing is:
1) get access to all hosts esxcli
2) on each of those esxcli to run command: esxcli system time get and esxcli system hostname get
3) output with columns time and hostname
This will output time from all our esxi host systems that are registered in the virtual center to which we are connected in current powercli session.
If you do not want to it for all hosts simply manipulate the get-vmhost , like get-vmhost -Location ‘xxxx’
