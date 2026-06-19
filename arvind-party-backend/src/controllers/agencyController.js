const User = require('../models/User');
const Agency = require('../models/Agency');

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

exports.applyForAgency = async (req, res) => {
  try {
    const { agencyId } = req.body;
    const userId = req.user.id || req.user.userId;

    const agency = await Agency.findByIdAndUpdate(agencyId, { $addToSet: { hosts: userId } }, { new: true });
    if (!agency) {
      return res.status(404).json({ success: false, message: 'Agency not found' });
    }
    res.status(200).json({ success: true, agency, message: 'Application approved and joined agency' });
  } catch (error) {
    console.error('Apply Agency Error:', error);
    res.status(500).json({ success: false, message: 'Failed to apply to agency' });
  }
};