@echo off
setlocal

PUSHD "%~dp0"

CALL CheckAdmin.cmd || goto :EOF

echo.
echo Start dxdiag logs ...
set DXDIAG_LOG="%TEMP%\dxdiag.txt"
start dxdiag /whql:off /t %TEMP%\dxdiag.txt>nul 2>&1

if not "%1"=="" set OUTPUTLOCATION=%1

set LOG_FOLDER=%OUTPUTLOCATION%\%computername%-%username%
if not exist %LOG_FOLDER% mkdir %LOG_FOLDER%

set DATE_FOLDER=%date:~-4%%date:~4,2%%date:~7,2%%time:~0,2%%time:~3,2%%time:~6,2%
set DATE_FOLDER=%DATE_FOLDER: =0%
set OUTPUT_FOLDER=%LOG_FOLDER%\%DATE_FOLDER%
mkdir "%OUTPUT_FOLDER%"

tasklist /svc > "%OUTPUT_FOLDER%\TList.txt"

echo.
echo Flushing trace logs
echo.

net stop wbiosrvc >nul 2>&1
net stop sensordataservice >nul 2>&1
net stop frameserver >nul 2>&1

logman stop FaceTracker -ets >nul 2>&1
logman stop FaceUnlock -ets >nul 2>&1
logman stop FaceCredProv -ets >nul 2>&1
logman stop FaceReco -ets >nul 2>&1
logman stop FaceTel -ets >nul 2>&1
logman stop FacePerf -ets >nul 2>&1
logman stop BioEnrollment -ets >nul 2>&1
logman stop sds_log -ets >nul 2>&1
logman stop NGCTPMFingerprintCP -ets >nul 2>&1
logman stop LogonUICredFrame -ets >nul 2>&1
logman stop WinBioService -ets >nul 2>&1

REM sleep for 2 seconds
ping 127.0.0.1 -n 10 -w 200 > nul 2>&1

echo.
echo Exporting authux registry key
echo.

REG EXPORT HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication %HOMEDRIVE%\credprovs.reg /y

echo Copying logs files from %WINDIR%\system32\LogFiles\WMI to %OUTPUT_FOLDER%
echo.
copy "%WINDIR%\Logs\CBS\*.*" "%OUTPUT_FOLDER%"\
copy "%WINDIR%\system32\LogFiles\WMI\FaceUnlock.*" "%OUTPUT_FOLDER%"\
copy "%WINDIR%\system32\LogFiles\WMI\FaceReco.*" "%OUTPUT_FOLDER%"\
copy "%WINDIR%\system32\LogFiles\WMI\FaceTel.*" "%OUTPUT_FOLDER%"\
copy "%WINDIR%\system32\LogFiles\WMI\FaceTracker.*" "%OUTPUT_FOLDER%"\
copy "%WINDIR%\system32\LogFiles\WMI\FacePerf.*" "%OUTPUT_FOLDER%"\
copy "%WINDIR%\system32\LogFiles\WMI\BioEnrollment.*" "%OUTPUT_FOLDER%"\
copy "%WINDIR%\system32\LogFiles\WMI\sds_log.*" "%OUTPUT_FOLDER%"\
copy "%WINDIR%\system32\LogFiles\WMI\NGCTPMFingerprintCP.*" "%OUTPUT_FOLDER%"\
copy "%WINDIR%\system32\LogFiles\WMI\LogonUICredFrame.*" "%OUTPUT_FOLDER%"\
copy "%WINDIR%\system32\LogFiles\WMI\WinBioService.*" "%OUTPUT_FOLDER%"\
copy "%WINDIR%\Analog\Providers\ProviderLogOutput.txt" "%OUTPUT_FOLDER%"\ >nul 2>&1

del %WINDIR%\System32\LogFiles\WMI\FaceTracker.etl* >nul 2>&1
del %WINDIR%\System32\LogFiles\WMI\FaceCredProv.etl* >nul 2>&1
del %WINDIR%\System32\LogFiles\WMI\FaceUnlock.etl* >nul 2>&1
del %WINDIR%\System32\LogFiles\WMI\FaceReco.etl* >nul 2>&1
del %WINDIR%\System32\LogFiles\WMI\FaceTel.etl* >nul 2>&1
del %WINDIR%\System32\LogFiles\WMI\FacePerf.etl* >nul 2>&1
del %WINDIR%\System32\LogFiles\WMI\BioEnrollment.etl* >nul 2>&1
del %WINDIR%\System32\LogFiles\WMI\sds_log.etl* >nul 2>&1
del %WINDIR%\System32\LogFiles\WMI\NGCTPMFingerprintCP.etl* >nul 2>&1
del %WINDIR%\System32\LogFiles\WMI\LogonUICredFrame.etl* >nul 2>&1
del %WINDIR%\System32\LogFiles\WMI\WinBioService.etl* >nul 2>&1

echo.
ECHO Copying winbio.evtx
CALL wevtutil epl Microsoft-Windows-Biometrics/Operational "%OUTPUT_FOLDER%\winbio.evtx

echo.
ECHO Capturing environment information
set ENV_LOG="%OUTPUT_FOLDER%\CaptureEnvironment.txt"
CALL cmd /c CaptureEnvironment.cmd > %ENV_LOG% 2>&1

echo.
ECHO Capturing windows application error events, this may take a while ...
set ERROR_LOG="%OUTPUT_FOLDER%\ErrorEvents.txt"
CALL powershell -ExecutionPolicy Unrestricted -File dumpErrorEvents.ps1 > %ERROR_LOG% 2>&1

echo.
echo Copying dxdiag.txt ...
move /y %TEMP%\dxdiag.txt "%OUTPUT_FOLDER%"\

echo.
echo Copying driver installation logs ...
copy /y "%WINDIR%\INF\setupapi.dev.log" "%OUTPUT_FOLDER%"\

echo.
echo Eport PNP state.. may take a while...
pnputil.exe /export-pnpstate %OUTPUT_FOLDER%\pnpstate.pnp

echo.
echo Resetting the logging ...
CALL cmd /c EnableTraceLogs.cmd >nul 2>&1

echo.
echo Find your uploaded logs at %OUTPUT_FOLDER%
echo.

REM remove the outputdirname.txt file for sanity check
if exist OutputDirName.txt (
	del OutputDirName.txt
)
echo %OUTPUT_FOLDER% > OutputDirName.txt
echo "Thank you!"

if "%2"=="" pause
POPD
