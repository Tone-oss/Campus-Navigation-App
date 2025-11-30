const express = require('express');
const router = express.Router();
const mongoose = require('mongoose'); 
const Building = require('../models/Building');

// note: if you have time, maybe change search to also match services (tough cus dynamic keys)
// returns list of json objects that matches query term
router.get('/', async (req, res) => {
  const query = req.query.q;

  if (!query) {
    return res.status(400).json({ error: 'no query' });
  }

  try {
    // returns the top 5 closest building matches
    const results = await Building.find(
      { $text: { $search: query } },
      { Building: 1, Coordinates: 1, Abbreviation: 1, Description: 1, Floors: 1} 
    )
    .sort({ score: { $meta: 'textScore' } }) 
    .limit(5)
    .lean();

    res.json(results);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});




module.exports = router;