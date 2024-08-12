class DetallePedido {
  int id;
  int pedidoId;
  int productoId;
  int cantidad;
  String productoNombre;
  double productoPrecio;

  DetallePedido({
    required this.id,
    required this.pedidoId,
    required this.productoId,
    required this.cantidad,
    required this.productoNombre,
    required this.productoPrecio,
  });

  factory DetallePedido.fromJson(Map<String, dynamic> json) {
    return DetallePedido(
      id: json['id'],
      pedidoId: json['pedido_id'],
      productoId: json['producto_id'],
      cantidad: json['cantidad'],
      productoNombre: json['producto_nombre'] ?? '',
      productoPrecio: json['producto_precio'] ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pedido_id': pedidoId,
      'producto_id': productoId,
      'cantidad': cantidad,
      'producto_nombre': productoNombre,
      'producto_precio': productoPrecio,
    };
  }

  @override
  String toString() {
    return 'DetallePedido(id: $id, pedidoId: $pedidoId, productoId: $productoId, cantidad: $cantidad, productoNombre: $productoNombre, productoPrecio: $productoPrecio)';
  }
}
