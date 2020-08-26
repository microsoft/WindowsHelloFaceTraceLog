@echo off
setlocal

PUSHD "%~dp0"
call CopyEtlLogs.cmd %userprofile%\desktop
POPD

endlocal