DROP DATABASE IF EXISTS ecommerce;

CREATE DATABASE ecommerce;

USE ecommerce;


-- 1. Categorias

CREATE TABLE categorias (
    id_categoria INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT,
    id_categoria_padre INT,
    cantidad_productos INT DEFAULT 0,

    FOREIGN KEY (id_categoria_padre)
        REFERENCES categorias(id_categoria)
);

-- 2. Proveedores

CREATE TABLE proveedores (
    id_proveedor INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email_contacto VARCHAR(100) UNIQUE,
    telefono_contacto VARCHAR(30),
    activo BOOLEAN DEFAULT TRUE
);

-- 3. Sucursales

CREATE TABLE sucursales (
    id_sucursal INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    direccion VARCHAR(200),
    ciudad VARCHAR(100),
    region VARCHAR(100),
    activo BOOLEAN DEFAULT TRUE
);

-- 4. Productos

CREATE TABLE productos (
    id_producto INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT,
    precio DECIMAL(10,2) NOT NULL,
    costo DECIMAL(10,2) NOT NULL,
    stock INT NOT NULL DEFAULT 0,
    stock_minimo INT NOT NULL DEFAULT 10,
    sku VARCHAR(50) NOT NULL UNIQUE,
    peso DECIMAL(10,2) DEFAULT 0,
    ubicacion VARCHAR(100),
    fecha_creacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    fecha_modificacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE,
    id_categoria INT,
    id_proveedor INT,
    cantidad_ventas INT DEFAULT 0,

    FOREIGN KEY (id_categoria)
        REFERENCES categorias(id_categoria),

    FOREIGN KEY (id_proveedor)
        REFERENCES proveedores(id_proveedor)
);

-- 5. Clientes

CREATE TABLE clientes (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    contraseña VARCHAR(255) NOT NULL,
    fecha_nacimiento DATE,
    direccion_envio VARCHAR(200),
    ciudad VARCHAR(100),
    region VARCHAR(100),
    fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP,
    total_gastado DECIMAL(12,2) DEFAULT 0,
    ultima_fecha_pedido DATETIME,
    activo BOOLEAN DEFAULT TRUE,
    fecha_eliminacion DATETIME,
    id_cliente_referidor INT,

    FOREIGN KEY (id_cliente_referidor)
        REFERENCES clientes(id_cliente)
);

-- 6. Carritos

CREATE TABLE carritos (
    id_carrito INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT NOT NULL,
    fecha_creacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    estado VARCHAR(30) DEFAULT 'Activo',

    FOREIGN KEY (id_cliente)
        REFERENCES clientes(id_cliente)
);

-- 7. Detalle Carrito

CREATE TABLE detalle_carrito (
    id_detalle_carrito INT AUTO_INCREMENT PRIMARY KEY,
    id_carrito INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad INT NOT NULL,

    FOREIGN KEY (id_carrito)
        REFERENCES carritos(id_carrito),

    FOREIGN KEY (id_producto)
        REFERENCES productos(id_producto)
);

-- 8. Ventas

CREATE TABLE ventas (
    id_venta INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT NOT NULL,
    id_sucursal INT,
    id_carrito INT,
    fecha_venta DATETIME DEFAULT CURRENT_TIMESTAMP,
    estado VARCHAR(30) NOT NULL DEFAULT 'Pendiente de Pago',
    total DECIMAL(12,2) DEFAULT 0,
    fecha_eliminacion DATETIME,

    FOREIGN KEY (id_cliente)
        REFERENCES clientes(id_cliente),

    FOREIGN KEY (id_sucursal)
        REFERENCES sucursales(id_sucursal),

    FOREIGN KEY (id_carrito)
        REFERENCES carritos(id_carrito)
);

-- 9. Detalle Venta

CREATE TABLE detalle_venta (
    id_detalle INT AUTO_INCREMENT PRIMARY KEY,
    id_venta INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario_congelado DECIMAL(10,2) NOT NULL,

    FOREIGN KEY (id_venta)
        REFERENCES ventas(id_venta),

    FOREIGN KEY (id_producto)
        REFERENCES productos(id_producto)
);


-- 10. Promociones

