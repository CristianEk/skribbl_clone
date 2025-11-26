const express =require('express');
var http = require('http');
const app = express();
const port = process.env.PORT || 3000;
var server = http.createServer(app);
const mongoose = require('mongoose');
const Room = require('./models/Room');
const Player = require('./models/Player');
const getWord = require('./api/getWord');

var io = require('socket.io')(server);

app.use(express.json());

const DB = 'mongodb+srv://cristian:12345@cluster0.zsekcig.mongodb.net/?appName=Cluster0';

mongoose.connect(DB).then(() =>{
    console.log('Conectado a la base de datos');
}).catch((e) => {
    console.log(e);
})

io.on('connection',(socket) => {
    console.log('connected');
    //CREAR SALA
    //cuando se ejecuta el evento escucha los datos en la carga 
    socket.on('Create-Game', async({Nickname,Roomname,Rounds,LobbySize})=>{
        //si existe manda error de sala existente
        try{
            const existingRoom = await Room.findOne({Roomname});
            if(existingRoom){
                socket.emit('notCorrectGame','Room with name already exist!');
                return;
            }
            //si no, crea la sala con los datos y elige una palabra para la ronda
            let room = new Room();
            const word = getWord();
            room.word = word;
            room.Roomname = Roomname;
            room.Rounds = Rounds;
            room.lobbySize = LobbySize;
            //crea al dueño de la sala a base del socket.id y le asigna el rando lider
            let player = {
                socketID: socket.id,
                nickname: Nickname,
                isPartyLeader: true,
            }
            //manda a los jugadores a la sala
            room.players.push(player);
            //guarda la sala en la base de datos
            room = await room.save();
            //el socket entra a la sala
            socket.join(Roomname);
            //envia los datos a todos en la sala
            io.to(Roomname).emit('updateRoom',room);
        }
        catch(e){
            console.log(e);
        }
    })
    //UNIRSE A SALA 
    socket.on('Join-Game', async({Nickname,Roomname})=>{
        //si existe manda error de sala existente
        try{
            let room = await Room.findOne({Roomname});
            if(!room){
                socket.emit('notCorrectGame','Room with name already not exist!');
                return;
            }
            if(room.isJoin){
                let player = {
                socketID: socket.id,
                nickname: Nickname,
                }
                room.players.push(player);
                socket.join(Roomname);

                if(room.players.length === room.lobbySize){
                    room.isJoin = false;
                }
                room.turn = room.players[room.turnIndex];
                room = await room.save();
                io.to(Roomname).emit('updateRoom',room);
            }
            else{
                socket.emit('notCorrectGame','Game in progress, try later!');
            }    
        }
        catch(e){
            console.log(e);
        }
    })
    //recibe los datos del nombre y mensaje de las salas y los replica usando el socker msdg en paintscreen
    socket.on('msg',async(data) =>{
        try {
            if(data.msg===data.word){
                let room = await Room.find({Roomname: data.roomName});
                let userPlayer = room[0].players.filter(
                    (player) => player.nickname === data.nickname
                )
                if(data.timeTaken !== 0){
                    userPlayer[0].points += Math.round((200/data.timeTaken) * 10);
                }
                room = await room[0].save();
                io.to(data.roomName).emit('msg',{
                nickname: data.nickname,
                msg: 'guessed it!',
                guessedUserCtr:data.guessedUserCtr +1,
            })
            socket.emit('closeInput', "");
        }
            else{
                io.to(data.roomName).emit('msg',{
                nickname: data.nickname,
                msg: data.msg,
                guessedUserCtr:data.guessedUserCtr,
            })}
        } 
        catch (e) {
            console.log(e.toString());
        }
    })

    //socket para controlar los turnos
    socket.on('change-turn', async(Roomname) =>{
        try {
            let room = await Room.findOne({Roomname});
            let idx = room.turnIndex;
            if(idx +1 === room.players.length){
                room.currentRound+=1;
            }
            if(room.currentRound <= room.Rounds){
                const word = getWord();
                room.word = word;
                room.turnIndex = (idx+1) % room.players.length;
                room.turn = room.players[room.turnIndex];
                room = await room.save();
                io.to(Roomname).emit('change-turn', room);
            }
            else{

            }
            
        } catch (e) {
            console.log(e);
        }
    })

    //socket para actualizar el marcador
    socket.on('updateScore', async(Roomname) =>{
        try {
            const room = await Room.findOne({Roomname});
            io.to(Roomname).emit('updateScore', room);
        } 
        catch (e) {
            console.log(e);
        }
    })

    //reenvia los datos pintados a todos en la sala
    socket.on('paint', ({details, roomName})=>{
        io.to(roomName).emit('points',{details:details});
    })

    //controlador para cambiar el color
    socket.on('color-change', ({color,roomName})=>{
        io.to(roomName).emit('color-change',color)
    })

    //controlador para el grosor
    socket.on('stroke-width', ({value, roomName}) =>{
        io.to(roomName).emit('stroke-width',value)
    })
    //controlador para limpiar el trazo
    socket.on('clean-screen', (roomName) =>{
        io.to(roomName).emit('clean-screen','')
    })
});

server.listen(port, "0.0.0.0", () => {
    console.log(`Servidor corriendo en el puerto ${port}`);
});