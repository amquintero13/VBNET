Imports System.Xml
Imports System.Data.SqlClient
Imports System.IO

Module Module1
    'Variables de globales de clase
    Private _connectionString As String
    Private _logFile As String
    Private _errorLogFile As String

    Sub Main()

        'ObtenerDatos Archivo Config
        Dim xmlDoc As New XmlDocument()
        xmlDoc.Load("Config.xml")

        'Set variables Globales de clase
        _connectionString = xmlDoc.SelectSingleNode("/config/connectionString").InnerText
        _logFile = xmlDoc.SelectSingleNode("/config/logFile").InnerText
        _errorLogFile = xmlDoc.SelectSingleNode("/config/errorLogFile").InnerText

        'Guardar Usuarios
        Dim usuario1 As Usuario = New Usuario("Pedro", "Perez", 26, "pruebas@hotmail.com", "Nadar-Correr-Jugar fútbol-Cocinar")
        GuardarUsuario(usuario1)
        Dim usuario2 As Usuario = New Usuario("luisa", "rojas", 15, "pruebas2@hotmail.com", "Caminar-Baloncesto-Television-Musica")
        GuardarUsuario(usuario2)
        Dim usuario3 As Usuario = New Usuario("Rosa", "Aguirre", 38, "pruebas4@hotmail.com", "Dormir-Cocinar-Comer")
        GuardarUsuario(usuario3)


        'Lanzar procedmiento por edades
        ObtenerUsuariosPorEdad(12)
        ObtenerUsuariosPorEdad(30)

        'Lanzar procedimiento Por Horas
        ObtenerUsuariosUltimas2Horas()

    End Sub

    Private Sub GuardarUsuario(ByVal pUsuario As Usuario)
        Try
            Using connection As New SqlConnection(_connectionString)
                connection.Open()

                Dim sqlQuery As String = "sp_InsertarUsuario" & " '" & pUsuario.Nombre & "','" & pUsuario.Apellido & "'," & pUsuario.Edad & _
                ",'" & pUsuario.Correo & "','" & pUsuario.Hobbies & "','Admin'"
                Dim cmd1 As New SqlCommand(sqlQuery, connection)
                Dim reader1 As SqlDataReader = cmd1.ExecuteReader()

                While reader1.Read()
                    If String.IsNullOrEmpty(reader1.Item(0)) Then
                        EscribirLog("Usuario: " & pUsuario.ObtenerNombreCompleto())
                    Else
                        EscribirErrorLog(reader1.Item(0))
                    End If
                End While

                reader1.Close()
                connection.Close()
            End Using
        Catch ex As Exception
            EscribirErrorLog(ex.Message)
        End Try
    End Sub

    Private Sub ObtenerUsuariosPorEdad(ByVal pEdadMinima As Integer)
        Try
            Using connection As New SqlConnection(_connectionString)
                connection.Open()

                Dim sqlQuery As String = "sp_ObtenerUsuariosPorEdad" & " " & pEdadMinima
                Dim cmd1 As New SqlCommand(sqlQuery, connection)
                Dim reader1 As SqlDataReader = cmd1.ExecuteReader()

                While reader1.Read()
                    EscribirLog("Usuario: " & reader1("IdUsuario") & " - " & reader1("Nombre") & " - " & reader1("Apellido") & " - " & reader1("Edad") & _
                                " - " & reader1("Correo") & " - " & reader1("HobbiesOrdenados") & " - " & IIf(reader1("Activo") = 1, "SI", "NO") & " - " & reader1("FechaCreacion"))
                End While

                reader1.Close()
                connection.Close()
            End Using
        Catch ex As Exception
            EscribirErrorLog(ex.Message)
        End Try
    End Sub

    Private Sub ObtenerUsuariosUltimas2Horas()
        Try
            Using connection As New SqlConnection(_connectionString)
                connection.Open()

                Dim cmd1 As New SqlCommand("sp_ObtenerUsuariosUltimas2Horas", connection)
                Dim reader1 As SqlDataReader = cmd1.ExecuteReader()

                While reader1.Read()
                    EscribirLog("Usuario: " & reader1("IdUsuario") & " - " & reader1("Nombre") & " - " & reader1("Apellido") & " - " & reader1("Edad") & _
                                " - " & reader1("Correo") & " - " & reader1("HobbiesOrdenados") & " - " & IIf(reader1("Activo") = 1, "SI", "NO") & " - " & reader1("FechaCreacion"))
                End While

                reader1.Close()
                connection.Close()
            End Using
        Catch ex As Exception
            EscribirErrorLog(ex.Message)
        End Try
    End Sub

    Private Sub EscribirLog(ByVal pLinea As String)
        Try
            Using writer As New StreamWriter(_logFile, True)
                writer.WriteLine("Fecha:" & Now & " - " & pLinea)
            End Using
        Catch ex As Exception
            EscribirErrorLog(ex.Message)
        End Try
    End Sub

    Private Sub EscribirErrorLog(ByVal pLineaError As String)
        Try
            Using writer As New StreamWriter(_errorLogFile, True)
                writer.WriteLine("Fecha:" & Now & " - " & pLineaError)
            End Using
        Catch ex As Exception
            Console.WriteLine(ex.Message)
        End Try
    End Sub

End Module
