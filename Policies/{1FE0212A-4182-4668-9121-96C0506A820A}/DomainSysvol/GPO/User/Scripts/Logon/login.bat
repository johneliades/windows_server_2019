:: BEGIN CALLOUT A
If Exist Z:\uniquelogin.txt Goto notlogon
Echo %username% logged in from %computername% > Z:\uniquelogin.txt
:: END CALLOUT A
Goto end
:notlogon
Logoff
:end