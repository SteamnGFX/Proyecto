import 'package:alimentos_app/widgets/menuLateral.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alimentos_app/models/pedido.dart';
import 'package:alimentos_app/services/pedidoService.dart';

class CajaScreen extends StatefulWidget {
  const CajaScreen({super.key});

  @override
  _CajaScreenState createState() => _CajaScreenState();
}

class _CajaScreenState extends State<CajaScreen> {
  List<Pedido> pedidos = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarPedidosListos();
  }

  void _cargarPedidosListos() async {
    final pedidoService = Provider.of<PedidoService>(context, listen: false);
    try {
      final responsePedidos = await pedidoService.getPedidosListos();
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

  IconData _getIconForEstado(String estado) {
    switch (estado) {
      case 'pendiente':
        return Icons.access_time;
      case 'listo':
        return Icons.check_circle_outline;
      case 'cobrar':
        return Icons.attach_money_outlined;
      default:
        return Icons.help_outline;
    }
  }

  Color _getColorForEstado(String estado) {
    switch (estado) {
      case 'pendiente':
        return Colors.orange;
      case 'listo':
        return Colors.teal;
      case 'cobrar':
        return Colors.deepOrange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'CAJA',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.purple,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      drawer: CustomDrawer(
        rol: 'Caja',
        currentScreen: 'Caja',
        onLogout: () {},
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: pedidos.length,
              itemBuilder: (context, index) {
                final pedido = pedidos[index];
                return GestureDetector(
                  onTap: () => _mostrarDetallesPedido(context, pedido),
                  child: Container(
                    margin: const EdgeInsets.all(8.0),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color:
                          _getColorForEstado(pedido.estatus).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(
                        color: _getColorForEstado(pedido.estatus),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getIconForEstado(pedido.estatus),
                          size: 40,
                          color: _getColorForEstado(pedido.estatus),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Mesa ${pedido.mesaId} - Comanda: ${pedido.comanda}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _getColorForEstado(pedido.estatus),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(child: Text('Estado: ${pedido.estatus}')),
                        Center(
                          child: Text(
                            'Productos: ${pedido.detalles.length}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _mostrarDetallesPedido(BuildContext context, Pedido pedido) {
    final total = pedido.detalles.fold<double>(
      0.0,
      (total, detalle) => total + (detalle.cantidad * detalle.productoPrecio),
    );

    final TextEditingController pagoController = TextEditingController();
    double cambio = 0;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Center(
                child: const Text('Cuenta'),
              ),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Text(
                        'Mesa ${pedido.mesaId} - Comanda: ${pedido.comanda}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 16.0),
                        child: Text(
                          "PRODUCTOS",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    ...pedido.detalles.map((detalle) => Text(
                        '➥ ${detalle.productoNombre}\nCantidad: ${detalle.cantidad}\nPrecio:${detalle.productoPrecio}\n')),
                    Padding(
                      padding: EdgeInsets.only(top: 16.0),
                      child: Text(
                        'Total: \$${total.toStringAsFixed(2)} MXN',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: pagoController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Monto pagado',
                      ),
                      onChanged: (value) {
                        setState(() {
                          double pago = double.tryParse(value) ?? 0;
                          cambio = pago - total;
                        });
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 16.0),
                      child: Text(
                        'Cambio: \$${cambio.toStringAsFixed(2)} MXN',
                        style: TextStyle(
                          color: cambio < 0 ? Colors.red : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cerrar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    double pago = double.tryParse(pagoController.text) ?? 0;
                    if (pago < total) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Error'),
                          content: const Text(
                              'El monto pagado es menor al total. Por favor ingrese una cantidad válida.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    } else {
                      _cobrarPedido(pedido.id);
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Cobrar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _cobrarPedido(int pedidoId) async {
    final pedidoService = Provider.of<PedidoService>(context, listen: false);
    try {
      final response = await pedidoService.cobrarPedido(pedidoId);
      if (response['message'] == 'Pedido cobrado') {
        _cargarPedidosListos();
      } else {
        throw Exception('Error al cobrar el pedido');
      }
    } catch (e) {
    }
  }
}
