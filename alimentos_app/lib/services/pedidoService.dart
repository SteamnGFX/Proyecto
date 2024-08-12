import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:alimentos_app/models/pedido.dart';

class PedidoService {
  final String apiUrl = 'http://192.168.1.178:5002';

  Future<http.Response> createPedido(Pedido pedido) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/pedidos'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(pedido.toJson()),
      );

      if (response.statusCode != 200) {
        throw Exception('Error al crear pedido: ${response.body}');
      }
      
      return response;
    } catch (e) {
      rethrow;
    }
  }



  Future<void> updatePedido(Pedido pedido) async {
    try {
      final response = await http.put(
        Uri.parse('$apiUrl/pedidos/${pedido.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(pedido.toJson()),
      );

      if (response.statusCode != 200) {
        throw Exception('Error al actualizar pedido: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Pedido?> getPedidoByMesaId(int mesaId) async {
    try {
      final response =
          await http.get(Uri.parse('$apiUrl/pedidos?mesa_id=$mesaId'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          return Pedido.fromJson(data.last);
        }
      } else {
        throw Exception('Error al obtener pedido: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  Future<List<Pedido>> getPedidosPendientes() async {
    final response = await http.get(Uri.parse('$apiUrl/cocina'));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => Pedido.fromJson(item)).toList();
    } else {
      throw Exception('Error al cargar los pedidos pendientes');
    }
  }

  Future<void> actualizarEstatusMesa(int mesaId, String nuevoEstatus) async {
    final response = await http.put(
      Uri.parse('$apiUrl/mesas/$mesaId/estatus'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'estatus': nuevoEstatus}),
    );
    if (response.statusCode != 200) {
      throw Exception('Error al actualizar el estatus de la mesa');
    }
  }

  Future<void> actualizarEstatusPedido(
      int pedidoId, String nuevoEstatus) async {
    final response = await http.put(
      Uri.parse('$apiUrl/cocina/$pedidoId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'estatus': nuevoEstatus}),
    );
    if (response.statusCode != 200) {
      throw Exception('Error al actualizar el estatus del pedido');
    }
  }

  Future<List<Pedido>> getPedidosListos() async {
  final response = await http.get(Uri.parse('$apiUrl/pedidos/listos'));
  if (response.statusCode == 200) {
    List<dynamic> data = jsonDecode(response.body);
    Map<int, Pedido> pedidosAgrupados = {};

    for (var item in data) {
      Pedido pedido = Pedido.fromJson(item);
      if (pedidosAgrupados.containsKey(pedido.mesaId)) {
        pedidosAgrupados[pedido.mesaId]!.detalles.addAll(pedido.detalles);
      } else {
        pedidosAgrupados[pedido.mesaId] = pedido;
      }
    }

    return pedidosAgrupados.values.toList();
  } else {
    throw Exception('Error al cargar los pedidos listos');
  }
}


  Future<Map<String, dynamic>> cobrarPedido(int pedidoId) async {
    final response = await http.put(
      Uri.parse('$apiUrl/cobrar_pedido/$pedidoId'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al cobrar el pedido');
    }
  }
}
