const mongoose = require('mongoose');

const tokenSchema = new mongoose.Schema({
    accessToken: { type:String, required: true,},
    username:{ type:String, required: true, unique: true},
    createdAt: { type: Date, default: Date.now},

});
module.exports = mongoose.model('Token', tokenSchema);