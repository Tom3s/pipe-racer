Get-ChildItem -Path . -Recurse -File | Where-Object { $_.BaseName -match '^\d+$' -and [int]$_.BaseName -gt 16000000 } | ForEach-Object {
    $newName = [int]$_.BaseName - 12582912
    $newName += $_.Extension
    Rename-Item -Path $_.FullName -NewName $newName -Force -Verbose
}
