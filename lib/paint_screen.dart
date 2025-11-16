import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class PaintScreen extends StatefulWidget {
  const PaintScreen({super.key});

  @override
  State<PaintScreen> createState() => _PaintScreenState();
}

class _PaintScreenState extends State<PaintScreen> {

  //variable del socket
  late IO.Socket socket;

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

    // Escuchar eventos de conexión

    socket.onConnect((data) {
      print('Connected to socket server');
    });
  }


  @override
  Widget build(BuildContext context) {
    return Container();
  }
}