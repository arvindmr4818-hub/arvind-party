// =========================================================================
// MODULE: REFERRAL — CONTROLLER
// =========================================================================


// ─── FROM: referralController.js ────────────────────────────────────────
const User = require('../../models/User');

// GET /api/system/referral
exports.getReferralInfo = async (req, res) => {
  try {
    const userId = req.user?.id || req.query.userId;
    if (!userId) return res.status(401).json({ success: false, message: 'Unauthorized' });

    const user = await User.findById(userId).select('referralCode referralCount referralRewards');
    res.json({
      success: true,
      referralLink: `https://arvindparty.com/invite/${user?.referralCode || userId}`,
      referralCode: user?.referralCode || userId?.toString().slice(-6),
      totalReferrals: user?.referralCount || 0,
      totalRewards: user?.referralRewards || 0,
      pendingRewards: 0,
    });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

// POST /api/system/referral/claim
exports.claimReward = async (req, res) => {
  try {
    const userId = req.user?.id || req.body.userId;
    if (!userId) return res.status(401).json({ success: false, message: 'Unauthorized' });

    const reward = 100;
    await User.findByIdAndUpdate(userId, { $inc: { coins: reward } });
    res.json({ success: true, reward, message: 'Reward claimed!' });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

// ─── FROM: loginStreakController.js ────────────────────────────────────────
const LoginStreak = require('../../models/LoginStreak');
const User = require('../../models/User');

// ─── GET USER LOGIN STREAK ────────────────────────────────────────────
exports.getLoginStreak = async (req, res) => {
  try {
    const userId = req.user.userId;
    let streak = await LoginStreak.findOne({ userId });
    if (!streak) {
      streak = await LoginStreak.create({ userId });
    }
    res.status(200).json({ success: true, data: streak });
  } catch (error) {
    console.error('Get LoginStreak Error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch login streak' });
  }
};

// ─── CLAIM DAILY LOGIN (Called on app open) ────────────────────────────
exports.claimDailyLogin = async (req, res) => {
  try {
    const userId = req.user.userId;
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    let streak = await LoginStreak.findOne({ userId });
    if (!streak) {
      streak = await LoginStreak.create({ userId });
    }

    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const lastLogin = streak.last_login_date ? new Date(streak.last_login_date) : null;

    // Check if already claimed today
    if (lastLogin) {
      const lastLoginDay = new Date(lastLogin);
      lastLoginDay.setHours(0, 0, 0, 0);
      if (lastLoginDay.getTime() === today.getTime()) {
        return res.status(200).json({
          success: true,
          data: streak,
          already_claimed_today: true,
          message: 'Already claimed today\'s login reward'
        });
      }
    }

    // Calculate streak
    let newStreak = 1;
    if (lastLogin) {
      const yesterday = new Date(today);
      yesterday.setDate(yesterday.getDate() - 1);
      const lastLoginDay = new Date(lastLogin);
      lastLoginDay.setHours(0, 0, 0, 0);

      if (lastLoginDay.getTime() === yesterday.getTime()) {
        newStreak = streak.current_streak + 1;
      } else if (lastLoginDay.getTime() < yesterday.getTime()) {
        newStreak = 1; // Streak broken
      }
    }

    streak.current_streak = newStreak;
    if (newStreak > streak.longest_streak) {
      streak.longest_streak = newStreak;
    }
    streak.last_login_date = today;
    streak.total_logins += 1;

    // Determine reward based on streak day
    let rewardCoins = 0;
    let rewardDiamonds = 0;
    let rewardXp = 0;
    let rewardType = 'daily_login';
    let specialReward = null;

    const dayKey = `day_${Math.min(newStreak, 30)}`;
    const dayRewards = streak.daily_rewards[dayKey] || streak.daily_rewards.day_1;

    rewardCoins = dayRewards?.coins || 10;
    rewardDiamonds = dayRewards?.diamonds || 0;
    rewardXp = dayRewards?.xp || 5;

    // Special milestone rewards
    if (newStreak === 7 && !streak.day_7_reward_claimed) {
      streak.day_7_reward_claimed = true;
      rewardCoins += 100;
      rewardDiamonds += 10;
      rewardXp += 50;
      rewardType = '7_day_streak';
    }

    if (newStreak === 30 && !streak.day_30_reward_claimed) {
      streak.day_30_reward_claimed = true;
      rewardCoins += 500;
      rewardDiamonds += 50;
      rewardXp += 200;
      rewardType = '30_day_streak';
      const badgeId = streak.daily_rewards.day_30?.special_badge || 'loyal_fighter';
      user.unlockedBadges = user.unlockedBadges || [];
      if (!user.unlockedBadges.includes(badgeId)) {
        user.unlockedBadges.push(badgeId);
        specialReward = { type: 'badge', id: badgeId, name: 'Loyal Fighter' };
      }
    }

    // Special rewards at specific milestones
    const specialMilestones = [3, 5, 10, 15, 20, 25];
    if (specialMilestones.includes(newStreak)) {
      const bubbleId = `chat_bubble_streak_${newStreak}`;
      streak.special_rewards_unlocked.push({
        type: 'chat_bubble',
        id: bubbleId,
        name: `Streak ${newStreak} Bubble`,
        streak_milestone: newStreak
      });
      specialReward = { type: 'chat_bubble', id: bubbleId, name: `Streak ${newStreak} Bubble` };
    }

    // Apply rewards to user
    user.coins = (user.coins || 0) + rewardCoins;
    user.diamonds = (user.diamonds || 0) + rewardDiamonds;
    user.xp = (user.xp || 0) + rewardXp;
    await user.save();

    // Record login history
    streak.login_history.push({
      date: today,
      rewarded: true,
      reward_type: rewardType,
      reward_value: rewardCoins + rewardDiamonds
    });
    // Keep only last 30 days
    if (streak.login_history.length > 30) {
      streak.login_history = streak.login_history.slice(-30);
    }
    streak.total_rewards_claimed += 1;
    await streak.save();

    res.status(200).json({
      success: true,
      data: {
        streak: streak.current_streak,
        longest_streak: streak.longest_streak,
        reward: { coins: rewardCoins, diamonds: rewardDiamonds, xp: rewardXp },
        reward_type: rewardType,
        special_reward: specialReward,
        total_logins: streak.total_logins,
        day_7_claimed: streak.day_7_reward_claimed,
        day_30_claimed: streak.day_30_reward_claimed,
        special_rewards_unlocked: streak.special_rewards_unlocked
      }
    });
  } catch (error) {
    console.error('Claim Daily Login Error:', error);
    res.status(500).json({ success: false, message: 'Failed to claim daily login' });
  }
};

// ─── ADMIN: GET ALL USER STREAKS ──────────────────────────────────────
exports.adminGetAllStreaks = async (req, res) => {
  try {
    const streaks = await LoginStreak.find()
      .populate('userId', 'username uid coins')
      .sort({ current_streak: -1 })
      .limit(200);
    res.status(200).json({ success: true, data: streaks });
  } catch (error) {
    console.error('Admin Get Streaks Error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch streaks' });
  }
};

// ─── ADMIN: RESET USER STREAK ─────────────────────────────────────────
exports.adminResetStreak = async (req, res) => {
  try {
    const { userId } = req.params;
    const streak = await LoginStreak.findOneAndUpdate(
      { userId },
      { current_streak: 0, day_7_reward_claimed: false, day_30_reward_claimed: false },
      { new: true }
    );
    if (!streak) {
      return res.status(404).json({ success: false, message: 'Streak not found' });
    }
    res.status(200).json({ success: true, message: 'Streak reset', data: streak });
  } catch (error) {
    console.error('Admin Reset Streak Error:', error);
    res.status(500).json({ success: false, message: 'Failed to reset streak' });
  }
};

// ─── FROM: dailyTaskController.js ────────────────────────────────────────
const DailyTask = require('../../models/DailyTask');
const User = require('../../models/User');
const UserEventProgress = require('../../models/UserEventProgress');

// ─── ADMIN: CREATE DAILY TASK ─────────────────────────────────────────
exports.createDailyTask = async (req, res) => {
  try {
    const payload = req.body;
    if (!payload.task_name || !payload.task_type || !payload.target_value) {
      return res.status(400).json({ success: false, message: 'task_name, task_type, target_value required' });
    }
    const task = await DailyTask.create(payload);
    res.status(201).json({ success: true, data: task });
  } catch (error) {
    console.error('Create DailyTask Error:', error);
    res.status(500).json({ success: false, message: 'Failed to create task' });
  }
};

// ─── PUBLIC: GET ACTIVE DAILY TASKS ───────────────────────────────────
exports.getActiveTasks = async (req, res) => {
  try {
    const tasks = await DailyTask.find({ is_active: true });
    const userId = req.user.userId;

    // Enrich with user progress
    const enrichedTasks = [];
    for (const task of tasks) {
      const progress = await UserEventProgress.findOne({
        userId,
        taskId: task._id,
        createdAt: {
          $gte: new Date(new Date().setHours(0, 0, 0, 0)),
          $lte: new Date(new Date().setHours(23, 59, 59, 999))
        }
      });

      enrichedTasks.push({
        _id: task._id,
        task_name: task.task_name,
        description: task.description,
        task_type: task.task_type,
        target_value: task.target_value,
        reward_coins: task.reward_coins,
        reward_diamonds: task.reward_diamonds,
        reward_xp: task.reward_xp,
        reward_frames: task.reward_frames,
        reward_badges: task.reward_badges,
        streak_bonus: task.streak_bonus,
        progress: progress ? progress.progress : 0,
        is_completed: progress ? progress.is_completed : false,
        is_claimed: progress ? progress.is_claimed : false
      });
    }

    res.status(200).json({ success: true, data: enrichedTasks });
  } catch (error) {
    console.error('Get DailyTasks Error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch tasks' });
  }
};

// ─── PUBLIC: UPDATE TASK PROGRESS ─────────────────────────────────────
exports.updateTaskProgress = async (req, res) => {
  try {
    const { taskId } = req.params;
    const { progressIncrement } = req.body;
    const userId = req.user.userId;

    const task = await DailyTask.findById(taskId);
    if (!task || !task.is_active) {
      return res.status(404).json({ success: false, message: 'Task not found or inactive' });
    }

    const todayStart = new Date(new Date().setHours(0, 0, 0, 0));
    const todayEnd = new Date(new Date().setHours(23, 59, 59, 999));

    let userProgress = await UserEventProgress.findOne({
      userId,
      taskId,
      createdAt: { $gte: todayStart, $lte: todayEnd }
    });

    if (!userProgress) {
      userProgress = await UserEventProgress.create({
        userId,
        taskId,
        progress: 0,
        target_value: task.target_value,
        is_completed: false,
        is_claimed: false
      });
    }

    if (userProgress.is_completed) {
      return res.status(200).json({ success: true, data: userProgress, message: 'Task already completed' });
    }

    userProgress.progress = Math.min(userProgress.progress + (progressIncrement || 1), task.target_value);

    if (userProgress.progress >= task.target_value) {
      userProgress.is_completed = true;
      userProgress.completed_at = new Date();
    }

    await userProgress.save();

    res.status(200).json({ success: true, data: userProgress });
  } catch (error) {
    console.error('Update Task Progress Error:', error);
    res.status(500).json({ success: false, message: 'Failed to update progress' });
  }
};

// ─── PUBLIC: CLAIM TASK REWARD ────────────────────────────────────────
exports.claimTaskReward = async (req, res) => {
  try {
    const { taskId } = req.params;
    const userId = req.user.userId;
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    const task = await DailyTask.findById(taskId);
    if (!task || !task.is_active) {
      return res.status(404).json({ success: false, message: 'Task not found or inactive' });
    }

    const todayStart = new Date(new Date().setHours(0, 0, 0, 0));
    const todayEnd = new Date(new Date().setHours(23, 59, 59, 999));

    const userProgress = await UserEventProgress.findOne({
      userId,
      taskId,
      createdAt: { $gte: todayStart, $lte: todayEnd },
      is_completed: true,
      is_claimed: false
    });

    if (!userProgress) {
      return res.status(400).json({ success: false, message: 'Task not completed or already claimed' });
    }

    // Distribute rewards
    user.coins = (user.coins || 0) + (task.reward_coins || 0);
    user.diamonds = (user.diamonds || 0) + (task.reward_diamonds || 0);
    user.xp = (user.xp || 0) + (task.reward_xp || 0);

    if (task.reward_frames && task.reward_frames.length > 0) {
      user.unlockedFrames = user.unlockedFrames || [];
      for (const frame of task.reward_frames) {
        if (!user.unlockedFrames.includes(frame)) {
          user.unlockedFrames.push(frame);
        }
      }
    }
    if (task.reward_badges && task.reward_badges.length > 0) {
      user.unlockedBadges = user.unlockedBadges || [];
      for (const badge of task.reward_badges) {
        if (!user.unlockedBadges.includes(badge)) {
          user.unlockedBadges.push(badge);
        }
      }
    }

    await user.save();

    userProgress.is_claimed = true;
    userProgress.claimed_at = new Date();
    await userProgress.save();

    res.status(200).json({
      success: true,
      message: 'Reward claimed',
      data: {
        coins: task.reward_coins,
        diamonds: task.reward_diamonds,
        xp: task.reward_xp,
        frames: task.reward_frames,
        badges: task.reward_badges
      }
    });
  } catch (error) {
    console.error('Claim Task Reward Error:', error);
    res.status(500).json({ success: false, message: 'Failed to claim reward' });
  }
};

// ─── ADMIN: GET ALL TASKS ─────────────────────────────────────────────
exports.adminGetAllTasks = async (req, res) => {
  try {
    const tasks = await DailyTask.find().sort({ createdAt: -1 });
    res.status(200).json({ success: true, data: tasks });
  } catch (error) {
    console.error('Admin Get Tasks Error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch tasks' });
  }
};

