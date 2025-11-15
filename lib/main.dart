import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Skribbl Clone',
      // Quita el banner de depuración  
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        //definimos el colores primario de la aplicación como azul
        primarySwatch: Colors.blue,
      
        //colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const Text("Skribbl Clone"),
    );
  }
}
