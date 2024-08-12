import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:alimentos_app/models/mesa.dart';

class MesaService {
  final String apiUrl = "http://192.168.1.178:5002";

  Future<List<Mesa>> getMesas() async {
    final response = await http.get(Uri.parse('$apiUrl/mesas'));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => Mesa.fromJson(item)).toList();
    } else {
      throw Exception('Error al cargar las mesas');
    }
  }

  Future<void> updateMesa(int id, String estatus, String cliente, int numero, int comanda) async {
    final response = await http.put(
      Uri.parse('$apiUrl/mesas/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'estatus': estatus,
        'cliente': cliente,
        'numero': numero,
        'comanda': comanda
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Error al actualizar la mesa');
    }
  }

  Future<void> updateMesaStatus(int id, String nuevoEstado) async {
    final response = await http.put(
      Uri.parse('$apiUrl/mesas/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'estatus': nuevoEstado,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Error al actualizar el estado de la mesa');
    }
  }
  Future<Map<String, dynamic>> entregarComida(int mesaId) async {
    final response = await http.put(
      Uri.parse('$apiUrl/entregar_comida/$mesaId'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al entregar comida');
    }
  }
  Future<Map<String, dynamic>> pedirCuenta(int mesaId) async {
    final response = await http.put(
      Uri.parse('$apiUrl/pedircuenta/$mesaId'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al entregar comida');
    }
  }
  Future<Map<String, dynamic>> limpiarMesa(int mesaId) async {
    final response = await http.put(
      Uri.parse('$apiUrl/limpiar/$mesaId'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al limpiar');
    }
  }
}
