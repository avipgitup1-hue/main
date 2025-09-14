const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const Expense = require('../models/Expense');
const Joi = require('joi');

const expenseSchema = Joi.object({
  amount: Joi.number().precision(2).required(),
  category: Joi.string().allow(''),
  date: Joi.date().optional(),
  description: Joi.string().allow(''),
  _id: Joi.string().optional(),
  userId: Joi.string().optional()
}).unknown(true);

router.get('/', auth, async (req, res) => {
  try {
    const list = await Expense.find({ userId: req.user.id }).sort({ date: -1 }).limit(200);
    res.json(list);
  } catch (err) { res.status(500).json({ msg: err.message }); }
});

router.post('/', auth, async (req, res) => {
  try {
    const { error } = expenseSchema.validate(req.body);
    if (error) return res.status(400).json({ msg: error.details[0].message });

    const { amount, category, date, description } = req.body;
    const ex = new Expense({ userId: req.user.id, amount, category, date, description });
    await ex.save();
    res.status(201).json(ex);
  } catch (err) { res.status(500).json({ msg: err.message }); }
});

router.get('/:id', auth, async (req, res) => {
  try {
    const ex = await Expense.findOne({ _id: req.params.id, userId: req.user.id });
    if (!ex) return res.status(404).json({ msg: 'Not found' });
    res.json(ex);
  } catch (err) { res.status(500).json({ msg: err.message }); }
});

router.put('/:id', auth, async (req, res) => {
  try {
    const { error } = expenseSchema.validate(req.body);
    if (error) return res.status(400).json({ msg: error.details[0].message });

    const ex = await Expense.findOneAndUpdate(
      { _id: req.params.id, userId: req.user.id },
      { $set: req.body }, { new: true }
    );
    if (!ex) return res.status(404).json({ msg: 'Not found' });
    res.json(ex);
  } catch (err) { res.status(500).json({ msg: err.message }); }
});

router.delete('/:id', auth, async (req, res) => {
  try {
    const ex = await Expense.findOneAndDelete({ _id: req.params.id, userId: req.user.id });
    if (!ex) return res.status(404).json({ msg: 'Not found' });
    res.json({ msg: 'Deleted' });
  } catch (err) { res.status(500).json({ msg: err.message }); }
});

module.exports = router;
