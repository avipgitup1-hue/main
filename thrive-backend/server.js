require('dotenv').config();
const express = require('express');
const cors = require('cors');
const morgan = require('morgan');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const connectDB = require('./config/db');
const errorHandler = require('./middleware/errorHandler');

const app = express();
app.use(helmet());
app.use(cors());
app.use(express.json());
app.use(morgan('dev'));

// rate limit (basic)
const limiter = rateLimit({ windowMs: 60*1000, max: 120 });
app.use(limiter);

// connect DB
connectDB(process.env.MONGO_URI);

// routes
app.use('/api/auth', require('./routes/auth'));
app.use('/api/expenses', require('./routes/expenses'));
app.use('/api/incomes', require('./routes/incomes'));
app.use('/api/goals', require('./routes/goals'));
app.use('/api/predict', require('./routes/predict'));
app.use('/api/admin', require('./routes/admin'));

// simple health check
app.get('/', (req, res) => res.json({ ok: true, env: process.env.NODE_ENV || 'dev' }));

// error handler middleware
app.use(errorHandler);

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server running on http://localhost:${PORT}`));
