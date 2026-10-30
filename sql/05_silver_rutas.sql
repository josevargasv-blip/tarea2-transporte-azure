SET NOCOUNT ON;
GO
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name='silver') EXEC('CREATE SCHEMA silver');
GO
DROP TABLE IF EXISTS silver.Rutas, silver.Cuarentena, silver.Auditoria;
GO
CREATE TABLE silver.Rutas (RutaId INT NULL, CodRuta VARCHAR(20) NULL, NombreRuta VARCHAR(200) NULL, Origen VARCHAR(100) NULL, Destino VARCHAR(100) NULL, VigenciaDesde DATE NULL, VigenciaHasta DATE NULL, Estado VARCHAR(20) NULL, AnioFuente VARCHAR(20) NULL);
CREATE TABLE silver.Cuarentena (Entidad VARCHAR(50) NULL, Registro VARCHAR(500) NULL, Motivo VARCHAR(200) NULL, AnioFuente VARCHAR(20) NULL, FechaCuarentena DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME());
CREATE TABLE silver.Auditoria (Entidad VARCHAR(50) NULL, FilasLeidas INT NULL, FilasSilver INT NULL, FilasCuarentena INT NULL, FechaEjecucion DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME());
GO
SELECT name FROM sys.tables WHERE SCHEMA_NAME(schema_id)='silver';
GO