// ─── ADMIN: UPDATE TASK ───────────────────────────────────────────────
exports.adminUpdateTask = async (req, res) => {
  try {
    const task = await DailyTask.findByIdAndUpdate(req.params.id, req.body, { new: true });
    if (!task) {
      return res.status(404).json({ success: false, message: 'Task not found' });
    }
    res.status(200).json({ success: true, data: task });
  } catch (error) {
    console.error('Admin Update Task Error:', error);
    res.status(500).json({ success: false, message: 'Failed to update task' });
  }
};

// ─── ADMIN: DELETE TASK ───────────────────────────────────────────────
exports.adminDeleteTask = async (req, res) => {
  try {
    const task = await DailyTask.findByIdAndDelete(req.params.id);
    if (!task) {
      return res.status(404).json({ success: false, message: 'Task not found' });
    }
    res.status(200).json({ success: true, message: 'Task deleted' });
  } catch (error) {
    console.error('Admin Delete Task Error:', error);
    res.status(500).json({ success: false, message: 'Failed to delete task' });
  }
};

// ─── SEED DEFAULT DAILY TASKS (Admin only) ────────────────────────────
exports.seedDefaultTasks = async (req, res) => {
  try {
    const defaultTasks = [
      {
        task_name: 'Daily Login',
        description: 'Log in to the app',
        task_type: 'LOGIN',
        target_value: 1,
        reward_coins: 20,
        reward_xp: 10
      },
      {
        task_name: 'Stay in Room',
        description: 'Stay in a room for 10 minutes',
        task_type: 'ROOM_STAY',
        target_value: 1,
        reward_coins: 30,
        reward_xp: 15
      },
      {
        task_name: 'Send Messages',
        description: 'Send 5 messages in any room',
        task_type: 'SEND_MESSAGES',
        target_value: 5,
        reward_coins: 15,
        reward_xp: 10
      },
      {
        task_name: 'Send Gifts',
        description: 'Send 3 gifts to other users',
        task_type: 'SEND_GIFTS',
        target_value: 3,
        reward_coins: 50,
        reward_diamonds: 2,
        reward_xp: 25
      },
      {
        task_name: 'PK Battle',
        description: 'Participate in 1 PK battle',
        task_type: 'PK_BATTLE',
        target_value: 1,
        reward_coins: 40,
        reward_xp: 20
      }
    ];

    for (const task of defaultTasks) {
      await DailyTask.findOneAndUpdate(
        { task_name: task.task_name },
        { $setOnInsert: task },
        { upsert: true }
      );
    }

    const allTasks = await DailyTask.find();
    res.status(200).json({ success: true, message: 'Default tasks seeded', data: allTasks });
  } catch (error) {
    console.error('Seed Tasks Error:', error);
    res.status(500).json({ success: false, message: 'Failed to seed tasks' });
  }
};

