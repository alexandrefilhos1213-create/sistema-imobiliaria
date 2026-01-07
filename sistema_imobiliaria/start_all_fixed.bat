@echo off
title Sistema Imobiliária - Iniciar Tudo
echo =====================================
echo  Sistema Imobiliaria - API + Flutter
echo =====================================
echo.
echo 1. Iniciando a API...
start "API" cmd /c "cd /d %~dp0\sistema_imobiliaria_api && npm run dev && timeout /t 2 >nul && exit"

timeout /t 4 /nobreak >nul

echo.
echo 2. Iniciando o Flutter Web...
set CHROME_NO_SANDBOX=1
start "Flutter" cmd /c "cd /d %~dp0 && flutter run -d chrome --web-port=8080 && timeout /t 3 >nul && exit"

echo.
echo Aguardando aplicação abrir no navegador...
timeout /t 15 /nobreak >nul

echo.
echo Aplicação iniciada! Fechando esta janela em 3 segundos...
timeout /t 3 /nobreak >nul
exit
