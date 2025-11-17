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
//1:41:50
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
            socket.join(room);
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

});

server.listen(port, "0.0.0.0", () => {
    console.log(`Servidor corriendo en el puerto ${port}`);
});