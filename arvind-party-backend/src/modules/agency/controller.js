// =========================================================================
// MODULE: AGENCY — CONTROLLER
// =========================================================================


// ─── FROM: agencyController.js ────────────────────────────────────────
const User = require('../../models/User');
const Agency = require('../../models/Agency');
const redisRankingIntegration = require('../../services/redisRankingIntegration');

// ─────────────────────────────────────────────────────────────────────────
// GET CURRENT USER'S AGENCY
// GET /api/agency
// ─────────────────────────────────────────────────────────────────────────
exports.getMyAgency = async (req, res) => {
  try {
    const userId = req.user.id || req.user.userId;
    const agency = await Agency.findOne({ hosts: userId }).populate('owner', 'name avatar');
    if (agency) {
      res.status(200).json({ success: true, agency, message: "Agency data loaded" });
    } else {
      res.status(200).json({ success: true, agency: null, message: "Not part of an agency" });
    }
  } catch (error) {
    console.error('Get Agency Error:', error);
    res.status(500).json({ success: false, message: 'Failed to load agency data' });
  }
};

// ─────────────────────────────────────────────────────────────────────────
// CREATE AGENCY
// POST /api/agency/create
// ─────────────────────────────────────────────────────────────────────────
exports.createAgency = async (req, res) => {
  try {
    const { name, description, logo } = req.body;
    const userId = req.user.id || req.user.userId;

    if (!name) {
      return res.status(400).json({ success: false, message: 'Agency name is required' });
    }

    // Check if user already owns an agency
    const existing = await Agency.findOne({ owner: userId });
    if (existing) {
      return res.status(400).json({ success: false, message: 'You already own an agency' });
    }

    const agency = await Agency.create({
      name,
      owner: userId,
      ownerUid: req.user.uid || userId.toString(),
      description: description || '',
      logo: logo || '',
      hosts: [userId],
      totalHosts: 1,
    });

    const populated = await Agency.findById(agency._id).populate('owner', 'name avatar');

    // Initialize agency in Redis rankings
    redisRankingIntegration.onAgencyDiamondEarned(agency._id, 0).catch(err => console.error('Redis agency init failed:', err.message));

    res.status(201).json({
      success: true,
      agency: populated,
      message: 'Agency created successfully'
    });
  } catch (error) {
    console.error('Create Agency Error:', error);
    if (error.code === 11000) {
      return res.status(400).json({ success: false, message: 'Agency name already exists' });
    }
    res.status(500).json({ success: false, message: 'Failed to create agency' });
  }
};

// ─────────────────────────────────────────────────────────────────────────
// LIST AGENCY HOSTS/MEMBERS
// GET /api/agency/hosts
// ─────────────────────────────────────────────────────────────────────────
exports.listHosts = async (req, res) => {
  try {
    const userId = req.user.id || req.user.userId;
    const agency = await Agency.findOne({ hosts: userId })
      .populate('hosts', 'name avatar arvindId coins diamonds');

    if (!agency) {
      return res.status(404).json({ success: false, message: 'Agency not found' });
    }

    const hosts = agency.hosts.map(host => {
      if (typeof host === 'object' && host !== null) {
        return {
          _id: host._id,
          name: host.name,
          avatar: host.avatar,
          arvindId: host.arvindId,
          earnings: host.coins || 0,
          role: host._id.toString() === agency.owner.toString() ? 'owner' : 'host'
        };
      }
      return host;
    });

    res.status(200).json({
      success: true,
      data: hosts,
      count: hosts.length
    });
  } catch (error) {
    console.error('List Hosts Error:', error);
    res.status(500).json({ success: false, message: 'Failed to list agency hosts' });
  }
};

// ─────────────────────────────────────────────────────────────────────────
// GET AGENCY EARNINGS
// GET /api/agency/earnings
// ─────────────────────────────────────────────────────────────────────────
exports.getEarnings = async (req, res) => {
  try {
    const userId = req.user.id || req.user.userId;
    const agency = await Agency.findOne({ hosts: userId });

    if (!agency) {
      return res.status(404).json({ success: false, message: 'Agency not found' });
    }

    const totalEarnings = agency.earnings || 0;
    const totalHosts = agency.totalHosts || agency.hosts.length;

    res.status(200).json({
      success: true,
      data: {
        agencyId: agency._id,
        agencyName: agency.name,
        totalEarnings,
        totalHosts,
        commissionRate: 0.1, // 10% commission
        thisMonthEarnings: Math.floor(totalEarnings * 0.3), // ~30% this month estimate
        lastMonthEarnings: Math.floor(totalEarnings * 0.2),  // ~20% last month estimate
        currency: 'diamonds'
      }
    });
  } catch (error) {
    console.error('Get Earnings Error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch agency earnings' });
  }
};

// ─────────────────────────────────────────────────────────────────────────
// APPLY / JOIN AGENCY
// POST /api/agency/apply
// ─────────────────────────────────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────────────
// ADMIN: LIST ALL AGENCIES
// GET /api/admin/agencies
// ─────────────────────────────────────────────────────────────────────────
exports.getAgencies = async (req, res) => {
  try {
    const agencies = await Agency.find()
      .sort({ createdAt: -1 })
      .lean();
    return res.status(200).json({ success: true, data: agencies });
  } catch (error) {
    console.error('Get Agencies Error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch agencies' });
  }
};

// ─────────────────────────────────────────────────────────────────────────
// ADMIN: APPROVE AGENCY
// POST /api/admin/agencies/approve/:id
// ─────────────────────────────────────────────────────────────────────────
exports.approveAgency = async (req, res) => {
  try {
    const { id } = req.params;
    const agency = await Agency.findByIdAndUpdate(id, { isApproved: true, status: 'active' }, { new: true });
    if (!agency) {
      return res.status(404).json({ success: false, message: 'Agency not found' });
    }
    return res.status(200).json({ success: true, message: 'Agency approved successfully', agency });
  } catch (error) {
    console.error('Approve Agency Error:', error);
    res.status(500).json({ success: false, message: 'Failed to approve agency' });
  }
};

// ─────────────────────────────────────────────────────────────────────────
// ADMIN: REVOKE AGENCY
// POST /api/admin/agencies/revoke/:id
// ─────────────────────────────────────────────────────────────────────────
exports.revokeAgency = async (req, res) => {
  try {
    const { id } = req.params;
    const agency = await Agency.findByIdAndUpdate(id, { isApproved: false, status: 'revoked' }, { new: true });
    if (!agency) {
      return res.status(404).json({ success: false, message: 'Agency not found' });
    }
    return res.status(200).json({ success: true, message: 'Agency revoked successfully', agency });
  } catch (error) {
    console.error('Revoke Agency Error:', error);
    res.status(500).json({ success: false, message: 'Failed to revoke agency' });
  }
};

exports.applyForAgency = async (req, res) => {
  try {
    const { agencyId } = req.body;
    const userId = req.user.id || req.user.userId;

    const agency = await Agency.findById(agencyId);
    if (!agency) return res.status(404).json({ success: false, message: 'Agency not found' });

    if (agency.hosts.includes(userId)) {
      return res.status(400).json({ success: false, message: 'Already a member of this agency' });
    }

    const existingRequest = await HostRequest.findOne({ agencyId, userId });
    if (existingRequest && existingRequest.status === 'pending') {
      return res.status(400).json({ success: false, message: 'Request already pending' });
    }

    const hostRequest = await HostRequest.create({
      agencyId,
      userId,
      status: 'approved',
      requestedBy: userId,
      applicationMessage: '',
      reviewedBy: agency.owner,
      reviewedAt: new Date(),
      reviewNotes: 'Auto-approved via apply flow',
    });

    agency.hosts.push(userId);
    agency.totalHosts = agency.hosts.length;
    await agency.save();

    await User.findByIdAndUpdate(userId, { agencyId: agency._id, role: 'host' });

    // Update agency ranking
    redisRankingIntegration.onAgencyDiamondEarned(agency._id, 0).catch(err => console.error('Redis agency join failed:', err.message));

    res.status(200).json({ success: true, agency, message: 'Joined agency successfully' });
  } catch (error) {
    console.error('Apply Agency Error:', error);
    res.status(500).json({ success: false, message: 'Failed to apply to agency' });
  }
};

