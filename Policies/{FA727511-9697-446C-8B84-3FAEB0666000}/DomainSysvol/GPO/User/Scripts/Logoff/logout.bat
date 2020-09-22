:: BEGIN CALLOUT A
If Not Exist Z:\uniquelogin.txt goto notlogon
Del Z:\uniquelogin.txt
:: END CALLOUT A
Goto end
:notlogon
Logoff
:end