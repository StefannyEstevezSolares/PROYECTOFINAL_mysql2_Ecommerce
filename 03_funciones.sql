-- 01. CALCULAR TOTAL DE UNA VENTA

DELIMITER //

CREATE FUNCTION fn_CalcularTotalVenta(p_id_venta INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
READS SQL DATA
BEGIN

    DECLARE total_venta DECIMAL(10,2);

    SELECT SUM(cantidad * precio_unitario_congelado)
    INTO total_venta
    FROM detalle_venta
    WHERE id_venta = p_id_venta;

    RETURN total_venta;

END //

DELIMITER ;


-- 02. VERIFICAR DISPONIBILIDAD DE STOCK

DELIMITER //

CREATE FUNCTION fn_VerificarDisponibilidadStock(
    p_id_producto INT,
    p_cantidad INT
)
RETURNS BOOLEAN
DETERMINISTIC
READS SQL DATA
BEGIN

    DECLARE stock_actual INT;

    SELECT stock
    INTO stock_actual
    FROM productos
    WHERE id_producto = p_id_producto;

    RETURN stock_actual >= p_cantidad;

END //

DELIMITER ;


-- 03. OBTENER PRECIO DE UN PRODUCTO

DELIMITER //

CREATE FUNCTION fn_ObtenerPrecioProducto(p_id_producto INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
READS SQL DATA
BEGIN

    DECLARE precio_actual DECIMAL(10,2);

    SELECT precio
    INTO precio_actual
    FROM productos
    WHERE id_producto = p_id_producto;

    RETURN precio_actual;

END //

DELIMITER ;


-- 04. CALCULAR EDAD DEL CLIENTE

DELIMITER //

CREATE FUNCTION fn_CalcularEdadCliente(p_id_cliente INT)
RETURNS INT
NOT DETERMINISTIC
READS SQL DATA
BEGIN

    DECLARE edad INT;

    SELECT TIMESTAMPDIFF(
        YEAR,
        fecha_nacimiento,
        CURDATE()
    )
    INTO edad
    FROM clientes
    WHERE id_cliente = p_id_cliente;

    RETURN edad;

END //

DELIMITER ;


-- 05. FORMATEAR NOMBRE COMPLETO

DELIMITER //

CREATE FUNCTION fn_FormatearNombreCompleto(p_id_cliente INT)
RETURNS VARCHAR(100)
DETERMINISTIC
READS SQL DATA
BEGIN

    DECLARE nombre_completo VARCHAR(100);

    SELECT CONCAT(nombre, ' ', apellido)
    INTO nombre_completo
    FROM clientes
    WHERE id_cliente = p_id_cliente;

    RETURN nombre_completo;

END //

DELIMITER ;


-- 06. VERIFICAR SI EL CLIENTE ES NUEVO

DELIMITER //

CREATE FUNCTION fn_EsClienteNuevo(p_id_cliente INT)
RETURNS BOOLEAN
NOT DETERMINISTIC
READS SQL DATA
BEGIN

    DECLARE primera_compra DATE;

    SELECT MIN(fecha_venta)
    INTO primera_compra
    FROM ventas
    WHERE id_cliente = p_id_cliente;

    RETURN primera_compra >= DATE_SUB(CURDATE(), INTERVAL 30 DAY);

END //

DELIMITER ;


-- 07. CALCULAR COSTO DE ENVÍO

DELIMITER //

CREATE FUNCTION fn_CalcularCostoEnvio(p_id_venta INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
READS SQL DATA
BEGIN

    DECLARE peso_total DECIMAL(10,2);

    SELECT SUM(dv.cantidad * p.peso)
    INTO peso_total
    FROM detalle_venta dv
    INNER JOIN productos p
        ON dv.id_producto = p.id_producto
    WHERE dv.id_venta = p_id_venta;

    IF peso_total <= 5 THEN
        RETURN 30;
    ELSE
        RETURN 50;
    END IF;

END //

DELIMITER ;


-- 08. APLICAR DESCUENTO

DELIMITER //

CREATE FUNCTION fn_AplicarDescuento(
    p_precio DECIMAL(10,2),
    p_descuento DECIMAL(10,2)
)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN

    DECLARE precio_final DECIMAL(10,2);

    SET precio_final =
        p_precio - (p_precio * p_descuento / 100);

    RETURN precio_final;

END //

DELIMITER ;


-- 09. OBTENER ÚLTIMA FECHA DE COMPRA

DELIMITER //

CREATE FUNCTION fn_ObtenerUltimaFechaCompra(p_id_cliente INT)
RETURNS DATETIME
DETERMINISTIC
READS SQL DATA
BEGIN

    DECLARE ultima_compra DATETIME;

    SELECT MAX(fecha_venta)
    INTO ultima_compra
    FROM ventas
    WHERE id_cliente = p_id_cliente;

    RETURN ultima_compra;

END //

DELIMITER ;


-- 10. VALIDAR FORMATO DE EMAIL

DELIMITER //

CREATE FUNCTION fn_ValidarFormatoEmail(p_email VARCHAR(150))
RETURNS BOOLEAN
DETERMINISTIC
BEGIN

    RETURN p_email LIKE '%@%.%';

END //

DELIMITER ;


-- 11. OBTENER NOMBRE DE CATEGORÍA

DELIMITER //

CREATE FUNCTION fn_ObtenerNombreCategoria(p_id_categoria INT)
RETURNS VARCHAR(100)
DETERMINISTIC
READS SQL DATA
BEGIN

    DECLARE nombre_categoria VARCHAR(100);

    SELECT nombre
    INTO nombre_categoria
    FROM categorias
    WHERE id_categoria = p_id_categoria;

    RETURN nombre_categoria;

END //

DELIMITER ;


-- 12. CONTAR VENTAS DEL CLIENTE

DELIMITER //

CREATE FUNCTION fn_ContarVentasCliente(p_id_cliente INT)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN

    DECLARE cantidad_ventas INT;

    SELECT COUNT(*)
    INTO cantidad_ventas
    FROM ventas
    WHERE id_cliente = p_id_cliente;

    RETURN cantidad_ventas;

END //

DELIMITER ;


-- 13. CALCULAR DÍAS DESDE LA ÚLTIMA COMPRA

DELIMITER //

CREATE FUNCTION fn_CalcularDiasDesdeUltimaCompra(p_id_cliente INT)
RETURNS INT
NOT DETERMINISTIC
READS SQL DATA
BEGIN

    DECLARE ultima_compra DATE;

    SELECT MAX(fecha_venta)
    INTO ultima_compra
    FROM ventas
    WHERE id_cliente = p_id_cliente;

    RETURN DATEDIFF(CURDATE(), ultima_compra);

END //

DELIMITER ;


-- 14. DETERMINAR ESTADO DE LEALTAD

DELIMITER //

CREATE FUNCTION fn_DeterminarEstadoLealtad(p_id_cliente INT)
RETURNS VARCHAR(20)
DETERMINISTIC
READS SQL DATA
BEGIN

    DECLARE gasto_total DECIMAL(10,2);
    DECLARE nivel VARCHAR(20);

    SELECT total_gastado
    INTO gasto_total
    FROM clientes
    WHERE id_cliente = p_id_cliente;

    IF gasto_total >= 10000 THEN
        SET nivel = 'Oro';
    ELSEIF gasto_total >= 5000 THEN
        SET nivel = 'Plata';
    ELSE
        SET nivel = 'Bronce';
    END IF;

    RETURN nivel;

END //

DELIMITER ;


-- 15. GENERAR SKU

DELIMITER //

CREATE FUNCTION fn_GenerarSKU(p_id_producto INT)
RETURNS VARCHAR(50)
DETERMINISTIC
READS SQL DATA
BEGIN

    DECLARE nombre_producto VARCHAR(100);
    DECLARE sku VARCHAR(50);

    SELECT nombre
    INTO nombre_producto
    FROM productos
    WHERE id_producto = p_id_producto;

    SET sku = CONCAT(
        UPPER(LEFT(nombre_producto, 3)),
        '-',
        p_id_producto
    );

    RETURN sku;

END //

DELIMITER ;


-- 16. CALCULAR IVA

DELIMITER //

CREATE FUNCTION fn_CalcularIVA(p_monto DECIMAL(10,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN

    DECLARE iva DECIMAL(10,2);

    SET iva = p_monto * 0.12;

    RETURN iva;

END //

DELIMITER ;


-- 17. OBTENER STOCK TOTAL POR CATEGORÍA

DELIMITER //

CREATE FUNCTION fn_ObtenerStockTotalPorCategoria(p_id_categoria INT)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN

    DECLARE stock_total INT;

    SELECT SUM(stock)
    INTO stock_total
    FROM productos
    WHERE id_categoria = p_id_categoria;

    RETURN stock_total;

END //

DELIMITER ;


-- 18. ESTIMAR FECHA DE ENTREGA

DELIMITER //

CREATE FUNCTION fn_EstimarFechaEntrega(p_id_cliente INT)
RETURNS DATE
NOT DETERMINISTIC
READS SQL DATA
BEGIN

    DECLARE region_cliente VARCHAR(100);
    DECLARE dias_entrega INT;

    SELECT region
    INTO region_cliente
    FROM clientes
    WHERE id_cliente = p_id_cliente;

    IF region_cliente = 'Guatemala' THEN
        SET dias_entrega = 2;
    ELSE
        SET dias_entrega = 5;
    END IF;

    RETURN DATE_ADD(CURDATE(), INTERVAL dias_entrega DAY);

END //

DELIMITER ;


-- 19. CONVERTIR MONEDA

DELIMITER //

CREATE FUNCTION fn_ConvertirMoneda(
    p_monto DECIMAL(10,2),
    p_tasa DECIMAL(10,4)
)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN

    DECLARE resultado DECIMAL(10,2);

    SET resultado = p_monto * p_tasa;

    RETURN resultado;

END //

DELIMITER ;


-- 20. VALIDAR COMPLEJIDAD DE CONTRASEÑA

DELIMITER //

CREATE FUNCTION fn_ValidarComplejidadContraseña(
    p_contraseña VARCHAR(100)
)
RETURNS BOOLEAN
DETERMINISTIC
BEGIN

    IF LENGTH(p_contraseña) < 8 THEN
        RETURN FALSE;
    END IF;

    IF p_contraseña NOT REGEXP '[A-Za-z]' THEN
        RETURN FALSE;
    END IF;

    IF p_contraseña NOT REGEXP '[0-9]' THEN
        RETURN FALSE;
    END IF;

    RETURN TRUE;

END //

DELIMITER ;