// ─── FROM: rewardConfigController.js ────────────────────────────────────────
const RewardConfig = require('../../models/RewardConfig');
const LuckyDraw = require('../../models/LuckyDraw');
const TreasureHunt = require('../../models/TreasureHunt');
const User = require('../../models/User');
const AuditLog = require('../../models/AuditLog');
const { getSocketIo } = require('../sockets/socketManager');

// ═══════════════════════════════════════════════════════════════════════════
// CONTROLLER: RewardConfigController — Dynamic reward configuration & management
// ═══════════════════════════════════════════════════════════════════════════

/**
 * POST /api/admin/reward-configs
 * Create a new reward configuration
 */
exports.createRewardConfig = async (req, res) => {
  try {
    const payload = req.body;
    const userId = req.user?.userId || 'OWNER';
    
    if (!payload.configName || !payload.gameType || !payload.startTime || !payload.endTime) {
      return res.status(400).json({ 
        success: false, 
        message: 'Missing required fields: configName, gameType, startTime, endTime' 
      });
    }

    if (!payload.rewardItems || payload.rewardItems.length === 0) {
      return res.status(400).json({ 
        success: false, 
        message: 'At least one reward item is required' 
      });
    }

    const totalProbability = payload.rewardItems.reduce((sum, item) => sum + (item.probability || 0), 0);
    if (Math.abs(totalProbability - 100) > 0.01) {
      return res.status(400).json({ 
        success: false, 
        message: `Total probability must equal 100%. Current: ${totalProbability}%` 
      });
    }

    const config = await RewardConfig.create({
      ...payload,
      deployedBy: userId
    });

    await AuditLog.create({
      action: 'REWARD_CONFIG_CREATE',
      performedBy: userId,
      details: `Created reward config: ${payload.configName} for ${payload.gameType}`,
      metadata: { configId: config._id, configName: payload.configName, gameType: payload.gameType }
    });

    res.status(201).json({ success: true, message: 'Reward config created', data: config });
  } catch (error) {
    console.error('Create RewardConfig Error:', error);
    res.status(500).json({ success: false, message: 'Failed to create reward config' });
  }
};

