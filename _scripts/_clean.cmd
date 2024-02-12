@ECHO OFF
IF NOT "%1"=="CalledFromInit" (
    SETLOCAL
    TITLE _clean
    REM [TODO: other plugins, do a for loop, too lazy rn]
    echo This script will clean the project of all intermediate/built files, and ONLY the Wwise Plugin.
    echo You might want to backup "Saved", it will be wiped too!
    echo.
    echo This script could be useful for when the Pal sources are updated, or to try and fix a broken project.
    echo.
    echo Press any key to start.
    echo.
    PAUSE > NUL
    
)

echo [#] STARTING CLEAN...
echo     _build\ ...
RMDIR /s /q "%~dp0\..\_build"
echo     _dist\ ...
RMDIR /s /q "%~dp0\..\_dist"
echo     Binaries\ ...
RMDIR /s /q "%~dp0\..\Binaries"
echo     DerivedDataCache\ ...
RMDIR /s /q "%~dp0\..\DerivedDataCache"
echo     Intermediate\ ...
RMDIR /s /q "%~dp0\..\Intermediate"
echo     Platforms\ ...
RMDIR /s /q "%~dp0\..\Platforms"
echo     Plugins\Wwise\Intermediate\ ...
RMDIR /s /q "%~dp0\..\Plugins\Wwise\Intermediate"
echo     Saved\ ...
RMDIR /s /q "%~dp0\..\Saved"

IF NOT "%1"=="CalledFromInit" (
    echo.
    echo.
    echo.
    echo [i] All done! You can now import Pal.uproject into UE.
    pause
    ENDLOCAL
)