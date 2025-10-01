# Script de PowerShell para desplegar PostgreSQL con Docker
# deploy.ps1

param(
    [string]$Mode = "standard",  # "standard" o "spanish"
    [switch]$Rebuild = $false,   # Forzar rebuild de las imágenes
    [switch]$Clean = $false      # Limpiar volúmenes existentes
)

Write-Host "🐘 Desplegando PostgreSQL con Docker..." -ForegroundColor Green

# Verificar que Docker esté funcionando
try {
    docker --version | Out-Null
    Write-Host "✅ Docker está disponible" -ForegroundColor Green
} catch {
    Write-Host "❌ Error: Docker no está instalado o no está funcionando" -ForegroundColor Red
    exit 1
}

# Limpiar volúmenes si se solicita
if ($Clean) {
    Write-Host "🧹 Limpiando volúmenes existentes..." -ForegroundColor Yellow
    docker-compose down -v
    if ($Mode -eq "spanish") {
        docker-compose -f docker-compose.spanish.yml down -v
    }
}

# Seleccionar configuración
$composeFile = "docker-compose.yml"
$configDescription = "estándar (locales en inglés)"

if ($Mode -eq "spanish") {
    $composeFile = "docker-compose.spanish.yml"
    $configDescription = "en español (locales es_ES.UTF-8)"
    Write-Host "🇪🇸 Usando configuración en español..." -ForegroundColor Cyan
} else {
    Write-Host "🇺🇸 Usando configuración estándar..." -ForegroundColor Cyan
}

Write-Host "📋 Configuración: $configDescription" -ForegroundColor White

# Parámetros de docker-compose
$dockerArgs = @("-f", $composeFile, "up", "-d")
if ($Rebuild) {
    $dockerArgs += "--build"
    Write-Host "🔨 Forzando rebuild de imágenes..." -ForegroundColor Yellow
}

# Ejecutar docker-compose
try {
    Write-Host "🚀 Iniciando contenedores..." -ForegroundColor Green
    & docker-compose @dockerArgs
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ ¡Contenedores iniciados exitosamente!" -ForegroundColor Green
        Write-Host ""
        Write-Host "📊 Información de conexión:" -ForegroundColor Cyan
        Write-Host "  • PostgreSQL: localhost:5432" -ForegroundColor White
        Write-Host "  • Usuario: jesusgarza" -ForegroundColor White
        Write-Host "  • Contraseña: wars3yo10" -ForegroundColor White
        Write-Host "  • Base de datos: usuarios" -ForegroundColor White
        Write-Host "  • pgAdmin: http://localhost:8080" -ForegroundColor White
        Write-Host ""
        Write-Host "🔍 Para ver logs:" -ForegroundColor Yellow
        Write-Host "  docker-compose -f $composeFile logs -f postgres" -ForegroundColor Gray
        Write-Host ""
        Write-Host "🛑 Para detener:" -ForegroundColor Yellow
        Write-Host "  docker-compose -f $composeFile down" -ForegroundColor Gray
    } else {
        Write-Host "❌ Error al iniciar los contenedores" -ForegroundColor Red
        Write-Host "💡 Intenta con:" -ForegroundColor Yellow
        Write-Host "  .\deploy.ps1 -Rebuild" -ForegroundColor Gray
        exit 1
    }
} catch {
    Write-Host "❌ Error durante el despliegue: $_" -ForegroundColor Red
    exit 1
}

# Verificar estado de los contenedores
Write-Host "🔍 Verificando estado de contenedores..." -ForegroundColor Cyan
Start-Sleep -Seconds 3
& docker-compose -f $composeFile ps

Write-Host ""
Write-Host "🎉 ¡Despliegue completado!" -ForegroundColor Green