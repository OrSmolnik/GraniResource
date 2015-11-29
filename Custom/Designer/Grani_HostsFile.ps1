Import-Module xDSCResourceDesigner
$property = @()
$property += New-xDscResourceProperty `
    -Name HostName `
    -Type String `
    -Attribute Key `
    -Description "HostName to be redirected."
$property += New-xDscResourceProperty `
    -Name Ensure `
    -Type String `
    -Attribute Required `
    -Description "Ensure Host Entry is Present or Absent." `
    -ValueMap Present, Absent `
    -Values Present, Absent
$property += New-xDscResourceProperty `
    -Name Reference `
    -Type String `
    -Attribute Required `
    -ValueMap DnsServer, StaticIp `
    -Values DnsServer, StaticIp `
    -Description "Reference type for DnsServer. When Reference is DnsServer, resolve DNS with selected server. When Reference is StaticIp, no resolve and just added IP Address"
$property += New-xDscResourceProperty `
    -Name IpAddress `
    -Type String `
    -Attribute Required `
    -Description "IP Address for reference."

New-xDscResource -Name Grani_HostsFile -Property $property -Path .\ -ModuleName GraniResource -FriendlyName cHostsFile -Force