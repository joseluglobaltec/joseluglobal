@echo off
title Herramienta TODO EN UNO - By Jose Luis
color 0A
mode con: cols=90 lines=30

:: ================================================================
::  HERRAMIENTA TODO EN UNO - By Jose Luis
:: ================================================================

:inicio
cls
echo ================================================================
echo               HERRAMIENTA TODO EN UNO - BY JOSE LUIS
echo ================================================================
echo.
echo Verificando permisos de administrador...
net session >nul 2>&1
if %errorlevel% NEQ 0 (
    color 0C
    echo.
    echo [ERROR] Este script requiere permisos de administrador.
    echo Haz clic derecho y selecciona "Ejecutar como administrador".
    echo.
    pause
    exit /b
)
color 0A
echo Permisos de administrador confirmados.
timeout /t 1 >nul
goto menu

:menu
cls
echo ================================================================
echo               HERRAMIENTA TODO EN UNO - BY JOSE LUIS
echo ================================================================
echo.
echo  [1] Desinstalar actualizaciones KB (5066835 / 5065789)
echo  [2] Desactivar Firewall de Windows
echo  [3] Activar Firewall de Windows
echo  [4] Pausar actualizaciones de Windows (31 días)
echo  [5] Mostrar estado del Firewall
echo  [6] Salir
echo.
set /p opcion=Selecciona una opción [1-6]: 

if "%opcion%"=="1" goto uninstall_updates
if "%opcion%"=="2" goto disable_firewall
if "%opcion%"=="3" goto enable_firewall
if "%opcion%"=="4" goto pause_updates
if "%opcion%"=="5" goto show_firewall
if "%opcion%"=="6" goto salir
goto menu

:uninstall_updates
cls
echo ================================================================
echo         DESINSTALANDO ACTUALIZACIONES PROBLEMATICAS
echo ================================================================
echo.
echo -> Comprobando la actualizacion KB5066835...
dism /online /get-packages | findstr /i "KB5066835" >nul
if %errorlevel%==0 (
    echo [ENCONTRADA] Iniciando desinstalacion KB5066835...
    wusa /uninstall /kb:5066835 /quiet /norestart
) else (
    echo [NO ENCONTRADA] KB5066835 no esta instalada.
)
echo.
echo -> Comprobando la actualizacion KB5065789...
dism /online /get-packages | findstr /i "KB5065789" >nul
if %errorlevel%==0 (
    echo [ENCONTRADA] Iniciando desinstalacion KB5065789...
    wusa /uninstall /kb:5065789 /quiet /norestart
) else (
    echo [NO ENCONTRADA] KB5065789 no esta instalada.
)
echo.
echo [OK] Proceso completado. Reinicia el sistema si alguna fue desinstalada.
pause
goto menu

:disable_firewall
cls
echo ================================================================
echo               DESACTIVANDO FIREWALL DE WINDOWS
echo ================================================================
netsh advfirewall set allprofiles state off
echo.
echo [OK] Firewall desactivado. Ten cuidado con la seguridad.
pause
goto menu

:enable_firewall
cls
echo ================================================================
echo                ACTIVANDO FIREWALL DE WINDOWS
echo ================================================================
netsh advfirewall set allprofiles state on
echo.
echo [OK] Firewall activado correctamente. Sistema protegido.
pause
goto menu

:pause_updates
cls
echo ================================================================
echo              PAUSANDO ACTUALIZACIONES DE WINDOWS
echo ================================================================
echo -> Pausando las actualizaciones durante 31 días...
powershell -Command "$ExpiryDate = (Get-Date).AddDays(31).ToString('yyyy-MM-ddT00:00:00Z'); New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings' -Name 'PauseUpdatesExpiryTime' -Value $ExpiryDate -PropertyType String -Force | Out-Null"
echo.
echo [OK] Actualizaciones pausadas por 31 días.
pause
goto menu

:show_firewall
cls
echo ================================================================
echo                 ESTADO ACTUAL DEL FIREWALL
echo ================================================================
netsh advfirewall show allprofiles
echo.
pause
goto menu

:salir
cls
color 0B
echo ================================================================
echo              HERRAMIENTA TODO EN UNO - BY JOSE LUIS
echo ================================================================
echo.
echo  ¡Gracias por usar esta herramienta!
echo  TRABAJO REALIZADO POR: JOSE LUIS
echo.
echo msgbox "TRABAJO REALIZADO POR JOSE LUIS.",vbInformation,"Proceso Finalizado" > %temp%\popup.vbs
cscript //nologo %temp%\popup.vbs
del %temp%\popup.vbs >nul 2>&1
exit
