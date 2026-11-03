-- RetailPro - Pre-entrega 4
-- Consultas SQL de negocio
-- Base: Ventas_Tech_DB
-- Motor: SQL Server
-- Para estas consultas uso únicamente la tabla ventas.

USE Ventas_Tech_DB;
GO

-- 1. Resumen ejecutivo mensual
-- Agrupo las ventas por mes para obtener las tres métricas.
SELECT
    MONTH(fecha_venta) AS mes,
    SUM(cantidad * precio_unitario) AS total_facturado,
    COUNT(*) AS cantidad_pedidos,
    CAST(AVG(cantidad * precio_unitario) AS DECIMAL(12, 2)) AS ticket_promedio
FROM ventas
GROUP BY MONTH(fecha_venta)
ORDER BY mes;

-- 2. Ranking de productos
-- Ordeno por facturación y muestro solamente los primeros cinco.
SELECT TOP 5
    id_producto,
    SUM(cantidad) AS unidades_vendidas,
    SUM(cantidad * precio_unitario) AS total_facturado
FROM ventas
GROUP BY id_producto
ORDER BY total_facturado DESC;

-- 3. Clientes recurrentes
-- HAVING deja únicamente los clientes con más de una compra.
SELECT
    id_cliente,
    COUNT(*) AS cantidad_pedidos,
    SUM(cantidad * precio_unitario) AS total_gastado
FROM ventas
GROUP BY id_cliente
HAVING COUNT(*) > 1
ORDER BY total_gastado DESC;

-- 4. Productos por encima o por debajo del promedio
-- Primero sumo las ventas de cada producto.
-- Luego comparo esos totales con su promedio general.
WITH totales_por_producto AS (
    SELECT
        id_producto,
        SUM(cantidad * precio_unitario) AS total_facturado
    FROM ventas
    GROUP BY id_producto
)
SELECT
    id_producto,
    total_facturado,
    CASE
        WHEN total_facturado > (
            SELECT AVG(total_facturado)
            FROM totales_por_producto
        ) THEN 'Por encima'
        ELSE 'Por debajo'
    END AS comparacion_promedio
FROM totales_por_producto
ORDER BY total_facturado DESC;

-- Hallazgos a partir de los datos del Módulo 3
-- 1. En marzo de 2024 se registraron 10 pedidos por un total de $6.444,
--    con un ticket promedio de $644,40. Es el primer mes disponible,
--    por lo que todavía no se puede comparar la evolución mensual.
-- 2. Los productos con ID 1 y 3 facturaron $3.600 y $1.350.
--    Juntos representan el 76,82 % de los ingresos. Conviene controlar
--    el stock de ambos para evitar faltantes.
-- 3. Los 5 clientes de la base tienen 2 compras cada uno. El cliente
--    con ID 1 gastó $2.640, el importe más alto entre los clientes.
--    Se podrían pensar promociones para mantener a estos compradores.
