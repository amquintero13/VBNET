Public Class Usuario
    'Propiedades
    Private _nombre As String
    Private _apellido As String
    Private _edad As Integer
    Private _correo As String
    Private _hobbies As String

    Public Property Nombre() As String
        Get
            Return _nombre
        End Get
        Set(ByVal value As String)
            _nombre = value
        End Set
    End Property

    Public Property Apellido() As String
        Get
            Return _apellido
        End Get
        Set(ByVal value As String)
            _apellido = value
        End Set
    End Property

    Public Property Edad() As Integer
        Get
            Return _edad
        End Get
        Set(ByVal value As Integer)
            _edad = value
        End Set
    End Property

    Public Property Correo() As String
        Get
            Return _correo
        End Get
        Set(ByVal value As String)
            _correo = value
        End Set
    End Property

    Public Property Hobbies() As String
        Get
            Return _hobbies
        End Get
        Set(ByVal value As String)
            _hobbies = value
        End Set
    End Property

    'Constuctor de clase
    Public Sub New(ByVal nombre As String, ByVal apellido As String, ByVal edad As Integer, ByVal correo As String, ByVal hobbies As String)
        _nombre = nombre
        _apellido = apellido
        _edad = edad
        _correo = correo
        _hobbies = hobbies
    End Sub

    Public Function ObtenerNombreCompleto() As String
        Return _nombre & " " & _apellido
    End Function
End Class
