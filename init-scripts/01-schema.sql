-- Script de inicialización para PostgreSQL con tu esquema personalizado
-- Este script se ejecuta automáticamente cuando se crea el contenedor por primera vez

-- Crear usuario adicional con permisos específicos para acceso remoto
DO
$do$
BEGIN
   IF NOT EXISTS (
      SELECT FROM pg_catalog.pg_roles
      WHERE  rolname = 'usuario_remoto') THEN

      CREATE ROLE usuario_remoto LOGIN PASSWORD 'contraseña_remota';
   END IF;
END
$do$;

-- Otorgar permisos al usuario remoto sobre la base de datos
GRANT CONNECT ON DATABASE usuarios TO usuario_remoto;
GRANT USAGE ON SCHEMA public TO usuario_remoto;
GRANT CREATE ON SCHEMA public TO usuario_remoto;

-- Tu esquema original
CREATE TABLE IF NOT EXISTS usuarios (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS roles_usuario (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    descripcion VARCHAR(255),
    usuario_id BIGINT NOT NULL UNIQUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
);

-- Otorgar permisos sobre las tablas a los usuarios remotos
GRANT SELECT, INSERT, UPDATE, DELETE ON usuarios TO usuario_remoto;
GRANT SELECT, INSERT, UPDATE, DELETE ON roles_usuario TO usuario_remoto;
GRANT USAGE, SELECT ON SEQUENCE usuarios_id_seq TO usuario_remoto;
GRANT USAGE, SELECT ON SEQUENCE roles_usuario_id_seq TO usuario_remoto;

-- Insertar algunos datos de ejemplo (opcional)
INSERT INTO usuarios (nombre, email, password) VALUES 
    ('Administrador', 'admin@ejemplo.com', '$2b$10$example_hash_password_1'),
    ('Usuario Demo', 'demo@ejemplo.com', '$2b$10$example_hash_password_2')
ON CONFLICT (email) DO NOTHING;

-- Insertar roles para los usuarios de ejemplo
INSERT INTO roles_usuario (nombre, descripcion, usuario_id) 
SELECT 'Administrador', 'Usuario con permisos completos', u.id 
FROM usuarios u 
WHERE u.email = 'admin@ejemplo.com'
AND NOT EXISTS (SELECT 1 FROM roles_usuario WHERE usuario_id = u.id);

INSERT INTO roles_usuario (nombre, descripcion, usuario_id) 
SELECT 'Usuario', 'Usuario estándar con permisos limitados', u.id 
FROM usuarios u 
WHERE u.email = 'demo@ejemplo.com'
AND NOT EXISTS (SELECT 1 FROM roles_usuario WHERE usuario_id = u.id);

-- Crear índices para mejor rendimiento
CREATE INDEX IF NOT EXISTS idx_usuarios_email ON usuarios(email);
CREATE INDEX IF NOT EXISTS idx_usuarios_activo ON usuarios(activo);
CREATE INDEX IF NOT EXISTS idx_roles_usuario_id ON roles_usuario(usuario_id);

-- Crear función de utilidad para obtener información
CREATE OR REPLACE FUNCTION obtener_estadisticas_usuarios()
RETURNS TABLE(total_usuarios INTEGER, usuarios_activos INTEGER, total_roles INTEGER) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        (SELECT COUNT(*)::INTEGER FROM usuarios),
        (SELECT COUNT(*)::INTEGER FROM usuarios WHERE activo = TRUE),
        (SELECT COUNT(*)::INTEGER FROM roles_usuario);
END;
$$ LANGUAGE plpgsql;

-- Otorgar permisos sobre la función
GRANT EXECUTE ON FUNCTION obtener_estadisticas_usuarios() TO usuario_remoto;

-- Mensaje de confirmación
DO $$
DECLARE
    stats RECORD;
BEGIN
    SELECT * INTO stats FROM obtener_estadisticas_usuarios();
    RAISE NOTICE '============================================';
    RAISE NOTICE 'Base de datos inicializada correctamente';
    RAISE NOTICE '============================================';
    RAISE NOTICE 'Usuario principal: jesusgarza';
    RAISE NOTICE 'Usuario remoto: usuario_remoto';
    RAISE NOTICE 'Total usuarios creados: %', stats.total_usuarios;
    RAISE NOTICE 'Usuarios activos: %', stats.usuarios_activos;
    RAISE NOTICE 'Total roles asignados: %', stats.total_roles;
    RAISE NOTICE '============================================';
END $$;
