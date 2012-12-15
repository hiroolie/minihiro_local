var passwdFilename, groupFilename;
var passwdFile, groupFile;
var pStr, gStr;
var pLines, gLines;
var pFields, gFields;
var executeCommands = false;
var temptest;

var fso = new ActiveXObject ("Scripting.FileSystemObject");




args = WScript.Arguments;

namedArgs = WScript.Arguments.Named;


//passwdFilename = namedArgs.Item("passwd");
//groupFilename = namedArgs.Item("group");
//ldifFilename = namedArgs.Item("ldf");
//usercmdFilename = namedArgs.Item("usercmd");
//logFilename = namedArgs.Item("log");
//userPassword = namedArgs.Item("userpassword");

passwdFilename = "passwd";
groupFilename = "group";
ldifFilename = "users.ldf";
usercmdFilename = "create-local-users-groups.cmd";
logFilename = "configure-adlds.txt";
userPassword = namedArgs.Item("userpassword");


for (i = 0; i < args.length; i++)
    {
    if (args(i) == "/execute")
        executeCommands = true;
    }



function Print (x)
    {
    WScript.Echo (x);
    }



function Usage ()
    {
    Print (WScript.ScriptName + " /passwd:passwdfile /group:groupfile /ldf:out.ldf\n" +
           "    /usercmd:generateusers.cmd [/execute] [/log:logname]\n" +
           "\n" +
           "/passwd       - location of passwd file\n" +
           "/group        - location of group file\n" +
           "/ldf          - output generated ldf file\n" +
           "/usercmd      - output cmd file to generate local users and groups\n" +
           "/userpassword - provide a password to be used for all user accounts created\n" +
           "/execute      - import user objects to ADAM using the generated files\n" +
           "/log          - specify a filename to log operations\n" +
           "\n" +
           "Both /passwd and /group must be specified.\n" +
           "At least one of /ldf or /usercmd must be specified.\n" +
           "If /userpassword is not specified all local accounts created must have\n" +
           "passwords set manually before NFS mapping will succeed.\n");
    Print("passwd=" + passwdFilename)
    Print("groupFilename=" + groupFilename)
    Print("ldifFilename=" + ldifFilename)
    Print("usercmdFilename=" + usercmdFilename)
    Print("logFilename=" + logFilename)
    Print("temptest=" + temptest)
    }


function ValidatePasswdGroup ()
    {
    var i, j;

    for (i = 0; i < pLines.length; i++)
        {
        pFields = pLines[i].split(":");

        if (0 == pFields[0].length)
            continue;

        for (j = 0; j < gLines.length; j++)
            {
            gFields = gLines[j].split(":");

            if (0 == gFields[0].length)
                continue;

            if (pFields[0] == gFields[0])
                {
                Print ("The name " + pFields[0] + " occurs in both passwd and group files\n\n");

                return false;
                }
            }
        }

    return true;
    }


function GenerateLdif (s)
    {
    var i;

    for (i = 0; i < pLines.length; i++)
        {
        pFields = pLines[i].split(":");

        if (0 == pFields[0].length)
            continue;

        s.Write ("dn: CN=" + pFields[0] + ",CN=Users,CN=nfs,DC=nfs\n");
        s.Write ("changetype: add\n");
        s.Write ("cn: " + pFields[0] + "\n");
        s.Write ("objectClass: user\n");
        s.Write ("uidNumber: " + pFields[2] + "\n");
        s.Write ("gidNumber: " + pFields[3] + "\n");
        s.Write ("sAMAccountName: " + pFields[0] + "\n");
        s.Write ("\n");
        }

    for (i = 0; i < gLines.length; i++)
        {
        gFields = gLines[i].split(":");

        if (0 == gFields[0].length)
            continue;

        s.Write ("dn: CN=" + gFields[0] + ",CN=Users,CN=nfs,DC=nfs\n");
        s.Write ("changetype: add\n");
        s.Write ("cn: " + gFields[0] + "\n");
        s.Write ("objectClass: group\n");
        s.Write ("gidNumber: " + gFields[2] + "\n");
        s.Write ("sAMAccountName: " + gFields[0] + "\n");
        s.Write ("\n");
        }
    }


