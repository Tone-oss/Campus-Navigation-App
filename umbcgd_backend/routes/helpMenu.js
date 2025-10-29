const express = require('express');
const router = express.Router();
const mongoose = require('mongoose'); 
const Building = require('../models/Building');

// processes database and returns building with list of services in matching category
function servicesByCategoryPipeline(category) {
  return [
    // turn root document into array [{k: "<key>", v: <value>}, ...]
    { $project: { rootAsArray: { $objectToArray: "$$ROOT" }, Building: 1, buildingId: "$_id" } },

    // unwind so each service-like key becomes a document
    { $unwind: "$rootAsArray" },
    // ignore known top-level fields that are not services
    { $match: { "rootAsArray.k": { $nin: ["_id","Building","Abbreviation","Floors","Description","__v"] } } },
    { $match: { "rootAsArray.v.Category": category } },

    { $group: {
        _id: "$buildingId",
        buildingName: { $first: "$Building" },
        services: { $push: { key: "$rootAsArray.k"} }
        //services: { $push: { key: "$rootAsArray.k", service: "$rootAsArray.v" } }
    }},

    { $project: { _id: 0, buildingId: "$_id", buildingName: 1, services: 1 } }
  ];
}


//after linking database, pull name of buildings within their respective category
router.get('/academic', async (req, res) => {
  try {
    const category = "Academic";
    const pipeline = servicesByCategoryPipeline(category);
    // replace 'buildings' with collection name
    const results = await mongoose.connection.collection('Buildings').aggregate(pipeline).toArray();
    return res.status(200).json(results);
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: 'Server error' });
  }
});

router.get('/administrative', async (req, res) => {
  try {
    const category = "Administrative";
    const pipeline = servicesByCategoryPipeline(category);
    const results = await mongoose.connection.collection('Buildings').aggregate(pipeline).toArray();
    return res.status(200).json(results);
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: 'Server error' });
  }
});

router.get('/financial', async (req, res) => {
  try {
    const category = "Financial";
    const pipeline = servicesByCategoryPipeline(category);
    const results = await mongoose.connection.collection('Buildings').aggregate(pipeline).toArray();
    return res.status(200).json(results);
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: 'Server error' });
  }
});

router.get('/food', async (req, res) => {
  try {
    const category = "Food";
    const pipeline = servicesByCategoryPipeline(category);
    const results = await mongoose.connection.collection('Buildings').aggregate(pipeline).toArray();
    return res.status(200).json(results);
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: 'Server error' });
  }
});

router.get('/health', async (req, res) => {
  try {
    const category = "Health";
    const pipeline = servicesByCategoryPipeline(category);
    const results = await mongoose.connection.collection('Buildings').aggregate(pipeline).toArray();
    return res.status(200).json(results);
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: 'Server error' });
  }
});

router.get('/recreational', async (req, res) => {
  try {
    const category = "Recreational";
    const pipeline = servicesByCategoryPipeline(category);
    const results = await mongoose.connection.collection('Buildings').aggregate(pipeline).toArray();
    return res.status(200).json(results);
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: 'Server error' });
  }
});

router.get('/residential', async (req, res) => {
  
  return res.status(200);
});

router.get('/studentservices', async (req, res) => {
  try {
    const category = "Student Services";
    const pipeline = servicesByCategoryPipeline(category);
    const results = await mongoose.connection.collection('Buildings').aggregate(pipeline).toArray();
    return res.status(200).json(results);
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: 'Server error' });
  }
});


module.exports = router;