import 'package:alimentos_app/widgets/menuLateral.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alimentos_app/services/mesaService.dart';
import 'package:alimentos_app/models/mesa.dart';

class HostScreen extends StatefulWidget {
  const HostScreen({super.key});

  @override
  _HostScreenState createState() => _HostScreenState();
}

class _HostScreenState extends State<HostScreen> {
  List<Mesa> mesas = [];
  final TextEditingController _clienteController = TextEditingController();
  final TextEditingController _comandaController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarMesas();
  }

  void _cargarMesas() async {
    final apiService = Provider.of<MesaService>(context, listen: false);
    try {
      final response = await apiService.getMesas();
      setState(() {
        mesas = response;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _asignarMesa(BuildContext context, Mesa mesa) {
    if (mesa.estatus == 'comiendo' || mesa.estatus == 'limpieza' || mesa.estatus == 'cobrar') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se puede asignar la mesa ${mesa.numero} en este momento.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: Center(
            child: const Text(
              'ASIGNAR UNA MESA',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontSize: 20,
              ),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _clienteController,
                decoration: InputDecoration(
                  labelText: 'Nombre del Cliente',
                  labelStyle: TextStyle(
                    color: Colors.purple,
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.purple),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _comandaController,
                decoration: InputDecoration(
                  labelText: 'Número de Comanda',
                  labelStyle: TextStyle(
                    color: Colors.purple,
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.purple),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  mesa.estatus = 'asignada';
                  mesa.cliente = _clienteController.text;
                  mesa.comanda = int.parse(_comandaController.text);
                });
                final apiService = Provider.of<MesaService>(context, listen: false);
                apiService.updateMesa(mesa.id, mesa.estatus, mesa.cliente, mesa.numero, mesa.comanda).then((_) {
                  _clienteController.clear();
                  _comandaController.clear();

                  _cargarMesas();
                  Navigator.pop(context);
                }).catchError((e) {
                  Navigator.pop(context);
                });
              },
              child: const Text(
                'Asignar',
                style: TextStyle(
                  color: Colors.purple,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _desasignarMesa(BuildContext context, Mesa mesa) {
    final apiService = Provider.of<MesaService>(context, listen: false);
    setState(() {
      mesa.estatus = 'libre';
      mesa.cliente = '';
      mesa.comanda = 0;
    });
    apiService.updateMesa(mesa.id, mesa.estatus, mesa.cliente, mesa.numero, mesa.comanda).then((_) {
      _cargarMesas(); 
    }).catchError((e) {
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'HOST',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.purple,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white, 
        ),
      ),
      drawer: CustomDrawer(
        rol: 'Host',
        currentScreen: 'Host',
        onLogout: () {
        },
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              color: Colors.white,
              child: GridView.builder(
                padding: const EdgeInsets.all(8.0),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                ),
                itemCount: mesas.length,
                itemBuilder: (context, index) {
                  final mesa = mesas[index];
                  return GestureDetector(
                    onTap: () => _asignarMesa(context, mesa),
                    onLongPress: () => _desasignarMesa(context, mesa),
                    child: Container(
                      margin: const EdgeInsets.all(8.0),
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: _getColorForStatus(mesa.estatus).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(
                          color: _getColorForStatus(mesa.estatus),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _getIconForStatus(mesa.estatus),
                          const SizedBox(height: 10),
                          Text(
                            'Mesa ${mesa.numero}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _getColorForStatus(mesa.estatus),
                            ),
                          ),
                          if (mesa.estatus != 'libre') ...[
                            const SizedBox(height: 8),
                            Text('Comanda: ${mesa.comanda}', style: const TextStyle(fontSize: 16)),
                            if (mesa.cliente.isNotEmpty)
                              Text('Cliente: ${mesa.cliente}', style: const TextStyle(fontSize: 16)),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  Color _getColorForStatus(String estatus) {
    switch (estatus) {
      case 'libre':
        return Colors.green;
      case 'asignada':
        return Colors.yellow[700]!;
      case 'pedido':
        return Colors.orange;
      case 'comiendo':
        return Colors.blue;
      case 'preparando':
        return Colors.purple;
      case 'listo':
        return Colors.teal;
      case 'limpieza':
        return Colors.red;
      case 'cobrar':
        return Colors.deepOrange;
      default:
        return Colors.grey;
    }
  }

  Widget _getIconForStatus(String estatus) {
    switch (estatus) {
      case 'libre':
        return const Icon(Icons.event_seat_outlined, size: 40, color: Colors.green);
      case 'asignada':
        return const Icon(Icons.person_outline, size: 40, color: Colors.yellow);
      case 'pedido':
        return const Icon(Icons.restaurant_menu, size: 40, color: Colors.orange);
      case 'comiendo':
        return const Icon(Icons.local_dining, size: 40, color: Colors.blue);
      case 'preparando':
        return const Icon(Icons.kitchen, size: 40, color: Colors.purple);
      case 'listo':
        return const Icon(Icons.check_circle_outline, size: 40, color: Colors.teal);
      case 'limpieza':
        return const Icon(Icons.cleaning_services_outlined, size: 40, color: Colors.red);
      case 'cobrar':
        return const Icon(Icons.attach_money_outlined, size: 40, color: Colors.deepOrange); 
      default:
        return const Icon(Icons.help_outline, size: 40, color: Colors.grey);
    }
  }
}
