-- 01. TOP 10 PRODUCTOS POR INGRESOS

SELECT
    p.id_producto,
    p.nombre,
    SUM(dv.cantidad * dv.precio_unitario_congelado) AS ingresos_totales
FROM productos p
INNER JOIN detalle_venta dv
    ON p.id_producto = dv.id_producto
GROUP BY
    p.id_producto,
    p.nombre
ORDER BY ingresos_totales DESC
LIMIT 10;

-- 02. Obtener el 10% de productos con menores ventas

SELECT 
    p.id_producto,
    p.nombre,
    SUM(dv.cantidad) AS unidades_vendidas
FROM productos p
INNER JOIN detalle_venta dv
    ON p.id_producto = dv.id_producto
GROUP BY p.id_producto, p.nombre
ORDER BY unidades_vendidas ASC
LIMIT 10;


-- 03. TOP 5 CLIENTES VIP

SELECT
    c.id_cliente,
    c.nombre,
    c.apellido,
    SUM(v.total) AS gasto_total
FROM clientes c
INNER JOIN ventas v
    ON c.id_cliente = v.id_cliente
GROUP BY
    c.id_cliente,
    c.nombre,
    c.apellido
ORDER BY gasto_total DESC
LIMIT 5;

-- 04. VENTAS MENSUALES

SELECT
    YEAR(fecha_venta) AS año,
    MONTH(fecha_venta) AS mes,
    SUM(total) AS ventas_totales
FROM ventas
GROUP BY
    YEAR(fecha_venta),
    MONTH(fecha_venta)
ORDER BY
    año,
    mes;


-- 05. NUEVOS CLIENTES POR TRIMESTRE

SELECT
    YEAR(fecha_registro) AS año,
    QUARTER(fecha_registro) AS trimestre,
    COUNT(*) AS nuevos_clientes
FROM clientes
GROUP BY
    YEAR(fecha_registro),
    QUARTER(fecha_registro)
ORDER BY
    año,
    trimestre;


-- 06. TASA DE COMPRA REPETIDA

SELECT
    COUNT(*) * 100.0 / (
        SELECT COUNT(DISTINCT id_cliente)
        FROM ventas
    ) AS tasa_compra_repetida
FROM (
    SELECT
        id_cliente
    FROM ventas
    GROUP BY id_cliente
    HAVING COUNT(*) > 1
) AS clientes_repetidores;


-- 07. PRODUCTOS COMPRADOS JUNTOS

SELECT
    dv1.id_producto AS producto1,
    dv2.id_producto AS producto2,
    COUNT(*) AS veces_juntos
FROM detalle_venta dv1
INNER JOIN detalle_venta dv2
    ON dv1.id_venta = dv2.id_venta
WHERE dv1.id_producto < dv2.id_producto
GROUP BY
    dv1.id_producto,
    dv2.id_producto
ORDER BY veces_juntos DESC;


-- 08. ROTACIÓN DE INVENTARIO POR CATEGORÍA

SELECT
    c.id_categoria,
    c.nombre,
    SUM(dv.cantidad) AS unidades_vendidas,
    SUM(p.stock) AS stock_disponible,
    SUM(dv.cantidad) / SUM(p.stock) AS rotacion_inventario
FROM categorias c
INNER JOIN productos p
    ON c.id_categoria = p.id_categoria
INNER JOIN detalle_venta dv
    ON p.id_producto = dv.id_producto
GROUP BY
    c.id_categoria,
    c.nombre
ORDER BY rotacion_inventario DESC;

-- 09. PRODUCTOS POR DEBAJO DEL STOCK MÍNIMO

SELECT
    id_producto,
    nombre,
    stock,
    stock_minimo,
    ubicacion
FROM productos
WHERE stock < stock_minimo
ORDER BY stock ASC;

-- 10. CARRITOS ABANDONADOS

SELECT DISTINCT
    c.id_cliente,
    c.nombre,
    c.apellido,
    ca.id_carrito,
    ca.fecha_creacion
FROM clientes c
INNER JOIN carritos ca
    ON c.id_cliente = ca.id_cliente
INNER JOIN detalle_carrito dc
    ON ca.id_carrito = dc.id_carrito
LEFT JOIN ventas v
    ON ca.id_carrito = v.id_carrito
WHERE v.id_venta IS NULL
  AND ca.fecha_creacion >= '2026-09-01'
  AND ca.fecha_creacion < '2026-10-01';


  -- 11. RENDIMIENTO DE PROVEEDORES

SELECT
    pr.id_proveedor,
    pr.nombre,
    SUM(dv.cantidad) AS unidades_vendidas
FROM proveedores pr
INNER JOIN productos p
    ON pr.id_proveedor = p.id_proveedor
INNER JOIN detalle_venta dv
    ON p.id_producto = dv.id_producto
GROUP BY
    pr.id_proveedor,
    pr.nombre
ORDER BY unidades_vendidas DESC;

-- 12. VENTAS POR CIUDAD Y REGIÓN

