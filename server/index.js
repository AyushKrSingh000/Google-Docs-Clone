const express = require("express");
const cors= require("cors");
const mongoose = require("mongoose");
const authRouter = require("./routes/auth");
const documentRouter= require("./routes/document");
const http=require("http");


const port = process.env.PORT | 3001;
const app = express();
const server= http.createServer(app);
var io = require("socket.io")(server);

app.use(cors());
app.use(express.json());
app.use(authRouter);
app.use(documentRouter);
const db="mongodb+srv://ayushsingh:ayush1084@cluster0.dsik5ow.mongodb.net/?retryWrites=true&w=majority";
 mongoose.connect(db).then(()=>{
    console.log("hello world");
 }).catch((err)=>{
    console.log(err);
 });
 io.on('connection',(socket)=>{
   socket.on('join',(documentID)=>{
      socket.join(documentID);
      console.log('joined');
      socket.on('typing',(data)=>{
         socket.broadcast.to(data.room).emit('changes',data);
         console.log('joined');
      })
   })
 });

server.listen(port, "0.0.0.0", function () {
  console.log(`connected at port ${port}`);
});
