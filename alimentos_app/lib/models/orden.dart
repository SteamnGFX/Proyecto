class Orden {
  final int id;
  final int mesaId;
  final int usuarioId;
  final String estatus;
  final DateTime fecha;

  Orden({required this.id, required this.mesaId, required this.usuarioId, required this.estatus, required this.fecha});

  factory Orden.fromJson(Map<String, dynamic> json) {
    return Orden(
      id: json['id'],
      mesaId: json['mesa_id'],
      usuarioId: json['usuario_id'],
      estatus: json['estatus'],
      fecha: DateTime.parse(json['fecha']),
    );
  }
}