CREATE TABLE promociones (
    id_promocion INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    porcentaje_descuento DECIMAL(5,2) NOT NULL,
    fecha_inicio DATETIME NOT NULL,
    fecha_fin DATETIME NOT NULL,
    activo BOOLEAN DEFAULT TRUE
);


-- 11. Producto Promocion

CREATE TABLE producto_promocion (
    id_producto_promocion INT AUTO_INCREMENT PRIMARY KEY,
    id_producto INT NOT NULL,
    id_promocion INT NOT NULL,

    FOREIGN KEY (id_producto)
        REFERENCES productos(id_producto),

    FOREIGN KEY (id_promocion)
        REFERENCES promociones(id_promocion)
);

-- 12. Pagos

CREATE TABLE pagos (
    id_pago INT AUTO_INCREMENT PRIMARY KEY,
    id_venta INT NOT NULL,
    monto DECIMAL(12,2) NOT NULL,
    metodo_pago VARCHAR(50) NOT NULL,
    fecha_pago DATETIME DEFAULT CURRENT_TIMESTAMP,
    estado VARCHAR(30) DEFAULT 'Pendiente',

    FOREIGN KEY (id_venta)
        REFERENCES ventas(id_venta)
);

-- 13. Devoluciones

CREATE TABLE devoluciones (
    id_devolucion INT AUTO_INCREMENT PRIMARY KEY,
    id_venta INT NOT NULL,
    id_detalle INT NOT NULL,
    cantidad INT NOT NULL,
    motivo VARCHAR(255),
    fecha_devolucion DATETIME DEFAULT CURRENT_TIMESTAMP,
    monto_credito DECIMAL(12,2) DEFAULT 0,
    estado VARCHAR(30) DEFAULT 'Pendiente',

    FOREIGN KEY (id_venta)
        REFERENCES ventas(id_venta),

    FOREIGN KEY (id_detalle)
        REFERENCES detalle_venta(id_detalle)
);

-- 14. Resenas

CREATE TABLE resenas (
    id_resena INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT NOT NULL,
    id_producto INT NOT NULL,
    calificacion INT NOT NULL,
    comentario TEXT,
    fecha_resena DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (id_cliente)
        REFERENCES clientes(id_cliente),

    FOREIGN KEY (id_producto)
        REFERENCES productos(id_producto)
);

-- 15. Visitas Producto

CREATE TABLE visitas_producto (
    id_visita INT AUTO_INCREMENT PRIMARY KEY,
    id_producto INT NOT NULL,
    id_cliente INT,
    fecha_visita DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (id_producto)
        REFERENCES productos(id_producto),

    FOREIGN KEY (id_cliente)
        REFERENCES clientes(id_cliente)
);

-- 16. Referidos

CREATE TABLE referidos (
    id_referido INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente_referidor INT NOT NULL,
    id_cliente_referido INT NOT NULL,
    fecha_referido DATETIME DEFAULT CURRENT_TIMESTAMP,
    estado VARCHAR(30) DEFAULT 'Pendiente',

    FOREIGN KEY (id_cliente_referidor)
        REFERENCES clientes(id_cliente),

    FOREIGN KEY (id_cliente_referido)
        REFERENCES clientes(id_cliente)
);

-- 17. Movimientos Inventario

CREATE TABLE movimientos_inventario (
    id_movimiento INT AUTO_INCREMENT PRIMARY KEY,
    id_producto INT NOT NULL,
    tipo_movimiento VARCHAR(30) NOT NULL,
    cantidad INT NOT NULL,
    stock_anterior INT,
    stock_nuevo INT,
    motivo VARCHAR(255),
    fecha_movimiento DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (id_producto)
        REFERENCES productos(id_producto)
);

-- 18. Alertas Stock

CREATE TABLE alertas_stock (
    id_alerta INT AUTO_INCREMENT PRIMARY KEY,
    id_producto INT NOT NULL,
    stock_actual INT,
    stock_minimo INT,
    fecha_alerta DATETIME DEFAULT CURRENT_TIMESTAMP,
    estado VARCHAR(30) DEFAULT 'Pendiente',

    FOREIGN KEY (id_producto)
        REFERENCES productos(id_producto)
);


-- 19. Usuarios Sistema

