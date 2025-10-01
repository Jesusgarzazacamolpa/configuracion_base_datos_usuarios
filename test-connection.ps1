# Script de Prueba para PostgreSQL
# test-connection.ps1

param(
    [string]$DbHost = "localhost",
    [string]$Port = "5432",
    [string]$Database = "usuarios",
    [string]$User = "jesusgarza"
)

Write-Host "🧪 Probando conexión a PostgreSQL..." -ForegroundColor Green
Write-Host "📊 Parámetros de conexión:" -ForegroundColor Cyan
Write-Host "  • Host: $DbHost" -ForegroundColor White
Write-Host "  • Puerto: $Port" -ForegroundColor White
Write-Host "  • Base de datos: $Database" -ForegroundColor White
Write-Host "  • Usuario: $User" -ForegroundColor White
Write-Host ""

# Verificar que Docker esté funcionando
try {
    $containers = docker ps --filter "name=postgres" --format "table {{.Names}}\t{{.Status}}"
    if ($containers -match "postgres") {
        Write-Host "✅ Contenedor PostgreSQL está funcionando" -ForegroundColor Green
        Write-Host $containers -ForegroundColor Gray
    } else {
        Write-Host "❌ No se encontró contenedor PostgreSQL funcionando" -ForegroundColor Red
        Write-Host "💡 Ejecuta: docker-compose up -d" -ForegroundColor Yellow
        return
    }
} catch {
    Write-Host "❌ Error al verificar Docker: $_" -ForegroundColor Red
    return
}

Write-Host ""

# Verificar conectividad de red
Write-Host "🌐 Probando conectividad de red..." -ForegroundColor Cyan
try {
    $connection = Test-NetConnection -ComputerName $DbHost -Port $Port -WarningAction SilentlyContinue
    if ($connection.TcpTestSucceeded) {
        Write-Host "✅ Puerto $Port es accesible en $DbHost" -ForegroundColor Green
    } else {
        Write-Host "❌ No se puede conectar al puerto $Port en $DbHost" -ForegroundColor Red
        return
    }
} catch {
    Write-Host "⚠️ No se pudo verificar conectividad de red: $_" -ForegroundColor Yellow
}

Write-Host ""

# Intentar conexión con psql (si está disponible)
Write-Host "🔌 Intentando conexión con psql..." -ForegroundColor Cyan
try {
    $psqlVersion = psql --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ psql está disponible: $psqlVersion" -ForegroundColor Green
        
        # Crear archivo temporal con consulta de prueba
        $testQuery = @"
\echo 'Conexión exitosa!'
SELECT current_database() as base_datos, current_user as usuario_actual, version() as version_postgresql;
\echo 'Verificando tablas creadas:'
\dt
\echo 'Verificando usuarios del sistema:'
SELECT rolname, rolcanlogin FROM pg_roles WHERE rolname IN ('jesusgarza', 'usuario_remoto');
\q
"@
        
        $tempFile = [System.IO.Path]::GetTempFileName() + ".sql"
        $testQuery | Out-File -FilePath $tempFile -Encoding UTF8
        
        Write-Host "🔍 Ejecutando consultas de prueba..." -ForegroundColor Yellow
        $env:PGPASSWORD = "wars3yo10"
        psql -h $DbHost -p $Port -U $User -d $Database -f $tempFile
        
        Remove-Item $tempFile -Force
        Remove-Item Env:PGPASSWORD
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ ¡Conexión y consultas exitosas!" -ForegroundColor Green
        } else {
            Write-Host "❌ Error en las consultas" -ForegroundColor Red
        }
    } else {
        Write-Host "⚠️ psql no está disponible. Instala PostgreSQL client para pruebas completas." -ForegroundColor Yellow
        Write-Host "💡 Puedes usar pgAdmin en http://localhost:8080 para conectarte" -ForegroundColor Cyan
    }
} catch {
    Write-Host "⚠️ No se pudo usar psql: $_" -ForegroundColor Yellow
    Write-Host "💡 Instala PostgreSQL client o usa pgAdmin en http://localhost:8080" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "🎯 Información de conexión para aplicaciones:" -ForegroundColor Green
Write-Host "  Connection String: postgresql://${User}:wars3yo10@${DbHost}:${Port}/${Database}" -ForegroundColor Gray
Write-Host "  pgAdmin: http://localhost:8080 (admin@admin.com / admin123)" -ForegroundColor Gray
Write-Host ""
Write-Host "🔍 Para ver logs del contenedor:" -ForegroundColor Yellow
Write-Host "  docker-compose logs -f postgres" -ForegroundColor Gray