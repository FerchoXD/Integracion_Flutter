import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart'; 

class QrCodeScreen extends StatefulWidget {
  @override
  _QRCodeScreenState createState() => _QRCodeScreenState();
}

class _QRCodeScreenState extends State<QrCodeScreen> {
  String? qrResult; // Almacenará el resultado del QR (matrícula)
  MobileScannerController cameraController = MobileScannerController(); // Controlador del escáner
  final ImagePicker _picker = ImagePicker();  // Controlador para seleccionar imágenes

  @override
  void initState() {
    super.initState();
    // Eliminar _requestAllPermissions(); y _requestCameraPermission(); de aquí
  }

  Future<void> _requestCameraPermission() async {
    // Solicitar permisos de cámara
    PermissionStatus cameraStatus = await Permission.camera.request();

    // Verifica si el permiso fue concedido
    if (cameraStatus == PermissionStatus.granted) {
      cameraController.start();   // Iniciar la cámara una vez que el permiso es concedido
    } else if (cameraStatus == PermissionStatus.permanentlyDenied) {
      // Si el permiso fue denegado permanentemente, abrir la configuración
      await openAppSettings();
    }
  }

  // Función que seguirá solicitando permisos de cámara y galería hasta que se otorguen
  Future<void> _requestAllPermissions() async {
    bool permissionsGranted = false;

    while (!permissionsGranted) {
      // Solicitar permisos de galería
      PermissionStatus galleryStatus = await Permission.photos.request();

      // Verifica si ambos permisos fueron concedidos
      if (galleryStatus == PermissionStatus.granted) {
        permissionsGranted = true;  // Todos los permisos otorgados, salir del ciclo
      } else if (galleryStatus == PermissionStatus.permanentlyDenied) {
        // Si los permisos fueron denegados permanentemente, abrir la configuración
        await openAppSettings();
      }
    }
  }

  // Función de detección de códigos QR
  void _onDetect(BarcodeCapture capture) {
    final Barcode? barcode = capture.barcodes.first;
    final String? code = barcode?.rawValue;  // Obtiene el valor del código QR
    if (code != null) {
      setState(() {
        qrResult = code;  // Almacena el resultado (matrícula)
        cameraController.stop();  // Detiene la cámara al detectar
      });
    }
  }

  // Función para seleccionar una imagen de la galería y procesar el código QR
  Future<void> _scanImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final String imagePath = image.path;
      final BarcodeCapture? result = await cameraController.analyzeImage(imagePath); // Analiza la imagen usando el path
      if (result != null && result.barcodes.isNotEmpty) {
        setState(() {
          qrResult = result.barcodes.first.rawValue; // Muestra el valor del código QR
        });
      } else {
        setState(() {
          qrResult = 'No se detectó ningún código QR en la imagen.';
        });
      }
    }
  }

  // Función para resetear el valor de qrResult
  void _resetQRResult() {
    setState(() {
      qrResult = null;  // Resetea el valor a null
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Escanear Matrícula QR'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: MobileScanner(
              controller: cameraController,
              onDetect: _onDetect,  // Detecta el código QR con la cámara
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                qrResult != null
                    ? Text(
                        'Matrícula: $qrResult',  // Muestra la matrícula escaneada
                        style: TextStyle(fontSize: 24),
                      )
                    : Text(
                        'Escanea un código QR',
                        style: TextStyle(fontSize: 20),
                      ),
                SizedBox(height: 20),  // Espaciado
                ElevatedButton(
                  onPressed: _resetQRResult,  // Llamar la función de reset al presionar el botón
                  child: Text('Resetear Matrícula'),
                ),
                SizedBox(height: 20),  // Espaciado
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.camera_alt),
                      onPressed: () async {
                        await _requestCameraPermission(); // Verifica y solicita permisos de cámara
                        _resetQRResult();  // Resetea el valor de qrResult
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.flash_on),
                      onPressed: () => cameraController.toggleTorch(),  // Alternar linterna
                    ),
                    IconButton(
                      icon: Icon(Icons.image),
                      onPressed: _scanImage,  // Seleccionar imagen de la galería
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
