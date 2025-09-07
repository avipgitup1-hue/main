const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const Expense = require('../models/Expense');
const Income = require('../models/Income');
const SavingsGoal = require('../models/SavingsGoal');

// Get spending prediction
router.get('/', auth, async (req, res) => {
  try {
    const expenses = await Expense.find({ userId: req.user.id }).sort({ date: -1 }).limit(12);
    const amounts = expenses.map(e => e.amount || 0);
    const avg = amounts.length ? amounts.reduce((s,a)=>s+a,0)/amounts.length : 0;
    const predicted = +(avg * 1.05).toFixed(2); // naive +5%
    res.json({ predictedSpending: predicted, confidence: 0.7 });
  } catch (err) {
    res.status(500).json({ msg: err.message });
  }
});

// Get comprehensive dashboard data
router.get('/dashboard', auth, async (req, res) => {
  try {
    const userId = req.user.id;
    const currentDate = new Date();
    const currentMonth = new Date(currentDate.getFullYear(), currentDate.getMonth(), 1);
    const lastMonth = new Date(currentDate.getFullYear(), currentDate.getMonth() - 1, 1);

    // Current month expenses and income
    const currentMonthExpenses = await Expense.find({
      userId,
      date: { $gte: currentMonth }
    });
    
    const currentMonthIncome = await Income.find({
      userId,
      date: { $gte: currentMonth }
    });

    // Last month for comparison
    const lastMonthExpenses = await Expense.find({
      userId,
      date: { $gte: lastMonth, $lt: currentMonth }
    });

    // Calculate totals
    const currentExpenseTotal = currentMonthExpenses.reduce((sum, exp) => sum + exp.amount, 0);
    const currentIncomeTotal = currentMonthIncome.reduce((sum, inc) => sum + inc.amount, 0);
    const lastExpenseTotal = lastMonthExpenses.reduce((sum, exp) => sum + exp.amount, 0);

    // Category breakdown
    const categoryBreakdown = {};
    currentMonthExpenses.forEach(exp => {
      const category = exp.category || 'Uncategorized';
      categoryBreakdown[category] = (categoryBreakdown[category] || 0) + exp.amount;
    });

    // Savings goals progress
    const savingsGoals = await SavingsGoal.find({ userId });
    const goalsProgress = savingsGoals.map(goal => ({
      id: goal._id,
      title: goal.title,
      progress: goal.targetAmount > 0 ? (goal.currentAmount / goal.targetAmount) * 100 : 0,
      currentAmount: goal.currentAmount,
      targetAmount: goal.targetAmount,
      deadline: goal.deadline
    }));

    // Calculate trends
    const expenseChange = lastExpenseTotal > 0 
      ? ((currentExpenseTotal - lastExpenseTotal) / lastExpenseTotal) * 100 
      : 0;

    // Convert category breakdown to array format expected by Flutter
    const categoryArray = Object.entries(categoryBreakdown).map(([category, amount]) => ({
      category,
      amount: +amount.toFixed(2),
      count: currentMonthExpenses.filter(exp => (exp.category || 'Uncategorized') === category).length,
      percentage: currentExpenseTotal > 0 ? +(amount / currentExpenseTotal * 100).toFixed(2) : 0
    })).sort((a, b) => b.amount - a.amount);

    // Convert transactions to expected format
    const recentTransactions = [
      ...currentMonthExpenses.slice(0, 3).map(exp => ({
        id: exp._id.toString(),
        type: 'expense',
        amount: exp.amount,
        description: exp.description || exp.category,
        date: exp.date,
        category: exp.category
      })),
      ...currentMonthIncome.slice(0, 2).map(inc => ({
        id: inc._id.toString(),
        type: 'income',
        amount: inc.amount,
        description: inc.source,
        date: inc.date,
        category: null
      }))
    ].sort((a, b) => new Date(b.date) - new Date(a.date));

    res.json({
      currentMonth: {
        totalExpenses: +currentExpenseTotal.toFixed(2),
        totalIncome: +currentIncomeTotal.toFixed(2),
        savingsGoalProgress: +(currentIncomeTotal - currentExpenseTotal).toFixed(2),
        transactionCount: currentMonthExpenses.length + currentMonthIncome.length
      },
      previousMonth: {
        totalExpenses: +lastExpenseTotal.toFixed(2),
        totalIncome: 0, // We don't fetch last month income in this simple version
        savingsGoalProgress: 0,
        transactionCount: lastMonthExpenses.length
      },
      categoryBreakdown: categoryArray,
      recentTransactions: recentTransactions
    });
  } catch (err) {
    res.status(500).json({ msg: err.message });
  }
});

// Get spending by category analytics
router.get('/analytics/categories', auth, async (req, res) => {
  try {
    const { months = 3 } = req.query;
    const startDate = new Date();
    startDate.setMonth(startDate.getMonth() - parseInt(months));

    const expenses = await Expense.find({
      userId: req.user.id,
      date: { $gte: startDate }
    });

    const categoryTotals = {};
    expenses.forEach(exp => {
      const category = exp.category || 'Uncategorized';
      categoryTotals[category] = (categoryTotals[category] || 0) + exp.amount;
    });

    const sortedCategories = Object.entries(categoryTotals)
      .sort(([,a], [,b]) => b - a)
      .map(([category, amount]) => ({ category, amount: +amount.toFixed(2) }));

    res.json(sortedCategories);
  } catch (err) {
    res.status(500).json({ msg: err.message });
  }
});

module.exports = router;
