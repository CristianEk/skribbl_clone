import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:skribbl_clone/models/touch_points.dart';
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
  List<TouchPoints?> points =[];
  StrokeCap strokeType =StrokeCap.round;
  Color selectedColor =Colors.black;
  double opacity =1;
  double strokeWidth =2;

 //estado de ejecutar una sola vez cuando la pantala se crea (connectar al socket)
  @override
  void initState() {
    super.initState();
    connect();
  }

  // Lógica para conectar al servidor de socket
  //aqui debo cambiar mi ip dependiendo de la red donde este XD
  void connect() {
    socket = IO.io('http://192.168.18.132:3000',<String,dynamic>{
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
      //socket que envia los puntos/trazos y hace que se pinte
      socket.on('points', (point) {
        if (point['details'] != null) {
          setState(() {
            points.add(TouchPoints(
                points: Offset((point['details']['dx']).toDouble(),
                    (point['details']['dy']).toDouble()),
                paint: Paint()
                  ..strokeCap = strokeType
                  ..isAntiAlias = true
                  ..color = selectedColor.withOpacity(opacity)
                  ..strokeWidth = strokeWidth));
          });
                }else {
            // FIN DE TRAZO
            setState(() {
              points.add(null);   
            });
          }
      });
      //socket para cambiar  el color
      socket.on('color-change',(colorString){
        int value = int.parse(colorString, radix: 16);
        Color otherColor = Color(value);
        setState(() {
          selectedColor = otherColor;
        });
      });
      //socket para grosor de linea
      socket.on('stroke-width',(value){
        setState(() {
          strokeWidth = value.toDouble();
        });
      });
      //socket para limpiar la pantalla
            socket.on('clean-screen',(data){
        setState(() {
          points.clear();
        });
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    //constructor que hace cambiar el color del pincel
    void selectColor(){
      showDialog(context: context, builder: (context)=> AlertDialog(
        title: const Text('Choose color'),
        content: SingleChildScrollView(
          child: BlockPicker(pickerColor: selectedColor, onColorChanged: (color){
            String valueString = color.value.toRadixString(16).padLeft(8, '0');
            print(valueString);
            Map map = {
              'color':valueString,
              'roomName': dataOfRoom['Roomname']
            };
            socket.emit('color-change', map);
          }),
        ),
        //boton para cerrar el cuadro de texto/ paleta de colores
        actions: [
          TextButton(onPressed: () {Navigator.of(context).pop();},
          child: Text('Close'),
          )
        ],
      ));
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: width,
                height: height *0.55,
                //detectar los gestos del usuario
                child: GestureDetector(
                  //el usuario arrastra el dedo pintando
                  onPanUpdate: (details) {
                    print(details.localPosition.dx);
                    socket.emit('paint', {
                      
                      'details':{
                        'dx': details.localPosition.dx,
                        'dy': details.localPosition.dy,
                      },
                      'roomName': widget.data['Roomname'],
                    });
                  },
                  //el usuario pone el dedo en la pantalla
                  onPanStart: (details) {
                    
                    socket.emit('paint', {
                      'details':{
                        'dx': details.localPosition.dx,
                        'dy': details.localPosition.dy,
                      },
                      'roomName': widget.data['Roomname'],
                    });
                  },
                  //el usuario levanta el dedo
                  onPanEnd: (details) {
                    socket.emit('paint', {
                      'details': null,
                      'roomName': widget.data['Roomname'],
                    });
                    setState(() {
                        points.add(null);
                      });
                  },      
                  child: SizedBox.expand(
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      child: RepaintBoundary(
                        child: CustomPaint(
                          size: Size.infinite,
                          painter: MyCustomPainter(pointsList: points),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              //barra que controla el grueso de la línea
              Row(
                children: [
                  IconButton(icon:Icon(Icons.color_lens, color:selectedColor), onPressed: () {
                    selectColor();
                  },),
                  Expanded(
                    child: Slider(
                      min: 1.0,
                      max: 10,
                      label: "Strokewidth $strokeWidth",
                      activeColor: selectedColor,
                      value: strokeWidth,
                      onChanged: (double value){
                        Map map ={
                          'value': value,
                          'roomName': dataOfRoom['Roomname']
                        };
                        socket.emit('stroke-width', map);
                      }
                    ),),
                    //borrar lienzo
                    IconButton(icon:Icon(Icons.layers_clear, color:selectedColor), onPressed: () {
                      socket.emit('clean-screen',dataOfRoom['Roomname']);
                    },),
                ]
              ),
            ],
          )
        ],
      ),
    );
  }
}