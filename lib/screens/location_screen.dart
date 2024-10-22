import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class LocationScreen extends StatefulWidget {
  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  Position? _position;
  String _locationStatus = "Comprobando ubicación...";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      setState(() {
        _locationStatus = "Permiso de ubicación denegado";
        isLoading = false;
      });
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
    ));

    setState(() {
      _position = position;
      _locationStatus = "Ubicación obtenida";
      isLoading = false;
    });
  }

  Future<void> _openMaps() async {
    if (_position != null) {
      final url =
          'https://www.google.com/maps/search/?api=1&query=${_position!.latitude},${_position!.longitude}';
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        throw 'No se puede abrir Google Maps';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("GPS"),
        centerTitle: true,
      ),
      body: Center(
        child: isLoading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    _locationStatus,
                    style: const TextStyle(fontSize: 24),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
              
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Latitud: ${_position?.latitude ?? 'Desconocida'}",
                    style: const TextStyle(fontSize: 18),
                  ),
                  Text(
                    "Longitud: ${_position?.longitude ?? 'Desconocida'}",
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: _openMaps,
                    child: const Text("Abrir en Google Maps"),
                  ),
                ],
              ),
      ),
    );
  }
}
