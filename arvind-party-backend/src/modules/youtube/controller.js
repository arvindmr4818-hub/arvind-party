// ═══════════════════════════════════════════════════════════════════════════
// MODULE: youtube/controller.js — Real YouTube Data API v3
// ═══════════════════════════════════════════════════════════════════════════

const axios = require('axios');
const YouTubePlaylist = require('../../models/YouTubePlaylist');

const YOUTUBE_API_KEY = process.env.YOUTUBE_API_KEY;
const YOUTUBE_API_BASE = 'https://www.googleapis.com/youtube/v3';

const youtubeController = {

  // Search YouTube videos (REAL API)
  searchVideos: async (req, res) => {
    try {
      const { q, maxResults = 10 } = req.query;
      if (!q) return res.status(400).json({ success: false, message: 'Query required' });

      if (!YOUTUBE_API_KEY) {
        // Fallback: return empty with message
        return res.json({ success: true, videos: [], message: 'Set YOUTUBE_API_KEY in .env to enable search' });
      }

      const response = await axios.get(`${YOUTUBE_API_BASE}/search`, {
        params: {
          part: 'snippet',
          q,
          type: 'video',
          maxResults: parseInt(maxResults),
          key: YOUTUBE_API_KEY,
          videoEmbeddable: true,
        },
        timeout: 10000,
      });

      const videos = response.data.items.map(item => ({
        id: item.id.videoId,
        title: item.snippet.title,
        channelName: item.snippet.channelTitle,
        thumbnailUrl: item.snippet.thumbnails?.medium?.url || item.snippet.thumbnails?.default?.url,
        videoUrl: `https://www.youtube.com/watch?v=${item.id.videoId}`,
        publishedAt: item.snippet.publishedAt,
        description: item.snippet.description?.substring(0, 100),
      }));

      res.json({ success: true, videos });
    } catch (error) {
      if (error.response?.status === 403) {
        return res.status(403).json({ success: false, message: 'YouTube API quota exceeded or invalid key' });
      }
      res.status(500).json({ success: false, message: error.message });
    }
  },

  // Get room playlist
  getPlaylist: async (req, res) => {
    try {
      const { roomId } = req.params;
      if (!roomId) return res.status(400).json({ success: false, message: 'roomId required' });
      const playlist = await YouTubePlaylist.findOne({ roomId }).lean();
      res.json({ success: true, videos: playlist?.videos || [], currentVideo: playlist?.currentVideo, watchPartyEnabled: playlist?.watchPartyEnabled });
    } catch (error) { res.status(500).json({ success: false, message: error.message }); }
  },

  // Add video to playlist
  addToPlaylist: async (req, res) => {
    try {
      const { roomId, video } = req.body;
      if (!roomId || !video?.id) return res.status(400).json({ success: false, message: 'roomId and video required' });
      let playlist = await YouTubePlaylist.findOne({ roomId });
      if (!playlist) playlist = await YouTubePlaylist.create({ roomId, hostId: req.user._id, videos: [] });
      if (!playlist.videos.some(v => v.id === video.id)) {
        playlist.videos.push(video);
        await playlist.save();
      }
      req.app.get('io')?.to(roomId).emit('youtube:playlist_updated', { videos: playlist.videos });
      res.json({ success: true, videos: playlist.videos });
    } catch (error) { res.status(500).json({ success: false, message: error.message }); }
  },

  // Remove video
  removeFromPlaylist: async (req, res) => {
    try {
      const { roomId, videoId } = req.params;
      const playlist = await YouTubePlaylist.findOne({ roomId });
      if (!playlist) return res.status(404).json({ success: false, message: 'Playlist not found' });
      playlist.videos = playlist.videos.filter(v => v.id !== videoId);
      await playlist.save();
      req.app.get('io')?.to(roomId).emit('youtube:playlist_updated', { videos: playlist.videos });
      res.json({ success: true, videos: playlist.videos });
    } catch (error) { res.status(500).json({ success: false, message: error.message }); }
  },

  // Sync playback
  updatePlaybackState: async (req, res) => {
    try {
      const { roomId, isPlaying, position, videoId } = req.body;
      req.app.get('io')?.to(roomId).emit('youtube:sync_update', { isPlaying, position, videoId, updatedBy: req.user?._id });
      res.json({ success: true });
    } catch (error) { res.status(500).json({ success: false, message: error.message }); }
  },
};

module.exports = youtubeController;
