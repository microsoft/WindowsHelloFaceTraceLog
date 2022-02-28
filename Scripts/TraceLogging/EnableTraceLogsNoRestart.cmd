@echo off
setlocal

PUSHD "%~dp0"

CALL CheckAdmin.cmd || GOTO :EOF

CALL DisableTraceLogs.cmd

REM net stop wbiosrvc >nul 2>&1
REM net stop sensordataservice >nul 2>&1
REM net stop frameserver >nul 2>&1

echo.
echo Enabling Face Unlock, CredFrame, Fingerprint, Tracker, Enrollment, wbiosrvc
echo.
echo Setting Permissions

SET SETACLEXE="SetACL.exe"
%SETACLEXE% -on "HKLM\SYSTEM\CurrentControlSet\Control\WMI\AutoLogger\FaceTracker" -ot reg -actn setowner -ownr "n:builtin\Administrators" >nul 2>&1
%SETACLEXE% -on "HKLM\SYSTEM\CurrentControlSet\Control\WMI\AutoLogger\FaceCredProv" -ot reg -actn setowner -ownr "n:builtin\Administrators" >nul 2>&1
%SETACLEXE% -on "HKLM\SYSTEM\CurrentControlSet\Control\WMI\AutoLogger\FaceReco" -ot reg -actn setowner -ownr "n:builtin\Administrators" >nul 2>&1
%SETACLEXE% -on "HKLM\SYSTEM\CurrentControlSet\Control\WMI\AutoLogger\FaceTel" -ot reg -actn setowner -ownr "n:builtin\Administrators" >nul 2>&1
%SETACLEXE% -on "HKLM\SYSTEM\CurrentControlSet\Control\WMI\AutoLogger\FacePerf" -ot reg -actn setowner -ownr "n:builtin\Administrators" >nul 2>&1
%SETACLEXE% -on "HKLM\SYSTEM\CurrentControlSet\Control\WMI\AutoLogger\BioEnrollment" -ot reg -actn setowner -ownr "n:builtin\Administrators" >nul 2>&1
%SETACLEXE% -on "HKLM\SYSTEM\CurrentControlSet\Control\WMI\AutoLogger\sds_log" -ot reg -actn setowner -ownr "n:builtin\Administrators" >nul 2>&1
%SETACLEXE% -on "HKLM\SYSTEM\CurrentControlSet\Control\WMI\AutoLogger\NGCTPMFingerprintCP" -ot reg -actn setowner -ownr "n:builtin\Administrators" >nul 2>&1
%SETACLEXE% -on "HKLM\SYSTEM\CurrentControlSet\Control\WMI\AutoLogger\LogonUICredFrame" -ot reg -actn setowner -ownr "n:builtin\Administrators" >nul 2>&1
%SETACLEXE% -on "HKLM\SYSTEM\CurrentControlSet\Control\WMI\AutoLogger\WinBioService" -ot reg -actn setowner -ownr "n:builtin\Administrators" >nul 2>&1
%SETACLEXE% -on "HKLM\SYSTEM\CurrentControlSet\Control\WMI\AutoLogger\MFTracing" -ot reg -actn setowner -ownr "n:builtin\Administrators" >nul 2>&1

echo.
echo Importing Logging Registry Entries
echo.
reg import .\Config\FaceTracker.reg
reg import .\Config\FaceUnlock.reg
reg import .\Config\FaceReco.reg
reg import .\Config\FaceTel.reg
reg import .\Config\FacePerf.reg
reg import .\Config\BioEnrollment.reg
reg import .\Config\sds_log.reg
reg import .\Config\NGCTPMFingerprintCP.reg
reg import .\Config\LogonUICredFrame.reg
reg import .\Config\WinBioService.reg
reg import .\Config\MFTracing.reg

echo.
echo Starting Loggers
echo.

cd

logman import FaceReco -xml .\Config\FaceReco.xml -ets
logman import FaceTel -xml .\Config\FaceTel.xml -ets
logman import FaceTracker -xml .\Config\FaceTracker.xml -ets
logman import FaceUnlock -xml .\Config\FaceUnlock.xml -ets
logman import FacePerf -xml .\Config\FacePerf.xml -ets
logman import BioEnrollment -xml .\Config\BioEnrollment.xml -ets
logman import sds_log -xml .\Config\sds_log.xml -ets
logman import NGCTPMFingerprintCP -xml .\Config\NGCTPMFingerprintCP.xml -ets
logman import LogonUICredFrame -xml .\Config\LogonUICredFrame.xml -ets
logman import WinBioService -xml .\Config\WinBioService.xml -ets
logman import MFTracing -xml .\Config\MFTracing.xml -ets

echo.
