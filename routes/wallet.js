const express = require('express');
const router = express.Router();
const walletController = require('../controllers/walletController');
const { attachUser, requireAuth } = require('../middleware/auth');

// Apply authentication middleware to all routes
router.use(attachUser);
router.use(requireAuth);

// Get wallet balance
router.get('/balance', walletController.getWalletBalance);

// Get wallet details
router.get('/details', walletController.getWalletDetails);

// Create deposit intent
router.post('/deposit/create', walletController.createDepositIntent);

// Verify payment
router.post('/deposit/verify', walletController.verifyPayment);

// Get wallet transactions
router.get('/transactions', walletController.getTransactions);

// Request settlement/withdrawal
router.post('/settlement/request', walletController.requestSettlement);

// Get settlement history
router.get('/settlements', walletController.getSettlements);

module.exports = router;
