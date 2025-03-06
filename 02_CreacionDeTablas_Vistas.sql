USE [LabManager]
GO
/****** Object:  User [LabManager_Asistencia]    Script Date: 3/6/2025 4:19:19 PM ******/
CREATE USER [LabManager_Asistencia] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  Schema [Asistencia]    Script Date: 3/6/2025 4:19:19 PM ******/
CREATE SCHEMA [Asistencia]
GO
/****** Object:  Schema [Basico]    Script Date: 3/6/2025 4:19:19 PM ******/
CREATE SCHEMA [Basico]
GO
/****** Object:  Schema [GestionInformacion]    Script Date: 3/6/2025 4:19:19 PM ******/
CREATE SCHEMA [GestionInformacion]
GO
/****** Object:  Schema [Migra]    Script Date: 3/6/2025 4:19:19 PM ******/
CREATE SCHEMA [Migra]
GO
/****** Object:  Schema [Registro]    Script Date: 3/6/2025 4:19:19 PM ******/
CREATE SCHEMA [Registro]
GO
/****** Object:  Schema [Reportes]    Script Date: 3/6/2025 4:19:19 PM ******/
CREATE SCHEMA [Reportes]
GO
/****** Object:  Schema [Seguridad]    Script Date: 3/6/2025 4:19:19 PM ******/
CREATE SCHEMA [Seguridad]
GO
/****** Object:  Schema [Sistema]    Script Date: 3/6/2025 4:19:19 PM ******/
CREATE SCHEMA [Sistema]
GO
/****** Object:  UserDefinedFunction [dbo].[Split]    Script Date: 3/6/2025 4:19:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[Split] 
( 
    @string NVARCHAR(MAX), 
    @delimiter CHAR(1) 
) 
RETURNS @output TABLE(id integer, splitdata NVARCHAR(MAX) 
) 
BEGIN 
	DECLARE @N INT=0;
    DECLARE @start INT, @end INT 
    SELECT @start = 1, @end = CHARINDEX(@delimiter, @string) 
    WHILE @start < LEN(@string) + 1 BEGIN 
        IF @end = 0  
            SET @end = LEN(@string) + 1
       
        INSERT INTO @output (id,splitdata)  
        VALUES(@N,SUBSTRING(@string, @start, @end - @start)) 
        SET @start = @end + 1 
        SET @end = CHARINDEX(@delimiter, @string, @start)
        SET @N = @N + 1         
    END 
    RETURN 
END
GO
/****** Object:  Table [Seguridad].[Usuario]    Script Date: 3/6/2025 4:19:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Seguridad].[Usuario](
	[UsuarioId] [bigint] IDENTITY(1,1) NOT NULL,
	[TipoUsuarioId] [int] NOT NULL,
	[Nombres] [varchar](50) NOT NULL,
	[Apellidos] [varchar](50) NOT NULL,
	[Documento] [varchar](50) NOT NULL,
	[Codigo] [varchar](50) NULL,
	[BarCode] [varchar](50) NULL,
	[Password] [varbinary](50) NULL,
	[PasswordCoded] [bit] NOT NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime] NOT NULL,
	[FechaModificacion] [datetime] NULL,
	[CreadoId] [bigint] NOT NULL,
	[ModificadoId] [bigint] NULL,
	[FacultadId] [int] NULL,
	[SemestreBasico] [int] NULL,
	[Token] [varbinary](1024) NULL,
	[TokenDate] [datetime] NULL,
	[CorreoElectronico] [varchar](255) NULL,
 CONSTRAINT [PK_Usuario] PRIMARY KEY CLUSTERED 
(
	[UsuarioId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [IX_Usuario_Barcode] UNIQUE NONCLUSTERED 
(
	[BarCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [IX_Usuario_Documento] UNIQUE NONCLUSTERED 
(
	[Documento] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [Asistencia].[View_AsistenciaEstudiante]    Script Date: 3/6/2025 4:19:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Asistencia].[View_AsistenciaEstudiante]
AS
SELECT Documento, Nombres, Apellidos
FROM     Seguridad.Usuario AS u
WHERE  (TipoUsuarioId IN (1))
GO
/****** Object:  Table [Registro].[Multa]    Script Date: 3/6/2025 4:19:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Registro].[Multa](
	[MultaId] [bigint] IDENTITY(1,1) NOT NULL,
	[DeudorId] [bigint] NOT NULL,
	[Descripcion] [varchar](1024) NOT NULL,
	[Valor] [int] NOT NULL,
	[EstadoMultaId] [int] NOT NULL,
	[FechaCreacion] [datetime] NOT NULL,
	[FechaModificacion] [datetime] NULL,
	[CreadoId] [bigint] NOT NULL,
	[ModificadoId] [bigint] NULL,
 CONSTRAINT [PK_Multa] PRIMARY KEY CLUSTERED 
(
	[MultaId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [Reportes].[View_CSV_Deudores]    Script Date: 3/6/2025 4:19:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Reportes].[View_CSV_Deudores]
AS
select 'Documento;Nombres;Apellidos;Valor;Fecha de creación;Descripción;Responsable' as Registro
union
	Select 

	REPLACE(REPLACE(
		u.Documento+';'+u.Nombres+';'+ u.Apellidos+';'+ CONVERT(varchar(MAX),m.Valor)+';'+ SUBSTRING(CONVERT(varchar(MAX),m.FechaCreacion,126),0,11)+';'+
		m.Descripcion+';'+ uc.Nombres + ' ' + uc.Apellidos
	, CHAR(13), ''), CHAR(10), '')
	from Registro.Multa m
	left join Seguridad.Usuario u on u.UsuarioId = m.DeudorId
	left join Seguridad.Usuario uc on uc.UsuarioId = m.CreadoId
	where m.EstadoMultaId = 1
GO
/****** Object:  View [Reportes].[View_CSV_MultasPagas]    Script Date: 3/6/2025 4:19:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [Reportes].[View_CSV_MultasPagas]
AS

select	'Documento;Nombres;Apellidos;Valor;'+
		'Descripción;Creada por;Fecha creación;'+
		'Modificada por;Fecha modificación' as Registro
union
	Select 

	REPLACE(REPLACE(
		
		u.Documento+';'+u.Nombres+';'+ u.Apellidos+';'+ 
		CONVERT(varchar(MAX),m.Valor)+';'+ 
		m.Descripcion+';'+ 
		uc.Nombres + ' ' + uc.Apellidos+';'+ 
		SUBSTRING(CONVERT(varchar(MAX),m.FechaCreacion,126),0,11)+';'+
		um.Nombres + ' ' + um.Apellidos +';'+
		SUBSTRING(CONVERT(varchar(MAX),m.FechaModificacion,126),0,11)

	, CHAR(13), ''), CHAR(10), '')
	from Registro.Multa m
	left join Seguridad.Usuario u on u.UsuarioId = m.DeudorId
	left join Seguridad.Usuario uc on uc.UsuarioId = m.CreadoId
	left join Seguridad.Usuario um on um.UsuarioId = m.ModificadoId
	where m.EstadoMultaId = 2

GO
/****** Object:  View [Reportes].[View_CSV_MultasAnuladas]    Script Date: 3/6/2025 4:19:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [Reportes].[View_CSV_MultasAnuladas]
AS
select	'Documento;Nombres;Apellidos;Valor;'+
		'Descripción;Creada por;Fecha creación;'+
		'Modificada por;Fecha modificación' as Registro
union
	Select 

	REPLACE(REPLACE(
		
		u.Documento+';'+u.Nombres+';'+ u.Apellidos+';'+ 
		CONVERT(varchar(MAX),m.Valor)+';'+ 
		m.Descripcion+';'+ 
		uc.Nombres + ' ' + uc.Apellidos+';'+ 
		SUBSTRING(CONVERT(varchar(MAX),m.FechaCreacion,126),0,11)+';'+
		um.Nombres + ' ' + um.Apellidos +';'+
		SUBSTRING(CONVERT(varchar(MAX),m.FechaModificacion,126),0,11)

	, CHAR(13), ''), CHAR(10), '')
	from Registro.Multa m
	left join Seguridad.Usuario u on u.UsuarioId = m.DeudorId
	left join Seguridad.Usuario uc on uc.UsuarioId = m.CreadoId
	left join Seguridad.Usuario um on um.UsuarioId = m.ModificadoId
	where m.EstadoMultaId = 3

GO
/****** Object:  Table [Registro].[Anotacion]    Script Date: 3/6/2025 4:19:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Registro].[Anotacion](
	[AnotacionId] [bigint] IDENTITY(1,1) NOT NULL,
	[UsuarioId] [bigint] NOT NULL,
	[Descripcion] [varchar](1024) NOT NULL,
	[EstadoAnotacionId] [int] NOT NULL,
	[FechaCreacion] [datetime] NOT NULL,
	[FechaModificacion] [datetime] NULL,
	[CreadoId] [bigint] NOT NULL,
	[ModificadoId] [bigint] NULL,
 CONSTRAINT [PK_Anotacion] PRIMARY KEY CLUSTERED 
(
	[AnotacionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Registro].[PrestamoRecepcion]    Script Date: 3/6/2025 4:19:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Registro].[PrestamoRecepcion](
	[PrestamoRecepcionId] [bigint] IDENTITY(1,1) NOT NULL,
	[UsuarioId] [bigint] NOT NULL,
	[EquipoId] [bigint] NOT NULL,
	[FacultadId] [int] NULL,
	[SemestreBasico] [int] NULL,
	[AuxilliarPrestaId] [bigint] NOT NULL,
	[FechaPrestamo] [datetime] NOT NULL,
	[PrestamoMaual] [bit] NOT NULL,
	[AuxilliarRecibeId] [bigint] NULL,
	[FechaRecepcion] [datetime] NULL,
	[RecepcionManual] [bit] NULL,
 CONSTRAINT [PK_PrestamoRecepcion] PRIMARY KEY CLUSTERED 
(
	[PrestamoRecepcionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Sistema].[Parametro]    Script Date: 3/6/2025 4:19:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Sistema].[Parametro](
	[ParametroId] [int] NOT NULL,
	[Nombre] [varchar](50) NOT NULL,
	[Valor] [varchar](50) NOT NULL,
	[Descripcion] [varchar](1024) NULL,
 CONSTRAINT [PK_Parametro] PRIMARY KEY CLUSTERED 
(
	[ParametroId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [GestionInformacion].[View_Inactivos]    Script Date: 3/6/2025 4:19:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [GestionInformacion].[View_Inactivos]
AS
	SELECT 
		u.UsuarioId as UsuarioIdInactivo, 
		(SELECT COUNT(1) FROM Registro.PrestamoRecepcion pr WHERE pr.UsuarioId=u.UsuarioId) AS Prestamos,
		(
			SELECT COUNT(1) 
			FROM Registro.PrestamoRecepcion pr 
			WHERE 
				pr.UsuarioId=u.UsuarioId and 
				((SELECT DATEPART(YEAR,GETDATE()))-DATEPART(YEAR,FechaRecepcion))>(select convert(int, valor) from Sistema.Parametro where Nombre ='TiempoHistorico')
		) AS PrestamosObsoletos,
		(SELECT COUNT(1) FROM Registro.Multa m WHERE m.DeudorId=u.UsuarioId and m.EstadoMultaId=1) AS MultasActivas,
		(SELECT COUNT(1) FROM Registro.Anotacion a WHERE a.UsuarioId=u.UsuarioId and a.EstadoAnotacionId=1) AS AnotacionesActivas
	FROM Seguridad.Usuario u 
	WHERE u.TipoUsuarioId =1 and u.Activo =0
GO
/****** Object:  View [GestionInformacion].[View_CandidatosEliminar]    Script Date: 3/6/2025 4:19:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [GestionInformacion].[View_CandidatosEliminar]
AS
	select * from [GestionInformacion].[View_Inactivos]
	where AnotacionesActivas=0 and MultasActivas=0 and Prestamos=PrestamosObsoletos
GO
/****** Object:  Table [Basico].[TipoEquipo]    Script Date: 3/6/2025 4:19:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Basico].[TipoEquipo](
	[TipoEquipoId] [int] IDENTITY(1,1) NOT NULL,
	[Descripcion] [varchar](50) NOT NULL,
	[Marca] [varchar](50) NOT NULL,
	[Referencia] [varchar](50) NOT NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime] NOT NULL,
	[FechaModificacion] [datetime] NULL,
	[CreadoId] [bigint] NOT NULL,
	[ModificadoId] [bigint] NULL,
 CONSTRAINT [PK_TipoEquipo] PRIMARY KEY CLUSTERED 
(
	[TipoEquipoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Basico].[Equipo]    Script Date: 3/6/2025 4:19:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Basico].[Equipo](
	[EquipoId] [bigint] IDENTITY(1,1) NOT NULL,
	[TipoEquipoId] [int] NOT NULL,
	[CodigoLaboratorio] [varchar](50) NOT NULL,
	[CodigoInventario] [varchar](50) NULL,
	[Serial] [varchar](50) NULL,
	[Activo] [bit] NOT NULL,
	[ResponsableId] [bigint] NULL,
	[FechaCompra] [datetime] NULL,
	[FechaCreacion] [datetime] NOT NULL,
	[FechaModificacion] [datetime] NULL,
	[CreadoId] [bigint] NOT NULL,
	[ModificadoId] [bigint] NULL,
	[EquipoMigraId] [int] NULL,
 CONSTRAINT [PK_Equipo] PRIMARY KEY CLUSTERED 
(
	[EquipoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [Basico].[View_Historial_Equipo]    Script Date: 3/6/2025 4:19:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [Basico].[View_Historial_Equipo]
AS
	SELECT
		pr.PrestamorecepcionId, pr.UsuarioId, pr.EquipoId, eq.TipoEquipoId, u.Documento as UsuarioDocumento, u.Nombres+' ' + u.Apellidos as UsuarioResponsable
		,pr.FechaPrestamo, pr.FechaRecepcion, eq.CodigoInventario, eq.CodigoLaboratorio, teq.Descripcion, teq.Marca
	FROM
	registro.PrestamoRecepcion pr
	LEFT JOIN Seguridad.Usuario u ON u.UsuarioId = pr.UsuarioId
	LEFT JOIN Basico.Equipo eq ON eq.EquipoId = pr.EquipoId
	LEFT JOIN Basico.TipoEquipo teq ON eq.TipoEquipoId = teq.TipoEquipoId
GO
/****** Object:  Table [Basico].[Facultad]    Script Date: 3/6/2025 4:19:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Basico].[Facultad](
	[FacultadId] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [varchar](50) NOT NULL,
	[Codigo] [int] NOT NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime] NOT NULL,
	[FechaModificacion] [datetime] NULL,
	[CreadoId] [bigint] NOT NULL,
	[ModificadoId] [bigint] NULL,
	[SedeId] [int] NULL,
 CONSTRAINT [PK_Facultad] PRIMARY KEY CLUSTERED 
(
	[FacultadId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [IX_Facultad] UNIQUE NONCLUSTERED 
(
	[FacultadId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [Reportes].[View_Deudores]    Script Date: 3/6/2025 4:19:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [Reportes].[View_Deudores]
AS

	Select 
--Id de la multa
	m.MultaId,
--Información del deudor
		u.Documento,
		u.Codigo,
		u.Nombres, 
		u.Apellidos, 
		f.Nombre as Facultad,
--Informacion de la multa		
		m.Valor, 
		m.Descripcion, 
--Informacion de la creación
		m.FechaCreacion,
		uc.Nombres + ' ' + uc.Apellidos as CreadaPor,
		m.FechaModificacion,
		um.Nombres + ' ' + um.Apellidos as ModificadaPor
	from Registro.Multa m
	left join Seguridad.Usuario u on u.UsuarioId = m.DeudorId
	left join Seguridad.Usuario uc on uc.UsuarioId = m.CreadoId
	left join Seguridad.Usuario um on um.UsuarioId = m.ModificadoId
	left join Basico.Facultad f on f.FacultadId = u.FacultadId
	where m.EstadoMultaId = 1
GO
/****** Object:  Table [Seguridad].[Menu]    Script Date: 3/6/2025 4:19:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Seguridad].[Menu](
	[MenuId] [int] NOT NULL,
	[Activo] [bit] NOT NULL,
	[Texto] [varchar](50) NOT NULL,
	[Imagen] [varchar](50) NULL,
	[Destino] [varchar](500) NOT NULL,
	[Orden] [int] NOT NULL,
	[CreaId] [bigint] NOT NULL,
	[Grupo] [varchar](250) NULL,
	[FechaCreacion] [datetime] NULL,
	[ModificaId] [bigint] NULL,
	[FechaModificacion] [datetime] NULL,
 CONSTRAINT [PK_Menu] PRIMARY KEY CLUSTERED 
(
	[MenuId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [Seguridad].[View_Menu_Reportes]    Script Date: 3/6/2025 4:19:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [Seguridad].[View_Menu_Reportes]
AS
	SELECT * FROM 
	Seguridad.Menu
	WHERE Grupo='Reportes'
GO
/****** Object:  Table [Sistema].[TipoUsuario]    Script Date: 3/6/2025 4:19:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Sistema].[TipoUsuario](
	[TipoUsuarioId] [int] NOT NULL,
	[Nombre] [varchar](50) NOT NULL,
 CONSTRAINT [PK_TipoUsuario] PRIMARY KEY CLUSTERED 
(
	[TipoUsuarioId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [Reportes].[View_DetallePrestamoRecepcion]    Script Date: 3/6/2025 4:19:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [Reportes].[View_DetallePrestamoRecepcion]
AS

	Select 
--Id del detalle de la transacción
	pr.PrestamoRecepcionId,
--Información del estudiante docente
		u.Documento,
		u.Codigo,
		u.Nombres, 
		u.Apellidos, 
		f.FacultadId,
		f.Nombre as Facultad,
		tu.Nombre as Rol,
--Información del equipo		
		eq.CodigoLaboratorio as CodigoEquipo,
		teq.Descripcion as Descripcion,
		teq.Marca,
		teq.Referencia,
--Informacion de la transacción
		pr.SemestreBasico,
		pr.PrestamoMaual,
		pr.FechaPrestamo,
		up.Nombres + ' ' + up.Apellidos as PrestadoPor,
		pr.RecepcionManual,
		pr.FechaRecepcion,
		ur.Nombres + ' ' + ur.Apellidos as RecibidoPor
	from Registro.PrestamoRecepcion pr
	left join Seguridad.Usuario u on u.UsuarioId = pr.UsuarioId
	left join Basico.Facultad f on f.FacultadId = u.FacultadId

	left join Basico.Equipo eq on eq.EquipoId = pr.EquipoId
	left join Basico.TipoEquipo teq on teq.TipoEquipoId = eq.TipoEquipoId

	left join Sistema.TipoUsuario tu on tu.TipoUsuarioId = pr.UsuarioId
	left join Seguridad.Usuario up on up.UsuarioId = pr.AuxilliarPrestaId
	left join Seguridad.Usuario ur on ur.UsuarioId = pr.AuxilliarRecibeId
GO
/****** Object:  UserDefinedFunction [Reportes].[EstadisticasPrestamoEquipos]    Script Date: 3/6/2025 4:19:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [Reportes].[EstadisticasPrestamoEquipos]
(	
	@FiltroFechaInicio datetime,
	@FiltroFechaFin datetime
)
RETURNS TABLE 
AS
RETURN 
(
	select
		e.TipoEquipoId,
		e.EquipoId,
		te.Descripcion as TipoEquipo,
		te.Marca,
		te.Referencia,
		te.Activo as TipoEquipoActivo,
		(
			select count(PrestamoRecepcionId) 
			from Registro.PrestamoRecepcion pr
			left join Basico.Equipo eq on eq.EquipoId = pr.EquipoId
			where 
				eq.TipoEquipoId = e.TipoEquipoId 
				AND
				(FechaPrestamo >= COALESCE(@FiltroFechaInicio,FechaPrestamo ))
				AND 
				(FechaPrestamo <= COALESCE(@FiltroFechaFin,FechaPrestamo ))
		) as PrestamosTipoEquipo,
		e.CodigoLaboratorio,
		e.Serial,
		e.CodigoInventario,
		(
			select count(PrestamoRecepcionId) 
			from Registro.PrestamoRecepcion pr 
			where 
				pr.EquipoId = e.EquipoId
				AND
				(FechaPrestamo >= COALESCE(@FiltroFechaInicio,FechaPrestamo ))
				AND 
				(FechaPrestamo <= COALESCE(@FiltroFechaFin,FechaPrestamo ))
		) as PrestamosEquipo,
		e.Activo as EquipoActivo
		from 
		Basico.Equipo e
		left join Basico.TipoEquipo te on te.TipoEquipoId = e.TipoEquipoId
)
GO
/****** Object:  View [Reportes].[View_EstadisticasPrestamoEquipos]    Script Date: 3/6/2025 4:19:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [Reportes].[View_EstadisticasPrestamoEquipos]
AS

	select * from Reportes.EstadisticasPrestamoEquipos (null, null)
GO
/****** Object:  View [Seguridad].[View_Menu_Gestion]    Script Date: 3/6/2025 4:19:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [Seguridad].[View_Menu_Gestion]
AS
	SELECT * FROM 
	Seguridad.Menu
	Where Grupo = 'Gestion'
GO
/****** Object:  View [Seguridad].[View_Menu_Principal]    Script Date: 3/6/2025 4:19:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [Seguridad].[View_Menu_Principal]
AS
	SELECT * FROM 
	Seguridad.Menu
	Where Grupo = 'Principal'
GO
/****** Object:  View [Basico].[View_TipoEquipo]    Script Date: 3/6/2025 4:19:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [Basico].[View_TipoEquipo]
AS
	SELECT 
		te.TipoEquipoId, te.CreadoId, te.ModificadoId,
		te.Descripcion, te.Marca, te.Referencia, te.Activo,
		uc.Nombres+' '+uc.Apellidos as Creado,
		te.FechaCreacion as FechaCreado,
		te.FechaModificacion as FechaModificado,
		um.Nombres+' '+um.Apellidos as Modificado
	FROM 
	Basico.TipoEquipo te
	LEFT JOIN Seguridad.Usuario uc ON uc.UsuarioId = te.CreadoId
	LEFT JOIN Seguridad.Usuario um ON um.UsuarioId = te.ModificadoId
GO
/****** Object:  View [Basico].[View_UsuarioPrestamo]    Script Date: 3/6/2025 4:19:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [Basico].[View_UsuarioPrestamo]
AS
	SELECT u.Activo, u.Nombres, u.Apellidos, u.Documento AS Documento, f.Nombre AS Facultad, u.BarCode, u.UsuarioId
	FROM 
	Seguridad.Usuario u
	LEFT JOIN Basico.Facultad f ON f.FacultadId = U.FacultadId
GO
/****** Object:  View [Basico].[View_Administrativo]    Script Date: 3/6/2025 4:19:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE VIEW [Basico].[View_Administrativo]
AS
	SELECT 
		u.UsuarioId, uc.UsuarioId AS UsuarioCreaId, um.UsuarioId AS UsuarioModificaId, u.Documento, u.Barcode, u.Nombres, u.Apellidos, '' AS [Password],
		u.Activo, u.FechaCreacion, u.FechaModificacion,
		uc.Nombres + ' '+ uc.Apellidos AS Creado, um.Nombres + ' '+ um.Apellidos AS Modificado, u.CorreoElectronico
		FROM 
		Seguridad.Usuario u
		LEFT JOIN Seguridad.Usuario uc ON uc.UsuarioId = u.CreadoId
		LEFT JOIN Seguridad.Usuario um ON um.UsuarioId = u.ModificadoId
		WHERE u.TipoUsuarioId =4
GO
/****** Object:  View [Basico].[View_Auxiliar]    Script Date: 3/6/2025 4:19:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE VIEW [Basico].[View_Auxiliar]
AS
	SELECT 
		u.UsuarioId, uc.UsuarioId AS UsuarioCreaId, um.UsuarioId AS UsuarioModificaId, u.Documento, u.Barcode, u.Nombres, u.Apellidos, '' AS [Password], 
		u.Activo, u.FechaCreacion, u.FechaModificacion,
		uc.Nombres + ' '+ uc.Apellidos AS Creado, um.Nombres + ' '+ um.Apellidos AS Modificado, u.CorreoElectronico
		FROM 
		Seguridad.Usuario u
		LEFT JOIN Seguridad.Usuario uc ON uc.UsuarioId = u.CreadoId
		LEFT JOIN Seguridad.Usuario um ON um.UsuarioId = u.ModificadoId
		WHERE u.TipoUsuarioId =2
GO
/****** Object:  View [Basico].[View_Docente]    Script Date: 3/6/2025 4:19:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE VIEW [Basico].[View_Docente]
AS
	SELECT 
		u.UsuarioId, u.FacultadId, uc.UsuarioId AS UsuarioCreaId, um.UsuarioId AS UsuarioModificaId, u.Documento, u.Barcode, u.Nombres, u.Apellidos, 
		f.Nombre AS FacultadNombre,u.Activo, u.FechaCreacion, u.FechaModificacion,
		uc.Nombres + ' '+ uc.Apellidos AS Creado, um.Nombres + ' '+ um.Apellidos AS Modificado, u.CorreoElectronico
		FROM 
		Seguridad.Usuario u
		LEFT JOIN Basico.Facultad f ON f.FacultadId = u.FacultadId
		LEFT JOIN Seguridad.Usuario uc ON uc.UsuarioId = u.CreadoId
		LEFT JOIN Seguridad.Usuario um ON um.UsuarioId = u.ModificadoId
		WHERE u.TipoUsuarioId =3
GO
/****** Object:  View [Basico].[View_Historial_Docente]    Script Date: 3/6/2025 4:19:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [Basico].[View_Historial_Docente]
AS
	SELECT
		pr.PrestamorecepcionId, pr.UsuarioId, pr.EquipoId, eq.TipoEquipoId
		,pr.FechaPrestamo, pr.FechaRecepcion, eq.CodigoInventario, eq.CodigoLaboratorio, teq.Descripcion, teq.Marca
	FROM
	registro.PrestamoRecepcion pr
	LEFT JOIN Seguridad.Usuario u ON u.UsuarioId = pr.UsuarioId
	LEFT JOIN Basico.Equipo eq ON eq.EquipoId = pr.EquipoId
	LEFT JOIN Basico.TipoEquipo teq ON eq.TipoEquipoId = teq.TipoEquipoId
GO
/****** Object:  View [Basico].[View_Historial_Estudiante]    Script Date: 3/6/2025 4:19:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [Basico].[View_Historial_Estudiante]
AS
	SELECT
		pr.PrestamorecepcionId, pr.UsuarioId, pr.EquipoId, eq.TipoEquipoId
		,pr.FechaPrestamo, pr.FechaRecepcion, eq.CodigoInventario, eq.CodigoLaboratorio, teq.Descripcion, teq.Marca
	FROM
	registro.PrestamoRecepcion pr
	LEFT JOIN Seguridad.Usuario u ON u.UsuarioId = pr.UsuarioId
	LEFT JOIN Basico.Equipo eq ON eq.EquipoId = pr.EquipoId
	LEFT JOIN Basico.TipoEquipo teq ON eq.TipoEquipoId = teq.TipoEquipoId
GO
/****** Object:  Table [Sistema].[EstadoMulta]    Script Date: 3/6/2025 4:19:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Sistema].[EstadoMulta](
	[EstadoMultaId] [int] NOT NULL,
	[Descripcion] [varchar](50) NOT NULL,
 CONSTRAINT [PK_EstadoMulta] PRIMARY KEY CLUSTERED 
(
	[EstadoMultaId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [Basico].[View_Anotaciones]    Script Date: 3/6/2025 4:19:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE VIEW [Basico].[View_Anotaciones]
AS
	SELECT 
		a.AnotacionId, a.Descripcion,
		a.UsuarioId, ua.Nombres + ' ' + ua.Apellidos as Usuario,
		a.CreadoId, uc.Nombres+' '+uc.Apellidos as NombreCreador, a.FechaCreacion, 
		a.ModificadoId, umo.Nombres+' '+umo.Apellidos as NombreModifica, a.FechaModificacion,
		a.EstadoAnotacionId, ea.Descripcion as EstadoAnotacion
	FROM Registro.Anotacion a
	LEFT JOIN Seguridad.Usuario ua on ua.UsuarioId = a.UsuarioId
	LEFT JOIN Seguridad.Usuario uc on uc.UsuarioId = a.CreadoId
	LEFT JOIN Seguridad.Usuario umo on umo.UsuarioId = a.ModificadoId
	LEFT JOIN Sistema.EstadoMulta ea ON ea.EstadoMultaId = a.EstadoAnotacionId
GO
/****** Object:  View [Basico].[View_Multas]    Script Date: 3/6/2025 4:19:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE VIEW [Basico].[View_Multas]
AS
	SELECT 
		m.MultaId, m.Descripcion, m.Valor, 
		m.DeudorId, um.Nombres + ' ' + um.Apellidos as Deudor,
		m.CreadoId, uc.Nombres+' '+uc.Apellidos as NombreCreador, m.FechaCreacion, 
		m.ModificadoId, umo.Nombres+' '+umo.Apellidos as NombreModifica, m.FechaModificacion,
		m.EstadoMultaId, em.Descripcion as EstadoMulta
	FROM Registro.Multa m
	LEFT JOIN Seguridad.Usuario um on um.UsuarioId = m.DeudorId
	LEFT JOIN Seguridad.Usuario uc on uc.UsuarioId = m.CreadoId
	LEFT JOIN Seguridad.Usuario umo on umo.UsuarioId = m.ModificadoId
	LEFT JOIN Sistema.EstadoMulta em ON em.EstadoMultaId = m.EstadoMultaId
GO
/****** Object:  Table [Basico].[Sede]    Script Date: 3/6/2025 4:19:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Basico].[Sede](
	[SedeId] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [varchar](50) NOT NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime] NOT NULL,
	[FechaModificacion] [datetime] NULL,
	[CreadoId] [bigint] NOT NULL,
	[ModificadoId] [bigint] NULL,
 CONSTRAINT [PK_Sede] PRIMARY KEY CLUSTERED 
(
	[SedeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [Basico].[View_Facultad]    Script Date: 3/6/2025 4:19:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [Basico].[View_Facultad]
AS
	SELECT 
		f.FacultadId, 
		f.Nombre, 
		f.Codigo, 
		f.Activo, 
		f.SedeId,
		sd.Nombre AS NombreSede, 
		f.FechaCreacion, 
		f.CreadoId AS UsuarioCreaId, 
		uc.Nombres+' '+uc.Apellidos AS UsuarioCrea, 
		f.FechaModificacion, 
		f.ModificadoId AS UsuarioModificaId, 
		um.Nombres+' '+um.Apellidos AS UsuarioMoifica

		FROM 
		Basico.Facultad f
		LEFT JOIN Seguridad.Usuario uc ON uc.UsuarioId = f.CreadoId
		LEFT JOIN Seguridad.Usuario um ON um.UsuarioId = f.ModificadoId
		LEFT JOIN Basico.Sede sd ON sd.SedeId = f.SedeId
GO
/****** Object:  View [Basico].[View_Estudiante]    Script Date: 3/6/2025 4:19:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE VIEW [Basico].[View_Estudiante]
AS
	SELECT 
		u.UsuarioId, u.FacultadId, uc.UsuarioId AS UsuarioCreaId, um.UsuarioId AS UsuarioModificaId, u.Documento, u.Codigo, u.Barcode, u.SemestreBasico,u.Nombres, u.Apellidos, 
		f.Nombre AS FacultadNombre,u.Activo, u.FechaCreacion, u.FechaModificacion,
		uc.Nombres + ' '+ uc.Apellidos AS Creado, um.Nombres + ' '+ um.Apellidos AS Modificado
		FROM 
		Seguridad.Usuario u
		LEFT JOIN Basico.Facultad f ON f.FacultadId = u.FacultadId
		LEFT JOIN Seguridad.Usuario uc ON uc.UsuarioId = u.CreadoId
		LEFT JOIN Seguridad.Usuario um ON um.UsuarioId = u.ModificadoId
		WHERE u.TipoUsuarioId in (1)

GO
/****** Object:  View [Basico].[View_Sede]    Script Date: 3/6/2025 4:19:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [Basico].[View_Sede]
AS
	SELECT 
		Sd.SedeId,sd.Nombre,Sd.Activo,Sd.FechaCreacion,Sd.FechaModificacion,
		Sd.CreadoId, Sd.ModificadoId,
		uc.Nombres+' '+uc.Apellidos as Creado,
		um.Nombres+' '+um.Apellidos as Modificado
	FROM 
	Basico.Sede Sd
	LEFT JOIN Seguridad.Usuario uc ON uc.UsuarioId = Sd.CreadoId
	LEFT JOIN Seguridad.Usuario um ON um.UsuarioId = Sd.ModificadoId
GO
/****** Object:  View [Basico].[View_Auxiliar_Activo]    Script Date: 3/6/2025 4:19:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO










CREATE VIEW [Basico].[View_Auxiliar_Activo]
AS
	SELECT 
		u.UsuarioId, uc.UsuarioId AS UsuarioCreaId, um.UsuarioId AS UsuarioModificaId, u.Documento, u.Barcode, u.Nombres, u.Apellidos, '' AS [Password], 
		u.Nombres+' ' + u.Apellidos AS TextoCorto,
		u.Activo, u.FechaCreacion, u.FechaModificacion,
		uc.Nombres + ' '+ uc.Apellidos AS Creado, um.Nombres + ' '+ um.Apellidos AS Modificado, u.CorreoElectronico
		FROM 
		Seguridad.Usuario u
		LEFT JOIN Seguridad.Usuario uc ON uc.UsuarioId = u.CreadoId
		LEFT JOIN Seguridad.Usuario um ON um.UsuarioId = u.ModificadoId
		WHERE u.TipoUsuarioId =2 AND u.Activo=1
GO
/****** Object:  View [Basico].[View_TipoEquipo_Activo]    Script Date: 3/6/2025 4:19:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE VIEW [Basico].[View_TipoEquipo_Activo]
AS
	SELECT 
		te.TipoEquipoId, te.CreadoId, te.ModificadoId,
		te.Descripcion, te.Marca, te.Referencia, te.Activo,
		te.Descripcion+' \ '+te.Marca+' \ '+te.Referencia AS TextoCorto,
		uc.Nombres+' '+uc.Apellidos as Creado,
		te.FechaCreacion as FechaCreado,
		te.FechaModificacion as FechaModificado,
		um.Nombres+' '+um.Apellidos as Modificado
	FROM 
	Basico.TipoEquipo te
	LEFT JOIN Seguridad.Usuario uc ON uc.UsuarioId = te.CreadoId
	LEFT JOIN Seguridad.Usuario um ON um.UsuarioId = te.ModificadoId
	Where te.Activo=1
GO
/****** Object:  Table [Basico].[Restriccion]    Script Date: 3/6/2025 4:19:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Basico].[Restriccion](
	[RestriccionId] [int] IDENTITY(1,1) NOT NULL,
	[Descripcion] [varchar](1024) NOT NULL,
	[Texto] [varchar](1024) NOT NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime] NOT NULL,
	[FechaModificacion] [datetime] NULL,
	[CreadoId] [bigint] NOT NULL,
	[ModificadoId] [bigint] NULL,
 CONSTRAINT [PK_Restriccion] PRIMARY KEY CLUSTERED 
(
	[RestriccionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [Basico].[View_Restriccion]    Script Date: 3/6/2025 4:19:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [Basico].[View_Restriccion]
AS
	SELECT 
		r.RestriccionId, r.Descripcion, r.Texto, r.Activo, r.FechaCreacion, r.FechaModificacion, r.CreadoId, r.ModificadoId,

		uc.Nombres+' '+uc.Apellidos as Creado,
		um.Nombres+' '+um.Apellidos as Modificado
	FROM 
	Basico.Restriccion r
	LEFT JOIN Seguridad.Usuario uc ON uc.UsuarioId = r.CreadoId
	LEFT JOIN Seguridad.Usuario um ON um.UsuarioId = r.ModificadoId
GO
/****** Object:  Table [Basico].[RestriccionTipoEquipo]    Script Date: 3/6/2025 4:19:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Basico].[RestriccionTipoEquipo](
	[RestriccionTipoEquipoId] [int] IDENTITY(1,1) NOT NULL,
	[TipoEquipoId] [int] NOT NULL,
	[RestriccionId] [int] NOT NULL,
	[Activo] [bit] NOT NULL,
	[FechaCreacion] [datetime] NOT NULL,
	[FechaModificacion] [datetime] NULL,
	[CreadoId] [bigint] NOT NULL,
	[ModificadoId] [bigint] NULL,
 CONSTRAINT [PK_RestriccionEquipo] PRIMARY KEY CLUSTERED 
(
	[RestriccionTipoEquipoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [Basico].[View_RestriccionTipoEquipo]    Script Date: 3/6/2025 4:19:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO










CREATE VIEW [Basico].[View_RestriccionTipoEquipo]
AS
	SELECT 
		te.TipoEquipoId, r.RestriccionId, COALESCE(rte.RestriccionTipoEquipoId,-1) AS RestriccionTipoEquipoId, r.Descripcion, CONVERT(bit,IIF(rte.RestriccionId IS NULL,0,1)) AS Activa
	FROM 
	
	Basico.TipoEquipo te
	cross join Basico.Restriccion r
	left join Basico.RestriccionTipoEquipo rte on rte.TipoEquipoId = te.TipoEquipoId and rte.RestriccionId = r.RestriccionId and rte.Activo=1
	where r.Activo =1
GO
/****** Object:  View [Registro].[View_AnotacionesActivas]    Script Date: 3/6/2025 4:19:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [Registro].[View_AnotacionesActivas]
AS
	SELECT a.AnotacionId, ua.UsuarioId, ua.Documento, ua.Nombres+' '+ua.Apellidos as Nombre,a.Descripcion, uc.Nombres+' '+uc.Apellidos as NombreCreador, a.FechaCreacion, umo.Nombres+' '+umo.Apellidos as NombreModifica 
	FROM Registro.Anotacion a
	LEFT JOIN Seguridad.Usuario ua on ua.UsuarioId = a.UsuarioId
	LEFT JOIN Seguridad.Usuario uc on uc.UsuarioId = a.CreadoId
	LEFT JOIN Seguridad.Usuario umo on umo.UsuarioId = a.UsuarioId
	where a.EstadoAnotacionId = 1
GO
/****** Object:  View [Registro].[View_MultasActivas]    Script Date: 3/6/2025 4:19:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [Registro].[View_MultasActivas]
AS
	SELECT m.MultaId, m.DeudorId, um.Documento, um.Nombres+' '+um.Apellidos as Nombre,m.Descripcion, m.Valor, uc.Nombres+' '+uc.Apellidos as NombreCreador, m.FechaCreacion, umo.Nombres+' '+umo.Apellidos as NombreModifica, m.FechaModificacion
	FROM Registro.Multa m
	LEFT JOIN Seguridad.Usuario um on um.UsuarioId = m.DeudorId
	LEFT JOIN Seguridad.Usuario uc on uc.UsuarioId = m.CreadoId
	LEFT JOIN Seguridad.Usuario umo on umo.UsuarioId = m.FechaModificacion
	where m.EstadoMultaId=1
GO
/****** Object:  View [Registro].[View_EquiposACargo]    Script Date: 3/6/2025 4:19:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [Registro].[View_EquiposACargo]
AS
	SELECT pr.UsuarioId, e.EquipoId, e.CodigoLaboratorio,te.Descripcion AS TipoEquipo
	FROM 
	Registro.PrestamoRecepcion pr
	LEFT JOIN Basico.Equipo e ON e.EquipoId = pr.EquipoId
	LEFT JOIN Basico.TipoEquipo te ON te.TipoEquipoId = e.TipoEquipoId
	WHERE pr.FechaRecepcion IS NULL
GO
/****** Object:  View [Registro].[View_Historial]    Script Date: 3/6/2025 4:19:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [Registro].[View_Historial]
AS
	SELECT
		pr.PrestamorecepcionId, pr.UsuarioId, pr.AuxilliarPrestaId, pr.AuxilliarRecibeId, pr.EquipoId, eq.TipoEquipoId
		,u.Nombres, u.Apellidos, ap.Nombres + ' ' + ap.Apellidos AS AuxiliarPresta, ar.Nombres + ' ' + ar.Apellidos AS AuxiliarRecibe
		, pr.FechaPrestamo, pr.FechaRecepcion, eq.CodigoInventario, eq.CodigoLaboratorio, teq.Descripcion, teq.Marca
	FROM
	registro.PrestamoRecepcion pr
	LEFT JOIN Seguridad.Usuario u ON u.UsuarioId = pr.UsuarioId
	LEFT JOIN Seguridad.Usuario ap ON ap.UsuarioId= pr.AuxilliarPrestaId
	LEFT JOIN Seguridad.Usuario ar ON ar.UsuarioId= pr.AuxilliarRecibeId
	LEFT JOIN Basico.Equipo eq ON eq.EquipoId = pr.EquipoId
	LEFT JOIN Basico.TipoEquipo teq ON teq.TipoEquipoId = eq.TipoEquipoId
GO
/****** Object:  View [Seguridad].[View_UsuarioAutentica]    Script Date: 3/6/2025 4:19:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [Seguridad].[View_UsuarioAutentica]
AS
	SELECT 
	u.UsuarioId, u.TipoUsuarioId, u.Nombres, u.Apellidos, u.BarCode, u.Documento, u.FacultadId, u.Codigo
	FROM 
	Seguridad.Usuario u
GO
/****** Object:  View [Reportes].[View_EstadoMultas]    Script Date: 3/6/2025 4:19:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE VIEW [Reportes].[View_EstadoMultas]
AS

	Select 
	m.MultaId,

	m.DeudorId,
	deudor.Documento as DeudorDocumento,
	deudor.Nombres+' '+deudor.Apellidos as Deudor,
	tu.Nombre as TipoDeudor,

	m.CreadoId as UsuarioCreaId,
	uc.Nombres + ' ' + uc.Apellidos as UsuarioCrea,
	m.FechaCreacion as FechaCrea,
	
	m.ModificadoId as UsuarioModificaId,
	um.Nombres + ' ' + um.Apellidos as UsuarioModifica,
	m.FechaModificacion as FechaModifica,

	m.EstadoMultaId,
	em.Descripcion as EstadoMulta,

	m.Valor,
	m.Descripcion

	FROM 

	Registro.Multa m
	LEFT JOIN Seguridad.Usuario uc ON uc.UsuarioId = m.CreadoId
	LEFT JOIN Seguridad.Usuario um ON um.UsuarioId = m.ModificadoId
	LEFT JOIN Sistema.EstadoMulta em ON em.EstadoMultaId = m.EstadoMultaId
	LEFT JOIN Seguridad.Usuario deudor ON deudor.UsuarioId = m.DeudorId
	LEFT JOIN Sistema.TipoUsuario tu ON tu.TipoUsuarioId = deudor.TipoUsuarioId

GO
/****** Object:  View [Seguridad].[View_Menu]    Script Date: 3/6/2025 4:19:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [Seguridad].[View_Menu]
AS
	SELECT * FROM 
	Seguridad.Menu
	Where Grupo = 'Administrador'
GO
/****** Object:  View [Basico].[View_Equipo]    Script Date: 3/6/2025 4:19:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO










CREATE VIEW [Basico].[View_Equipo]
AS
	SELECT 
		e.EquipoId, e.CreadoId, e.ModificadoId,e.TipoEquipoId, e.CodigoInventario, e.CodigoLaboratorio, e.Serial,
		eac.UsuarioId as UsuarioResponsableId, ur.Nombres + ' ' + ur.Apellidos as UsuarioResponsable, ur.BarCode as UsuarioResponsableCodigoBarras,
		te.Descripcion as TipoEquipo, te.Marca, te.Referencia, e.Activo,
		uc.Nombres+' '+uc.Apellidos as Creado,
		e.FechaCreacion as FechaCreado,
		e.FechaModificacion as FechaModificado,
		um.Nombres+' '+um.Apellidos as Modificado,
		e.FechaCompra,
		e.ResponsableId as UsuarioInventarioResponsableId, uir.Nombres + ' ' + uir.Apellidos as UsuarioInventarioResponsable, uir.BarCode as UsuarioInventarioResponsableCodigoBarras
	FROM 
	Basico.Equipo e
	LEFT JOIN Basico.TipoEquipo te ON te.TipoEquipoId = e.TipoEquipoId
	LEFT JOIN Seguridad.Usuario uc ON uc.UsuarioId = e.CreadoId
	LEFT JOIN Seguridad.Usuario um ON um.UsuarioId = e.ModificadoId
	LEFT JOIN Registro.View_EquiposACargo eac ON eac.EquipoId = e.EquipoId
	LEFT JOIN Seguridad.Usuario ur ON ur.UsuarioId = eac.UsuarioId
	LEFT JOIN Seguridad.Usuario uir ON uir.UsuarioId = e.ResponsableId
GO
/****** Object:  View [Registro].[View_PrestamoRecepcion]    Script Date: 3/6/2025 4:19:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [Registro].[View_PrestamoRecepcion]
AS

	SELECT        u.UsuarioId, u.TipoUsuarioId, tu.Nombre AS TipoUsuario, u.BarCode,u.FacultadId,u.SemestreBasico,
                             (SELECT        COUNT(1) AS Expr1
                               FROM            Registro.View_AnotacionesActivas AS aa
                               WHERE        (UsuarioId = u.UsuarioId)) AS nAnotaciones,
                             (SELECT        COUNT(1) AS Expr1
                               FROM            Registro.View_MultasActivas AS ma
                               WHERE        (DeudorId = u.UsuarioId)) AS nMultas,
                             (SELECT        COUNT(1) AS Expr1
                               FROM            Registro.View_EquiposACargo AS eq
                               WHERE        (UsuarioId = u.UsuarioId)) AS nEquipos, u.Nombres, u.Apellidos, f.Nombre AS Facultad, u.Activo
	FROM            Seguridad.Usuario AS u LEFT OUTER JOIN
                         Sistema.TipoUsuario AS tu ON tu.TipoUsuarioId = u.TipoUsuarioId LEFT OUTER JOIN
                         Basico.Facultad AS f ON f.FacultadId = u.FacultadId
	WHERE        (u.TipoUsuarioId IN (1, 2,3)) and 
		(
			u.Activo=1 or 
			--Para activacion rápida en los meses seleccionados
			(
				SELECT IIF(COUNT(1)>0,1,0) 
				FROM 
				(
					SELECT CONVERT(int,splitdata) mes FROM Split(
						(select Valor from Sistema.Parametro where Nombre ='MesesActivacionRapida'),
						','
					)
				)T
				WHERE T.mes=(SELECT DATEPART(MONTH,GETDATE()))
			)=1
		)
GO
/****** Object:  View [Reportes].[View_PrestamoPorAuxiliar]    Script Date: 3/6/2025 4:19:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [Reportes].[View_PrestamoPorAuxiliar]
AS

	select * from 
	(
		select AuxiliarId, Fecha, count(1) Transacciones from (
			select pre.PrestamoRecepcionId, pre.AuxilliarPrestaId as AuxiliarId, CONVERT(varchar(10),FechaPrestamo,126) as Fecha from Registro.PrestamoRecepcion pre
			union 
			select rec.PrestamoRecepcionId,rec.AuxilliarRecibeId, CONVERT(varchar(10),FechaRecepcion,126) from Registro.PrestamoRecepcion rec where FechaRecepcion is not null
		) T 
		group by AuxiliarId, fecha
	)T
	left join 
	Seguridad.Usuario u on u.UsuarioId = AuxiliarId


GO
/****** Object:  Table [GestionInformacion].[EventoGestion]    Script Date: 3/6/2025 4:19:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [GestionInformacion].[EventoGestion](
	[EventoGestionId] [bigint] IDENTITY(1,1) NOT NULL,
	[TipoEventoGestionId] [int] NOT NULL,
	[UsuarioId] [bigint] NOT NULL,
	[FechaEvento] [datetime] NOT NULL,
 CONSTRAINT [PK_EventoGestion] PRIMARY KEY CLUSTERED 
(
	[EventoGestionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Migra].[EquipoMigra]    Script Date: 3/6/2025 4:19:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Migra].[EquipoMigra](
	[EquipoMigraId] [int] IDENTITY(1,1) NOT NULL,
	[TdeE] [varchar](250) NOT NULL,
	[CodigoL] [varchar](250) NOT NULL,
	[CodigoI] [varchar](250) NOT NULL,
	[Serial] [varchar](250) NOT NULL,
	[Activo] [nchar](10) NOT NULL,
	[EquipoId] [int] NULL,
	[TipoEquipoId] [int] NULL,
	[Migrar] [bit] NOT NULL,
 CONSTRAINT [PK_EquipoMigra] PRIMARY KEY CLUSTERED 
(
	[EquipoMigraId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Migra].[EquipoPrestadoMigra]    Script Date: 3/6/2025 4:19:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Migra].[EquipoPrestadoMigra](
	[EquipoPrestadoMigraId] [int] IDENTITY(1,1) NOT NULL,
	[Alumno] [varchar](250) NOT NULL,
	[Equipo] [varchar](250) NOT NULL,
 CONSTRAINT [PK_EquipoPrestadoMigra] PRIMARY KEY CLUSTERED 
(
	[EquipoPrestadoMigraId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Migra].[EstudianteMigra]    Script Date: 3/6/2025 4:19:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Migra].[EstudianteMigra](
	[EstudienteMigraId] [int] IDENTITY(1,1) NOT NULL,
	[Nombres] [varchar](250) NOT NULL,
	[Apellidos] [varchar](250) NOT NULL,
	[Codigo] [varchar](250) NOT NULL,
	[Facultad] [varchar](250) NOT NULL,
	[Activo] [bit] NOT NULL,
	[Deudor] [bit] NOT NULL,
 CONSTRAINT [PK_EstudianteMigra] PRIMARY KEY CLUSTERED 
(
	[EstudienteMigraId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Migra].[TipoEquipoMigra]    Script Date: 3/6/2025 4:19:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Migra].[TipoEquipoMigra](
	[TipoEquipoMigraId] [int] IDENTITY(1,1) NOT NULL,
	[TipoEquipoOriginal] [varchar](1024) NOT NULL,
	[TipoEquipoId] [int] NULL,
	[Descripcion] [varchar](50) NULL,
	[Marca] [varchar](50) NULL,
	[Referencia] [varchar](50) NULL,
 CONSTRAINT [PK_TipoEquipoMigra] PRIMARY KEY CLUSTERED 
(
	[TipoEquipoMigraId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Sistema].[EstadoAnotacion]    Script Date: 3/6/2025 4:19:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Sistema].[EstadoAnotacion](
	[EstadoAnotacionId] [int] NOT NULL,
	[Descripcion] [varchar](50) NOT NULL,
 CONSTRAINT [PK_EstadoAnotacion] PRIMARY KEY CLUSTERED 
(
	[EstadoAnotacionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Sistema].[TipoEventoGestion]    Script Date: 3/6/2025 4:19:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Sistema].[TipoEventoGestion](
	[TipoEventoGestionId] [int] NOT NULL,
	[Descripcion] [varchar](256) NULL,
 CONSTRAINT [PK_TipoEventoGestion] PRIMARY KEY CLUSTERED 
(
	[TipoEventoGestionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Registro].[Multa] ADD  CONSTRAINT [DF_Multa_EstadoMultaId]  DEFAULT ((1)) FOR [EstadoMultaId]
GO
ALTER TABLE [Basico].[Equipo]  WITH CHECK ADD  CONSTRAINT [FK_Equipo_Responsable] FOREIGN KEY([ResponsableId])
REFERENCES [Seguridad].[Usuario] ([UsuarioId])
GO
ALTER TABLE [Basico].[Equipo] CHECK CONSTRAINT [FK_Equipo_Responsable]
GO
ALTER TABLE [Basico].[Equipo]  WITH CHECK ADD  CONSTRAINT [FK_Equipo_TipoEquipo] FOREIGN KEY([TipoEquipoId])
REFERENCES [Basico].[TipoEquipo] ([TipoEquipoId])
GO
ALTER TABLE [Basico].[Equipo] CHECK CONSTRAINT [FK_Equipo_TipoEquipo]
GO
ALTER TABLE [Basico].[Equipo]  WITH CHECK ADD  CONSTRAINT [FK_Equipo_Usuario] FOREIGN KEY([CreadoId])
REFERENCES [Seguridad].[Usuario] ([UsuarioId])
GO
ALTER TABLE [Basico].[Equipo] CHECK CONSTRAINT [FK_Equipo_Usuario]
GO
ALTER TABLE [Basico].[Equipo]  WITH CHECK ADD  CONSTRAINT [FK_Equipo_Usuario1] FOREIGN KEY([ModificadoId])
REFERENCES [Seguridad].[Usuario] ([UsuarioId])
GO
ALTER TABLE [Basico].[Equipo] CHECK CONSTRAINT [FK_Equipo_Usuario1]
GO
ALTER TABLE [Basico].[Facultad]  WITH CHECK ADD  CONSTRAINT [FK_Facultad_Sede] FOREIGN KEY([SedeId])
REFERENCES [Basico].[Sede] ([SedeId])
GO
ALTER TABLE [Basico].[Facultad] CHECK CONSTRAINT [FK_Facultad_Sede]
GO
ALTER TABLE [Basico].[Facultad]  WITH CHECK ADD  CONSTRAINT [FK_Facultad_Usuario] FOREIGN KEY([CreadoId])
REFERENCES [Seguridad].[Usuario] ([UsuarioId])
GO
ALTER TABLE [Basico].[Facultad] CHECK CONSTRAINT [FK_Facultad_Usuario]
GO
ALTER TABLE [Basico].[Facultad]  WITH CHECK ADD  CONSTRAINT [FK_Facultad_Usuario1] FOREIGN KEY([ModificadoId])
REFERENCES [Seguridad].[Usuario] ([UsuarioId])
GO
ALTER TABLE [Basico].[Facultad] CHECK CONSTRAINT [FK_Facultad_Usuario1]
GO
ALTER TABLE [Basico].[Restriccion]  WITH CHECK ADD  CONSTRAINT [FK_Restriccion_Restriccion_Modifica] FOREIGN KEY([ModificadoId])
REFERENCES [Seguridad].[Usuario] ([UsuarioId])
GO
ALTER TABLE [Basico].[Restriccion] CHECK CONSTRAINT [FK_Restriccion_Restriccion_Modifica]
GO
ALTER TABLE [Basico].[Restriccion]  WITH CHECK ADD  CONSTRAINT [FK_Restriccion_Usuario_Crea] FOREIGN KEY([CreadoId])
REFERENCES [Seguridad].[Usuario] ([UsuarioId])
GO
ALTER TABLE [Basico].[Restriccion] CHECK CONSTRAINT [FK_Restriccion_Usuario_Crea]
GO
ALTER TABLE [Basico].[RestriccionTipoEquipo]  WITH CHECK ADD  CONSTRAINT [FK_RestriccionTipoEquipo_Restriccion] FOREIGN KEY([RestriccionId])
REFERENCES [Basico].[Restriccion] ([RestriccionId])
GO
ALTER TABLE [Basico].[RestriccionTipoEquipo] CHECK CONSTRAINT [FK_RestriccionTipoEquipo_Restriccion]
GO
ALTER TABLE [Basico].[RestriccionTipoEquipo]  WITH CHECK ADD  CONSTRAINT [FK_RestriccionTipoEquipo_TipoEquipo] FOREIGN KEY([TipoEquipoId])
REFERENCES [Basico].[TipoEquipo] ([TipoEquipoId])
GO
ALTER TABLE [Basico].[RestriccionTipoEquipo] CHECK CONSTRAINT [FK_RestriccionTipoEquipo_TipoEquipo]
GO
ALTER TABLE [Basico].[Sede]  WITH CHECK ADD  CONSTRAINT [FK_Sede_Usuario_Creado] FOREIGN KEY([CreadoId])
REFERENCES [Seguridad].[Usuario] ([UsuarioId])
GO
ALTER TABLE [Basico].[Sede] CHECK CONSTRAINT [FK_Sede_Usuario_Creado]
GO
ALTER TABLE [Basico].[Sede]  WITH CHECK ADD  CONSTRAINT [FK_Sede_Usuario_Modificado] FOREIGN KEY([ModificadoId])
REFERENCES [Seguridad].[Usuario] ([UsuarioId])
GO
ALTER TABLE [Basico].[Sede] CHECK CONSTRAINT [FK_Sede_Usuario_Modificado]
GO
ALTER TABLE [Basico].[TipoEquipo]  WITH CHECK ADD  CONSTRAINT [FK_TipoEquipo_Usuario] FOREIGN KEY([CreadoId])
REFERENCES [Seguridad].[Usuario] ([UsuarioId])
GO
ALTER TABLE [Basico].[TipoEquipo] CHECK CONSTRAINT [FK_TipoEquipo_Usuario]
GO
ALTER TABLE [Basico].[TipoEquipo]  WITH CHECK ADD  CONSTRAINT [FK_TipoEquipo_Usuario1] FOREIGN KEY([ModificadoId])
REFERENCES [Seguridad].[Usuario] ([UsuarioId])
GO
ALTER TABLE [Basico].[TipoEquipo] CHECK CONSTRAINT [FK_TipoEquipo_Usuario1]
GO
ALTER TABLE [GestionInformacion].[EventoGestion]  WITH CHECK ADD  CONSTRAINT [FK_EventoGestion_EventoGestion] FOREIGN KEY([TipoEventoGestionId])
REFERENCES [Sistema].[TipoEventoGestion] ([TipoEventoGestionId])
GO
ALTER TABLE [GestionInformacion].[EventoGestion] CHECK CONSTRAINT [FK_EventoGestion_EventoGestion]
GO
ALTER TABLE [GestionInformacion].[EventoGestion]  WITH CHECK ADD  CONSTRAINT [FK_EventoGestion_Usuario] FOREIGN KEY([UsuarioId])
REFERENCES [Seguridad].[Usuario] ([UsuarioId])
GO
ALTER TABLE [GestionInformacion].[EventoGestion] CHECK CONSTRAINT [FK_EventoGestion_Usuario]
GO
ALTER TABLE [Registro].[Anotacion]  WITH CHECK ADD  CONSTRAINT [FK_Anotacion_Anotacion] FOREIGN KEY([AnotacionId])
REFERENCES [Registro].[Anotacion] ([AnotacionId])
GO
ALTER TABLE [Registro].[Anotacion] CHECK CONSTRAINT [FK_Anotacion_Anotacion]
GO
ALTER TABLE [Registro].[Anotacion]  WITH CHECK ADD  CONSTRAINT [FK_Anotacion_EstadoAnotacion] FOREIGN KEY([EstadoAnotacionId])
REFERENCES [Sistema].[EstadoAnotacion] ([EstadoAnotacionId])
GO
ALTER TABLE [Registro].[Anotacion] CHECK CONSTRAINT [FK_Anotacion_EstadoAnotacion]
GO
ALTER TABLE [Registro].[Anotacion]  WITH CHECK ADD  CONSTRAINT [FK_Anotacion_Usuario] FOREIGN KEY([UsuarioId])
REFERENCES [Seguridad].[Usuario] ([UsuarioId])
GO
ALTER TABLE [Registro].[Anotacion] CHECK CONSTRAINT [FK_Anotacion_Usuario]
GO
ALTER TABLE [Registro].[Anotacion]  WITH CHECK ADD  CONSTRAINT [FK_Anotacion_Usuario1] FOREIGN KEY([CreadoId])
REFERENCES [Seguridad].[Usuario] ([UsuarioId])
GO
ALTER TABLE [Registro].[Anotacion] CHECK CONSTRAINT [FK_Anotacion_Usuario1]
GO
ALTER TABLE [Registro].[Anotacion]  WITH CHECK ADD  CONSTRAINT [FK_Anotacion_Usuario2] FOREIGN KEY([ModificadoId])
REFERENCES [Seguridad].[Usuario] ([UsuarioId])
GO
ALTER TABLE [Registro].[Anotacion] CHECK CONSTRAINT [FK_Anotacion_Usuario2]
GO
ALTER TABLE [Registro].[Multa]  WITH CHECK ADD  CONSTRAINT [FK_Multa_Usuario] FOREIGN KEY([DeudorId])
REFERENCES [Seguridad].[Usuario] ([UsuarioId])
GO
ALTER TABLE [Registro].[Multa] CHECK CONSTRAINT [FK_Multa_Usuario]
GO
ALTER TABLE [Registro].[Multa]  WITH CHECK ADD  CONSTRAINT [FK_Multa_Usuario1] FOREIGN KEY([CreadoId])
REFERENCES [Seguridad].[Usuario] ([UsuarioId])
GO
ALTER TABLE [Registro].[Multa] CHECK CONSTRAINT [FK_Multa_Usuario1]
GO
ALTER TABLE [Registro].[Multa]  WITH CHECK ADD  CONSTRAINT [FK_Multa_Usuario2] FOREIGN KEY([ModificadoId])
REFERENCES [Seguridad].[Usuario] ([UsuarioId])
GO
ALTER TABLE [Registro].[Multa] CHECK CONSTRAINT [FK_Multa_Usuario2]
GO
ALTER TABLE [Registro].[PrestamoRecepcion]  WITH CHECK ADD  CONSTRAINT [FK_PrestamoRecepcion_Equipo] FOREIGN KEY([EquipoId])
REFERENCES [Basico].[Equipo] ([EquipoId])
GO
ALTER TABLE [Registro].[PrestamoRecepcion] CHECK CONSTRAINT [FK_PrestamoRecepcion_Equipo]
GO
ALTER TABLE [Registro].[PrestamoRecepcion]  WITH CHECK ADD  CONSTRAINT [FK_PrestamoRecepcion_Facultad] FOREIGN KEY([FacultadId])
REFERENCES [Basico].[Facultad] ([FacultadId])
GO
ALTER TABLE [Registro].[PrestamoRecepcion] CHECK CONSTRAINT [FK_PrestamoRecepcion_Facultad]
GO
ALTER TABLE [Registro].[PrestamoRecepcion]  WITH CHECK ADD  CONSTRAINT [FK_PrestamoRecepcion_Usuario] FOREIGN KEY([AuxilliarPrestaId])
REFERENCES [Seguridad].[Usuario] ([UsuarioId])
GO
ALTER TABLE [Registro].[PrestamoRecepcion] CHECK CONSTRAINT [FK_PrestamoRecepcion_Usuario]
GO
ALTER TABLE [Registro].[PrestamoRecepcion]  WITH CHECK ADD  CONSTRAINT [FK_PrestamoRecepcion_Usuario1] FOREIGN KEY([UsuarioId])
REFERENCES [Seguridad].[Usuario] ([UsuarioId])
GO
ALTER TABLE [Registro].[PrestamoRecepcion] CHECK CONSTRAINT [FK_PrestamoRecepcion_Usuario1]
GO
ALTER TABLE [Seguridad].[Menu]  WITH CHECK ADD  CONSTRAINT [FK_Menu_Usuario_Crea] FOREIGN KEY([CreaId])
REFERENCES [Seguridad].[Usuario] ([UsuarioId])
GO
ALTER TABLE [Seguridad].[Menu] CHECK CONSTRAINT [FK_Menu_Usuario_Crea]
GO
ALTER TABLE [Seguridad].[Menu]  WITH CHECK ADD  CONSTRAINT [FK_Menu_Usuario_Modifica] FOREIGN KEY([ModificaId])
REFERENCES [Seguridad].[Usuario] ([UsuarioId])
GO
ALTER TABLE [Seguridad].[Menu] CHECK CONSTRAINT [FK_Menu_Usuario_Modifica]
GO
ALTER TABLE [Seguridad].[Usuario]  WITH CHECK ADD  CONSTRAINT [FK_Usuario_Facultad] FOREIGN KEY([FacultadId])
REFERENCES [Basico].[Facultad] ([FacultadId])
GO
ALTER TABLE [Seguridad].[Usuario] CHECK CONSTRAINT [FK_Usuario_Facultad]
GO
ALTER TABLE [Seguridad].[Usuario]  WITH CHECK ADD  CONSTRAINT [FK_Usuario_TipoUsuario] FOREIGN KEY([TipoUsuarioId])
REFERENCES [Sistema].[TipoUsuario] ([TipoUsuarioId])
GO
ALTER TABLE [Seguridad].[Usuario] CHECK CONSTRAINT [FK_Usuario_TipoUsuario]
GO
ALTER TABLE [Seguridad].[Usuario]  WITH CHECK ADD  CONSTRAINT [FK_Usuario_Usuario] FOREIGN KEY([ModificadoId])
REFERENCES [Seguridad].[Usuario] ([UsuarioId])
GO
ALTER TABLE [Seguridad].[Usuario] CHECK CONSTRAINT [FK_Usuario_Usuario]
GO
ALTER TABLE [Seguridad].[Usuario]  WITH CHECK ADD  CONSTRAINT [FK_Usuario_Usuario1] FOREIGN KEY([CreadoId])
REFERENCES [Seguridad].[Usuario] ([UsuarioId])
GO
ALTER TABLE [Seguridad].[Usuario] CHECK CONSTRAINT [FK_Usuario_Usuario1]
GO
/****** Object:  StoredProcedure [Basico].[Administrativo]    Script Date: 3/6/2025 4:19:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [Basico].[Administrativo] 
	@FiltroTexto varchar(MAX),
	@FiltroActivo bit
AS
BEGIN
	SET NOCOUNT ON; 
	
	DECLARE @filtros AS TABLE (filtro VARCHAR(max))

	INSERT INTO @filtros SELECT '%'+splitdata+'%' FROM Split(@filtrotexto,' ')

		SELECT * FROM [Basico].[View_Administrativo]
		WHERE
			(SELECT IIF(count(1)=0,1,0) from @filtros)=1			
			OR
			(SELECT COUNT(1) FROM @filtros WHERE (Documento+' '+Barcode+' '+' '+Nombres +' '+ Apellidos) LIKE filtro)>0
END
GO
/****** Object:  StoredProcedure [Basico].[Auxiliar]    Script Date: 3/6/2025 4:19:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [Basico].[Auxiliar] 
	@FiltroTexto varchar(MAX),
	@FiltroActivo bit
AS
BEGIN
	SET NOCOUNT ON; 
	
	DECLARE @filtros AS TABLE (filtro VARCHAR(max))

	INSERT INTO @filtros SELECT '%'+splitdata+'%' FROM Split(@filtrotexto,' ')

		SELECT * FROM [Basico].[View_Auxiliar]
		WHERE
			(SELECT IIF(count(1)=0,1,0) from @filtros)=1			
			OR
			(SELECT COUNT(1) FROM @filtros WHERE (Documento+' '+Barcode+' '+' '+Nombres +' '+ Apellidos) LIKE filtro)>0
END
GO
/****** Object:  StoredProcedure [Basico].[Docente]    Script Date: 3/6/2025 4:19:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [Basico].[Docente] 
	@FiltroTexto varchar(MAX),
	@FiltroActivo bit
AS
BEGIN
	SET NOCOUNT ON; 
	
	DECLARE @filtros AS TABLE (filtro VARCHAR(max))

	INSERT INTO @filtros SELECT '%'+splitdata+'%' FROM Split(@filtrotexto,' ')

		SELECT * FROM [Basico].[View_Docente]
		WHERE
			(SELECT IIF(count(1)=0,1,0) from @filtros)=1			
			OR
			(SELECT COUNT(1) FROM @filtros WHERE (Documento+' '+Barcode+' '+' '+Nombres +' '+ Apellidos+' '+ISNULL(FacultadNombre,'')) LIKE filtro)>0
END
GO
/****** Object:  StoredProcedure [Basico].[Equipos]    Script Date: 3/6/2025 4:19:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [Basico].[Equipos] 
	@FiltroTexto varchar(MAX),
	@FiltroActivo bit
AS
BEGIN
	SET NOCOUNT ON; 
	
	DECLARE @filtros AS TABLE (filtro VARCHAR(max))

	INSERT INTO @filtros SELECT '%'+splitdata+'%' FROM Split(@filtrotexto,' ')

		SELECT * FROM [Basico].[View_Equipo]
		WHERE
			(SELECT IIF(count(1)=0,1,0) from @filtros)=1			
			OR
			(SELECT COUNT(1) FROM @filtros WHERE (CodigoLaboratorio+' '+ISNULL(CodigoInventario,'')+' '+' '+ISNULL(Serial,'') +' '+ ISNULL(UsuarioResponsable,'')+' '+ISNULL(TipoEquipo,'')+' '+ISNULL(Marca,'')+' '+ISNULL(Referencia,'')) LIKE filtro)>0
END
GO
/****** Object:  StoredProcedure [Basico].[Estudiante]    Script Date: 3/6/2025 4:19:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [Basico].[Estudiante] 
	@FiltroTexto varchar(MAX),
	@FiltroActivo bit
AS
BEGIN
	SET NOCOUNT ON; 
	
	DECLARE @filtros AS TABLE (filtro VARCHAR(max))

	INSERT INTO @filtros SELECT '%'+splitdata+'%' FROM Split(@filtrotexto,' ')

		SELECT * FROM [Basico].[View_Estudiante]
		WHERE
			(SELECT IIF(count(1)=0,1,0) from @filtros)=1			
			OR
			(SELECT COUNT(1) FROM @filtros WHERE (Documento+' '+Barcode+' '+ISNULL(Codigo,'')+' '+Nombres +' '+ Apellidos+' '+ISNULL(FacultadNombre,'')) LIKE filtro)>0
END
GO
/****** Object:  StoredProcedure [Basico].[Facultades]    Script Date: 3/6/2025 4:19:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [Basico].[Facultades] 
	@FiltroTexto varchar(MAX),
	@FiltroActivo bit
AS
BEGIN
	SET NOCOUNT ON; 
	
	DECLARE @filtros AS TABLE (filtro VARCHAR(max))

	INSERT INTO @filtros SELECT '%'+splitdata+'%' FROM Split(@filtrotexto,' ')

		SELECT * FROM [Basico].[View_Facultad]
		WHERE
			(SELECT IIF(count(1)=0,1,0) from @filtros)=1			
			OR
			(SELECT COUNT(1) FROM @filtros WHERE (ISNULL(Nombre,'')+' '+ISNULL(CONVERT(varchar(MAX),codigo),'')) LIKE filtro)>0
END
GO
/****** Object:  StoredProcedure [Basico].[Restricciones]    Script Date: 3/6/2025 4:19:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [Basico].[Restricciones] 
	@FiltroTexto varchar(MAX),
	@FiltroActivo bit
AS
BEGIN
	SET NOCOUNT ON; 
	
	DECLARE @filtros AS TABLE (filtro VARCHAR(max))

	INSERT INTO @filtros SELECT '%'+splitdata+'%' FROM Split(@filtrotexto,' ')

		SELECT * FROM [Basico].[View_Restriccion]
		WHERE
			(
				(SELECT IIF(count(1)=0,1,0) from @filtros)=1			
				OR
				(SELECT COUNT(1) FROM @filtros WHERE (CONCAT(ISNULL(Descripcion,''),ISNULL(Texto,''))) LIKE filtro)>0
			)
			AND
			Activo = IIF(@FiltroActivo IS nuLL,Activo, @FiltroActivo)
END
GO
/****** Object:  StoredProcedure [Basico].[Sedes]    Script Date: 3/6/2025 4:19:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
Create PROCEDURE [Basico].[Sedes] 
	@FiltroTexto varchar(MAX),
	@FiltroActivo bit
AS
BEGIN
	SET NOCOUNT ON; 
	
	DECLARE @filtros AS TABLE (filtro VARCHAR(max))

	INSERT INTO @filtros SELECT '%'+splitdata+'%' FROM Split(@filtrotexto,' ')

		SELECT * FROM [Basico].[View_Sede]
		WHERE
			(SELECT IIF(count(1)=0,1,0) from @filtros)=1			
			OR
			(SELECT COUNT(1) FROM @filtros WHERE (ISNULL(Nombre,'')) LIKE filtro)>0
END
GO
/****** Object:  StoredProcedure [Basico].[TiposEquipo]    Script Date: 3/6/2025 4:19:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [Basico].[TiposEquipo] 
	@FiltroTexto varchar(MAX),
	@FiltroActivo bit
AS
BEGIN
	SET NOCOUNT ON; 
	
	DECLARE @filtros AS TABLE (filtro VARCHAR(max))

	INSERT INTO @filtros SELECT '%'+splitdata+'%' FROM Split(@filtrotexto,' ')

		SELECT * FROM [Basico].[View_TipoEquipo]
		WHERE
			(SELECT IIF(count(1)=0,1,0) from @filtros)=1			
			OR
			(SELECT COUNT(1) FROM @filtros WHERE (ISNULL(Descripcion,'')+' '+ISNULL(Marca,'')+' '+' '+ISNULL(Referencia,'')) LIKE filtro)>0
END
GO
/****** Object:  StoredProcedure [GestionInformacion].[ActivarEstudiantes]    Script Date: 3/6/2025 4:19:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [GestionInformacion].[ActivarEstudiantes] 
	@UsuarioId bigInt,
	@UsuarioIdActivar bigInt
AS
BEGIN
	DECLARE @tipoUsuario AS BIGINT = (SELECT TipoUsuarioId from Seguridad.Usuario where UsuarioId=@UsuarioId)
	DECLARE @mesesActivacionParametro AS VARCHAR(126) = (SELECT Valor FROM Sistema.Parametro WHERE Nombre = 'MesesActivacionRapida')
	DECLARE @mesesActivacion AS TABLE(mes int);
	INSERT INTO @mesesActivacion SELECT splitdata FROM dbo.Split(@mesesActivacionParametro, ',')
	DECLARE @mesAutorizado AS int = (SELECT IIF(count(1)>0,1,0) FROM  @mesesActivacion where mes = DATEPART(MONTH,GETDATE()))
	IF (@mesAutorizado<>1) BEGIN
		THROW 51002, 'El mes actual no esta autorizado para activar estudiantes. Para activar estudiantes use la opción de editar.', 1
	END


	IF (@tipoUsuario<>0 and @tipoUsuario<>4 and @tipoUsuario<>2) OR @tipoUsuario IS NULL BEGIN
		THROW 51000, 'El usuario no tine los permisos para activar a los estudiantes', 1
	END
	BEGIN TRANSACTION I
	BEGIN TRY 
		--INSERT INTO GestionInformacion.EventoGestion (TipoEventoGestionId,UsuarioId,FechaEvento) values (x,@UsuarioId,GETDATE())
		UPDATE Seguridad.Usuario SET Activo = 1 WHERE TipoUsuarioId = 1 and UsuarioId=@UsuarioIdActivar
		COMMIT TRANSACTION I
	END TRY
	BEGIN CATCH 
		THROW 51001, 'Error al activar estudiantes', 1
		ROLLBACK TRANSACTION I 
	END CATCH
END
GO
/****** Object:  StoredProcedure [GestionInformacion].[EliminarEstudiantes]    Script Date: 3/6/2025 4:19:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [GestionInformacion].[EliminarEstudiantes] 
	@UsuarioId bigInt
AS
BEGIN
	DECLARE @tipoUsuario AS BIGINT = (SELECT TipoUsuarioId from Seguridad.Usuario where UsuarioId=@UsuarioId)
	IF (@tipoUsuario<>0 and @tipoUsuario<>4 and @tipoUsuario<>2) OR @tipoUsuario IS NULL BEGIN
		THROW 51000, 'El usuario no tine los permisos para eliminar a los estudiantes', 1
	END
	BEGIN TRANSACTION I
	BEGIN TRY 
		INSERT INTO GestionInformacion.EventoGestion (TipoEventoGestionId,UsuarioId,FechaEvento) values (2,@UsuarioId,GETDATE())
		DECLARE @estudiantesId AS TABLE (UsuarioId INT);

		INSERT INTO @estudiantesId
		SELECT UsuarioIdInactivo FROM [GestionInformacion].[View_CandidatosEliminar];

		DELETE FROM Registro.Multa WHERE DeudorId in 
		(SELECT UsuarioId FROM @estudiantesId);

		DELETE FROM Registro.Anotacion WHERE UsuarioId in 
		(SELECT UsuarioId FROM @estudiantesId);

		DELETE FROM Registro.PrestamoRecepcion WHERE UsuarioId in
		(SELECT UsuarioId FROM @estudiantesId);

		DELETE FROM Seguridad.Usuario WHERE UsuarioId in 
		(SELECT UsuarioId FROM @estudiantesId);

		COMMIT TRANSACTION I 
	END TRY
	BEGIN CATCH 
		ROLLBACK TRANSACTION I 
		DECLARE @error VARCHAR(MAX) = 
		(
			SELECT CONCAT(
				'Error al eliminar estudiantes',
				(SELECT ERROR_MESSAGE())
			)
		); 
		THROW 51003, @error, 1
	END CATCH
END
GO
/****** Object:  StoredProcedure [GestionInformacion].[InactivarEstudiantes]    Script Date: 3/6/2025 4:19:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [GestionInformacion].[InactivarEstudiantes] 
	@UsuarioId bigInt
AS
BEGIN
	DECLARE @tipoUsuario AS BIGINT = (SELECT TipoUsuarioId from Seguridad.Usuario where UsuarioId=@UsuarioId);
	DECLARE @mesesInactivacionParametro AS VARCHAR(126) = (SELECT Valor FROM Sistema.Parametro WHERE Nombre = 'MesesInactivacion');
	DECLARE @mesesInactivacion AS TABLE(mes int);
	INSERT INTO @mesesInactivacion SELECT splitdata FROM dbo.Split(@mesesInactivacionParametro, ',');
	DECLARE @mesAutorizado AS int = (SELECT IIF(count(1)>0,1,0) FROM  @mesesInactivacion where mes = DATEPART(MONTH,GETDATE()));
	IF (@mesAutorizado<>1) BEGIN
		THROW 51002, 'El mes actual no esta autorizado para inactivar estudiantes', 1
	END


	IF (@tipoUsuario<>0 and @tipoUsuario<>4and @tipoUsuario<>2) OR @tipoUsuario IS NULL BEGIN
		THROW 51000, 'El usuario no tine los permisos para inactivar a los estudiantes', 1
	END
	BEGIN TRY 
		BEGIN TRANSACTION A
		INSERT INTO GestionInformacion.EventoGestion (TipoEventoGestionId,UsuarioId,FechaEvento) values (1,@UsuarioId,GETDATE())
		UPDATE Seguridad.Usuario SET Activo = 0 WHERE TipoUsuarioId = 1
		COMMIT TRANSACTION A
	END TRY
	BEGIN CATCH 
		ROLLBACK TRANSACTION A;
		DECLARE @error VARCHAR(MAX) = 
		(
			SELECT CONCAT(
				'Error al inactivar estudiantes',
				(SELECT ERROR_MESSAGE())
			)
		); 
		THROW 51001, @error, 1;
	END CATCH
END
GO
/****** Object:  StoredProcedure [GestionInformacion].[InformacionEliminarEstudiantes]    Script Date: 3/6/2025 4:19:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [GestionInformacion].[InformacionEliminarEstudiantes] 
	@UsuarioId bigInt
AS
BEGIN
	
	SELECT (SELECT count(1) FROM [GestionInformacion].[View_Inactivos]) AS Inactivos,count(UsuarioIdInactivo) AS Candidatos,SUM(Prestamos) AS HistorialEliminar FROM	[GestionInformacion].[View_CandidatosEliminar]
END
GO
/****** Object:  StoredProcedure [Registro].[Historial]    Script Date: 3/6/2025 4:19:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [Registro].[Historial] 
	@FiltroTexto varchar(MAX)
AS
BEGIN
	SET NOCOUNT ON; 
	
	DECLARE @filtros AS TABLE (filtro VARCHAR(max))

	INSERT INTO @filtros SELECT '%'+splitdata+'%' FROM Split(@filtrotexto,' ')

		SELECT * FROM Registro.View_Historial
		WHERE
			(SELECT IIF(count(1)=0,1,0) from @filtros)=1			
			OR
			(SELECT COUNT(1) FROM @filtros WHERE (Nombres+' '+Apellidos+' '+CodigoLaboratorio+' '+ Descripcion+' '+Marca) LIKE filtro)>0
END
GO
/****** Object:  StoredProcedure [Reportes].[DetallePrestamoRecepcion]    Script Date: 3/6/2025 4:19:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [Reportes].[DetallePrestamoRecepcion] 
	@FiltroFechaInicio datetime,
	@FiltroFechaFin datetime,
	@FacultadId int NULL
AS
BEGIN
	SET NOCOUNT ON; 
	select * from 
	Reportes.View_DetallePrestamoRecepcion
	where 
	FechaPrestamo >= @FiltroFechaInicio
	and 
	FechaPrestamo <= @FiltroFechaFin
	and 
	(FacultadId=IIF(@FacultadId IS NULL,FacultadId,@FacultadId))
END
GO
/****** Object:  StoredProcedure [Seguridad].[MenuUsuario]    Script Date: 3/6/2025 4:19:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [Seguridad].[MenuUsuario] 
	@UsuarioId bigint
AS
BEGIN
	SET NOCOUNT ON; 
	
	Select * from Seguridad.View_Menu 
	WHERE Activo=1
	ORDER BY Orden
END
GO
/****** Object:  StoredProcedure [Seguridad].[MenuUsuarioGestion]    Script Date: 3/6/2025 4:19:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [Seguridad].[MenuUsuarioGestion] 
	@UsuarioId bigint
AS
BEGIN
	SET NOCOUNT ON; 
	
	Select * from Seguridad.View_Menu_Gestion 
	WHERE Activo=1
	ORDER BY Orden
END
GO
/****** Object:  StoredProcedure [Seguridad].[MenuUsuarioPrincipal]    Script Date: 3/6/2025 4:19:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [Seguridad].[MenuUsuarioPrincipal] 
	@UsuarioId bigint
AS
BEGIN
	SET NOCOUNT ON; 
	
	Select * from Seguridad.View_Menu_Principal 
	WHERE Activo=1
	ORDER BY Orden
END
GO
/****** Object:  StoredProcedure [Seguridad].[MenuUsuarioReportes]    Script Date: 3/6/2025 4:19:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [Seguridad].[MenuUsuarioReportes] 
	@UsuarioId bigint
AS
BEGIN
	SET NOCOUNT ON; 
	
	Select * from Seguridad.View_Menu_Reportes 
	WHERE Activo=1
	ORDER BY Orden
END
GO
/****** Object:  StoredProcedure [Seguridad].[Validar]    Script Date: 3/6/2025 4:19:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [Seguridad].[Validar] 
	@user varchar(MAX),
	@password varchar(MAX)
AS
BEGIN

		SELECT u.UsuarioId, u.TipoUsuarioId, u.Nombres, u.Apellidos, u.BarCode, u.Documento, u.FacultadId, u.Codigo FROM Seguridad.Usuario u
		WHERE 
			u.Activo = 1 AND 
			u.Documento = @user AND 
			u.TipoUsuarioId in (0,2,4) AND
			u.[Password]=CONVERT(varbinary(MAX),@password) AND 
			u.[Password] IS NOT NULL;
END
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Referencia a las tablas de migración de equipos' , @level0type=N'SCHEMA',@level0name=N'Basico', @level1type=N'TABLE',@level1name=N'Equipo', @level2type=N'COLUMN',@level2name=N'EquipoMigraId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "u"
            Begin Extent = 
               Top = 7
               Left = 48
               Bottom = 170
               Right = 268
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'Asistencia', @level1type=N'VIEW',@level1name=N'View_AsistenciaEstudiante'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'Asistencia', @level1type=N'VIEW',@level1name=N'View_AsistenciaEstudiante'
GO
USE [master]
GO
ALTER DATABASE [LabManager] SET  READ_WRITE 
GO
