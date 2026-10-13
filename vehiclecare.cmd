@echo off
setlocal EnableExtensions
pushd "%~dp0"

rem Prefer the existing Codex runtime without changing the user's global PATH.
set "VEHICLECARE_RUNTIME=%USERPROFILE%\.cache\codex-runtimes\codex-primary-runtime\dependencies"
if not exist "%VEHICLECARE_RUNTIME%\node\bin\node.exe" goto installed
if not exist "%VEHICLECARE_RUNTIME%\bin\fallback\pnpm.cmd" goto installed
set "PATH=%VEHICLECARE_RUNTIME%\node\bin;%PATH%"
set "VEHICLECARE_PNPM=%VEHICLECARE_RUNTIME%\bin\fallback\pnpm.cmd"
goto run

:installed
where node.exe >nul 2>nul
if errorlevel 1 goto missing
where pnpm >nul 2>nul
if errorlevel 1 goto missing
set "VEHICLECARE_PNPM=pnpm"

:run
if "%~1"=="" (
  call "%VEHICLECARE_PNPM%" dev
) else (
  call "%VEHICLECARE_PNPM%" %*
)
set "VEHICLECARE_RESULT=%ERRORLEVEL%"
popd
exit /b %VEHICLECARE_RESULT%

:missing
echo VehicleCare could not find Node.js and pnpm.
echo This launcher supports the existing Codex runtime or Node.js and pnpm on PATH.
echo See README.md for setup requirements.
popd
exit /b 1
