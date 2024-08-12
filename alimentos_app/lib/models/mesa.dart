class Mesa {
  int id;
  int numero;
  String estatus;
  String cliente;
  int comanda;
  int meseroId;
  int corredorId;

  Mesa({
    required this.id,
    required this.numero,
    required this.estatus,
    required this.cliente,
    required this.comanda,
    required this.meseroId,
    required this.corredorId,
  });

  factory Mesa.fromJson(Map<String, dynamic> json) {
    return Mesa(
      id: json['id'],
      numero: json['numero'],
      estatus: json['estatus'],
      cliente: json['cliente'],
      comanda: json['comanda'],
      meseroId: json['meseroId'],  // <--- Aquí el cambio
      corredorId: json['corredor_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'numero': numero,
      'estatus': estatus,
      'cliente': cliente,
      'comanda': comanda,
      'meseroId': meseroId,
      'corredor_id': corredorId,
    };
  }
}