CREATE TABLE usuarios_sistema (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    usuario_mysql VARCHAR(100) NOT NULL UNIQUE,
    id_sucursal INT,
    activo BOOLEAN DEFAULT TRUE,

    FOREIGN KEY (id_sucursal)
        REFERENCES sucursales(id_sucursal)
);

-- 20. Log Cambios Precio

CREATE TABLE log_cambios_precio (
    id_log INT AUTO_INCREMENT PRIMARY KEY,
    id_producto INT,
    precio_anterior DECIMAL(10,2),
    precio_nuevo DECIMAL(10,2),
    fecha_cambio DATETIME DEFAULT CURRENT_TIMESTAMP,
    usuario VARCHAR(100),

    FOREIGN KEY (id_producto)
        REFERENCES productos(id_producto)
);


-- 21. Log Clientes

CREATE TABLE log_clientes (
    id_log INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT,
    accion VARCHAR(50),
    fecha_log DATETIME DEFAULT CURRENT_TIMESTAMP,
    descripcion VARCHAR(255)
);
-- 22. Log Estados Venta

CREATE TABLE log_estados_venta (
    id_log INT AUTO_INCREMENT PRIMARY KEY,
    id_venta INT,
    estado_anterior VARCHAR(30),
    estado_nuevo VARCHAR(30),
    fecha_cambio DATETIME DEFAULT CURRENT_TIMESTAMP,
    usuario VARCHAR(100),

    FOREIGN KEY (id_venta)
        REFERENCES ventas(id_venta)
);
-- 23. Log Permisos

CREATE TABLE log_permisos (
    id_log INT AUTO_INCREMENT PRIMARY KEY,
    usuario VARCHAR(100),
    accion VARCHAR(100),
    permiso VARCHAR(100),
    fecha_log DATETIME DEFAULT CURRENT_TIMESTAMP
);
-- 24. Log Login

CREATE TABLE log_login (
    id_log INT AUTO_INCREMENT PRIMARY KEY,
    usuario VARCHAR(100),
    fecha_intento DATETIME DEFAULT CURRENT_TIMESTAMP,
    resultado VARCHAR(30),
    direccion_ip VARCHAR(50),
    motivo VARCHAR(255)
);
-- 25. Log Ventas Eliminadas

CREATE TABLE log_ventas_eliminadas (
    id_log INT AUTO_INCREMENT PRIMARY KEY,
    id_venta INT,
    id_cliente INT,
    fecha_venta DATETIME,
    estado VARCHAR(30),
    total DECIMAL(12,2),
    fecha_eliminacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    usuario VARCHAR(100)
);


-- 26. Reporte Ventas Semanales

CREATE TABLE reporte_ventas_semanales (
    id_reporte INT AUTO_INCREMENT PRIMARY KEY,
    semana INT,
    fecha_inicio DATE,
    fecha_fin DATE,
    total_ventas DECIMAL(12,2),
    cantidad_ventas INT
);
-- 27. Resumen Ventas Diarias

CREATE TABLE resumen_ventas_diarias (
    id_resumen INT AUTO_INCREMENT PRIMARY KEY,
    fecha DATE,
    cantidad_ventas INT DEFAULT 0,
    total_ventas DECIMAL(12,2) DEFAULT 0,
    unidades_vendidas INT DEFAULT 0
);
-- 28. Ranking Productos

CREATE TABLE ranking_productos (
    id_ranking INT AUTO_INCREMENT PRIMARY KEY,
    id_producto INT,
    cantidad_vendida INT DEFAULT 0,
    ingresos DECIMAL(12,2) DEFAULT 0,
    posicion INT,
    fecha_calculo DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (id_producto)
        REFERENCES productos(id_producto)
);
-- 29. KPIs Mensuales

CREATE TABLE kpis_mensuales (
    id_kpi INT AUTO_INCREMENT PRIMARY KEY,
    anio INT,
    mes INT,
    ventas_totales DECIMAL(12,2),
    nuevos_clientes INT,
    ticket_promedio DECIMAL(12,2),
    clientes_activos INT
);
-- 30. Rendimiento Proveedores

