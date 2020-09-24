# windows_server_2019

Script for mass user creation on a windows server 2019 with group policy (GPO) restrictions on the clients adequate for use in a school environment.

![Image of website](https://github.com/johneliades/windows_server_2019/blob/master/image.png)

## Notes

The script assumes(for now) that:

* there is a disk with the label C:\ on the server
* the usernames and user passwords are stored in the file users.csv in the given format
* clients must configure dns ip to be the same as server's ip("192.168.1.20" by default)

## Features

* users cannot open:
  * the task manager
  * the registry editor
  * the cmd
  * any windows settings
* users cannot right click on taskbar
* users cannot install or uninstall programs
* users cannot switch user, hibernate, lock, change password
* users do not have access to their C:\ drive
* each user can see their SMB share created remotely on server as their personal space labeled Z:\ that has full access and points to a different folder for each user. All those user folders are by default stored in C:\Network Users\ on the server
* all users see an SMB share labeled K\: that has read access only for teacher to assign homework. The default location is C:\Share on the server
* downloads folder is redirected to a downloads folder in the Z:\ remote drive
* documents folder is redirected to a documents folder in the Z:\ remote drive
* pictures folder is redirected to a pictures folder in the Z:\ remote drive

Notes: 

* The redirections are necessary because any program installed that tries to access downloads documents or pictures would result in an error as C:\ drive is restricted and hidden. Ideally all similar folders should be redirected under Z:\

* All the restrictions are applied using GPO

## Run

- Run the init.ps1 in powershell and then *** REBOOT ***

- Then run the setup.ps1

 After running the 1st script on the server the active directory domain services gets installed and a static ip is assigned on the server accompanied by a school dns server. After running the 2nd script the users are created (as described in the users.csv) with the features described above. After that, any client machine connected in the same domain (school.local by default) should be able to connect to any of those policy restricted users.

Running the cleanup.ps1 should result in reversing the proccess.

## Author

**Eliades John** - *Developer* - [Github](https://github.com/johneliades)
