import 'package:flutter/material.dart';
import 'package:skribbl_clone/widgets/custom_text_field.dart';
import 'package:skribbl_clone/paint_screen.dart';

class CreateRoomScreen extends StatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  // Controlador para el campo de texto del nombre usuario
  final TextEditingController _nameController = TextEditingController();
  // Controlador para el campo de texto del nombre de la sala
  final TextEditingController _roomNameController = TextEditingController();
  // Valor seleccionado en el Dropdown de rondas máximas
  late String? _maxRoundsValue;
  // Valor seleccionado en el Dropdown de tamaño de sala
  late String? _roomSizeValue;

  // Función para manejar la creación de la sala
  void createRoom() {
    if (_nameController.text.isNotEmpty &&
        _roomNameController.text.isNotEmpty &&
        _maxRoundsValue != null &&
        _roomSizeValue != null) {
          Map <String, String> data= {
            "Nickname": _nameController.text,
            "Roomname": _roomNameController.text,
            "Rounds": _maxRoundsValue!,
            "LobbySize": _roomSizeValue!
          };
          //me manda a la sala de PaintScreen con los datos del Map y la ruta de donded viene
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => PaintScreen(data : data, screenFrom: 'createRoom' )));              
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Acomoda los hijos en el centro verticalmente
        children: [
          const Text("Create Room",style: TextStyle(
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
          SizedBox(height: 20),
          // Dropdown para seleccionar el número de rondas
          DropdownButton<String>(
            focusColor: Color(0xFFF5F6FA),
            // lista de elelemntos que se vuelven opciones en el dropdown con el .map
            items: ["2", "5", "10", "15"].map<DropdownMenuItem<String>>(
              // función anónima que crea un DropdownMenuItem para cada valor
              (String value) => DropdownMenuItem(
                value: value,
                child: Text(
                  value,
                  style: const TextStyle(color: Colors.black),
                ))).toList(), // convierte el iterable en una lista
            hint: const Text("Select Max Rounds",style: TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),),
              // valor seleccionado actualmente
            onChanged: (String? value) {
              setState(() {
                _maxRoundsValue = value;
              });
            },
          ),
          SizedBox(height: 20),
          // Dropdown para seleccionar el número de jugadores
          DropdownButton<String>(
            focusColor: Color(0xFFF5F6FA),
            // lista de elelemntos que se vuelven opciones en el dropdown con el .map
            items: ["2", "3", "4", "5", "6", "7", "8"].map<DropdownMenuItem<String>>(
              // función anónima que crea un DropdownMenuItem para cada valor
              (String value) => DropdownMenuItem(
                value: value,
                child: Text(
                  value,
                  style: const TextStyle(color: Colors.black),
                ))).toList(), // convierte el iterable en una lista
            hint: const Text("Select room size",style: TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),),
              // valor seleccionado actualmente
            onChanged: (String? value) {
              setState(() {
                _roomSizeValue = value;
              });
            },
          ),
          SizedBox(height: 40),
          // Botón para crear la sala
          ElevatedButton(onPressed: createRoom, 
          style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.blue), //usa el color azul de fondo para todos los estados
                foregroundColor: MaterialStateProperty.all(Colors.white), //color del texto
                minimumSize: MaterialStateProperty.all(Size(MediaQuery.of(context).size.width/2.5, 50))
              ),
          child: const Text("Create!", style: TextStyle(color:Colors.white, fontSize: 16),),
          ),

        ],
      ),

    );
  }
}