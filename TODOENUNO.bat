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
echo  [6] Desinstalar SQL Server / Ágora / IGT
echo  [7] Salir
echo.
set /p opcion=Selecciona una opción [1-7]: 

if "%opcion%"=="1" goto uninstall_updates
if "%opcion%"=="2" goto disable_firewall
if "%opcion%"=="3" goto enable_firewall
if "%opcion%"=="4" goto pause_updates
if "%opcion%"=="5" goto show_firewall
if "%opcion%"=="6" goto uninstall_sql
if "%opcion%"=="7" goto salir
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

:: ================================================================
:: NUEVA OPCION: DESINSTALAR SQL SERVER / AGORA / IGT
:: ================================================================
:uninstall_sql
cls
echo ================================================================
echo     DESINSTALACION DE SQL SERVER / AGORA / IGT MICROELECTRONICS
echo ================================================================
echo.
echo Este proceso buscara y ofrecera eliminar:
echo   - Servicios con nombres que contengan 'SQL', 'MSSQL' o 'Agora'
echo   - Programas instalados de SQL Server o Agora
echo   - Carpetas: 
echo        C:\Program Files\Microsoft SQL Server
echo        C:\Program Files (x86)\Microsoft SQL Server
echo        C:\Program Files (x86)\IGT Microelectronics
echo   - Claves de registro relacionadas (opcional)
echo.
echo *** Usa esta herramienta con precaucion ***
pause

:: Verificar si el script auxiliar ya existe (opcional)
set "tmpbat=%temp%\sql_remove_temp.bat"
(
echo @echo off
echo setlocal enabledelayedexpansion
echo color 0E
echo echo ================================================================
echo echo  LIMPIEZA DE SQL SERVER / AGORA / IGT MICROELECTRONICS
echo echo ================================================================
echo echo.
echo set /p CONF="Deseas continuar con la limpieza completa (S/N)? "
echo if /I "%%CONF%%" NEQ "S" exit /b
echo.
echo echo --- Deteniendo y eliminando servicios relacionados ---
for /f "tokens=2 delims=:" %%%%S in ('sc query state^= all ^| findstr "SERVICE_NAME:"') do (
    set svc=%%%%S
    set svc=!svc:~1!
    echo !svc! | findstr /I "SQL MSSQL Agora" >nul
    if not errorlevel 1 (
        echo Servicio encontrado: !svc!
        set /p delsvc="  -> Eliminar !svc!? (S/N): "
        if /I "!delsvc!"=="S" (
            sc stop "!svc!" >nul 2>&1
            sc delete "!svc!" >nul 2>&1
        )
    )
)
echo.
echo --- Desinstalando productos (via WMIC) ---
for /f "skip=1 delims=" %%%%P in ('wmic product get name 2^>nul ^| findstr /I "SQL Agora"') do (
    echo Producto detectado: %%%%P
    set /p un="  -> Desinstalar %%%%P (S/N): "
    if /I "!un!"=="S" (
        wmic product where "name='%%%%P'" call uninstall /nointeractive >nul 2>&1
    )
)
echo.
echo --- Borrado de carpetas ---
call :d "C:\Program Files\Microsoft SQL Server"
call :d "C:\Program Files (x86)\Microsoft SQL Server"
call :d "C:\Program Files (x86)\IGT Microelectronics"
call :d "C:\Program Files\IGT Microelectronics"
echo.
echo --- Limpieza de registro ---
call :r "HKLM\SOFTWARE\Microsoft\Microsoft SQL Server"
call :r "HKLM\SOFTWARE\WOW6432Node\Microsoft\Microsoft SQL Server"
call :r "HKLM\SOFTWARE\IGT Microelectronics"
call :r "HKLM\SOFTWARE\WOW6432Node\IGT Microelectronics"
echo.
echo Proceso finalizado. Se recomienda reiniciar.
pause
exit /b

:d
set pth=%%~1
if exist "%%pth%%" (
  echo Carpeta: %%pth%%
  set /p ans="  -> Borrar %%pth%% (S/N): "
  if /I "%%ans%%"=="S" rd /s /q "%%pth%%"
)
exit /b

:r
set rk=%%~1
reg query "%%rk%%" >nul 2>&1
if not errorlevel 1 (
  echo Clave: %%rk%%
  set /p rr="  -> Borrar %%rk%% (S/N): "
  if /I "%%rr%%"=="S" reg delete "%%rk%%" /f >nul 2>&1
)
exit /b
) > "%tmpbat%"

call "%tmpbat%"
del "%tmpbat%" >nul 2>&1
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
