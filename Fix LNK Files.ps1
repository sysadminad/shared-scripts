#Create new PSDrive
New-PSDrive -PSProvider Registry -Name HKU -Root HKEY_USERS

#Define All User Profile location
$allprogsm = "$env:ALLUSERSPROFILE\microsoft\windows\start menu\programs"

#Fix All User Profile by consolidated source
$consource = "" #Define path to lnk source
$shortcuts = Get-childitem $consource -Filter *.lnk -Recurse

#Loop through each shortcut
ForEach($shortcut in $shortcuts)
{
    #Define the shortcut path
    $shortcutpath = $shortcut.FullName
    #Create a new object for the WScript.Shell com object
    $sh = New-Object -ComObject WScript.Shell
    $directoryname = $shortcut.DirectoryName
    $target = $sh.CreateShortcut("$shortcutpath").TargetPath
    #Check if the target path exists
    write-host "Checking: $directoryname"

    If($target -ne $null -and $target -ne "")
    {

    If(Test-path $target)
    {
        #Replace the source path with the target path
        $newpath = $directoryname.replace("$consource","C:\ProgramData\Microsoft\Windows\Start Menu\Programs")
        #Copy the shortcut to the new location
        write-host "Found path $target, copying $shortcutpath to $newpath"
        try{copy-item -path $shortcutpath -destination "$newpath" -Force}catch{}
    }
    }
}

#Fix User Taskbar
$sid = (Get-ItemProperty -path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI"  -ErrorAction SilentlyContinue)."SelectedUserSID"
$ByteArrayFromRegistry = (Get-ItemProperty -Path "HKU:\$SID\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Taskband" -ErrorAction SilentlyContinue)."FavoritesResolve"

$ascii0 = [char]0
$taskband = ($ByteArrayFromRegistry | ForEach{ [char]$_ }) -join "" -replace $ascii0 
$newtaskband = $taskband.Replace("OSDisk","~")
$taskbandarr = $newtaskband.Split("~")
$taskbandarr = $taskbandarr.Split("``")

#loop through each line of the taskbar
ForEach($line in $taskbandarr)
{
    #Check if line is a shortcut
    If($line -like '*.lnk')
    {
        #Check if the file path exists
        If(!(Test-Path $line))
        {
            #Define missing file name and the path of the shortcut
            $missingfile = $line.Split("\")[10]
            $lnkpath = $line.Replace("\$missingfile","")
            write-host "$missingfile"
            write-host "$lnkpath"
            #Get the missing file
            $shortcuts = Get-childitem $consource -Filter $missingfile -Recurse
            #Loop through the missing files
            ForEach($shortcut in $shortcuts)
            {
                $shortcutpath = $shortcut.FullName
                #Copy the file
                try{copy-item -path $shortcutpath}catch{}
            }
    }

    }
}
