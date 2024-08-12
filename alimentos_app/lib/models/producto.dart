class Producto {
  int id;
  String nombre;
  String descripcion;
  double precio;
  String categoria;

  Producto({required this.id, required this.nombre, required this.descripcion, required this.precio, required this.categoria});

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['producto_id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      precio: json['precio'],
      categoria: json['categoria'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'categoria': categoria,
    };
  }
}
