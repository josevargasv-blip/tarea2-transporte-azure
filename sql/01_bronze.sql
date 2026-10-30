SET NOCOUNT ON;
GO
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'bronze') EXEC('CREATE SCHEMA bronze');
GO

DROP TABLE IF EXISTS bronze.Rutas, bronze.Paradas, bronze.Vehiculos, bronze.Viajes, bronze.DemandaParadas, bronze.Incidentes;
GO

CREATE TABLE bronze.Rutas (
  cod_ruta VARCHAR(100) NULL, nombre_ruta VARCHAR(200) NULL, origen VARCHAR(100) NULL, destino VARCHAR(100) NULL,
  fecha_desde VARCHAR(50) NULL, fecha_hasta VARCHAR(50) NULL, estado VARCHAR(50) NULL,
  AnioFuente VARCHAR(10) NULL, ArchivoOrigen VARCHAR(200) NULL, FechaCarga DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME()
);

CREATE TABLE bronze.Paradas (
  nro_parada VARCHAR(100) NULL, nombre_parada VARCHAR(200) NULL, zona VARCHAR(100) NULL,
  latitud VARCHAR(50) NULL, longitud VARCHAR(50) NULL, fecha_desde VARCHAR(50) NULL, fecha_hasta VARCHAR(50) NULL, estado VARCHAR(50) NULL,
  AnioFuente VARCHAR(10) NULL, ArchivoOrigen VARCHAR(200) NULL, FechaCarga DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME()
);

CREATE TABLE bronze.Vehiculos (
  nro_bus VARCHAR(100) NULL, placa VARCHAR(50) NULL, tipo_bus VARCHAR(50) NULL, capacidad VARCHAR(50) NULL,
  fecha_desde VARCHAR(50) NULL, fecha_hasta VARCHAR(50) NULL, estado VARCHAR(50) NULL,
  AnioFuente VARCHAR(10) NULL, ArchivoOrigen VARCHAR(200) NULL, FechaCarga DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME()
);

CREATE TABLE bronze.Viajes (
  id_viaje VARCHAR(100) NULL, cod_ruta VARCHAR(100) NULL, nro_bus VARCHAR(100) NULL, fec_servicio VARCHAR(50) NULL,
  hora_programada VARCHAR(50) NULL, hora_salida VARCHAR(50) NULL, hora_llegada VARCHAR(50) NULL,
  pasajeros_reportados VARCHAR(50) NULL, pasajeros_estimados VARCHAR(50) NULL, km_recorridos VARCHAR(50) NULL,
  estado_viaje VARCHAR(50) NULL, tipo_metrica VARCHAR(50) NULL,
  AnioFuente VARCHAR(10) NULL, ArchivoOrigen VARCHAR(200) NULL, FechaCarga DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME()
);

CREATE TABLE bronze.DemandaParadas (
  fec_servicio VARCHAR(50) NULL, cod_ruta VARCHAR(100) NULL, nro_parada VARCHAR(100) NULL, franja VARCHAR(50) NULL,
  abordajes_manuales VARCHAR(50) NULL, descensos_manuales VARCHAR(50) NULL, demanda_no_atendida VARCHAR(50) NULL, medicion VARCHAR(50) NULL,
  AnioFuente VARCHAR(10) NULL, ArchivoOrigen VARCHAR(200) NULL, FechaCarga DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME()
);

CREATE TABLE bronze.Incidentes (
  id_incidente VARCHAR(100) NULL, tipo VARCHAR(100) NULL, severidad VARCHAR(50) NULL,
  fecha_inicio VARCHAR(50) NULL, hora_inicio VARCHAR(50) NULL, fecha_fin VARCHAR(50) NULL, hora_fin VARCHAR(50) NULL,
  fecha_registro VARCHAR(50) NULL, rutas_afectadas VARCHAR(300) NULL, vehiculo_afectado VARCHAR(100) NULL, descripcion VARCHAR(500) NULL,
  AnioFuente VARCHAR(10) NULL, ArchivoOrigen VARCHAR(200) NULL, FechaCarga DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME()
);
GO

SELECT t.name AS tabla, COUNT(c.column_id) AS columnas
FROM sys.tables t JOIN sys.columns c ON c.object_id = t.object_id
WHERE SCHEMA_NAME(t.schema_id) = 'bronze' GROUP BY t.name ORDER BY t.name;
GO
