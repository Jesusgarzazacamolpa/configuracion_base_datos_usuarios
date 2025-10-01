# Dockerfile para PostgreSQL con acceso remoto
FROM postgres:15

# Establecer variables de entorno por defecto
ENV POSTGRES_DB=mi_base_datos
ENV POSTGRES_USER=mi_usuario
ENV POSTGRES_PASSWORD=mi_contraseña_segura
ENV PGDATA=/var/lib/postgresql/data/pgdata

# Exponer el puerto de PostgreSQL
EXPOSE 5432

# Copiar archivos de configuración personalizados
COPY ./config/postgresql.conf /etc/postgresql/postgresql.conf
COPY ./config/pg_hba.conf /etc/postgresql/pg_hba.conf

# Copiar scripts de inicialización
COPY ./init-scripts/ /docker-entrypoint-initdb.d/

# Crear directorio para datos y establecer permisos
RUN mkdir -p /var/lib/postgresql/data/pgdata && \
    chown -R postgres:postgres /var/lib/postgresql/data

# Configurar PostgreSQL para usar nuestros archivos de configuración
RUN echo "include '/etc/postgresql/postgresql.conf'" >> /usr/share/postgresql/postgresql.conf.sample

# Comando por defecto
CMD ["postgres", "-c", "config_file=/etc/postgresql/postgresql.conf", "-c", "hba_file=/etc/postgresql/pg_hba.conf"]