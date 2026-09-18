-- 01. Realizar una nueva venta.

DELIMITER //

CREATE PROCEDURE sp_RealizarNuevaVenta(
    IN p_id_cliente INT,
    IN p_id_sucursal INT
)
BEGIN

    INSERT INTO ventas
    (
        id_cliente,
        id_sucursal,
        fecha_venta,
        estado,
        total
    )
    VALUES
    (
        p_id_cliente,
        p_id_sucursal,
        NOW(),
        'Pendiente de Pago',
        0
    );

END //

DELIMITER ;


-- 02. Agregar un nuevo producto.

DELIMITER //

CREATE PROCEDURE sp_AgregarNuevoProducto(
    IN p_nombre VARCHAR(100),
    IN p_descripcion TEXT,
    IN p_precio DECIMAL(10,2),
    IN p_costo DECIMAL(10,2),
    IN p_stock INT,
    IN p_sku VARCHAR(50),
    IN p_id_categoria INT,
    IN p_id_proveedor INT
)
BEGIN

    INSERT INTO productos
    (
        nombre,
        descripcion,
        precio,
        costo,
        stock,
        sku,
        id_categoria,
        id_proveedor
    )
    VALUES
    (
        p_nombre,
        p_descripcion,
        p_precio,
        p_costo,
        p_stock,
        p_sku,
        p_id_categoria,
        p_id_proveedor
    );

END //

DELIMITER ;


-- 03. Actualizar la dirección de un cliente.

DELIMITER //

CREATE PROCEDURE sp_ActualizarDireccionCliente(
    IN p_id_cliente INT,
    IN p_direccion VARCHAR(255)
)
BEGIN

    UPDATE clientes
    SET direccion_envio = p_direccion
    WHERE id_cliente = p_id_cliente;

END //

DELIMITER ;


-- 04. Procesar una devolución.

DELIMITER //

CREATE PROCEDURE sp_ProcesarDevolucion(
    IN p_id_venta INT,
    IN p_motivo VARCHAR(255)
)
BEGIN

    INSERT INTO devoluciones
    (
        id_venta,
        motivo,
        fecha_devolucion
    )
    VALUES
    (
        p_id_venta,
        p_motivo,
        NOW()
    );

END //

DELIMITER ;


-- 05. Obtener el historial de compras de un cliente.

DELIMITER //

CREATE PROCEDURE sp_ObtenerHistorialComprasCliente(
    IN p_id_cliente INT
)
BEGIN

    SELECT
        id_venta,
        fecha_venta,
        estado,
        total
    FROM ventas
    WHERE id_cliente = p_id_cliente
    ORDER BY fecha_venta DESC;

END //

DELIMITER ;


-- 06. Ajustar el nivel de stock de un producto.

DELIMITER //

CREATE PROCEDURE sp_AjustarNivelStock(
    IN p_id_producto INT,
    IN p_nuevo_stock INT
)
BEGIN

    UPDATE productos
    SET stock = p_nuevo_stock
    WHERE id_producto = p_id_producto;

END //

DELIMITER ;


-- 07. Eliminar un cliente de forma segura.

DELIMITER //

CREATE PROCEDURE sp_EliminarClienteDeFormaSegura(
    IN p_id_cliente INT
)
BEGIN

    UPDATE clientes
    SET activo = 0,
        fecha_eliminacion = NOW()
    WHERE id_cliente = p_id_cliente;

END //

DELIMITER ;


-- 08. Aplicar descuento por categoría.

DELIMITER //

CREATE PROCEDURE sp_AplicarDescuentoPorCategoria(
    IN p_id_categoria INT,
    IN p_descuento DECIMAL(10,2)
)
BEGIN

    UPDATE productos
    SET precio = precio - (precio * p_descuento / 100)
    WHERE id_categoria = p_id_categoria;

END //

DELIMITER ;


-- 09. Generar reporte mensual de ventas.

DELIMITER //

CREATE PROCEDURE sp_GenerarReporteMensualVentas(
    IN p_año INT,
    IN p_mes INT
)
BEGIN

    SELECT
        YEAR(fecha_venta) AS año,
        MONTH(fecha_venta) AS mes,
        COUNT(id_venta) AS cantidad_ventas,
        SUM(total) AS total_ventas
    FROM ventas
    WHERE YEAR(fecha_venta) = p_año
      AND MONTH(fecha_venta) = p_mes
    GROUP BY
        YEAR(fecha_venta),
        MONTH(fecha_venta);

END //

DELIMITER ;


-- 10. Cambiar el estado de un pedido.

DELIMITER //

CREATE PROCEDURE sp_CambiarEstadoPedido(
    IN p_id_venta INT,
    IN p_estado VARCHAR(50)
)
BEGIN

    UPDATE ventas
    SET estado = p_estado
    WHERE id_venta = p_id_venta;

END //

DELIMITER ;


-- 11. Registrar un nuevo cliente.

DELIMITER //

