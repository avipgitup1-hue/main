const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const Income = require('../models/Income');
const Joi = require('joi');

const incomeSchema = Joi.object({
  amount: Joi.number().precision(2).required(),
  source: Joi.string().allow(''),
  date: Joi.date().optional(),
  _id: Joi.string().optional(),
  userId: Joi.string().optional()
}).unknown(true);

// Get all incomes for user
router.get('/', auth, async (req, res) => {
  try {
    const list = await Income.find({ userId: req.user.id }).sort({ date: -1 }).limit(200);
    res.json(list);
  } catch (err) { 
    res.status(500).json({ msg: err.message }); 
  }
});

// Create new income
router.post('/', auth, async (req, res) => {
  try {
    const { error } = incomeSchema.validate(req.body);
    if (error) return res.status(400).json({ msg: error.details[0].message });

    const { amount, source, date } = req.body;
    const income = new Income({ userId: req.user.id, amount, source, date });
    await income.save();
    res.status(201).json(income);
  } catch (err) { 
    res.status(500).json({ msg: err.message }); 
  }
});

// Get specific income
router.get('/:id', auth, async (req, res) => {
  try {
    const income = await Income.findOne({ _id: req.params.id, userId: req.user.id });
    if (!income) return res.status(404).json({ msg: 'Income not found' });
    res.json(income);
  } catch (err) { 
    res.status(500).json({ msg: err.message }); 
  }
});

// Update income
router.put('/:id', auth, async (req, res) => {
  try {
    const { error } = incomeSchema.validate(req.body);
    if (error) return res.status(400).json({ msg: error.details[0].message });

    const income = await Income.findOneAndUpdate(
      { _id: req.params.id, userId: req.user.id },
      { $set: req.body }, 
      { new: true }
    );
    if (!income) return res.status(404).json({ msg: 'Income not found' });
    res.json(income);
  } catch (err) { 
    res.status(500).json({ msg: err.message }); 
  }
});

// Delete income
router.delete('/:id', auth, async (req, res) => {
  try {
    const income = await Income.findOneAndDelete({ _id: req.params.id, userId: req.user.id });
    if (!income) return res.status(404).json({ msg: 'Income not found' });
    res.json({ msg: 'Income deleted successfully' });
  } catch (err) { 
    res.status(500).json({ msg: err.message }); 
  }
});

module.exports = router;