/**
 * GET /api/admin/reward-configs
 * Get all reward configurations with filters
 */
exports.getAllRewardConfigs = async (req, res) => {
  try {
    const { gameType, isActive, page = 1, limit = 20 } = req.query;
    const skip = (parseInt(page) - 1) * parseInt(limit);
    
    const query = {};
    if (gameType) query.gameType = gameType;
    if (isActive !== undefined) query.isActive = isActive === 'true';

    const [configs, total] = await Promise.all([
      RewardConfig.find(query)
        .populate('deployedBy', 'name uid')
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(parseInt(limit))
        .lean(),
      RewardConfig.countDocuments(query)
    ]);

    res.status(200).json({
      success: true,
      data: configs,
      pagination: { page: parseInt(page), limit: parseInt(limit), total, pages: Math.ceil(total / parseInt(limit)) }
    });
  } catch (error) {
    console.error('Get RewardConfigs Error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch reward configs' });
  }
};

/**
 * GET /api/admin/reward-configs/:id
 * Get a single reward configuration by ID
 */
exports.getRewardConfigById = async (req, res) => {
  try {
    const config = await RewardConfig.findById(req.params.id)
      .populate('deployedBy', 'name uid')
      .lean();
    
    if (!config) {
      return res.status(404).json({ success: false, message: 'Reward config not found' });
    }

    res.status(200).json({ success: true, data: config });
  } catch (error) {
    console.error('Get RewardConfig Error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch reward config' });
  }
};

