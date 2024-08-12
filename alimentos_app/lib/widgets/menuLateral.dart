import 'package:flutter/material.dart';
import 'package:alimentos_app/screens/login.dart'; // Asegúrate de importar la pantalla de login

class CustomDrawer extends StatelessWidget {
  final String rol;
  final String currentScreen;
  final Function onLogout;

  const CustomDrawer({
    super.key,
    required this.rol,
    required this.currentScreen,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.purple,
            ),
            accountName: Text(
              rol,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            accountEmail: null,  // Elimina esta línea para no mostrar accountEmail
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                rol[0], // Primera letra del rol
                style: const TextStyle(fontSize: 40, color: Colors.purple),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Inicio'),
            onTap: () {
              Navigator.of(context).pop(); // Cierra el drawer
              // Navegar a la pantalla de inicio (puedes personalizar esta acción)
            },
          ),
          const Spacer(),
          Divider(color: Colors.grey.shade400),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.red),
            title: const Text(
              'Cerrar Sesión',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              Navigator.of(context).pop(); // Cierra el drawer
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()), // Navega a la pantalla de login
              );
            },
          ),
        ],
      ),
    );
  }
}
