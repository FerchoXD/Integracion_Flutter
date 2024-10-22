import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:fl_chart/fl_chart.dart';

class SensorsScreen extends StatefulWidget {
  const SensorsScreen({Key? key}) : super(key: key); // Asegúrate de agregar "super(key: key)"

  @override
  _SensorScreenState createState() => _SensorScreenState();
}

class _SensorScreenState extends State<SensorsScreen> {
  List<double> _accelerometerDataX = [];
  List<double> _accelerometerDataY = [];
  List<double> _accelerometerDataZ = [];
  List<double> _gyroscopeDataX = [];
  List<double> _gyroscopeDataY = [];
  List<double> _gyroscopeDataZ = [];
  List<double> _magnetometerDataX = [];
  List<double> _magnetometerDataY = [];
  List<double> _magnetometerDataZ = [];

  @override
  void initState() {
    super.initState();
    _initSensors();
  }

  void _initSensors() {
    // Escuchar los cambios del acelerómetro
    accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        _addDataToList(event.x, event.y, event.z, _accelerometerDataX, _accelerometerDataY, _accelerometerDataZ);
      });
    });

    // Escuchar los cambios del giroscopio
    gyroscopeEvents.listen((GyroscopeEvent event) {
      setState(() {
        _addDataToList(event.x, event.y, event.z, _gyroscopeDataX, _gyroscopeDataY, _gyroscopeDataZ);
      });
    });

    // Escuchar los cambios del magnetómetro
    magnetometerEvents.listen((MagnetometerEvent event) {
      setState(() {
        _addDataToList(event.x, event.y, event.z, _magnetometerDataX, _magnetometerDataY, _magnetometerDataZ);
      });
    });
  }

  void _addDataToList(double x, double y, double z, List<double> xList, List<double> yList, List<double> zList) {
    if (xList.length > 20) {
      xList.removeAt(0);
      yList.removeAt(0);
      zList.removeAt(0);
    }
    xList.add(x);
    yList.add(y);
    zList.add(z);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Datos de Sensores')),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _buildSensorGraph("Acelerómetro - X", _accelerometerDataX),
            _buildSensorGraph("Acelerómetro - Y", _accelerometerDataY),
            _buildSensorGraph("Acelerómetro - Z", _accelerometerDataZ),
            _buildSensorGraph("Giroscopio - X", _gyroscopeDataX),
            _buildSensorGraph("Giroscopio - Y", _gyroscopeDataY),
            _buildSensorGraph("Giroscopio - Z", _gyroscopeDataZ),
            _buildSensorGraph("Magnetómetro - X", _magnetometerDataX),
            _buildSensorGraph("Magnetómetro - Y", _magnetometerDataY),
            _buildSensorGraph("Magnetómetro - Z", _magnetometerDataZ),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorGraph(String title, List<double> data) {
    double minY = title.contains("Magnetómetro") ? -30 : -10;
    double maxY = title.contains("Magnetómetro") ? 30 : 10;

    return Card(
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
                  ),
                  borderData: FlBorderData(show: true),
                  minX: 0,
                  maxX: 20,
                  minY: minY,
                  maxY: maxY,
                  lineBarsData: [
                    LineChartBarData(
                      spots: data.asMap().entries.map((e) {
                        return FlSpot(e.key.toDouble(), e.value);
                      }).toList(),
                      isCurved: true,
                      color: Colors.blue,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
