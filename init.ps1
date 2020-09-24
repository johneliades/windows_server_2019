New-NetIPAddress -InterfaceAlias 'Ethernet' -AddressFamily IPv4 -IPAddress 192.168.1.32 -PrefixLength 24 -DefaultGateway 192.168.1.1
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses("194.63.238.4", "194.63.239.164")
Disable-NetAdapterBinding -Name "Ethernet" -ComponentID ms_tcpip6

Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

$Params = @{
    CreateDnsDelegation = $false
    DatabasePath = 'C:\Windows\NTDS'
    DomainMode = 'WinThreshold'
    DomainName = 'school.local'
    DomainNetbiosName = 'SCHOOL'
    ForestMode = 'WinThreshold'
    InstallDns = $true
    LogPath = 'C:\Windows\NTDS'
    NoRebootOnCompletion = $true
    SafeModeAdministratorPassword = "janiomoy4!" | ConvertTo-SecureString -AsPlainText -Force
    SysvolPath = 'C:\Windows\SYSVOL'
    Force = $true
}
 
Install-ADDSForest @Params