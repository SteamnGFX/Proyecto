import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class MagnetometroScreen extends StatefulWidget {
  const MagnetometroScreen({super.key});

  @override
  _MagnetometroScreenState createState() => _MagnetometroScreenState();
}

class _MagnetometroScreenState extends State<MagnetometroScreen> {
  double _x = 0.0, _y = 0.0, _z = 0.0;

  @override
  void initState() {
    super.initState();
    magnetometerEvents.listen((MagnetometerEvent event) {
      setState(() {
        _x = event.x;
        _y = event.y;
        _z = event.z;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Magnétometro',
          style: TextStyle(color: Colors.white),  
        ),
        backgroundColor: Colors.blueAccent,
        iconTheme: IconThemeData(color: Colors.white), 
      ),
      body: Center(
        child: Text('Campo magnético\nX: $_x µT\nY: $_y µT\nZ: $_z µT'),
      ),
    );
  }
}
