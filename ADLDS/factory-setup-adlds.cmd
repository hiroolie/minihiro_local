setlocal enabledelayedexpansion
 
set opt_insecure=0
 
for %%i in (%*) do (
        if %%i equ insecure set opt_insecure=1
)
 
rem === create set-defaultnamingcontext.ldf
echo dn: CN=NTDS Settings,CN=%COMPUTERNAME%$NFSInstance,CN=Servers,CN=Default-First-Site-Name,CN=Sites,CN=Configuration,DC=X>set-defaultnamingcontext.ldf
echo changetype: modify>>set-defaultnamingcontext.ldf
echo replace: msDS-DefaultNamingContext>>set-defaultnamingcontext.ldf
echo msDS-DefaultNamingContext: CN=nfs,DC=nfs>>set-defaultnamingcontext.ldf
echo ->>set-defaultnamingcontext.ldf
 
rem === Install the ADAM role
start /w servermanagercmd -i FS-NFS-Services
start /w servermanagercmd -i ADLDS
 
rem === Create a ADAM instance for use by Services for NFS named NFSInstance
%systemroot%\ADAM\adaminstall.exe /answer:nfs-instance-answer.txt
 
rem === Set the default naming context
ldifde -i -f set-defaultnamingcontext.ldf -s localhost:389 -c "cn=Configuration,dc=X" #configurationNamingContext
 
rem === Extend the schema to add the uidNumber/gidNumber attributes to the user
rem === class and the gidNumber attribute to the group class
ldifde -i -f add-uidnumber-gidnumber.ldf -s localhost:389 -c "cn=Configuration,dc=X" #configurationNamingContext
 
rem === Add Users container object
ldifde -i -f add-users-container.ldf -s localhost:389
 
rem === Provide read access to the NFS instance
dsacls \\localhost:389\CN=nfs,DC=nfs /G everyone:GR /I:T
 
if "!opt_insecure!" equ "1" (
        dsacls \\\\localhost:389\\CN=nfs,DC=nfs /G "anonymous logon":GR /I:T
        ldifde -i -f change-dsheuristics.ldf -s localhost:389 -j . -c "cn=Configuration,dc=X" #configurationNamingContext
)
 
rem === Configure the Services for NFS mapping source to use ADAM
nfsadmin mapping config adlookup=yes addomain=%COMPUTERNAME%:389
 
rem === Cleanup generated file
del set-defaultnamingcontext.ldf