// ─────────────────────────────────────────────────────────────────────────
// AGENCY OWNER: SEND HOST REQUEST TO USER BY UID
// POST /api/agency/hosts/request
// ─────────────────────────────────────────────────────────────────────────
exports.sendHostRequest = async (req, res) => {
  try {
    const userId = req.user.id || req.user.userId;
    const { targetUid, message } = req.body;

    if (!targetUid) return res.status(400).json({ success: false, message: 'Target UID is required' });

    const agency = await Agency.findOne({ owner: userId });
    if (!agency) return res.status(404).json({ success: false, message: 'Agency not found' });

    const targetUser = await User.findOne({ uid: targetUid });
    if (!targetUser) return res.status(404).json({ success: false, message: 'User not found with this UID' });

    if (agency.hosts.includes(targetUser._id)) {
      return res.status(400).json({ success: false, message: 'User is already a host in your agency' });
    }

    const existing = await HostRequest.findOne({ agencyId: agency._id, userId: targetUser._id });
    if (existing && existing.status === 'pending') {
      return res.status(400).json({ success: false, message: 'Request already pending for this user' });
    }

    const hostRequest = await HostRequest.create({
      agencyId: agency._id,
      userId: targetUser._id,
      status: 'pending',
      requestedBy: userId,
      applicationMessage: message || '',
    });

    res.status(201).json({ success: true, hostRequest, message: 'Host request sent' });
  } catch (error) {
    console.error('Send Host Request Error:', error);
    res.status(500).json({ success: false, message: 'Failed to send host request' });
  }
};

// ─────────────────────────────────────────────────────────────────────────
// AGENCY OWNER: LIST PENDING HOST REQUESTS
// GET /api/agency/hosts/requests
// ─────────────────────────────────────────────────────────────────────────
exports.getHostRequests = async (req, res) => {
  try {
    const userId = req.user.id || req.user.userId;
    const agency = await Agency.findOne({ owner: userId });
    if (!agency) return res.status(404).json({ success: false, message: 'Agency not found' });

    const requests = await HostRequest.find({ agencyId: agency._id, status: 'pending' })
      .populate('userId', 'name avatar arvindId uid')
      .sort({ createdAt: -1 });

    res.status(200).json({ success: true, data: requests, count: requests.length });
  } catch (error) {
    console.error('Get Host Requests Error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch host requests' });
  }
};

// ─────────────────────────────────────────────────────────────────────────
// AGENCY OWNER: APPROVE HOST REQUEST
// POST /api/agency/hosts/approve/:requestId
// ─────────────────────────────────────────────────────────────────────────
exports.approveHostRequest = async (req, res) => {
  try {
    const userId = req.user.id || req.user.userId;
    const { requestId } = req.params;
    const { reviewNotes } = req.body;

    const agency = await Agency.findOne({ owner: userId });
    if (!agency) return res.status(404).json({ success: false, message: 'Agency not found' });

    const request = await HostRequest.findById(requestId);
    if (!request) return res.status(404).json({ success: false, message: 'Request not found' });
    if (request.agencyId.toString() !== agency._id.toString()) return res.status(403).json({ success: false, message: 'Not authorized' });
    if (request.status !== 'pending') return res.status(400).json({ success: false, message: 'Request already processed' });

    request.status = 'approved';
    request.reviewedBy = userId;
    request.reviewedAt = new Date();
    request.reviewNotes = reviewNotes || '';
    await request.save();

    if (!agency.hosts.includes(request.userId)) {
      agency.hosts.push(request.userId);
      agency.totalHosts = agency.hosts.length;
      await agency.save();
    }

    await User.findByIdAndUpdate(request.userId, { agencyId: agency._id, role: 'host' });

    // Update agency ranking with new host
    redisRankingIntegration.onAgencyDiamondEarned(agency._id, 0).catch(err => console.error('Redis agency host add failed:', err.message));

    res.status(200).json({ success: true, message: 'Host request approved' });
  } catch (error) {
    console.error('Approve Host Request Error:', error);
    res.status(500).json({ success: false, message: 'Failed to approve request' });
  }
};

// ─────────────────────────────────────────────────────────────────────────
// AGENCY OWNER: REJECT HOST REQUEST
// POST /api/agency/hosts/reject/:requestId
// ─────────────────────────────────────────────────────────────────────────
exports.rejectHostRequest = async (req, res) => {
  try {
    const userId = req.user.id || req.user.userId;
    const { requestId } = req.params;
    const { reviewNotes } = req.body;

    const agency = await Agency.findOne({ owner: userId });
    if (!agency) return res.status(404).json({ success: false, message: 'Agency not found' });

    const request = await HostRequest.findById(requestId);
    if (!request) return res.status(404).json({ success: false, message: 'Request not found' });
    if (request.agencyId.toString() !== agency._id.toString()) return res.status(403).json({ success: false, message: 'Not authorized' });
    if (request.status !== 'pending') return res.status(400).json({ success: false, message: 'Request already processed' });

    request.status = 'rejected';
    request.reviewedBy = userId;
    request.reviewedAt = new Date();
    request.reviewNotes = reviewNotes || '';
    await request.save();

    res.status(200).json({ success: true, message: 'Host request rejected' });
  } catch (error) {
    console.error('Reject Host Request Error:', error);
    res.status(500).json({ success: false, message: 'Failed to reject request' });
  }
};

// ─────────────────────────────────────────────────────────────────────────
// AGENCY OWNER: REMOVE HOST FROM AGENCY
// POST /api/agency/hosts/remove/:hostId
// ─────────────────────────────────────────────────────────────────────────
exports.removeHost = async (req, res) => {
  try {
    const userId = req.user.id || req.user.userId;
    const { hostId } = req.params;

    const agency = await Agency.findOne({ owner: userId });
    if (!agency) return res.status(404).json({ success: false, message: 'Agency not found' });

    if (agency.owner.toString() === hostId) {
      return res.status(400).json({ success: false, message: 'Cannot remove agency owner' });
    }

    agency.hosts = agency.hosts.filter(h => h.toString() !== hostId);
    agency.totalHosts = agency.hosts.length;
    await agency.save();

    await User.findByIdAndUpdate(hostId, { $unset: { agencyId: 1 }, role: 'user' });

    // Update agency ranking after host removal
    redisRankingIntegration.onAgencyDiamondEarned(agency._id, 0).catch(err => console.error('Redis agency host remove failed:', err.message));

    res.status(200).json({ success: true, message: 'Host removed from agency' });
  } catch (error) {
    console.error('Remove Host Error:', error);
    res.status(500).json({ success: false, message: 'Failed to remove host' });
  }
};


// ─── FROM: agentController.js ────────────────────────────────────────
const mongoose = require('mongoose');
const User = require('../../models/User');
const Agency = require('../../models/Agency');
const Agent = require('../../models/Agent');
const AuditLog = require('../../models/AuditLog');

// ─────────────────────────────────────────────────────────────────────────
// AGENCY OWNER: ADD NEW AGENT (RECRUITER)
// POST /api/agency/agents/add
// ─────────────────────────────────────────────────────────────────────────
exports.addAgent = async (req, res) => {
  try {
    const userId = req.user.id || req.user.userId;
    const { uid, commissionRate } = req.body;

    if (!uid) return res.status(400).json({ success: false, message: 'Agent UID is required' });

    const agency = await Agency.findOne({ hosts: userId });
    if (!agency) return res.status(404).json({ success: false, message: 'Agency not found' });
    if (agency.owner.toString() !== userId.toString()) {
      return res.status(403).json({ success: false, message: 'Only agency owner can add agents' });
    }

    const agentUser = await User.findOne({ uid });
    if (!agentUser) return res.status(404).json({ success: false, message: 'User not found with this UID' });
    if (!agency.hosts.includes(agentUser._id)) {
      return res.status(400).json({ success: false, message: 'User must be a host in the agency first' });
    }

    const existing = await Agent.findOne({ agencyId: agency._id, uid });
    if (existing) return res.status(400).json({ success: false, message: 'Agent already exists' });

    const agent = await Agent.create({
      agencyId: agency._id,
      recruiterId: agentUser._id,
      uid: agentUser.uid,
      name: agentUser.name,
      avatar: agentUser.avatar,
      commissionRate: commissionRate || 5,
    });

    res.status(201).json({ success: true, agent, message: 'Agent added successfully' });
  } catch (error) {
    console.error('Add Agent Error:', error);
    res.status(500).json({ success: false, message: 'Failed to add agent' });
  }
};

// ─────────────────────────────────────────────────────────────────────────
// AGENCY OWNER: LIST ALL AGENTS
// GET /api/agency/agents
// ─────────────────────────────────────────────────────────────────────────
exports.listAgents = async (req, res) => {
  try {
    const userId = req.user.id || req.user.userId;
    const agency = await Agency.findOne({ hosts: userId });
    if (!agency) return res.status(404).json({ success: false, message: 'Agency not found' });

    const agents = await Agent.find({ agencyId: agency._id })
      .populate('recruiterId', 'name avatar arvindId')
      .sort({ createdAt: -1 });

    res.status(200).json({ success: true, data: agents, count: agents.length });
  } catch (error) {
    console.error('List Agents Error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch agents' });
  }
};

