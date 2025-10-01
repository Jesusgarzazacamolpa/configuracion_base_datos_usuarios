-- Funciones y vistas adicionales para el esquema de usuarios y roles
-- Este archivo se ejecuta después del esquema principal

-- Vista para obtener usuarios con sus roles
CREATE OR REPLACE VIEW vista_usuarios_roles AS
SELECT 
    u.id as usuario_id,
    u.nombre as usuario_nombre,
    u.email,
    u.activo,
    u.fecha_creacion as usuario_creado,
    r.id as rol_id,
    r.nombre as rol_nombre,
    r.descripcion as rol_descripcion,
    r.fecha_creacion as rol_asignado
FROM usuarios u
LEFT JOIN roles_usuario r ON u.id = r.usuario_id
ORDER BY u.nombre;

-- Función para crear un usuario con rol
CREATE OR REPLACE FUNCTION crear_usuario_con_rol(
    p_nombre VARCHAR(255),
    p_email VARCHAR(255),
    p_password VARCHAR(255),
    p_rol_nombre VARCHAR(50),
    p_rol_descripcion VARCHAR(255) DEFAULT NULL
)
RETURNS INTEGER AS $$
DECLARE
    nuevo_usuario_id INTEGER;
BEGIN
    -- Insertar usuario
    INSERT INTO usuarios (nombre, email, password)
    VALUES (p_nombre, p_email, p_password)
    RETURNING id INTO nuevo_usuario_id;
    
    -- Insertar rol
    INSERT INTO roles_usuario (nombre, descripcion, usuario_id)
    VALUES (p_rol_nombre, COALESCE(p_rol_descripcion, 'Rol asignado automáticamente'), nuevo_usuario_id);
    
    RETURN nuevo_usuario_id;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error al crear usuario: %', SQLERRM;
        RETURN -1;
END;
$$ LANGUAGE plpgsql;

-- Función para cambiar el estado activo de un usuario
CREATE OR REPLACE FUNCTION cambiar_estado_usuario(
    p_usuario_id INTEGER,
    p_activo BOOLEAN
)
RETURNS BOOLEAN AS $$
BEGIN
    UPDATE usuarios 
    SET activo = p_activo 
    WHERE id = p_usuario_id;
    
    IF FOUND THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Función para buscar usuarios por nombre o email
CREATE OR REPLACE FUNCTION buscar_usuarios(p_termino VARCHAR(255))
RETURNS TABLE(
    id INTEGER,
    nombre VARCHAR(255),
    email VARCHAR(255),
    activo BOOLEAN,
    rol_nombre VARCHAR(50)
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        u.id,
        u.nombre,
        u.email,
        u.activo,
        r.nombre as rol_nombre
    FROM usuarios u
    LEFT JOIN roles_usuario r ON u.id = r.usuario_id
    WHERE u.nombre ILIKE '%' || p_termino || '%' 
       OR u.email ILIKE '%' || p_termino || '%'
    ORDER BY u.nombre;
END;
$$ LANGUAGE plpgsql;

-- Trigger para actualizar fecha de modificación (si agregas esta columna)
-- CREATE OR REPLACE FUNCTION actualizar_fecha_modificacion()
-- RETURNS TRIGGER AS $$
-- BEGIN
--     NEW.fecha_modificacion = CURRENT_TIMESTAMP;
--     RETURN NEW;
-- END;
-- $$ LANGUAGE plpgsql;

-- Otorgar permisos sobre las nuevas funciones y vistas
GRANT SELECT ON vista_usuarios_roles TO usuario_remoto;
GRANT EXECUTE ON FUNCTION crear_usuario_con_rol(VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR) TO usuario_remoto;
GRANT EXECUTE ON FUNCTION cambiar_estado_usuario(INTEGER, BOOLEAN) TO usuario_remoto;
GRANT EXECUTE ON FUNCTION buscar_usuarios(VARCHAR) TO usuario_remoto;

-- Ejemplos de uso (comentados para no ejecutar automáticamente)
/*
-- Ejemplo 1: Crear un usuario con rol
SELECT crear_usuario_con_rol(
    'Juan Pérez',
    'juan@ejemplo.com',
    '$2b$10$ejemplo_hash',
    'Editor',
    'Usuario con permisos de edición'
);

-- Ejemplo 2: Buscar usuarios
SELECT * FROM buscar_usuarios('admin');

-- Ejemplo 3: Ver todos los usuarios con roles
SELECT * FROM vista_usuarios_roles;

-- Ejemplo 4: Desactivar un usuario
SELECT cambiar_estado_usuario(1, false);

-- Ejemplo 5: Obtener estadísticas
SELECT * FROM obtener_estadisticas_usuarios();
*/

-- Mensaje de confirmación (envuelto en bloque DO)
DO $$
BEGIN
    RAISE NOTICE 'Funciones y vistas adicionales creadas correctamente';
END $$;