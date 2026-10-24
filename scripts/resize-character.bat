@echo off
setlocal
set "WUKONG_PROJECT=%~dp0.."
if defined WUKONG_PYTHON goto run
set "WUKONG_PYTHON=%WUKONG_PROJECT%\.tools\python\Scripts\python.exe"
if exist "%WUKONG_PYTHON%" goto run
set "WUKONG_PYTHON=%~dp0..\..\..\work\build-tools\python\Scripts\python.exe"
if exist "%WUKONG_PYTHON%" goto run
echo Set WUKONG_PYTHON to a Python interpreter with Pillow 11.3.0 installed.
exit /b 1
:run
"%WUKONG_PYTHON%" -X utf8 "%WUKONG_PROJECT%\tools\resize_character.py" %*
exit /b %errorlevel%
