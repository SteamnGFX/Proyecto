import 'package:intl/intl.dart';
import 'detallePedido.dart';

class Pedido {
  int id;
  int mesaId;
  int usuarioId;
  String estatus;
  DateTime fecha;
  String cliente;
  int comanda;
  List<DetallePedido> detalles;

  Pedido({
    required this.id,
    required this.mesaId,
    required this.usuarioId,
    required this.estatus,
    required this.fecha,
    required this.cliente,
    required this.comanda,
    required this.detalles,
  });

  factory Pedido.fromJson(Map<String, dynamic> json) {
  return Pedido(
    id: getSafeInt(json['pedido_id']),
    mesaId: getSafeInt(json['mesa_id']),
    usuarioId: getSafeInt(json['usuario_id']),
    estatus: json['estatus'] ?? 'pendiente',
    fecha: DateTime.parse(json['fecha']),
    cliente: json['cliente'] ?? 'Desconocido',
    comanda: getSafeInt(json['comanda']),
    detalles: (json['detalles'] as List)
        .map((detalle) => DetallePedido.fromJson(detalle))
        .toList(),
  );
}


  Map<String, dynamic> toJson() {
    return {
      'pedido_id': id,
      'mesa_id': mesaId,
      'usuario_id': usuarioId,
      'estatus': estatus,
      'fecha': fecha.toIso8601String(),
      'cliente': cliente,
      'comanda': comanda,
      'detalles': detalles.map((detalle) => detalle.toJson()).toList(),
    };
  }

  static int getSafeInt(dynamic value) {
    if (value == null) return 0;
    return value is int ? value : int.tryParse(value.toString()) ?? 0;
  }

  static DateTime parseRFC1123Date(String dateString) {
    return DateFormat('EEE, dd MMM yyyy HH:mm:ss Z', 'en_US').parse(dateString);
  }
  
  @override
  String toString() {
    return 'Pedido(id: $id, mesaId: $mesaId, usuarioId: $usuarioId, estatus: $estatus, fecha: $fecha, cliente: $cliente, comanda: $comanda, detalles: $detalles)';
  }
}
