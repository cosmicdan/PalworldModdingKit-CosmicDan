@ECHO OFF
SETLOCAL
TITLE ServerTools_dist
:: vars
SET MOD_PAK_SRC=%~dp0..\_build\Windows\Pal\Content\Paks\pakchunk10-Windows.pak
SET MOD_LUAMODS_SRC=..\_mods\ServerTools\LuaMods
SET MOD_DIST_OUT=%~dp0\..\_dist\ServerTools
SET MOD_DIST_PAKNAME=ServerTools.pak

IF EXIST "%MOD_DIST_OUT%" (
    echo [!] Existing dist exists, [re]move first:
    echo     "%MOD_DIST_OUT%"
    pause
    exit /b
)

SET MOD_OUTDIR_PAK=%MOD_DIST_OUT%\Pal\Content\Paks\LogicMods
SET MOD_OUTDIR_LUA=%MOD_DIST_OUT%\Pal\Binaries\Win64\Mods

echo [#] Making dist at "%MOD_DIST_OUT%"...
mkdir "%MOD_OUTDIR_PAK%"
mkdir "%MOD_OUTDIR_LUA%"
:: copy pak file
copy /y "%MOD_PAK_SRC%" "%MOD_OUTDIR_PAK%\ServerTools.pak"
:: copy lua part
XCOPY "%MOD_LUAMODS_SRC%" "%MOD_OUTDIR_LUA%\" /E /I /Q /Y

echo.
echo.
echo.
echo [i] All done! Press a key to close.
pause>nul