// ─────────────────────────────────────────────────────────────────────────
// AGENCY OWNER: UPDATE AGENT COMMISSION RATE
// PUT /api/agency/agents/:agentId
// ─────────────────────────────────────────────────────────────────────────
exports.updateAgent = async (req, res) => {
  try {
    const userId = req.user.id || req.user.userId;
    const { agentId } = req.params;
    const { commissionRate, isActive } = req.body;

    const agency = await Agency.findOne({ hosts: userId });
    if (!agency) return res.status(404).json({ success: false, message: 'Agency not found' });
    if (agency.owner.toString() !== userId.toString()) {
      return res.status(403).json({ success: false, message: 'Only agency owner can update agents' });
    }

    const agent = await Agent.findOne({ _id: agentId, agencyId: agency._id });
    if (!agent) return res.status(404).json({ success: false, message: 'Agent not found' });

    if (commissionRate !== undefined) agent.commissionRate = commissionRate;
    if (isActive !== undefined) agent.isActive = isActive;
    await agent.save();

    res.status(200).json({ success: true, agent, message: 'Agent updated' });
  } catch (error) {
    console.error('Update Agent Error:', error);
    res.status(500).json({ success: false, message: 'Failed to update agent' });
  }
};

// ─────────────────────────────────────────────────────────────────────────
// AGENCY OWNER: REMOVE AGENT
// DELETE /api/agency/agents/:agentId
// ─────────────────────────────────────────────────────────────────────────
exports.deleteAgent = async (req, res) => {
  try {
    const userId = req.user.id || req.user.userId;
    const { agentId } = req.params;

    const agency = await Agency.findOne({ hosts: userId });
    if (!agency) return res.status(404).json({ success: false, message: 'Agency not found' });
    if (agency.owner.toString() !== userId.toString()) {
      return res.status(403).json({ success: false, message: 'Only agency owner can remove agents' });
    }

    const agent = await Agent.findOneAndDelete({ _id: agentId, agencyId: agency._id });
    if (!agent) return res.status(404).json({ success: false, message: 'Agent not found' });

    res.status(200).json({ success: true, message: 'Agent removed successfully' });
  } catch (error) {
    console.error('Delete Agent Error:', error);
    res.status(500).json({ success: false, message: 'Failed to remove agent' });
  }
};

// ─────────────────────────────────────────────────────────────────────────
// AGENCY OWNER: GET AGENT PERFORMANCE
// GET /api/agency/agents/:agentId/performance
// ─────────────────────────────────────────────────────────────────────────
exports.getAgentPerformance = async (req, res) => {
  try {
    const userId = req.user.id || req.user.userId;
    const { agentId } = req.params;

    const agency = await Agency.findOne({ hosts: userId });
    if (!agency) return res.status(404).json({ success: false, message: 'Agency not found' });

    const agent = await Agent.findOne({ _id: agentId, agencyId: agency._id }).populate('recruiterId', 'name avatar arvindId');
    if (!agent) return res.status(404).json({ success: false, message: 'Agent not found' });

    const recruitedHosts = await User.find({ referredBy: agent.recruiterId?._id, agencyId: agency._id })
      .select('name avatar arvindId createdAt');

    const performance = {
      ...agent.toObject(),
      recruitedHosts,
      totalEarningsGenerated: agent.totalEarningsGenerated || 0,
      commissionRate: agent.commissionRate || 5,
    };

    res.status(200).json({ success: true, data: performance });
  } catch (error) {
    console.error('Agent Performance Error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch agent performance' });
  }
};

module.exports = {};

// ─── FROM: salaryController.js ────────────────────────────────────────
const mongoose = require('mongoose');
const User = require('../../models/User');
const Attendance = require('../../models/Attendance');
const Gift = require('../../models/Gift');
const SalaryRecord = require('../../models/SalaryRecord');
const Penalty = require('../../models/Penalty');
const Bonus = require('../../models/Bonus');
const AgencyWallet = require('../../models/AgencyWallet');
const Transaction = require('../../models/Transaction');
const AuditLog = require('../../models/AuditLog');

// ─────────────────────────────────────────────────────────────────────────
// CRON: CALCULATE MONTHLY SALARY FOR ALL HOSTS IN AN AGENCY
// POST /api/agency/salary/calculate-monthly
// ─────────────────────────────────────────────────────────────────────────
exports.calculateMonthlySalary = async (req, res) => {
  try {
    const { agencyId } = req.params;
    const { month, year } = req.query;

    const m = parseInt(month) || new Date().getMonth() + 1;
    const y = parseInt(year) || new Date().getFullYear() - 1; // previous month by default for cron

    const startDate = new Date(y, m - 1, 1);
    const endDate = new Date(y, m, 0, 23, 59, 59);

    const agency = await Agency.findById(agencyId);
    if (!agency) return res.status(404).json({ success: false, message: 'Agency not found' });

    const hostIds = agency.hosts;
    const attendances = await Attendance.find({
      agencyId: agency._id,
      date: { $gte: startDate, $lte: endDate },
      userId: { $in: hostIds },
    }).lean();

    const gifts = await Gift.find({
      toUserId: { $in: hostIds },
      createdAt: { $gte: startDate, $lte: endDate },
    }).lean();

    const penalties = await Penalty.find({
      agencyId: agency._id,
      month: m,
      year: y,
      userId: { $in: hostIds },
    }).lean();

    const bonuses = await Bonus.find({
      agencyId: agency._id,
      month: m,
      year: y,
      userId: { $in: hostIds },
    }).lean();

    const summaryMap = {};
    hostIds.forEach(id => {
      summaryMap[id.toString()] = {
        userId: id,
        attendanceDays: 0,
        totalMinutes: 0,
        giftsReceived: 0,
        giftsValue: 0,
      };
    });

    attendances.forEach(att => {
      const uid = att.userId.toString();
      if (!summaryMap[uid]) summaryMap[uid] = { userId: att.userId, attendanceDays: 0, totalMinutes: 0, giftsReceived: 0, giftsValue: 0 };
      summaryMap[uid].attendanceDays += att.isValidDay ? 1 : 0;
      summaryMap[uid].totalMinutes += att.totalDailyMinutes;
    });

    gifts.forEach(g => {
      const uid = g.toUserId.toString();
      if (!summaryMap[uid]) summaryMap[uid] = { userId: g.toUserId, attendanceDays: 0, totalMinutes: 0, giftsReceived: 0, giftsValue: 0 };
      summaryMap[uid].giftsReceived += 1;
      summaryMap[uid].giftsValue += g.diamondValue || 0;
    });

    const salaryRecords = [];
    for (const hostId of hostIds) {
      const uid = hostId.toString();
      const user = await User.findById(hostId).select('name coins diamonds hostLevel');
      const data = summaryMap[uid] || { attendanceDays: 0, totalMinutes: 0, giftsReceived: 0, giftsValue: 0 };

      const hostPenalties = penalties.filter(p => p.userId.toString() === uid);
      const hostBonuses = bonuses.filter(b => b.userId.toString() === uid);

      let baseSalary = 2000;
      const bonusesTotal = hostBonuses.reduce((sum, b) => sum + (b.type === 'coins' ? b.amount : 0), 0);
      const penaltiesTotal = hostPenalties.reduce((sum, p) => {
        if (p.isPercentage) return sum + (baseSalary * p.amount / 100);
        return sum + p.amount;
      }, 0);

      const attendanceBonus = data.attendanceDays >= 25 ? 500 : data.attendanceDays >= 20 ? 300 : 0;
      const giftCommission = Math.floor(data.giftsValue * 0.05);
      const totalPaid = Math.max(0, baseSalary + bonusesTotal + attendanceBonus + giftCommission - penaltiesTotal);

      const record = await SalaryRecord.findOneAndUpdate(
        { userId: hostId, month: m, year: y },
        {
          userId: hostId,
          agencyId: agency._id,
          month: m,
          year: y,
          baseSalary,
          targetBonus: 0,
          attendanceBonus,
          giftCommission,
          penaltyDeduction: penaltiesTotal,
          bonus: bonusesTotal,
          totalPaid,
          attendanceDays: data.attendanceDays,
          attendanceMinutes: data.totalMinutes,
          giftsReceived: data.giftsReceived,
          hostLevel: user?.hostLevel || 'bronze',
          targetAchieved: data.attendanceDays >= 25,
          paymentStatus: 'pending',
          notes: `Auto-generated salary for ${m}/${y}`,
        },
        { new: true, upsert: true }
      );

      salaryRecords.push(record);
    }

    const wallet = await AgencyWallet.findOne({ agencyId: agency._id });
    const totalSalary = salaryRecords.reduce((sum, r) => sum + r.totalPaid, 0);

    if (wallet && wallet.balance >= totalSalary) {
      wallet.balance -= totalSalary;
      wallet.totalWithdrawn += totalSalary;
      await wallet.save();

      for (const record of salaryRecords) {
        if (record.totalPaid > 0) {
          record.paymentStatus = 'paid';
          record.paidAt = new Date();
          await record.save();

          await User.findByIdAndUpdate(record.userId, { $inc: { coins: record.totalPaid } });

          await Transaction.create({
            userId: record.userId,
            agencyId: agency._id,
            type: 'salary',
            amount: record.totalPaid,
            currency: 'coins',
            description: `Salary ${m}/${y}`,
            status: 'completed',
          });
        } else {
          record.paymentStatus = 'cancelled';
          await record.save();
        }
      }

      await AuditLog.create({
        userId: req.user?.id || null,
        action: 'salary_paid',
        targetId: agency._id,
        metadata: { month: m, year: y, totalSalary, count: salaryRecords.length },
        ip: req.ip,
      });
    }

    res.status(200).json({
      success: true,
      message: 'Monthly salary calculated',
      data: {
        month: m,
        year: y,
        totalSalary,
        records: salaryRecords.length,
        agencyBalance: wallet ? wallet.balance : 0,
      },
    });
  } catch (error) {
    console.error('Calculate Salary Error:', error);
    res.status(500).json({ success: false, message: 'Failed to calculate monthly salary' });
  }
};

