# Output Handling Using CSV
# Machine availability check
# Script Author : www.vivekrr.com

$details = @()
$pc = Get-Content $env:USERPROFILE\desktop\pc.txt
foreach ($sys in $pc)
{
    if(!(Test-Connection -Cn $sys -BufferSize 16 -Count 1 -ea 0 -quiet))
    {
        $Result = [ordered]@{
            MACHINE_NAME     = "$sys"
            PING_STATUS      = "MACHINE OFFLINE"
            OS_NAME = "N/A"
            TOTAL_PHYSICALMEMORY = "N/A"
    }
    $Details += New-Object PSObject -Property $Result
    }
    else
        {
        $osname = "N/A"
        $physicalmemory = "N/A"
        $sysdetails = ""
        $sysdetails = Get-WmiObject -Class Win32_computersystem -ComputerName $sys | select -ExpandProperty TotalPhysicalMemory
        $osname = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $sys | select -ExpandProperty caption
        $physicalmemory = ($sysdetails)/1mb -as [int]
            $Result = [ordered]@{
                MACHINE_NAME     = "$sys"
                PING_STATUS      = "MACHINE ONLINE"
                OS_NAME = "$OSNAME"
                TOTAL_PHYSICALMEMORY = "$physicalmemory"
        }
        $Details += New-Object PSObject -Property $Result
        }
}
$date = Get-Date -UFormat "%m-%d-%y"
$pathofcsv = "$env:userprofile\desktop\" + "Ping_Result_" + "$date" + ".csv"
$Details | export-csv -Path $pathofcsv -NoTypeInformation