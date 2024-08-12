import 'package:alimentos_app/widgets/menuLateral.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alimentos_app/models/pedido.dart';
import 'package:alimentos_app/services/pedidoService.dart';

class CocinaScreen extends StatefulWidget {
  const CocinaScreen({super.key});

  @override
  _CocinaScreenState createState() => _CocinaScreenState();
}

class _CocinaScreenState extends State<CocinaScreen> {
  List<Pedido> pedidos = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarPedidos();
  }

  void _cargarPedidos() async {
    final pedidoService = Provider.of<PedidoService>(context, listen: false);
    try {
      final responsePedidos = await pedidoService.getPedidosPendientes();
      setState(() {
        pedidos = responsePedidos;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _confirmarPrepararPedido(Pedido pedido) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar'),
          content: Text(
              '¿Estás seguro de preparar el pedido de la mesa ${pedido.mesaId} con comanda ${pedido.comanda}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      _actualizarEstatusPedido(pedido.id, 'preparando');
    }
  }

  Future<void> _confirmarListoPedido(Pedido pedido) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar'),
          content: Text(
              '¿Estás seguro de confirmar como listo el pedido de la mesa ${pedido.mesaId} con comanda ${pedido.comanda}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      _actualizarEstatusPedido(pedido.id, 'listo');
    }
  }

  void _actualizarEstatusPedido(int pedidoId, String nuevoEstatus) async {
    final pedidoService = Provider.of<PedidoService>(context, listen: false);
    try {
      await pedidoService.actualizarEstatusPedido(pedidoId, nuevoEstatus);
      _cargarPedidos(); 
    } catch (e) {
    }
  }

  IconData _getIconForEstado(String estado) {
    switch (estado) {
      case 'pendiente':
        return Icons.access_time;
      case 'preparando':
        return Icons.kitchen;
      case 'listo':
        return Icons.check_circle_outline;
      default:
        return Icons.help_outline;
    }
  }

  Color _getColorForEstado(String estado) {
    switch (estado) {
      case 'pendiente':
        return Colors.orange;
      case 'preparando':
        return Colors.purple;
      case 'listo':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'COCINA',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.purple,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white, 
        ),
      ),
      drawer: CustomDrawer(
        rol: 'Cocina',
        currentScreen: 'Cocina',
        onLogout: () {},
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : pedidos.isEmpty
              ? const Center(
                  child: Text(
                    'Enhorabuena, no hay pedidos pendientes',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: pedidos.length,
                  itemBuilder: (context, index) {
                    final pedido = pedidos[index];

                    return Card(
                      color: Color(0xFFEDE7F6), 
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: BorderSide(
                          color: Colors.purple,
                          width: 2,
                        ),
                      ),
                      elevation: 3,
                      margin: const EdgeInsets.all(8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _getIconForEstado(pedido.estatus),
                                  size: 30,
                                  color: _getColorForEstado(pedido.estatus),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Mesa ${pedido.mesaId} - Comanda ${pedido.comanda}',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Divider(
                              color: Colors.purple.withOpacity(0.3),
                            ),
                            const Text('PRODUCTOS',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            ...pedido.detalles.map((detalle) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Text(
                                    '• ${detalle.productoNombre} (x${detalle.cantidad})',
                                    style: const TextStyle(fontSize: 16)),
                              );
                            }),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                if (pedido.estatus == 'pendiente')
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () =>
                                          _confirmarPrepararPedido(pedido),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.purple,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 14),
                                      ),
                                      child: const Text(
                                        'Preparar',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 18),
                                      ),
                                    ),
                                  ),
                                const SizedBox(width: 8),
                                if (pedido.estatus == 'preparando')
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () =>
                                          _confirmarListoPedido(pedido),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 14),
                                      ),
                                      child: const Text(
                                        'Listo',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 18),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
