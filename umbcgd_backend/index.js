require('dotenv').config();
const express = require('express')
const helmet = require('helmet');
const mongoose = require('mongoose');
const cors = require('cors');
const Building = require('./models/Building');
const helpRoutes = require('./routes/helpMenu');
const searchRoute = require('./routes/search');

const app = express()

// middlewares for safety, cross origin comms, json parsing etc.
app.use(helmet());
app.use(cors());
app.use(express.json());
app.use('/helpmenu', helpRoutes);
app.use('/search', searchRoute);

const uri = process.env.MONGODB_URI;
mongoose.set('strictQuery', false);

// conencting to mongodb atlas
mongoose.connect(uri, { useNewUrlParser: true, useUnifiedTopology: true })
  .then(() => {console.log('Connected to MongoDB Atlas')
    console.log('Database:', mongoose.connection.db.databaseName);
  })
  .catch(err => {
    console.error('MongoDB connection error:', err);
    process.exit(1);
});



app.listen(3000)