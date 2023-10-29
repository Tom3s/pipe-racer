Get-ChildItem -Path . -File | Where-Object { $_.Extension -eq '' } | ForEach-Object {
    $newName = $_.Name + '.png'
    Rename-Item -Path $_.FullName -NewName $newName -Force
}
