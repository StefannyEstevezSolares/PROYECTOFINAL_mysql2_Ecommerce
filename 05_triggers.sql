-- 01. Auditar cambios de precio.

DELIMITER //

CREATE TRIGGER tr_auditar_cambio_precio
AFTER UPDATE ON productos
FOR EACH ROW
BEGIN

    IF OLD.precio <> NEW.precio THEN

        INSERT INTO log_cambios_precio
        (
            id_producto,
            precio_anterior,
            precio_nuevo,
            fecha_cambio
        )
        VALUES
        (
            NEW.id_producto,
            OLD.precio,
            NEW.precio,
            NOW()
        );

    END IF;

END //

DELIMITER ;


-- 02. Verificar stock antes de realizar una venta.

DELIMITER //

CREATE TRIGGER tr_verificar_stock
BEFORE INSERT ON detalle_venta
FOR EACH ROW
BEGIN

    DECLARE stock_actual INT;

    SELECT stock
    INTO stock_actual
    FROM productos
    WHERE id_producto = NEW.id_producto;

    IF stock_actual < NEW.cantidad THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Stock insuficiente';
    END IF;

END //

DELIMITER ;


-- 03. Descontar stock después de realizar una venta.

DELIMITER //

CREATE TRIGGER tr_descontar_stock
AFTER INSERT ON detalle_venta
FOR EACH ROW
BEGIN

    UPDATE productos
    SET stock = stock - NEW.cantidad
    WHERE id_producto = NEW.id_producto;

END //

DELIMITER ;


-- 04. Impedir eliminar una categoría que tenga productos.

DELIMITER //

CREATE TRIGGER tr_prevenir_eliminar_categoria
BEFORE DELETE ON categorias
FOR EACH ROW
BEGIN

    DECLARE cantidad_productos INT;

    SELECT COUNT(*)
    INTO cantidad_productos
    FROM productos
    WHERE id_categoria = OLD.id_categoria;

    IF cantidad_productos > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se puede eliminar una categoría con productos';
    END IF;

END //

DELIMITER ;


-- 05. Registrar un nuevo cliente.

DELIMITER //

CREATE TRIGGER tr_registrar_cliente
AFTER INSERT ON clientes
FOR EACH ROW
BEGIN

    INSERT INTO log_clientes
    (
        id_cliente,
        nombre,
        fecha_registro
    )
    VALUES
    (
        NEW.id_cliente,
        CONCAT(NEW.nombre, ' ', NEW.apellido),
        NOW()
    );

END //

DELIMITER ;


-- 06. Actualizar el total gastado del cliente.

DELIMITER //

CREATE TRIGGER tr_actualizar_total_cliente
AFTER INSERT ON ventas
FOR EACH ROW
BEGIN

    UPDATE clientes
    SET total_gastado = total_gastado + NEW.total
    WHERE id_cliente = NEW.id_cliente;

END //

DELIMITER ;


-- 07. Actualizar la fecha de modificación del producto.

DELIMITER //

CREATE TRIGGER tr_actualizar_fecha_producto
BEFORE UPDATE ON productos
FOR EACH ROW
BEGIN

    SET NEW.fecha_modificacion = NOW();

END //

DELIMITER ;


-- 08. Impedir que el stock sea negativo.

DELIMITER //

CREATE TRIGGER tr_prevenir_stock_negativo
BEFORE UPDATE ON productos
FOR EACH ROW
BEGIN

    IF NEW.stock < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El stock no puede ser negativo';
    END IF;

END //

DELIMITER ;


-- 09. Convertir nombre y apellido del cliente a mayúsculas iniciales.

DELIMITER //

CREATE TRIGGER tr_formatear_nombre_cliente
BEFORE INSERT ON clientes
FOR EACH ROW
BEGIN

    SET NEW.nombre = CONCAT(
        UPPER(LEFT(NEW.nombre, 1)),
        LOWER(SUBSTRING(NEW.nombre, 2))
    );

    SET NEW.apellido = CONCAT(
        UPPER(LEFT(NEW.apellido, 1)),
        LOWER(SUBSTRING(NEW.apellido, 2))
    );

END //

DELIMITER ;


-- 10. Recalcular el total de la venta cuando cambie su detalle.

DELIMITER //

CREATE TRIGGER tr_recalcular_total_venta
AFTER INSERT ON detalle_venta
FOR EACH ROW
BEGIN

    UPDATE ventas
    SET total = (
        SELECT SUM(cantidad * precio_unitario_congelado)
        FROM detalle_venta
        WHERE id_venta = NEW.id_venta
    )
    WHERE id_venta = NEW.id_venta;