function GenerateUserGroupCmd (s)
    {
    var i, j;

    if (!userPassword || 0 == userPassword.length)
        {
        Print ("WARNING: No /userpassword option was specified, after local accounts\n" +
               "are created, passwords must be set on these accounts manually before\n" +
               "they can be used for ADLDS mapping for NFS components.\n");
        }


    //
    // Create local groups based on group file
    //
    for (i = 0; i < gLines.length; i++)
        {
        gFields = gLines[i].split(":");

        if (0 == gFields[0].length)
            continue;

        s.Write ("net localgroup " + gFields[0] +
                 " /add /comment:\"Group for GID:" + gFields[2] + "\"\n");
        }
    s.Write ("\n");


    //
    // Create local users from passwd file
    //
    for (i = 0; i < pLines.length; i++)
        {
        pFields = pLines[i].split(":");

        if (0 == pFields[0].length)
            continue;

        if (userPassword && 0 != userPassword.length)
            {
            s.Write ("net user " + pFields[0] + " /add /comment:\"User for UID:" +
                     pFields[2] + " GID:" + pFields[3] + "\" && net user " + pFields[0] + " " + userPassword + "\n");
            }
        else
            {
            s.Write ("net user " + pFields[0] + " /add /comment:\"User for UID:" +
                     pFields[2] + " GID:" + pFields[3] + "\"\n");
            }

        //
        // Add users to their primary groups
        //
        for (j = 0; j < gLines.length; j++)
            {
            gFields = gLines[j].split(":");

            if (0 == gFields[0].length)
                continue;

            if (gFields[2] == pFields[3])
                {
                s.Write ("net localgroup " + gFields[0] + " " + pFields[0] +
                         " /add\n");
                }
            }

        s.Write ("\n");
        }
    s.Write ("\n");


    //
    // Add users to supplementary groups
    //
    for (i = 0; i < gLines.length; i++)
        {
        gFields = gLines[i].split(":");

        if (4 == gFields.length && 0 != gFields[3].length)
            {
            supUsers = gFields[3].split(",");

            for (j = 0; j < supUsers.length; j++)
                {
                s.Write ("net localgroup " + gFields[0] + " " + supUsers[j] + " /add\n");
                }
            }
        }
    s.Write ("\n");
    }






if (!passwdFilename || !groupFilename ||
    (!ldifFilename && !usercmdFilename))
    {
    Usage ();
    }
else
    {
    passwdFile = fso.OpenTextFile (passwdFilename, 1);
    groupFile = fso.OpenTextFile (groupFilename, 1);

    pStr = passwdFile.ReadAll ();
    gStr = groupFile.ReadAll ();

    passwdFile.Close ();
    groupFile.Close ();

    pLines = pStr.split ("\n");
    gLines = gStr.split ("\n");


    if (!ValidatePasswdGroup ())
        {
        Print ("error: passwd and group files must not have names that overlap\n" +
               "       Please edit the files to create unique names.\n");
        }
    else
        {
        if (ldifFilename)
            {
            ldifS = fso.OpenTextFile (ldifFilename, 2, true);

            GenerateLdif (ldifS);

            ldifS.Close ();
            }


        if (usercmdFilename)
            {
            usercmdS = fso.OpenTextFile (usercmdFilename, 2, true);

            GenerateUserGroupCmd (usercmdS);

            usercmdS.Close ();
            }

        if (executeCommands)
            {
            var oShell = WScript.CreateObject("WScript.Shell");
            var command = "cmd /k ";

            if (ldifFilename)
                {
                command = command + "echo Importing user objects & ldifde -i -f " + ldifFilename + " -s localhost:389 ";

                if (logFilename)
                    {
                    command = command + ">>" + logFilename + " 2>&1 ";
                    }

                command = command + "& echo command complete ";

                if (usercmdFilename)
                    {
                    command = command + "& ";
                    }
                }

            if (usercmdFilename)
                {
                command = command + "echo Creating local users & " + usercmdFilename + " ";

                if (logFilename)
                    {
                    command = command + ">>" + logFilename + " 2>&1 ";
                    }

                command = command + "& echo command complete ";
                }

            oShell.Run (command);
            }
        }

    }