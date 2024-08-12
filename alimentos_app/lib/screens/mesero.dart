import 'package:alimentos_app/widgets/menuLateral.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alimentos_app/models/mesa.dart';
import 'package:alimentos_app/widgets/mesaPedido.dart';
import 'package:alimentos_app/services/mesaService.dart';
import 'package:alimentos_app/screens/realizarPedido.dart';

class MeseroScreen extends StatefulWidget {
  final int meseroId;
  const MeseroScreen({super.key, required this.meseroId});

  @override
  MeseroState createState() => MeseroState();
}

class MeseroState extends State<MeseroScreen> {
  List<Mesa> mesas = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getMesas();
  }

  void getMesas() async {
    final apiService = Provider.of<MesaService>(context, listen: false);
    try {
      final response = await apiService.getMesas();
      setState(() {
        mesas = response.where((mesa) => mesa.meseroId == widget.meseroId).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> pantallaRealizarPedido(int mesaId, String estatusMesa, String cliente, int comanda) async {
    if (estatusMesa == 'limpieza' || estatusMesa == 'cobrar') {
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RealizarPedidoScreen(
          mesaId: mesaId,
          meseroId: widget.meseroId,
          estatusMesa: estatusMesa,
          cliente: cliente,
          comanda: comanda,
        ),
      ),
    );

    if (result == true) {
      getMesas();
    }
  }

  void marcarEntregadoPedido(int mesaId) async {
    final apiService = Provider.of<MesaService>(context, listen: false);
    try {
      final response = await apiService.entregarComida(mesaId);
      if (response['message'] == 'Mesa actualizada a comiendo') {
        getMesas();
      } else {
        throw Exception('Error al entregar comida');
      }
    } catch (e) {
    }
  }

  void pedirCuentaMesa(int mesaId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar'),
          content: Text('¿Estás seguro de cerrar la cuenta de la mesa $mesaId?'),
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
      final apiService = Provider.of<MesaService>(context, listen: false);
      try {
        final response = await apiService.pedirCuenta(mesaId);
        if (response['message'] == 'Mesa actualizada a limpieza' || response['message'] == 'Mesa actualizada a cobrar') {
          getMesas();
        } else {
          throw Exception('Error al actualizar la mesa a limpieza');
        }
      } catch (e) {
      }
    }
  }

  void cobrarCuentaMesa(int mesaId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar'),
          content: Text('¿Estás seguro de cobrar la mesa $mesaId?'),
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
      getMesas();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MESAS',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.purple,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white, 
        ),
      ),
      drawer: CustomDrawer(
        rol: 'Mesero',
        currentScreen: 'Mesero',
        onLogout: () {},
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: mesas.length,
              itemBuilder: (context, index) {
                final mesa = mesas[index];
                return MesaConPedidoWidget(
                  numeroMesa: mesa.numero,
                  estado: mesa.estatus,
                  cliente: mesa.cliente,
                  comanda: mesa.comanda,
                  onTap: () {
                    if (mesa.estatus != 'libre' && mesa.estatus != 'limpieza' && mesa.estatus != 'cobrar') {
                      pantallaRealizarPedido(mesa.id, mesa.estatus, mesa.cliente, mesa.comanda);
                    }
                  },
                  onPedido: () {
                    if (mesa.estatus != 'libre' && mesa.estatus != 'limpieza' && mesa.estatus != 'cobrar') {
                      pantallaRealizarPedido(mesa.id, mesa.estatus, mesa.cliente, mesa.comanda);
                    }
                  },
                  onDesasignar: () {},
                  onEntregar: (int mesaId) {
                    if (mesa.estatus == 'listo') {
                      marcarEntregadoPedido(mesaId);
                    }
                  },
                  onPedirCuenta: (int mesaId) {
                    if (mesa.estatus == 'comiendo') {
                      pedirCuentaMesa(mesaId);
                    }
                  },
                );
              },
            ),
    );
  }
}