CREATE TABLE rendimiento_proveedores (
    id_reporte INT AUTO_INCREMENT PRIMARY KEY,
    id_proveedor INT,
    unidades_vendidas INT DEFAULT 0,
    ingresos DECIMAL(12,2) DEFAULT 0,
    fecha_calculo DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (id_proveedor)
        REFERENCES proveedores(id_proveedor)
);
-- 31. Alertas Fraude

CREATE TABLE alertas_fraude (
    id_alerta INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT,
    id_venta INT,
    tipo_alerta VARCHAR(100),
    descripcion VARCHAR(255),
    fecha_alerta DATETIME DEFAULT CURRENT_TIMESTAMP,
    estado VARCHAR(30) DEFAULT 'Pendiente',

    FOREIGN KEY (id_cliente)
        REFERENCES clientes(id_cliente),

    FOREIGN KEY (id_venta)
        REFERENCES ventas(id_venta)
);
-- 32. Lista Reabastecimiento

CREATE TABLE lista_reabastecimiento (
    id_reabastecimiento INT AUTO_INCREMENT PRIMARY KEY,
    id_producto INT,
    stock_actual INT,
    stock_minimo INT,
    cantidad_sugerida INT,
    fecha_generacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    estado VARCHAR(30) DEFAULT 'Pendiente',

    FOREIGN KEY (id_producto)
        REFERENCES productos(id_producto)
);
-- 33. Logs Tamano Base Datos

CREATE TABLE logs_tamano_bd (
    id_log INT AUTO_INCREMENT PRIMARY KEY,
    fecha DATETIME DEFAULT CURRENT_TIMESTAMP,
    tamano_mb DECIMAL(12,2),
    tablas INT
);
-- 34. Felicitaciones Cumpleanos

CREATE TABLE felicitaciones_cumpleanos (
    id_felicitacion INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT,
    fecha_generacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    cupon VARCHAR(50),
    enviado BOOLEAN DEFAULT FALSE,

    FOREIGN KEY (id_cliente)
        REFERENCES clientes(id_cliente)
);
-- 35. Inconsistencias Datos

CREATE TABLE inconsistencias_datos (
    id_inconsistencia INT AUTO_INCREMENT PRIMARY KEY,
    tipo VARCHAR(100),
    descripcion VARCHAR(255),
    fecha_detectada DATETIME DEFAULT CURRENT_TIMESTAMP,
    estado VARCHAR(30) DEFAULT 'Pendiente'
);


-- Datos de categorias

INSERT INTO categorias
(nombre, descripcion, id_categoria_padre)
VALUES
('Electronica', 'Productos electronicos', NULL),
('Computadoras', 'Computadoras y laptops', 1),
('Celulares', 'Telefonos celulares', 1),
('Accesorios', 'Accesorios electronicos', 1),
('Hogar', 'Productos para el hogar', NULL),
('Cocina', 'Productos para cocina', 5);

-- 2. Proveedores
-- Datos de proveedores

INSERT INTO proveedores
(nombre, email_contacto, telefono_contacto)
VALUES
('Tech Guatemala', 'ventas@techguatemala.com', '5555-1001'),
('Digital Store', 'contacto@digitalstore.com', '5555-1002'),
('Hogar Plus', 'ventas@hogarplus.com', '5555-1003'),
('Importadora Central', 'info@importadoracentral.com', '5555-1004');


-- 3. Sucursales
-- Datos de sucursales

INSERT INTO sucursales
(nombre, direccion, ciudad, region)
VALUES
('Sucursal Central', 'Zona 1', 'Guatemala', 'Metropolitana'),
('Sucursal Norte', 'Zona 17', 'Guatemala', 'Metropolitana'),
('Sucursal Antigua', 'Centro de Antigua', 'Antigua Guatemala', 'Sacatepequez');


-- 4. Productos
-- Datos de productos

