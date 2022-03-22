# SSTP-Troubleshooting
Powershell Scripts for SSTP Trobuleshooting



The Scripts are triggered by Windows Events for connecting and disconnecting a VPN Connection

Both Scripts play a sound when they run, so that users easily recognize a change in the VPN Connection state.
- Start: Rasman Event ID 20267
- Stop:  Rasman Event ID 20268


The Task Scheduler Task XML files expects the scripts in C:\Windows\COMPANY\VPN\
Everything was tested on Windows 10 20h2 x64 and is not x86 compatible because of the Paths that are used
# Things you need to modify
To import the Task you need to replace the following strings in the two xml Files

- domain\user
- C:\Windows\COMPANY\VPN\

In the vpn-start.ps1 files you need to replace this String
- SSTPIP with the Pulbic IP of your VPN Server

In the vpn-stop.ps1 files you need to replace these Strings
- $logpath with a path were all the Files are stored
- $logurl with a URL which can receive custom Headers

# Receive the Logs

I used a logstash HTTP Connector to receive the Logs and display them in Kibana.
You can use any other tool that can save and display Custom HTTP Headers.

![grafik](https://user-images.githubusercontent.com/10107699/159523072-b66d42ba-f1ca-4a55-8ad9-30bfc5255770.png)

# Why BitsTransfer

I use Start-BitsTransfer to transmit the logs, because it solves the Problem of retransmitting for me.
Otherwise I needed to implement a way to resend the log on a schedule and the script would be much more complicated.

One downside of using it, can be duplicated transmissions.
