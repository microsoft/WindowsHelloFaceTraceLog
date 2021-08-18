@echo off
setlocal

PUSHD "%~dp0"

CALL CheckAdmin.cmd || GOTO :EOF

echo.
echo Stopping loggers

logman stop FaceUnlock -ets >nul 2>&1
logman stop FaceCredProv -ets >nul 2>&1
logman stop FaceReco -ets >nul 2>&1
logman stop FaceTel -ets >nul 2>&1
logman stop FaceTracker -ets >nul 2>&1
logman stop FacePerf -ets >nul 2>&1
logman stop BioEnrollment -ets >nul 2>&1
logman stop sds_log -ets >nul 2>&1
logman stop NGCTPMFingerprintCP -ets >nul 2>&1
logman stop LogonUICredFrame -ets >nul 2>&1
logman stop WinBioService -ets >nul 2>&1
logman stop MFTracing -ets >nul 2>&1

del %WINDIR%\System32\LogFiles\WMI\FaceUnlock.etl* >nul 2>&1
del %WINDIR%\System32\LogFiles\WMI\FaceReco.etl* >nul 2>&1
del %WINDIR%\System32\LogFiles\WMI\FaceTel.etl* >nul 2>&1
del %WINDIR%\System32\LogFiles\WMI\FaceTracker.etl* >nul 2>&1
del %WINDIR%\System32\LogFiles\WMI\FacePerf.etl* >nul 2>&1
del %WINDIR%\System32\LogFiles\WMI\BioEnrollment.etl* >nul 2>&1
del %WINDIR%\System32\LogFiles\WMI\sds_log.etl* >nul 2>&1
del %WINDIR%\System32\LogFiles\WMI\NGCTPMFingerprintCP.etl* >nul 2>&1
del %WINDIR%\System32\LogFiles\WMI\LogonUICredFrame.etl* >nul 2>&1
del %WINDIR%\System32\LogFiles\WMI\WinBioService.etl* >nul 2>&1
del %WINDIR%\System32\LogFiles\WMI\MFTracing.etl* >nul 2>&1

reg import .\Config\DisableAllLoggers.reg

echo.
