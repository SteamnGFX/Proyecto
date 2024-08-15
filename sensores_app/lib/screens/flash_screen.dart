import 'package:flutter/material.dart';
import 'package:torch_light/torch_light.dart';

class FlashScreen extends StatefulWidget {
  @override
  _FlashScreenState createState() => _FlashScreenState();
}

class _FlashScreenState extends State<FlashScreen> {
  bool _isFlashOn = false;

  void _toggleFlash() async {
    try {
      if (_isFlashOn) {
        await TorchLight.disableTorch();
      } else {
        await TorchLight.enableTorch();
      }
      setState(() {
        _isFlashOn = !_isFlashOn;
      });
    } catch (e) {
      print("Error encendiendo el flash: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("No se pudo acceder al flash"),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  void dispose() {
    if (_isFlashOn) {
      TorchLight.disableTorch();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Control del Flash',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isFlashOn ? Icons.flash_on : Icons.flash_off,
              size: 100,
              color: _isFlashOn ? Colors.yellow : Colors.grey,
            ),
            SizedBox(height: 20),
            Text(
              _isFlashOn ? 'Flash Encendido' : 'Flash Apagado',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _toggleFlash,
              icon: Icon(_isFlashOn ? Icons.flash_off : Icons.flash_on, color: Colors.white),
              label: Text(
                _isFlashOn ? 'Apagar Flash' : 'Encender Flash',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                textStyle: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
