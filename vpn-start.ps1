$Command = 'netsh.exe';
$Parms = 'trace start provider=Microsoft-Windows-RRAS provider=Microsoft-Windows-WFP provider=Microsoft-Windows-Ras-NdisWanPacketCapture provider=Microsoft-Windows-RasSstp provider=Microsoft-Windows-WebIO  provider={106B464D-8043-46B1-8CB8-E92A0CD7A560} keywords=0xFFFFFFFFFFFFFFFF level=255 Ethernet.Type=(IPv4,IPv6,0) Wifi.Type=Data capture=yes report=disabled correlation=disabled overwrite=yes tracefile=vpn-probe.etl';
$Prms = $Parms.Split(' ');
& $Command $Prms;

pktmon filter remove
pktmon filter add SSTP -p   443 -i SSTPIP
pktmon start --capture --comp nics --flags 0x10 --file-name C:\Windows\system32\pktmon.etl


&{1..1|%{(new-Object System.Media.SoundPlayer('c:\windows\media\tada.wav')).Play();sleep 2}}
