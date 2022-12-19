const express = require("express");
const User = require("../models/user");
const jwt = require("jsonwebtoken");
const authRouter = express.Router();
const auth =require("../middleware/auth");
authRouter.post("/api/signup", async (req, res) => {
  try {
    console.log(req.body);
    const {name, email,photoUrl} = req.body;
    
    let user = await User.findOne({ email: email });
    // console.log(user);
    if (user==null) {
      
      user = new User({ email: email, profilePic: photoUrl, name: name });
      user = await user.save();
      
    }
    // console.log(user);
    const token=jwt.sign({id: user._id},"passwordKey");
    
    res.json({user,token});
    
  } catch (e) {
    res.status(500).json({error: e.message});
  }
});

authRouter.get('/',auth, async (req, res) => {
  const user = await User.findById(req.user);
  res.json({user,token: req.token});
  
})

module.exports = authRouter;