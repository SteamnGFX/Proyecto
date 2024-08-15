import 'package:flutter/material.dart';
import 'package:sensores_app/screens/giroscopio_screen.dart';
import 'package:sensores_app/screens/magnetometro_screen.dart';
import 'package:sensores_app/screens/proxomidad_screen.dart';
import 'package:sensores_app/screens/acelerometro_screen.dart';
import 'package:sensores_app/screens/flash_screen.dart';
import '../widgets/drawer_menu.dart';

class InicioScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sensores', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        iconTheme: IconThemeData(color: Colors.white),
        actionsIconTheme: IconThemeData(color: Colors.white),
      ),
      drawer: DrawerMenu(),
      drawerEnableOpenDragGesture: true,  
      drawerScrimColor: Colors.black54,
      body: GridView.count(
        crossAxisCount: 2,
        children: [
          _buildSensorButton(context, 'Acelerómetro', Icons.speed, AcelerometroScreen()),
          _buildSensorButton(context, 'Giroscopio', Icons.screen_rotation, GiroscopioScreen()),
          _buildSensorButton(context, 'Magnetómetro', Icons.explore, MagnetometroScreen()),
          _buildSensorButton(context, 'Proximidad', Icons.sensors, ProximidadScreen()),
          _buildSensorButton(context, 'Flash', Icons.flash_on, FlashScreen()),
        ],
      ),
    );
  }

  Widget _buildSensorButton(BuildContext context, String title, IconData icon, Widget screen) {
    return Card(
      color: Colors.white,
      shadowColor: Colors.blueAccent,
      elevation: 5,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
        },
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 50, color: Colors.blueAccent),
              SizedBox(height: 10),
              Text(title, style: TextStyle(color: Colors.blueAccent, fontSize: 18)),
            ],
          ),
        ),
      ),
    );
  }
}
