@echo off
setlocal enabledelayedexpansion

title CapCut Downgrader - %TARGET_VER%
echo CapCut Downgrader
echo Downgrading to: %TARGET_VER%
echo.
echo Checking CapCut installation...

:: Define paths
set "CAPCUT_DIR=%localappdata%\CapCut"
set "APPS_DIR=%CAPCUT_DIR%\Apps"
set "TARGET_VER=1.4.0.198"
set "DOWNLOAD_FOLDER_DIR=%USERPROFILE%\Downloads"
set "BACKUP_EXE=%CAPCUT_DIR%\backup.exe"

:: =========================
:: CHECK IF APPS EXISTS
:: =========================
if exist "%APPS_DIR%" (
    echo Apps folder found.
    goto continue
) else (
    echo Apps folder not found. Starting installation...
    goto install
)

:: =========================
:: INSTALLATION
:: =========================
:install
echo Preparing installation...

:: --- USE BACKUP ---
if exist "%BACKUP_EXE%" (
    echo Using backup installer...
    start "" /wait "%BACKUP_EXE%" /silent_install=1
    goto continue
)

:: --- CHECK WINGET ---
winget >nul 2>&1
if errorlevel 1 (
    echo Winget not working!
    echo Update "App Installer" in Microsoft Store.
    pause
    exit /b
)

:: --- DOWNLOAD ONLY ---
echo Downloading installer via winget...

cd /d "%DOWNLOAD_FOLDER_DIR%"
winget download ByteDance.CapCut --version %TARGET_VER%

echo Searching for installer...

set FOUND=0

for /d %%D in (ByteDance.CapCut_%TARGET_VER%*) do (
    cd /d "%%D"
    for %%F in (CapCut*.exe) do (
        echo Running installer: %%F
        start "" /wait "%%F" /silent_install=1

        echo Saving backup...
        if not exist "%CAPCUT_DIR%" mkdir "%CAPCUT_DIR%"
        copy "%%F" "%BACKUP_EXE%" >nul

        set FOUND=1
    )
)

if "!FOUND!"=="0" (
    echo Installer not found!
    pause
    exit /b
)

goto continue

:: =========================
:: CONTINUE
:: =========================
:continue
echo Checking version folder...

if exist "%APPS_DIR%\%TARGET_VER%" (
    echo Target version exists.
    goto continue2
) else (
    echo Target version not found. Reinstalling...
    goto install
)

:: =========================
:: CONTINUE 2
:: =========================
:continue2
echo Cleaning other versions...

set COUNT=0

for /d %%D in ("%APPS_DIR%\*") do (
    set /a COUNT+=1
)

if "%COUNT%"=="1" (
    echo Only one version found. Nothing to clean.
    pause
    exit /b
)

for /d %%D in ("%APPS_DIR%\*") do (
    if /i not "%%~nxD"=="%TARGET_VER%" (
        echo Deleting folder: %%~nxD
        rmdir /s /q "%%D"
    )
)

echo Done. Only version %TARGET_VER% remains.
pause
exit /b