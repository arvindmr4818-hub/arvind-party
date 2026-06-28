// =========================================================================
// MODULE: GAME — CONTROLLER
// =========================================================================


// ─── FROM: game.controller.js ────────────────────────────────────────
const User = require('../../models/User');
const LuckyDrawReward = require('../../models/LuckyDrawReward');

// Cost per spin
const SPIN_COST_COINS = 50;

/**
 * @desc    Get all active rewards for the Lucky Wheel UI
 * @route   GET /api/games/lucky-wheel/rewards
 */
exports.getLuckyWheelRewards = async (req, res) => {
  try {
    const rewards = await LuckyDrawReward.find({ isActive: true })
      .select('_id name type value image probability')
      .lean();
    return res.status(200).json({ success: true, data: rewards });
  } catch (error) {
    console.error('getLuckyWheelRewards Error:', error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

/**
 * @desc    Execute a spin, deduct balance, calculate probability, and award user
 * @route   POST /api/games/lucky-wheel/spin
 */
exports.spinLuckyWheel = async (req, res) => {
  try {
    const userId = req.user.userId;
    const user = await User.findById(userId);

    if (!user) return res.status(404).json({ success: false, message: 'User not found' });
    
    // 1. Check and deduct balance
    if (user.coins < SPIN_COST_COINS) {
      return res.status(400).json({ success: false, message: `Not enough coins. Need ${SPIN_COST_COINS} coins to spin.` });
    }
    user.coins -= SPIN_COST_COINS;

    // 2. Fetch Rewards
    const rewards = await LuckyDrawReward.find({ isActive: true }).lean();
    if (rewards.length === 0) {
      return res.status(400).json({ success: false, message: 'Rewards pool is empty.' });
    }

    // 3. Mathematical Probability Algorithm
    const rand = Math.random();
    let cumulativeProb = 0;
    let selectedReward = rewards[rewards.length - 1]; // Fallback to last item

    for (const reward of rewards) {
      cumulativeProb += reward.probability;
      if (rand <= cumulativeProb) {
        selectedReward = reward;
        break;
      }
    }

    // 4. Grant the reward (Core Inventory/Economy Integration)
    if (selectedReward.type === 'coin') {
      user.coins += selectedReward.value;
    } else if (selectedReward.type === 'diamond') {
      user.diamonds += selectedReward.value;
    }
    // Note: Future logic for 'frame', 'car', 'badge' can insert into an Inventory collection here.

    await user.save();

    // 5. Respond with result
    return res.status(200).json({
      success: true,
      message: `Congratulations! You won ${selectedReward.name}`,
      data: { reward: selectedReward, newBalance: user.coins }
    });
  } catch (error) {
    console.error('spinLuckyWheel Error:', error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

// ─── FROM: gameController.js ────────────────────────────────────────
const User = require('../../models/User');
const GameRecord = require('../../models/GameRecord');
let cron = null;
try {
  cron = require('node-cron');
} catch (e) {
  console.warn('⚠️ node-cron package not available. Weekly champion cron disabled.');
}
const MissionProgress = require('../../models/MissionProgress');

exports.playLuckyWheel = async (req, res) => {
  try {
    const userId = req.user.userId;
    const betAmount = 50; // Cost to spin the wheel

    const user = await User.findById(userId);
    if (!user) return res.status(404).json({ error: 'User not found' });

    if ((user.coins || 0) < betAmount) {
      return res.status(400).json({ success: false, error: 'Insufficient coins to play' });
    }

    // Deduct bet amount
    user.coins -= betAmount;

    // Define Wheel Rewards & Probabilities
    const rewards = [
      { type: 'NOTHING', amount: 0, probability: 40 },
      { type: 'COINS', amount: 20, probability: 30 },
      { type: 'COINS', amount: 100, probability: 20 },
      { type: 'COINS', amount: 500, probability: 8 },
      { type: 'DIAMONDS', amount: 10, probability: 2 }
    ];

    // Random pick based on cumulative probability
    const rand = Math.random() * 100;
    let cumulative = 0;
    let selectedReward = rewards[0];
    for (const reward of rewards) {
      cumulative += reward.probability;
      if (rand <= cumulative) {
        selectedReward = reward;
        break;
      }
    }

    // Credit the won amount securely
    if (selectedReward.type === 'COINS') user.coins += selectedReward.amount;
    if (selectedReward.type === 'DIAMONDS') user.diamonds = (user.diamonds || 0) + selectedReward.amount;
    await user.save();

    // Log the transaction
    await GameRecord.create({
      user: userId,
      gameType: 'LUCKY_WHEEL',
      betAmount,
      winAmount: selectedReward.amount,
      rewardType: selectedReward.type
    });

    // Update Daily Mission Progress
    const today = new Date().toISOString().split('T')[0];
    let progress = await MissionProgress.findOne({ user: userId });
    if (progress) {
      if (progress.lastResetDate !== today) {
        progress.lastResetDate = today; progress.dailyLogin = 1; progress.gamesPlayed = 1; progress.giftsSent = 0; progress.claimedMissions = [];
      } else {
        progress.gamesPlayed += 1;
      }
      await progress.save();
    } else {
      await MissionProgress.create({ user: userId, lastResetDate: today, dailyLogin: 1, gamesPlayed: 1 });
    }

    res.status(200).json({ success: true, reward: selectedReward, balance: { coins: user.coins, diamonds: user.diamonds }});
  } catch (error) {
    console.error('Lucky Wheel Error:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
};

exports.playScratchCard = async (req, res) => {
  try {
    const userId = req.user.userId;
    const betAmount = 20; // Cost to buy a scratch card

    const user = await User.findById(userId);
    if (!user) return res.status(404).json({ error: 'User not found' });

    if ((user.coins || 0) < betAmount) {
      return res.status(400).json({ success: false, error: 'Insufficient coins to play' });
    }

    // Deduct bet amount
    user.coins -= betAmount;

    // Define Scratch Card Rewards & Probabilities
    const rewards = [
      { type: 'NOTHING', amount: 0, probability: 45 },
      { type: 'COINS', amount: 20, probability: 30 }, // Break even
      { type: 'COINS', amount: 50, probability: 15 }, // Small win
      { type: 'COINS', amount: 200, probability: 8 }, // Big win
      { type: 'DIAMONDS', amount: 5, probability: 2 } // Jackpot
    ];

    // Random pick based on cumulative probability
    const rand = Math.random() * 100;
    let cumulative = 0;
    let selectedReward = rewards[0];
    for (const reward of rewards) {
      cumulative += reward.probability;
      if (rand <= cumulative) {
        selectedReward = reward;
        break;
      }
    }

    // Credit the won amount securely
    if (selectedReward.type === 'COINS') user.coins += selectedReward.amount;
    if (selectedReward.type === 'DIAMONDS') user.diamonds = (user.diamonds || 0) + selectedReward.amount;
    await user.save();

    // Log the transaction
    await GameRecord.create({ user: userId, gameType: 'SCRATCH_CARD', betAmount, winAmount: selectedReward.amount, rewardType: selectedReward.type });

    // Update Daily Mission Progress
    const today = new Date().toISOString().split('T')[0];
    let progress = await MissionProgress.findOne({ user: userId });
    if (progress) {
      if (progress.lastResetDate !== today) {
        progress.lastResetDate = today; progress.dailyLogin = 1; progress.gamesPlayed = 1; progress.giftsSent = 0; progress.claimedMissions = [];
      } else {
        progress.gamesPlayed += 1;
      }
      await progress.save();
    } else {
      await MissionProgress.create({ user: userId, lastResetDate: today, dailyLogin: 1, gamesPlayed: 1 });
    }

    res.status(200).json({ success: true, reward: selectedReward, balance: { coins: user.coins, diamonds: user.diamonds }});
  } catch (error) {
    console.error('Scratch Card Error:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
};

exports.getLeaderboard = async (req, res) => {
  try {
    // Calculate the date 7 days ago
    const oneWeekAgo = new Date();
    oneWeekAgo.setDate(oneWeekAgo.getDate() - 7);

    const leaderboard = await GameRecord.aggregate([
      // 1. Match games from the last 7 days where the user actually won coins
      { 
        $match: { 
          createdAt: { $gte: oneWeekAgo },
          winAmount: { $gt: 0 },
          rewardType: 'COINS'
        } 
      },
      // 2. Group by user and sum up their total coins won
      { 
        $group: { 
          _id: '$user', 
          totalWon: { $sum: '$winAmount' } 
        } 
      },
      // 3. Sort descending to get the top winners first
      { $sort: { totalWon: -1 } },
      // 4. Limit to the Top 10 Winners
      { $limit: 10 },
      // 5. Lookup the user's profile information
      { $lookup: { from: 'users', localField: '_id', foreignField: '_id', as: 'userInfo' } },
      // 6. Flatten the userInfo array
      { $unwind: '$userInfo' },
      // 7. Project only the fields we need to send to the frontend app
      { $project: { _id: 1, totalWon: 1, name: '$userInfo.name', avatar: '$userInfo.avatar' } }
    ]);

    res.status(200).json({ success: true, leaderboard });
  } catch (error) {
    console.error('Leaderboard Error:', error);
    res.status(500).json({ error: 'Failed to load leaderboard' });
  }
};

exports.processWeeklyChampion = async (io) => {
  try {
    const oneWeekAgo = new Date();
    oneWeekAgo.setDate(oneWeekAgo.getDate() - 7);

    const leaderboard = await GameRecord.aggregate([
      { 
        $match: { 
          createdAt: { $gte: oneWeekAgo },
          winAmount: { $gt: 0 },
          rewardType: 'COINS'
        } 
      },
      { 
        $group: { 
          _id: '$user', 
          totalWon: { $sum: '$winAmount' } 
        } 
      },
      { $sort: { totalWon: -1 } },
      { $limit: 1 } // Only fetch the #1 player!
    ]);

    if (leaderboard.length > 0) {
      const topPlayerId = leaderboard[0]._id;
      
      // Safely award the badge without duplicates using $addToSet
      // (Note: ensure 'unlockedBadges' matches the actual array field in your User Schema)
      await User.findByIdAndUpdate(topPlayerId, {
        $addToSet: { unlockedBadges: 'WEEKLY_CHAMPION_BADGE_ID' }
      });
      
      console.log(`🏆 Weekly Champion Badge awarded to user ID: ${topPlayerId}`);

      // Emit real-time notification to the app via Socket.IO
      if (io) {
        io.emit('badge_unlocked', { userId: topPlayerId, badgeId: 'WEEKLY_CHAMPION_BADGE_ID' });
      }
    }
  } catch (error) {
    console.error('Weekly Champion Cron Error:', error);
  }
};

exports.initGameCronJobs = (io) => {
  // Runs every Sunday at 23:59 (11:59 PM)
  cron.schedule('59 23 * * 0', async () => {
    console.log('Running Weekly Champion Cron Job...');
    await exports.processWeeklyChampion(io);
  });
};

// ─── FROM: webViewGameController.js ────────────────────────────────────────
const mongoose = require('mongoose');
const WebViewGame = require('../../models/WebViewGame');
const GameRecord = require('../../models/GameRecord');
const User = require('../../models/User');
const WalletTransaction = require('../../models/WalletTransaction');

exports.getAllGames = async (req, res) => {
  try {
    const { gameType, isActive, page = 1, limit = 20 } = req.query;
    const filter = {};
    if (gameType) filter.gameType = gameType;
    if (isActive !== undefined) filter.isActive = isActive === 'true';

    const games = await WebViewGame.find(filter)
      .sort({ createdAt: -1 })
      .skip((page - 1) * limit)
      .limit(parseInt(limit))
      .populate('createdBy', 'name uid');

    const total = await WebViewGame.countDocuments(filter);

    return res.status(200).json({
      success: true,
      data: games,
      pagination: { page: parseInt(page), limit: parseInt(limit), total, pages: Math.ceil(total / limit) }
    });
  } catch (error) {
    console.error('Fetch Games Error:', error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

exports.getActiveGames = async (req, res) => {
  try {
    const games = await WebViewGame.find({ isActive: true }).select('-createdBy').sort({ createdAt: -1 });
    return res.status(200).json({ success: true, data: games });
  } catch (error) {
    console.error('Fetch Active Games Error:', error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

exports.getGameById = async (req, res) => {
  try {
    const { gameId } = req.params;
    const game = await WebViewGame.findById(gameId).populate('createdBy', 'name uid');
    if (!game) return res.status(404).json({ success: false, message: 'Game not found' });
    return res.status(200).json({ success: true, data: game });
  } catch (error) {
    console.error('Fetch Game Error:', error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

exports.createGame = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { name, description, gameType, gameUrl, thumbnailUrl, minBetAmount, maxBetAmount, houseEdgePercentage, rewardType, coinToDiamondRatio, diamondToCoinRatio, tags, configuration } = req.body;

    if (!name || !gameType || !gameUrl) {
      return res.status(400).json({ success: false, message: 'Name, gameType, and gameUrl are required' });
    }

    const validGameTypes = ['RENTED', 'IN_HOUSE', 'WEB_BASED'];
    if (!validGameTypes.includes(gameType)) {
      return res.status(400).json({ success: false, message: 'Invalid gameType. Must be RENTED, IN_HOUSE, or WEB_BASED' });
    }

    const validRewardTypes = ['COINS', 'DIAMONDS', 'BOTH'];
    if (rewardType && !validRewardTypes.includes(rewardType)) {
      return res.status(400).json({ success: false, message: 'Invalid rewardType' });
    }

    const game = await WebViewGame.create({
      name,
      description: description || '',
      gameType,
      gameUrl,
      thumbnailUrl: thumbnailUrl || '',
      minBetAmount: minBetAmount || 10,
      maxBetAmount: maxBetAmount || 10000,
      houseEdgePercentage: houseEdgePercentage || 5,
      rewardType: rewardType || 'COINS',
      coinToDiamondRatio: coinToDiamondRatio || 100,
      diamondToCoinRatio: diamondToCoinRatio || 0.01,
      createdBy: userId,
      tags: tags || [],
      configuration: configuration || {}
    });

    return res.status(201).json({ success: true, message: 'Game created successfully', data: game });
  } catch (error) {
    console.error('Create Game Error:', error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

exports.updateGame = async (req, res) => {
  try {
    const { gameId } = req.params;
    const updates = req.body;

    const game = await WebViewGame.findById(gameId);
    if (!game) return res.status(404).json({ success: false, message: 'Game not found' });

    if (updates.gameType && !['RENTED', 'IN_HOUSE', 'WEB_BASED'].includes(updates.gameType)) {
      return res.status(400).json({ success: false, message: 'Invalid gameType' });
   }

    if (updates.rewardType && !['COINS', 'DIAMONDS', 'BOTH'].includes(updates.rewardType)) {
      return res.status(400).json({ success: false, message: 'Invalid rewardType' });
    }

    Object.assign(game, updates);
    await game.save();

    return res.status(200).json({ success: true, message: 'Game updated successfully', data: game });
  } catch (error) {
    console.error('Update Game Error:', error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

exports.deleteGame = async (req, res) => {
  try {
    const { gameId } = req.params;
    const game = await WebViewGame.findById(gameId);
    if (!game) return res.status(404).json({ success: false, message: 'Game not found' });

    game.isActive = false;
    await game.save();

    return res.status(200).json({ success: true, message: 'Game deactivated successfully' });
  } catch (error) {
    console.error('Delete Game Error:', error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

exports.startGameSession = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { gameId, betAmount } = req.body;

    if (!gameId || !betAmount || betAmount <= 0) {
      return res.status(400).json({ success: false, message: 'gameId and valid betAmount are required' });
    }

    const user = await User.findById(userId);
    if (!user) return res.status(404).json({ success: false, message: 'User not found' });

    const game = await WebViewGame.findById(gameId);
    if (!game) return res.status(404).json({ success: false, message: 'Game not found' });
    if (!game.isActive) return res.status(400).json({ success: false, message: 'Game is not active' });

    if (betAmount < game.minBetAmount || betAmount > game.maxBetAmount) {
      return res.status(400).json({ success: false, message: `Bet amount must be between ${game.minBetAmount} and ${game.maxBetAmount}` });
    }

    const currentCoins = user.coins || 0;
    if (currentCoins < betAmount) {
      return res.status(400).json({ success: false, message: 'Insufficient coins', balance: { coins: currentCoins } });
    }

    user.coins -= betAmount;
    await user.save();

    const gameSession = await GameRecord.create({
      user: userId,
      gameType: `WEBVIEW_${game.gameType}`,
      betAmount: betAmount,
      winAmount: 0,
      rewardType: game.rewardType,
      gameId: gameId
    });

    game.totalPlays += 1;
    game.totalVolume += betAmount;
    await game.save();

    return res.status(200).json({
      success: true,
      message: 'Game session started',
      sessionId: gameSession._id,
      gameUrl: game.gameUrl,
      balance: { coins: user.coins, diamonds: user.diamonds || 0 },
      configuration: game.configuration,
      rewardType: game.rewardType,
      coinToDiamondRatio: game.coinToDiamondRatio,
      diamondToCoinRatio: game.diamondToCoinRatio
    });
  } catch (error) {
    console.error('Start Game Session Error:', error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

exports.endGameSession = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { sessionId, winAmount } = req.body;

    if (!sessionId || !winAmount || winAmount < 0) {
      return res.status(400).json({ success: false, message: 'sessionId and winAmount are required' });
    }

    const gameSession = await GameRecord.findById(sessionId);
    if (!gameSession) return res.status(404).json({ success: false, message: 'Game session not found' });
    if (gameSession.user.toString() !== userId) {
      return res.status(403).json({ success: false, message: 'Unauthorized' });
    }
    if (gameSession.winAmount > 0) {
      return res.status(400).json({ success: false, message: 'Session already ended' });
    }

    const user = await User.findById(userId);
    const game = await WebViewGame.findById(gameSession.gameId);

    if (!user || !game) {
      return res.status(404).json({ success: false, message: 'User or Game not found' });
    }

    gameSession.winAmount = winAmount;
    gameSession.rewardType = game.rewardType;

    if (winAmount > 0) {
      if (game.rewardType === 'COINS' || game.rewardType === 'BOTH') {
        user.coins += winAmount;
      }
      if (game.rewardType === 'DIAMONDS' || game.rewardType === 'BOTH') {
        const diamondAmount = game.rewardType === 'BOTH'
          ? Math.floor(winAmount / game.coinToDiamondRatio)
          : winAmount;
        user.diamonds = (user.diamonds || 0) + diamondAmount;
      }
      game.totalWinnings += winAmount;
    }

    await user.save();
    await gameSession.save();
    await game.save();

    return res.status(200).json({
      success: true,
      message: 'Game session ended',
      balance: { coins: user.coins, diamonds: user.diamonds || 0 },
      won: winAmount > 0,
      winAmount
    });
  } catch (error) {
    console.error('End Game Session Error:', error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

exports.getGameLedger = async (req, res) => {
  try {
    const adminUserId = req.user.userId;
    const user = await User.findById(adminUserId);
    if (!user || user.role !== 'admin') {
      return res.status(403).json({ success: false, message: 'Admin access required' });
    }

    const { gameId, startDate, endDate, page = 1, limit = 50 } = req.query;
    const filter = {};

    if (gameId) filter.gameId = gameId;
    if (startDate || endDate) {
      filter.createdAt = {};
      if (startDate) filter.createdAt.$gte = new Date(startDate);
      if (endDate) filter.createdAt.$lte = new Date(endDate);
    }

    const sessions = await GameRecord.find(filter)
      .populate('user', 'name uid avatar')
      .populate('gameId', 'name gameType')
      .sort({ createdAt: -1 })
      .skip((page - 1) * limit)
      .limit(parseInt(limit));

    const totalVolumeResult = await GameRecord.aggregate([
      { $match: filter },
      { $group: { _id: null, totalVolume: { $sum: '$betAmount' }, totalWinnings: { $sum: '$winAmount' }, totalSessions: { $sum: 1 } } }
    ]);

    const totalVolume = totalVolumeResult.length > 0 ? totalVolumeResult[0] : { totalVolume: 0, totalWinnings: 0, totalSessions: 0 };
    const netProfit = totalVolume.totalVolume - totalVolume.totalWinnings;

    return res.status(200).json({
      success: true,
      data: sessions,
      summary: { totalVolume: totalVolume.totalVolume, totalWinnings: totalVolume.totalWinnings, netProfit, totalSessions: totalVolume.totalSessions }
    });
  } catch (error) {
    console.error('Get Game Ledger Error:', error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

exports.getGameLeaderboard = async (req, res) => {
  try {
    const { period = 'weekly', gameId, limit = 50 } = req.query;

    let dateFilter = {};
    const now = new Date();
    if (period === 'daily') {
      dateFilter.$gte = new Date(now.setHours(0, 0, 0, 0));
    } else if (period === 'weekly') {
      dateFilter.$gte = new Date(now.setDate(now.getDate() - 7));
    } else if (period === 'monthly') {
      dateFilter.$gte = new Date(now.setMonth(now.getMonth() - 1));
    }

    const matchFilter = {
      createdAt: dateFilter,
      winAmount: { $gt: 0 },
      gameType: { $regex: /^WEBVIEW_/ }
    };
    if (gameId) matchFilter.gameId = mongoose.Types.ObjectId(gameId);

    const leaderboard = await GameRecord.aggregate([
      { $match: matchFilter },
      { $group: { _id: '$user', totalWon: { $sum: '$winAmount' }, sessionsPlayed: { $sum: 1 } } },
      { $sort: { totalWon: -1 } },
      { $limit: parseInt(limit) },
      { $lookup: { from: 'users', localField: '_id', foreignField: '_id', as: 'userInfo' } },
      { $unwind: '$userInfo' },
      { $project: { _id: 1, totalWon: 1, sessionsPlayed: 1, name: '$userInfo.name', avatar: '$userInfo.avatar', uid: '$userInfo.uid' } }
    ]);

    return res.status(200).json({ success: true, leaderboard, period });
  } catch (error) {
    console.error('Get Game Leaderboard Error:', error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

// ─── FROM: cpController.js ────────────────────────────────────────
const CpPair = require('../../models/CpPair');
const User = require('../../models/User');

exports.getMyCp = async (req, res) => {
  try {
    const userId = req.user.id || req.user.userId;
    
    // Find any active CP relationship for this user
    const cpData = await CpPair.findOne({
      $or: [{ user1Id: userId }, { user2Id: userId }],
      isActive: true
    }).populate('user1Id', 'name avatar').populate('user2Id', 'name avatar');

    if (!cpData) {
      return res.status(200).json({ success: true, cpPair: null, message: "No active CP relationship" });
    }

    res.status(200).json({ success: true, cpPair: cpData });
  } catch (error) {
    console.error('Get CP Error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch CP details' });
  }
};

exports.bindCp = async (req, res) => {
  try {
    const { targetUserId } = req.body;
    const userId = req.user.id || req.user.userId;

    // In production: Create a CP Request, then target user accepts it.
    // For now, we directly bind them to replace the fake data immediately.
    const newCp = await CpPair.create({ user1Id: userId, user2Id: targetUserId });
    res.status(201).json({ success: true, cpPair: newCp, message: "Successfully bound as CP!" });
  } catch (error) {
    console.error('Bind CP Error:', error);
    res.status(500).json({ success: false, message: 'Failed to bind CP' });
  }
};