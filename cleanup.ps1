$Users = Import-Csv -Path ".\users.csv"

Remove-SmbShare -Name "Network Users"
Remove-SmbShare -Name "Share"

# Remove server folders
Remove-Item -Path "C:\Share" -Recurse

takeown /f 'C:\Network Users\*' /r /d y 
icacls 'C:\Network Users\*' /grant administrators:F /T

Remove-Item -Path "C:\Network Users\" -Recurse

ForEach ($User In $Users)
{
    # Remove each user
    Remove-ADUser -Identity $User.Name -Confirm:$False `
}

Remove-GPO -Name "User Policies"
Remove-GPO -Name "Computer Policies"