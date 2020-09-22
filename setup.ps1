$Users = Import-Csv -Path ".\users.csv"

#Create server folders
New-Item `
    -Path "C:\" `
    -Name "Network Users" `
    -ItemType "directory" `
    -ErrorAction SilentlyContinue `

New-Item `
    -Path "C:\" `
    -Name "Share" `
    -ItemType "directory" `
    -ErrorAction SilentlyContinue `

# Share them
New-SmbShare `
    -Name "Network Users" `
    -Path "C:\Network Users\" `
    -CachingMode None `
    -FullAccess "Everyone"`
    -FolderEnumerationMode AccessBased `

New-SmbShare `
    -Name "Share" `
    -Path "C:\Share" `
    -CachingMode None `
    -FullAccess "Everyone"`
    -FolderEnumerationMode AccessBased `

# Set Security Network Users
$acl = Get-Acl -Path "C:\Network Users\"
$acl.SetAccessRuleProtection($true, $false)

$args = "Administrator", "FullControl", "Allow"
$accessrule = New-Object -Typename System.Security.AccessControl.FileSystemAccessRule -ArgumentList $args
$acl.SetAccessRule($accessrule)

$args = "SCHOOL\Domain Admins", "FullControl", "Allow"
$accessrule = New-Object -Typename System.Security.AccessControl.FileSystemAccessRule -ArgumentList $args
$acl.SetAccessRule($accessrule)

$args = "SCHOOL\Domain Users", "FullControl", "Allow"
$accessrule = New-Object -Typename System.Security.AccessControl.FileSystemAccessRule -ArgumentList $args
$acl.SetAccessRule($accessrule)

Set-Acl -Path "C:\Network Users\" -AclObject $acl

# Set Security Share
$acl = Get-Acl -Path "C:\Share\"

$args = "Administrator", "FullControl", "ContainerInherit, ObjectInherit", "None", "Allow"
$accessrule = New-Object -Typename System.Security.AccessControl.FileSystemAccessRule -ArgumentList $args
$acl.SetAccessRule($accessrule)

$args = "SCHOOL\Domain Admins", "FullControl", "ContainerInherit, ObjectInherit", "None", "Allow"
$accessrule = New-Object -Typename System.Security.AccessControl.FileSystemAccessRule -ArgumentList $args
$acl.SetAccessRule($accessrule)

$args = "SCHOOL\Domain Users", "ReadAndExecute", "ContainerInherit, ObjectInherit", "None", "Allow"
$accessrule = New-Object -Typename System.Security.AccessControl.FileSystemAccessRule -ArgumentList $args
$acl.SetAccessRule($accessrule)

Set-Acl -Path "C:\Share\" -AclObject $acl

New-ADOrganizationalUnit -Name "SCHOOL" -Path "DC=SCHOOL,DC=LOCAL" -ProtectedFromAccidentalDeletion $True
New-GPO -Name "User Policies" | New-GPLink -Target "OU=SCHOOL,DC=SCHOOL,DC=LOCAL" -LinkEnabled Yes
Import-GPO -TargetName "User Policies" -BackupGpoName "User Policies" -Path "./Policies"

#Redirect Downloads
Set-GPRegistryValue `
    -Name "User Policies" `
    -Key "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" `
    -ValueName "{374DE290-123F-4565-9164-39C4925E467B}" `
    -Type ExpandString `
    -Value "\\SERVER\Network Users\%USERNAME%\Downloads" `

#Redirect Documents
Set-GPRegistryValue `
    -Name "User Policies" `
    -Key "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" `
    -ValueName "Personal" `
    -Type ExpandString `
    -Value "\\SERVER\Network Users\%USERNAME%\Documents" `

#Redirect Pictures
Set-GPRegistryValue `
    -Name "User Policies" `
    -Key "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" `
    -ValueName "My Pictures" `
    -Type ExpandString `
    -Value "\\SERVER\Network Users\%USERNAME%\Pictures" `

New-ADOrganizationalUnit -Name "CLIENTS" -Path "DC=SCHOOL,DC=LOCAL" -ProtectedFromAccidentalDeletion $True
New-GPO -Name "Computer Policies" | New-GPLink -Target "OU=CLIENTS,DC=SCHOOL,DC=LOCAL" -LinkEnabled Yes
Import-GPO -TargetName "Computer Policies" -BackupGpoName "Computer Policies" -Path "./Policies"

redircmp "OU=CLIENTS,DC=SCHOOL,dc=LOCAL"

ForEach ($User In $Users)
{
    # Create user folder in Network Users for each user
    New-Item `
        -Path "C:\Network Users\" `
        -Name $User.Name `
        -ItemType "directory" `
        -ErrorAction SilentlyContinue `

    # Create Downloads for each user
    New-Item `
        -Path "C:\Network Users\$($User.Name)" `
        -Name  "Downloads" `
        -ItemType "directory" `
        -ErrorAction SilentlyContinue `

    # Create Documents for each user
    New-Item `
        -Path "C:\Network Users\$($User.Name)" `
        -Name  "Documents" `
        -ItemType "directory" `
        -ErrorAction SilentlyContinue `

    # Create Pictures for each user
    New-Item `
        -Path "C:\Network Users\$($User.Name)" `
        -Name  "Pictures" `
        -ItemType "directory" `
        -ErrorAction SilentlyContinue `

    # Create the user
    New-ADUser `
        -Name $User.Name `
        -AccountPassword (ConvertTo-SecureString $User.Password -AsPlainText -Force) `
        -PasswordNeverExpires $True `
        -ChangePasswordAtLogon $False `
        -CannotChangePassword $True `
        -Path "OU=SCHOOL,DC=SCHOOL,DC=LOCAL" `
        -HomeDrive "Z:" `
        -HomeDirectory "\\SERVER\Network Users\$($User.Name)" `
        -Enabled $True `

    # Set Security 
    $acl = Get-Acl -Path "C:\Network Users\$($User.Name)"
    $acl.SetAccessRuleProtection($false, $false)

    $args = "$($User.Name)", "FullControl", "ContainerInherit, ObjectInherit", "None", "Allow"
    $accessrule = New-Object -Typename System.Security.AccessControl.FileSystemAccessRule -ArgumentList $args
    $acl.SetAccessRule($accessrule)

    $args = "Administrator", "FullControl", "ContainerInherit, ObjectInherit", "None", "Allow"
    $accessrule = New-Object -Typename System.Security.AccessControl.FileSystemAccessRule -ArgumentList $args
    $acl.SetAccessRule($accessrule)

    $args = "SCHOOL\Domain Admins", "FullControl", "ContainerInherit, ObjectInherit", "None", "Allow"
    $accessrule = New-Object -Typename System.Security.AccessControl.FileSystemAccessRule -ArgumentList $args
    $acl.SetAccessRule($accessrule)

    Set-Acl -Path "C:\Network Users\$($User.Name)" -AclObject $acl
}
