@echo off
color 0A
echo ===============================
echo   SCRIPT CREADO POR JOSE LUIS :)
echo ===============================
timeout /t 5 /nobreak >nul
echo.

REM Verificar si se está ejecutando con privilegios de administrador
openfiles >nul 2>&1
if not %errorlevel% == 0 (
    echo [ERROR] Este script necesita permisos de administrador. 
    echo Haz clic derecho y selecciona "Ejecutar como administrador".
    pause
    exit /b
)

echo [INFO] Desactivando el firewall de Windows para todos los perfiles...
netsh advfirewall set allprofiles state off

echo.
echo [INFO] Estado actual del firewall:
netsh advfirewall show allprofiles
echo.
echo [OK] Firewall desactivado correctamente. ¡Ten cuidado con la seguridad!
pause
