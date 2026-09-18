-- 01. Generar reporte semanal de ventas.

DELIMITER //

CREATE EVENT ev_reporte_ventas_semanal
ON SCHEDULE EVERY 1 WEEK
DO
BEGIN

    INSERT INTO reporte_ventas_semanales
    (
        fecha_reporte,
        total_ventas,
        cantidad_ventas
    )
    SELECT
        NOW(),
        SUM(total),
        COUNT(id_venta)
    FROM ventas
    WHERE fecha_venta >= DATE_SUB(NOW(), INTERVAL 7 DAY);

END //

DELIMITER ;


-- 02. Limpiar datos temporales diariamente.

DELIMITER //

CREATE EVENT ev_limpiar_datos_temporales
ON SCHEDULE EVERY 1 DAY
DO
BEGIN

    DELETE FROM carritos
    WHERE fecha_creacion < DATE_SUB(NOW(), INTERVAL 1 DAY);

END //

DELIMITER ;


-- 03. Archivar logs antiguos mensualmente.

DELIMITER //

CREATE EVENT ev_archivar_logs
ON SCHEDULE EVERY 1 MONTH
DO
BEGIN

    DELETE FROM log_login
    WHERE fecha_login < DATE_SUB(NOW(), INTERVAL 6 MONTH);

END //

DELIMITER ;


-- 04. Desactivar promociones expiradas cada hora.

DELIMITER //

CREATE EVENT ev_desactivar_promociones
ON SCHEDULE EVERY 1 HOUR
DO
BEGIN

    UPDATE promociones
    SET activo = 0
    WHERE fecha_fin < NOW();

END //

DELIMITER ;


-- 05. Recalcular niveles de lealtad cada noche.

DELIMITER //

CREATE EVENT ev_recalcular_lealtad
ON SCHEDULE EVERY 1 DAY
DO
BEGIN

    UPDATE clientes
    SET nivel_lealtad =
        CASE
            WHEN total_gastado >= 10000 THEN 'Oro'
            WHEN total_gastado >= 5000 THEN 'Plata'
            ELSE 'Bronce'
        END;

END //

DELIMITER ;


-- 06. Generar diariamente la lista de reabastecimiento.

DELIMITER //

CREATE EVENT ev_lista_reabastecimiento
ON SCHEDULE EVERY 1 DAY
DO
BEGIN

    INSERT INTO lista_reabastecimiento
    (
        id_producto,
        stock_actual,
        stock_minimo,
        fecha_reporte
    )
    SELECT
        id_producto,
        stock,
        stock_minimo,
        NOW()
    FROM productos
    WHERE stock < stock_minimo;

END //

DELIMITER ;


-- 07. Reconstruir índices semanalmente.

DELIMITER //

CREATE EVENT ev_reconstruir_indices
ON SCHEDULE EVERY 1 WEEK
DO
BEGIN

    ANALYZE TABLE productos;
    ANALYZE TABLE ventas;
    ANALYZE TABLE detalle_venta;

END //

DELIMITER ;


-- 08. Suspender cuentas inactivas trimestralmente.

DELIMITER //

CREATE EVENT ev_suspender_cuentas
ON SCHEDULE EVERY 3 MONTH
DO
BEGIN

    UPDATE clientes
    SET activo = 0
    WHERE ultima_fecha_pedido < DATE_SUB(NOW(), INTERVAL 1 YEAR);

END //

DELIMITER ;


-- 09. Crear resumen diario de ventas.

DELIMITER //

CREATE EVENT ev_resumen_ventas_diarias
ON SCHEDULE EVERY 1 DAY
DO
BEGIN

    INSERT INTO resumen_ventas_diarias
    (
        fecha,
        total_ventas,
        cantidad_ventas
    )
    SELECT
        CURDATE(),
        SUM(total),
        COUNT(id_venta)
    FROM ventas
    WHERE DATE(fecha_venta) = CURDATE();

END //

DELIMITER ;


-- 10. Revisar la consistencia de los datos cada noche.

DELIMITER //

CREATE EVENT ev_consistencia_datos
ON SCHEDULE EVERY 1 DAY
DO
BEGIN

    INSERT INTO inconsistencias_datos
    (
        descripcion,
        fecha_revision
    )
    SELECT
        'Venta sin cliente',
        NOW()
    FROM ventas
    WHERE id_cliente IS NULL;

END //

DELIMITER ;


-- 11. Generar felicitaciones de cumpleaños diariamente.

DELIMITER //

CREATE EVENT ev_felicitaciones_cumpleanos
ON SCHEDULE EVERY 1 DAY
DO
BEGIN

    INSERT INTO felicitaciones_cumpleanos
    (
        id_cliente,
        fecha,
        mensaje
    )
    SELECT
        id_cliente,
        CURDATE(),
        'Feliz cumpleaños'
    FROM clientes
    WHERE MONTH(fecha_nacimiento) = MONTH(CURDATE())
      AND DAY(fecha_nacimiento) = DAY(CURDATE());