END //

DELIMITER ;


-- 11. Registrar cambios en el estado de una venta.

DELIMITER //

CREATE TRIGGER tr_registrar_cambio_estado
AFTER UPDATE ON ventas
FOR EACH ROW
BEGIN

    IF OLD.estado <> NEW.estado THEN

        INSERT INTO log_estados_venta
        (
            id_venta,
            estado_anterior,
            estado_nuevo,
            fecha_cambio
        )
        VALUES
        (
            NEW.id_venta,
            OLD.estado,
            NEW.estado,
            NOW()
        );

    END IF;

END //

DELIMITER ;


-- 12. Impedir registrar productos con precio menor o igual a cero.

DELIMITER //

CREATE TRIGGER tr_validar_precio_producto
BEFORE INSERT ON productos
FOR EACH ROW
BEGIN

    IF NEW.precio <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El precio debe ser mayor que cero';
    END IF;

END //

DELIMITER ;


-- 13. Generar una alerta cuando el stock llegue al mínimo.

DELIMITER //

CREATE TRIGGER tr_alerta_stock
AFTER UPDATE ON productos
FOR EACH ROW
BEGIN

    IF NEW.stock <= NEW.stock_minimo THEN

        INSERT INTO alertas_stock
        (
            id_producto,
            stock_actual,
            stock_minimo,
            fecha_alerta
        )
        VALUES
        (
            NEW.id_producto,
            NEW.stock,
            NEW.stock_minimo,
            NOW()
        );

    END IF;

END //

DELIMITER ;


-- 14. Archivar una venta antes de eliminarla.

DELIMITER //

CREATE TRIGGER tr_archivar_venta
BEFORE DELETE ON ventas
FOR EACH ROW
BEGIN

    INSERT INTO log_ventas_eliminadas
    (
        id_venta,
        id_cliente,
        fecha_venta,
        total,
        fecha_eliminacion
    )
    VALUES
    (
        OLD.id_venta,
        OLD.id_cliente,
        OLD.fecha_venta,
        OLD.total,
        NOW()
    );

END //

DELIMITER ;


-- 15. Validar el correo electrónico del cliente.

DELIMITER //

CREATE TRIGGER tr_validar_email_cliente
BEFORE INSERT ON clientes
FOR EACH ROW
BEGIN

    IF NEW.email NOT LIKE '%@%.%' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El correo electrónico no es válido';
    END IF;

END //

DELIMITER ;


-- 16. Actualizar la fecha del último pedido del cliente.

DELIMITER //

CREATE TRIGGER tr_actualizar_ultimo_pedido
AFTER INSERT ON ventas
FOR EACH ROW
BEGIN

    UPDATE clientes
    SET ultima_fecha_pedido = NEW.fecha_venta
    WHERE id_cliente = NEW.id_cliente;

END //

DELIMITER ;


-- 17. Impedir que un cliente se refiera a sí mismo.

DELIMITER //

CREATE TRIGGER tr_prevenir_autoreferencia
BEFORE INSERT ON clientes
FOR EACH ROW
BEGIN

    IF NEW.id_cliente_referidor = NEW.id_cliente THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Un cliente no puede referirse a sí mismo';
    END IF;

END //

DELIMITER ;


-- 18. Registrar cambios de permisos.

-- Los cambios de permisos realizados con
-- GRANT o REVOKE no pueden ser detectados
-- mediante un trigger normal de una tabla :3


-- 19. Asignar la categoría General si el producto no tiene categoría.

DELIMITER //

CREATE TRIGGER tr_categoria_general
BEFORE INSERT ON productos
FOR EACH ROW
BEGIN

    IF NEW.id_categoria IS NULL THEN

        SET NEW.id_categoria = (
            SELECT id_categoria
            FROM categorias
            WHERE nombre = 'General'
            LIMIT 1
        );

    END IF;

END //

DELIMITER ;


-- 20. Actualizar la cantidad de productos de una categoría.

DELIMITER //

CREATE TRIGGER tr_actualizar_cantidad_categoria
AFTER INSERT ON productos
FOR EACH ROW
BEGIN

    UPDATE categorias
    SET cantidad_productos = cantidad_productos + 1
    WHERE id_categoria = NEW.id_categoria;

END //

DELIMITER ;