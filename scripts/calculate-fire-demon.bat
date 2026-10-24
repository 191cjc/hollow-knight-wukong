@echo off
setlocal
cd /d "%~dp0.."
set "WUKONG_CALC_PYTHON=..\..\work\build-tools\python\Scripts\python.exe"
if not exist "%WUKONG_CALC_PYTHON%" set "WUKONG_CALC_PYTHON=python"
if "%~1"=="" (
  "%WUKONG_CALC_PYTHON%" -X utf8 tools\calculate_fire_demon.py --attack 100 --defense 0 --level 1
) else (
  "%WUKONG_CALC_PYTHON%" -X utf8 tools\calculate_fire_demon.py %*
)
exit /b %errorlevel%
