@echo off

rem Check for administrator privileges
if "%PROCESSOR_ARCHITECTURE%"=="x86" if not "%PROCESSOR_ARCHITEW6432%"=="" goto :UAC_CHECK
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" goto :UAC_CHECK
:UAC_FAIL
echo Requesting administrative privileges...
goto :UAC_FAIL

:UAC_CHECK
net session >nul 2>&1
if %errorlevel% == 0 (
    goto :UAC_SUCCESS
) else (
    goto :UAC_FAIL
)

:UAC_SUCCESS

rem Clear the browser cache
del /f /q %temp%\*.*

rem Clear the Windows Update cache
net stop wuauserv
net stop cryptsvc
del /f /s /q %windir%\SoftwareDistribution\Download\*.*
del /f /s /q %windir%\system32\catroot2\*.*
net start cryptsvc
net start wuauserv

rem Clear the Windows Store cache
powershell -Command "Get-AppxPackage -AllUsers | Remove-AppxPackage"
powershell -Command "Get-AppxProvisionedPackage -online | Remove-AppxProvisionedPackage -online"

rem Clear the Windows Defender cache
powershell -Command "Start-MpWDOScan -ScanType 3"

rem Clear the OneDrive cache
rd %userprofile%\OneDrive\ /s /q

rem Clear the recycle bin
rd /s /q C:\$Recycle.bin

rem update all apps
powershell (Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall* | Get-ItemProperty).DisplayName | %{& "$env:windir\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -Command "$_.Update()"}

echo Cache cleared and all apps updated successfully.
pause
