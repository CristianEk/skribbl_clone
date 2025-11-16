import 'package:flutter/material.dart';
import 'package:skribbl_clone/widgets/custom_text_field.dart';

class JoinRoomScreen extends StatefulWidget {
  const JoinRoomScreen({super.key});

  @override
  State<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends State<JoinRoomScreen> {
    // Controlador para el campo de texto del nombre usuario
  final TextEditingController _nameController = TextEditingController();
  // Controlador para el campo de texto del nombre de la sala
  final TextEditingController _roomNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Acomoda los hijos en el centro verticalmente
        children: [
          const Text("Join Room",style: TextStyle(
            color: Colors.black,fontSize: 24,)),
          //Espacio entre texto y botones, toma el 8% de la altura de la pantalla
          SizedBox(height: MediaQuery.of(context).size.height*0.08),
          //contenedor para el campo de texto del nombre de usuario
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: CustomTextField(
              controller: _nameController,
              hintText: "Enter your name",
            ),
          ),
          SizedBox(height: 20),
          //contenedor para el campo de texto del nombre de la sala
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: CustomTextField(
              controller: _roomNameController,
              hintText: "Enter room name",
            ),
          ), 
          SizedBox(height: 40),
          // Botón para crear la sala
          ElevatedButton(onPressed: (){}, 
          style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.blue), //usa el color azul de fondo para todos los estados
                foregroundColor: MaterialStateProperty.all(Colors.white), //color del texto
                minimumSize: MaterialStateProperty.all(Size(MediaQuery.of(context).size.width/2.5, 50))
              ),
          child: const Text("Join!", style: TextStyle(color:Colors.white, fontSize: 16),),
          ),

        ],
      ),

    );
  }
}