CREATE PROCEDURE sp_RegistrarNuevoCliente(
    IN p_nombre VARCHAR(100),
    IN p_apellido VARCHAR(100),
    IN p_email VARCHAR(150),
    IN p_contraseña VARCHAR(255),
    IN p_direccion VARCHAR(255),
    IN p_fecha_nacimiento DATE,
    IN p_ciudad VARCHAR(100),
    IN p_region VARCHAR(100)
)
BEGIN

    INSERT INTO clientes
    (
        nombre,
        apellido,
        email,
        contraseña,
        direccion_envio,
        fecha_nacimiento,
        ciudad,
        region,
        fecha_registro,
        activo
    )
    VALUES
    (
        p_nombre,
        p_apellido,
        p_email,
        p_contraseña,
        p_direccion,
        p_fecha_nacimiento,
        p_ciudad,
        p_region,
        NOW(),
        1
    );

END //

DELIMITER ;


-- 12. Obtener los detalles completos de un producto.

DELIMITER //

CREATE PROCEDURE sp_ObtenerDetallesProductoCompleto(
    IN p_id_producto INT
)
BEGIN

    SELECT
        p.id_producto,
        p.nombre,
        p.descripcion,
        p.precio,
        p.costo,
        p.stock,
        p.sku,
        c.nombre AS categoria,
        pr.nombre AS proveedor
    FROM productos p
    INNER JOIN categorias c
        ON p.id_categoria = c.id_categoria
    INNER JOIN proveedores pr
        ON p.id_proveedor = pr.id_proveedor
    WHERE p.id_producto = p_id_producto;

END //

DELIMITER ;


-- 13. Fusionar cuentas de clientes.

DELIMITER //

CREATE PROCEDURE sp_FusionarCuentasCliente(
    IN p_cliente_principal INT,
    IN p_cliente_secundario INT
)
BEGIN

    UPDATE ventas
    SET id_cliente = p_cliente_principal
    WHERE id_cliente = p_cliente_secundario;

    UPDATE clientes
    SET activo = 0,
        fecha_eliminacion = NOW()
    WHERE id_cliente = p_cliente_secundario;

END //

DELIMITER ;


-- 14. Asignar un producto a un proveedor.

DELIMITER //

CREATE PROCEDURE sp_AsignarProductoAProveedor(
    IN p_id_producto INT,
    IN p_id_proveedor INT
)
BEGIN

    UPDATE productos
    SET id_proveedor = p_id_proveedor
    WHERE id_producto = p_id_producto;

END //

DELIMITER ;


-- 15. Buscar productos.

DELIMITER //

CREATE PROCEDURE sp_BuscarProductos(
    IN p_nombre VARCHAR(100)
)
BEGIN

    SELECT
        id_producto,
        nombre,
        descripcion,
        precio,
        stock
    FROM productos
    WHERE nombre LIKE CONCAT('%', p_nombre, '%');

END //

DELIMITER ;


-- 16. Obtener dashboard del administrador.

DELIMITER //

CREATE PROCEDURE sp_ObtenerDashboardAdmin()
BEGIN

    SELECT
        (SELECT COUNT(*) FROM productos) AS total_productos,
        (SELECT COUNT(*) FROM clientes) AS total_clientes,
        (SELECT COUNT(*) FROM ventas) AS total_ventas,
        (SELECT SUM(total) FROM ventas) AS ingresos_totales;

END //

DELIMITER ;


-- 17. Procesar un pago.

DELIMITER //

CREATE PROCEDURE sp_ProcesarPago(
    IN p_id_venta INT,
    IN p_metodo_pago VARCHAR(50),
    IN p_monto DECIMAL(10,2)
)
BEGIN

    INSERT INTO pagos
    (
        id_venta,
        metodo_pago,
        monto,
        fecha_pago
    )
    VALUES
    (
        p_id_venta,
        p_metodo_pago,
        p_monto,
        NOW()
    );

    UPDATE ventas
    SET estado = 'Procesando'
    WHERE id_venta = p_id_venta;

END //

DELIMITER ;


-- 18. Añadir una reseña de producto.

DELIMITER //

CREATE PROCEDURE sp_AñadirReseñaProducto(
    IN p_id_cliente INT,
    IN p_id_producto INT,
    IN p_calificacion INT,
    IN p_comentario TEXT
)
BEGIN

    INSERT INTO resenas
    (
        id_cliente,
        id_producto,
        calificacion,
        comentario,
        fecha_resena
    )
    VALUES
    (
        p_id_cliente,
        p_id_producto,
        p_calificacion,
        p_comentario,
        NOW()
    );

END //

DELIMITER ;


-- 19. Obtener productos relacionados.

DELIMITER //

CREATE PROCEDURE sp_ObtenerProductosRelacionados(
    IN p_id_producto INT
)
BEGIN

    SELECT
        p2.id_producto,
        p2.nombre,
        p2.precio
    FROM productos p1
    INNER JOIN productos p2
        ON p1.id_categoria = p2.id_categoria
    WHERE p1.id_producto = p_id_producto
      AND p2.id_producto <> p_id_producto;

END //

DELIMITER ;


-- 20. Mover productos entre categorías.

DELIMITER //

CREATE PROCEDURE sp_MoverProductosEntreCategorias(
    IN p_categoria_actual INT,
    IN p_categoria_nueva INT
)
BEGIN

    UPDATE productos
    SET id_categoria = p_categoria_nueva
    WHERE id_categoria = p_categoria_actual;

END //

DELIMITER ;