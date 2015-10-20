Import-Module xDSCResourceDesigner
$property = @()
$property += New-xDscResourceProperty `
    -Name HostName `
    -Type String `
    -Attribute Key `
    -Description "HostName to be redirected."
$property += New-xDscResourceProperty `
    -Name IpAddress `
    -Type String `
    -Attribute Required `
    -Description "IP Address redirect to."
$property += New-xDscResourceProperty `
    -Name Ensure `
    -Type String `
    -Attribute Required `
    -Description "Ensure Host Entry is Present or Absent." `
    -ValueMap Present, Absent `
    -Values Present, Absent

New-xDscResource -Name Grani_HostsFile -Property $property -Path .\ -ModuleName GraniResource -FriendlyName cHostsFile -Force