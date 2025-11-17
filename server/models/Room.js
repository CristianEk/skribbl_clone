const mongoose = require('mongoose');
const {playerSchema} = require('./Player');

const RoomSchema = new mongoose.Schema({
    word:{
        required: true,
        type: String
    },
    Roomname:{
        required: true,
        type: String,
        unique: true,
        trim: true
    },
    lobbySize:{
        required: true,
        type: Number,
        default: 4
    },
    Rounds:{
        required: true,
        type: Number
    },
    currentRound:{
        required: true,
        type: Number,
        default: 1
    },
    players: [playerSchema],
    isJoin:{
        type:Boolean,
        default:true
    },
    turn: playerSchema,
    turnIndex:{
        type:Number,
        default:0
    }
});

const gameModel = mongoose.model('Room', RoomSchema);
module.exports = gameModel;