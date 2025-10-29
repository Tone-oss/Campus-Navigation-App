const mongoose = require('mongoose');

const BuildingSchema = new mongoose.Schema({
  Building:    { type: String },
  Abbreviation:{ type: String },
  Floors:      { type: Number },
  Description: { type: String }
}, { strict: false });

//creates a text index for building and abbrev fields to enable $text search
BuildingSchema.index({ Building: 'text', Abbreviation: 'text' });


module.exports = mongoose.model('Building', BuildingSchema, 'Buildings');