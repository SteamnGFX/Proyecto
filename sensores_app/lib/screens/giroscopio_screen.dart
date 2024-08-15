import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class GiroscopioScreen extends StatefulWidget {
  const GiroscopioScreen({super.key});

  @override
  _GiroscopioScreenState createState() => _GiroscopioScreenState();
}

class _GiroscopioScreenState extends State<GiroscopioScreen> {
  double _x = 0.0, _y = 0.0, _z = 0.0;

  @override
  void initState() {
    super.initState();
    gyroscopeEvents.listen((GyroscopeEvent event) {
      setState(() {
        _x = event.x;
        _y = event.y;
        _z = event.z;
      });
      _handleRotation();
    });
  }

  void _handleRotation() {
    if ((_x > 5.0 || _y > 5.0 || _z > 5.0)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Alta rotación detectada!"),
        backgroundColor: Colors.blue,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Giroscopio',
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
