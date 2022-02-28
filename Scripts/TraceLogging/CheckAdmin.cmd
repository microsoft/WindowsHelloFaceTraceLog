@echo off

:::::::::::::::::::::::::::
:: Checks if the user has administrator privileges.
:::::::::::::::::::::::::::
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

:::::::::::::::::::::::::::
:: If error flag set, the user does not have admin privileges.
:::::::::::::::::::::::::::
if '%errorlevel%' NEQ '0' (
    echo You must run this script in a command window with ADMINISTRATOR privileges.
    pause
    exit /b 1
)
