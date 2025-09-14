const express = require('express');
const router = express.Router();
const adminAuth = require('../middleware/adminAuth');
const User = require('../models/User');
const Expense = require('../models/Expense');
const Income = require('../models/Income');
const SavingsGoal = require('../models/SavingsGoal');
const bcrypt = require('bcryptjs');

// Get all users (admin only)
router.get('/users', adminAuth, async (req, res) => {
  try {
    const users = await User.find({}).select('-passwordHash').sort({ createdAt: -1 });
    res.json(users);
  } catch (err) {
    res.status(500).json({ msg: err.message });
  }
});

// Get user statistics (admin only)
router.get('/stats', adminAuth, async (req, res) => {
  try {
    const totalUsers = await User.countDocuments();
    const totalExpenses = await Expense.countDocuments();
    const totalIncomes = await Income.countDocuments();
    const totalGoals = await SavingsGoal.countDocuments();
    
    const totalExpenseAmount = await Expense.aggregate([
      { $group: { _id: null, total: { $sum: '$amount' } } }
    ]);
    
    const totalIncomeAmount = await Income.aggregate([
      { $group: { _id: null, total: { $sum: '$amount' } } }
    ]);

    res.json({
      totalUsers,
      totalExpenses,
      totalIncomes,
      totalGoals,
      totalExpenseAmount: totalExpenseAmount[0]?.total || 0,
      totalIncomeAmount: totalIncomeAmount[0]?.total || 0
    });
  } catch (err) {
    res.status(500).json({ msg: err.message });
  }
});

// Get all expenses (admin only)
router.get('/expenses', adminAuth, async (req, res) => {
  try {
    const expenses = await Expense.find({})
      .populate('userId', 'name email')
      .sort({ date: -1 })
      .limit(500);
    res.json(expenses);
  } catch (err) {
    res.status(500).json({ msg: err.message });
  }
});

// Get all incomes (admin only)
router.get('/incomes', adminAuth, async (req, res) => {
  try {
    const incomes = await Income.find({})
      .populate('userId', 'name email')
      .sort({ date: -1 })
      .limit(500);
    res.json(incomes);
  } catch (err) {
    res.status(500).json({ msg: err.message });
  }
});

// Get all savings goals (admin only)
router.get('/goals', adminAuth, async (req, res) => {
  try {
    const goals = await SavingsGoal.find({})
      .populate('userId', 'name email')
      .sort({ deadline: 1 });
    res.json(goals);
  } catch (err) {
    res.status(500).json({ msg: err.message });
  }
});

// Delete user (admin only)
router.delete('/users/:id', adminAuth, async (req, res) => {
  try {
    const user = await User.findById(req.params.id);
    if (!user) {
      return res.status(404).json({ msg: 'User not found' });
    }

    // Delete all user data
    await Expense.deleteMany({ userId: req.params.id });
    await Income.deleteMany({ userId: req.params.id });
    await SavingsGoal.deleteMany({ userId: req.params.id });
    await User.findByIdAndDelete(req.params.id);

    res.json({ msg: 'User and all associated data deleted successfully' });
  } catch (err) {
    res.status(500).json({ msg: err.message });
  }
});

// Make user admin (admin only)
router.patch('/users/:id/make-admin', adminAuth, async (req, res) => {
  try {
    const user = await User.findByIdAndUpdate(
      req.params.id,
      { isAdmin: true },
      { new: true }
    ).select('-passwordHash');
    
    if (!user) {
      return res.status(404).json({ msg: 'User not found' });
    }

    res.json(user);
  } catch (err) {
    res.status(500).json({ msg: err.message });
  }
});

// Remove admin privileges (admin only)
router.patch('/users/:id/remove-admin', adminAuth, async (req, res) => {
  try {
    const user = await User.findByIdAndUpdate(
      req.params.id,
      { isAdmin: false },
      { new: true }
    ).select('-passwordHash');
    
    if (!user) {
      return res.status(404).json({ msg: 'User not found' });
    }

    res.json(user);
  } catch (err) {
    res.status(500).json({ msg: err.message });
  }
});

// Create admin user (for initial setup)
router.post('/create-admin', async (req, res) => {
  try {
    const { email, password, name } = req.body;
    
    // Check if any admin exists
    const existingAdmin = await User.findOne({ isAdmin: true });
    if (existingAdmin) {
      return res.status(400).json({ msg: 'Admin already exists' });
    }

    // Check if user already exists
    let user = await User.findOne({ email });
    if (user) {
      return res.status(400).json({ msg: 'Email already registered' });
    }

    const salt = await bcrypt.genSalt(10);
    const hash = await bcrypt.hash(password, salt);
    
    user = new User({ 
      name: name || 'Admin',
      email, 
      passwordHash: hash,
      isAdmin: true
    });
    
    await user.save();
    res.json({ msg: 'Admin user created successfully', user: { id: user._id, name: user.name, email: user.email, isAdmin: user.isAdmin } });
  } catch (err) {
    res.status(500).json({ msg: err.message });
  }
});

module.exports = router;
