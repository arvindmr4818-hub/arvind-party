// =========================================================================
// MODULE: EVENTS — CONTROLLER
// =========================================================================


// ─── FROM: eventController.js ────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════
// FILE: src/controllers/eventController.js
// ARVIND PARTY - MASTER EVENT ENGINE CONTROLLER
// ═══════════════════════════════════════════════════════════════════════════

const mongoose = require('mongoose');
const Event = require('../../models/Event');
const WelcomeWeekTask = require('../../models/WelcomeWeekTask');
const UserEventProgress = require('../../models/UserEventProgress');
const EventPrizePool = require('../../models/EventPrizePool');
const FestivalGift = require('../../models/FestivalGift');
const AnniversaryReward = require('../../models/AnniversaryReward');
const Gift = require('../../models/Gift');
const User = require('../../models/User');
const Transaction = require('../../models/Transaction');
const WalletTransaction = require('../../models/WalletTransaction');
const { broadcastToUser } = require('../sockets/eventSocket');

class EventController {
  // ─────────────────────────────────────────────────────────────────────────
  // GET ACTIVE EVENTS FOR USER
  // GET /api/events/active
  // ─────────────────────────────────────────────────────────────────────────
  static async getActiveEvents(req, res) {
    try {
      const userId = req.user.userId;
      const user = await User.findById(userId);
      const now = new Date();

      const query = {
        is_active: true,
        status: 'active',
        start_time: { $lte: now },
        end_time: { $gte: now }
      };

      const events = await Event.find(query)
        .populate('created_by', 'name avatar')
        .sort({ 'config.highlight_priority': -1, createdAt: -1 });

      const enrichedEvents = events.map(event => {
        const meetsRequirements = this.checkEventRequirements(event, user);
        const userProgress = null;

        return {
          ...event.toObject(),
          meets_requirements: meetsRequirements,
          user_progress: userProgress,
          is_joined: event.participants.includes(userId)
        };
      });

      res.status(200).json({
        success: true,
        data: enrichedEvents,
        count: enrichedEvents.length
      });
    } catch (error) {
      console.error('Error fetching active events:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to fetch active events'
      });
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CHECK EVENT REQUIREMENTS
  // ─────────────────────────────────────────────────────────────────────────
  static checkEventRequirements(event, user) {
    const req = event.requirements || {};

    if (req.min_level && user.level < req.min_level) return false;
    if (req.min_days_active && user.daysActive < req.min_days_active) return false;
    if (req.new_user_only && !user.isNewUser) return false;
    if (req.account_age_days && user.accountAge < req.account_age_days) return false;
    if (req.vip_required && !user.isVip) return false;
    if (req.agency_required && !user.agencyId) return false;
    if (req.gender && req.gender !== '' && user.gender !== req.gender) return false;
    if (req.specific_countries && req.specific_countries.length > 0 && !req.specific_countries.includes(user.country)) return false;

    return true;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // GET EVENT DETAILS
  // GET /api/events/{eventId}
  // ─────────────────────────────────────────────────────────────────────────
  static async getEventDetails(req, res) {
    try {
      const { eventId } = req.params;
      const userId = req.user.userId;

      const event = await Event.findById(eventId).populate('created_by', 'name avatar');

      if (!event) {
        return res.status(404).json({
          success: false,
          message: 'Event not found'
        });
      }

      const user = await User.findById(userId);
      const progress = await UserEventProgress.findOne({ userId, eventId });
      const prizePool = await EventPrizePool.findOne({ event_id: eventId });

      const enrichedEvent = {
        ...event.toObject(),
        meets_requirements: this.checkEventRequirements(event, user),
        user_progress: progress,
        prize_pool: prizePool
      };

      res.status(200).json({
        success: true,
        data: enrichedEvent
      });
    } catch (error) {
      console.error('Error fetching event details:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to fetch event details'
      });
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // JOIN EVENT
  // POST /api/events/{eventId}/join
  // ─────────────────────────────────────────────────────────────────────────
  static async joinEvent(req, res) {
    try {
      const { eventId } = req.params;
      const userId = req.user.userId;

      const event = await Event.findById(eventId);
      if (!event) {
        return res.status(404).json({
          success: false,
          message: 'Event not found'
        });
      }

      if (event.status !== 'active') {
        return res.status(400).json({
          success: false,
          message: 'Event is not active'
        });
      }

      const user = await User.findById(userId);
      if (!this.checkEventRequirements(event, user)) {
        return res.status(400).json({
          success: false,
          message: 'You do not meet the event requirements'
        });
      }

      if (event.max_participants > 0 && event.participants_count >= event.max_participants) {
        return res.status(400).json({
          success: false,
          message: 'Event is full'
        });
      }

      if (event.participants.includes(userId)) {
        return res.status(400).json({
          success: false,
          message: 'Already joined this event'
        });
      }

      event.participants.push(userId);
      event.participants_count = event.participants.length;
      await event.save();

      if (event.event_type === 'WELCOME_WEEK') {
        await this.initializeWelcomeWeekProgress(userId, eventId);
      }

      broadcastToUser(userId, 'event_joined', {
        eventId: event._id,
        event_name: event.event_name,
        participants_count: event.participants_count
      });

      res.status(200).json({
        success: true,
        data: {
          participants_count: event.participants_count,
          message: 'Joined event successfully'
        }
      });
    } catch (error) {
      console.error('Error joining event:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to join event'
      });
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // LEAVE EVENT
  // POST /api/events/{eventId}/leave
  // ─────────────────────────────────────────────────────────────────────────
  static async leaveEvent(req, res) {
    try {
      const { eventId } = req.params;
      const userId = req.user.userId;

      const event = await Event.findById(eventId);
      if (!event) {
        return res.status(404).json({
          success: false,
          message: 'Event not found'
        });
      }

      if (!event.participants.includes(userId)) {
        return res.status(400).json({
          success: false,
          message: 'Not joined this event'
        });
      }

      event.participants = event.participants.filter(id => id.toString() !== userId.toString());
      event.participants_count = event.participants.length;
      await event.save();

      await UserEventProgress.deleteMany({ userId, eventId });

      res.status(200).json({
        success: true,
        data: {
          participants_count: event.participants_count,
          message: 'Left event successfully'
        }
      });
    } catch (error) {
      console.error('Error leaving event:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to leave event'
      });
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CLAIM EVENT REWARD
  // POST /api/events/{eventId}/claim
  // ─────────────────────────────────────────────────────────────────────────
  static async claimEventReward(req, res) {
    try {
      const { eventId } = req.params;
      const userId = req.user.userId;

      const event = await Event.findById(eventId);
      if (!event) {
        return res.status(404).json({
          success: false,
          message: 'Event not found'
        });
      }

      const progress = await UserEventProgress.findOne({ userId, eventId });
      if (!progress || !progress.is_completed) {
        return res.status(400).json({
          success: false,
          message: 'Event task not completed yet'
        });
      }

      if (progress.is_claimed) {
        return res.status(400).json({
          success: false,
          message: 'Reward already claimed'
        });
      }

      const user = await User.findById(userId);
      const rewards = event.reward_details;

      if (rewards.coins > 0) {
        user.coins += rewards.coins;
        await WalletTransaction.create({
          userId,
          type: 'event_reward',
          amount: rewards.coins,
          currency: 'coins',
          description: `Event reward: ${event.event_name}`,
          reference_id: eventId
        });
      }

      if (rewards.diamonds > 0) {
        user.diamonds += rewards.diamonds;
      }

      if (rewards.xp > 0) {
        user.xp += rewards.xp;
      }

      if (rewards.badges && rewards.badges.length > 0) {
        user.badges = [...(user.badges || []), ...rewards.badges];
      }

      if (rewards.frames && rewards.frames.length > 0) {
        user.frames = [...(user.frames || []), ...rewards.frames];
      }

      if (rewards.vipDays > 0) {
        user.vipExpiry = new Date(Date.now() + rewards.vipDays * 24 * 60 * 60 * 1000);
      }

      await user.save();

      progress.is_claimed = true;
      progress.claimed_at = new Date();
      await progress.save();

      broadcastToUser(userId, 'event_reward_claimed', {
        eventId: event._id,
        rewards: rewards
      });

      res.status(200).json({
        success: true,
        data: {
          rewards: rewards,
          message: 'Reward claimed successfully'
        }
      });
    } catch (error) {
      console.error('Error claiming event reward:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to claim reward'
      });
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // UPDATE EVENT PROGRESS
  // POST /api/events/{eventId}/progress
  // ─────────────────────────────────────────────────────────────────────────
  static async updateProgress(req, res) {
    try {
      const { eventId } = req.params;
      const { taskId, progress_value, metadata = {} } = req.body;
      const userId = req.user.userId;

      const event = await Event.findById(eventId);
      if (!event) {
        return res.status(404).json({
          success: false,
          message: 'Event not found'
        });
      }

      let progress = await UserEventProgress.findOne({ userId, eventId, taskId });

      if (!progress) {
        progress = await UserEventProgress.create({
          userId,
          eventId,
          taskId,
          progress: 0,
          target_value: event.metadata?.welcome_week_day || 1,
          metadata
        });
      }

      progress.progress = Math.min(progress.progress + progress_value, progress.target_value);
      progress.last_activity_date = new Date();

      if (progress.progress >= progress.target_value) {
        progress.is_completed = true;
        progress.completed_at = new Date();

        broadcastToUser(userId, 'event_task_completed', {
          eventId: event._id,
          taskId: taskId,
          event_name: event.event_name
        });
      }

      await progress.save();

      res.status(200).json({
        success: true,
        data: {
          progress: progress.progress,
          target: progress.target_value,
          is_completed: progress.is_completed
        }
      });
    } catch (error) {
      console.error('Error updating progress:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to update progress'
      });
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // GET USER EVENT HISTORY
  // GET /api/events/user/history
  // ─────────────────────────────────────────────────────────────────────────
  static async getUserEventHistory(req, res) {
    try {
      const userId = req.user.userId;
      const { page = 1, limit = 20 } = req.query;
      const skip = (parseInt(page) - 1) * parseInt(limit);

      const progress = await UserEventProgress.find({ userId })
        .populate('eventId', 'event_name event_type reward_details start_time end_time')
        .populate('taskId', 'task_name task_type')
        .sort({ updatedAt: -1 })
        .skip(skip)
        .limit(parseInt(limit));

      const total = await UserEventProgress.countDocuments({ userId });

      res.status(200).json({
        success: true,
        data: progress,
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          total,
          pages: Math.ceil(total / parseInt(limit))
        }
      });
    } catch (error) {
      console.error('Error fetching user event history:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to fetch event history'
      });
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ADMIN: GET ALL EVENTS
  // GET /api/events/admin/list
  // ─────────────────────────────────────────────────────────────────────────
  static async getAllEventsAdmin(req, res) {
    try {
      const { page = 1, limit = 50, type, status } = req.query;
      const skip = (parseInt(page) - 1) * parseInt(limit);

      const query = {};
      if (type) query.event_type = type;
      if (status) query.status = status;

      const events = await Event.find(query)
        .populate('created_by', 'name email')
        .populate('updated_by', 'name email')
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(parseInt(limit));

      const total = await Event.countDocuments(query);

      res.status(200).json({
        success: true,
        data: events,
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          total,
          pages: Math.ceil(total / parseInt(limit))
        }
      });
    } catch (error) {
      console.error('Error fetching admin events:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to fetch events'
      });
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ADMIN: CREATE EVENT
  // POST /api/events/admin/create
  // ─────────────────────────────────────────────────────────────────────────
  static async createEvent(req, res) {
    try {
      const payload = req.body;
      const adminId = req.user.userId;

      if (!payload.event_name || !payload.event_type || !payload.title || !payload.start_time || !payload.end_time) {
        return res.status(400).json({
          success: false,
          message: 'Missing required event fields'
        });
      }

      const event = await Event.create({
        ...payload,
        created_by: adminId
      });

      if (payload.event_type === 'TOURNAMENT' || payload.event_type === 'PK_BATTLE') {
        await EventPrizePool.create({
          event_id: event._id,
          total_amount: payload.metadata?.prize_pool_amount || 0,
          currency_type: 'coins',
          contribution_rules: {
            gift_percentage: payload.metadata?.gift_percentage || 10,
            recharge_percentage: 5
          },
          distribution_rules: {
            type: 'top_3_split',
            winners_count: 3
          }
        });
      }

      res.status(201).json({
        success: true,
        data: event,
        message: 'Event created successfully'
      });
    } catch (error) {
      console.error('Error creating event:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to create event'
      });
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ADMIN: UPDATE EVENT
  // PUT /api/events/admin/{eventId}
  // ─────────────────────────────────────────────────────────────────────────
  static async updateEvent(req, res) {
    try {
      const { eventId } = req.params;
      const payload = req.body;
      const adminId = req.user.userId;

      const event = await Event.findById(eventId);
      if (!event) {
        return res.status(404).json({
          success: false,
          message: 'Event not found'
        });
      }

      Object.assign(event, payload, { updated_by: adminId });
      await event.save();

      res.status(200).json({
        success: true,
        data: event,
        message: 'Event updated successfully'
      });
    } catch (error) {
      console.error('Error updating event:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to update event'
      });
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ADMIN: DELETE EVENT
  // DELETE /api/events/admin/{eventId}
  // ─────────────────────────────────────────────────────────────────────────
  static async deleteEvent(req, res) {
    try {
      const { eventId } = req.params;

      const event = await Event.findById(eventId);
      if (!event) {
        return res.status(404).json({
          success: false,
          message: 'Event not found'
        });
      }

      await Event.findByIdAndDelete(eventId);
      await UserEventProgress.deleteMany({ eventId });
      await EventPrizePool.deleteMany({ event_id: eventId });

      res.status(200).json({
        success: true,
        message: 'Event deleted successfully'
      });
    } catch (error) {
      console.error('Error deleting event:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to delete event'
      });
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ADMIN: MANAGE WELCOME WEEK TASKS
  // ─────────────────────────────────────────────────────────────────────────
  static async getWelcomeWeekTasks(req, res) {
    try {
      const tasks = await WelcomeWeekTask.find().sort({ day_number: 1, display_order: 1 });
      res.status(200).json({
        success: true,
        data: tasks
      });
    } catch (error) {
      console.error('Error fetching welcome week tasks:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to fetch tasks'
      });
    }
  }

  static async createWelcomeWeekTask(req, res) {
    try {
      const task = await WelcomeWeekTask.create(req.body);
      res.status(201).json({
        success: true,
        data: task,
        message: 'Task created successfully'
      });
    } catch (error) {
      console.error('Error creating task:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to create task'
      });
    }
  }

  static async updateWelcomeWeekTask(req, res) {
    try {
      const { taskId } = req.params;
      const task = await WelcomeWeekTask.findByIdAndUpdate(taskId, req.body, { new: true });
      res.status(200).json({
        success: true,
        data: task,
        message: 'Task updated successfully'
      });
    } catch (error) {
      console.error('Error updating task:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to update task'
      });
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ADMIN: MANAGE FESTIVAL GIFTS
  // ─────────────────────────────────────────────────────────────────────────
  static async getFestivalGifts(req, res) {
    try {
      const { festival_type } = req.query;
      const query = { is_active: true };
      if (festival_type) query.festival_type = festival_type;

      const gifts = await FestivalGift.find(query).sort({ createdAt: -1 });
      res.status(200).json({
        success: true,
        data: gifts
      });
    } catch (error) {
      console.error('Error fetching festival gifts:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to fetch festival gifts'
      });
    }
  }

  static async createFestivalGift(req, res) {
    try {
      const gift = await FestivalGift.create(req.body);
      res.status(201).json({
        success: true,
        data: gift,
        message: 'Festival gift created successfully'
      });
    } catch (error) {
      console.error('Error creating festival gift:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to create festival gift'
      });
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ADMIN: MANAGE ANNIVERSARY REWARDS
  // ─────────────────────────────────────────────────────────────────────────
  static async getAnniversaryRewards(req, res) {
    try {
      const { year_anniversary } = req.query;
      const query = {};
      if (year_anniversary) query.year_anniversary = parseInt(year_anniversary);

      const rewards = await AnniversaryReward.find(query).sort({ year_anniversary: -1, category: 1, rank_position: 1 });
      res.status(200).json({
        success: true,
        data: rewards
      });
    } catch (error) {
      console.error('Error fetching anniversary rewards:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to fetch anniversary rewards'
      });
    }
  }

  static async createAnniversaryReward(req, res) {
    try {
      const reward = await AnniversaryReward.create(req.body);
      res.status(201).json({
        success: true,
        data: reward,
        message: 'Anniversary reward created successfully'
      });
    } catch (error) {
      console.error('Error creating anniversary reward:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to create anniversary reward'
      });
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ADMIN: MANAGE EVENT PRIZE POOLS
  // ─────────────────────────────────────────────────────────────────────────
  static async getEventPrizePool(req, res) {
    try {
      const { eventId } = req.params;
      const pool = await EventPrizePool.findOne({ event_id: eventId });
      res.status(200).json({
        success: true,
        data: pool
      });
    } catch (error) {
      console.error('Error fetching prize pool:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to fetch prize pool'
      });
    }
  }

  static async updateEventPrizePool(req, res) {
    try {
      const { eventId } = req.params;
      const updates = req.body;

      const pool = await EventPrizePool.findOneAndUpdate(
        { event_id: eventId },
        updates,
        { new: true, upsert: true }
      );

      res.status(200).json({
        success: true,
        data: pool,
        message: 'Prize pool updated successfully'
      });
    } catch (error) {
      console.error('Error updating prize pool:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to update prize pool'
      });
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // GET EVENT STATS (ADMIN)
  // GET /api/events/admin/stats
  // ─────────────────────────────────────────────────────────────────────────
  static async getEventStats(req, res) {
    try {
      const totalEvents = await Event.countDocuments();
      const activeEvents = await Event.countDocuments({ status: 'active' });
      const upcomingEvents = await Event.countDocuments({ status: 'upcoming' });
      const completedEvents = await Event.countDocuments({ status: 'completed' });

      const eventTypeStats = await Event.aggregate([
        { $group: { _id: '$event_type', count: { $sum: 1 } } }
      ]);

      const totalParticipants = await Event.aggregate([
        { $group: { _id: null, total: { $sum: '$participants_count' } } }
      ]);

      res.status(200).json({
        success: true,
        data: {
          total_events: totalEvents,
          active_events: activeEvents,
          upcoming_events: upcomingEvents,
          completed_events: completedEvents,
          event_type_breakdown: eventTypeStats,
          total_participants: totalParticipants[0]?.total || 0
        }
      });
    } catch (error) {
      console.error('Error fetching event stats:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to fetch event statistics'
      });
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // INITIALIZE WELCOME WEEK PROGRESS
  // ─────────────────────────────────────────────────────────────────────────
  static async initializeWelcomeWeekProgress(userId, eventId) {
    const tasks = await WelcomeWeekTask.find().sort({ day_number: 1, display_order: 1 });

    const progressRecords = tasks.map(task => ({
      userId,
      eventId,
      taskId: task._id,
      progress: 0,
      target_value: task.target_count,
      is_completed: false,
      is_claimed: false,
      streak_count: 0
    }));

    await UserEventProgress.insertMany(progressRecords);
    return progressRecords;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // PROCESS RECHARGE EVENT
  // ─────────────────────────────────────────────────────────────────────────
  static async processRechargeEvent(userId, rechargeAmount) {
    const now = new Date();
    const rechargeEvents = await Event.find({
      event_type: { $in: ['RECHARGE', 'RECHARGE_BONUS'] },
      status: 'active',
      is_active: true,
      start_time: { $lte: now },
      end_time: { $gte: now },
      'requirements.min_recharge_amount': { $lte: rechargeAmount }
    });

    for (const event of rechargeEvents) {
      const existingProgress = await UserEventProgress.findOne({ userId, eventId: event._id });
      if (!existingProgress) {
        await UserEventProgress.create({
          userId,
          eventId: event._id,
          progress: rechargeAmount,
          target_value: event.requirements.min_recharge_amount,
          is_completed: true,
          completed_at: now,
          metadata: { recharge_amount: rechargeAmount }
        });

        broadcastToUser(userId, 'recharge_event_completed', {
          eventId: event._id,
          event_name: event.event_name,
          rewards: event.reward_details
        });
      }
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // DISTRIBUTE PRIZE POOL (TOURNAMENT/BATTLE)
  // ─────────────────────────────────────────────────────────────────────────
  static async distributePrizePool(eventId, winners) {
    const pool = await EventPrizePool.findOne({ event_id: eventId });
    if (!pool || pool.is_locked) return;

    pool.is_locked = true;
    pool.locked_at = new Date();
    await pool.save();

    const distribution = pool.distribution_rules;
    const totalPool = pool.current_amount;

    for (let i = 0; i < winners.length && i < distribution.winners_count; i++) {
      const winner = winners[i];
      const percentage = distribution.percentages[i]?.percentage || this.getDefaultPercentage(i, distribution.winners_count);
      const rewardAmount = Math.floor(totalPool * percentage / 100);

      if (pool.currency_type === 'coins' || pool.currency_type === 'mixed') {
        await WalletTransaction.create({
          userId: winner.userId,
          type: 'event_prize',
          amount: rewardAmount,
          currency: 'coins',
          description: `Event prize - Rank ${i + 1}`,
          reference_id: eventId
        });
      }
    }

    pool.distributed_at = new Date();
    await pool.save();
  }

  static getDefaultPercentage(rank, totalWinners) {
    const percentages = [50, 30, 20, 10, 5];
    return percentages[rank] || 5;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // INJECT FESTIVAL GIFTS
  // ─────────────────────────────────────────────────────────────────────────
  static async injectFestivalGifts(eventId, giftIds) {
    const event = await Event.findById(eventId);
    if (!event || event.event_type !== 'FESTIVAL') {
      throw new Error('Invalid festival event');
    }

    event.reward_details.gifts = giftIds;
    await event.save();

    return {
      success: true,
      message: 'Festival gifts injected successfully',
      gifts_count: giftIds.length
    };
  }

  // ─────────────────────────────────────────────────────────────────────────
  // GET TOURNAMENT STANDINGS
  // ─────────────────────────────────────────────────────────────────────────
  static async getTournamentStandings(req, res) {
    try {
      const { eventId } = req.params;

      const event = await Event.findById(eventId);
      if (!event || event.event_type !== 'TOURNAMENT') {
        return res.status(404).json({
          success: false,
          message: 'Tournament not found'
        });
      }

      const standings = await UserEventProgress.find({ eventId })
        .populate('userId', 'name avatar level agencyId')
        .sort({ progress: -1, completed_at: 1 })
        .limit(16);

      res.status(200).json({
        success: true,
        data: standings,
        tournament_rounds: event.metadata.tournament_rounds
      });
    } catch (error) {
      console.error('Error fetching tournament standings:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to fetch tournament standings'
      });
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // GET USER EVENTS DASHBOARD
  // GET /api/events/dashboard
  // ─────────────────────────────────────────────────────────────────────────
  static async getUserEventsDashboard(req, res) {
    try {
      const userId = req.user.userId;
      const now = new Date();

      const activeEvents = await Event.find({
        is_active: true,
        status: 'active',
        start_time: { $lte: now },
        end_time: { $gte: now }
      }).sort({ 'config.highlight_priority': -1 });

      const myProgress = await UserEventProgress.find({ userId })
        .populate('eventId', 'event_name event_type reward_details')
        .where('is_completed').equals(false);

      const myCompletedEvents = await UserEventProgress.find({ userId, is_completed: true, is_claimed: false })
        .populate('eventId', 'event_name reward_details');

      res.status(200).json({
        success: true,
        data: {
          active_events: activeEvents,
          pending_events: myProgress,
          completed_events: myCompletedEvents
        }
      });
    } catch (error) {
      console.error('Error fetching events dashboard:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to fetch events dashboard'
      });
    }
  }
}

module.exports = EventController;

// ─── FROM: tournamentController.js ────────────────────────────────────────
const Tournament = require('../../models/Tournament');
const User = require('../../models/User');
const Championship = require('../../models/Championship');
const redisRankingService = require('../../services/redisRankingService');

// ─── TOURNAMENT CRUD ───────────────────────────────────────────────────

exports.createTournament = async (req, res) => {
  try {
    const payload = req.body;
    const createdBy = req.user.userId;

    if (!payload.tournament_name || !payload.event_type || !payload.start_time || !payload.end_time) {
      return res.status(400).json({ success: false, message: 'Missing required tournament fields' });
    }

    const tournament = await Tournament.create({
      ...payload,
      created_by: createdBy,
      status: 'upcoming'
    });

    res.status(201).json({ success: true, message: 'Tournament created successfully', data: tournament });
  } catch (error) {
    console.error('Create Tournament Error:', error);
    res.status(500).json({ success: false, message: 'Failed to create tournament' });
  }
};

exports.getTournaments = async (req, res) => {
  try {
    const { page = 1, limit = 20, status, event_type } = req.query;
    const skip = (parseInt(page) - 1) * parseInt(limit);

    const query = { is_active: true };
    if (status) query.status = status;
    if (event_type) query.event_type = event_type;

    const tournaments = await Tournament.find(query)
      .populate('created_by', 'name avatar')
      .sort({ start_time: -1 })
      .skip(skip)
      .limit(parseInt(limit));

    const total = await Tournament.countDocuments(query);

    res.status(200).json({
      success: true,
      data: tournaments,
      pagination: { page: parseInt(page), limit: parseInt(limit), total, pages: Math.ceil(total / parseInt(limit)) }
    });
  } catch (error) {
    console.error('Get Tournaments Error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch tournaments' });
  }
};

exports.getTournamentById = async (req, res) => {
  try {
    const { tournamentId } = req.params;
    const tournament = await Tournament.findById(tournamentId).populate('created_by', 'name avatar');

    if (!tournament) {
      return res.status(404).json({ success: false, message: 'Tournament not found' });
    }

    res.status(200).json({ success: true, data: tournament });
  } catch (error) {
    console.error('Get Tournament Error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch tournament' });
  }
};

exports.registerForTournament = async (req, res) => {
  try {
    const { tournamentId } = req.params;
    const userId = req.user.userId;

    const tournament = await Tournament.findById(tournamentId);
    if (!tournament) {
      return res.status(404).json({ success: false, message: 'Tournament not found' });
    }

    if (tournament.status !== 'registration_open') {
      return res.status(400).json({ success: false, message: 'Registration is not open' });
    }

    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    const existingParticipant = tournament.participants.find(p => p.userId.toString() === userId.toString());
    if (existingParticipant) {
      return res.status(400).json({ success: false, message: 'Already registered' });
    }

    if (tournament.entry_fee > 0 && user.coins < tournament.entry_fee) {
      return res.status(400).json({ success: false, message: 'Insufficient coins for entry fee' });
    }

    if (tournament.entry_fee > 0) {
      user.coins -= tournament.entry_fee;
      await user.save();
    }

    tournament.participants.push({
      userId: user._id,
      username: user.username,
      registered_at: new Date(),
      current_round: 1,
      score: 0,
      is_eliminated: false,
      final_rank: 0
    });
    tournament.participants_count = tournament.participants.length;
    await tournament.save();

    res.status(200).json({ success: true, message: 'Registered successfully', data: tournament });
  } catch (error) {
    console.error('Register Tournament Error:', error);
    res.status(500).json({ success: false, message: 'Failed to register' });
  }
};

exports.updateTournamentScore = async (req, res) => {
  try {
    const { tournamentId } = req.params;
    const { userId, score, is_eliminated, final_rank } = req.body;

    const tournament = await Tournament.findById(tournamentId);
    if (!tournament || tournament.status !== 'live') {
      return res.status(400).json({ success: false, message: 'Tournament not live' });
    }

    const participant = tournament.participants.find(p => p.userId.toString() === userId.toString());
    if (!participant) {
      return res.status(404).json({ success: false, message: 'Participant not found' });
    }

    if (score !== undefined) participant.score += score;
    if (is_eliminated !== undefined) participant.is_eliminated = is_eliminated;
    if (final_rank !== undefined) participant.final_rank = final_rank;

    await tournament.save();

    res.status(200).json({ success: true, data: tournament });
  } catch (error) {
    console.error('Update Tournament Score Error:', error);
    res.status(500).json({ success: false, message: 'Failed to update score' });
  }
};

exports.completeTournament = async (req, res) => {
  try {
    const { tournamentId } = req.params;
    const tournament = await Tournament.findById(tournamentId);

    if (!tournament || tournament.status !== 'live') {
      return res.status(400).json({ success: false, message: 'Tournament not live' });
    }

    tournament.status = 'completed';
    tournament.participants.sort((a, b) => b.score - a.score);

    tournament.participants.forEach((p, index) => {
      p.final_rank = index + 1;
    });

    await tournament.save();

    await distributeTournamentRewards(tournament);

    res.status(200).json({ success: true, message: 'Tournament completed', data: tournament });
  } catch (error) {
    console.error('Complete Tournament Error:', error);
    res.status(500).json({ success: false, message: 'Failed to complete tournament' });
  }
};

async function distributeTournamentRewards(tournament) {
  const rewards = tournament.rewards;
  const top3 = tournament.participants.filter(p => p.final_rank <= 3).sort((a, b) => a.final_rank - b.final_rank);

  for (const participant of top3) {
    const user = await User.findById(participant.userId);
    if (!user) continue;

    const rank = participant.final_rank;
    let rewardKey = '';
    if (rank === 1) rewardKey = 'first';
    else if (rank === 2) rewardKey = 'second';
    else if (rank === 3) rewardKey = 'third';

    const reward = rewards[rewardKey];
    if (!reward) continue;

    user.coins = (user.coins || 0) + (reward.coins || 0);
    user.diamonds = (user.diamonds || 0) + (reward.diamonds || 0);
    user.xp = (user.xp || 0) + (reward.xp || 0);

    if (reward.vipTag && reward.vipTag.trim() !== '') {
      user.unlockedBadges = user.unlockedBadges || [];
      if (!user.unlockedBadges.includes(reward.vipTag)) {
        user.unlockedBadges.push(reward.vipTag);
      }
    }

    await user.save();

    if (reward.cashPrize > 0 && tournament.metadata.agencyId) {
      const Agency = require('../../models/Agency');
      const agency = await Agency.findById(tournament.metadata.agencyId);
      if (agency) {
        agency.earnings = (agency.earnings || 0) + reward.cashPrize;
        await agency.save();
      }
    }
  }

  for (const participant of tournament.participants) {
    if (participant.final_rank > 3) {
      const user = await User.findById(participant.userId);
      if (user && rewards.participation) {
        user.coins = (user.coins || 0) + (rewards.participation.coins || 0);
        user.xp = (user.xp || 0) + (rewards.participation.xp || 0);
        await user.save();
      }
    }
  }
}

exports.getTournamentLeaderboard = async (req, res) => {
  try {
    const { tournamentId } = req.params;
    const tournament = await Tournament.findById(tournamentId);

    if (!tournament) {
      return res.status(404).json({ success: false, message: 'Tournament not found' });
    }

    const sorted = tournament.participants
      .filter(p => !p.is_eliminated)
      .sort((a, b) => b.score - a.score)
      .slice(0, 100);

    res.status(200).json({ success: true, data: sorted, total: tournament.participants_count });
  } catch (error) {
    console.error('Get Tournament Leaderboard Error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch leaderboard' });
  }
};

exports.adminGetAllTournaments = async (req, res) => {
  try {
    const tournaments = await Tournament.find()
      .populate('created_by', 'name avatar')
      .sort({ created_at: -1 });

    res.status(200).json({ success: true, data: tournaments });
  } catch (error) {
    console.error('Admin Get Tournaments Error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch tournaments' });
  }
};

// ─── FROM: luckyDrawController.js ────────────────────────────────────────
const LuckyDraw = require('../../models/LuckyDraw');
const User = require('../../models/User');
const UserEventProgress = require('../../models/UserEventProgress');

// ─── ADMIN: CREATE LUCKY DRAW ──────────────────────────────────────────
exports.createLuckyDraw = async (req, res) => {
  try {
    const payload = req.body;
    if (!payload.draw_name || !payload.start_time || !payload.end_time) {
      return res.status(400).json({ success: false, message: 'Missing required fields: draw_name, start_time, end_time' });
    }
    if (!payload.segments || payload.segments.length < 2) {
      return res.status(400).json({ success: false, message: 'At least 2 wheel segments required' });
    }

    const totalWeight = payload.segments.reduce((sum, s) => sum + (s.weight || 10), 0);
    if (totalWeight <= 0) {
      return res.status(400).json({ success: false, message: 'Total segment weight must be > 0' });
    }

    const luckyDraw = await LuckyDraw.create({
      ...payload,
      created_by: req.user.userId
    });

    res.status(201).json({ success: true, message: 'Lucky draw created', data: luckyDraw });
  } catch (error) {
    console.error('Create LuckyDraw Error:', error);
    res.status(500).json({ success: false, message: 'Failed to create lucky draw' });
  }
};

// ─── PUBLIC: GET ACTIVE LUCKY DRAWS ────────────────────────────────────
exports.getActiveLuckyDraws = async (req, res) => {
  try {
    const now = new Date();
    
    // First try to get from RewardConfig (new system)
    const RewardConfig = require('../../models/RewardConfig');
    const activeConfigs = await RewardConfig.find({
      gameType: 'lucky_spin',
      isActive: true,
      startTime: { $lte: now },
      endTime: { $gte: now }
    }).sort({ createdAt: -1 });

    if (activeConfigs.length > 0) {
      const configs = activeConfigs.map(config => ({
        _id: config._id,
        draw_name: config.configName,
        description: config.description,
        spin_cost_coins: config.spinCostCoins,
        spin_cost_diamonds: config.spinCostDiamonds,
        max_spins_per_user: config.maxSpinsPerUser,
        total_spins_allowed: config.totalSpinsAllowed,
        spins_used: config.totalSpinsUsed,
        segments: config.rewardItems.map(item => ({
          label: item.itemName,
          prize_type: item.itemType,
          prize_value: item.itemValue,
          prize_name: item.itemName,
          prize_id: item.itemId,
          weight: item.weight,
          color: config.tiers.find(t => t.tierName === item.tier)?.colorCode || '#FF6B6B'
        })),
        jackpot_enabled: config.jackpotEnabled,
        jackpot_prize: config.jackpotPrize,
        jackpot_current_pool: config.jackpotCurrentPool,
        jackpot_trigger_rate: config.jackpotTriggerRate,
        is_active: config.isActive,
        start_time: config.startTime,
        end_time: config.endTime,
        version: config.version
      }));

      return res.status(200).json({ success: true, data: configs });
    }

    // Fallback to old LuckyDraw system
    const draws = await LuckyDraw.find({
      is_active: true,
      start_time: { $lte: now },
      end_time: { $gte: now }
    }).select('-unique_users -recent_wins')
      .sort({ createdAt: -1 });

    res.status(200).json({ success: true, data: draws });
  } catch (error) {
    console.error('Get LuckyDraws Error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch lucky draws' });
  }
};

// ─── PUBLIC: GET SINGLE LUCKY DRAW ─────────────────────────────────────
exports.getLuckyDrawById = async (req, res) => {
  try {
    const draw = await LuckyDraw.findById(req.params.id)
      .select('-unique_users');
    if (!draw) {
      return res.status(404).json({ success: false, message: 'Lucky draw not found' });
    }
    res.status(200).json({ success: true, data: draw });
  } catch (error) {
    console.error('Get LuckyDraw Error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch lucky draw' });
  }
};

// ─── PUBLIC: SPIN THE WHEEL ────────────────────────────────────────────
exports.spinWheel = async (req, res) => {
  try {
    const { drawId } = req.params;
    const userId = req.user?.userId;
    
    if (!userId) {
      return res.status(401).json({ success: false, message: 'Authentication required' });
    }

    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    // Try to fetch from RewardConfig first (new system)
    const RewardConfig = require('../../models/RewardConfig');
    const config = await RewardConfig.findOne({
      _id: drawId,
      gameType: 'lucky_spin',
      isActive: true
    });

    if (config) {
      return await spinFromConfig(req, res, config, user);
    }

    // Fallback to old LuckyDraw system
    const draw = await LuckyDraw.findById(drawId);
    if (!draw || !draw.is_active) {
      return res.status(400).json({ success: false, message: 'Lucky draw not found or inactive' });
    }

    const now = new Date();
    if (now < draw.start_time || now > draw.end_time) {
      return res.status(400).json({ success: false, message: 'Lucky draw is not currently active' });
    }

    const userSpinCount = await UserEventProgress.countDocuments({
      userId,
      eventId: draw._id,
      taskId: null,
      is_completed: true
    });

    if (userSpinCount >= draw.max_spins_per_user) {
      return res.status(400).json({ success: false, message: 'Max spins reached for this draw' });
    }

    if (draw.spins_used >= draw.total_spins_allowed) {
      return res.status(400).json({ success: false, message: 'Draw is fully spun out' });
    }

    if (draw.spin_cost_coins > 0) {
      if ((user.coins || 0) < draw.spin_cost_coins) {
        return res.status(400).json({ success: false, message: 'Insufficient coins' });
      }
      user.coins -= draw.spin_cost_coins;
    }
    if (draw.spin_cost_diamonds > 0) {
      if ((user.diamonds || 0) < draw.spin_cost_diamonds) {
        return res.status(400).json({ success: false, message: 'Insufficient diamonds' });
      }
      user.diamonds -= draw.spin_cost_diamonds;
    }
    await user.save();

    const prizeIndex = weightedRandom(draw.segments);
    const wonSegment = draw.segments[prizeIndex];
    let prizeResult = {
      segment_index: prizeIndex,
      label: wonSegment.label,
      prize_type: wonSegment.prize_type,
      prize_value: wonSegment.prize_value,
      prize_name: wonSegment.prize_name,
      prize_id: wonSegment.prize_id || ''
    };

    let jackpotHit = false;
    if (draw.jackpot_enabled && Math.random() < draw.jackpot_trigger_rate) {
      jackpotHit = true;
      prizeResult = {
        segment_index: -1,
        label: draw.jackpot_prize.prize_name || 'JACKPOT',
        prize_type: draw.jackpot_prize.prize_type,
        prize_value: draw.jackpot_current_pool + draw.jackpot_prize.prize_value,
        prize_name: draw.jackpot_prize.prize_name || 'JACKPOT',
        prize_id: 'jackpot'
      };
    }

    await distributePrize(user, prizeResult);

    draw.total_spins += 1;
    draw.spins_used += 1;
    if (!draw.unique_users.some(id => id.toString() === userId.toString())) {
      draw.unique_users.push(userId);
      draw.total_users_played = draw.unique_users.length;
    }
    draw.recent_wins.unshift({
      userId: user._id,
      username: user.username || 'User',
      prize_label: prizeResult.label,
      prize_value: prizeResult.prize_value
    });
    if (draw.recent_wins.length > 50) draw.recent_wins = draw.recent_wins.slice(0, 50);
    await draw.save();

    await UserEventProgress.create({
      userId,
      eventId: draw._id,
      progress: 1,
      target_value: 1,
      is_completed: true,
      completed_at: new Date(),
      metadata: { prize: prizeResult }
    });

    if (draw.jackpot_enabled && !jackpotHit) {
      const poolContribution = Math.floor((draw.spin_cost_coins || 0) * 0.1);
      draw.jackpot_current_pool += poolContribution;
      await draw.save();
    }

    res.status(200).json({ success: true, data: { prize: prizeResult, jackpot_hit: jackpotHit } });
  } catch (error) {
    console.error('Spin Wheel Error:', error);
    res.status(500).json({ success: false, message: 'Failed to process spin' });
  }
};

// ─── ADMIN: GET ALL LUCKY DRAWS ────────────────────────────────────────
exports.adminGetAll = async (req, res) => {
  try {
    const draws = await LuckyDraw.find()
      .populate('created_by', 'name uid')
      .sort({ createdAt: -1 });
    res.status(200).json({ success: true, data: draws });
  } catch (error) {
    console.error('Admin Get LuckyDraws Error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch lucky draws' });
  }
};

// ─── ADMIN: UPDATE LUCKY DRAW ──────────────────────────────────────────
exports.updateLuckyDraw = async (req, res) => {
  try {
    const draw = await LuckyDraw.findByIdAndUpdate(req.params.id, req.body, { new: true });
    if (!draw) {
      return res.status(404).json({ success: false, message: 'Lucky draw not found' });
    }
    res.status(200).json({ success: true, data: draw });
  } catch (error) {
    console.error('Update LuckyDraw Error:', error);
    res.status(500).json({ success: false, message: 'Failed to update lucky draw' });
  }
};

// ─── ADMIN: DELETE LUCKY DRAW ──────────────────────────────────────────
exports.deleteLuckyDraw = async (req, res) => {
  try {
    const draw = await LuckyDraw.findByIdAndDelete(req.params.id);
    if (!draw) {
      return res.status(404).json({ success: false, message: 'Lucky draw not found' });
    }
    res.status(200).json({ success: true, message: 'Lucky draw deleted' });
  } catch (error) {
    console.error('Delete LuckyDraw Error:', error);
    res.status(500).json({ success: false, message: 'Failed to delete lucky draw' });
  }
};

// ─── SPIN FROM REWARDCONFIG ─────────────────────────────────────────────
async function spinFromConfig(req, res, config, user) {
  try {
    const userId = user._id;
    const now = new Date();
    
    if (now < config.startTime || now > config.endTime) {
      return res.status(400).json({ success: false, message: 'Configuration is not currently active' });
    }

    if (config.totalSpinsAllowed > 0 && config.totalSpinsUsed >= config.totalSpinsAllowed) {
      return res.status(400).json({ success: false, message: 'Configuration has reached max spins' });
    }

    if (config.spinCostCoins > 0) {
      if ((user.coins || 0) < config.spinCostCoins) {
        return res.status(400).json({ success: false, message: 'Insufficient coins' });
      }
      user.coins -= config.spinCostCoins;
    }
    if (config.spinCostDiamonds > 0) {
      if ((user.diamonds || 0) < config.spinCostDiamonds) {
        return res.status(400).json({ success: false, message: 'Insufficient diamonds' });
      }
      user.diamonds -= config.spinCostDiamonds;
    }
    await user.save();

    const prizeIndex = weightedRandomFromConfig(config.rewardItems);
    const wonItem = config.rewardItems[prizeIndex];
    let prizeResult = {
      segment_index: prizeIndex,
      label: wonItem.itemName,
      prize_type: wonItem.itemType,
      prize_value: wonItem.itemValue,
      prize_name: wonItem.itemName,
      prize_id: wonItem.itemId,
      tier: wonItem.tier,
      probability: wonItem.probability
    };

    let jackpotHit = false;
    if (config.jackpotEnabled && Math.random() < config.jackpotTriggerRate) {
      jackpotHit = true;
      prizeResult = {
        segment_index: -1,
        label: config.jackpotPrize.prizeName || 'JACKPOT',
        prize_type: config.jackpotPrize.prizeType,
        prize_value: config.jackpotCurrentPool + config.jackpotPrize.prizeValue,
        prize_name: config.jackpotPrize.prizeName || 'JACKPOT',
        prize_id: 'jackpot',
        tier: 'mythic'
      };
    }

    await distributePrizeFromConfig(user, prizeResult);

    config.totalSpinsUsed += 1;
    config.totalCoinsIn += config.spinCostCoins;
    if (!jackpotHit) {
      config.totalRewardsOut += prizeResult.prize_value || 0;
    }
    await config.save();

    await UserEventProgress.create({
      userId,
      eventId: config._id,
      progress: 1,
      target_value: 1,
      is_completed: true,
      completed_at: new Date(),
      metadata: { 
        prize: prizeResult,
        configId: config._id,
        version: config.version
      }
    });

    if (config.jackpotEnabled && !jackpotHit) {
      const poolContribution = Math.floor((config.spinCostCoins || 0) * 0.1);
      config.jackpotCurrentPool += poolContribution;
      await config.save();
    }

    res.status(200).json({ 
      success: true, 
      data: { 
        reward: prizeResult, 
        jackpot_hit: jackpotHit,
        newBalance: { coins: user.coins, diamonds: user.diamonds }
      } 
    });
  } catch (error) {
    console.error('Spin from config error:', error);
    res.status(500).json({ success: false, message: 'Failed to process spin from config' });
  }
}

function weightedRandomFromConfig(rewardItems) {
  const totalWeight = rewardItems.reduce((sum, item) => sum + (item.weight || 10), 0);
  let random = Math.random() * totalWeight;
  for (let i = 0; i < rewardItems.length; i++) {
    random -= (rewardItems[i].weight || 10);
    if (random <= 0) return i;
  }
  return rewardItems.length - 1;
}

async function distributePrizeFromConfig(user, prize) {
  switch (prize.prize_type) {
    case 'coins':
    case 'jackpot_coins':
      user.coins = (user.coins || 0) + (prize.prize_value || 0);
      break;
    case 'diamonds':
      user.diamonds = (user.diamonds || 0) + (prize.prize_value || 0);
      break;
    case 'xp':
      user.xp = (user.xp || 0) + (prize.prize_value || 0);
      break;
    case 'vip_days':
      user.vipExpiry = user.vipExpiry || new Date();
      if (user.vipExpiry < new Date()) user.vipExpiry = new Date();
      user.vipExpiry.setDate(user.vipExpiry.getDate() + (prize.prize_value || 1));
      break;
    case 'frame':
      user.unlockedFrames = user.unlockedFrames || [];
      if (prize.prize_id && !user.unlockedFrames.includes(prize.prize_id)) {
        user.unlockedFrames.push(prize.prize_id);
      }
      break;
    case 'badge':
      user.unlockedBadges = user.unlockedBadges || [];
      if (prize.prize_id && !user.unlockedBadges.includes(prize.prize_id)) {
        user.unlockedBadges.push(prize.prize_id);
      }
      break;
    case 'rocket':
      user.rockets = (user.rockets || 0) + (prize.prize_value || 1);
      break;
    case 'entry_car':
      user.unlockedEntryCars = user.unlockedEntryCars || [];
      if (prize.prize_id && !user.unlockedEntryCars.includes(prize.prize_id)) {
        user.unlockedEntryCars.push(prize.prize_id);
      }
      break;
    case 'mount':
    case 'entry_effect':
    case 'avatar_decoration':
    case 'chat_bubble':
    case 'seat_frame':
      if (!user.inventory) user.inventory = {};
      if (!user.inventory.customAssets) user.inventory.customAssets = [];
      user.inventory.customAssets.push({
        type: prize.prize_type,
        assetId: prize.prize_id,
        assetName: prize.prize_name,
        acquiredAt: new Date()
      });
      break;
    case 'nothing':
    default:
      break;
  }
  await user.save();
}

// ─── HELPERS ───────────────────────────────────────────────────────────
function weightedRandom(segments) {
  const totalWeight = segments.reduce((sum, s) => sum + (s.weight || 10), 0);
  let random = Math.random() * totalWeight;
  for (let i = 0; i < segments.length; i++) {
    random -= (segments[i].weight || 10);
    if (random <= 0) return i;
  }
  return segments.length - 1;
}

async function distributePrize(user, prize) {
  switch (prize.prize_type) {
    case 'coins':
    case 'jackpot_coins':
      user.coins = (user.coins || 0) + (prize.prize_value || 0);
      break;
    case 'diamonds':
      user.diamonds = (user.diamonds || 0) + (prize.prize_value || 0);
      break;
    case 'xp':
      user.xp = (user.xp || 0) + (prize.prize_value || 0);
      break;
    case 'vip_days':
      user.vipExpiry = user.vipExpiry || new Date();
      if (user.vipExpiry < new Date()) user.vipExpiry = new Date();
      user.vipExpiry.setDate(user.vipExpiry.getDate() + (prize.prize_value || 1));
      break;
    case 'frame':
      user.unlockedFrames = user.unlockedFrames || [];
      if (prize.prize_id && !user.unlockedFrames.includes(prize.prize_id)) {
        user.unlockedFrames.push(prize.prize_id);
      }
      break;
    case 'badge':
      user.unlockedBadges = user.unlockedBadges || [];
      if (prize.prize_id && !user.unlockedBadges.includes(prize.prize_id)) {
        user.unlockedBadges.push(prize.prize_id);
      }
      break;
    case 'rocket':
      user.rockets = (user.rockets || 0) + (prize.prize_value || 1);
      break;
    case 'entry_car':
      user.unlockedEntryCars = user.unlockedEntryCars || [];
      if (prize.prize_id && !user.unlockedEntryCars.includes(prize.prize_id)) {
        user.unlockedEntryCars.push(prize.prize_id);
      }
      break;
    case 'nothing':
    default:
      break;
  }
  await user.save();
}

// ─── FROM: treasureHuntController.js ────────────────────────────────────────
const TreasureHunt = require('../../models/TreasureHunt');
const Event = require('../../models/Event');
const User = require('../../models/User');

// ─── TREASURE HUNT CRUD ────────────────────────────────────────────────

exports.createTreasureHunt = async (req, res) => {
  try {
    const payload = req.body;
    const ownerId = req.user.userId;

    if (!payload.hunt_name || !payload.event_id || !payload.room_id || !payload.start_time || !payload.end_time) {
      return res.status(400).json({ success: false, message: 'Missing required treasure hunt fields' });
    }

    const event = await Event.findById(payload.event_id);
    if (!event) {
      return res.status(404).json({ success: false, message: 'Event not found' });
    }

    const treasureHunt = await TreasureHunt.create({
      ...payload,
      owner_id: ownerId
    });

    res.status(201).json({ success: true, message: 'Treasure hunt created successfully', data: treasureHunt });
  } catch (error) {
    console.error('Create Treasure Hunt Error:', error);
    res.status(500).json({ success: false, message: 'Failed to create treasure hunt' });
  }
};

exports.getTreasureHunts = async (req, res) => {
  try {
    const { page = 1, limit = 20, event_id, room_id, is_active } = req.query;
    const skip = (parseInt(page) - 1) * parseInt(limit);

    const query = {};
    if (event_id) query.event_id = event_id;
    if (room_id) query.room_id = room_id;
    if (is_active !== undefined) query.is_active = is_active === 'true';

    const treasureHunts = await TreasureHunt.find(query)
      .populate('owner_id', 'name avatar uid')
      .populate('event_id', 'event_name')
      .sort({ created_at: -1 })
      .skip(skip)
      .limit(parseInt(limit));

    const total = await TreasureHunt.countDocuments(query);

    res.status(200).json({
      success: true,
      data: treasureHunts,
      pagination: { page: parseInt(page), limit: parseInt(limit), total, pages: Math.ceil(total / parseInt(limit)) }
    });
  } catch (error) {
    console.error('Get Treasure Hunts Error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch treasure hunts' });
  }
};

exports.getTreasureHuntById = async (req, res) => {
  try {
    const { huntId } = req.params;
    const treasureHunt = await TreasureHunt.findById(huntId)
      .populate('owner_id', 'name avatar uid')
      .populate('event_id', 'event_name')
      .populate('found_by', 'name avatar uid');

    if (!treasureHunt) {
      return res.status(404).json({ success: false, message: 'Treasure hunt not found' });
    }

    res.status(200).json({ success: true, data: treasureHunt });
  } catch (error) {
    console.error('Get Treasure Hunt Error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch treasure hunt' });
  }
};

exports.collectTreasureKey = async (req, res) => {
  try {
    const { huntId } = req.params;
    const userId = req.user.userId;

    const treasureHunt = await TreasureHunt.findById(huntId);
    if (!treasureHunt || !treasureHunt.is_active) {
      return res.status(404).json({ success: false, message: 'Treasure hunt not found or inactive' });
    }

    if (treasureHunt.is_found) {
      return res.status(400).json({ success: false, message: 'Treasure has already been found' });
    }

    if (treasureHunt.keys_collected_count >= treasureHunt.keys_required) {
      return res.status(400).json({ success: false, message: 'All keys already collected' });
    }

    if (treasureHunt.keys_collected.some(k => k.toString() === userId.toString())) {
      return res.status(400).json({ success: false, message: 'You have already collected a key' });
    }

    treasureHunt.keys_collected.push(userId);
    treasureHunt.keys_collected_count = treasureHunt.keys_collected.length;

    if (treasureHunt.keys_collected_count >= treasureHunt.keys_required) {
      treasureHunt.is_found = true;
      treasureHunt.found_by = userId;
      treasureHunt.found_at = new Date();

      await distributeTreasureRewards(treasureHunt);
    }

    await treasureHunt.save();

    res.status(200).json({
      success: true,
      message: treasureHunt.is_found ? 'Treasure found! Rewards distributed' : 'Key collected successfully',
      data: {
        keysCollected: treasureHunt.keys_collected_count,
        keysRequired: treasureHunt.keys_required,
        isFound: treasureHunt.is_found
      }
    });
  } catch (error) {
    console.error('Collect Treasure Key Error:', error);
    res.status(500).json({ success: false, message: 'Failed to collect key' });
  }
};

async function distributeTreasureRewards(treasureHunt) {
  const rewards = treasureHunt.rewards;
  const finders = treasureHunt.keys_collected;

  for (const finderId of finders) {
    const user = await User.findById(finderId);
    if (!user) continue;

    user.coins = (user.coins || 0) + (rewards.coins || 0);
    user.diamonds = (user.diamonds || 0) + (rewards.diamonds || 0);
    user.xp = (user.xp || 0) + (rewards.xp || 0);

    if (rewards.frames && rewards.frames.length > 0) {
      user.unlockedFrames = user.unlockedFrames || [];
      for (const frame of rewards.frames) {
        if (!user.unlockedFrames.includes(frame)) {
          user.unlockedFrames.push(frame);
        }
      }
    }

    if (rewards.badges && rewards.badges.length > 0) {
      user.unlockedBadges = user.unlockedBadges || [];
      for (const badge of rewards.badges) {
        if (!user.unlockedBadges.includes(badge)) {
          user.unlockedBadges.push(badge);
        }
      }
    }

    if (rewards.cars && rewards.cars.length > 0) {
      user.unlockedFrames = user.unlockedFrames || [];
      for (const car of rewards.cars) {
        if (!user.unlockedFrames.includes(car)) {
          user.unlockedFrames.push(car);
        }
      }
    }

    await user.save();
  }
}

exports.getActiveTreasureHunt = async (req, res) => {
  try {
    const { roomId } = req.query;
    const userId = req.user.userId;

    if (!roomId) {
      return res.status(400).json({ success: false, message: 'Room ID is required' });
    }

    const now = new Date();
    const treasureHunt = await TreasureHunt.findOne({
      room_id: roomId,
      is_active: true,
      is_found: false,
      start_time: { $lte: now },
      end_time: { $gte: now }
    }).populate('owner_id', 'name avatar uid');

    if (!treasureHunt) {
      return res.status(404).json({ success: false, message: 'No active treasure hunt in this room' });
    }

    const hasKey = treasureHunt.keys_collected.some(k => k.toString() === userId.toString());

    res.status(200).json({
      success: true,
      data: {
        ...treasureHunt.toObject(),
        hasKey,
        keysCollected: treasureHunt.keys_collected_count,
        keysRequired: treasureHunt.keys_required
      }
    });
  } catch (error) {
    console.error('Get Active Treasure Hunt Error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch treasure hunt' });
  }
};

exports.adminGetAllTreasureHunts = async (req, res) => {
  try {
    const treasureHunts = await TreasureHunt.find()
      .populate('owner_id', 'name avatar uid')
      .populate('event_id', 'event_name')
      .populate('found_by', 'name avatar uid')
      .sort({ created_at: -1 });

    res.status(200).json({ success: true, data: treasureHunts });
  } catch (error) {
    console.error('Admin Get Treasure Hunts Error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch treasure hunts' });
  }
};

// ─── FROM: inviteEventController.js ────────────────────────────────────────
const InviteEvent = require('../../models/InviteEvent');
const User = require('../../models/User');
const crypto = require('crypto');

// ─── GENERATE INVITE LINK ─────────────────────────────────────────────
exports.generateInviteLink = async (req, res) => {
  try {
    const userId = req.user.userId;
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    // Check for existing active invite
    let invite = await InviteEvent.findOne({ inviter_id: userId, status: 'pending', is_active: true });
    if (invite) {
      return res.status(200).json({
        success: true,
        data: {
          invite_code: invite.invite_code,
          invite_link: invite.invite_link,
          commission_percent: invite.commission_percent
        }
      });
    }

    // Generate unique invite code
    const inviteCode = user.uid || user._id.toString().slice(-8);
    const uniqueCode = `${inviteCode}_${crypto.randomBytes(3).toString('hex')}`;
    const appBaseUrl = process.env.APP_BASE_URL || 'https://arvindparty.app';
    const inviteLink = `${appBaseUrl}/invite?code=${uniqueCode}`;

    const commissionPercent = req.body.commission_percent || 5;

    invite = await InviteEvent.create({
      inviter_id: userId,
      invite_code: uniqueCode,
      invite_link: inviteLink,
      commission_percent: Math.min(Math.max(commissionPercent, 1), 20),
      expires_at: new Date(Date.now() + 365 * 24 * 60 * 60 * 1000), // 1 year
      metadata: {
        inviter_username: user.username || 'User'
      }
    });

    res.status(201).json({
      success: true,
      data: {
        invite_code: invite.invite_code,
        invite_link: invite.invite_link,
        commission_percent: invite.commission_percent
      }
    });
  } catch (error) {
    console.error('Generate Invite Error:', error);
    res.status(500).json({ success: false, message: 'Failed to generate invite link' });
  }
};

// ─── REGISTER VIA INVITE (When new user signs up with invite code) ────
exports.registerViaInvite = async (req, res) => {
  try {
    const { invite_code } = req.body;
    const newUserId = req.user.userId;

    if (!invite_code) {
      return res.status(400).json({ success: false, message: 'Invite code required' });
    }

    const invite = await InviteEvent.findOne({ invite_code, is_active: true, status: 'pending' });
    if (!invite) {
      return res.status(400).json({ success: false, message: 'Invalid or expired invite code' });
    }

    // Prevent self-invite
    if (invite.inviter_id.toString() === newUserId.toString()) {
      return res.status(400).json({ success: false, message: 'Cannot invite yourself' });
    }

    // Check if invitee already used
    if (invite.invitee_id) {
      return res.status(400).json({ success: false, message: 'Invite code already used' });
    }

    const newUser = await User.findById(newUserId);
    if (!newUser) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    invite.invitee_id = newUserId;
    invite.status = 'registered';
    invite.invitee_joined_at = new Date();
    invite.metadata.invitee_username = newUser.username || 'New User';
    await invite.save();

    // Give small reward to inviter for successful referral
    const inviter = await User.findById(invite.inviter_id);
    if (inviter) {
      const welcomeBonus = 10; // Small coins for referring
      inviter.coins = (inviter.coins || 0) + welcomeBonus;
      await inviter.save();
    }

    // Give new user welcome bonus
    newUser.coins = (newUser.coins || 0) + 5;
    await newUser.save();

    res.status(200).json({
      success: true,
      message: 'Registered via invite successfully',
      data: {
        inviter_username: invite.metadata.inviter_username,
        welcome_bonus: 5
      }
    });
  } catch (error) {
    console.error('Register via Invite Error:', error);
    res.status(500).json({ success: false, message: 'Failed to register via invite' });
  }
};

// ─── COMMISSION ON INVITEE RECHARGE ───────────────────────────────────
exports.processRechargeCommission = async (req, res) => {
  try {
    const { userId, rechargeAmount } = req.body;
    if (!userId || !rechargeAmount) {
      return res.status(400).json({ success: false, message: 'userId and rechargeAmount required' });
    }

    // Find invite where this user was invited via
    const invite = await InviteEvent.findOne({ invitee_id: userId, status: 'registered', is_active: true });
    if (!invite) {
      return res.status(200).json({ success: false, message: 'No invite referral found for this user' });
    }

    const inviter = await User.findById(invite.inviter_id);
    if (!inviter) {
      return res.status(404).json({ success: false, message: 'Inviter not found' });
    }

    const commissionPercent = invite.commission_percent;
    const commissionCoins = Math.floor((rechargeAmount * commissionPercent) / 100);

    inviter.coins = (inviter.coins || 0) + commissionCoins;
    await inviter.save();

    invite.status = 'commission_paid';
    invite.commission_coins_earned = commissionCoins;
    invite.invitee_recharge_amount = rechargeAmount;
    invite.invitee_recharged_at = new Date();
    invite.commission_paid_at = new Date();
    await invite.save();

    res.status(200).json({
      success: true,
      message: `Commission of ${commissionCoins} coins paid to inviter`,
      data: {
        inviter_id: invite.inviter_id,
        inviter_username: invite.metadata.inviter_username,
        commission_coins: commissionCoins,
        commission_percent: commissionPercent,
        recharge_amount: rechargeAmount
      }
    });
  } catch (error) {
    console.error('Process Recharge Commission Error:', error);
    res.status(500).json({ success: false, message: 'Failed to process commission' });
  }
};

// ─── GET USER INVITE STATS ────────────────────────────────────────────
exports.getMyInviteStats = async (req, res) => {
  try {
    const userId = req.user.userId;

    const totalInvites = await InviteEvent.countDocuments({ inviter_id: userId });
    const registeredCount = await InviteEvent.countDocuments({ inviter_id: userId, status: { $ne: 'pending' } });
    const rechargedCount = await InviteEvent.countDocuments({ inviter_id: userId, status: 'commission_paid' });
    const totalCommissions = await InviteEvent.aggregate([
      { $match: { inviter_id: userId, status: 'commission_paid' } },
      { $group: { _id: null, total: { $sum: '$commission_coins_earned' } } }
    ]);

    const activeInvite = await InviteEvent.findOne({ inviter_id: userId, status: 'pending', is_active: true })
      .select('invite_code invite_link commission_percent');

    res.status(200).json({
      success: true,
      data: {
        total_invites: totalInvites,
        registered_count: registeredCount,
        recharged_count: rechargedCount,
        total_commission_coins: totalCommissions.length > 0 ? totalCommissions[0].total : 0,
        active_invite: activeInvite || null
      }
    });
  } catch (error) {
    console.error('Get Invite Stats Error:', error);
    res.status(500).json({ success: false, message: 'Failed to get invite stats' });
  }
};

// ─── ADMIN: GET ALL INVITES ───────────────────────────────────────────
exports.adminGetAllInvites = async (req, res) => {
  try {
    const { page = 1, limit = 50, status } = req.query;
    const skip = (parseInt(page) - 1) * parseInt(limit);

    const query = {};
    if (status) query.status = status;

    const invites = await InviteEvent.find(query)
      .populate('inviter_id', 'username uid')
      .populate('invitee_id', 'username uid')
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(parseInt(limit));

    const total = await InviteEvent.countDocuments(query);

    res.status(200).json({
      success: true,
      data: invites,
      pagination: { page: parseInt(page), limit: parseInt(limit), total, pages: Math.ceil(total / parseInt(limit)) }
    });
  } catch (error) {
    console.error('Admin Get Invites Error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch invites' });
  }
};

// ─── ADMIN: UPDATE COMMISSION PERCENT ─────────────────────────────────
exports.adminUpdateCommission = async (req, res) => {
  try {
    const { inviteId } = req.params;
    const { commission_percent } = req.body;

    if (!commission_percent || commission_percent < 1 || commission_percent > 50) {
      return res.status(400).json({ success: false, message: 'Commission must be between 1-50%' });
    }

    const invite = await InviteEvent.findByIdAndUpdate(
      inviteId,
      { commission_percent },
      { new: true }
    );

    if (!invite) {
      return res.status(404).json({ success: false, message: 'Invite not found' });
    }

    res.status(200).json({ success: true, data: invite });
  } catch (error) {
    console.error('Admin Update Commission Error:', error);
    res.status(500).json({ success: false, message: 'Failed to update commission' });
  }
};