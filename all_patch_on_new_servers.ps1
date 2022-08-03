$pswd = Read-Host -AsSecureString -Prompt 'Provide your password to BSA' 
$bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($pswd)
$pswdvalue = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
blcred cred -acquire -profile Replica -username $env:USERNAME -password $pswdvalue
$servers = Read-Host  -Prompt 'Provide hostname (or hostnames separated with comma, without spaces) to patch' 
$servers=$servers.replace(' ','')
Write-Output "Starting patching job"
$JOB_FOLDER="/FLVS/Patch Management/Windows Patching"
$JOB_NAME="All patch on new server"
$JOB_KEY=blcli -v Replica -r FLVS_L3AdminW PatchingJob getDBKeyByGroupAndName $JOB_FOLDER $JOB_NAME
$patchjob=blcli -v Replica -r FLVS_L3AdminW Job executeAgainstServers $JOB_KEY $servers
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