SELECT
    c.region,
    c.ciudad,
    SUM(v.total) AS ventas_totales
FROM clientes c
INNER JOIN ventas v
    ON c.id_cliente = v.id_cliente
GROUP BY
    c.region,
    c.ciudad
ORDER BY ventas_totales DESC;


-- 13. VENTAS POR HORA

SELECT
    HOUR(fecha_venta) AS hora,
    COUNT(id_venta) AS ventas_por_hora
FROM ventas
GROUP BY HOUR(fecha_venta)
ORDER BY ventas_por_hora DESC
LIMIT 5;

-- 14. IMPACTO DE UNA PROMOCIÓN

SELECT
    CASE
        WHEN fecha_venta < '2026-09-10' THEN 'Antes'
        WHEN fecha_venta >= '2026-09-10'
             AND fecha_venta < '2026-09-21' THEN 'Durante'
        WHEN fecha_venta >= '2026-09-21' THEN 'Despues'
    END AS periodo,
    SUM(total) AS ventas_totales
FROM ventas
WHERE fecha_venta >= '2026-09-01'
  AND fecha_venta < '2026-10-01'
GROUP BY periodo
ORDER BY
    CASE periodo
        WHEN 'Antes' THEN 1
        WHEN 'Durante' THEN 2
        WHEN 'Despues' THEN 3
    END;


-- 15. RETENCIÓN POR COHORTE

SELECT
    MONTH(pc.primera_compra) AS mes_cohorte,
    MONTH(v.fecha_venta) AS mes_compra,
    COUNT(DISTINCT v.id_cliente) AS clientes
FROM ventas v
INNER JOIN (
    SELECT
        id_cliente,
        MIN(fecha_venta) AS primera_compra
    FROM ventas
    GROUP BY id_cliente
) pc
    ON v.id_cliente = pc.id_cliente
GROUP BY
    MONTH(pc.primera_compra),
    MONTH(v.fecha_venta)
ORDER BY
    mes_cohorte,
    mes_compra;


-- 16. MARGEN DE GANANCIA POR PRODUCTO

SELECT
    id_producto,
    nombre,
    precio,
    costo,
    precio - costo AS ganancia,
    ROUND(
        (precio - costo) / precio * 100,
        2
    ) AS margen_porcentaje
FROM productos
ORDER BY margen_porcentaje DESC;


-- 17. TIEMPO ENTRE COMPRAS

SELECT
    v1.id_cliente,
    v1.fecha_venta AS compra_1,
    v2.fecha_venta AS compra_2,
    DATEDIFF(
        v2.fecha_venta,
        v1.fecha_venta
    ) AS dias_entre_compras
FROM ventas v1
INNER JOIN ventas v2
    ON v1.id_cliente = v2.id_cliente
WHERE v2.fecha_venta > v1.fecha_venta
ORDER BY
    v1.id_cliente,
    v1.fecha_venta;

-- 18. PRODUCTOS MÁS VISTOS VS. MÁS COMPRADOS

SELECT
    p.id_producto,
    p.nombre,
    COUNT(DISTINCT vp.id_visita) AS total_vistas,
    COALESCE(SUM(dv.cantidad), 0) AS total_comprado
FROM productos p
LEFT JOIN visitas_producto vp
    ON p.id_producto = vp.id_producto
LEFT JOIN detalle_venta dv
    ON p.id_producto = dv.id_producto
GROUP BY
    p.id_producto,
    p.nombre
ORDER BY total_vistas DESC;

-- 19. SEGMENTACIÓN RFM DE CLIENTES

SELECT
    c.id_cliente,
    c.nombre,
    c.apellido,

    DATEDIFF(
        CURDATE(),
        MAX(v.fecha_venta)
    ) AS recencia,

    COUNT(v.id_venta) AS frecuencia,

    SUM(v.total) AS valor_monetario

FROM clientes c
INNER JOIN ventas v
    ON c.id_cliente = v.id_cliente

GROUP BY
    c.id_cliente,
    c.nombre,
    c.apellido

ORDER BY
    valor_monetario DESC;


-- 20. ESTIMACIÓN DE DEMANDA DEL PRÓXIMO MES POR CATEGORÍA

SELECT
    c.id_categoria,
    c.nombre,
    SUM(dv.cantidad) AS unidades_vendidas,
    COUNT(DISTINCT YEAR(v.fecha_venta), MONTH(v.fecha_venta))
        AS meses_con_ventas,

    SUM(dv.cantidad) /
    COUNT(DISTINCT YEAR(v.fecha_venta), MONTH(v.fecha_venta))
        AS demanda_estimada

FROM categorias c
INNER JOIN productos p
    ON c.id_categoria = p.id_categoria
INNER JOIN detalle_venta dv
    ON p.id_producto = dv.id_producto
INNER JOIN ventas v
    ON dv.id_venta = v.id_venta

GROUP BY
    c.id_categoria,
    c.nombre

ORDER BY demanda_estimada DESC;