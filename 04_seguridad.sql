-- 01. Crear el rol Administrador_Sistema con todos los privilegios.

CREATE ROLE 'Administrador_Sistema';

GRANT ALL PRIVILEGES
ON ecommerce.*
TO 'Administrador_Sistema';


-- 02. Crear el rol Gerente_Marketing con acceso de solo lectura a ventas y clientes.

CREATE ROLE 'Gerente_Marketing';

GRANT SELECT
ON ecommerce.ventas
TO 'Gerente_Marketing';

GRANT SELECT
ON ecommerce.clientes
TO 'Gerente_Marketing';


-- 03. Crear el rol Analista_Datos con acceso de solo lectura a todas las tablas, excepto a las de auditoría.

CREATE ROLE 'Analista_Datos';

GRANT SELECT
ON ecommerce.*
TO 'Analista_Datos';


-- 04. Crear el rol Empleado_Inventario que solo pueda modificar la tabla productos (stock y ubicación).

CREATE ROLE 'Empleado_Inventario';

GRANT UPDATE (stock, ubicacion)
ON ecommerce.productos
TO 'Empleado_Inventario';


-- 05. Crear el rol Atencion_Cliente que pueda ver clientes y ventas, pero no modificar precios.

CREATE ROLE 'Atencion_Cliente';

GRANT SELECT
ON ecommerce.clientes
TO 'Atencion_Cliente';

GRANT SELECT
ON ecommerce.ventas
TO 'Atencion_Cliente';


-- 06. Crear el rol Auditor_Financiero con acceso de solo lectura a ventas, productos y logs de precios.

CREATE ROLE 'Auditor_Financiero';

GRANT SELECT
ON ecommerce.ventas
TO 'Auditor_Financiero';

GRANT SELECT
ON ecommerce.productos
TO 'Auditor_Financiero';

GRANT SELECT
ON ecommerce.log_cambios_precio
TO 'Auditor_Financiero';


-- 07. Crear un usuario admin_user y asignarle el rol de administrador.

CREATE USER 'admin_user'@'localhost'
IDENTIFIED BY 'Admin123';

GRANT 'Administrador_Sistema'
TO 'admin_user'@'localhost';


-- 08. Crear un usuario marketing_user y asignarle el rol de marketing.

CREATE USER 'marketing_user'@'localhost'
IDENTIFIED BY 'Marketing123';

GRANT 'Gerente_Marketing'
TO 'marketing_user'@'localhost';


-- 09. Crear un usuario inventory_user y asignarle el rol de inventario.

CREATE USER 'inventory_user'@'localhost'
IDENTIFIED BY 'Inventory123';

GRANT 'Empleado_Inventario'
TO 'inventory_user'@'localhost';


-- 10. Crear un usuario support_user y asignarle el rol de atención al cliente.

CREATE USER 'support_user'@'localhost'
IDENTIFIED BY 'Support123';

GRANT 'Atencion_Cliente'
TO 'support_user'@'localhost';


-- 11. Impedir que el rol Analista_Datos pueda ejecutar comandos DELETE o TRUNCATE.

REVOKE DELETE
ON ecommerce.*
FROM 'Analista_Datos';

REVOKE DROP
ON ecommerce.*
FROM 'Analista_Datos';


-- 12. Otorgar al rol Gerente_Marketing permiso para ejecutar procedimientos almacenados de reportes de marketing.

GRANT EXECUTE
ON PROCEDURE ecommerce.sp_GenerarReporteMensualVentas
TO 'Gerente_Marketing';


-- 13. Crear una vista v_info_clientes_basica que oculte información sensible y dar acceso a ella al rol Atencion_Cliente.

CREATE VIEW v_info_clientes_basica AS
SELECT
    id_cliente,
    nombre,
    apellido,
    email,
    ciudad,
    region,
    fecha_registro
FROM clientes;

GRANT SELECT
ON ecommerce.v_info_clientes_basica
TO 'Atencion_Cliente';


-- 14. Revocar el permiso de UPDATE sobre la columna precio de la tabla productos al rol Empleado_Inventario.

REVOKE UPDATE (precio)
ON ecommerce.productos
FROM 'Empleado_Inventario';


-- 15. Implementar una política de contraseñas seguras para todos los usuarios.

ALTER USER 'admin_user'@'localhost'
IDENTIFIED BY 'Admin123';

ALTER USER 'marketing_user'@'localhost'
IDENTIFIED BY 'Marketing123';

ALTER USER 'inventory_user'@'localhost'
IDENTIFIED BY 'Inventory123';

ALTER USER 'support_user'@'localhost'
IDENTIFIED BY 'Support123';


-- 15. Implementar una política de contraseñas seguras para todos los usuarios.

SET GLOBAL validate_password.length = 8;

SET GLOBAL validate_password.number_count = 1;

SET GLOBAL validate_password.mixed_case_count = 1;

SET GLOBAL validate_password.mixed_case_count = 1;

SET GLOBAL validate_password.special_char_count = 1;



-- 16. Asegurar que el usuario root no pueda ser usado desde conexiones remotas.

DROP USER 'root'@'%';


-- 17. Crear un rol Visitante que solo pueda ver la tabla productos.

CREATE ROLE 'Visitante';

GRANT SELECT
ON ecommerce.productos
TO 'Visitante';


-- 18. Limitar el número de consultas por hora para el rol Analista_Datos para evitar sobrecarga.

CREATE USER 'analista_user'@'localhost'
IDENTIFIED BY 'Analista123!'
WITH MAX_QUERIES_PER_HOUR 50;

GRANT 'Analista_Datos'
TO 'analista_user'@'localhost';


-- 19. Asegurar que los usuarios solo puedan ver las ventas de la sucursal a la que pertenecen (requiere añadir id_sucursal).

CREATE VIEW v_ventas_sucursal AS
SELECT
    id_venta,
    id_sucursal,
    id_cliente,
    fecha_venta,
    estado,
    total
FROM ventas;

GRANT SELECT
ON ecommerce.v_ventas_sucursal
TO 'Atencion_Cliente';


-- 20. Auditar todos los intentos de inicio de sesión fallidos en la base de datos.

-- Los intentos fallidos de inicio de sesión
-- requieren un sistema de auditoría de MySQL
-- o de la aplicación.
--Quizás podría hacerse con un SET GLOBAL audit_log, o algo parecido pero
--el login falla antes de ingresar a la base de datos específica, por lo que 
-- registraría el fallo de otras bases de datos y no solamente esta.


