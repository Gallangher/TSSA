$limit = (Get-Date).AddDays(-80)
Get-ChildItem -Path 'C:\temp\stage' -Recurse | Where-Object { $_.LastWriteTime -lt $limit } |Remove-Item -Recurse -Force -Confirm:$false
Get-ChildItem -Path 'C:\Program Files\BMC Software\BladeLogic\RSCD\Transactions'  -Exclude shavlik,log,locks,events,Database,analysis_archive -Recurse | Where-Object { $_.LastWriteTime -lt $limit } | Remove-Item -Recurse -Force -Confirm:$false
