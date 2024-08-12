import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:alimentos_app/models/usuario.dart';

class UsuarioService {
  final String apiUrl = 'http://127.0.0.1:5002/api/usuarios';

  Future<List<Usuario>> obtenerUsuarios() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) {
          return Usuario.fromJson({
            'id': json['id'] ?? '',
            'nombre': json['nombre'] ?? '',
            'email': json['email'] ?? '',
            'password': json['password'] ?? '',
            'rol': json['rol'] ?? '',
          });
        }).toList();
      } else {
        throw Exception('Error al obtener usuarios');
      }
    } catch (e) {
      throw Exception('Error al obtener usuarios');
    }
  }

  Future<void> eliminarUsuario(String usuarioId) async {
    final response = await http.delete(Uri.parse('$apiUrl/$usuarioId'));

    if (response.statusCode != 200) {
      throw Exception('Error al eliminar usuario');
    }
  }

  Future<void> crearUsuario(Usuario usuario) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nombre': usuario.nombre,
        'email': usuario.email,
        'password': usuario.password,
        'rol': usuario.rol,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['message'] == 'Usuario creado') {
        usuario.usuarioId = data['usuario_id'];
        return;
      } else {
        throw Exception('Error al crear usuario');
      }
    } else {
      throw Exception('Error al crear usuario');
    }
  }
}
