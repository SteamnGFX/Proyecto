class Usuario {
  String id;
  int usuarioId;
  String nombre;
  String email;
  String password;
  String rol;

  Usuario({
    required this.id,
    required this.nombre,
    required this.email,
    required this.password,
    required this.rol,
    required this.usuarioId,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      rol: json['rol'] ?? '',
      usuarioId: json['usuario_id'] ?? 0,

    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'email': email,
      'password': password,
      'rol': rol,
      'usuario_id': usuarioId,
    };
  }
}
