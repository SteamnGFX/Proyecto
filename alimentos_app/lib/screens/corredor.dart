import 'package:alimentos_app/widgets/menuLateral.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alimentos_app/models/mesa.dart';
import 'package:alimentos_app/services/mesaService.dart';

class CorredorScreen extends StatefulWidget {
  final int corredorId;
  const CorredorScreen({super.key, required this.corredorId});

  @override
  _CorredorScreenState createState() => _CorredorScreenState();
}

class _CorredorScreenState extends State<CorredorScreen> {
  List<Mesa> mesas = [];
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
        mesas = response.where((mesa) => mesa.estatus == 'limpieza').toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _confirmarLimpieza(int mesaId) {
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
                _limpiarMesa(mesaId);
              },
            ),
          ],
        );
      },
    );
  }

  void _limpiarMesa(int mesaId) async {
    final apiService = Provider.of<MesaService>(context, listen: false);
    try {
      final response = await apiService.limpiarMesa(mesaId);
      if (response['message'] == 'Mesa actualizada a libre') {
        _cargarMesas();
      } else {
        throw Exception('Error al limpiar');
      }
    } catch (e) {}
  }

  IconData _getIconForEstado(String estado) {
    switch (estado) {
      case 'limpieza':
        return Icons.cleaning_services_outlined;
      default:
        return Icons.help_outline;
    }
  }

  Color _getColorForEstado(String estado) {
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
                  onTap: () => _confirmarLimpieza(mesa.id),
                  child: Container(
                    margin: const EdgeInsets.all(8.0),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: _getColorForEstado(mesa.estatus).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(
                        color: _getColorForEstado(mesa.estatus),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getIconForEstado(mesa.estatus),
                          size: 40,
                          color: _getColorForEstado(mesa.estatus),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Mesa ${mesa.numero}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _getColorForEstado(mesa.estatus),
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
