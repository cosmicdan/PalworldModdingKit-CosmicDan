@ECHO OFF
SETLOCAL
IF NOT "%1" == "silent" (
    TITLE _compile_pmk
    echo This script will compile the entire project for Win64 [creating pak files].
    echo.
    echo Press any key to start.
    echo.
    PAUSE > NUL
)

IF EXIST "%~dp0\_setenv.cmd" (
    echo [#] Reading _setenv.cmd ...
    CALL "%~dp0\_setenv.cmd" IsSafeToRun
) ELSE (
    echo [#] Reading _setenv.default.cmd [no _setenv.cmd found] ...
    CALL "%~dp0\_setenv.default.cmd" IsSafeToRun
)
:: do env verification 
IF NOT EXIST "%UDK_RUNUAT_PATH%" (
    echo [!] setenv is incorrect, could not find file/dir:
    echo     "%UDK_RUNUAT_PATH%"
    echo.
    echo Fix it! Press any key to exit.
    pause > nul
    exit /B
)

echo [#] Starting compile...

CALL "%UDK_RUNUAT_PATH%" BuildCookRun -project="%~dp0\..\Pal.uproject" -noP4 -platform=Win64 -clientconfig=Shipping -serverconfig=Shipping -cook -allmaps -build -stage -pak -archive -archivedirectory="%~dp0\..\_build" 
echo.
echo.
echo.
IF NOT "%1" == "silent" (
    echo [i] All done! Ready to package/test/whatever a mod.
    ENDLOCAL
    pause
)