@ECHO OFF
:START
CALL "%~dp0\_compile_all_paks.cmd" silent
CALL "%~dp0\ServerTools_deploy-test.bat"
GOTO :START
