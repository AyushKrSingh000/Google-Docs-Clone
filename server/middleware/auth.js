const jwt= require('jsonwebtoken');
const auth = async(req,res,next) => {
    try{
        const token=req.header('X-Auth-Token');
        if(!token){
            return res.status(401).json({msg : "No auth token, access denied"});

        }

        const verfified=jwt.verify(token,"passwordKey");
        if(!verfified){
            return res.status(401).json({msg : "Token Verficiaction failed, authorization denied"});
        }
        req.user= verfified.id;
        req.token=token;
        next();
    }catch(e){
        res.status(500).json({error : e.message});
        
    }
};
module.exports = auth;