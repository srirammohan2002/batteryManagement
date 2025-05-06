import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'mqtt_handler.dart';
import 'dashboard_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => MqttHandler(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Battery Monitor',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const DashboardScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
