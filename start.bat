@echo off
title Supply Chain Traceability Server (Port 9090)
echo ========================================================
echo   Starting Supply Chain Traceability System on Port 9090
echo ========================================================
echo.

cd /d "%~dp0"
mvn spring-boot:run

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [ERROR] The application stopped with error code %ERRORLEVEL%.
    pause
)

