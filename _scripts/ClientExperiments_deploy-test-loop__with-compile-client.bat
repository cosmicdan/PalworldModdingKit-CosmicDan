@ECHO OFF

:START
CALL "%~dp0\_compile_all_paks.cmd" silent
CALL "%~dp0\ClientExperiments_deploy-test-client.bat"
GOTO :START
