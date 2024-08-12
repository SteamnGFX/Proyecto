import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alimentos_app/models/detallePedido.dart';
import 'package:alimentos_app/services/productoService.dart';
import 'package:alimentos_app/models/producto.dart';
import 'package:alimentos_app/services/mesaService.dart';
import 'package:alimentos_app/services/pedidoService.dart';
import 'package:alimentos_app/models/pedido.dart';
import 'dart:convert';
import 'package:collection/collection.dart';

class RealizarPedidoScreen extends StatefulWidget {
  final int mesaId;
  final int meseroId;
  final String estatusMesa;
  final String cliente;
  final int comanda;

  const RealizarPedidoScreen({
    super.key,
    required this.mesaId,
    required this.meseroId,
    required this.estatusMesa,
    required this.cliente,
    required this.comanda,
  });

  @override
  _RealizarPedidoScreenState createState() => _RealizarPedidoScreenState();
}

class _RealizarPedidoScreenState extends State<RealizarPedidoScreen> {
  List<Producto> productos = [];
  List<DetallePedido> pedidoDetalles = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarProductosYPedido();
  }

  void _cargarProductosYPedido() async {
    final productoService =
        Provider.of<ProductoService>(context, listen: false);
    try {
      final responseProductos = await productoService.getProductos();
      setState(() {
        productos = responseProductos;
        pedidoDetalles = [];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _agregarDetalle(int productoId) {
    setState(() {
      final detalleExistente = pedidoDetalles.firstWhereOrNull(
        (detalle) => detalle.productoId == productoId,
      );

      if (detalleExistente != null) {
        detalleExistente.cantidad += 1;
      } else {
        final producto =
            productos.firstWhere((producto) => producto.id == productoId);
        final detalle = DetallePedido(
          id: 0,
          pedidoId: 0,
          productoId: productoId,
          cantidad: 1,
          productoNombre: producto.nombre,
          productoPrecio: producto.precio,
        );
        pedidoDetalles.add(detalle);
      }

    });
  }

  void _eliminarDetalle(int productoId) {
    setState(() {
      pedidoDetalles.removeWhere((detalle) => detalle.productoId == productoId);
    });
  }

  void _enviarPedido() async {
    final apiService = Provider.of<PedidoService>(context, listen: false);

    final pedido = Pedido(
      id: 0,
      mesaId: widget.mesaId,
      usuarioId: widget.meseroId,
      estatus: 'pendiente',
      fecha: DateTime.now(),
      cliente: widget.cliente,
      comanda: widget.comanda,
      detalles: pedidoDetalles,
    );

    try {
      final response = await apiService.createPedido(pedido);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final pedidoId = responseData['pedido_id'];

        setState(() {
          for (var detalle in pedidoDetalles) {
            detalle.pedidoId = pedidoId;
          }
        });

        await _actualizarEstadoMesa(widget.mesaId, 'pedido');

        setState(() {
          isLoading = false;
        });

        Navigator.pop(context, true);
      } else {
        _showErrorDialog(
            context, 'Error al enviar el pedido: ${response.body}');
      }
    } catch (e) {
      _showErrorDialog(context, 'Hubo un error al enviar el pedido: $e');
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _actualizarEstadoMesa(int mesaId, String nuevoEstado) async {
    final mesaService = Provider.of<MesaService>(context, listen: false);
    try {
      await mesaService.updateMesaStatus(mesaId, nuevoEstado);
    } catch (e) {
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
            color: Colors.white), 
        title: const Text(
          'REALIZAR PEDIDO',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.purple,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'MENÚ',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: productos.length,
                          itemBuilder: (context, index) {
                            final producto = productos[index];
                            return Card(
                              elevation: 4,
                              margin: const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 8),
                              child: ListTile(
                                title: Text(producto.nombre),
                                subtitle: Text(
                                    '${producto.descripcion} - \$${producto.precio}'),
                                onTap: () => _agregarDetalle(producto.id),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const VerticalDivider(width: 1, color: Colors.grey),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'PRODUCTOS DEL PEDIDO',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: pedidoDetalles.length,
                          itemBuilder: (context, index) {
                            final detalle = pedidoDetalles[index];
                            return Card(
                              elevation: 4,
                              margin: const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 8),
                              child: ListTile(
                                title: Text(detalle.productoNombre),
                                subtitle: Text('Cantidad: ${detalle.cantidad}'),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () =>
                                      _eliminarDetalle(detalle.productoId),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              isLoading = true;
                            });
                            _enviarPedido();
                          },
                          icon: const Icon(Icons.send),
                          label: const Text('Enviar Pedido'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 24),
                            textStyle: const TextStyle(fontSize: 18),
                            minimumSize: const Size.fromHeight(
                                50), 
                            foregroundColor: Colors
                                .white, 
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
