@echo off
setlocal
title SM64CoopDX 64-player build
set "WORKDIR=%~dp0"
cd /d "%WORKDIR%"

echo ============================================================
echo  SM64CoopDX - 64-player fork builder
echo  Fork: mobiusbagel/sm64coopdx   Branch: maxplayers-64
echo ============================================================
echo.

rem --- Locate MSYS2 ---
set "MSYS2="
for %%D in (C:\msys64 D:\msys64 E:\msys64 "%USERPROFILE%\msys64") do (
    if not defined MSYS2 if exist "%%~D\msys2_shell.cmd" set "MSYS2=%%~D"
)
if not defined MSYS2 (
    echo MSYS2 not found. Trying to install it with winget...
    where winget >nul 2>nul
    if not errorlevel 1 (
        winget install --id MSYS2.MSYS2 -e --accept-source-agreements --accept-package-agreements
        if exist "C:\msys64\msys2_shell.cmd" set "MSYS2=C:\msys64"
    )
)
if not defined MSYS2 (
    echo.
    echo Could not install MSYS2 automatically.
    echo Install it from https://www.msys2.org/ ^(default folder C:\msys64^),
    echo then run this .bat again.
    pause
    exit /b 1
)
echo Using MSYS2 at %MSYS2%
echo.

rem --- If you dropped the ROM next to this .bat, stage it into the repo ---
if exist "%WORKDIR%baserom.us.z64" if exist "%WORKDIR%sm64coopdx-64p" (
    copy /y "%WORKDIR%baserom.us.z64" "%WORKDIR%sm64coopdx-64p\baserom.us.z64" >nul
)

call "%MSYS2%\msys2_shell.cmd" -mingw64 -defterm -here -no-start -c "./build-inside.sh %~1"
set "RC=%ERRORLEVEL%"
echo.
if "%RC%"=="0" (
    echo ============================================================
    echo  DONE. Your game is at:
    echo    %WORKDIR%sm64coopdx-64p\build\us_pc\sm64coopdx.exe
    echo  Run sm64coopdx.exe from that folder - it needs the files
    echo  sitting next to it ^(dynos, lang, mods, palettes, dlls^).
    echo ============================================================
) else (
    echo Finished with exit code %RC% - see the messages above.
    echo If MSYS2 updated itself mid-run, just run this .bat again.
)
pause
exit /b %RC%
