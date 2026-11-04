import 'package:bab4/provider/app_provider.dart';
import 'package:bab4/screens/home_page.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  DevicePreview.enable();

runApp(const MyApp());
} 
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (_) => AppProvider(),
    child: MaterialApp(
      title: "MCS BAB 4",
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const HomePage(),
    ),
  );
}
