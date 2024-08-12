import 'package:alimentos_app/widgets/menuLateral.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alimentos_app/services/usuarioService.dart';
import 'package:alimentos_app/models/usuario.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    UsuariosTab(),
    ReportesTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ADMINISTRACIÓN',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.purple,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      drawer: CustomDrawer(
        rol: 'Administrador',
        currentScreen: 'Administrador',
        onLogout: () {},
      ),
      body: _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Usuarios',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Reportes',
          ),
        ],
      ),
    );
  }
}

class UsuariosTab extends StatefulWidget {
  const UsuariosTab({super.key});

  @override
  _UsuariosTabState createState() => _UsuariosTabState();
}

class _UsuariosTabState extends State<UsuariosTab> {
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _rol = 'mesero';

  final List<String> _roles = [
    'mesero',
    'corredor',
    'host',
    'limpieza',
    'administrador',
  ];

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usuarioService = Provider.of<UsuarioService>(context);
    final currentUserEmail =
        'tu_email_actual@gmail.com';

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _nombreController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _rol,
                    onChanged: (String? newValue) {
                      setState(() {
                        _rol = newValue!;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Rol',
                      border: OutlineInputBorder(),
                    ),
                    items: _roles.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 30),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () async {
                      if (_nombreController.text.isEmpty ||
                          _emailController.text.isEmpty ||
                          _passwordController.text.isEmpty) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Campos vacíos'),
                            content: const Text(
                                'Por favor, complete todos los campos.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                        return;
                      }

                      try {
                        final usuario = Usuario(
                          id: "",
                          nombre: _nombreController.text,
                          email: _emailController.text,
                          password: _passwordController.text,
                          rol: _rol,
                          usuarioId: 0,
                        );
                        await usuarioService.crearUsuario(usuario);
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Éxito'),
                            content: const Text('Usuario creado correctamente'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                        setState(() {});
                      } catch (e) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Error'),
                            content: const Text('No se pudo crear el usuario.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    child: const Text('Agregar Usuario'),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Usuario>>(
            future: usuarioService.obtenerUsuarios(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return const Center(child: Text('Error al cargar usuarios'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No hay usuarios registrados'));
              } else {
                final usuarios = snapshot.data!;
                return ListView.builder(
                  itemCount: usuarios.length,
                  itemBuilder: (context, index) {
                    final usuario = usuarios[index];
                    return ListTile(
                      title: Text(usuario.nombre),
                      subtitle:
                          Text('Email: ${usuario.email}\nRol: ${usuario.rol}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: usuario.rol == 'administrador' ||
                                usuario.email == currentUserEmail
                            ? null
                            : () async {
                                bool confirmar = await showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Confirmación'),
                                    content: const Text(
                                        '¿Está seguro que desea eliminar este usuario?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(false),
                                        child: const Text('Cancelar'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(true),
                                        child: const Text('Eliminar'),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirmar) {
                                  await usuarioService
                                      .eliminarUsuario(usuario.id);
                                  setState(
                                      () {});
                                }
                              },
                      ),
                      onTap: () {
                        
                      },
                    );
                  },
                );
              }
            },
          ),
        ),
      ],
    );
  }
}

class ReportesTab extends StatelessWidget {
  const ReportesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "Opss... este módulo está en desarrollo",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }
}
