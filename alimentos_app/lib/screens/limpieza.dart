import 'package:alimentos_app/widgets/menuLateral.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alimentos_app/models/mesa.dart';
import 'package:alimentos_app/services/mesaService.dart';

class LimpiadorScreen extends StatefulWidget {
  final int corredorId;
  const LimpiadorScreen({super.key, required this.corredorId});

  @override
  LimpiadorState createState() => LimpiadorState();
}

class LimpiadorState extends State<LimpiadorScreen> {
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
        mesas = response.where((mesa) => mesa.estatus == 'limpieza').toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void establecerLimpieza(int mesaId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Limpieza'),
          content: const Text(
              '¿Está seguro de que ha terminado de limpiar la mesa?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Sí'),
              onPressed: () {
                Navigator.of(context).pop();
                limpiarMesa(mesaId);
              },
            ),
          ],
        );
      },
    );
  }

  void limpiarMesa(int mesaId) async {
    final apiService = Provider.of<MesaService>(context, listen: false);
    try {
      final response = await apiService.limpiarMesa(mesaId);
      if (response['message'] == 'Mesa actualizada a libre') {
        getMesas();
      } else {
        throw Exception('Error al limpiar');
      }
    } catch (e) {}
  }

  IconData getIconEstado(String estado) {
    switch (estado) {
      case 'limpieza':
        return Icons.cleaning_services_outlined;
      default:
        return Icons.help_outline;
    }
  }

  Color getColorEstado(String estado) {
    switch (estado) {
      case 'limpieza':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'LIMPIEZA',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.purple,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      drawer: CustomDrawer(
        rol: 'Limpieza',
        currentScreen: 'Limpieza',
        onLogout: () {
        },
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
                return GestureDetector(
                  onTap: () => establecerLimpieza(mesa.id),
                  child: Container(
                    margin: const EdgeInsets.all(8.0),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: getColorEstado(mesa.estatus).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(
                        color: getColorEstado(mesa.estatus),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          getIconEstado(mesa.estatus),
                          size: 40,
                          color: getColorEstado(mesa.estatus),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Mesa ${mesa.numero}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: getColorEstado(mesa.estatus),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('Cliente: ${mesa.cliente}',
                            style: const TextStyle(fontSize: 16)),
                        Text('Estado: ${mesa.estatus}',
                            style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