/**
 * PUT /api/admin/reward-configs/:id
 * Update a reward configuration (live deployment)
 */
exports.updateRewardConfig = async (req, res) => {
  try {
    const config = await RewardConfig.findById(req.params.id);
    if (!config) {
      return res.status(404).json({ success: false, message: 'Reward config not found' });
    }

    const oldConfig = { ...config.toObject() };
    const updates = req.body;

    if (updates.rewardItems && updates.rewardItems.length > 0) {
      const totalProbability = updates.rewardItems.reduce((sum, item) => sum + (item.probability || 0), 0);
      if (Math.abs(totalProbability - 100) > 0.01) {
        return res.status(400).json({ 
          success: false, 
          message: `Total probability must equal 100%. Current: ${totalProbability}%` 
        });
      }
    }

    Object.assign(config, updates);
    config.version = incrementVersion(config.version);
    await config.save();

    await AuditLog.create({
      action: 'REWARD_CONFIG_UPDATE',
      performedBy: req.user?.userId || 'OWNER',
      details: `Updated reward config: ${config.configName}`,
      metadata: { 
        configId: config._id, 
        changes: detectChanges(oldConfig, config.toObject()) 
      }
    });

    // Broadcast update via Socket.IO for real-time sync
    try {
      const io = getSocketIo();
      io.to(`game:${config.gameType}`).emit('reward_config_updated', {
        configId: config._id,
        configName: config.configName,
        gameType: config.gameType,
        version: config.version,
        timestamp: new Date()
      });
    } catch (socketError) {
      console.warn('Socket broadcast failed:', socketError.message);
    }

    res.status(200).json({ success: true, message: 'Reward config updated', data: config });
  } catch (error) {
    console.error('Update RewardConfig Error:', error);
    res.status(500).json({ success: false, message: 'Failed to update reward config' });
  }
};

/**
 * DELETE /api/admin/reward-configs/:id
 * Delete a reward configuration
 */
exports.deleteRewardConfig = async (req, res) => {
  try {
    const config = await RewardConfig.findById(req.params.id);
    if (!config) {
      return res.status(404).json({ success: false, message: 'Reward config not found' });
    }

    if (config.isDefault) {
      return res.status(400).json({ success: false, message: 'Cannot delete default config' });
    }

    await RewardConfig.findByIdAndDelete(req.params.id);

    await AuditLog.create({
      action: 'REWARD_CONFIG_DELETE',
      performedBy: req.user?.userId || 'OWNER',
      details: `Deleted reward config: ${config.configName}`,
      metadata: { configId: config._id, configName: config.configName }
    });

    res.status(200).json({ success: true, message: 'Reward config deleted' });
  } catch (error) {
    console.error('Delete RewardConfig Error:', error);
    res.status(500).json({ success: false, message: 'Failed to delete reward config' });
  }
};

/**
 * POST /api/admin/reward-configs/:id/deploy
 * Deploy a config as active (stops previous active configs for same gameType)
 */
