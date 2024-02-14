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

echo [#] Making dist at "%MOD_DIST_OUT%"...
mkdir "%MOD_DIST_OUT%\LogicMods"
mkdir "%MOD_DIST_OUT%\Mods"
:: copy pak file
copy /y "%MOD_PAK_SRC%" "%MOD_DIST_OUT%\LogicMods\ServerTools.pak"
:: copy lua part
XCOPY "%MOD_LUAMODS_SRC%" "%MOD_DIST_OUT%\Mods" /E /I /Q /Y

echo.
echo.
echo.
echo [i] All done! Press a key to close.
pause>nul