@ECHO OFF
SETLOCAL
TITLE ClientExperiments_deploy-test-client
:: vars
SET PAL_TEST_DIR=D:\Games\Steam\steamapps\common\Palworld\Pal
SET MOD_PAK_SRC=%~dp0..\_build\Windows\Pal\Content\Paks\pakchunk299-Windows.pak
SET MOD_PAK_DST=%PAL_TEST_DIR%\Content\Paks\LogicMods\ClientExperiments.pak
SET MOD_LUAMODS_DIR=..\_mods\ClientExperiments_DOES_NOT_EXIST
SET PAL_EXE=Palworld-Win64-Shipping.exe


:START
echo [#] Copying mod files...
:: copy pak file
copy /y "%MOD_PAK_SRC%" "%MOD_PAK_DST%"
:: copy lua part
::rmdir /S /Q "%PAL_TEST_DIR%\Binaries\Win64\Mods\ServerToolsLoader"
::XCOPY "%MOD_LUAMODS_DIR%" "%PAL_TEST_DIR%\Binaries\Win64\Mods\ServerToolsLoader" /E /I /Q /Y

:: backup prev log
copy /y "%PAL_TEST_DIR%\Binaries\Win64\UE4SS.log" "%PAL_TEST_DIR%\Binaries\Win64\UE4SS.prev.log"
:: go!
if "%1" == "SameWindow" (
    START "" /WAIT /B "%PAL_TEST_DIR%\Binaries\Win64\%PAL_EXE%"
) ELSE (
    START "" /WAIT "%PAL_TEST_DIR%\Binaries\Win64\%PAL_EXE%"
)
