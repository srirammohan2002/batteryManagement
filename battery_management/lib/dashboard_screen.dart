import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'mqtt_handler.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mqtt = Provider.of<MqttHandler>(context, listen: false);
      mqtt.connect();
    });
  }

  @override
  Widget build(BuildContext context) {
    final mqtt = Provider.of<MqttHandler>(context);
    final data = mqtt.batteryData;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Battery Monitor'),
        actions: [
          IconButton(
            icon: Icon(mqtt.isConnected ? Icons.wifi : Icons.wifi_off),
            onPressed: () => mqtt.connect(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildConnectionStatus(mqtt),
            const SizedBox(height: 20),
            _buildGauge("Voltage (V)", data['voltage'], 30, 50),
            const SizedBox(height: 20),
            _buildGauge("Current (A)", data['current'], -10, 10),
            const SizedBox(height: 20),
            _buildCircularGauge("Charge (%)", data['soc'], 0, 100),
            const SizedBox(height: 20),
            _buildTemperatureCard(data['temperature']),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionStatus(MqttHandler mqtt) {
    return Card(
      child: ListTile(
        leading: Icon(
          mqtt.isConnected ? Icons.check_circle : Icons.error,
          color: mqtt.isConnected ? Colors.green : Colors.red,
        ),
        title: Text(mqtt.status),
        trailing: !mqtt.isConnected
            ? TextButton(
                onPressed: mqtt.connect,
                child: const Text("Reconnect"),
              )
            : null,
      ),
    );
  }

  Widget _buildGauge(String title, double value, double min, double max) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: SfLinearGauge(
                minimum: min,
                maximum: max,
                markerPointers: [
                  LinearShapePointer(value: value),
                ],
                ranges: [
                  LinearGaugeRange(
                    startValue: min,
                    endValue: max,
                    color: _getRangeColor(value, min, max),
                  ),
                ],
              ),
            ),
            Text("$value", style: const TextStyle(fontSize: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularGauge(
      String title, double value, double min, double max) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: SfRadialGauge(
                axes: [
                  RadialAxis(
                    minimum: min,
                    maximum: max,
                    ranges: [
                      GaugeRange(
                        startValue: min,
                        endValue: max,
                        color: _getRangeColor(value, min, max),
                      ),
                    ],
                    pointers: [
                      NeedlePointer(value: value),
                    ],
                  ),
                ],
              ),
            ),
            Text("$value%", style: const TextStyle(fontSize: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildTemperatureCard(double temp) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.thermostat, size: 40),
        title: const Text("Temperature"),
        subtitle: Text("$temp °C", style: const TextStyle(fontSize: 24)),
        trailing: Icon(
          temp > 35 ? Icons.warning : Icons.check,
          color: temp > 35 ? Colors.red : Colors.green,
        ),
      ),
    );
  }

  Color _getRangeColor(double value, double min, double max) {
    final percent = (value - min) / (max - min);
    if (percent < 0.3) return Colors.red;
    if (percent < 0.6) return Colors.orange;
    return Colors.green;
  }
}
