import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:alimentos_app/models/producto.dart';

class ProductoService {
  final String apiUrl = 'http://127.0.0.1:5002/api';

  Future<List<Producto>> getProductos() async {
    final response = await http.get(Uri.parse('$apiUrl/productos'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      List<Producto> productos = body.map((dynamic item) => Producto.fromJson(item)).toList();
      return productos;
    } else {
      throw Exception('Failed to load productos');
    }
  }

  Future<Producto> getProductoById(int id) async {
    final response = await http.get(Uri.parse('$apiUrl/productos/$id'));

    if (response.statusCode == 200) {
      return Producto.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load producto');
    }
  }
}
