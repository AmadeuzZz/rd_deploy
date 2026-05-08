# Check RustDesk deployment reports.

$root = "\\YOUR-FILE-SERVER\YOUR-SHARE$\reports"

Write-Host "=== Win7 main reports ==="
Get-ChildItem "$root\win7" -Filter *.txt -ErrorAction SilentlyContinue |
    Select-Object Name, LastWriteTime

Write-Host "=== Win10/11 main reports ==="
Get-ChildItem "$root\win10-11" -Filter *.txt -ErrorAction SilentlyContinue |
    Select-Object Name, LastWriteTime

Write-Host "=== Errors ==="
Get-ChildItem "$root\win7" -Filter *.txt -ErrorAction SilentlyContinue |
    Select-String "Status: ERROR"

Get-ChildItem "$root\win10-11" -Filter *.txt -ErrorAction SilentlyContinue |
    Select-String "Status: ERROR"

Write-Host "=== OK installs ==="
Get-ChildItem "$root\win7" -Filter *.txt -ErrorAction SilentlyContinue |
    Select-String "Status: OK"

Get-ChildItem "$root\win10-11" -Filter *.txt -ErrorAction SilentlyContinue |
    Select-String "Status: OK"

Write-Host "=== Status files ==="
Get-ChildItem "$root\win7\status" -Filter *.txt -ErrorAction SilentlyContinue |
    Select-Object Name, LastWriteTime

Get-ChildItem "$root\win10-11\status" -Filter *.txt -ErrorAction SilentlyContinue |
    Select-Object Name, LastWriteTime
