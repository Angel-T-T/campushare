import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/home_screen.dart';

// Asegúrate de tener un archivo firebase_options.dart generado por FlutterFire CLI para configuración multiplataforma segura.
// Si no lo tienes, puedes usar Firebase.initializeApp() sin parámetros, pero es recomendable usar FirebaseOptions.

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // O usa: Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App de Aprendizaje',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
    );
  }
}