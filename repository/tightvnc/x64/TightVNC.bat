:: Purpose:       Installs a package
:: Requirements:  Run this script with Administrator rights
:: Author:        vocatus on reddit.com/r/sysadmin ( vocatus.gate@gmail.com ) // PGP key ID: 0x07d1490f82a211a2
:: History:       1.0.0 + Initial write


::::::::::
:: Prep :: -- Don't change anything in this section
::::::::::
@echo off
set SCRIPT_VERSION=1.0.0
set SCRIPT_UPDATED=2014-07-25
:: Get the date into ISO 8601 standard date format (yyyy-mm-dd) so we can use it
FOR /f %%a in ('WMIC OS GET LocalDateTime ^| find "."') DO set DTS=%%a
set CUR_DATE=%DTS:~0,4%-%DTS:~4,2%-%DTS:~6,2%

:: This is useful if we start from a network share; converts CWD to a drive letter
pushd "%~dp0"
cls


:::::::::::::::
:: VARIABLES :: -- Set these to your desired values
:::::::::::::::
:: Log location and name. Do not use trailing slashes (\)
set LOGPATH=%SystemDrive%\Logs
set LOGFILE=

:: Package to install. Do not use trailing slashes (\)
set LOCATION=
set BINARY=TightVNC v2.7.10 x64.msi
set FLAGS=/quiet /norestart ADDLOCAL="Server,Viewer"

:: Create the log directory if it doesn't exist
if not exist %LOGPATH% mkdir %LOGPATH%


::::::::::::::::::
:: INSTALLATION ::
::::::::::::::::::
:: This line uninstalls any prior version
"%ProgramFiles%\TightVNC\uninstall.exe" /S >NUL
"%ProgramFiles(x86)%\TightVNC\uninstall.exe" /S >NUL

:: Stop any running servers
"%ProgramFiles%\TightVNC\tvnserver.exe" -stop -silent

:: Delay to let it finish
ping 127.0.0.1 -n 2

:: Install the new version
msiexec.exe /i "%BINARY%" %FLAGS%

:: Install the new server/listener, and then stops it so we can import the settings file
"%ProgramFiles%\TightVNC\tvnserver.exe" -stop -silent
"%ProgramFiles%\TightVNC\tvnserver.exe" -install -silent
"%ProgramFiles%\TightVNC\tvnserver.exe" -stop -silent

:: This line imports the new settings
regedit /s "TightVNC settings.reg"

:: This line starts the server back up
"%ProgramFiles%\TightVNC\tvnserver.exe" -start -silent

:::::::::::::
:: CLEANUP ::
:::::::::::::
:: 64-bit
if exist "%ProgramFiles%\TightVNC\TightVNC Web Site.url" del "%ProgramFiles%\TightVNC\TightVNC Web Site.url"
if exist "%ProgramFiles%\TightVNC\LICENSE.txt" del "%ProgramFiles%\TightVNC\LICENSE.txt"

:: 32-bit
if exist "%ProgramFiles(x86)%\TightVNC\TightVNC Web Site.url" del "%ProgramFiles(x86)%\TightVNC\TightVNC Web Site.url"
if exist "%ProgramFiles(x86)%\TightVNC\LICENSE.txt" del "%ProgramFiles(x86)%\TightVNC\LICENSE.txt"

:: Start menu shortcuts. Comment these lines out if you want to keep start menu shortcuts
if exist "%ProgramData%\Microsoft\Windows\Start Menu\Programs\TightVNC\" rmdir /s /q "%ProgramData%\Microsoft\Windows\Start Menu\Programs\TightVNC\"
if exist "%AllUsersProfile%\Start Menu\Programs\TightVNC\" rmdir /s /q "%AllUsersProfile%\Start Menu\Programs\TightVNC\"

:: Pop back to original directory. This isn't necessary in stand-alone runs of the script, but is needed when being called from another script
popd

:: Return exit code to SCCM/PDQ Deploy/etc
exit /B %EXIT_CODE%