INSERT INTO productos
(nombre, descripcion, precio, costo, stock, stock_minimo, sku, peso, ubicacion, id_categoria, id_proveedor)
VALUES
('Laptop Lenovo', 'Laptop para trabajo y estudio', 6500.00, 5000.00, 15, 5, 'LAP-001', 2.50, 'A-01', 2, 1),
('Laptop HP', 'Laptop para oficina', 5800.00, 4300.00, 12, 5, 'LAP-002', 2.30, 'A-02', 2, 1),
('iPhone 15', 'Telefono inteligente', 7200.00, 5900.00, 8, 5, 'CEL-001', 0.20, 'B-01', 3, 2),
('Samsung S24', 'Telefono inteligente Samsung', 6100.00, 4800.00, 10, 5, 'CEL-002', 0.20, 'B-02', 3, 2),
('Mouse Logitech', 'Mouse inalambrico', 250.00, 120.00, 25, 10, 'ACC-001', 0.10, 'C-01', 4, 2),
('Teclado Logitech', 'Teclado inalambrico', 450.00, 230.00, 18, 8, 'ACC-002', 0.50, 'C-02', 4, 2),
('Monitor LG', 'Monitor 24 pulgadas', 1800.00, 1300.00, 9, 5, 'MON-001', 3.00, 'A-03', 2, 1),
('Audifonos Sony', 'Audifonos inalambricos', 900.00, 550.00, 20, 8, 'AUD-001', 0.30, 'C-03', 4, 2),
('Licuadora Oster', 'Licuadora para cocina', 700.00, 450.00, 14, 5, 'COC-001', 2.00, 'D-01', 6, 3),
('Cafetera Oster', 'Cafetera electrica', 850.00, 500.00, 7, 5, 'COC-002', 2.20, 'D-02', 6, 3);
-- 5. Clientes
-- Datos de clientes

INSERT INTO clientes
(nombre, apellido, email, contraseña, fecha_nacimiento, direccion_envio, ciudad, region, fecha_registro)
VALUES
('Ana', 'Garcia', 'ana@gmail.com', 'Hash123', '1995-04-15', 'Zona 1', 'Guatemala', 'Metropolitana', '2026-01-10 09:00:00'),
('Carlos', 'Lopez', 'carlos@gmail.com', 'Hash456', '1990-08-20', 'Zona 10', 'Guatemala', 'Metropolitana', '2026-02-15 10:30:00'),
('Maria', 'Perez', 'maria@gmail.com', 'Hash789', '1998-03-12', 'Zona 7', 'Guatemala', 'Metropolitana', '2026-03-20 12:00:00'),
('Luis', 'Hernandez', 'luis@gmail.com', 'Hash111', '1988-11-05', 'Zona 12', 'Guatemala', 'Metropolitana', '2026-04-05 14:00:00'),
('Sofia', 'Morales', 'sofia@gmail.com', 'Hash222', '1997-07-18', 'Zona 2', 'Antigua Guatemala', 'Sacatepequez', '2026-05-10 15:00:00'),
('Diego', 'Ramirez', 'diego@gmail.com', 'Hash333', '1993-01-25', 'Zona 5', 'Guatemala', 'Metropolitana', '2026-06-12 11:00:00'),
('Laura', 'Castillo', 'laura@gmail.com', 'Hash444', '1999-09-10', 'Zona 3', 'Antigua Guatemala', 'Sacatepequez', '2026-07-18 16:00:00'),
('Pedro', 'Mendez', 'pedro@gmail.com', 'Hash555', '1991-12-30', 'Zona 4', 'Guatemala', 'Metropolitana', '2026-08-20 13:00:00');


-- 6. Carritos
-- Datos de carritos

INSERT INTO carritos
(id_cliente, fecha_creacion, fecha_actualizacion, estado)
VALUES
(1, '2026-09-01 10:00:00', '2026-09-01 10:30:00', 'Completado'),
(2, '2026-09-02 11:00:00', '2026-09-02 11:20:00', 'Completado'),
(3, '2026-09-05 12:00:00', '2026-09-05 12:30:00', 'Abandonado'),
(4, '2026-09-06 13:00:00', '2026-09-06 13:30:00', 'Abandonado'),
(5, '2026-09-08 14:00:00', '2026-09-08 14:30:00', 'Completado');


-- 7. Detalle carrito
-- Datos de detalle carrito

INSERT INTO detalle_carrito
(id_carrito, id_producto, cantidad)
VALUES
(1, 1, 1),
(1, 5, 2),
(2, 3, 1),
(2, 8, 1),
(3, 4, 1),
(3, 6, 2),
(4, 7, 1),
(4, 5, 3),
(5, 9, 1);


