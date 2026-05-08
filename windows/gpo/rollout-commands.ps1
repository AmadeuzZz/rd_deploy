# PowerShell rollout helpers.
# Run from DC/admin workstation with RSAT.

# One PC:
Invoke-GPUpdate -Computer "YOUR-WIN10-TEST-PC" -Force -RandomDelayInMinutes 0
Restart-Computer -ComputerName "YOUR-WIN10-TEST-PC" -Force

# List of PCs:
$pcs = Get-Content C:\Temp\rustdesk-test-pcs.txt

foreach ($pc in $pcs) {
    if (Test-Connection $pc -Count 1 -Quiet) {
        Write-Host "$pc online, gpupdate..."
        Invoke-GPUpdate -Computer $pc -Force -RandomDelayInMinutes 0
    } else {
        Write-Host "$pc offline"
    }
}

foreach ($pc in $pcs) {
    if (Test-Connection $pc -Count 1 -Quiet) {
        Write-Host "$pc reboot..."
        Restart-Computer -ComputerName $pc -Force
    }
}

# Export AD computers by OS:
Get-ADComputer -Filter * -Properties OperatingSystem |
Select-Object Name, OperatingSystem |
Sort-Object OperatingSystem, Name |
Export-Csv C:\Temp\computers-os.csv -NoTypeInformation -Encoding UTF8

# Win7 list:
Get-ADComputer -Filter * -Properties OperatingSystem |
Where-Object { $_.OperatingSystem -like "*Windows 7*" } |
Select-Object -ExpandProperty Name |
Out-File C:\Temp\win7-pcs.txt -Encoding ascii

# Win10/11 list:
Get-ADComputer -Filter * -Properties OperatingSystem |
Where-Object {
    $_.OperatingSystem -like "*Windows 10*" -or
    $_.OperatingSystem -like "*Windows 11*"
} |
Select-Object -ExpandProperty Name |
Out-File C:\Temp\win10-11-pcs.txt -Encoding ascii
