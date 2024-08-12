import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alimentos_app/services/loginService.dart';
import 'package:alimentos_app/services/mesaService.dart';
import 'package:alimentos_app/services/productoService.dart';
import 'package:alimentos_app/services/pedidoService.dart';
import 'package:alimentos_app/services/usuarioService.dart';
import 'package:alimentos_app/screens/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),
        Provider<MesaService>(
          create: (_) => MesaService(),
        ),
        Provider<ProductoService>(
          create: (_) => ProductoService(),
        ),
        Provider<PedidoService>(
          create: (_) => PedidoService(),
        ),
        Provider<UsuarioService>(
          create: (_) => UsuarioService(),
        ),
      ],
      child: MaterialApp(
        title: 'RESTAURANTE - APP',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const LoginScreen(),
      ),
    );
  }
}