-- 8. Ventas
-- Datos de ventas

INSERT INTO ventas
(id_cliente, id_sucursal, id_carrito, fecha_venta, estado, total)
VALUES
(1, 1, 1, '2026-01-15 10:15:00', 'Entregado', 7000.00),
(1, 1, NULL, '2026-02-20 11:30:00', 'Entregado', 6500.00),
(1, 2, NULL, '2026-04-10 14:20:00', 'Entregado', 1800.00),

(2, 1, 2, '2026-02-18 09:45:00', 'Entregado', 8100.00),
(2, 1, NULL, '2026-05-22 16:10:00', 'Entregado', 6100.00),

(3, 2, NULL, '2026-03-25 12:30:00', 'Entregado', 900.00),
(3, 2, NULL, '2026-06-15 13:40:00', 'Entregado', 1800.00),

(4, 1, NULL, '2026-04-12 15:20:00', 'Entregado', 250.00),

(5, 3, 5, '2026-05-15 10:10:00', 'Entregado', 700.00),
(5, 3, NULL, '2026-07-20 11:50:00', 'Entregado', 850.00),

(6, 1, NULL, '2026-06-20 17:30:00', 'Entregado', 7200.00),
(6, 1, NULL, '2026-08-12 18:20:00', 'Entregado', 900.00),

(7, 3, NULL, '2026-07-25 13:10:00', 'Entregado', 450.00),

(8, 1, NULL, '2026-08-28 14:45:00', 'Entregado', 250.00);


-- 9. Detalle de ventas
-- Datos de detalle de ventas

INSERT INTO detalle_venta
(id_venta, id_producto, cantidad, precio_unitario_congelado)
VALUES
(1, 1, 1, 6500.00),
(1, 5, 2, 250.00),

(2, 2, 1, 5800.00),
(2, 6, 1, 450.00),
(2, 8, 1, 250.00),

(3, 7, 1, 1800.00),

(4, 3, 1, 7200.00),
(4, 8, 1, 900.00),

(5, 4, 1, 6100.00),

(6, 8, 1, 900.00),

(7, 7, 1, 1800.00),

(8, 5, 1, 250.00),

(9, 9, 1, 700.00),

(10, 10, 1, 850.00),

(11, 3, 1, 7200.00),

(12, 8, 1, 900.00),

(13, 6, 1, 450.00),

(14, 5, 1, 250.00);


-- 10. Promociones
-- Datos de promociones

INSERT INTO promociones
(nombre, descripcion, porcentaje_descuento, fecha_inicio, fecha_fin, activo)
VALUES
('Regreso a Clases', 'Descuento para productos seleccionados', 10.00, '2026-01-10 00:00:00', '2026-01-20 23:59:59', FALSE),
('Oferta de Mayo', 'Promocion especial de mayo', 15.00, '2026-05-10 00:00:00', '2026-05-20 23:59:59', FALSE),
('Oferta Septiembre', 'Promocion de septiembre', 20.00, '2026-09-10 00:00:00', '2026-09-20 23:59:59', TRUE);


-- 11. Producto promoción
-- Datos producto promocion

INSERT INTO producto_promocion
(id_producto, id_promocion)
VALUES
(1, 1),
(5, 1),
(3, 2),
(4, 2),
(8, 3),
(5, 3),
(6, 3);


-- 12. Pagos
-- Datos de pagos

INSERT INTO pagos
(id_venta, monto, metodo_pago, fecha_pago, estado)
VALUES
(1, 7000.00, 'Tarjeta', '2026-01-15 10:20:00', 'Pagado'),
(2, 6500.00, 'Transferencia', '2026-02-20 11:35:00', 'Pagado'),
(3, 1800.00, 'Tarjeta', '2026-04-10 14:25:00', 'Pagado'),
(4, 8100.00, 'Tarjeta', '2026-02-18 09:50:00', 'Pagado'),
(5, 6100.00, 'Transferencia', '2026-05-22 16:15:00', 'Pagado'),
(6, 900.00, 'Efectivo', '2026-03-25 12:35:00', 'Pagado'),
(7, 1800.00, 'Tarjeta', '2026-06-15 13:45:00', 'Pagado'),
(8, 250.00, 'Efectivo', '2026-04-12 15:25:00', 'Pagado'),
(9, 700.00, 'Tarjeta', '2026-05-15 10:15:00', 'Pagado'),
(10, 850.00, 'Tarjeta', '2026-07-20 11:55:00', 'Pagado'),
(11, 7200.00, 'Transferencia', '2026-06-20 17:35:00', 'Pagado'),
(12, 900.00, 'Tarjeta', '2026-08-12 18:25:00', 'Pagado'),
(13, 450.00, 'Efectivo', '2026-07-25 13:15:00', 'Pagado'),
(14, 250.00, 'Tarjeta', '2026-08-28 14:50:00', 'Pagado');


