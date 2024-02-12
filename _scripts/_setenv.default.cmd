:: Default env settings for all scripts.
:: Copy this to a file called "_setenv.cmd" to use your own values, since this
:: file is tracked upstream an can change.
::
:: Using full paths is recommended, relative paths will probably work anyway but its best to be explicit
::
::

:: Do not touch this line, its just for safety
IF NOT "%1"=="IsSafeToRun" ( exit /b )

:: Path of Wwise_Unreal_Integration_2021.1.11.2437 > Unreal.5.0 > Wwise folder (the one containing Wwise.uplugin)
SET PMK_WWISE_UE5_PATH=E:\Development\Palworld\Wwise_Unreal_Integration_2021.1.11.2437\Unreal.5.0\Wwise

:: Use directory junctions instead of copying for the Wwise VC dependency stuff (ThirdParty folder). Saves almost 3GB.
:: NOTE: Doesnt do anything yet, _init will always make links instead of copying, I'll add it if there's any need (
SET PMK_WWISE_DEPS_USE_LINKS=true

:: Path of Wwise SDK, seems to be set via installer already but we'll make it configurable just in case
SET PMK_WWISE_SDK_PATH=%WWISESDK%

:: Path of UE5.1.1 "RunUAT.bat" required for compile script
SET UDK_RUNUAT_PATH=D:\Games\Epic Games\UE_5.1\Engine\Build\BatchFiles\RunUAT.bat


