import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class ProximidadScreen extends StatefulWidget {
  const ProximidadScreen({super.key});

  @override
  _ProximidadScreenState createState() => _ProximidadScreenState();
}

class _ProximidadScreenState extends State<ProximidadScreen> {
  bool _isNear = false;

  @override
  void initState() {
    super.initState();
    userAccelerometerEvents.listen((UserAccelerometerEvent event) {
      setState(() {
        _isNear = event.z < 5; 
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sensor de proximidad',
          style: TextStyle(color: Colors.white),  
        ),
        backgroundColor: Colors.blueAccent,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isNear ? Icons.signal_cellular_4_bar : Icons.signal_cellular_null,
              size: 100,
              color: _isNear ? Colors.green : Colors.red,
            ),
            const SizedBox(height: 20),
            Text(
              _isNear ? 'Objeto Cercano Detectado' : 'No se Detecta Objeto Cercano',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _isNear ? Colors.green : Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, color: Colors.white),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Este sensor detecta si hay un objeto cerca del dispositivo.',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
