/****** Object:  Table [dbo].[Usuarios]    Script Date: 31/08/2024 18:02:58 ******/
--Creación de tabla Usuarios

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Usuarios]') AND type in (N'U'))
BEGIN
	CREATE TABLE [dbo].[Usuarios](
		[IdUsuario] [int] IDENTITY(1,1) NOT NULL,
		[Nombre] [varchar](50) NOT NULL,
		[Apellido] [varchar](50) NOT NULL,
		[Edad] [int] NULL,
		[Correo] [varchar](100) NULL,
		[Hobbies] [varchar](255) NULL,
		[Activo] [tinyint] NULL,
		[FechaCreacion] [datetime] NULL,
		[UsuarioCreacion] [varchar](50) NULL,
		[FechaModificacion] [datetime] NULL,
		[UsuarioModificacion] [varchar](50) NULL,
	PRIMARY KEY CLUSTERED 
	(
		[IdUsuario] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	) ON [PRIMARY]

	ALTER TABLE [dbo].[Usuarios] ADD  DEFAULT ((1)) FOR [Activo]

	ALTER TABLE [dbo].[Usuarios] ADD  DEFAULT (getdate()) FOR [FechaCreacion]

	CREATE INDEX IX_Usuarios_Edad ON Usuarios (Edad);
END
GO





/****** Object:  Trigger [TR_Usuarios_Update]    Script Date: 31/08/2024 18:13:42 ******/
IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[TR_Usuarios_Update]'))
DROP TRIGGER [dbo].[TR_Usuarios_Update]
GO

/****** Object:  Trigger [dbo].[TR_Usuarios_Update]    Script Date: 31/08/2024 18:13:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- Trigger para actualizar los campos de auditoria al modificar un usuario

CREATE TRIGGER [dbo].[TR_Usuarios_Update]
ON [dbo].[Usuarios]
AFTER UPDATE
AS
BEGIN
    UPDATE Usuarios
    SET FechaModificacion = GETDATE(),
        UsuarioModificacion = SYSTEM_USER
    FROM Usuarios u
    INNER JOIN inserted i ON u.IdUsuario = i.IdUsuario;
END;
GO

ALTER TABLE [dbo].[Usuarios] ENABLE TRIGGER [TR_Usuarios_Update]
GO






/****** Object:  StoredProcedure [dbo].[sp_InsertarUsuario]    Script Date: 31/08/2024 18:18:26 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_InsertarUsuario]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[sp_InsertarUsuario]
GO

/****** Object:  StoredProcedure [dbo].[sp_InsertarUsuario]    Script Date: 31/08/2024 18:18:26 ******/

-- PA para agregar o modificar un usuario
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_InsertarUsuario]
    @Nombre VARCHAR(50),
    @Apellido VARCHAR(50),
    @Edad INT,
    @Correo VARCHAR(100),
    @Hobbies VARCHAR(255),
    @UsuarioCreacion VARCHAR(50) =''
AS
BEGIN
	BEGIN TRY
		IF NOT EXISTS(SELECT IdUsuario FROM Usuarios WHERE Nombre = @Nombre AND Apellido = @Apellido AND Edad = @Edad)
		BEGIN
			INSERT INTO Usuarios (
				Nombre,
				Apellido,
				Edad,
				Correo,
				Hobbies,
				UsuarioCreacion
			)
			VALUES (
				@Nombre,
				@Apellido,
				@Edad,
				@Correo,
				@Hobbies,
				@UsuarioCreacion
			);
		END
		ELSE
		BEGIN
			UPDATE Usuarios SET Correo = @Correo, Hobbies = @Hobbies
		END

	    SELECT ''

	END TRY

	BEGIN CATCH
		SELECT ERROR_MESSAGE()
	END CATCH
END;
GO







/****** Object:  UserDefinedFunction [dbo].[fn_OrdenarPalabrasConComas]    Script Date: 31/08/2024 18:32:20 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fn_OrdenarPalabrasConComas]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[fn_OrdenarPalabrasConComas]
GO

/****** Object:  UserDefinedFunction [dbo].[fn_OrdenarPalabrasConComas]    Script Date: 31/08/2024 18:32:20 ******/
-- Función que ordena las palabras de una cadena alfabeticamente y separadas por comas
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fn_OrdenarPalabrasConComas] (
    @cadena NVARCHAR(MAX)
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
    DECLARE @tabla TABLE (palabra NVARCHAR(MAX))
    DECLARE @palabra NVARCHAR(MAX)
    DECLARE @indice INT = 1
    DECLARE @longitud INT = LEN(@cadena)

    WHILE @indice <= @longitud
    BEGIN
        SET @palabra = SUBSTRING(@cadena, @indice, 
                    CHARINDEX('-', @cadena + '-', @indice) - @indice)
        INSERT INTO @tabla(palabra) VALUES (@palabra)
        SET @indice = CHARINDEX('-', @cadena + '-', @indice) + 1
    END

    DECLARE @resultado NVARCHAR(MAX) = ''
    
    SELECT @resultado = @resultado + CASE WHEN @resultado = '' THEN '' ELSE ',' END + palabra
    FROM @tabla
    ORDER BY palabra

    RETURN @resultado
END
GO





/****** Object:  StoredProcedure [dbo].[sp_ObtenerUsuariosPorEdad]    Script Date: 31/08/2024 18:46:52 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_ObtenerUsuariosPorEdad]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[sp_ObtenerUsuariosPorEdad]
GO

/****** Object:  StoredProcedure [dbo].[sp_ObtenerUsuariosPorEdad]    Script Date: 31/08/2024 18:46:52 ******/
-- PA para obetner los usuarios iguales o mayores a una edad dada como parametro
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_ObtenerUsuariosPorEdad] @edadMinima INT
AS
BEGIN
    SELECT 
        u.IdUsuario,
        u.Nombre,
        u.Apellido,
        u.Edad,
		u.Correo,
        dbo.fn_OrdenarPalabrasConComas(u.Hobbies) AS HobbiesOrdenados,
		U.Activo,
		U.FechaCreacion
    FROM
        Usuarios u
    WHERE
        u.Edad >= @edadMinima;
END;
GO





/****** Object:  StoredProcedure [dbo].[sp_ObtenerUsuariosUltimas2Horas]    Script Date: 31/08/2024 18:50:36 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_ObtenerUsuariosUltimas2Horas]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[sp_ObtenerUsuariosUltimas2Horas]
GO

/****** Object:  StoredProcedure [dbo].[sp_ObtenerUsuariosUltimas2Horas]    Script Date: 31/08/2024 18:50:36 ******/
-- PA para obtener los usuarios creados en als ultimas 2 horas
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_ObtenerUsuariosUltimas2Horas]
AS
BEGIN
    SELECT 
        U.IdUsuario,
        U.Nombre,
        U.Apellido,
        U.Edad,
        U.Correo,
        dbo.fn_OrdenarPalabrasConComas(u.Hobbies) AS HobbiesOrdenados,
        U.Activo,
        U.FechaCreacion
    FROM 
        Usuarios U
    WHERE 
        U.FechaCreacion >= DATEADD(HOUR, -2, GETDATE());
END;
GO