// ─────────────────────────────────────────────────────────────────────────
// AGENCY: GET SALARY HISTORY
// GET /api/agency/salary/history
// ─────────────────────────────────────────────────────────────────────────
exports.getSalaryHistory = async (req, res) => {
  try {
    const userId = req.user.id || req.user.userId;
    const { month, year, hostId } = req.query;

    const agency = await Agency.findOne({ hosts: userId });
    if (!agency) return res.status(404).json({ success: false, message: 'Agency not found' });

    const query = { agencyId: agency._id };
    if (month) query.month = parseInt(month);
    if (year) query.year = parseInt(year);
    if (hostId) query.userId = hostId;

    const records = await SalaryRecord.find(query)
      .populate('userId', 'name avatar arvindId')
      .sort({ year: -1, month: -1 });

    res.status(200).json({ success: true, data: records, count: records.length });
  } catch (error) {
    console.error('Salary History Error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch salary history' });
  }
};

// ─────────────────────────────────────────────────────────────────────────
// AGENCY: GET SINGLE HOST SALARY DETAIL
// GET /api/agency/salary/detail/:hostId
// ─────────────────────────────────────────────────────────────────────────
exports.getHostSalaryDetail = async (req, res) => {
  try {
    const userId = req.user.id || req.user.userId;
    const { hostId } = req.params;

    const agency = await Agency.findOne({ hosts: userId });
    if (!agency) return res.status(404).json({ success: false, message: 'Agency not found' });
    if (!agency.hosts.map(h => h.toString()).includes(hostId)) {
      return res.status(403).json({ success: false, message: 'Host not in your agency' });
    }

    const user = await User.findById(hostId).select('name avatar arvindId hostLevel');
    const currentMonth = new Date().getMonth() + 1;
    const currentYear = new Date().getFullYear();

    const currentSalary = await SalaryRecord.findOne({
      userId: hostId,
      agencyId: agency._id,
      month: currentMonth,
      year: currentYear,
    });

    const recentRecords = await SalaryRecord.find({ userId: hostId, agencyId: agency._id })
      .sort({ year: -1, month: -1 })
      .limit(6);

    res.status(200).json({
      success: true,
      data: {
        user,
        currentSalary: currentSalary || null,
        history: recentRecords,
      },
    });
  } catch (error) {
    console.error('Host Salary Detail Error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch salary detail' });
  }
};

module.exports = {};

// ─── FROM: attendanceController.js ────────────────────────────────────────
const Attendance = require('../../models/Attendance');
const Agency = require('../../models/Agency');
const User = require('../../models/User');
const AuditLog = require('../../models/AuditLog');

// ─────────────────────────────────────────────────────────────────────────
// HOST: START LIVE SESSION
// POST /api/agency/attendance/start
// ─────────────────────────────────────────────────────────────────────────
exports.startSession = async (req, res) => {
  try {
    const userId = req.user.id || req.user.userId;
    const { roomId } = req.body;

    const user = await User.findById(userId);
    const agency = await Agency.findOne({ hosts: userId });
    if (!agency) return res.status(404).json({ success: false, message: 'Not part of any agency' });
    if (user.role !== 'host') return res.status(403).json({ success: false, message: 'Only hosts can start attendance' });

    const now = new Date();
    const dayStart = new Date(now.getFullYear(), now.getMonth(), now.getDate());

    let attendance = await Attendance.findOne({ userId, date: dayStart });
    if (!attendance) {
      attendance = await Attendance.create({
        userId,
        agencyId: agency._id,
        date: dayStart,
        sessionStart: now,
        durationMinutes: 0,
        roomId: roomId || null,
        isPresent: true,
        isValidDay: false,
        totalDailyMinutes: 0,
      });
    } else if (attendance.sessionEnd && attendance.durationMinutes >= 120) {
      return res.status(400).json({ success: false, message: 'Attendance already completed for today' });
    } else {
      attendance.sessionStart = now;
      attendance.roomId = roomId || attendance.roomId;
      await attendance.save();
    }

    await AuditLog.create({
      userId,
      action: 'attendance_start',
      targetId: attendance._id,
      metadata: { roomId, agencyId: agency._id.toString() },
      ip: req.ip,
    });

    res.status(200).json({ success: true, attendance, message: 'Attendance session started' });
  } catch (error) {
    console.error('Start Session Error:', error);
    res.status(500).json({ success: false, message: 'Failed to start attendance' });
  }
};

// ─────────────────────────────────────────────────────────────────────────
// HOST: END LIVE SESSION
// POST /api/agency/attendance/end
// ─────────────────────────────────────────────────────────────────────────
exports.endSession = async (req, res) => {
  try {
    const userId = req.user.id || req.user.userId;
    const now = new Date();
    const dayStart = new Date(now.getFullYear(), now.getMonth(), now.getDate());

    const attendance = await Attendance.findOne({ userId, date: dayStart });
    if (!attendance) return res.status(404).json({ success: false, message: 'No active session found' });
    if (!attendance.sessionStart) return res.status(400).json({ success: false, message: 'Session not started' });
    if (attendance.sessionEnd) return res.status(400).json({ success: false, message: 'Session already ended' });

    attendance.sessionEnd = now;
    const sessionMins = Math.floor((now - attendance.sessionStart) / (1000 * 60));
    attendance.durationMinutes += sessionMins;
    attendance.totalDailyMinutes += sessionMins;

    if (attendance.totalDailyMinutes >= 120) {
      attendance.isValidDay = true;
    }

    await attendance.save();

    const agency = await Agency.findOne({ hosts: userId });
    if (agency && ioInstance) {
      ioInstance.to(`agency_${agency._id}`).emit('attendance_update', {
        userId,
        date: dayStart.toISOString(),
        totalDailyMinutes: attendance.totalDailyMinutes,
        isValidDay: attendance.isValidDay,
      });
    }

    res.status(200).json({
      success: true,
      attendance,
      message: 'Attendance session ended',
      todayMinutes: attendance.totalDailyMinutes,
      isValidDay: attendance.isValidDay,
    });
  } catch (error) {
    console.error('End Session Error:', error);
    res.status(500).json({ success: false, message: 'Failed to end attendance' });
  }
};

// ─────────────────────────────────────────────────────────────────────────
// AGENCY OWNER: GET ALL HOSTS LIVE ATTENDANCE
// GET /api/agency/attendance/live
// ─────────────────────────────────────────────────────────────────────────
exports.getLiveAttendance = async (req, res) => {
  try {
    const userId = req.user.id || req.user.userId;
    const agency = await Agency.findOne({ hosts: userId });
    if (!agency) return res.status(404).json({ success: false, message: 'Agency not found' });

    const hostIds = agency.hosts.map(h => h.toString());
    const todayStart = new Date();
    todayStart.setHours(0, 0, 0, 0);

    const todayAttendance = await Attendance.find({
      userId: { $in: hostIds },
      date: todayStart,
    }).populate('userId', 'name avatar arvindId');

    const hosts = await User.find({ _id: { $in: hostIds } }, 'name avatar arvindId').lean();

    const result = hosts.map(host => {
      const att = todayAttendance.find(a => a.userId._id.toString() === host._id.toString());
      return {
        ...host,
        status: att && att.sessionStart && !att.sessionEnd ? 'live' : (att && att.isValidDay ? 'done' : 'not_started'),
        minutesToday: att ? att.totalDailyMinutes : 0,
        isValidDay: att ? att.isValidDay : false,
      };
    });

    res.status(200).json({ success: true, data: result, count: result.length });
  } catch (error) {
    console.error('Live Attendance Error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch live attendance' });
  }
};