-- 13. Reseñas
-- Datos de resenas

INSERT INTO resenas
(id_cliente, id_producto, calificacion, comentario)
VALUES
(1, 1, 5, 'Excelente laptop'),
(2, 3, 5, 'Muy buen telefono'),
(3, 8, 4, 'Buen sonido'),
(4, 5, 4, 'Funciona muy bien'),
(5, 9, 5, 'Muy buena licuadora'),
(6, 3, 5, 'Excelente producto'),
(7, 6, 4, 'Buen teclado');


-- 14. Visitas
-- Datos de visitas

INSERT INTO visitas_producto
(id_producto, id_cliente, fecha_visita)
VALUES
(1, 1, '2026-01-10 09:00:00'),
(1, 2, '2026-01-12 10:00:00'),
(1, 3, '2026-01-15 11:00:00'),
(1, 4, '2026-02-01 12:00:00'),

(3, 1, '2026-02-10 13:00:00'),
(3, 2, '2026-02-11 14:00:00'),
(3, 3, '2026-02-12 15:00:00'),

(5, 1, '2026-03-01 10:00:00'),
(5, 2, '2026-03-02 11:00:00'),

(8, 4, '2026-03-05 12:00:00'),
(8, 5, '2026-03-06 13:00:00'),
(8, 6, '2026-03-07 14:00:00'),
(8, 7, '2026-03-08 15:00:00'),

(10, 1, '2026-04-01 10:00:00');


-- 15. Referidos
-- Datos de referidos

INSERT INTO referidos
(id_cliente_referidor, id_cliente_referido, fecha_referido, estado)
VALUES
(1, 2, '2026-02-01 10:00:00', 'Completado'),
(2, 3, '2026-03-01 11:00:00', 'Completado'),
(3, 4, '2026-04-01 12:00:00', 'Completado');


-- 16. Movimientos de inventario
-- Datos de movimientos de inventario

INSERT INTO movimientos_inventario
(id_producto, tipo_movimiento, cantidad, stock_anterior, stock_nuevo, motivo)
VALUES
(1, 'Entrada', 20, 0, 20, 'Compra inicial'),
(2, 'Entrada', 15, 0, 15, 'Compra inicial'),
(3, 'Entrada', 12, 0, 12, 'Compra inicial'),
(4, 'Entrada', 15, 0, 15, 'Compra inicial'),
(5, 'Entrada', 30, 0, 30, 'Compra inicial'),
(6, 'Entrada', 25, 0, 25, 'Compra inicial'),
(7, 'Entrada', 12, 0, 12, 'Compra inicial'),
(8, 'Entrada', 25, 0, 25, 'Compra inicial'),
(9, 'Entrada', 18, 0, 18, 'Compra inicial'),
(10, 'Entrada', 10, 0, 10, 'Compra inicial');


-- 17. Alertas de stock
-- Datos de alertas de stock

INSERT INTO alertas_stock
(id_producto, stock_actual, stock_minimo, estado)
VALUES
(3, 8, 5, 'Atendida'),
(4, 10, 5, 'Atendida'),
(7, 9, 5, 'Atendida'),
(10, 7, 5, 'Pendiente');


-- 18. Usuarios del sistema
-- Datos de usuarios del sistema

INSERT INTO usuarios_sistema
(nombre, usuario_mysql, id_sucursal)
VALUES
('Administrador', 'admin_user', 1),
('Marketing', 'marketing_user', 1),
('Inventario', 'inventory_user', 2),
('Atencion Cliente', 'support_user', 3);