exports.deployRewardConfig = async (req, res) => {
  try {
    const config = await RewardConfig.findById(req.params.id);
    if (!config) {
      return res.status(404).json({ success: false, message: 'Reward config not found' });
    }

    await RewardConfig.updateMany(
      { gameType: config.gameType, isActive: true, _id: { $ne: config._id } },
      { isActive: false }
    );

    config.isActive = true;
    config.isDefault = true;
    await config.save();

    // Sync to LuckyDraw or TreasureHunt based on gameType
    await syncToGameModel(config);

    await AuditLog.create({
      action: 'REWARD_CONFIG_DEPLOY',
      performedBy: req.user?.userId || 'OWNER',
      details: `Deployed reward config: ${config.configName} for ${config.gameType}`,
      metadata: { configId: config._id, gameType: config.gameType }
    });

    // Broadcast deployment
    try {
      const io = getSocketIo();
      io.to(`game:${config.gameType}`).emit('reward_config_deployed', {
        configId: config._id,
        configName: config.configName,
        gameType: config.gameType,
        version: config.version,
        timestamp: new Date()
      });
    } catch (socketError) {
      console.warn('Socket broadcast failed:', socketError.message);
    }

    res.status(200).json({ success: true, message: 'Reward config deployed', data: config });
  } catch (error) {
    console.error('Deploy RewardConfig Error:', error);
    res.status(500).json({ success: false, message: 'Failed to deploy reward config' });
  }
};

/**
 * GET /api/admin/reward-configs/analytics/:id
 * Get analytics for a reward configuration
 */
exports.getRewardAnalytics = async (req, res) => {
  try {
    const config = await RewardConfig.findById(req.params.id)
      .select('analytics totalSpinsUsed totalWinners totalCoinsIn totalRewardsOut')
      .lean();
    
    if (!config) {
      return res.status(404).json({ success: false, message: 'Reward config not found' });
    }

    const roi = config.totalCoinsIn > 0 
      ? ((config.totalCoinsIn - config.totalRewardsOut) / config.totalCoinsIn * 100).toFixed(2)
      : 0;

    res.status(200).json({
      success: true,
      data: {
        ...config,
        roi,
        houseEdge: (100 - parseFloat(roi)).toFixed(2)
      }
    });
  } catch (error) {
    console.error('Get Analytics Error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch analytics' });
  }
};

/**
 * GET /api/admin/reward-configs/tiers
 * Get all available reward tiers
 */
exports.getRewardTiers = async (req, res) => {
  try {
    const tiers = [
      { rarity: 'common', label: 'Common', color: '#9E9E9E', probability: '40-60%' },
      { rarity: 'uncommon', label: 'Uncommon', color: '#4CAF50', probability: '20-30%' },
      { rarity: 'rare', label: 'Rare', color: '#2196F3', probability: '10-15%' },
      { rarity: 'epic', label: 'Epic', color: '#9C27B0', probability: '3-8%' },
      { rarity: 'legendary', label: 'Legendary', color: '#FF9800', probability: '0.5-2%' },
      { rarity: 'mythic', label: 'Mythic', color: '#F44336', probability: '0.1-0.5%' }
    ];

    res.status(200).json({ success: true, data: tiers });
  } catch (error) {
    console.error('Get Tiers Error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch tiers' });
  }
};

// ═══════════════════════════════════════════════════════════════════════════
// HELPERS
// ═══════════════════════════════════════════════════════════════════════════

function incrementVersion(current) {
  const parts = current.split('.');
  const patch = parseInt(parts[2] || '0') + 1;
  return `${parts[0]}.${parts[1]}.${patch}`;
}

function detectChanges(oldObj, newObj) {
  const changes = {};
  for (const key in newObj) {
    if (JSON.stringify(oldObj[key]) !== JSON.stringify(newObj[key])) {
      changes[key] = { from: oldObj[key], to: newObj[key] };
    }
  }
  return changes;
}

async function syncToGameModel(config) {
  if (config.gameType === 'lucky_spin') {
    await LuckyDraw.updateMany(
      { is_active: true },
      { 
        segments: config.rewardItems.map(item => ({
          label: item.itemName,
          prize_type: item.itemType,
          prize_value: item.itemValue,
          prize_name: item.itemName,
          prize_id: item.itemId,
          weight: item.weight,
          color: config.tiers.find(t => t.tierName === item.tier)?.colorCode || '#FF6B6B'
        })),
        spin_cost_coins: config.spinCostCoins,
        spin_cost_diamonds: config.spinCostDiamonds,
        max_spins_per_user: config.maxSpinsPerUser,
        total_spins_allowed: config.totalSpinsAllowed,
        jackpot_enabled: config.jackpotEnabled,
        jackpot_prize: config.jackpotPrize,
        jackpot_trigger_rate: config.jackpotTriggerRate
      }
    );
  } else if (config.gameType === 'treasure_hunt') {
    await TreasureHunt.updateMany(
      { is_active: true, is_found: false },
      {
        rewards: {
          coins: config.rewardItems.find(i => i.itemType === 'coins')?.itemValue || 0,
          diamonds: config.rewardItems.find(i => i.itemType === 'diamonds')?.itemValue || 0,
          xp: config.rewardItems.find(i => i.itemType === 'xp')?.itemValue || 0,
          frames: config.rewardItems.filter(i => i.itemType === 'frame').map(i => i.itemId),
          badges: config.rewardItems.filter(i => i.itemType === 'badge').map(i => i.itemId),
          cars: config.rewardItems.filter(i => i.itemType === 'entry_car').map(i => i.itemId),
          specialEffects: config.rewardItems.filter(i => ['mount', 'entry_effect', 'avatar_decoration', 'chat_bubble', 'seat_frame'].includes(i.itemType)).map(i => i.itemId)
        }
      }
    );
  }
}

