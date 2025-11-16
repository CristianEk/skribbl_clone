const express =require('express');
var http = require('http');
const app = express();
const port = process.env.PORT || 3000;
var server = http.createServer(app);
const mongoose = require('mongoose');

var io = require('socket.io')(server);

app.use(express.json());

const DB = 'mongodb+srv://cristian:12345@cluster0.zsekcig.mongodb.net/?appName=Cluster0';

mongoose.connect(DB).then(() =>{
    console.log('Conectado a la base de datos');
}).catch((e) => {
    console.log(e);
})

server.listen(port, "0.0.0.0", () => {
    console.log(`Servidor corriendo en el puerto ${port}`);
});