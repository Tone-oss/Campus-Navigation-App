require('dotenv').config();
const express = require('express')
const helmet = require('helmet');
const mongoose = require('mongoose');
const cors = require('cors');
const helpRoutes = require('./routes/helpMenu');

const app = express()

// middlewares for safety, cross origin comms, json parsing etc.
app.use(helmet());
app.use(cors());
app.use(express.json());
app.use('/helpmenu', helpRoutes);


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

const BuildingSchema = new mongoose.Schema({
  Building:    { type: String },
  Abbreviation:{ type: String },
  Floors:      { type: Number },
  Description: { type: String }
}, { strict: false });

// add mongodb collection name to third field
const Building = mongoose.model('Building', BuildingSchema, 'Buildings');


app.listen(3000)