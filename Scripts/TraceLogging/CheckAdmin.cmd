@echo off

:::::::::::::::::::::::::::
:: Check for permissions
:::::::::::::::::::::::::::
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

:::::::::::::::::::::::::::
:: If error flag set, we do not have admin.
:::::::::::::::::::::::::::
if '%errorlevel%' NEQ '0' (
    echo You must run this in a command window with ADMINISTRATOR privileges.
    exit /b 1
)
