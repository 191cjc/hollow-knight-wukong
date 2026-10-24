@echo off
setlocal
set "WUKONG_PROJECT=%~dp0.."
if defined WUKONG_PYTHON goto run
set "WUKONG_PYTHON=%WUKONG_PROJECT%\.tools\python\Scripts\python.exe"
if exist "%WUKONG_PYTHON%" goto run
set "WUKONG_PYTHON=%~dp0..\..\..\work\build-tools\python\Scripts\python.exe"
if exist "%WUKONG_PYTHON%" goto run
echo Set WUKONG_PYTHON to Python with Pillow 11.3.0 installed.
exit /b 1
:run
"%WUKONG_PYTHON%" -X utf8 "%WUKONG_PROJECT%\tools\prepare_all_assets.py" %*
exit /b %errorlevel%
