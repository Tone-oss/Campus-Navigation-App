const express = require('express');
const router = express.Router();

//after linking database, pull name of buildings within their respective category
router.get('/academic', (req, res) => {
  res.status(200).json([{Name: "building1", message2: "library2", whatever3: "rac" }]);
});

router.get('/administrative', (req, res) => {
  res.status(200).json({message: "placeholder"});
});

router.get('/financial', (req, res) => {
  res.status(200).json({message: "placeholder"});
});

router.get('/food', (req, res) => {
  res.status(200).json({message: "placeholder"});
});

router.get('/health', (req, res) => {
  res.status(200).json({message: "placeholder"});
});

router.get('/recreational', (req, res) => {
  res.status(200).json({message: "placeholder"});
});

router.get('/residential', (req, res) => {
  res.status(200).json({message: "placeholder"});
});

router.get('/studentservices', (req, res) => {
  res.status(200).json({message: "placeholder"});
});


module.exports = router;