// ─────────────────────────────────────────────────────────────────────────
// AGENCY OWNER: GET MONTHLY ATTENDANCE REPORT
// GET /api/agency/attendance/monthly
// ─────────────────────────────────────────────────────────────────────────
exports.getMonthlyAttendance = async (req, res) => {
  try {
    const userId = req.user.id || req.user.userId;
    const { month, year } = req.query;

    const agency = await Agency.findOne({ hosts: userId });
    if (!agency) return res.status(404).json({ success: false, message: 'Agency not found' });

    const m = parseInt(month) || new Date().getMonth() + 1;
    const y = parseInt(year) || new Date().getFullYear();
    const startDate = new Date(y, m - 1, 1);
    const endDate = new Date(y, m, 0, 23, 59, 59);

    const records = await Attendance.find({
      agencyId: agency._id,
      date: { $gte: startDate, $lte: endDate },
    }).populate('userId', 'name avatar');

    const summary = {};
    records.forEach(rec => {
      const uid = rec.userId._id.toString();
      if (!summary[uid]) {
        summary[uid] = {
          userId: uid,
          name: rec.userId.name,
          avatar: rec.userId.avatar,
          totalMinutes: 0,
          validDays: 0,
          daysRecorded: 0,
        };
      }
      summary[uid].totalMinutes += rec.totalDailyMinutes;
      summary[uid].daysRecorded += 1;
      if (rec.isValidDay) summary[uid].validDays += 1;
    });

    const data = Object.values(summary);
    res.status(200).json({ success: true, data, count: data.length, month: m, year: y });
  } catch (error) {
    console.error('Monthly Attendance Error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch monthly attendance' });
  }
};

// ─────────────────────────────────────────────────────────────────────────
// AGENCY OWNER: GET HOST ATTENDANCE HISTORY
// GET /api/agency/attendance/history/:hostId
// ─────────────────────────────────────────────────────────────────────────
exports.getHostAttendanceHistory = async (req, res) => {
  try {
    const userId = req.user.id || req.user.userId;
    const { hostId } = req.params;

    const agency = await Agency.findOne({ hosts: userId });
    if (!agency) return res.status(404).json({ success: false, message: 'Agency not found' });
    if (!agency.hosts.includes(hostId)) return res.status(403).json({ success: false, message: 'Host not in agency' });

    const history = await Attendance.find({ userId: hostId })
      .sort({ date: -1 })
      .limit(90);

    res.status(200).json({ success: true, data: history, count: history.length });
  } catch (error) {
    console.error('Host History Error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch host history' });
  }
};

module.exports = { ioInstance: null };

// ─── FROM: bonusController.js ────────────────────────────────────────
const Bonus = require('../../models/Bonus');
const Agency = require('../../models/Agency');
const User = require('../../models/User');
const SalaryRecord = require('../../models/SalaryRecord');
const AuditLog = require('../../models/AuditLog');

// ─────────────────────────────────────────────────────────────────────────
// AGENCY OWNER: AWARD BONUS TO HOST
// POST /api/agency/bonus/award
// ─────────────────────────────────────────────────────────────────────────
exports.awardBonus = async (req, res) => {
  try {
    const userId = req.user.id || req.user.userId;
    const { hostId, reason, type, amount, vipTag, badgeId, month, year, notes } = req.body;

    if (!hostId || !reason || !amount) {
      return res.status(400).json({ success: false, message: 'hostId, reason and amount are required' });
    }

    const agency = await Agency.findOne({ hosts: userId });
    if (!agency) return res.status(404).json({ success: false, message: 'Agency not found' });
    if (agency.owner.toString() !== userId.toString()) {
      return res.status(403).json({ success: false, message: 'Only agency owner can award bonuses' });
    }
    if (!agency.hosts.map(h => h.toString()).includes(hostId)) {
      return res.status(403).json({ success: false, message: 'User is not a host in your agency' });
    }

    const m = month || new Date().getMonth() + 1;
    const y = year || new Date().getFullYear();

    const bonus = await Bonus.create({
      userId: hostId,
      agencyId: agency._id,
      awardedBy: userId,
      reason,
      type: type || 'coins',
      amount,
      vipTag: vipTag || '',
      badgeId: badgeId || '',
      month: m,
      year: y,
      notes: notes || '',
    });

    if (type === 'coins') {
      await User.findByIdAndUpdate(hostId, { $inc: { coins: amount } });
    }

    await AuditLog.create({
      userId,
      action: 'bonus_awarded',
      targetId: bonus._id,
      metadata: { hostId, agencyId: agency._id.toString(), amount, reason },
      ip: req.ip,
    });

    res.status(201).json({ success: true, bonus, message: 'Bonus awarded successfully' });
  } catch (error) {
    console.error('Award Bonus Error:', error);
    res.status(500).json({ success: false, message: 'Failed to award bonus' });
  }
};

// ─────────────────────────────────────────────────────────────────────────
// AGENCY OWNER: GET BONUSES FOR A HOST
// GET /api/agency/bonus/history/:hostId
// ─────────────────────────────────────────────────────────────────────────
exports.getHostBonuses = async (req, res) => {
  try {
    const userId = req.user.id || req.user.userId;
    const { hostId } = req.params;

    const agency = await Agency.findOne({ hosts: userId });
    if (!agency) return res.status(404).json({ success: false, message: 'Agency not found' });
    if (!agency.hosts.map(h => h.toString()).includes(hostId)) {
      return res.status(403).json({ success: false, message: 'Host not in agency' });
    }

    const bonuses = await Bonus.find({ userId: hostId, agencyId: agency._id })
      .sort({ createdAt: -1 })
      .limit(100);

    res.status(200).json({ success: true, data: bonuses, count: bonuses.length });
  } catch (error) {
    console.error('Get Host Bonuses Error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch bonuses' });
  }
};

// ─────────────────────────────────────────────────────────────────────────
// AGENCY OWNER: GET MONTHLY BONUS SUMMARY
// GET /api/agency/bonus/summary
// ─────────────────────────────────────────────────────────────────────────
exports.getMonthlyBonusSummary = async (req, res) => {
  try {
    const userId = req.user.id || req.user.userId;
    const { month, year } = req.query;

    const agency = await Agency.findOne({ hosts: userId });
    if (!agency) return res.status(404).json({ success: false, message: 'Agency not found' });

    const m = parseInt(month) || new Date().getMonth() + 1;
    const y = parseInt(year) || new Date().getFullYear();

    const bonuses = await Bonus.find({
      agencyId: agency._id,
      month: m,
      year: y,
    }).populate('userId', 'name avatar arvindId');

    const totalBonus = bonuses.reduce((sum, b) => sum + (b.type === 'coins' ? b.amount : 0), 0);

    res.status(200).json({
      success: true,
      data: bonuses,
      totalBonus,
      count: bonuses.length,
      month: m,
      year: y,
    });
  } catch (error) {
    console.error('Monthly Bonus Summary Error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch bonus summary' });
  }
};

// ─────────────────────────────────────────────────────────────────────────
// AGENCY OWNER: REMOVE BONUS
// DELETE /api/agency/bonus/:bonusId
// ─────────────────────────────────────────────────────────────────────────
exports.removeBonus = async (req, res) => {
  try {
    const userId = req.user.id || req.user.userId;
    const { bonusId } = req.params;

    const agency = await Agency.findOne({ hosts: userId });
    if (!agency) return res.status(404).json({ success: false, message: 'Agency not found' });
    if (agency.owner.toString() !== userId.toString()) {
      return res.status(403).json({ success: false, message: 'Only agency owner can remove bonuses' });
    }

    const bonus = await Bonus.findOneAndDelete({ _id: bonusId, agencyId: agency._id });
    if (!bonus) return res.status(404).json({ success: false, message: 'Bonus not found' });

    if (bonus.type === 'coins') {
      await User.findByIdAndUpdate(bonus.userId, { $inc: { coins: -bonus.amount } });
    }

    await AuditLog.create({
      userId,
      action: 'bonus_removed',
      targetId: bonusId,
      metadata: { hostId: bonus.userId.toString(), reason: bonus.reason },
      ip: req.ip,
    });

    res.status(200).json({ success: true, message: 'Bonus removed successfully' });
  } catch (error) {
    console.error('Remove Bonus Error:', error);
    res.status(500).json({ success: false, message: 'Failed to remove bonus' });
  }
};

