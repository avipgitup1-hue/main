const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const SavingsGoal = require('../models/SavingsGoal');
const Joi = require('joi');

const goalSchema = Joi.object({
  title: Joi.string().required(),
  targetAmount: Joi.number().precision(2).required(),
  currentAmount: Joi.number().precision(2).optional(),
  deadline: Joi.date().optional(),
  _id: Joi.string().optional(),
  userId: Joi.string().optional()
}).unknown(true);

// Get all savings goals for user
router.get('/', auth, async (req, res) => {
  try {
    const goals = await SavingsGoal.find({ userId: req.user.id }).sort({ deadline: 1 });
    res.json(goals);
  } catch (err) { 
    res.status(500).json({ msg: err.message }); 
  }
});

// Create new savings goal
router.post('/', auth, async (req, res) => {
  try {
    const { error } = goalSchema.validate(req.body);
    if (error) return res.status(400).json({ msg: error.details[0].message });

    const { title, targetAmount, currentAmount, deadline } = req.body;
    const goal = new SavingsGoal({ 
      userId: req.user.id, 
      title, 
      targetAmount, 
      currentAmount: currentAmount || 0, 
      deadline 
    });
    await goal.save();
    res.status(201).json(goal);
  } catch (err) { 
    res.status(500).json({ msg: err.message }); 
  }
});

// Get specific savings goal
router.get('/:id', auth, async (req, res) => {
  try {
    const goal = await SavingsGoal.findOne({ _id: req.params.id, userId: req.user.id });
    if (!goal) return res.status(404).json({ msg: 'Savings goal not found' });
    res.json(goal);
  } catch (err) { 
    res.status(500).json({ msg: err.message }); 
  }
});

// Update savings goal
router.put('/:id', auth, async (req, res) => {
  try {
    const { error } = goalSchema.validate(req.body);
    if (error) return res.status(400).json({ msg: error.details[0].message });

    const goal = await SavingsGoal.findOneAndUpdate(
      { _id: req.params.id, userId: req.user.id },
      { $set: req.body }, 
      { new: true }
    );
    if (!goal) return res.status(404).json({ msg: 'Savings goal not found' });
    res.json(goal);
  } catch (err) { 
    res.status(500).json({ msg: err.message }); 
  }
});

// Add money to savings goal
router.patch('/:id/add', auth, async (req, res) => {
  try {
    const { amount } = req.body;
    if (!amount || amount <= 0) {
      return res.status(400).json({ msg: 'Amount must be positive' });
    }

    const goal = await SavingsGoal.findOne({ _id: req.params.id, userId: req.user.id });
    if (!goal) return res.status(404).json({ msg: 'Savings goal not found' });

    goal.currentAmount += amount;
    await goal.save();
    res.json(goal);
  } catch (err) { 
    res.status(500).json({ msg: err.message }); 
  }
});

// Delete savings goal
router.delete('/:id', auth, async (req, res) => {
  try {
    const goal = await SavingsGoal.findOneAndDelete({ _id: req.params.id, userId: req.user.id });
    if (!goal) return res.status(404).json({ msg: 'Savings goal not found' });
    res.json({ msg: 'Savings goal deleted successfully' });
  } catch (err) { 
    res.status(500).json({ msg: err.message }); 
  }
});

module.exports = router;