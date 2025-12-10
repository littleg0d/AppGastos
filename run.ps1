# Script de instalación y ejecución de GastoFácil
# Ejecutar en PowerShell

Write-Host "=== Instalación de dependencias de GastoFácil ===" -ForegroundColor Cyan

# Verificar que Flutter esté instalado
Write-Host "`nVerificando instalación de Flutter..." -ForegroundColor Yellow
flutter --version

if ($LASTEXITCODE -ne 0) {
    Write-Host "`n❌ Flutter no está instalado o no está en el PATH" -ForegroundColor Red
    Write-Host "Por favor, sigue las instrucciones de instalación primero." -ForegroundColor Red
    exit 1
}

Write-Host "`n✅ Flutter encontrado!" -ForegroundColor Green

# Navegar al directorio del proyecto
Set-Location "C:\Users\feder\OneDrive\Documentos\Gastos\gastofacil"

# Instalar dependencias
Write-Host "`nInstalando dependencias del proyecto..." -ForegroundColor Yellow
flutter pub get

if ($LASTEXITCODE -ne 0) {
    Write-Host "`n❌ Error al instalar dependencias" -ForegroundColor Red
    exit 1
}

Write-Host "`n✅ Dependencias instaladas!" -ForegroundColor Green

# Verificar dispositivos disponibles
Write-Host "`nDispositivos disponibles:" -ForegroundColor Yellow
flutter devices

# Preguntar cómo ejecutar
Write-Host "`n=== ¿Cómo quieres ejecutar la app? ===" -ForegroundColor Cyan
Write-Host "1. Chrome (Web) - Más fácil para probar"
Write-Host "2. Windows Desktop"
Write-Host "3. Emulador Android (si tienes uno configurado)"
Write-Host "4. Solo instalar dependencias (no ejecutar)"

$choice = Read-Host "`nElige una opción (1-4)"

switch ($choice) {
    "1" {
        Write-Host "`nEjecutando en Chrome..." -ForegroundColor Green
        flutter run -d chrome
    }
    "2" {
        Write-Host "`nEjecutando en Windows..." -ForegroundColor Green
        flutter run -d windows
    }
    "3" {
        Write-Host "`nEjecutando en emulador Android..." -ForegroundColor Green
        flutter run
    }
    "4" {
        Write-Host "`n✅ Dependencias instaladas. Usa 'flutter run -d chrome' para ejecutar." -ForegroundColor Green
    }
    default {
        Write-Host "`n✅ Dependencias instaladas. Usa 'flutter run -d chrome' para ejecutar." -ForegroundColor Green
    }
}
