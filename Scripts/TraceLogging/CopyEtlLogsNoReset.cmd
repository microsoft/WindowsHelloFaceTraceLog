@echo off
setlocal

set _dir=%~dp0

CALL %_dir%\CheckAdmin.cmd || goto :EOF

echo.
echo Start dxdiag logs ...
set DXDIAG_LOG="%TEMP%\dxdiag.txt"
start dxdiag /whql:off /t %TEMP%\dxdiag.txt>nul 2>&1

echo.
echo Flushing trace logs
echo.

net stop wbiosrvc >nul 2>&1
net stop sensordataservice >nul 2>&1
net stop frameserver >nul 2>&1

logman stop FaceUnlock -ets >nul 2>&1
logman stop FaceCredProv -ets >nul 2>&1
logman stop FaceReco -ets >nul 2>&1
logman stop FaceRecoTel -ets >nul 2>&1
logman stop FacePerf -ets >nul 2>&1
logman stop BioEnrollment -ets >nul 2>&1
logman stop sds_log -ets >nul 2>&1
logman stop NGC -ets >nul 2>&1
logman stop TPM -ets >nul 2>&1
logman stop WinBioService -ets >nul 2>&1
logman stop WinLogon -ets >nul 2>&1
logman stop MFTracing -ets >nul 2>&1

REM sleep for 10 seconds
ping 127.0.0.1 -n 10 -w 1000 > nul 2>&1

set LOG_FOLDER=\\nuiface\Hello\ETLLogs\%computername%-%username%
if not exist %LOG_FOLDER% mkdir %LOG_FOLDER%

set DATE_FOLDER=%date:~-4%%date:~4,2%%date:~7,2%%time:~0,2%%time:~3,2%%time:~6,2%
set OUTPUT_FOLDER=%LOG_FOLDER%\%DATE_FOLDER%
mkdir "%OUTPUT_FOLDER%"

echo.
echo Copying logs files from %WINDIR%\system32\Logs\WMI to %OUTPUT_FOLDER%
echo.
move "%WINDIR%\system32\LogFiles\WMI\OldFaceLogFiles" "%OUTPUT_FOLDER%"\
copy "%WINDIR%\system32\LogFiles\WMI\FaceUnlock.*" "%OUTPUT_FOLDER%"\
copy "%WINDIR%\system32\LogFiles\WMI\FaceReco.*" "%OUTPUT_FOLDER%"\
copy "%WINDIR%\system32\LogFiles\WMI\FaceRecoTel.*" "%OUTPUT_FOLDER%"\
copy "%WINDIR%\system32\LogFiles\WMI\FacePerf.*" "%OUTPUT_FOLDER%"\
copy "%WINDIR%\system32\LogFiles\WMI\BioEnrollment.*" "%OUTPUT_FOLDER%"\
copy "%WINDIR%\system32\LogFiles\WMI\sds_log.*" "%OUTPUT_FOLDER%"\
copy "%WINDIR%\system32\LogFiles\WMI\NGC.*" "%OUTPUT_FOLDER%"\
copy "%WINDIR%\system32\LogFiles\WMI\TPM.*" "%OUTPUT_FOLDER%"\
copy "%WINDIR%\system32\LogFiles\WMI\WinBioService.*" "%OUTPUT_FOLDER%"\
copy "%WINDIR%\system32\LogFiles\WMI\WinLogon.*" "%OUTPUT_FOLDER%"\
copy "%WINDIR%\Analog\Providers\ProviderLogOutput.txt" "%OUTPUT_FOLDER%"\ >nul 2>&1
copy "%WINDIR%\system32\LogFiles\WMI\MFTracing.*" "%OUTPUT_FOLDER%"\

del %WINDIR%\System32\LogFiles\WMI\FaceUnlock.etl* >nul 2>&1
del %WINDIR%\System32\LogFiles\WMI\FaceReco.etl* >nul 2>&1
del %WINDIR%\System32\LogFiles\WMI\FaceRecoTel.etl* >nul 2>&1
del %WINDIR%\System32\LogFiles\WMI\FacePerf.etl* >nul 2>&1
del %WINDIR%\System32\LogFiles\WMI\BioEnrollment.etl* >nul 2>&1
del %WINDIR%\System32\LogFiles\WMI\sds_log.etl* >nul 2>&1
del %WINDIR%\System32\LogFiles\WMI\NGC.etl* >nul 2>&1
del %WINDIR%\System32\LogFiles\WMI\TPM.etl* >nul 2>&1
del %WINDIR%\System32\LogFiles\WMI\WinBioService.etl* >nul 2>&1
del %WINDIR%\System32\LogFiles\WMI\WinLogon.etl* >nul 2>&1
del %WINDIR%\System32\LogFiles\WMI\MFTracing.etl* >nul 2>&1

echo.
ECHO Copying winbio.evtx
CALL wevtutil epl Microsoft-Windows-Biometrics/Operational "%OUTPUT_FOLDER%\winbio.evtx

echo.
ECHO Capturing environment information
set ENV_LOG="%OUTPUT_FOLDER%\CaptureEnvironment.txt"
CALL %_dir%\CaptureEnvironment.cmd > %ENV_LOG% 2>&1

echo.
ECHO Capturing windows application error events, this may take a while ...
set ERROR_LOG="%OUTPUT_FOLDER%\ErrorEvents.txt"
CALL powershell -ExecutionPolicy Unrestricted -File dumpErrorEvents.ps1 > %ERROR_LOG% 2>&1

echo.
ECHO Resuming trace logging
echo.

logman import FaceCredProv -xml FaceUnlock.xml -ets
logman import FaceReco -xml FaceReco.xml -ets
logman import FaceRecoTel -xml FaceRecoTel.xml -ets
logman import FacePerf -xml FacePerf.xml -ets
logman import BioEnrollment -xml BioEnrollment.xml -ets
logman import sds_log -xml sds_log.xml -ets
logman import NGC -xml NGC.xml -ets
logman import TPM -xml TPM.xml -ets
logman import WinBioService -xml WinBioService.xml -ets
logman import WinLogon -xml WinLogon.xml -ets
logman import MFTracing -xml MFTracing.xml -ets

echo.
echo Copying dxdiag.txt ...
move /y %TEMP%\dxdiag.txt "%OUTPUT_FOLDER%"\

echo.
echo Resetting the logging ...
rem call %_dir%\EnableTraceLogs.cmd >nul 2>&1

echo.
echo Find your uploaded logs at %OUTPUT_FOLDER%
echo.

pause