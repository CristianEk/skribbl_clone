import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller; // Controlador para manejar el texto ingresado
  final String hintText; // Texto de sugerencia que aparece cuando el campo está vacío
  CustomTextField({super.key, required this.controller, required this.hintText});


  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller, //Conecta el TextField con un controlador.
      decoration: InputDecoration(
      // borde cuando el TextField no está enfocado
      border:OutlineInputBorder( 
          borderRadius: BorderRadius.circular(8), // Bordes redondeados con un radio de 8
          borderSide: const BorderSide(color: Colors.transparent), // Borde transparente
        ),
      // Borde cuando el TextField está habilitado
      enabledBorder: OutlineInputBorder( 
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
      // Espaciado interno del TextField
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), 
      filled: true,
      fillColor: const Color(0xFFEFEFEF), 
      hintText: hintText, 
      hintStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      ),
    );
  }
}