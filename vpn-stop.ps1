$logpath = "C:\install\vpn-logs\"
$logurl = "https://log.example.com/vpn/"

$Command = 'netsh.exe'
$Parms = 'trace stop';$Prms = $Parms.Split(' ')
& $Command $Prms
& pktmon stop

mkdir $logpath

$date=$(get-date -f yyyy-MM-dd-HH-mm-ss);
Copy-Item C:\Windows\System32\vpn-probe.etl "$logpath\vpn-probe-$($date).etl"
Move-Item C:\Windows\system32\pktmon.etl C:\Windows\system32\pktmon-stopped.etl -Force

& pktmon pcapng C:\Windows\system32\pktmon-stopped.etl --out C:\Windows\system32\pktmon-stopped-out.pcapng
& pktmon pcapng C:\Windows\system32\pktmon-stopped.etl --drop-only --out C:\Windows\system32\pktmon-stopped-drop.pcapng

Copy-Item C:\Windows\system32\pktmon-stopped-out.pcapng "$logpath\pktmon-stopped-out-$($date).pcapng"
Copy-Item C:\Windows\system32\pktmon-stopped-drop.pcapng "$logpath\pktmon-stopped-drop-$($date).pcapng"

$Hashtable = @{logname="System";ID="20267"}
$event = get-winevent -FilterHashtable $Hashtable -MaxEvents 1
$lastconnect = $event.TimeCreated

$Hashtable2 = @{logname="System";ID="20268"}
$event = get-winevent -FilterHashtable $Hashtable2 -MaxEvents 1
$lasdistconnect = $event.TimeCreated

$wmi = (Get-WmiObject -Class win32_process  | Where-Object name -Match explorer).getowner().User | select -First 1

$users = Get-ChildItem "c:\Users" | Sort-Object LastWriteTime -Descending | ForEach-Object { "$($_.Name) $($_.LastWriteTime)" }
$FSusers=[string]::join(" , ", $users);

$Hashtable = @{logname="Application";ID="20222"}
$event = get-winevent -FilterHashtable $Hashtable -MaxEvents 1
#$event = get-winevent -FilterHashtable $Hashtable -MaxEvents 1000 | Out-GridView -PassThru
$body = $event.Message -replace "`n",", " -replace "`r",", "

$regex = $body | Select-String -Pattern 'Namen \".*?\"'  -AllMatches
$VPNName = $regex.Matches[0].Value -replace "Namen `"","" -replace "`"",""

$regex = $body | Select-String -Pattern 'Phone Number =.*?,'  -AllMatches
$IP = $regex.Matches[0].Value -replace "Phone Number = ","" -replace ",",""

$regex = $body | Select-String -Pattern 'Device = WAN Miniport \(.*?,'  -AllMatches
$regex.Matches[0]
$Type = $regex.Matches[0].Value -replace "Device = WAN Miniport \(","" -replace "\),",""

Start-BitsTransfer -ProxyUsage NoProxy -RetryInterval 60 -MaxDownloadTime 86400  -Priority Foreground -DisplayName "VPN-Report-$($date)" -Destination "$logpath\bits.log" -source $logurl  -Credential $null -CustomHeaders "lastconnect:$lastconnect","lastdisconnect:$lasdistconnect","wmiUser:$wmi","FSUsers:$FSUsers","Computer:$($env:COMPUTERNAME)","LogfileDate:$date","VPNName:$VPNName","IP:$IP","Type:$Type" -Asynchronous; 

$transfers = Get-BitsTransfer -Name "VPN-Report-*"
foreach($transfer in $transfers){
    if($transfer.CreationTime -lt $(Get-date).AddDays(-1)){
         Remove-BitsTransfer $transfer -Confirm:$false
    }
}

&{1..5|%{(new-Object System.Media.SoundPlayer('C:\Windows\Media\Speech Misrecognition.wav')).Play();sleep 1}} 
