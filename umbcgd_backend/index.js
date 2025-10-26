const express = require('express')
const helmet = require('helmet');
const cors = require('cors');
const helpRoutes = require('./routes/helpMenu');

const app = express()

app.use(helmet());
app.use(cors());
app.use('/helpmenu', helpRoutes);

//app.get .post .delete .put .patch
app.get('/', (req, res) => {
    console.log("HERE")
    //super generic, not used often
    res.sendStatus(200).json({message: "umm"})
    
})

app.listen(3000)