module.exports = {};

// ─── FROM: penaltyController.js ────────────────────────────────────────
const mongoose = require('mongoose');
const Penalty = require('../../models/Penalty');
const User = require('../../models/User');
const Agency = require('../../models/Agency');
const SalaryRecord = require('../../models/SalaryRecord');
const AuditLog = require('../../models/AuditLog');

// ─────────────────────────────────────────────────────────────────────────
// AGENCY OWNER: APPLY PENALTY TO HOST
// POST /api/agency/penalty/apply
// ─────────────────────────────────────────────────────────────────────────
exports.applyPenalty = async (req, res) => {
  try {
    const userId = req.user.id || req.user.userId;
    const { hostId, reason, type, amount, isPercentage, month, year, notes } = req.body;

    if (!hostId || !reason || !amount) {
      return res.status(400).json({ success: false, message: 'hostId, reason and amount are required' });
    }

    const agency = await Agency.findOne({ hosts: userId });
    if (!agency) return res.status(404).json({ success: false, message: 'Agency not found' });
    if (agency.owner.toString() !== userId.toString()) {
      return res.status(403).json({ success: false, message: 'Only agency owner can apply penalties' });
    }
    if (!agency.hosts.map(h => h.toString()).includes(hostId)) {
      return res.status(403).json({ success: false, message: 'User is not a host in your agency' });
    }

    const m = month || new Date().getMonth() + 1;
    const y = year || new Date().getFullYear();

    const penalty = await Penalty.create({
      userId: hostId,
      agencyId: agency._id,
      appliedBy: userId,
      reason,
      type: type || 'coins',
      amount,
      isPercentage: isPercentage || false,
      month: m,
      year: y,
      notes: notes || '',
    });

    await AuditLog.create({
      userId,
      action: 'penalty_applied',
      targetId: penalty._id,
      metadata: { hostId, agencyId: agency._id.toString(), amount, reason },
      ip: req.ip,
    });

    res.status(201).json({ success: true, penalty, message: 'Penalty applied successfully' });
  } catch (error) {
    console.error('Apply Penalty Error:', error);
    res.status(500).json({ success: false, message: 'Failed to apply penalty' });
  }
};

// ─────────────────────────────────────────────────────────────────────────
// AGENCY OWNER: GET PENALTIES FOR A HOST
// GET /api/agency/penalty/history/:hostId
// ─────────────────────────────────────────────────────────────────────────
exports.getHostPenalties = async (req, res) => {
  try {
    const userId = req.user.id || req.user.userId;
    const { hostId } = req.params;

    const agency = await Agency.findOne({ hosts: userId });
    if (!agency) return res.status(404).json({ success: false, message: 'Agency not found' });
    if (!agency.hosts.map(h => h.toString()).includes(hostId)) {
      return res.status(403).json({ success: false, message: 'Host not in agency' });
    }

    const penalties = await Penalty.find({ userId: hostId, agencyId: agency._id })
      .sort({ createdAt: -1 })
      .limit(100);

    res.status(200).json({ success: true, data: penalties, count: penalties.length });
  } catch (error) {
    console.error('Get Host Penalties Error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch penalties' });
  }
};

// ─────────────────────────────────────────────────────────────────────────
// AGENCY OWNER: REMOVE PENALTY
// DELETE /api/agency/penalty/:penaltyId
// ─────────────────────────────────────────────────────────────────────────
exports.removePenalty = async (req, res) => {
  try {
    const userId = req.user.id || req.user.userId;
    const { penaltyId } = req.params;

    const agency = await Agency.findOne({ hosts: userId });
    if (!agency) return res.status(404).json({ success: false, message: 'Agency not found' });
    if (agency.owner.toString() !== userId.toString()) {
      return res.status(403).json({ success: false, message: 'Only agency owner can remove penalties' });
    }

    const penalty = await Penalty.findOneAndDelete({ _id: penaltyId, agencyId: agency._id });
    if (!penalty) return res.status(404).json({ success: false, message: 'Penalty not found' });

    await AuditLog.create({
      userId,
      action: 'penalty_removed',
      targetId: penaltyId,
      metadata: { hostId: penalty.userId.toString(), reason: penalty.reason },
      ip: req.ip,
    });

    res.status(200).json({ success: true, message: 'Penalty removed successfully' });
  } catch (error) {
    console.error('Remove Penalty Error:', error);
    res.status(500).json({ success: false, message: 'Failed to remove penalty' });
  }
};

// ─────────────────────────────────────────────────────────────────────────
// AGENCY OWNER: GET MONTHLY PENALTY SUMMARY
// GET /api/agency/penalty/summary
// ─────────────────────────────────────────────────────────────────────────
exports.getMonthlyPenaltySummary = async (req, res) => {
  try {
    const userId = req.user.id || req.user.userId;
    const { month, year } = req.query;

    const agency = await Agency.findOne({ hosts: userId });
    if (!agency) return res.status(404).json({ success: false, message: 'Agency not found' });

    const m = parseInt(month) || new Date().getMonth() + 1;
    const y = parseInt(year) || new Date().getFullYear();

    const penalties = await Penalty.find({
      agencyId: agency._id,
      month: m,
      year: y,
    }).populate('userId', 'name avatar arvindId');

    const totalPenalty = penalties.reduce((sum, p) => sum + p.amount, 0);

    res.status(200).json({
      success: true,
      data: penalties,
      totalPenalty,
      count: penalties.length,
      month: m,
      year: y,
    });
  } catch (error) {
    console.error('Monthly Penalty Summary Error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch penalty summary' });
  }
};

module.exports = {};

// ─── FROM: reportController.js ────────────────────────────────────────
const Report = require('../../models/Report');
const User = require('../../models/User');
const Room = require('../../models/Room');

const getLoggedInUserId = (req) => {
  return req.user?.id || req.user?.userId || req.user?._id || req.user?.uid || null;
};

const sendError = (res, statusCode, message, details = null) => {
  const payload = { success: false, message };
  if (details) payload.details = details;
  return res.status(statusCode).json(payload);
};

const buildReportQuery = (req) => {
  const query = {};
  const { status, search, reporterId, reportedUserId, roomId } = req.query;

  if (status) query.status = status;
  if (reporterId) query.reporterId = reporterId;
  if (reportedUserId) query.reportedUserId = reportedUserId;
  if (roomId) query.roomId = roomId;

  if (search) {
    const regex = new RegExp(search, 'i');
    query.$or = [
      { reason: regex },
      { details: regex },
      { contentType: regex }
    ];
  }

  return query;
};

const populateReport = (query) => {
  return query
    .populate('reporterId', 'uid name username avatar role')
    .populate('reportedUserId', 'uid name username avatar role')
    .populate('roomId', 'roomId title ownerId status')
    .populate('reviewedBy', 'uid name username avatar role');
};

exports.createReport = async (req, res) => {
  try {
    const {
      reportedUserId,
      roomId,
      contentType = 'other',
      contentId,
      reason,
      details = ''
    } = req.body;

    const reporterId = req.body.reporterId || getLoggedInUserId(req);

    if (!reporterId || !reason) {
      return sendError(res, 400, 'Reporter and reason are required.');
    }

    if (!reportedUserId && !roomId && !contentId) {
      return sendError(res, 400, 'Please provide a target user, room, or content reference.');
    }

    const report = await Report.create({
      reporterId,
      reportedUserId: reportedUserId || null,
      roomId: roomId || null,
      contentType,
      contentId: contentId || null,
      reason,
      details
    });

    const populatedReport = await populateReport(Report.findById(report._id));

    return res.status(201).json({
      success: true,
      message: 'Report submitted successfully.',
      report: populatedReport
    });
  } catch (error) {
    return sendError(res, 500, 'Failed to create report.', error.message);
  }
};

exports.getReports = async (req, res) => {
  try {
    const page = Math.max(1, parseInt(req.query.page, 10) || 1);
    const limit = Math.min(100, Math.max(1, parseInt(req.query.limit, 10) || 20));
    const query = buildReportQuery(req);

    const [reports, total] = await Promise.all([
      populateReport(
        Report.find(query)
          .sort({ createdAt: -1 })
          .skip((page - 1) * limit)
          .limit(limit)
      ),
      Report.countDocuments(query)
    ]);

    return res.status(200).json({
      success: true,
      reports,
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit) || 0
      }
    });
  } catch (error) {
    return sendError(res, 500, 'Failed to fetch reports.', error.message);
  }
};

