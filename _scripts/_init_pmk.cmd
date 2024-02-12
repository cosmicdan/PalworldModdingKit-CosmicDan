@ECHO OFF
::SETLOCAL EnableDelayedExpansion        < DONT FORGET: need to go through and change all !'s if I need it
SETLOCAL
TITLE _init_pmk
echo This script is for setting up a fresh repo clone of CosmicDan's PMK to make it ready for UE5 import.
echo You'll also need to do this if you move the folder after a previous init.
echo Note that _clean.cmd will also be called before running.
echo.
echo This consists of:
echo 1) Installing the Wwise integration plugin and setting up the ThirdParty folders;
echo 2) ... nothing else required for now.
echo.
echo IMPORTANT:
echo !) Be sure you have copied _setenv.default.cmd to _setenv.cmd 
echo !) Also be sure you have manually performed the VS2022 xml fix, and all other prerequisites.
echo.
echo Press any key to start.
echo.
PAUSE > NUL
IF EXIST "%~dp0\_setenv.cmd" (
    echo [#] Reading _setenv.cmd ...
    CALL "%~dp0\_setenv.cmd" IsSafeToRun
) ELSE (
    echo [#] Reading _setenv.default.cmd [no _setenv.cmd found] ...
    CALL "%~dp0\_setenv.default.cmd" IsSafeToRun
)
:: do env verification 
IF NOT EXIST "%PMK_WWISE_UE5_PATH%\Wwise.uplugin" (
    echo [!] setenv is incorrect, could not find file/dir:
    echo     "%PMK_WWISE_UE5_PATH%\Wwise.uplugin"
    echo.
    echo Fix it! Press any key to exit.
    pause > nul
    exit /B
)

IF NOT EXIST "%PMK_WWISE_SDK_PATH%\include\AK" (
    echo [!] setenv is incorrect, could not find file/dir:
    echo     "%PMK_WWISE_SDK_PATH%\include\AK"
    echo.
    echo Fix it! Press any key to exit.
    pause > nul
    exit /B
)

:: Wwise - check for existing install
IF EXIST "%~dp0\..\Plugins\Wwise" (
    echo [#] Removing existing Plugins\Wwise folder ...
    RMDIR /s /q "%~dp0\..\Plugins\Wwise"
)

:: do clean
echo [#] Doing clean first...
CALL "%~dp0\_clean.cmd" CalledFromInit

echo [#] Setting up Plugins\Wwise\ ...
XCOPY "%PMK_WWISE_UE5_PATH%" "%~dp0\..\Plugins\Wwise" /E /I /Q
MKDIR "%~dp0\..\Plugins\Wwise\ThirdParty"
MKLINK /J "%~dp0\..\Plugins\Wwise\ThirdParty\include" "%PMK_WWISE_SDK_PATH%\include"
MKLINK /J "%~dp0\..\Plugins\Wwise\ThirdParty\Win32_vc170" "%PMK_WWISE_SDK_PATH%\Win32_vc170"
MKLINK /J "%~dp0\..\Plugins\Wwise\ThirdParty\Win32_vc160" "%PMK_WWISE_SDK_PATH%\Win32_vc170"
MKLINK /J "%~dp0\..\Plugins\Wwise\ThirdParty\x64_vc170" "%PMK_WWISE_SDK_PATH%\x64_vc170"
MKLINK /J "%~dp0\..\Plugins\Wwise\ThirdParty\x64_vc160" "%PMK_WWISE_SDK_PATH%\x64_vc170"

echo.
echo.
echo.
echo [i] All done! You can now import Pal.uproject into UE.
pause
ENDLOCAL