// ─── FROM: rewardInjectorController.js ────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════
// CONTROLLER: RewardInjectorController — Direct UID-targeted asset injection
// VIP avatar frames, entry effects, mounts, badges for specific users
// ═══════════════════════════════════════════════════════════════════════════

const RewardInjector = require('../../models/RewardInjector');
const User = require('../../models/User');
const AuditLog = require('../../models/AuditLog');

/**
 * POST /api/admin/rewards/inject
 * Owner/Admin: Inject assets directly to a target UID
 */
exports.injectReward = async (req, res) => {
  try {
    const { targetUid, assets, reason } = req.body;

    if (!targetUid || !assets || !Array.isArray(assets) || assets.length === 0) {
      return res.status(400).json({ success: false, message: 'Target UID and assets array required' });
    }

    const user = await User.findOne({ uid: targetUid });
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found with this UID' });
    }

    // Validate each asset
    for (const asset of assets) {
      if (!asset.assetType || !asset.assetId || !asset.assetName) {
        return res.status(400).json({ success: false, message: 'Each asset needs assetType, assetId, assetName' });
      }
    }

    // Calculate expiration if duration is set
    let expiresAt = null;
    const hasDuration = assets.some((a) => a.durationDays && a.durationDays > 0);
    if (hasDuration) {
      const maxDays = Math.max(...assets.map((a) => a.durationDays || 0));
      expiresAt = new Date(Date.now() + maxDays * 24 * 60 * 60 * 1000);
    }

    const injector = await RewardInjector.create({
      targetUserId: user._id,
      targetUid,
      assets,
      reason: reason || 'Admin/Owner reward injection',
      injectedBy: req.user?.userId || 'OWNER',
      injectedByRole: req.user?.role || 'OWNER',
      expiresAt,
    });

    // Update user inventory (add assets to their equipped/owned items)
    if (!user.inventory) user.inventory = {};
    if (!user.inventory.ownedAssets) user.inventory.ownedAssets = [];
    
    for (const asset of assets) {
      user.inventory.ownedAssets.push({
        assetType: asset.assetType,
        assetId: asset.assetId,
        assetName: asset.assetName,
        acquiredAt: new Date(),
        expiresAt: asset.durationDays > 0
          ? new Date(Date.now() + asset.durationDays * 24 * 60 * 60 * 1000)
          : null,
      });
    }
    await user.save();

    // Audit log
    await AuditLog.create({
      action: 'REWARD_INJECT',
      performedBy: req.user?.userId || 'OWNER',
      details: `Injected ${assets.length} assets to UID ${targetUid}. Reason: ${reason || 'N/A'}`,
      metadata: { targetUid, assetCount: assets.length, assetTypes: assets.map((a) => a.assetType) },
    });

    return res.status(200).json({
      success: true,
      message: `${assets.length} asset(s) injected to UID ${targetUid}`,
      data: injector,
    });
  } catch (error) {
    console.error('injectReward Error:', error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

/**
 * GET /api/admin/rewards/history
 * Get reward injection history with filters
 */
exports.getRewardHistory = async (req, res) => {
  try {
    const { targetUid, assetType, page, limit } = req.query;
    const query = {};
    if (targetUid) query.targetUid = targetUid;
    if (assetType) query['assets.assetType'] = assetType;

    const pageNum = parseInt(page) || 1;
    const limitNum = parseInt(limit) || 20;

    const [rewards, total] = await Promise.all([
      RewardInjector.find(query)
        .populate('targetUserId', 'uid name username avatar')
        .sort({ createdAt: -1 })
        .skip((pageNum - 1) * limitNum)
        .limit(limitNum)
        .lean(),
      RewardInjector.countDocuments(query),
    ]);

    return res.status(200).json({
      success: true,
      data: rewards,
      pagination: { total, page: pageNum, pages: Math.ceil(total / limitNum) },
    });
  } catch (error) {
    console.error('getRewardHistory Error:', error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

/**
 * POST /api/admin/rewards/revoke/:id
 * Revoke an active reward injection
 */
exports.revokeReward = async (req, res) => {
  try {
    const injector = await RewardInjector.findById(req.params.id);
    if (!injector) {
      return res.status(404).json({ success: false, message: 'Reward injection not found' });
    }

    injector.isActive = false;
    await injector.save();

    await AuditLog.create({
      action: 'REWARD_REVOKE',
      performedBy: req.user?.userId || 'OWNER',
      details: `Revoked reward injection for UID ${injector.targetUid}`,
      metadata: { injectorId: injector._id.toString(), targetUid: injector.targetUid },
    });

    return res.status(200).json({ success: true, message: 'Reward injection revoked', data: injector });
  } catch (error) {
    console.error('revokeReward Error:', error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

/**
 * GET /api/admin/rewards/user/:uid
 * Get all active rewards for a specific UID
 */
exports.getUserRewards = async (req, res) => {
  try {
    const rewards = await RewardInjector.find({
      targetUid: req.params.uid,
      isActive: true,
    })
      .sort({ createdAt: -1 })
      .lean();

    const allAssets = [];
    for (const reward of rewards) {
      for (const asset of reward.assets) {
        allAssets.push({
          ...asset,
          rewardId: reward._id,
          injectedAt: reward.createdAt,
          expiresAt: reward.expiresAt,
        });
      }
    }

    return res.status(200).json({ success: true, data: allAssets });
  } catch (error) {
    console.error('getUserRewards Error:', error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

// ─── FROM: missionController.js ────────────────────────────────────────
const User = require('../../models/User');
const MissionProgress = require('../../models/MissionProgress');

// You can expand this array to add as many missions as you want!
const DAILY_MISSIONS = [
  { id: 'm1', title: 'Daily Check-in', description: 'Log into the app today.', target: 1, type: 'dailyLogin', rewardCoins: 10 },
  { id: 'm2', title: 'Arcade Player', description: 'Play Lucky Wheel or Scratch Card.', target: 2, type: 'gamesPlayed', rewardCoins: 30 },
  { id: 'm3', title: 'Generous Friend', description: 'Send virtual gifts in a live room.', target: 5, type: 'giftsSent', rewardCoins: 50 },
];

exports.getMissions = async (req, res) => {
  try {
    const userId = req.user.userId;
    const today = new Date().toISOString().split('T')[0];

    let progress = await MissionProgress.findOne({ user: userId });
    
    // Dynamically reset the user's progress if it's a new day
    if (!progress || progress.lastResetDate !== today) {
      if (progress) {
        progress.lastResetDate = today;
        progress.dailyLogin = 1; // They just logged in!
        progress.gamesPlayed = 0;
        progress.giftsSent = 0;
        progress.claimedMissions = [];
        await progress.save();
      } else {
        progress = await MissionProgress.create({ user: userId, lastResetDate: today, dailyLogin: 1 });
      }
    } else if (progress.dailyLogin === 0) {
      progress.dailyLogin = 1;
      await progress.save();
    }

    const missionsWithProgress = DAILY_MISSIONS.map(mission => {
      const currentProgress = progress[mission.type] || 0;
      return {
        ...mission,
        currentProgress: Math.min(currentProgress, mission.target),
        isCompleted: currentProgress >= mission.target,
        isClaimed: progress.claimedMissions.includes(mission.id)
      };
    });

    res.status(200).json({ success: true, missions: missionsWithProgress });
  } catch (error) {
    console.error('Get Missions Error:', error);
    res.status(500).json({ error: 'Failed to load missions' });
  }
};

exports.claimReward = async (req, res) => {
  try {
    const { missionId } = req.body;
    const userId = req.user.userId;
    const today = new Date().toISOString().split('T')[0];

    const mission = DAILY_MISSIONS.find(m => m.id === missionId);
    if (!mission) return res.status(404).json({ error: 'Mission not found' });

    const progress = await MissionProgress.findOne({ user: userId });
    if (!progress || progress.lastResetDate !== today) return res.status(400).json({ error: 'Progress out of sync. Please refresh.' });
    if (progress.claimedMissions.includes(missionId)) return res.status(400).json({ error: 'Reward already claimed' });
    if ((progress[mission.type] || 0) < mission.target) return res.status(400).json({ error: 'Mission not completed yet' });

    // Claim it and reward the user
    progress.claimedMissions.push(missionId);
    await progress.save();

    const user = await User.findById(userId);
    user.coins = (user.coins || 0) + mission.rewardCoins;
    await user.save();

    res.status(200).json({ success: true, message: 'Reward claimed!', rewardCoins: mission.rewardCoins, balance: { coins: user.coins }});
  } catch (error) {
    console.error('Claim Reward Error:', error);
    res.status(500).json({ error: 'Failed to claim reward' });
  }
};