exports.getUserReports = async (req, res) => {
  try {
    const userId = req.params.userId || req.query.userId;
    if (!userId) {
      return sendError(res, 400, 'User ID is required.');
    }

    const reports = await populateReport(
      Report.find({
        $or: [
          { reporterId: userId },
          { reportedUserId: userId }
        ]
      }).sort({ createdAt: -1 })
    );

    return res.status(200).json({ success: true, reports });
  } catch (error) {
    return sendError(res, 500, 'Failed to fetch user reports.', error.message);
  }
};

exports.resolveReport = async (req, res) => {
  try {
    if (req.method === 'DELETE' || req.query.action === 'delete') {
      return exports.deleteReport(req, res);
    }

    const reportId = req.params.id;
    const { status = 'resolved', reviewNote = '' } = req.body;

    if (!reportId) {
      return sendError(res, 400, 'Report ID is required.');
    }

    const report = await Report.findById(reportId);
    if (!report) {
      return sendError(res, 404, 'Report not found.');
    }

    const allowedStatuses = ['resolved', 'dismissed'];
    const nextStatus = allowedStatuses.includes(status) ? status : 'resolved';
    const adminId = getLoggedInUserId(req);

    report.status = nextStatus;
    report.reviewNote = reviewNote || (nextStatus === 'resolved'
      ? 'Resolved by admin'
      : 'Dismissed by admin');
    report.reviewedBy = adminId || report.reviewedBy;
    report.reviewedAt = new Date();

    await report.save();

    const updatedReport = await populateReport(Report.findById(report._id));

    return res.status(200).json({
      success: true,
      message: 'Report resolved successfully.',
      report: updatedReport
    });
  } catch (error) {
    return sendError(res, 500, 'Failed to resolve report.', error.message);
  }
};

exports.deleteReport = async (req, res) => {
  try {
    const reportId = req.params.id || req.body.reportId;
    if (!reportId) {
      return sendError(res, 400, 'Report ID is required.');
    }

    const report = await Report.findById(reportId);
    if (!report) {
      return sendError(res, 404, 'Report not found.');
    }

    await Report.findByIdAndDelete(reportId);

    return res.status(200).json({
      success: true,
      message: 'Report deleted successfully.'
    });
  } catch (error) {
    return sendError(res, 500, 'Failed to delete report.', error.message);
  }
};

// ─── FROM: agencyCommissionController.js ────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════
// CONTROLLER: AgencyCommissionController — Full commission tier management
// for host agencies with multi-level commission structures
// ═══════════════════════════════════════════════════════════════════════════

const Agency = require('../../models/Agency');
const User = require('../../models/User');
const WalletTransaction = require('../../models/WalletTransaction');
const AuditLog = require('../../models/AuditLog');

/**
 * POST /api/agency/commission-tiers/create
 * Create a new commission tier for an agency
 */
