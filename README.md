# PostgreSQL con Docker - Configuración para Acceso Remoto

Esta configuración te permite ejecutar PostgreSQL en un contenedor Docker con acceso remoto completo.

## 📋 Contenido del Proyecto

```
base de datos/
├── Dockerfile                    # Imagen personalizada de PostgreSQL
├── docker-compose.yml            # Orquestación de contenedores
├── config/
│   ├── postgresql.conf           # Configuración principal de PostgreSQL
│   └── pg_hba.conf              # Configuración de autenticación
├── init-scripts/
│   └── 01-init.sql              # Script de inicialización de BD
└── README.md                    # Este archivo
```

## 🚀 Inicio Rápido

### Opción 1: Configuración estándar (Recomendada)
```powershell
# Configuración con locales en inglés (más rápida y estable)
docker-compose up -d --build
```

### Opción 2: Configuración en español
```powershell
# Configuración con locales en español (requiere instalación adicional)
docker-compose -f docker-compose.spanish.yml up -d --build
```

### 2. Verificar que los contenedores están ejecutándose:
```powershell
docker-compose ps
```

### 3. Ver los logs en tiempo real:
```powershell
docker-compose logs -f postgres
```

## 🔐 Credenciales de Acceso

### Usuario Principal (Administrador):
- **Usuario:** `mi_usuario`
- **Contraseña:** `mi_contraseña_segura`
- **Base de datos:** `mi_base_datos`

### Usuario Remoto (Limitado):
- **Usuario:** `usuario_remoto`
- **Contraseña:** `contraseña_remota`
- **Base de datos:** `mi_base_datos`

### pgAdmin (Interfaz Web):
- **URL:** http://localhost:8080
- **Email:** `admin@admin.com`
- **Contraseña:** `admin123`

## 🌐 Conexión Remota

### Desde aplicaciones:
```
Host: localhost (o la IP de tu servidor)
Puerto: 5432
Base de datos: mi_base_datos
Usuario: mi_usuario o usuario_remoto
Contraseña: según el usuario elegido
```

### Cadena de conexión:
```
postgresql://mi_usuario:mi_contraseña_segura@localhost:5432/mi_base_datos
```

### Desde línea de comandos:
```powershell
# Instalar psql si no lo tienes
# Conectar a la base de datos
psql -h localhost -p 5432 -U mi_usuario -d mi_base_datos
```

### Desde pgAdmin:
1. Abre http://localhost:8080
2. Login con las credenciales de pgAdmin
3. Agregar servidor:
   - **Name:** Mi PostgreSQL
   - **Host:** postgres (nombre del contenedor)
   - **Port:** 5432
   - **Username:** mi_usuario
   - **Password:** mi_contraseña_segura

## 🛠️ Personalización

### Cambiar credenciales:
Edita las variables de entorno en `docker-compose.yml`:
```yaml
environment:
  POSTGRES_DB: tu_base_datos
  POSTGRES_USER: tu_usuario
  POSTGRES_PASSWORD: tu_contraseña_segura
```

### Cambiar puerto:
Modifica la sección de puertos en `docker-compose.yml`:
```yaml
ports:
  - "3306:5432"  # Cambia 3306 por el puerto que prefieras
```

### Modificar el esquema de base de datos:
El esquema personalizado está en `init-scripts/01-schema.sql` e incluye:
- Tabla `usuarios` con campos: id, nombre, email, password, fecha_creacion, activo
- Tabla `roles_usuario` con relación a usuarios
- Funciones útiles para gestión de usuarios
- Vista `vista_usuarios_roles` para consultas combinadas

### Agregar bases de datos adicionales:
Modifica `init-scripts/01-schema.sql` y agrega:
```sql
CREATE DATABASE IF NOT EXISTS otra_db OWNER mi_usuario;
```

## �️ Esquema de Base de Datos

### Tablas principales:
- **`usuarios`**: Almacena información de usuarios con campos id, nombre, email, password, fecha_creacion, activo
- **`roles_usuario`**: Roles asignados a cada usuario con descripción

### Funciones disponibles:
```sql
-- Crear usuario con rol
SELECT crear_usuario_con_rol('Nombre', 'email@ejemplo.com', 'password_hash', 'NombreRol', 'Descripción');

-- Buscar usuarios
SELECT * FROM buscar_usuarios('termino_busqueda');

-- Cambiar estado de usuario
SELECT cambiar_estado_usuario(user_id, true/false);

-- Ver estadísticas
SELECT * FROM obtener_estadisticas_usuarios();
```

### Vistas disponibles:
- **`vista_usuarios_roles`**: Combina datos de usuarios y sus roles asignados

## �📊 Comandos Útiles

### Gestión de contenedores:
```powershell
# Iniciar servicios
docker-compose up -d

# Detener servicios
docker-compose down

# Ver logs
docker-compose logs postgres

# Reiniciar solo PostgreSQL
docker-compose restart postgres

# Ejecutar comandos en el contenedor
docker-compose exec postgres psql -U mi_usuario -d mi_base_datos
```

### Backup y restauración:
```powershell
# Crear backup
docker-compose exec postgres pg_dump -U mi_usuario mi_base_datos > backup.sql

# Restaurar backup
docker-compose exec -T postgres psql -U mi_usuario mi_base_datos < backup.sql
```

## 🔒 Seguridad

### Para producción, considera:

1. **Cambiar contraseñas por defecto**
2. **Restringir IPs en pg_hba.conf:**
   ```
   host all all 192.168.1.0/24 md5  # Solo red local
   ```
3. **Habilitar SSL en postgresql.conf:**
   ```
   ssl = on
   ```
4. **Usar certificados SSL**
5. **Configurar firewall del servidor**

## 🐛 Solución de Problemas

### Error de locales (lc_messages, lc_monetary, etc.):
Si obtienes errores como `invalid value for parameter "lc_messages": "es_ES.UTF-8"`:

**Opción 1 (Recomendada):** Usar configuración en inglés
```powershell
# La configuración actual ya está corregida con locales en inglés
docker-compose up -d --build
```

**Opción 2:** Usar configuración en español (requiere más tiempo de build)
```powershell
# Usar el docker-compose con locales en español
docker-compose -f docker-compose.spanish.yml up -d --build
```

### El contenedor no inicia:
```powershell
# Ver logs detallados
docker-compose logs postgres

# Verificar permisos de archivos de configuración
# En Windows, asegurar que los archivos tienen terminaciones de línea correctas
```

### No puedo conectar remotamente:
1. Verificar que el puerto 5432 esté abierto
2. Revisar configuración de firewall
3. Verificar que `listen_addresses = '*'` en postgresql.conf
4. Comprobar pg_hba.conf para permitir conexiones desde tu IP

### Problemas de performance:
- Ajustar `shared_buffers` y `effective_cache_size` en postgresql.conf
- Considerar usar volúmenes SSD para mejor rendimiento

## 📝 Notas

- Los datos se persisten en volúmenes Docker
- Los scripts en `init-scripts/` solo se ejecutan en la primera creación
- Para cambios en configuración, reinicia con `docker-compose restart postgres`
- Para cambios en estructura de BD, elimina volúmenes: `docker-compose down -v`

## 🆘 Soporte

Si encuentras problemas:
1. Revisa los logs: `docker-compose logs postgres`
2. Verifica la configuración de red
3. Comprueba las credenciales
4. Asegúrate de que Docker esté ejecutándose correctamente