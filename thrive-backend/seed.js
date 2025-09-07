require('dotenv').config();
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const connectDB = require('./config/db');
const User = require('./models/User');
const Expense = require('./models/Expense');
const Income = require('./models/Income');
const SavingsGoal = require('./models/SavingsGoal');

const run = async () => {
  await connectDB(process.env.MONGO_URI);

  // Clear existing sample data (CAUTION)
  await User.deleteMany({});
  await Expense.deleteMany({});
  await Income.deleteMany({});
  await SavingsGoal.deleteMany({});

  const pw = 'pass123';
  const hash = await bcrypt.hash(pw, 10);
  const user = new User({ name: 'Sample User', email: 'sample@thrive.app', passwordHash: hash });
  await user.save();

  // Sample expenses with varied dates
  const currentDate = new Date();
  const sampleExpenses = [
    { userId: user._id, amount: 12.5, category: 'Food', description: 'Coffee', date: new Date(currentDate.getTime() - 1 * 24 * 60 * 60 * 1000) },
    { userId: user._id, amount: 45.00, category: 'Transport', description: 'Train ticket', date: new Date(currentDate.getTime() - 2 * 24 * 60 * 60 * 1000) },
    { userId: user._id, amount: 120.00, category: 'Groceries', description: 'Weekly shop', date: new Date(currentDate.getTime() - 3 * 24 * 60 * 60 * 1000) },
    { userId: user._id, amount: 25.99, category: 'Entertainment', description: 'Movie tickets', date: new Date(currentDate.getTime() - 5 * 24 * 60 * 60 * 1000) },
    { userId: user._id, amount: 89.50, category: 'Utilities', description: 'Electricity bill', date: new Date(currentDate.getTime() - 7 * 24 * 60 * 60 * 1000) },
    { userId: user._id, amount: 15.75, category: 'Food', description: 'Lunch', date: new Date(currentDate.getTime() - 10 * 24 * 60 * 60 * 1000) }
  ];

  // Sample income
  const sampleIncome = [
    { userId: user._id, amount: 3500.00, source: 'Salary', date: new Date(currentDate.getTime() - 5 * 24 * 60 * 60 * 1000) },
    { userId: user._id, amount: 250.00, source: 'Freelance', date: new Date(currentDate.getTime() - 15 * 24 * 60 * 60 * 1000) },
    { userId: user._id, amount: 50.00, source: 'Investment', date: new Date(currentDate.getTime() - 20 * 24 * 60 * 60 * 1000) }
  ];

  // Sample savings goals
  const sampleGoals = [
    { 
      userId: user._id, 
      title: 'Emergency Fund', 
      targetAmount: 5000.00, 
      currentAmount: 1250.00,
      deadline: new Date(currentDate.getTime() + 365 * 24 * 60 * 60 * 1000) // 1 year from now
    },
    { 
      userId: user._id, 
      title: 'Vacation', 
      targetAmount: 2000.00, 
      currentAmount: 450.00,
      deadline: new Date(currentDate.getTime() + 180 * 24 * 60 * 60 * 1000) // 6 months from now
    },
    { 
      userId: user._id, 
      title: 'New Laptop', 
      targetAmount: 1500.00, 
      currentAmount: 300.00,
      deadline: new Date(currentDate.getTime() + 90 * 24 * 60 * 60 * 1000) // 3 months from now
    }
  ];

  await Expense.insertMany(sampleExpenses);
  await Income.insertMany(sampleIncome);
  await SavingsGoal.insertMany(sampleGoals);
  
  console.log('Seed complete with comprehensive sample data!');
  console.log('Login credentials: sample@thrive.app / pass123');
  console.log(`Created ${sampleExpenses.length} expenses, ${sampleIncome.length} income entries, and ${sampleGoals.length} savings goals`);
  process.exit(0);
};

run().catch(err => { console.error(err); process.exit(1); });