exports.createCommissionTier = async (req, res) => {
  try {
    const { agencyId, tierName, minEarnings, commissionPercent, bonusPercent, requirements } = req.body;

    if (!agencyId || !tierName || commissionPercent === undefined) {
      return res.status(400).json({ success: false, message: 'Agency ID, tier name, and commission percent required' });
    }

    const agency = await Agency.findById(agencyId);
    if (!agency) {
      return res.status(404).json({ success: false, message: 'Agency not found' });
    }

    if (!agency.commissionTiers) agency.commissionTiers = [];
    
    agency.commissionTiers.push({
      tierName,
      minEarnings: minEarnings || 0,
      commissionPercent,
      bonusPercent: bonusPercent || 0,
      requirements: requirements || '',
      isActive: true,
    });

    await agency.save();

    return res.status(201).json({
      success: true,
      message: `Commission tier '${tierName}' created for agency`,
      data: agency.commissionTiers,
    });
  } catch (error) {
    console.error('createCommissionTier Error:', error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

/**
 * PUT /api/agency/commission-tiers/:agencyId/:tierIndex
 * Update a specific commission tier
 */
exports.updateCommissionTier = async (req, res) => {
  try {
    const { agencyId, tierIndex } = req.params;
    const idx = parseInt(tierIndex);
    const updates = req.body;

    const agency = await Agency.findById(agencyId);
    if (!agency) {
      return res.status(404).json({ success: false, message: 'Agency not found' });
    }

    if (!agency.commissionTiers || idx < 0 || idx >= agency.commissionTiers.length) {
      return res.status(400).json({ success: false, message: 'Invalid tier index' });
    }

    const tier = agency.commissionTiers[idx];
    if (updates.tierName !== undefined) tier.tierName = updates.tierName;
    if (updates.minEarnings !== undefined) tier.minEarnings = updates.minEarnings;
    if (updates.commissionPercent !== undefined) tier.commissionPercent = updates.commissionPercent;
    if (updates.bonusPercent !== undefined) tier.bonusPercent = updates.bonusPercent;
    if (updates.requirements !== undefined) tier.requirements = updates.requirements;
    if (updates.isActive !== undefined) tier.isActive = updates.isActive;

    await agency.save();

    return res.status(200).json({ success: true, message: 'Commission tier updated', data: agency.commissionTiers });
  } catch (error) {
    console.error('updateCommissionTier Error:', error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

/**
 * DELETE /api/agency/commission-tiers/:agencyId/:tierIndex
 * Delete a commission tier
 */
exports.deleteCommissionTier = async (req, res) => {
  try {
    const { agencyId, tierIndex } = req.params;
    const idx = parseInt(tierIndex);

    const agency = await Agency.findById(agencyId);
    if (!agency) {
      return res.status(404).json({ success: false, message: 'Agency not found' });
    }

    if (!agency.commissionTiers || idx < 0 || idx >= agency.commissionTiers.length) {
      return res.status(400).json({ success: false, message: 'Invalid tier index' });
    }

    agency.commissionTiers.splice(idx, 1);
    await agency.save();

    return res.status(200).json({ success: true, message: 'Commission tier deleted', data: agency.commissionTiers });
  } catch (error) {
    console.error('deleteCommissionTier Error:', error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

/**
 * GET /api/agency/commission-tiers/:agencyId
 * Get all commission tiers for an agency
 */
exports.getCommissionTiers = async (req, res) => {
  try {
    const agency = await Agency.findById(req.params.agencyId).select('commissionTiers name');
    if (!agency) {
      return res.status(404).json({ success: false, message: 'Agency not found' });
    }
    return res.status(200).json({ success: true, data: agency.commissionTiers || [] });
  } catch (error) {
    console.error('getCommissionTiers Error:', error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

/**
 * POST /api/agency/calculate-commission
 * Calculate commission for a host based on their agency's tier structure
 */
exports.calculateCommission = async (req, res) => {
  try {
    const { hostUid, earnings } = req.body;

    if (!hostUid || !earnings || earnings <= 0) {
      return res.status(400).json({ success: false, message: 'Host UID and positive earnings required' });
    }

    const host = await User.findOne({ uid: hostUid });
    if (!host) {
      return res.status(404).json({ success: false, message: 'Host not found' });
    }

    const agency = await Agency.findOne({ members: host._id });
    if (!agency) {
      return res.status(404).json({ success: false, message: 'Host not affiliated with any agency' });
    }

    // Find applicable tier
    const tiers = agency.commissionTiers || [];
    let applicableTier = tiers.find((t) => earnings >= t.minEarnings && t.isActive);
    if (!applicableTier) {
      // Use lowest active tier as fallback
      applicableTier = tiers.filter((t) => t.isActive).sort((a, b) => a.minEarnings - b.minEarnings)[0];
    }

    if (!applicableTier) {
      return res.status(400).json({ success: false, message: 'No applicable commission tier found for this earnings amount' });
    }

    const commissionAmount = Math.floor(earnings * (applicableTier.commissionPercent / 100));
    const bonusAmount = Math.floor(commissionAmount * ((applicableTier.bonusPercent || 0) / 100));
    const totalCommission = commissionAmount + bonusAmount;

    return res.status(200).json({
      success: true,
      data: {
        hostUid,
        earnings,
        tier: applicableTier.tierName,
        commissionPercent: applicableTier.commissionPercent,
        bonusPercent: applicableTier.bonusPercent || 0,
        commissionAmount,
        bonusAmount,
        totalCommission,
        agencyName: agency.name,
      },
    });
  } catch (error) {
    console.error('calculateCommission Error:', error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

// ─── FROM: agencyInvitationController.js ────────────────────────────────────────
const AgencyInvitation = require('../../models/AgencyInvitation');
const Agency = require('../../models/Agency');
const User = require('../../models/User');
const Notification = require('../../models/Notification');

// ─────────────────────────────────────────────────────────────────────────
// AGENCY OWNER: SEND INVITATION TO USER BY UID
// POST /api/agency/invitations/send
// ─────────────────────────────────────────────────────────────────────────
exports.sendInvitation = async (req, res) => {
  try {
    const userId = req.user.id || req.user.userId;
    const { targetUid, message, specialRoles } = req.body;

    if (!targetUid) {
      return res.status(400).json({ success: false, message: 'Target UID is required' });
    }

    const agency = await Agency.findOne({ owner: userId });
    if (!agency) {
      return res.status(404).json({ success: false, message: 'Agency not found. Create an agency first.' });
    }

    const targetUser = await User.findOne({ uid: targetUid });
    if (!targetUser) {
      return res.status(404).json({ success: false, message: 'User not found with this UID' });
    }

    if (targetUser._id.toString() === userId.toString()) {
      return res.status(400).json({ success: false, message: 'Cannot invite yourself' });
    }

    if (agency.hosts.some(h => h.toString() === targetUser._id.toString())) {
      return res.status(400).json({ success: false, message: 'User is already a member of your agency' });
    }

    const existing = await AgencyInvitation.findOne({
      agencyId: agency._id,
      targetUserId: targetUser._id,
      status: 'pending'
    });

    if (existing) {
      return res.status(400).json({ success: false, message: 'Invitation already pending for this user' });
    }

    const invitation = await AgencyInvitation.create({
      agencyId: agency._id,
      agencyName: agency.name,
      invitedBy: userId,
      invitedByUid: req.user.uid || userId.toString(),
      targetUserId: targetUser._id,
      targetUid: targetUser.uid,
      message: message || '',
      specialRoles: specialRoles || {}
    });

    await Notification.create({
      userId: targetUser._id,
      type: 'agency_invite',
      title: 'Agency Invitation',
      body: `${agency.name} has invited you to join their agency.`,
      data: {
        invitationId: invitation._id,
        agencyId: agency._id,
        agencyName: agency.name,
        invitedBy: userId.toString()
      }
    });

    res.status(201).json({
      success: true,
      invitation,
      message: 'Invitation sent successfully'
    });
  } catch (error) {
    console.error('Send Invitation Error:', error);
    res.status(500).json({ success: false, message: 'Failed to send invitation' });
  }
};

// ─────────────────────────────────────────────────────────────────────────
// USER: GET MY INBOX (PENDING INVITATIONS)
// GET /api/agency/invitations/inbox
// ─────────────────────────────────────────────────────────────────────────
exports.getInbox = async (req, res) => {
  try {
    const userId = req.user.id || req.user.userId;

    const invitations = await AgencyInvitation.find({
      targetUserId: userId,
      status: 'pending'
    })
      .populate('agencyId', 'name logo description')
      .populate('invitedBy', 'name avatar uid')
      .sort({ createdAt: -1 });

    res.status(200).json({
      success: true,
      data: invitations,
      count: invitations.length
    });
  } catch (error) {
    console.error('Get Inbox Error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch inbox' });
  }
};

// ─────────────────────────────────────────────────────────────────────────
// USER: ACCEPT INVITATION
// POST /api/agency/invitations/accept/:invitationId
// ─────────────────────────────────────────────────────────────────────────
exports.acceptInvitation = async (req, res) => {
  try {
    const userId = req.user.id || req.user.userId;
    const { invitationId } = req.params;

    const invitation = await AgencyInvitation.findOne({
      _id: invitationId,
      targetUserId: userId,
      status: 'pending'
    });

    if (!invitation) {
      return res.status(404).json({ success: false, message: 'Invitation not found or already processed' });
    }

    invitation.status = 'accepted';
    invitation.respondedAt = new Date();
    await invitation.save();

    const agency = await Agency.findById(invitation.agencyId);
    if (!agency) {
      return res.status(404).json({ success: false, message: 'Agency not found' });
    }

    if (!agency.hosts.includes(userId)) {
      agency.hosts.push(userId);
      agency.totalHosts = agency.hosts.length;
      await agency.save();
    }

    const specialRoles = invitation.specialRoles || {};
    const updatePayload = {
      agencyId: agency._id,
      role: 'host',
      specialRoles: specialRoles
    };

    if (specialRoles.vipFrame) {
      updatePayload.equippedFrame = 'vip_agency_frame';
      updatePayload.unlockedFrames = ['vip_agency_frame'];
    }

    await User.findByIdAndUpdate(userId, updatePayload);

    res.status(200).json({
      success: true,
      agency,
      specialRoles,
      message: 'Invitation accepted. Welcome to the agency!'
    });
  } catch (error) {
    console.error('Accept Invitation Error:', error);
    res.status(500).json({ success: false, message: 'Failed to accept invitation' });
  }
};

// ─────────────────────────────────────────────────────────────────────────
// USER: REJECT INVITATION
// POST /api/agency/invitations/reject/:invitationId
// ─────────────────────────────────────────────────────────────────────────
exports.rejectInvitation = async (req, res) => {
  try {
    const userId = req.user.id || req.user.userId;
    const { invitationId } = req.params;

    const invitation = await AgencyInvitation.findOne({
      _id: invitationId,
      targetUserId: userId,
      status: 'pending'
    });

    if (!invitation) {
      return res.status(404).json({ success: false, message: 'Invitation not found or already processed' });
    }

    invitation.status = 'rejected';
    invitation.respondedAt = new Date();
    await invitation.save();

    res.status(200).json({
      success: true,
      message: 'Invitation rejected'
    });
  } catch (error) {
    console.error('Reject Invitation Error:', error);
    res.status(500).json({ success: false, message: 'Failed to reject invitation' });
  }
};

// ─────────────────────────────────────────────────────────────────────────
// USER: SEARCH USER BY UID
// GET /api/users/search?uid=XXX
// ─────────────────────────────────────────────────────────────────────────
exports.searchUserByUid = async (req, res) => {
  try {
    const { uid } = req.query;

    if (!uid) {
      return res.status(400).json({ success: false, message: 'UID is required' });
    }

    const user = await User.findOne({ uid })
      .select('name avatar uid arvindId level isVip vipLevel agencyId role')
      .lean();

    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    const populated = await User.findById(user._id)
      .populate('agencyId', 'name logo')
      .lean();

    res.status(200).json({
      success: true,
      data: populated
    });
  } catch (error) {
    console.error('Search User Error:', error);
    res.status(500).json({ success: false, message: 'Failed to search user' });
  }
};

// ─────────────────────────────────────────────────────────────────────────
// GET ALL NOTIFICATIONS / INBOX ITEMS
// GET /api/notifications/inbox
// ─────────────────────────────────────────────────────────────────────────
exports.getNotifications = async (req, res) => {
  try {
    const userId = req.user.id || req.user.userId;

    const notifications = await Notification.find({ userId })
      .sort({ createdAt: -1 })
      .limit(50);

    const unreadCount = await Notification.countDocuments({ userId, read: false });

    res.status(200).json({
      success: true,
      data: notifications,
      unreadCount
    });
  } catch (error) {
    console.error('Get Notifications Error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch notifications' });
  }
};

// ─────────────────────────────────────────────────────────────────────────
// MARK NOTIFICATION AS READ
// POST /api/notifications/read/:notificationId
// ─────────────────────────────────────────────────────────────────────────
exports.markNotificationRead = async (req, res) => {
  try {
    const userId = req.user.id || req.user.userId;
    const { notificationId } = req.params;

    const notification = await Notification.findOneAndUpdate(
      { _id: notificationId, userId },
      { read: true, readAt: new Date() },
      { new: true }
    );

    if (!notification) {
      return res.status(404).json({ success: false, message: 'Notification not found' });
    }

    res.status(200).json({ success: true, data: notification });
  } catch (error) {
    console.error('Mark Read Error:', error);
    res.status(500).json({ success: false, message: 'Failed to mark notification as read' });
  }
};

// ─────────────────────────────────────────────────────────────────────────
// MARK ALL NOTIFICATIONS AS READ
// POST /api/notifications/read-all
// ─────────────────────────────────────────────────────────────────────────
exports.markAllNotificationsRead = async (req, res) => {
  try {
    const userId = req.user.id || req.user.userId;

    await Notification.updateMany(
      { userId, read: false },
      { read: true, readAt: new Date() }
    );

    res.status(200).json({ success: true, message: 'All notifications marked as read' });
  } catch (error) {
    console.error('Mark All Read Error:', error);
    res.status(500).json({ success: false, message: 'Failed to mark all notifications as read' });
  }
};