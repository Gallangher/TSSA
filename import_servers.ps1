
Write-Output "Ensure you saved csv generated from intake form in Desktop\BSA_New_Server\servers.csv"
pause
$pswd = Read-Host -AsSecureString -Prompt 'Provide your password to BSA' 
$bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($pswd)
$pswdvalue = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
blcred cred -acquire -profile Replica -username $env:USERNAME -password $pswdvalue
$importservers=blcli -v Replica -r FLVS_L3AdminW Server bulkAddServers /C:/Users/$env:USERNAME/Desktop/BSA_New_Server servers.csv UTF-8 false
$servers=$importservers -replace '[][]',''
$servers=$servers.replace(' ','')
Write-Output "Succesfully imported $servers"
Write-Output "Starting verify"
$verifyservers=blcli -v Replica -r FLVS_L3AdminW Utility updateServersStatus $servers 2 120000 trueWrite-Output "Starting patching job"
$JOB_FOLDER="/FLVS/Patch Management/Windows Patching"
$JOB_NAME="All patch on new server"
$JOB_KEY=blcli -v Replica -r FLVS_L3AdminW PatchingJob getDBKeyByGroupAndName $JOB_FOLDER $JOB_NAME
$patchjob=blcli -v Replica -r FLVS_L3AdminW Job executeAgainstServers $JOB_KEY $servers
Write-host "WARNING: WAITING 60 SECONDS BEFORE CHECKING PATCH JOB" -foregroundcolor red
Start-Sleep -s 60
$RunID=blcli -v Replica -r FLVS_L3AdminW JobRun findLastRunKeyByJobKey $JOB_KEY
While ($true) {
    try {
        $ErrorActionPreference= 'silentlycontinue'
        $endTime=blcli -v Replica -r FLVS_L3AdminW JobRun getEndTimeByRunKey $RunID
        if (!$endTime){
            Throw
        }else{
            Break
        }
       }
    catch { 
        Write-Output "Patching Job still running. Waiting 1m" 
        Start-Sleep -s 60
    }
}
Write-Output "Patching ended at $endtime"
pause

