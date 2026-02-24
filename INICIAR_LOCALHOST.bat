@echo off
setlocal
title Iniciar Sistema Local

set "ROOT=%~dp0"
set "API_DIR=%ROOT%sistema_imobiliaria_api"
set "APP_DIR=%ROOT%sistema_imobiliaria"

echo ==========================================
echo   Iniciando Backend + Frontend (Localhost)
echo ==========================================
echo.

if not exist "%API_DIR%\package.json" (
  echo [ERRO] Nao encontrei o backend em:
  echo %API_DIR%
  pause
  exit /b 1
)

if not exist "%APP_DIR%\pubspec.yaml" (
  echo [ERRO] Nao encontrei o frontend Flutter em:
  echo %APP_DIR%
  pause
  exit /b 1
)

echo [1/2] Subindo backend (Node)...
start "Backend API (localhost:3000)" cmd /k "cd /d ""%API_DIR%"" && npm run dev"

timeout /t 3 /nobreak >nul

echo [2/2] Subindo frontend (Flutter Web em localhost:8080)...
start "Frontend Flutter (localhost:8080)" cmd /k "cd /d ""%APP_DIR%"" && set CHROME_NO_SANDBOX=1 && flutter run -d chrome --web-port=8080"

timeout /t 8 /nobreak >nul
start "" "http://localhost:8080"

echo.
echo Pronto. Duplo clique neste arquivo sempre que quiser iniciar tudo.
exit /b 0
