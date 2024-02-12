@ECHO OFF
SETLOCAL
TITLE ServerTools_deploy-test
:: vars
SET PAL_TEST_DIR=D:\Games\PalServer_Modded\Pal
SET MOD_PAK_SRC=%~dp0..\_build\Windows\Pal\Content\Paks\pakchunk10-Windows.pak
SET MOD_PAK_DST=%PAL_TEST_DIR%\Content\Paks\LogicMods\ServerTools.pak
SET MOD_LUAMODS_DIR=..\_mods\ServerTools\LuaMods\ServerToolsLoader
SET PAL_EXE=PalServer-Win64-Test-Cmd.exe


:START
echo [#] Copying mod files...
:: copy pak file
copy /y "%MOD_PAK_SRC%" "%MOD_PAK_DST%"
:: copy lua part
rmdir /S /Q "%PAL_TEST_DIR%\Binaries\Win64\Mods\ServerToolsLoader"
XCOPY "%MOD_LUAMODS_DIR%" "%PAL_TEST_DIR%\Binaries\Win64\Mods\ServerToolsLoader" /E /I /Q /Y

:: backup prev log
copy /y "%PAL_TEST_DIR%\Binaries\Win64\UE4SS.log" "%PAL_TEST_DIR%\Binaries\Win64\UE4SS.prev.log"
:: go!
if "%1" == "SameWindow" (
    START "" /WAIT /B "%PAL_TEST_DIR%\Binaries\Win64\%PAL_EXE%"
) ELSE (
    START "" /WAIT "%PAL_TEST_DIR%\Binaries\Win64\%PAL_EXE%"
)
