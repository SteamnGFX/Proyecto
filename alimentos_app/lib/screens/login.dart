import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alimentos_app/services/loginService.dart';
import 'package:alimentos_app/screens/host.dart';
import 'package:alimentos_app/screens/mesero.dart';
import 'package:alimentos_app/screens/cocina.dart';
import 'package:alimentos_app/screens/limpieza.dart';
import 'package:alimentos_app/screens/cajero.dart';
import 'package:alimentos_app/screens/admin.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String errorMessage = '';

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Positioned(
            top: -50, 
            left: 0,
            right: 0,
            child: _buildTopContainer(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Spacer(flex: 2),
                const Text(
                  "Bienvenido",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Inicia sesión en tu cuenta",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                ),
                const Spacer(),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.email),
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock),
                    labelText: 'Contraseña',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  obscureText: true,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                    },
                    child: const Text('Olvidaste tu contraseña?'),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      final response = await authService.login(
                        _emailController.text,
                        _passwordController.text,
                      );
                      final int userId = response['id'] ?? 0;
                      if (response['rol'] == 'host') {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const HostScreen()),
                        );
                      } else if (response['rol'] == 'mesero') {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MeseroScreen(meseroId: userId),
                          ),
                        );
                      } else if (response['rol'] == 'cocina') {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const CocinaScreen()),
                        );
                      } else if (response['rol'] == 'corredor') {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LimpiadorScreen(corredorId: userId),
                          ),
                        );
                      } else if (response['rol'] == 'caja') {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const CajaScreen()),
                        );
                      } else if (response['rol'] == 'administrador') {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const AdminScreen()),
                        );
                      }
                    } catch (error) {
                      setState(() {
                        errorMessage = 'Usuario / contraeña incorrecta.';
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 30,
                    ),
                  ),
                  child: const Text('Iniciar Sesión'),
                ),
                const SizedBox(height: 20),
                Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
                const Spacer(),
                const SizedBox(height: 20),
                const Spacer(flex: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopContainer() {
    return Container(
      height: 300, 
      decoration: const BoxDecoration(
        color: Colors.purple,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(50),
          bottomRight: Radius.circular(50),
        ),
      ),
    );
  }
}
