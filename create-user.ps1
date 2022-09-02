$userName = "{{username}}"
$ssmParameter = "{{ssmparameter}}"
$checkForUser = (Get-LocalUser).Name -Contains $userName
$log_file = 'c:\\log_Create_User.txt'

# Check if user exist
if ($checkForUser -eq $false) {
    Write-Host "$userName does not exist, Creating user $userName"
    Add-Content -Path $log_file -Value "$userName does not exist, Creating user $userName"
    try {
        $ssmvalue = (Get-SSMParameterValue -Name $ssmParameter -WithDecryption $true).Parameters.Value
        $password = ConvertTo-SecureString $ssmvalue -AsPlainText -Force
        New-LocalUser "$username" -Password $password -ErrorAction stop
        Write-Host "$username local user created"
        Add-Content -Path $log_file -Value "$username local user created"
      } catch {
        Write-Host "Creating $username user failed"
        Add-Content -Path $log_file -Value "Creating $username user failed"
      }
    } ElseIf ($checkForUser -eq $true) {
      Write-Host "$userName Exists"
      Add-Content -Path $log_file -Value "$userName Exists"
}