END //

DELIMITER ;


-- 12. Actualizar ranking de productos cada hora.

DELIMITER //

CREATE EVENT ev_ranking_productos
ON SCHEDULE EVERY 1 HOUR
DO
BEGIN

    INSERT INTO ranking_productos
    (
        id_producto,
        cantidad_vendida,
        fecha_ranking
    )
    SELECT
        id_producto,
        SUM(cantidad),
        NOW()
    FROM detalle_venta
    GROUP BY id_producto;

END //

DELIMITER ;


-- 13. Realizar respaldo crítico diariamente.

DELIMITER //

CREATE EVENT ev_respaldo_diario
ON SCHEDULE EVERY 1 DAY
DO
BEGIN

    INSERT INTO logs_tamano_bd
    (
        fecha,
        descripcion
    )
    VALUES
    (
        NOW(),
        'Respaldo diario programado'
    );

END //

DELIMITER ;


-- 14. Limpiar carritos abandonados después de 72 horas.

DELIMITER //

CREATE EVENT ev_limpiar_carritos_abandonados
ON SCHEDULE EVERY 1 DAY
DO
BEGIN

    DELETE FROM carritos
    WHERE fecha_creacion < DATE_SUB(NOW(), INTERVAL 72 HOUR);

END //

DELIMITER ;


-- 15. Calcular KPIs mensuales.

DELIMITER //

CREATE EVENT ev_kpis_mensuales
ON SCHEDULE EVERY 1 MONTH
DO
BEGIN

    INSERT INTO kpis_mensuales
    (
        mes,
        total_ventas,
        cantidad_ventas
    )
    SELECT
        DATE_FORMAT(CURDATE(), '%Y-%m'),
        SUM(total),
        COUNT(id_venta)
    FROM ventas
    WHERE MONTH(fecha_venta) = MONTH(CURDATE())
      AND YEAR(fecha_venta) = YEAR(CURDATE());

END //

DELIMITER ;


-- 16. Actualizar la vista materializada durante la noche.

DELIMITER //

CREATE EVENT ev_actualizar_vista_materializada
ON SCHEDULE EVERY 1 DAY
DO
BEGIN

    INSERT INTO ranking_productos
    (
        id_producto,
        cantidad_vendida,
        fecha_ranking
    )
    SELECT
        id_producto,
        SUM(cantidad),
        NOW()
    FROM detalle_venta
    GROUP BY id_producto;

END //

DELIMITER ;


-- 17. Registrar semanalmente el tamaño de la base de datos.

DELIMITER //

CREATE EVENT ev_tamano_base_datos
ON SCHEDULE EVERY 1 WEEK
DO
BEGIN

    INSERT INTO logs_tamano_bd
    (
        fecha,
        descripcion
    )
    VALUES
    (
        NOW(),
        'Registro semanal del tamaño de la base de datos'
    );

END //

DELIMITER ;


-- 18. Detectar posibles fraudes cada hora.

DELIMITER //

CREATE EVENT ev_deteccion_fraude
ON SCHEDULE EVERY 1 HOUR
DO
BEGIN

    INSERT INTO alertas_fraude
    (
        id_cliente,
        descripcion,
        fecha_alerta
    )
    SELECT
        id_cliente,
        'Cliente con muchas compras recientes',
        NOW()
    FROM ventas
    WHERE fecha_venta >= DATE_SUB(NOW(), INTERVAL 1 HOUR)
    GROUP BY id_cliente
    HAVING COUNT(*) >= 5;

END //

DELIMITER ;


-- 19. Generar mensualmente el rendimiento de proveedores.

DELIMITER //

CREATE EVENT ev_rendimiento_proveedores
ON SCHEDULE EVERY 1 MONTH
DO
BEGIN

    INSERT INTO rendimiento_proveedores
    (
        id_proveedor,
        unidades_vendidas,
        fecha_reporte
    )
    SELECT
        p.id_proveedor,
        SUM(dv.cantidad),
        NOW()
    FROM productos p
    INNER JOIN detalle_venta dv
        ON p.id_producto = dv.id_producto
    GROUP BY p.id_proveedor;

END //

DELIMITER ;


-- 20. Eliminar semanalmente registros eliminados con más de 30 días.

DELIMITER //

CREATE EVENT ev_purgar_registros_eliminados
ON SCHEDULE EVERY 1 WEEK
DO
BEGIN

    DELETE FROM log_ventas_eliminadas
    WHERE fecha_eliminacion < DATE_SUB(NOW(), INTERVAL 30 DAY);

END //

DELIMITER ;