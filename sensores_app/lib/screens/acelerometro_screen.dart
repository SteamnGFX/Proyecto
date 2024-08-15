import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class AcelerometroScreen extends StatefulWidget {
  const AcelerometroScreen({super.key});

  @override
  _AcelerometroScreenState createState() => _AcelerometroScreenState();
}

class _AcelerometroScreenState extends State<AcelerometroScreen> {
  double _x = 0.0, _y = 0.0, _z = 0.0;

  @override
  void initState() {
    super.initState();
    accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        _x = event.x;
        _y = event.y;
        _z = event.z;
      });
      _handleMovement();
    });
  }

  void _handleMovement() {
    if ((_x > 15.0 || _y > 15.0 || _z > 15.0)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Movimiento rápido detectado!"),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Acelerometro',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Text('X: $_x, Y: $_y, Z: $_z'),
      ),
    );
  }
}
