@echo off

::Recursively delete files older than 7 days
FORFILES /D -7 /M *.* /P "\\nuiface\Hello\BVTTestLogs" /S /C "cmd /c del /f /q @path

::Recursively delete folders older than 7 days
FORFILES /D -7 /P "\\nuiface\Hello\BVTTestLogs" /C "cmd /c IF @isdir == TRUE rd /S /Q @path"