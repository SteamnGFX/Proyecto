import 'package:flutter/material.dart';

class MesaConPedidoWidget extends StatelessWidget {
  final int numeroMesa;
  final String estado;
  final String cliente;
  final int comanda;
  final Function onTap;
  final Function onPedido;
  final Function onDesasignar;
  final Function(int) onEntregar;
  final Function(int) onPedirCuenta;

  const MesaConPedidoWidget({
    super.key,
    required this.numeroMesa,
    required this.estado,
    required this.cliente,
    required this.comanda,
    required this.onTap,
    required this.onPedido,
    required this.onDesasignar,
    required this.onEntregar,
    required this.onPedirCuenta,
  });

  IconData getIconEstado(String estado) {
    switch (estado) {
      case 'libre':
        return Icons.event_seat_outlined;
      case 'asignada':
        return Icons.person_outline;
      case 'pedido':
        return Icons.restaurant_menu;
      case 'comiendo':
        return Icons.local_dining;
      case 'preparando':
        return Icons.kitchen;
      case 'listo':
        return Icons.check_circle_outline;
      case 'limpieza':
        return Icons.cleaning_services_outlined;
      case 'cobrar':
        return Icons.attach_money_outlined;
      default:
        return Icons.help_outline;
    }
  }

  Color getColorEstado(String estado) {
    switch (estado) {
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
        return Colors.deepOrange; // Cambié a un color no usado
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(),
      onLongPress: () => onDesasignar(),
      child: Container(
        margin: const EdgeInsets.all(8.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: getColorEstado(estado).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: getColorEstado(estado), width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              getIconEstado(estado),
              size: 40,
              color: getColorEstado(estado),
            ),
            const SizedBox(height: 10),
            Text(
              'Mesa $numeroMesa',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: getColorEstado(estado)),
            ),
            if (estado != 'libre') ...[
              const SizedBox(height: 8),
              Text('Comanda: $comanda', style: const TextStyle(fontSize: 16)),
              if (cliente.isNotEmpty)
                Text('Cliente: $cliente', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
            ],
            if (estado == 'asignada')
              ElevatedButton(
                onPressed: () => onPedido(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  textStyle: const TextStyle(fontSize: 14),
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
                child: const Text(
                  'Realizar Pedido',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            if (estado == 'listo')
              ElevatedButton(
                onPressed: () => onEntregar(numeroMesa),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  textStyle: const TextStyle(fontSize: 14),
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
                child: const Text(
                  'Entregar Pedido',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            if (estado == 'comiendo')
              ElevatedButton(
                onPressed: () => onPedirCuenta(numeroMesa),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, 
                  foregroundColor: Colors.white, 
                ),
                child: const Text('Pedir Cuenta'),
              ),
          ],
        ),
      ),
    );
  }
}
