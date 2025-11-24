import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:skribbl_clone/models/touch_points.dart';
import 'package:skribbl_clone/waiting_lobby_screen.dart';
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
  List <Widget>textBlankWidget=[];
  ScrollController _scrollController = ScrollController();
  TextEditingController controller = TextEditingController();
  List<Map> messages = [];
  int guessedUserCtr =0;
  int _start = 60;
  late Timer timer;



 //estado de ejecutar una sola vez cuando la pantala se crea (connectar al socket)
  @override
  void initState() {
    super.initState();
    connect();
  }

  //constructor para un contador
  void StartTimer(){
    const oneSec = const Duration(seconds: 1);
    timer = Timer.periodic(oneSec, (Timer time){
      if(_start ==0){
        socket.emit('change-turn', dataOfRoom['Roomname']);
        setState(() {
          timer.cancel();
        });
      }
      else{
        setState(() {
          _start--;
        });
      }
    });
  }

  //constructor de la palabra secreta en la sala
  void renderTextBlank(String text){
    textBlankWidget.clear();
    for(int i=0; i<text.length; i++){
      textBlankWidget.add(const Text('_', style: TextStyle(fontSize: 30)));
    }
  }

  // Lógica para conectar al servidor de socket
  //aqui debo cambiar mi ip dependiendo de la red donde este XD
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
        print(roomData['word']);
        setState(() {
          renderTextBlank(roomData['word']);
          dataOfRoom = roomData;
        });
        if(roomData['isJoin'] != true){
          StartTimer();
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

      //socket para el chat de palabras
      socket.on('msg', (msgData){
        setState(() {
          messages.add(msgData);
          guessedUserCtr = msgData['guessedUserCtr'];
        });
        if(guessedUserCtr == dataOfRoom['players'].length -1){
          socket.emit('change-turn',dataOfRoom['Roomname']);
        }
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent+40, 
          duration: Duration(milliseconds: 200), 
          curve: Curves.easeInOut);
      });

      //socket para cambiar turnos
        socket.on('change-turn', (data) {
          if (!mounted) return;

          String oldWord = dataOfRoom['word'];

          // mostrar diálogo normal
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => AlertDialog(
              title: Center(child: Text('Word was $oldWord')),
            ),
          );

          // ejecutamos la transición fuera del builder
          Future.delayed(Duration(seconds: 3), () {
            if (!mounted) return;  // <-- previene freeze

            Navigator.of(context).pop(); // <-- cerrar diálogo

            setState(() {
              dataOfRoom = data;
              renderTextBlank(data['word']);
              guessedUserCtr = 0;
              _start = 60;
              points.clear();
            });

            // reiniciar correctamente el timer
            timer.cancel();
            StartTimer();
          });
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
            //convierte el color en un texto hexadecimal
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
      body: dataOfRoom !=null ? 
      dataOfRoom['isJoin'] != true ?   
      Stack(
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
              //chat de la sala
              dataOfRoom['turn']['nickname'] != widget.data['Nickname']  ?Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children:textBlankWidget,
              ): Center(child: Text(dataOfRoom['word'], style: TextStyle(fontSize: 30),),),
              Container(
                height: MediaQuery.of(context).size.height*0.25,
                //crea una lista/scroll que se ajusta con los mensajes
                child: ListView.builder(
                  controller: _scrollController,
                  shrinkWrap: true,
                  itemCount: messages.length,
                  itemBuilder:(context, index){
                    var msg = messages[index].values;
                    return ListTile(
                      title: Text(
                        msg.elementAt(0),
                        style:TextStyle(color:Colors.black, fontSize: 19, fontWeight: FontWeight.bold)
                      ),
                      subtitle: Text(
                        msg.elementAt(1),
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    );
                }),
              ),
              dataOfRoom['turn']['nickname'] != widget.data['Nickname']  ? Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller: controller, 
                    onSubmitted: (value) {
                      if(value.trim().isNotEmpty){
                        Map map={
                          'nickname':widget.data['Nickname'],
                          'msg':value.trim(),
                          'word':dataOfRoom['word'],
                          'roomName':widget.data['Roomname'],
                          'guessedUserCtr':guessedUserCtr,
                          'totalTime':60,
                          'timeTaken':60 - _start
                        };
                      socket.emit('msg', map);
                      controller.clear();
                      }
                    },
                    autocorrect: false,
                    decoration: InputDecoration(
                    border:OutlineInputBorder( 
                        borderRadius: BorderRadius.circular(8), 
                        borderSide: const BorderSide(color: Colors.transparent), 
                      ),
                    enabledBorder: OutlineInputBorder( 
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.transparent),
                      ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), 
                    filled: true,
                    fillColor: const Color(0xFFEFEFEF), 
                    hintText: 'Your Guess', 
                    hintStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400),
                      ),
                  textInputAction: TextInputAction.done,
                  ),
                ),
              ): Container(),
            ],
          )
        ],
      ) :WaitingLobbyScreen(
        lobbyName: dataOfRoom['Roomname'], 
        noOfPlayers: dataOfRoom['players'].length,
        occupancy: dataOfRoom['lobbySize'],
        players: dataOfRoom['players'])
      :Center(child: CircularProgressIndicator()),
      floatingActionButton: Container(
        margin: EdgeInsets.only(bottom: 30),
        child: FloatingActionButton(
          onPressed: () {},
          elevation: 7,
          backgroundColor: Colors.white,
          child: Text('$_start', style: TextStyle(color: Colors.black, fontSize: 22),),
        ),
      ),
    );
  }
}