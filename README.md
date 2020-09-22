# windows_server_2019

Script for mass user creation on a windows server 2019 with group policy (GPO) restrictions on the clients adequate for use in a school environment.

## Notes

The script assumes that (for now):

* a forest is already created with the name school.local
* there is a disk with the label C:\ on the server
* the server computer is named "SERVER"
* the usernames and user passwords are stored in the file users.csv in the given format
* the active directory domain services is installed from the server manager

## Features



## Run

Running the setup.ps1 in a powershell on the server would result in the users' creation (as described in the users.csv) with the features described above. After that, any client machine connected in the same domain(school.local) should be able to connect to any of those restricted users.

Running the cleanup.ps1 should result in reversin the proccess.

## Author

**Eliades John** - *Developer* - [Github](https://github.com/johneliades)
