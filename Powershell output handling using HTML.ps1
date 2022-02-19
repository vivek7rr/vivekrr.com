## vivekrr.com ##

$Table =
{
'<table width=40% align=center>'
'<th align="center"> <h3><font color=red>SYSTEM PROPERTIES<h3></th>'
'</table>'
'<table border="1" width=40% align=center>'
'<tr bgcolor=skyblue>'
'<th>HOST NAME</th><th>OPERATING SYSTEM NAME</th><th>SERIAL NO</th>'
}

$process=
{
Get-Content $env:USerProfile\desktop\pc.txt | foreach {
'<tr>'
'<td align="center" >{0}</td>' -f $_
if(!(Test-Connection -Cn $_ -BufferSize 16 -Count 1 -ea 0 -quiet))
{
$failed = "Failed to Ping"
'<td bgcolor = orange align = center>{0}</td><td bgcolor = orange align = center>{1}</td>' -f $failed,$failed
}
else
{
$Error.Clear()
$Sysdetails = Get-WmiObject -Class win32_operatingsystem -ComputerName $_
if($Error[0])
{
$unknown = "Unknown"
'<td bgcolor = yellow align = center>{0}</td> <td bgcolor = yellow align = center>{1}</td>' -f $unknown,$unknown
}
else
{
'<td bgcolor=lightgreen align=center>{0}</td> <td bgcolor=lightgreen align=center>{1}</td>' -f $Sysdetails.Caption,$Sysdetails.SerialNumber
}
}'<tr>'
$Sysdetails = $null
}
# Foreach End
}
#Process End
$Tableend

$Path = "$env:USerProfile\desktop\SysDetails.html"
ForEach-Object -Begin $table -Process $process -End $tableend |
Set-Content -Path $Path -Encoding ascii
Invoke-Expression $Path