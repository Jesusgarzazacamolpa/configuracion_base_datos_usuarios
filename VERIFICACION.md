# Instrucciones de Verificación Post-Despliegue
## Scripts de Verificación para PostgreSQL

### 1. Verificar que la base de datos se creó correctamente
```sql
-- Conectar como usuario principal
\c usuarios jesusgarza

-- Verificar tablas creadas
\dt

-- Verificar usuarios del sistema
SELECT rolname, rolcanlogin FROM pg_roles WHERE rolname IN ('jesusgarza', 'usuario_remoto');
```

### 2. Verificar datos de ejemplo
```sql
-- Ver usuarios creados
SELECT * FROM usuarios;

-- Ver roles asignados
SELECT * FROM roles_usuario;

-- Ver vista combinada
SELECT * FROM vista_usuarios_roles;
```

### 3. Probar funciones
```sql
-- Obtener estadísticas
SELECT * FROM obtener_estadisticas_usuarios();

-- Buscar usuarios
SELECT * FROM buscar_usuarios('admin');
```

### 4. Probar conexión remota
```bash
# Desde línea de comandos
psql -h localhost -p 5432 -U usuario_remoto -d usuarios
```

### 5. Verificar permisos
```sql
-- Como usuario_remoto, verificar permisos
SELECT * FROM usuarios LIMIT 1;
INSERT INTO usuarios (nombre, email, password) VALUES ('Test', 'test@test.com', 'test123');
```

## Solución de Problemas

### Error: "database does not exist"
- Asegúrarse de que POSTGRES_DB coincida en docker-compose y scripts
- Verificar que los scripts usen current_database() para referencias dinámicas

### Error: "role does not exist" 
- Verificar que los usuarios se crearon correctamente
- Comprobar pg_roles para ver usuarios existentes

### Error de conexión
- Verificar que pg_hba.conf permite conexiones desde tu IP
- Comprobar que el puerto 5432 esté abierto