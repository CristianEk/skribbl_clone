import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold( // Scaffold proporciona la estructura básica de la pantalla
      body: Column( // Usamos una columna para organizar los elementos uno debajo del otro
        mainAxisAlignment: MainAxisAlignment.center, // Acomoda los hijos en el centro verticalmente
        crossAxisAlignment: CrossAxisAlignment.center, // Acomoda los hijos en el centro horizontalmente
        children: [
          const Text("Create or join a room to play!",style: TextStyle(
            color: Colors.black,
            fontSize: 24,
          )),
          //Espacio entre texto y botones, toma el 10% de la altura de la pantalla
          SizedBox(height: MediaQuery.of(context).size.height*0.1), 
          // Usamos una fila para organizar los botones uno al lado del otro
          Row( 
            mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Espacio uniforme entre los botones
            children: [
              //boton para crear sala
              ElevatedButton(onPressed: (){}, 
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.blue), //usa el color azul de fondo para todos los estados
                foregroundColor: MaterialStateProperty.all(Colors.white), //color del texto
                minimumSize: MaterialStateProperty.all(Size(MediaQuery.of(context).size.width/2.5, 50))
              ),
              child: const Text("Create Room"),
              ),
              //bopton para unirse a sala
              ElevatedButton(onPressed: (){},
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.blue), //usa el color azul de fondo para todos los estados
                foregroundColor: MaterialStateProperty.all(Colors.white),
                minimumSize: MaterialStateProperty.all(Size(MediaQuery.of(context).size.width/2.5, 50))
              ), 
              child: const Text("Join Room")
              ),
            ],
          )   
        ],

      ),


    );
  }
}