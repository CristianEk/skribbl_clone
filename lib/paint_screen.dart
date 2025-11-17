import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'models/my_custom_painter.dart';

class PaintScreen extends StatefulWidget {
  final Map<String, String> data;
  final String screenFrom;
  PaintScreen({required this.data, required this.screenFrom});

  @override
  State<PaintScreen> createState() => _PaintScreenState();
}

class _PaintScreenState extends State<PaintScreen> {

  //variable del socket
  late IO.Socket socket;

  Map dataOfRoom = {};
  List points =[];


 //estado de ejecutar una sola vez cuando la pantala se crea (connectar al socket)
  @override
  void initState() {
    super.initState();
    connect();
  }

  // Lógica para conectar al servidor de socket
  void connect() {
    socket = IO.io('http://192.168.100.17:3000',<String,dynamic>{
      'transports':['websocket'],
      'autoConnect': false
    });

    socket.connect();
    //si vengo de createRoom crea el evento con los datos
    if (widget.screenFrom == 'createRoom') {
      socket.emit('Create-Game', widget.data);
    } 
    else{
      socket.emit('Join-Game', widget.data);
    }
    // Escuchar eventos de conexión
    socket.onConnect((data) {
      print('Si conecte');
      //vienen los datos una vez validados en el index.js
      socket.on('updateRoom',(roomData){
        setState(() {
           dataOfRoom = roomData;
        });
        if(roomData['isJoin'] != true){
          
        }
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: width,
                height: height *0.55,
                child: GestureDetector(
                  onPanUpdate: (details) {},
                  onPanStart: (details) {},
                  onPanEnd: (details) {},
                  child: SizedBox.expand(
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      child: RepaintBoundary(
                        child: CustomPaint(
                          size: Size.infinite,
                          painter: MyCustomPainter(pointslist: points),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}