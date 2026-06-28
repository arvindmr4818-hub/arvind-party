// =========================================================================
// MODULE: INFRASTRUCTURE — SERVICES
// =========================================================================


// ─── FROM: monitoringService.js ────────────────────────────────────────
const os = require('os');
const { EventEmitter } = require('events');

class MonitoringService extends EventEmitter {
  constructor() {
    super();
    this.metrics = {
      requests: { total: 0, success: 0, failed: 0 },
      latency: { avg: 0, samples: [] },
      connections: { active: 0, total: 0 },
      system: {
        cpu: 0,
        memory: 0,
        uptime: 0,
        loadAverage: [0, 0, 0]
      },
      database: {
        connected: false,
        operations: { read: 0, write: 0, failed: 0 }
      },
      redis: {
        connected: false,
        hitRate: 0,
        operations: { get: 0, set: 0, del: 0 }
      },
      sockets: { connected: 0, rooms: 0, messages: 0 },
      queue: { jobs: { waiting: 0, active: 0, completed: 0, failed: 0 } }
    };
    this.startTime = Date.now();
    this.collectionInterval = null;
  }

  startCollection(intervalMs = 5000) {
    this.collectMetrics();
    this.collectionInterval = setInterval(() => {
      this.collectMetrics();
    }, intervalMs);
    console.log('📊 [MonitoringService] Started');
  }

  stopCollection() {
    if (this.collectionInterval) {
      clearInterval(this.collectionInterval);
      this.collectionInterval = null;
    }
  }

  collectMetrics() {
    const cpuUsage = this.getCPUUsage();
    const memoryUsage = this.getMemoryUsage();

    this.metrics.system = {
      cpu: cpuUsage,
      memory: memoryUsage.percentage,
      uptime: process.uptime(),
      loadAverage: os.loadavg(),
      totalMemory: memoryUsage.total,
      usedMemory: memoryUsage.used,
      freeMemory: memoryUsage.free
    };

    this.emit('metrics:update', this.metrics);
  }

  getCPUUsage() {
    const cpus = os.cpus();
    let totalIdle = 0;
    let totalTick = 0;

    cpus.forEach((cpu) => {
      for (const type in cpu.times) {
        totalTick += cpu.times[type];
      }
      totalIdle += cpu.times.idle;
    });

    return {
      cores: cpus.length,
      idle: totalIdle / cpus.length,
      total: totalTick / cpus.length,
      usage: ((totalTick - totalIdle) / totalTick) * 100
    };
  }

  getMemoryUsage() {
    const totalMem = os.totalmem();
    const freeMem = os.freemem();
    const usedMem = totalMem - freeMem;

    return {
      total: Math.round(totalMem / 1024 / 1024),
      free: Math.round(freeMem / 1024 / 1024),
      used: Math.round(usedMem / 1024 / 1024),
      percentage: parseFloat(((usedMem / totalMem) * 100).toFixed(2))
    };
  }

  recordRequest(status, latencyMs) {
    this.metrics.requests.total++;
    if (status >= 200 && status < 300) {
      this.metrics.requests.success++;
    } else {
      this.metrics.requests.failed++;
    }

    this.metrics.latency.samples.push(latencyMs);
    if (this.metrics.latency.samples.length > 1000) {
      this.metrics.latency.samples.shift();
    }

    const sum = this.metrics.latency.samples.reduce((a, b) => a + b, 0);
    this.metrics.latency.avg = parseFloat((sum / this.metrics.latency.samples.length).toFixed(2));
  }

  updateDatabaseStatus(connected) {
    this.metrics.database.connected = connected;
  }

  updateRedisStatus(connected) {
    this.metrics.redis.connected = connected;
  }

  updateSocketMetrics(connected, rooms, messages) {
    this.metrics.sockets.connected = connected;
    this.metrics.sockets.rooms = rooms;
    this.metrics.sockets.messages = messages;
  }

  updateQueueStats(stats) {
    if (stats) {
      this.metrics.queue.jobs = stats;
    }
  }

  getMetrics() {
    return {
      ...this.metrics,
      timestamp: new Date().toISOString(),
      serverTime: new Date().toLocaleString('en-IN', { timeZone: 'Asia/Kolkata' })
    };
  }

  getHealthStatus() {
    const system = this.metrics.system;
    const database = this.metrics.database;
    const redis = this.metrics.redis;

    const issues = [];
    if (system.memory > 85) {
      issues.push('High memory usage detected');
    }
    if (system.cpu && system.cpu.usage > 80) {
      issues.push('High CPU usage detected');
    }
    if (!database.connected) {
      issues.push('Database connection lost');
    }
    if (!redis.connected) {
      issues.push('Redis connection lost');
    }

    const isHealthy = issues.length === 0;

    return {
      status: isHealthy ? 'healthy' : 'degraded',
      uptime: system.uptime,
      issues,
      timestamp: new Date().toISOString()
    };
  }
}

module.exports = new MonitoringService();

// ─── FROM: autoScalingService.js ────────────────────────────────────────
const os = require('os');
const MonitoringService = require('./monitoringService');
const Logger = require('../../utils/logger');

class AutoScalingService {
  constructor() {
    this.isEnabled = process.env.AUTO_SCALING_ENABLED === 'true';
    this.checkInterval = null;
    this.scalingHistory = [];
    this.currentInstanceCount = 1;
    this.minInstances = parseInt(process.env.MIN_INSTANCES) || 1;
    this.maxInstances = parseInt(process.env.MAX_INSTANCES) || 4;
    this.cpuThreshold = parseFloat(process.env.CPU_SCALE_THRESHOLD) || 75;
    this.memoryThreshold = parseFloat(process.env.MEMORY_SCALE_THRESHOLD) || 80;
    this.cooldownPeriod = parseInt(process.env.SCALE_COOLDOWN_MS) || 300000;
    this.lastScaleAction = 0;
    this.scaleUpCount = 0;
    this.scaleDownCount = 0;
  }

  start() {
    if (!this.isEnabled) {
      Logger.info('Auto Scaling is disabled');
      return;
    }

    Logger.info('🚀 Auto Scaling Service started', {
      minInstances: this.minInstances,
      maxInstances: this.maxInstances,
      cpuThreshold: this.cpuThreshold,
      memoryThreshold: this.memoryThreshold
    });

    this.checkInterval = setInterval(() => {
      this.evaluateScaling();
    }, 30000);
  }

  stop() {
    if (this.checkInterval) {
      clearInterval(this.checkInterval);
      this.checkInterval = null;
      Logger.info('Auto Scaling Service stopped');
    }
  }

  evaluateScaling() {
    const metrics = MonitoringService.getMetrics();
    const system = metrics.system;
    const cpuUsage = system.cpu?.usage || 0;
    const memoryUsage = system.memory?.percentage || 0;
    const activeConnections = metrics.sockets?.connected || 0;
    const queueDepth = (metrics.queue?.jobs?.waiting || 0) + (metrics.queue?.jobs?.active || 0);

    this.recordMetricsSnapshot(cpuUsage, memoryUsage, activeConnections, queueDepth);

    if (Date.now() - this.lastScaleAction < this.cooldownPeriod) {
      return;
    }

    const shouldScaleUp = this.shouldScaleUp(cpuUsage, memoryUsage, queueDepth);
    const shouldScaleDown = this.shouldScaleDown(cpuUsage, memoryUsage, activeConnections);

    if (shouldScaleUp && this.currentInstanceCount < this.maxInstances) {
      this.scaleUp();
    } else if (shouldScaleDown && this.currentInstanceCount > this.minInstances) {
      this.scaleDown();
    }
  }

  shouldScaleUp(cpuUsage, memoryUsage, queueDepth) {
    const highCpu = cpuUsage > this.cpuThreshold;
    const highMemory = memoryUsage > this.memoryThreshold;
    const highQueueDepth = queueDepth > 1000;
    const consecutiveHigh = this.checkConsecutiveHighMetrics(3);

    return (highCpu && highMemory) || highQueueDepth || (consecutiveHigh && (highCpu || highMemory));
  }

  shouldScaleDown(cpuUsage, memoryUsage, activeConnections) {
    const lowCpu = cpuUsage < 25;
    const lowMemory = memoryUsage < 30;
    const lowConnections = activeConnections < 50;
    const consecutiveLow = this.checkConsecutiveLowMetrics(5);

    return lowCpu && lowMemory && lowConnections && consecutiveLow;
  }

  checkConsecutiveHighMetrics(requiredCount) {
    const recentSnapshots = this.scalingHistory.slice(-requiredCount);
    if (recentSnapshots.length < requiredCount) return false;

    return recentSnapshots.every(snapshot =>
      snapshot.cpu > this.cpuThreshold || snapshot.memory > this.memoryThreshold
    );
  }

  checkConsecutiveLowMetrics(requiredCount) {
    const recentSnapshots = this.scalingHistory.slice(-requiredCount);
    if (recentSnapshots.length < requiredCount) return false;

    return recentSnapshots.every(snapshot =>
      snapshot.cpu < 30 && snapshot.memory < 40 && snapshot.connections < 100
    );
  }

  recordMetricsSnapshot(cpu, memory, connections, queue) {
    this.scalingHistory.push({
      timestamp: Date.now(),
      cpu,
      memory,
      connections,
      queue
    });

    if (this.scalingHistory.length > 60) {
      this.scalingHistory.shift();
    }
  }

  async scaleUp() {
    const newInstanceCount = Math.min(this.currentInstanceCount + 1, this.maxInstances);
    this.lastScaleAction = Date.now();
    this.currentInstanceCount = newInstanceCount;
    this.scaleUpCount++;

    Logger.warn('⬆️ Scaling UP triggered', {
      from: this.currentInstanceCount - 1,
      to: newInstanceCount,
      reason: this.getScaleReason()
    });

    try {
      if (process.env.AWS_LAMBDA_FUNCTION_NAME) {
        await this.triggerAWSLambdaScale(newInstanceCount);
      } else if (process.env.RENDER_SERVICE_ID) {
        await this.triggerRenderScale(newInstanceCount);
      } else if (process.env.DOCKER_SWARM_MODE === 'true') {
        await this.triggerDockerSwarmScale(newInstanceCount);
      } else {
        await this.triggerGenericScale(newInstanceCount);
      }

      this.emitScalingEvent('scale_up', newInstanceCount);
    } catch (error) {
      Logger.error('Scale up failed', { error: error.message });
      this.currentInstanceCount--;
      this.scaleUpCount--;
    }
  }

  async scaleDown() {
    const newInstanceCount = Math.max(this.currentInstanceCount - 1, this.minInstances);
    this.lastScaleAction = Date.now();
    this.currentInstanceCount = newInstanceCount;
    this.scaleDownCount++;

    Logger.warn('⬇️ Scaling DOWN triggered', {
      from: this.currentInstanceCount + 1,
      to: newInstanceCount,
      reason: 'Low traffic detected'
    });

    try {
      if (process.env.AWS_LAMBDA_FUNCTION_NAME) {
        await this.triggerAWSLambdaScale(newInstanceCount);
      } else if (process.env.RENDER_SERVICE_ID) {
        await this.triggerRenderScale(newInstanceCount);
      } else if (process.env.DOCKER_SWARM_MODE === 'true') {
        await this.triggerDockerSwarmScale(newInstanceCount);
      } else {
        await this.triggerGenericScale(newInstanceCount);
      }

      this.emitScalingEvent('scale_down', newInstanceCount);
    } catch (error) {
      Logger.error('Scale down failed', { error: error.message });
      this.currentInstanceCount++;
      this.scaleDownCount--;
    }
  }

  getScaleReason() {
    const metrics = MonitoringService.getMetrics();
    const reasons = [];

    if (metrics.system.cpu?.usage > this.cpuThreshold) {
      reasons.push(`CPU at ${metrics.system.cpu.usage.toFixed(1)}%`);
    }
    if (metrics.system.memory?.percentage > this.memoryThreshold) {
      reasons.push(`Memory at ${metrics.system.memory.percentage.toFixed(1)}%`);
    }
    if ((metrics.queue?.jobs?.waiting || 0) > 1000) {
      reasons.push('High queue backlog');
    }

    return reasons.join(', ');
  }

  async triggerAWSLambdaScale(instanceCount) {
    const AWS = require('aws-sdk');
    const autoscaling = new AWS.AutoScaling({
      region: process.env.AWS_REGION || 'us-east-1',
      accessKeyId: process.env.AWS_ACCESS_KEY_ID,
      secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY
    });

    const params = {
      AutoScalingGroupName: process.env.AWS_AUTOSCALING_GROUP,
      DesiredCapacity: instanceCount,
      MinSize: this.minInstances,
      MaxSize: this.maxInstances
    };

    await autoscaling.updateAutoScalingGroup(params).promise();
    Logger.info('AWS AutoScaling group updated', { instanceCount });
  }

  async triggerRenderScale(instanceCount) {
    const render = require('render-api-client');
    await render.updateService({
      serviceId: process.env.RENDER_SERVICE_ID,
      plan: instanceCount > 1 ? 'starter' : 'free'
    });
    Logger.info('Render service scaled', { instanceCount });
  }

  async triggerDockerSwarmScale(instanceCount) {
    const { exec } = require('child_process');
    const util = require('util');
    const execAsync = util.promisify(exec);

    await execAsync(`docker service scale arvind-party-backend=${instanceCount}`);
    Logger.info('Docker Swarm service scaled', { instanceCount });
  }

  async triggerGenericScale(instanceCount) {
    Logger.info('Generic scale request', { instanceCount });
    if (this.onScaleCallback) {
      await this.onScaleCallback(instanceCount);
    }
  }

  emitScalingEvent(action, instanceCount) {
    if (this.io) {
      this.io.to('admins').emit('scaling:event', {
        action,
        instanceCount,
        timestamp: new Date().toISOString(),
        metrics: MonitoringService.getMetrics()
      });
    }
  }

  getScalingStats() {
    return {
      isEnabled: this.isEnabled,
      currentInstanceCount: this.currentInstanceCount,
      minInstances: this.minInstances,
      maxInstances: this.maxInstances,
      scaleUpCount: this.scaleUpCount,
      scaleDownCount: this.scaleDownCount,
      lastScaleAction: this.lastScaleAction ? new Date(this.lastScaleAction).toISOString() : null,
      cpuThreshold: this.cpuThreshold,
      memoryThreshold: this.memoryThreshold,
      cooldownPeriod: this.cooldownPeriod,
      recentHistory: this.scalingHistory.slice(-10)
    };
  }

  manualScale(direction) {
    if (direction === 'up' && this.currentInstanceCount < this.maxInstances) {
      this.scaleUp();
    } else if (direction === 'down' && this.currentInstanceCount > this.minInstances) {
      this.scaleDown();
    } else {
      Logger.warn('Manual scale blocked', { direction, current: this.currentInstanceCount });
    }
  }

  setIo(io) {
    this.io = io;
  }

  setScaleCallback(callback) {
    this.onScaleCallback = callback;
  }
}

module.exports = new AutoScalingService();

// ─── FROM: backupService.js ────────────────────────────────────────
const mongoose = require('mongoose');
const fs = require('fs').promises;
const path = require('path');
const { exec } = require('child_process');
const { promisify } = require('util');
const Logger = require('../../utils/logger');

const execAsync = promisify(exec);

class BackupService {
  constructor() {
    this.isEnabled = process.env.BACKUP_ENABLED !== 'false';
    this.backupDir = process.env.BACKUP_DIR || './backups';
    this.maxBackups = parseInt(process.env.MAX_BACKUPS) || 24;
    this.retentionDays = parseInt(process.env.BACKUP_RETENTION_DAYS) || 7;
    this.compressionEnabled = process.env.BACKUP_COMPRESSION === 'true';
    this.backupInterval = null;
    this.isBackupServer = process.env.BACKUP_SERVER_MODE === 'true';
    this.primaryServer = process.env.PRIMARY_SERVER_URL || '';
    this.lastBackupTime = null;
    this.backupHistory = [];
  }

  async initialize() {
    if (!this.isEnabled) {
      Logger.info('Backup Service is disabled');
      return false;
    }

    try {
      await fs.mkdir(this.backupDir, { recursive: true });
      await fs.mkdir(path.join(this.backupDir, 'database'), { recursive: true });
      await fs.mkdir(path.join(this.backupDir, 'media'), { recursive: true });

      if (this.isBackupServer) {
        Logger.info('🔄 Running as backup server mode');
        this.startSyncFromPrimary();
      } else {
        Logger.info('💾 Running as primary server, starting scheduled backups');
        this.startScheduledBackups();
      }

      Logger.info('Backup Service initialized', {
        backupDir: this.backupDir,
        maxBackups: this.maxBackups,
        isBackupServer: this.isBackupServer
      });

      return true;
    } catch (error) {
      Logger.error('Backup Service initialization failed', { error: error.message });
      return false;
    }
  }

  startScheduledBackups() {
    const backupIntervalMs = parseInt(process.env.BACKUP_INTERVAL_MS) || 3600000;

    this.backupInterval = setInterval(async () => {
      await this.createBackup();
    }, backupIntervalMs);

    Logger.info(`Scheduled backups every ${backupIntervalMs / 1000 / 60} minutes`);
  }

  startSyncFromPrimary() {
    if (!this.primaryServer) {
      Logger.warn('No primary server configured for backup server mode');
      return;
    }

    this.backupInterval = setInterval(async () => {
      await this.syncFromPrimary();
    }, 3600000);

    Logger.info('Sync from primary server scheduled');
  }

  async createBackup() {
    const startTime = Date.now();
    const backupId = this.generateBackupId();
    const backupPath = path.join(this.backupDir, 'database', backupId);

    try {
      Logger.info(`Starting backup: ${backupId}`);

      await fs.mkdir(backupPath, { recursive: true });

      const dbStats = await this.backupDatabase(backupPath);
      const configBackup = await this.backupConfig(backupPath);
      const uploadsBackup = await this.backupMediaAssets(backupPath);

      const manifest = {
        backupId,
        timestamp: new Date().toISOString(),
        duration: Date.now() - startTime,
        database: dbStats,
        config: configBackup,
        media: uploadsBackup,
        compression: this.compressionEnabled,
        serverVersion: process.env.VERSION || '1.0.0'
      };

      await fs.writeFile(
        path.join(backupPath, 'manifest.json'),
        JSON.stringify(manifest, null, 2)
      );

      const backupSize = await this.calculateBackupSize(backupPath);
      manifest.size = backupSize;

      if (this.compressionEnabled) {
        await this.compressBackup(backupPath, backupId);
      }

      this.lastBackupTime = new Date();
      this.backupHistory.unshift({
        id: backupId,
        timestamp: this.lastBackupTime,
        size: backupSize,
        status: 'success',
        duration: manifest.duration
      });

      if (this.backupHistory.length > this.maxBackups) {
        this.backupHistory.pop();
      }

      await this.cleanupOldBackups();

      Logger.info('Backup completed successfully', {
        backupId,
        size: `${(backupSize / 1024 / 1024).toFixed(2)} MB`,
        duration: `${manifest.duration}ms`
      });

      return {
        success: true,
        backupId,
        size: backupSize,
        timestamp: this.lastBackupTime
      };
    } catch (error) {
      Logger.error('Backup failed', { backupId, error: error.message });

      this.backupHistory.unshift({
        id: backupId,
        timestamp: new Date(),
        size: 0,
        status: 'failed',
        error: error.message
      });

      throw error;
    }
  }

  async backupDatabase(backupPath) {
    try {
      const dbName = mongoose.connection.name;
      const mongoDumpPath = path.join(backupPath, 'mongodb_dump');

      await fs.mkdir(mongoDumpPath, { recursive: true });

      const uri = process.env.MONGO_URI;
      const dbUser = process.env.MONGO_ROOT_USERNAME;
      const dbPass = process.env.MONGO_ROOT_PASSWORD;

      let authParams = '';
      if (dbUser && dbPass) {
        authParams = `-u ${dbUser} -p ${dbPass}`;
      }

      const mongodumpCmd = `mongodump --uri="${uri}" --archive="${path.join(mongoDumpPath, 'dump.archive')}" --gzip`;

      await execAsync(mongodumpCmd, { maxBuffer: 50 * 1024 * 1024 });

      const collections = Object.keys(mongoose.connection.collections);
      const collectionStats = {};

      for (const collectionName of collections) {
        try {
          const count = await mongoose.connection.collection(collectionName).countDocuments();
          collectionStats[collectionName] = count;
        } catch (e) {
          collectionStats[collectionName] = 'error';
        }
      }

      return {
        name: dbName,
        collections: collectionStats,
        totalCollections: collections.length,
        dumpPath: mongoDumpPath
      };
    } catch (error) {
      Logger.error('Database backup failed', { error: error.message });
      throw error;
    }
  }

  async backupConfig(backupPath) {
    try {
      const configFiles = ['.env', '.env.production', 'config.json', 'firebase.json'];
      const configDir = path.join(backupPath, 'config');

      await fs.mkdir(configDir, { recursive: true });

      const backedUpFiles = {};

      for (const file of configFiles) {
        try {
          const filePath = path.join(process.cwd(), file);
          const content = await fs.readFile(filePath, 'utf-8');
          const sanitizedContent = this.sanitizeConfigContent(content);
          await fs.writeFile(path.join(configDir, file), sanitizedContent);
          backedUpFiles[file] = 'backed_up';
        } catch (e) {
          backedUpFiles[file] = 'not_found';
        }
      }

      return backedUpFiles;
    } catch (error) {
      Logger.error('Config backup failed', { error: error.message });
      throw error;
    }
  }

  sanitizeConfigContent(content) {
    return content
      .replace(/(MONGO_ROOT_PASSWORD\s*=\s*)(.+)/g, '$1[REDACTED]')
      .replace(/(JWT_SECRET\s*=\s*)(.+)/g, '$1[REDACTED]')
      .replace(/(SECRET_KEY\s*=\s*)(.+)/g, '$1[REDACTED]')
      .replace(/(PASSWORD\s*=\s*)(.+)/g, '$1[REDACTED]');
  }

  async backupMediaAssets(backupPath) {
    try {
      const mediaDir = path.join(backupPath, 'media');
      await fs.mkdir(mediaDir, { recursive: true });

      const sourceMediaDir = path.join(process.cwd(), 'uploads');
      let totalFiles = 0;

      try {
        const files = await fs.readdir(sourceMediaDir);
        totalFiles = files.length;

        for (const file of files) {
          const sourcePath = path.join(sourceMediaDir, file);
          const destPath = path.join(mediaDir, file);
          await fs.copyFile(sourcePath, destPath);
        }
      } catch (e) {
        Logger.info('No media directory found, skipping');
      }

      return {
        totalFiles,
        status: totalFiles > 0 ? 'backed_up' : 'no_media'
      };
    } catch (error) {
      Logger.error('Media backup failed', { error: error.message });
      throw error;
    }
  }

  async compressBackup(backupPath, backupId) {
    try {
      const compressedPath = `${backupPath}.tar.gz`;
      const tarCmd = `tar -czf "${compressedPath}" -C "${path.dirname(backupPath)}" "${path.basename(backupPath)}"`;

      await execAsync(tarCmd);
      await fs.rm(backupPath, { recursive: true });

      Logger.info('Backup compressed', { backupId, path: compressedPath });
    } catch (error) {
      Logger.error('Backup compression failed', { backupId, error: error.message });
    }
  }

  async cleanupOldBackups() {
    try {
      const cutoffDate = new Date();
      cutoffDate.setDate(cutoffDate.getDate() - this.retentionDays);

      const backupDirs = await fs.readdir(path.join(this.backupDir, 'database'));

      for (const dir of backupDirs) {
        const dirPath = path.join(this.backupDir, 'database', dir);
        try {
          const stats = await fs.stat(dirPath);
          if (stats.mtime < cutoffDate) {
            await fs.rm(dirPath, { recursive: true });

            const compressedPath = `${dirPath}.tar.gz`;
            try {
              await fs.unlink(compressedPath);
            } catch (e) {
            }

            Logger.info('Old backup removed', { backupId: dir, age: this.retentionDays });
          }
        } catch (e) {
          Logger.warn('Failed to remove old backup', { dir, error: e.message });
        }
      }
    } catch (error) {
      Logger.error('Cleanup old backups failed', { error: error.message });
    }
  }

  async restoreBackup(backupId) {
    const startTime = Date.now();

    try {
      const backupPath = path.join(this.backupDir, 'database', backupId);
      const compressedPath = `${backupPath}.tar.gz`;

      if (!await this.backupExists(backupId)) {
        throw new Error(`Backup not found: ${backupId}`);
      }

      Logger.info(`Starting restore: ${backupId}`);

      await this.createBackup();

      if (await fs.access(compressedPath).then(() => true).catch(() => false)) {
        const extractCmd = `tar -xzf "${compressedPath}" -C "${path.dirname(backupPath)}"`;
        await execAsync(extractCmd);
      }

      const manifestPath = path.join(backupPath, 'manifest.json');
      const manifestContent = await fs.readFile(manifestPath, 'utf-8');
      const manifest = JSON.parse(manifestContent);

      const restoreMongoCmd = `mongorestore --uri="${process.env.MONGO_URI}" --archive="${path.join(backupPath, 'mongodb_dump', 'dump.archive')}" --gzip --drop`;
      await execAsync(restoreMongoCmd, { maxBuffer: 50 * 1024 * 1024 });

      await this.disconnectAllClients();

      const duration = Date.now() - startTime;

      Logger.info('Restore completed successfully', {
        backupId,
        duration,
        collections: Object.keys(manifest.database.collections).length
      });

      return {
        success: true,
        backupId,
        duration,
        collectionsRestored: Object.keys(manifest.database.collections).length,
        timestamp: new Date().toISOString()
      };
    } catch (error) {
      Logger.error('Restore failed', { backupId, error: error.message });
      throw error;
    }
  }

  async disconnectAllClients() {
    try {
      if (global.io) {
        global.io.disconnectSockets();
      }
    } catch (e) {
      Logger.warn('Failed to disconnect sockets', { error: e.message });
    }
  }

  async backupExists(backupId) {
    const backupPath = path.join(this.backupDir, 'database', backupId);
    const compressedPath = `${backupPath}.tar.gz`;

    try {
      await fs.access(backupPath);
      return true;
    } catch (e) {
      try {
        await fs.access(compressedPath);
        return true;
      } catch (e2) {
        return false;
      }
    }
  }

  async syncFromPrimary() {
    try {
      if (!this.primaryServer) {
        throw new Error('Primary server URL not configured');
      }

      const axios = require('axios');
      const response = await axios.post(`${this.primaryServer}/api/admin/backup/create`, {}, {
        timeout: 300000,
        headers: { 'Authorization': `Bearer ${process.env.BACKUP_SYNC_TOKEN}` }
      });

      if (response.data.success) {
        Logger.info('Synced backup from primary', { backupId: response.data.backupId });
      }
    } catch (error) {
      Logger.error('Sync from primary failed', { error: error.message });
    }
  }

  generateBackupId() {
    const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
    return `backup-${timestamp}`;
  }

  async calculateBackupSize(dirPath) {
    try {
      let totalSize = 0;

      const calcSize = async (dir) => {
        const files = await fs.readdir(dir);
        for (const file of files) {
          const filePath = path.join(dir, file);
          const stats = await fs.stat(filePath);
          if (stats.isDirectory()) {
            await calcSize(filePath);
          } else {
            totalSize += stats.size;
          }
        }
      };

      await calcSize(dirPath);
      return totalSize;
    } catch (error) {
      return 0;
    }
  }

  getBackupHistory() {
    return {
      total: this.backupHistory.length,
      recent: this.backupHistory.slice(0, 10),
      lastBackup: this.lastBackupTime,
      enabled: this.isEnabled
    };
  }

  getBackupStats() {
    return {
      isEnabled: this.isEnabled,
      backupDir: this.backupDir,
      maxBackups: this.maxBackups,
      retentionDays: this.retentionDays,
      isBackupServer: this.isBackupServer,
      primaryServer: this.primaryServer ? '[CONFIGURED]' : 'NOT CONFIGURED',
      lastBackup: this.lastBackupTime,
      totalBackups: this.backupHistory.length,
      successfulBackups: this.backupHistory.filter(b => b.status === 'success').length,
      failedBackups: this.backupHistory.filter(b => b.status === 'failed').length
    };
  }

  stop() {
    if (this.backupInterval) {
      clearInterval(this.backupInterval);
      this.backupInterval = null;
      Logger.info('Backup Service stopped');
    }
  }
}

module.exports = new BackupService();

// ─── FROM: cdnService.js ────────────────────────────────────────
const crypto = require('crypto');
const Cloudinary = require('cloudinary').v2;
const Logger = require('../../utils/logger');

class CDNService {
  constructor() {
    this.isEnabled = process.env.CDN_ENABLED !== 'false';
    this.provider = process.env.CDN_PROVIDER || 'cloudinary';
    this.cacheEnabled = true;
    this.defaultCacheTTL = parseInt(process.env.CDN_CACHE_TTL) || 86400;
    this.cdnDomains = {
      images: process.env.CDN_IMAGES_DOMAIN || '',
      videos: process.env.CDN_VIDEOS_DOMAIN || '',
      static: process.env.CDN_STATIC_DOMAIN || ''
    };
    this.stats = {
      requests: 0,
      cacheHits: 0,
      cacheMisses: 0,
      bytesServed: 0
    };
  }

  initialize() {
    if (!this.isEnabled) {
      Logger.info('CDN Service is disabled');
      return false;
    }

    try {
      if (this.provider === 'cloudinary') {
        Cloudinary.config({
          cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
          api_key: process.env.CLOUDINARY_API_KEY,
          api_secret: process.env.CLOUDINARY_API_SECRET
        });
        Logger.info('CDN Service initialized with Cloudinary');
        return true;
      } else if (this.provider === 's3') {
        const AWS = require('aws-sdk');
        this.s3 = new AWS.S3({
          region: process.env.AWS_REGION,
          accessKeyId: process.env.AWS_ACCESS_KEY_ID,
          secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY
        });
        this.s3Bucket = process.env.S3_BUCKET_NAME;
        this.cloudFrontDomain = process.env.CLOUD_FRONT_DOMAIN;
        Logger.info('CDN Service initialized with S3 + CloudFront');
        return true;
      } else if (this.provider === 'local') {
        Logger.info('CDN Service running in local mode (no external CDN)');
        return true;
      }

      Logger.warn('Unknown CDN provider, falling back to local mode');
      return true;
    } catch (error) {
      Logger.error('CDN Service initialization failed', { error: error.message });
      return false;
    }
  }

  async uploadAsset(file, options = {}) {
    try {
      const { folder = 'arvind-party', publicId, transformation } = options;
      const result = await Cloudinary.uploader.upload(file, {
        folder,
        public_id: publicId,
        transformation: transformation || {},
        resource_type: 'auto',
        quality: 'auto:good',
        fetch_format: 'auto'
      });

      const cdnUrl = this.transformToCDNUrl(result.secure_url, result.resource_type);

      Logger.info('Asset uploaded to CDN', {
        publicId: result.public_id,
        format: result.format,
        size: result.bytes,
        cdnUrl
      });

      return {
        success: true,
        url: cdnUrl,
        publicId: result.public_id,
        format: result.format,
        size: result.bytes,
        width: result.width,
        height: result.height,
        resourceType: result.resource_type
      };
    } catch (error) {
      Logger.error('CDN upload failed', { error: error.message });
      throw error;
    }
  }

  async uploadVideo(file, options = {}) {
    try {
      const { folder = 'arvind-party/videos', publicId } = options;
      const result = await Cloudinary.uploader.upload_large(file, {
        folder,
        public_id: publicId,
        resource_type: 'video',
        quality: 'auto:good',
        eager: [
          { format: 'webm', quality: 70 },
          { format: 'mp4', quality: 80 }
        ]
      });

      const cdnUrl = this.transformToCDNUrl(result.secure_url, 'video');

      Logger.info('Video uploaded to CDN', {
        publicId: result.public_id,
        duration: result.duration,
        size: result.bytes,
        cdnUrl
      });

      return {
        success: true,
        url: cdnUrl,
        publicId: result.public_id,
        duration: result.duration,
        size: result.bytes,
        format: result.format,
        resourceType: 'video'
      };
    } catch (error) {
      Logger.error('CDN video upload failed', { error: error.message });
      throw error;
    }
  }

  async deleteAsset(publicId, resourceType = 'image') {
    try {
      const result = await Cloudinary.uploader.destroy(publicId, {
        resource_type: resourceType
      });

      Logger.info('Asset deleted from CDN', { publicId, result: result.result });
      return result;
    } catch (error) {
      Logger.error('CDN delete failed', { publicId, error: error.message });
      throw error;
    }
  }

  transformToCDNUrl(url, resourceType) {
    if (!this.cacheEnabled) {
      return url;
    }

    const domain = this.cdnDomains[resourceType === 'video' ? 'videos' : 'images'];
    if (domain && this.provider === 'cloudinary') {
      return url.replace('res.cloudinary.com', domain);
    }

    return url;
  }

  getOptimizedUrl(publicId, options = {}) {
    try {
      const { width, height, quality, format, crop } = options;
      const transformations = [];

      if (width) transformations.push(`w_${width}`);
      if (height) transformations.push(`h_${height}`);
      if (crop) transformations.push(`c_${crop}`);
      if (quality) transformations.push(`q_${quality}`);
      if (format) transformations.push(`f_${format}`);

      transformations.push('fl_progressive');

      const baseUrl = this.cdnDomains.images || 'res.cloudinary.com';
      const cloudName = process.env.CLOUDINARY_CLOUD_NAME;

      return `https://${baseUrl}/${cloudName}/image/upload/${transformations.join(',')}/${publicId}`;
    } catch (error) {
      Logger.error('Failed to generate optimized URL', { error: error.message });
      return '';
    }
  }

  getVideoUrl(publicId, options = {}) {
    try {
      const { quality, format } = options;
      const transformations = [];

      if (quality) transformations.push(`q_${quality}`);
      if (format) transformations.push(`f_${format}`);

      const baseUrl = this.cdnDomains.videos || 'res.cloudinary.com';
      const cloudName = process.env.CLOUDINARY_CLOUD_NAME;

      return `https://${baseUrl}/${cloudName}/video/upload${transformations.length ? '/' + transformations.join(',') : ''}/${publicId}`;
    } catch (error) {
      Logger.error('Failed to generate video URL', { error: error.message });
      return '';
    }
  }

  generateCacheKey(url) {
    return crypto.createHash('md5').update(url).digest('hex');
  }

  async invalidateCache(urls) {
    try {
      if (this.provider === 'cloudinary') {
        const urlList = Array.isArray(urls) ? urls : [urls];
        const result = await Cloudinary.api.delete_resources_by_prefix(urls[0]);
        Logger.info('CDN cache invalidated', { urls: urlList.length, result: result.result });
        return result;
      } else if (this.provider === 's3' && this.cloudFrontDomain) {
        const cloudfront = require('aws-sdk').CloudFront;
        const cf = new cloudfront({ region: process.env.AWS_REGION });
        const distributionId = process.env.CLOUD_FRONT_DISTRIBUTION_ID;

        const invalidationParams = {
          DistributionId: distributionId,
          InvalidationBatch: {
            CallerReference: Date.now().toString(),
            Paths: {
              Quantity: urlList.length,
              Items: urlList
            }
          }
        };

        const result = await cf.createInvalidation(invalidationParams).promise();
        Logger.info('CloudFront cache invalidated', { invalidationId: result.Invalidation.Id });
        return result;
      }

      return null;
    } catch (error) {
      Logger.error('CDN cache invalidation failed', { error: error.message });
      throw error;
    }
  }

  async getSignedUrl(publicId, expiresIn = 3600) {
    try {
      const timestamp = Math.round(Date.now() / 1000) + expiresIn;

      if (this.provider === 'cloudinary') {
        const signature = Cloudinary.utils.api_sign_request(
          { timestamp, public_id: publicId },
          process.env.CLOUDINARY_API_SECRET
        );

        return `${Cloudinary.url(publicId, { sign_url: true })}?timestamp=${timestamp}&signature=${signature}`;
      }

      return '';
    } catch (error) {
      Logger.error('Failed to generate signed URL', { error: error.message });
      return '';
    }
  }

  recordCacheHit() {
    this.stats.cacheHits++;
    this.stats.requests++;
  }

  recordCacheMiss() {
    this.stats.cacheMisses++;
    this.stats.requests++;
  }

  recordBytesServed(bytes) {
    this.stats.bytesServed += bytes;
  }

  getStats() {
    const hitRate = this.stats.requests > 0
      ? ((this.stats.cacheHits / this.stats.requests) * 100).toFixed(2)
      : 0;

    return {
      ...this.stats,
      hitRate: parseFloat(hitRate),
      provider: this.provider,
      isEnabled: this.isEnabled,
      cacheEnabled: this.cacheEnabled,
      domains: this.cdnDomains
    };
  }

  getHealthStatus() {
    return {
      status: this.isEnabled ? 'healthy' : 'disabled',
      provider: this.provider,
      stats: this.getStats()
    };
  }
}

module.exports = new CDNService();

// ─── FROM: deploymentService.js ────────────────────────────────────────
const { exec } = require('child_process');
const { promisify } = require('util');
const fs = require('fs').promises;
const path = require('path');
const BackupService = require('./backupService');
const Logger = require('../../utils/logger');

const execAsync = promisify(exec);

class DeploymentService {
  constructor() {
    this.isEnabled = process.env.AUTO_DEPLOY_ENABLED !== 'false';
    this.currentVersion = process.env.VERSION || '1.0.0';
    this.deployHistory = [];
    this.maxHistory = 20;
    this.isDeploying = false;
    this.gitRepo = process.env.GIT_REPO || '';
    this.deployBranch = process.env.DEPLOY_BRANCH || 'main';
    this.deployPath = process.env.DEPLOY_PATH || process.cwd();
    this.webhookSecret = process.env.DEPLOY_WEBHOOK_SECRET || '';
  }

  async initialize() {
    if (!this.isEnabled) {
      Logger.info('Auto Deployment is disabled');
      return false;
    }

    try {
      const gitDir = path.join(this.deployPath, '.git');
      try {
        await fs.access(gitDir);
        Logger.info('Deployment Service initialized', { branch: this.deployBranch });
        return true;
      } catch (e) {
        Logger.warn('Not a git repository, deployment service disabled');
        this.isEnabled = false;
        return false;
      }
    } catch (error) {
      Logger.error('Deployment Service initialization failed', { error: error.message });
      return false;
    }
  }

  async deploy(source = 'manual') {
    if (this.isDeploying) {
      return { success: false, message: 'Deployment already in progress' };
    }

    this.isDeploying = true;
    const startTime = Date.now();
    const deployId = this.generateDeployId();

    try {
      Logger.info('Starting deployment', { deployId, source });

      const preDeployBackup = await this.createPreDeployBackup();

      await this.pullLatestCode();
      await this.installDependencies();
      const buildResult = await this.buildApplication();
      await this.runMigrations();
      await this.restartApplication();
      await this.verifyDeployment();

      const duration = Date.now() - startTime;
      const deployRecord = {
        id: deployId,
        timestamp: new Date().toISOString(),
        duration,
        version: this.currentVersion,
        source,
        status: 'success',
        backupId: preDeployBackup?.backupId || null,
        buildResult
      };

      this.deployHistory.unshift(deployRecord);
      if (this.deployHistory.length > this.maxHistory) {
        this.deployHistory.pop();
      }

      if (global.io) {
        global.io.to('admins').emit('deployment:complete', deployRecord);
      }

      Logger.info('Deployment completed successfully', { deployId, duration });

      return {
        success: true,
        deployId,
        version: this.currentVersion,
        duration,
        message: 'Deployment successful'
      };
    } catch (error) {
      const duration = Date.now() - startTime;

      const failedRecord = {
        id: deployId,
        timestamp: new Date().toISOString(),
        duration,
        version: this.currentVersion,
        source,
        status: 'failed',
        error: error.message
      };

      this.deployHistory.unshift(failedRecord);

      Logger.error('Deployment failed', { deployId, error: error.message });

      if (global.io) {
        global.io.to('admins').emit('deployment:failed', failedRecord);
      }

      return {
        success: false,
        deployId,
        error: error.message,
        message: 'Deployment failed'
      };
    } finally {
      this.isDeploying = false;
    }
  }

  async createPreDeployBackup() {
    try {
      const BackupService = require('./backupService');
      if (BackupService.isEnabled) {
        const result = await BackupService.createBackup();
        Logger.info('Pre-deployment backup created', { backupId: result.backupId });
        return result;
      }
    } catch (error) {
      Logger.warn('Pre-deployment backup failed', { error: error.message });
    }
    return null;
  }

  async pullLatestCode() {
    try {
      await execAsync('git fetch origin', { cwd: this.deployPath });
      const result = await execAsync(`git reset --hard origin/${this.deployBranch}`, { cwd: this.deployPath });
      Logger.info('Code pulled from git', { branch: this.deployBranch });
      return result;
    } catch (error) {
      Logger.warn('Git pull failed, continuing with existing code', { error: error.message });
    }
  }

  async installDependencies() {
    try {
      const packageManager = await fs.access(path.join(this.deployPath, 'package-lock.json'))
        .then(() => 'npm ci --only=production')
        .catch(() => 'npm install --only=production');

      const result = await execAsync(packageManager, { cwd: this.deployPath, timeout: 300000 });
      Logger.info('Dependencies installed');
      return result;
    } catch (error) {
      Logger.error('Dependency installation failed', { error: error.message });
      throw new Error(`npm install failed: ${error.message}`);
    }
  }

  async buildApplication() {
    try {
      const hasBuildScript = await this.checkPackageScript('build');

      if (hasBuildScript) {
        const result = await execAsync('npm run build', { cwd: this.deployPath, timeout: 300000 });
        Logger.info('Application built successfully');
        return { built: true, output: result.stdout.slice(-500) };
      }

      return { built: false, reason: 'No build script found' };
    } catch (error) {
      Logger.error('Build failed', { error: error.message });
      throw new Error(`Build failed: ${error.message}`);
    }
  }

  async checkPackageScript(scriptName) {
    try {
      const packageJsonPath = path.join(this.deployPath, 'package.json');
      const packageJson = JSON.parse(await fs.readFile(packageJsonPath, 'utf-8'));
      return !!(packageJson.scripts && packageJson.scripts[scriptName]);
    } catch (error) {
      return false;
    }
  }

  async runMigrations() {
    try {
      const result = await execAsync('npm run migrate', { cwd: this.deployPath, timeout: 120000 });
      Logger.info('Database migrations completed');
      return result;
    } catch (error) {
      Logger.warn('Migration command failed or not found', { error: error.message });
    }
  }

  async restartApplication() {
    try {
      if (process.env.PM2_PROCESS_NAME) {
        await execAsync(`pm2 restart ${process.env.PM2_PROCESS_NAME}`, { timeout: 30000 });
        Logger.info('Application restarted via PM2');
      } else if (process.env.DOCKER_CONTAINER_NAME) {
        await execAsync(`docker restart ${process.env.DOCKER_CONTAINER_NAME}`, { timeout: 60000 });
        Logger.info('Application restarted via Docker');
      } else if (process.env.RENDER_SERVICE_ID) {
        Logger.info('Render auto-deploys on git push, no manual restart needed');
      } else {
        Logger.info('No restart mechanism configured, manual restart required');
      }
    } catch (error) {
      Logger.warn('Application restart failed', { error: error.message });
    }
  }

  async verifyDeployment() {
    try {
      const maxRetries = 10;
      const retryDelay = 3000;

      for (let i = 0; i < maxRetries; i++) {
        try {
          const axios = require('axios');
          const healthUrl = `${process.env.HEALTH_CHECK_URL || 'http://localhost:5000'}/api/health`;
          const response = await axios.get(healthUrl, { timeout: 5000 });

          if (response.status === 200) {
            Logger.info('Deployment verified - health check passed');
            return { verified: true, healthResponse: response.data };
          }
        } catch (error) {
          await new Promise(resolve => setTimeout(resolve, retryDelay));
        }
      }

      throw new Error('Health check verification failed after retries');
    } catch (error) {
      Logger.error('Deployment verification failed', { error: error.message });
      throw error;
    }
  }

  async rollback(targetVersion = null, options = {}) {
    if (this.isDeploying) {
      return { success: false, message: 'Cannot rollback during deployment' };
    }

    const startTime = Date.now();
    const rollbackId = this.generateDeployId();

    try {
      Logger.info('Starting rollback', { rollbackId, targetVersion });

      const currentDeploy = this.deployHistory[0];
      if (!currentDeploy) {
        throw new Error('No deployment history found');
      }

      let targetDeploy;
      if (targetVersion) {
        targetDeploy = this.deployHistory.find(d => d.version === targetVersion);
      } else {
        targetDeploy = this.deployHistory.find(d => d.status === 'success' && d.id !== currentDeploy.id);
      }

      if (!targetDeploy) {
        throw new Error(targetVersion ? `Version ${targetVersion} not found in history` : 'No previous successful deployment found');
      }

      const targetCommit = await this.getCommitForVersion(targetDeploy.id);

      await execAsync(`git reset --hard ${targetCommit}`, { cwd: this.deployPath });
      await this.installDependencies();
      const buildResult = await this.buildApplication();
      await this.restartApplication();
      await this.verifyDeployment();

      const duration = Date.now() - startTime;

      const rollbackRecord = {
        id: rollbackId,
        timestamp: new Date().toISOString(),
        duration,
        type: 'rollback',
        fromVersion: currentDeploy.version,
        toVersion: targetDeploy.version,
        targetCommit,
        status: 'success'
      };

      this.deployHistory.unshift(rollbackRecord);

      this.currentVersion = targetDeploy.version;

      if (global.io) {
        global.io.to('admins').emit('deployment:rollback', rollbackRecord);
      }

      Logger.info('Rollback completed successfully', {
        rollbackId,
        from: currentDeploy.version,
        to: targetDeploy.version
      });

      return {
        success: true,
        rollbackId,
        fromVersion: currentDeploy.version,
        toVersion: targetDeploy.version,
        duration,
        message: 'Rollback successful'
      };
    } catch (error) {
      const duration = Date.now() - startTime;

      Logger.error('Rollback failed', { rollbackId, error: error.message });

      return {
        success: false,
        rollbackId,
        error: error.message,
        message: 'Rollback failed'
      };
    }
  }

  async getCommitForVersion(deployId) {
    try {
      const result = await execAsync('git log --oneline -20', { cwd: this.deployPath });
      const commits = result.stdout.split('\n').filter(c => c.trim());

      const deploy = this.deployHistory.find(d => d.id === deployId);
      if (deploy && deploy.gitCommit) {
        return deploy.gitCommit;
      }

      return commits[0]?.split(' ')[0];
    } catch (error) {
      return 'HEAD~1';
    }
  }

  async getDeploymentHistory(limit = 20) {
    return {
      total: this.deployHistory.length,
      currentVersion: this.currentVersion,
      history: this.deployHistory.slice(0, limit)
    };
  }

  getCurrentVersion() {
    return this.currentVersion;
  }

  async verifyWebhookSignature(payload, signature) {
    const crypto = require('crypto');
    const hmac = crypto.createHmac('sha256', this.webhookSecret);
    const expectedSignature = `sha256=${hmac.update(payload).digest('hex')}`;

    return crypto.timingSafeEqual(
      Buffer.from(signature || ''),
      Buffer.from(expectedSignature)
    );
  }

  async handleWebhook(payload, signature) {
    try {
      const isValid = await this.verifyWebhookSignature(JSON.stringify(payload), signature);
      if (!isValid) {
        throw new Error('Invalid webhook signature');
      }

      const event = payload?.ref?.split('/').pop() || 'unknown';
      if (event !== this.deployBranch) {
        return { success: true, message: `Ignoring push to ${event}, deploying ${this.deployBranch} only` };
      }

      const delay = parseInt(process.env.DEPLOY_DELAY_MS) || 0;
      if (delay > 0) {
        await new Promise(resolve => setTimeout(resolve, delay));
      }

      return await this.deploy('webhook');
    } catch (error) {
      Logger.error('Webhook handling failed', { error: error.message });
      return { success: false, error: error.message };
    }
  }

  generateDeployId() {
    const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
    return `deploy-${timestamp}`;
  }

  getStats() {
    return {
      enabled: this.isEnabled,
      currentVersion: this.currentVersion,
      branch: this.deployBranch,
      deploying: this.isDeploying,
      totalDeployments: this.deployHistory.length,
      successfulDeploys: this.deployHistory.filter(d => d.status === 'success').length,
      failedDeploys: this.deployHistory.filter(d => d.status === 'failed').length,
      lastDeployment: this.deployHistory[0] || null
    };
  }

  getHealthStatus() {
    const recentDeploys = this.deployHistory.slice(0, 5);
    const failedRecent = recentDeploys.filter(d => d.status === 'failed').length;

    let status = 'healthy';
    if (this.isDeploying) status = 'deploying';
    else if (failedRecent >= 2) status = 'degraded';
    else if (failedRecent >= 1) status = 'warning';

    return {
      status,
      currentVersion: this.currentVersion,
      isDeploying: this.isDeploying,
      recentFailures: failedRecent
    };
  }
}

module.exports = new DeploymentService();

// ─── FROM: errorReportingService.js ────────────────────────────────────────
const Sentry = require('@sentry/node');
const { NodeInstrumentation } = require('@sentry/integrations');
const MonitoringService = require('./monitoringService');
const Logger = require('../../utils/logger');

class ErrorReportingService {
  constructor() {
    this.isEnabled = process.env.SENTRY_DSN ? true : false;
    this.dsn = process.env.SENTRY_DSN || '';
    this.environment = process.env.NODE_ENV || 'development';
    this.errorHistory = [];
    this.maxHistory = parseInt(process.env.ERROR_HISTORY_MAX) || 500;
    this.alertThresholds = {
      critical: 10,
      error: 50,
      warning: 200
    };
    this.aiResolutionEnabled = process.env.AI_ERROR_RESOLUTION === 'true';
  }

  initialize() {
    if (!this.isEnabled) {
      Logger.info('Sentry Error Reporting is disabled');
      return false;
    }

    try {
      Sentry.init({
        dsn: this.dsn,
        environment: this.environment,
        tracesSampleRate: process.env.SENTRY_TRACES_SAMPLE_RATE || 0.1,
        integrations: [
          new NodeInstrumentation(),
          new Sentry.Integrations.Http({ tracing: true }),
          new Sentry.Integrations.Express({ app: null })
        ]
      });

      const requestHandler = Sentry.Handlers.requestHandler();
      const tracingHandler = Sentry.Handlers.tracingHandler();

      Logger.info('Sentry Error Reporting initialized', { environment: this.environment });
      return true;
    } catch (error) {
      Logger.error('Sentry initialization failed', { error: error.message });
      this.isEnabled = false;
      return false;
    }
  }

  captureException(error, context = {}) {
    const errorRecord = {
      id: Date.now().toString(36) + Math.random().toString(36).substr(2),
      timestamp: new Date().toISOString(),
      error: {
        message: error.message || String(error),
        stack: error.stack,
        name: error.name
      },
      context,
      severity: this.determineSeverity(error),
      aiGenerated: false,
      resolved: false
    };

    if (this.isEnabled) {
      Sentry.withScope((scope) => {
        scope.setContext('custom', context);
        scope.setLevel(errorRecord.severity);
        Sentry.captureException(error);
      });
    }

    this.errorHistory.unshift(errorRecord);
    if (this.errorHistory.length > this.maxHistory) {
      this.errorHistory.pop();
    }

    this.checkAlertThresholds(errorRecord.severity);

    Logger.error('Error captured', {
      id: errorRecord.id,
      message: errorRecord.error.message,
      severity: errorRecord.severity
    });

    return errorRecord;
  }

  captureMessage(message, level = 'info', context = {}) {
    const messageRecord = {
      id: Date.now().toString(36) + Math.random().toString(36).substr(2),
      timestamp: new Date().toISOString(),
      message,
      level,
      context,
      severity: this.mapLevelToSeverity(level)
    };

    if (this.isEnabled) {
      Sentry.captureMessage(message, level);
    }

    this.errorHistory.unshift(messageRecord);
    if (this.errorHistory.length > this.maxHistory) {
      this.errorHistory.pop();
    }

    return messageRecord;
  }

  determineSeverity(error) {
    if (error.message?.includes('ECONNREFUSED') || error.message?.includes('ETIMEDOUT')) {
      return 'warning';
    }
    if (error.message?.includes('MongoServerError') || error.message?.includes('MongoNetworkError')) {
      return 'critical';
    }
    if (error.statusCode >= 500) {
      return 'error';
    }
    if (error.statusCode >= 400) {
      return 'warning';
    }
    return 'error';
  }

  mapLevelToSeverity(level) {
    const mapping = {
      fatal: 'critical',
      error: 'error',
      warning: 'warning',
      info: 'info',
      log: 'info',
      debug: 'info'
    };
    return mapping[level] || 'info';
  }

  checkAlertThresholds(severity) {
    const recentErrors = this.getRecentErrors(5 * 60 * 1000);
    const countBySeverity = recentErrors.reduce((acc, err) => {
      acc[err.severity] = (acc[err.severity] || 0) + 1;
      return acc;
    }, {});

    for (const [level, threshold] of Object.entries(this.alertThresholds)) {
      if (countBySeverity[level] >= threshold) {
        this.triggerAlert(level, countBySeverity[level]);
      }
    }
  }

  triggerAlert(severity, count) {
    const alert = {
      timestamp: new Date().toISOString(),
      severity,
      count,
      message: `High volume of ${severity} errors detected: ${count} in last 5 minutes`
    };

    Logger.error('ALERT TRIGGERED', alert);

    if (global.io) {
      global.io.to('admins').emit('error:alert', alert);
    }

    if (process.env.ALERT_EMAIL_ENABLED === 'true') {
      this.sendEmailAlert(alert);
    }

    if (process.env.ALERT_SLACK_WEBHOOK) {
      this.sendSlackAlert(alert);
    }
  }

  async sendEmailAlert(alert) {
    try {
      const nodemailer = require('nodemailer');
      const transporter = nodemailer.createTransport({
        host: process.env.SMTP_HOST,
        port: process.env.SMTP_PORT,
        secure: true,
        auth: {
          user: process.env.SMTP_USER,
          pass: process.env.SMTP_PASS
        }
      });

      await transporter.sendMail({
        from: process.env.ALERT_FROM_EMAIL,
        to: process.env.ALERT_TO_EMAIL,
        subject: `[${alert.severity.toUpperCase()}] Arvind Party - Critical Error Alert`,
        html: `
          <h2>Critical Error Alert</h2>
          <p><strong>Severity:</strong> ${alert.severity}</p>
          <p><strong>Count:</strong> ${alert.count}</p>
          <p><strong>Message:</strong> ${alert.message}</p>
          <p><strong>Time:</strong> ${alert.timestamp}</p>
        `
      });

      Logger.info('Email alert sent', { severity: alert.severity, count: alert.count });
    } catch (error) {
      Logger.error('Failed to send email alert', { error: error.message });
    }
  }

  async sendSlackAlert(alert) {
    try {
      const axios = require('axios');
      await axios.post(process.env.ALERT_SLACK_WEBHOOK, {
        text: `*[${alert.severity.toUpperCase()}]* Arvind Party Alert\n${alert.message}\nTime: ${alert.timestamp}`,
        attachments: [{
          color: alert.severity === 'critical' ? 'danger' : alert.severity === 'error' ? 'warning' : 'good',
          fields: [
            { title: 'Severity', value: alert.severity, short: true },
            { title: 'Count', value: alert.count.toString(), short: true },
            { title: 'Time', value: alert.timestamp, short: false }
          ]
        }]
      });

      Logger.info('Slack alert sent', { severity: alert.severity });
    } catch (error) {
      Logger.error('Failed to send Slack alert', { error: error.message });
    }
  }

  async generateAIResolution(errorId) {
    if (!this.aiResolutionEnabled) {
      return null;
    }

    const error = this.errorHistory.find(e => e.id === errorId);
    if (!error) {
      return null;
    }

    try {
      const OpenAI = require('openai');
      const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });

      const prompt = `
You are a senior Node.js developer. Analyze this error and provide a detailed solution.

Error: ${error.error.message}
Stack: ${error.error.stack}
Context: ${JSON.stringify(error.context, null, 2)}

Provide:
1. Root cause analysis
2. Step-by-step solution
3. Prevention strategy
4. Code fix if applicable
      `;

      const completion = await openai.chat.completions.create({
        model: 'gpt-4',
        messages: [{ role: 'user', content: prompt }],
        max_tokens: 1000,
        temperature: 0.3
      });

      const aiSolution = completion.choices[0].message.content;

      error.aiGenerated = true;
      error.aiSolution = aiSolution;
      error.aiResolvedAt = new Date().toISOString();

      if (global.io) {
        global.io.to('admins').emit('error:ai_solution', {
          errorId: error.id,
          solution: aiSolution
        });
      }

      Logger.info('AI resolution generated', { errorId });
      return aiSolution;
    } catch (error) {
      Logger.error('AI resolution failed', { errorId, error: error.message });
      return null;
    }
  }

  getRecentErrors(durationMs = 3600000) {
    const cutoff = Date.now() - durationMs;
    return this.errorHistory.filter(err => new Date(err.timestamp).getTime() > cutoff);
  }

  getErrorStats() {
    const recent = this.getRecentErrors(3600000);
    const stats = {
      total: recent.length,
      bySeverity: {},
      byHour: {},
      topErrors: []
    };

    const errorCounts = {};
    recent.forEach(err => {
      stats.bySeverity[err.severity] = (stats.bySeverity[err.severity] || 0) + 1;

      const hour = new Date(err.timestamp).toISOString().slice(0, 13);
      stats.byHour[hour] = (stats.byHour[hour] || 0) + 1;

      const key = err.error.message;
      errorCounts[key] = (errorCounts[key] || 0) + 1;
    });

    stats.topErrors = Object.entries(errorCounts)
      .sort((a, b) => b[1] - a[1])
      .slice(0, 5)
      .map(([message, count]) => ({ message, count }));

    return stats;
  }

  getErrorHistory(limit = 100, severity = null) {
    let errors = this.errorHistory.slice(0, limit);
    if (severity) {
      errors = errors.filter(e => e.severity === severity);
    }
    return errors;
  }

  clearHistory() {
    this.errorHistory = [];
    Logger.info('Error history cleared');
  }

  getHealthStatus() {
    const recentErrors = this.getRecentErrors(300000);
    const criticalCount = recentErrors.filter(e => e.severity === 'critical').length;

    let status = 'healthy';
    if (criticalCount > 5) status = 'critical';
    else if (recentErrors.length > 50) status = 'degraded';

    return {
      status,
      enabled: this.isEnabled,
      recentErrors: recentErrors.length,
      criticalCount,
      dsn: this.dsn ? '[CONFIGURED]' : 'NOT CONFIGURED'
    };
  }

  resolveError(errorId, resolution) {
    const error = this.errorHistory.find(e => e.id === errorId);
    if (error) {
      error.resolved = true;
      error.resolution = resolution;
      error.resolvedAt = new Date().toISOString();
      Logger.info('Error marked as resolved', { errorId, resolution });
      return true;
    }
    return false;
  }

  getSentryUser(userId) {
    if (!this.isEnabled) return null;

    return Sentry.getUser();
  }

  setSentryUser(user) {
    if (!this.isEnabled) return;

    Sentry.setUser(user);
  }
}

module.exports = new ErrorReportingService();

// ─── FROM: featureFlagService.js ────────────────────────────────────────
const EventEmitter = require('events');
const Logger = require('../../utils/logger');

class FeatureFlagService extends EventEmitter {
  constructor() {
    super();
    this.isEnabled = process.env.FEATURE_FLAGS_ENABLED !== 'false';
    this.flags = new Map();
    this.overrideRules = new Map();
    this.rolloutHistory = [];
    this.maxHistory = 100;
    this.defaultTtl = parseInt(process.env.FEATURE_FLAG_TTL) || 86400000;
  }

  initialize() {
    if (!this.isEnabled) {
      Logger.info('Feature Flag Service is disabled');
      return false;
    }

    this.loadDefaultFlags();

    Logger.info('Feature Flag Service initialized', {
      flagCount: this.flags.size
    });

    return true;
  }

  loadDefaultFlags() {
    const defaultFlags = [
      {
        key: 'new_games_enabled',
        name: 'New Games Feature',
        description: 'Enables new games like Lucky Wheel, Scratch Card',
        enabled: false,
        rolloutPercentage: 0,
        targetUsers: [],
        environments: ['staging'],
        createdAt: new Date().toISOString(),
        createdBy: 'system'
      },
      {
        key: 'webview_games',
        name: 'WebView Games',
        description: 'Enables WebView-based mini games',
        enabled: false,
        rolloutPercentage: 0,
        targetUsers: [],
        environments: [],
        createdAt: new Date().toISOString(),
        createdBy: 'system'
      },
      {
        key: 'advanced_analytics',
        name: 'Advanced Analytics Dashboard',
        description: 'Enables advanced analytics for admins',
        enabled: true,
        rolloutPercentage: 100,
        targetUsers: ['admin', 'super_admin'],
        environments: ['production', 'staging'],
        createdAt: new Date().toISOString(),
        createdBy: 'system'
      },
      {
        key: 'family_war_2v2',
        name: 'Family War 2v2 Mode',
        description: 'Enables 2v2 family war battles',
        enabled: false,
        rolloutPercentage: 10,
        targetUsers: [],
        environments: ['staging'],
        createdAt: new Date().toISOString(),
        createdBy: 'system'
      },
      {
        key: 'new_onboarding',
        name: 'New User Onboarding Flow',
        description: 'Enables redesigned onboarding experience',
        enabled: true,
        rolloutPercentage: 50,
        targetUsers: [],
        environments: ['staging'],
        createdAt: new Date().toISOString(),
        createdBy: 'system'
      },
      {
        key: 'dark_mode',
        name: 'Dark Mode',
        description: 'Enables dark mode theme for app',
        enabled: true,
        rolloutPercentage: 100,
        targetUsers: [],
        environments: ['production', 'staging'],
        createdAt: new Date().toISOString(),
        createdBy: 'system'
      },
      {
        key: 'video_gifts',
        name: 'Video Gifts',
        description: 'Enables video-based gift animations',
        enabled: false,
        rolloutPercentage: 0,
        targetUsers: ['beta_tester'],
        environments: ['staging'],
        createdAt: new Date().toISOString(),
        createdBy: 'system'
      },
      {
        key: 'ai_recommendations',
        name: 'AI-Powered Recommendations',
        description: 'Enables AI-based user recommendations',
        enabled: false,
        rolloutPercentage: 0,
        targetUsers: [],
        environments: [],
        createdAt: new Date().toISOString(),
        createdBy: 'system'
      },
      {
        key: 'live_streaming',
        name: 'Live Streaming Feature',
        description: 'Enables live streaming capabilities',
        enabled: false,
        rolloutPercentage: 0,
        targetUsers: [],
        environments: [],
        createdAt: new Date().toISOString(),
        createdBy: 'system'
      },
      {
        key: 'crypto_payments',
        name: 'Cryptocurrency Payments',
        description: 'Enables crypto payment gateway',
        enabled: false,
        rolloutPercentage: 0,
        targetUsers: [],
        environments: [],
        createdAt: new Date().toISOString(),
        createdBy: 'system'
      }
    ];

    defaultFlags.forEach(flag => {
      this.flags.set(flag.key, flag);
    });
  }

  isFeatureEnabled(flagKey, user = {}) {
    if (!this.isEnabled) {
      return true;
    }

    const flag = this.flags.get(flagKey);
    if (!flag) {
      Logger.warn('Feature flag not found', { flagKey });
      return false;
    }

    if (!flag.enabled) {
      return false;
    }

    const environment = process.env.NODE_ENV || 'development';
    if (flag.environments.length > 0 && !flag.environments.includes(environment)) {
      return false;
    }

    if (flag.targetUsers.length > 0) {
      const userRoles = user.roles || [user.role];
      const hasAccess = flag.targetUsers.some(role => userRoles.includes(role));
      if (!hasAccess) {
        return false;
      }
    }

    if (flag.rolloutPercentage < 100 && user.userId) {
      const hash = this.hashUserId(user.userId);
      const userBucket = hash % 100;
      if (userBucket >= flag.rolloutPercentage) {
        return false;
      }
    }

    return true;
  }

  hashUserId(userId) {
    let hash = 0;
    const str = String(userId);
    for (let i = 0; i < str.length; i++) {
      const char = str.charCodeAt(i);
      hash = ((hash << 5) - hash) + char;
      hash = hash & hash;
    }
    return Math.abs(hash);
  }

  createFlag(flagData, createdBy) {
    if (this.flags.has(flagData.key)) {
      throw new Error(`Feature flag already exists: ${flagData.key}`);
    }

    const flag = {
      key: flagData.key,
      name: flagData.name || flagData.key,
      description: flagData.description || '',
      enabled: flagData.enabled || false,
      rolloutPercentage: flagData.rolloutPercentage ?? 0,
      targetUsers: flagData.targetUsers || [],
      environments: flagData.environments || [],
      createdAt: new Date().toISOString(),
      createdBy,
      updatedAt: new Date().toISOString()
    };

    this.flags.set(flag.key, flag);
    this.recordChange('create', flag.key, flag, createdBy);
    this.emit('flag:created', flag);

    Logger.info('Feature flag created', { key: flag.key, enabled: flag.enabled, createdBy });
    return flag;
  }

  updateFlag(flagKey, updates, updatedBy) {
    const flag = this.flags.get(flagKey);
    if (!flag) {
      throw new Error(`Feature flag not found: ${flagKey}`);
    }

    const oldValues = {
      enabled: flag.enabled,
      rolloutPercentage: flag.rolloutPercentage,
      targetUsers: [...flag.targetUsers],
      environments: [...flag.environments]
    };

    if (updates.enabled !== undefined) flag.enabled = updates.enabled;
    if (updates.rolloutPercentage !== undefined) flag.rolloutPercentage = updates.rolloutPercentage;
    if (updates.targetUsers !== undefined) flag.targetUsers = updates.targetUsers;
    if (updates.environments !== undefined) flag.environments = updates.environments;
    if (updates.name !== undefined) flag.name = updates.name;
    if (updates.description !== undefined) flag.description = updates.description;

    flag.updatedAt = new Date().toISOString();
    flag.updatedBy = updatedBy;

    this.recordChange('update', flagKey, { oldValues, newValues: updates }, updatedBy);
    this.emit('flag:updated', flag);

    Logger.info('Feature flag updated', {
      key: flagKey,
      enabled: flag.enabled,
      rolloutPercentage: flag.rolloutPercentage,
      updatedBy
    });

    return flag;
  }

  deleteFlag(flagKey, deletedBy) {
    const flag = this.flags.get(flagKey);
    if (!flag) {
      throw new Error(`Feature flag not found: ${flagKey}`);
    }

    this.flags.delete(flagKey);
    this.recordChange('delete', flagKey, flag, deletedBy);
    this.emit('flag:deleted', flagKey);

    Logger.info('Feature flag deleted', { key: flagKey, deletedBy });
    return true;
  }

  setOverride(flagKey, value, userId, expiresIn = null) {
    const override = {
      flagKey,
      value,
      userId,
      createdAt: new Date().toISOString(),
      expiresAt: expiresIn ? new Date(Date.now() + expiresIn).toISOString() : null
    };

    this.overrideRules.set(`${flagKey}_${userId}`, override);

    Logger.info('Feature flag override set', { flagKey, userId, value });
    return override;
  }

  removeOverride(flagKey, userId) {
    const key = `${flagKey}_${userId}`;
    const removed = this.overrideRules.delete(key);
    if (removed) {
      Logger.info('Feature flag override removed', { flagKey, userId });
    }
    return removed;
  }

  getOverride(flagKey, userId) {
    const override = this.overrideRules.get(`${flagKey}_${userId}`);
    if (!override) return null;

    if (override.expiresAt && new Date(override.expiresAt) < new Date()) {
      this.overrideRules.delete(`${flagKey}_${userId}`);
      return null;
    }

    return override.value;
  }

  getFlag(flagKey) {
    return this.flags.get(flagKey) || null;
  }

  getAllFlags() {
    return Array.from(this.flags.values());
  }

  getFlagsByEnvironment(environment) {
    return this.getAllFlags().filter(flag =>
      flag.environments.length === 0 || flag.environments.includes(environment)
    );
  }

  recordChange(action, flagKey, data, userId) {
    this.rolloutHistory.unshift({
      action,
      flagKey,
      data,
      userId,
      timestamp: new Date().toISOString()
    });

    if (this.rolloutHistory.length > this.maxHistory) {
      this.rolloutHistory.pop();
    }
  }

  getRolloutHistory(limit = 50) {
    return this.rolloutHistory.slice(0, limit);
  }

  getStats() {
    const total = this.flags.size;
    const enabled = Array.from(this.flags.values()).filter(f => f.enabled).length;
    const disabled = total - enabled;
    const environment = process.env.NODE_ENV || 'development';

    return {
      enabled: this.isEnabled,
      totalFlags: total,
      enabledFlags: enabled,
      disabledFlags: disabled,
      activeOverrides: this.overrideRules.size,
      environment,
      recentChanges: this.rolloutHistory.slice(0, 10)
    };
  }

  getHealthStatus() {
    return {
      status: this.isEnabled ? 'healthy' : 'disabled',
      totalFlags: this.flags.size,
      enabledFlags: Array.from(this.flags.values()).filter(f => f.enabled).length
    };
  }

  bulkUpdateFlags(updates, updatedBy) {
    const results = [];
    try {
      for (const update of updates) {
        const flag = this.updateFlag(update.key, update.values, updatedBy);
        results.push({ key: update.key, success: true, flag });
      }
      return { success: true, updated: results.length, results };
    } catch (error) {
      return { success: false, error: error.message, results };
    }
  }

  exportFlags() {
    return {
      flags: this.getAllFlags(),
      overrides: Array.from(this.overrideRules.values()),
      history: this.rolloutHistory,
      exportedAt: new Date().toISOString(),
      version: '1.0.0'
    };
  }

  importFlags(data, importedBy) {
    try {
      if (data.flags && Array.isArray(data.flags)) {
        data.flags.forEach(flag => {
          if (!this.flags.has(flag.key)) {
            this.flags.set(flag.key, flag);
            this.recordChange('import', flag.key, flag, importedBy);
          }
        });
      }

      if (data.overrides && Array.isArray(data.overrides)) {
        data.overrides.forEach(override => {
          this.overrideRules.set(`${override.flagKey}_${override.userId}`, override);
        });
      }

      Logger.info('Feature flags imported', {
        flagsCount: data.flags?.length || 0,
        overridesCount: data.overrides?.length || 0,
        importedBy
      });

      this.emit('flags:imported', { flagsCount: data.flags?.length || 0 });
      return true;
    } catch (error) {
      Logger.error('Failed to import feature flags', { error: error.message });
      return false;
    }
  }
}

module.exports = new FeatureFlagService();

// ─── FROM: healthAlertService.js ────────────────────────────────────────
const MonitoringService = require('./monitoringService');
const AutoScalingService = require('./autoScalingService');
const BackupService = require('./backupService');
const Logger = require('../../utils/logger');

class HealthAlertService {
  constructor() {
    this.isEnabled = process.env.HEALTH_ALERTS_ENABLED !== 'false';
    this.checkIntervalMs = parseInt(process.env.HEALTH_CHECK_INTERVAL) || 30000;
    this.alertCooldownMs = parseInt(process.env.ALERT_COOLDOWN_MS) || 300000;
    this.lastAlertTime = {};
    this.alertHistory = [];
    this.maxHistory = 100;
    this.checkInterval = null;
    this.activeAlerts = [];
    this.alertRules = {
      memory: { threshold: 85, severity: 'critical', cooldown: 300000 },
      cpu: { threshold: 90, severity: 'error', cooldown: 300000 },
      diskSpace: { threshold: 90, severity: 'critical', cooldown: 600000 },
      database: { severity: 'critical', cooldown: 180000 },
      redis: { severity: 'warning', cooldown: 180000 },
      queue: { severity: 'warning', cooldown: 180000 },
      websocket: { severity: 'warning', cooldown: 180000 },
      backup: { severity: 'warning', cooldown: 21600000 },
      errorRate: { threshold: 20, severity: 'error', cooldown: 300000 }
    };
  }

  start() {
    if (!this.isEnabled) {
      Logger.info('Health Alert Service is disabled');
      return;
    }

    Logger.info('Health Alert Service started', { interval: this.checkIntervalMs });

    this.checkInterval = setInterval(() => {
      this.runHealthChecks();
    }, this.checkIntervalMs);
  }

  stop() {
    if (this.checkInterval) {
      clearInterval(this.checkInterval);
      this.checkInterval = null;
      Logger.info('Health Alert Service stopped');
    }
  }

  async runHealthChecks() {
    try {
      const metrics = MonitoringService.getMetrics();
      const system = metrics.system;
      const health = MonitoringService.getHealthStatus();

      if (health.status === 'healthy') {
        this.resolveAllAlerts();
        return;
      }

      if (system.memory > this.alertRules.memory.threshold) {
        this.triggerAlert('memory', 'high', `Memory usage critical: ${system.memory}%`, {
          memory: system.memory,
          total: system.totalMemory,
          used: system.usedMemory,
          free: system.freeMemory
        }, this.alertRules.memory.severity);
      }

      if (system.cpu?.usage > this.alertRules.cpu.threshold) {
        this.triggerAlert('cpu', 'high', `CPU usage critical: ${system.cpu.usage.toFixed(1)}%`, {
          cpu: system.cpu.usage,
          cores: system.cpu.cores
        }, this.alertRules.cpu.severity);
      }

      if (!metrics.database?.connected) {
        this.triggerAlert('database', 'down', 'Database connection lost', {
          status: 'disconnected'
        }, this.alertRules.database.severity);
      }

      if (!metrics.redis?.connected) {
        this.triggerAlert('redis', 'down', 'Redis connection lost', {
          status: 'disconnected'
        }, this.alertRules.redis.severity);
      }

      const queueJobs = metrics.queue?.jobs || {};
      const pendingJobs = queueJobs.waiting || 0;
      const failedJobs = queueJobs.failed || 0;

      if (pendingJobs > 1000 || failedJobs > 100) {
        this.triggerAlert('queue', 'degraded', `Queue backlog: ${pendingJobs} waiting, ${failedJobs} failed`, {
          waiting: pendingJobs,
          failed: failedJobs,
          active: queueJobs.active || 0
        }, this.alertRules.queue.severity);
      }

      if (metrics.database?.operations?.failed > 10) {
        this.triggerAlert('database_errors', 'high', `Database operations failing: ${metrics.database.operations.failed}`, {
          failed: metrics.database.operations.failed,
          read: metrics.database.operations.read,
          write: metrics.database.operations.write
        }, 'error');
      }

      const totalRequests = metrics.requests?.total || 0;
      const failedRequests = metrics.requests?.failed || 0;
      const errorRate = totalRequests > 0 ? (failedRequests / totalRequests) * 100 : 0;

      if (errorRate > this.alertRules.errorRate.threshold && totalRequests > 100) {
        this.triggerAlert('error_rate', 'high', `Error rate critical: ${errorRate.toFixed(1)}%`, {
          errorRate: errorRate.toFixed(1),
          totalRequests,
          failedRequests
        }, this.alertRules.errorRate.severity);
      }

      const backupStats = BackupService.getBackupStats();
      if (backupStats.lastBackup) {
        const lastBackupTime = new Date(backupStats.lastBackup);
        const hoursSinceBackup = (Date.now() - lastBackupTime.getTime()) / (1000 * 60 * 60);

        if (hoursSinceBackup > 24) {
          this.triggerAlert('backup', 'stale', `Last backup was ${Math.floor(hoursSinceBackup)} hours ago`, {
            lastBackup: backupStats.lastBackup,
            hoursSinceBackup: Math.floor(hoursSinceBackup)
          }, this.alertRules.backup.severity);
        }
      }

      if (health.issues && health.issues.length > 0) {
        health.issues.forEach(issue => {
          this.triggerAlert('general', 'warning', issue, {}, 'warning');
        });
      }
    } catch (error) {
      Logger.error('Health check error', { error: error.message });
    }
  }

  canAlert(alertType) {
    const now = Date.now();
    const lastAlert = this.lastAlertTime[alertType];
    const cooldown = this.alertRules[alertType]?.cooldown || this.alertCooldownMs;

    if (!lastAlert || now - lastAlert > cooldown) {
      this.lastAlertTime[alertType] = now;
      return true;
    }

    return false;
  }

  triggerAlert(type, subtype, message, data, severity) {
    if (!this.canAlert(`${type}_${subtype}`)) return;

    const alert = {
      id: Date.now().toString(36) + Math.random().toString(36).substr(2),
      type,
      subtype,
      severity,
      message,
      data,
      timestamp: new Date().toISOString(),
      acknowledged: false
    };

    this.alertHistory.unshift(alert);
    if (this.alertHistory.length > this.maxHistory) {
      this.alertHistory.pop();
    }

    this.activeAlerts.push(alert);

    Logger.error('🚨 ALERT', alert);

    if (global.io) {
      global.io.to('admins').emit('health:alert', alert);
    }

    if (process.env.ALERT_EMAIL_ENABLED === 'true') {
      this.sendAlertNotification(alert);
    }

    if (process.env.ALERT_SLACK_WEBHOOK) {
      this.sendSlackAlert(alert);
    }

    if (severity === 'critical') {
      this.triggerEmergencyResponse(alert);
    }

    return alert;
  }

  async triggerEmergencyResponse(alert) {
    try {
      Logger.warn('Triggering emergency response for critical alert', { alert });

      if (alert.type === 'memory' || alert.type === 'cpu') {
        const scaleStats = AutoScalingService.getScalingStats();
        if (scaleStats.currentInstanceCount < scaleStats.maxInstances) {
          AutoScalingService.manualScale('up');
        }
      }

      if (alert.type === 'database') {
        if (BackupService.getBackupStats().lastBackup) {
          Logger.warn('Consider manual backup before any recovery action');
        }
      }
    } catch (error) {
      Logger.error('Emergency response failed', { error: error.message });
    }
  }

  async sendAlertNotification(alert) {
    try {
      const nodemailer = require('nodemailer');
      const transporter = nodemailer.createTransport({
        host: process.env.SMTP_HOST,
        port: parseInt(process.env.SMTP_PORT),
        secure: true,
        auth: {
          user: process.env.SMTP_USER,
          pass: process.env.SMTP_PASS
        }
      });

      const severityEmoji = {
        critical: '🔴',
        error: '🟠',
        warning: '🟡',
        info: '🔵'
      };

      await transporter.sendMail({
        from: process.env.ALERT_FROM_EMAIL,
        to: process.env.ALERT_TO_EMAIL,
        subject: `[${severityEmoji[alert.severity] || '⚪'}] ${alert.severity.toUpperCase()} Alert - Arvind Party`,
        html: `
          <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
            <h2 style="color: ${this.getSeverityColor(alert.severity)};">${severityEmoji[alert.severity] || '⚪'} ${alert.severity.toUpperCase()} Alert</h2>
            <div style="background: #f5f5f5; padding: 16px; border-radius: 8px; margin: 16px 0;">
              <p><strong>Type:</strong> ${alert.type}</p>
              <p><strong>Subtype:</strong> ${alert.subtype}</p>
              <p><strong>Message:</strong> ${alert.message}</p>
              <p><strong>Time:</strong> ${alert.timestamp}</p>
              ${Object.keys(alert.data).length > 0 ? '<p><strong>Details:</strong></p><pre>' + JSON.stringify(alert.data, null, 2) + '</pre>' : ''}
            </div>
            <p><small>Server: ${process.env.SERVER_ID || 'primary'}</small></p>
          </div>
        `
      });

      Logger.info('Alert email sent', { alertId: alert.id });
    } catch (error) {
      Logger.error('Failed to send alert email', { alertId: alert.id, error: error.message });
    }
  }

  async sendSlackAlert(alert) {
    try {
      const axios = require('axios');
      const severityEmoji = {
        critical: ':red_circle:',
        error: ':large_orange_circle:',
        warning: ':yellow_circle:',
        info: ':large_blue_circle:'
      };

      await axios.post(process.env.ALERT_SLACK_WEBHOOK, {
        text: `${severityEmoji[alert.severity] || ':white_circle:'} *${alert.severity.toUpperCase()} Alert*`,
        attachments: [{
          color: this.getSeverityColor(alert.severity),
          fields: [
            { title: 'Type', value: alert.type, short: true },
            { title: 'Subtype', value: alert.subtype, short: true },
            { title: 'Message', value: alert.message, short: false },
            { title: 'Time', value: alert.timestamp, short: true },
            { title: 'Server', value: process.env.SERVER_ID || 'primary', short: true }
          ]
        }]
      });

      Logger.info('Slack alert sent', { alertId: alert.id });
    } catch (error) {
      Logger.error('Failed to send Slack alert', { alertId: alert.id, error: error.message });
    }
  }

  getSeverityColor(severity) {
    const colors = {
      critical: '#FF0000',
      error: '#FF6B6B',
      warning: '#FFA500',
      info: '#4A90E2'
    };
    return colors[severity] || '#808080';
  }

  acknowledgeAlert(alertId) {
    const alert = this.activeAlerts.find(a => a.id === alertId);
    if (alert) {
      alert.acknowledged = true;
      alert.acknowledgedAt = new Date().toISOString();
      Logger.info('Alert acknowledged', { alertId });
      return true;
    }
    return false;
  }

  resolveAlert(alertId) {
    const index = this.activeAlerts.findIndex(a => a.id === alertId);
    if (index !== -1) {
      const alert = this.activeAlerts[index];
      alert.resolved = true;
      alert.resolvedAt = new Date().toISOString();
      this.activeAlerts.splice(index, 1);

      if (global.io) {
        global.io.to('admins').emit('health:alert_resolved', {
          alertId,
          timestamp: alert.resolvedAt
        });
      }

      Logger.info('Alert resolved', { alertId });
      return true;
    }
    return false;
  }

  resolveAllAlerts() {
    this.activeAlerts = [];
  }

  getActiveAlerts() {
    return {
      count: this.activeAlerts.length,
      alerts: this.activeAlerts.slice(0, 50)
    };
  }

  getAlertHistory(limit = 50) {
    return this.alertHistory.slice(0, limit);
  }

  getAlertStats() {
    const last24Hours = this.alertHistory.filter(
      a => Date.now() - new Date(a.timestamp).getTime() < 86400000
    );

    const bySeverity = last24Hours.reduce((acc, alert) => {
      acc[alert.severity] = (acc[alert.severity] || 0) + 1;
      return acc;
    }, {});

    const byType = last24Hours.reduce((acc, alert) => {
      acc[alert.type] = (acc[alert.type] || 0) + 1;
      return acc;
    }, {});

    return {
      enabled: this.isEnabled,
      last24Hours: last24Hours.length,
      activeAlerts: this.activeAlerts.length,
      bySeverity,
      byType
    };
  }

  initialize() {
    this.start();
  }

  getHealthStatus() {
    const activeCritical = this.activeAlerts.filter(a => a.severity === 'critical').length;
    const activeErrors = this.activeAlerts.filter(a => a.severity === 'error').length;

    let status = 'healthy';
    if (activeCritical > 0) status = 'critical';
    else if (activeErrors > 2) status = 'degraded';
    else if (this.activeAlerts.length > 0) status = 'warning';

    return {
      status,
      activeAlerts: this.activeAlerts.length,
      criticalAlerts: activeCritical,
      errorAlerts: activeErrors
    };
  }
}

module.exports = new HealthAlertService();

// ─── FROM: queueService.js ────────────────────────────────────────
const Queue = require('bullmq');
const Redis = require('redis');
const Logger = require('../../utils/logger');

class QueueService {
  constructor() {
    this.redisClient = null;
    this.queues = {};
    this.isConnected = false;
  }

  async connect() {
    try {
      this.redisClient = new Redis.RedisClient({
        socket: {
          host: process.env.REDIS_HOST || '127.0.0.1',
          port: parseInt(process.env.REDIS_PORT || '6379'),
          reconnectStrategy: (retries) => Math.min(retries * 50, 1000)
        },
        password: process.env.REDIS_PASSWORD || undefined,
        database: parseInt(process.env.REDIS_DB || '0')
      });

      this.redisClient.on('error', (err) => {
        console.error('❌ Queue Redis Error:', err.message);
        this.isConnected = false;
      });

      this.redisClient.on('connect', () => {
        console.log('🔄 Queue Redis Client Connected');
      });

      this.redisClient.on('ready', () => {
        console.log('✅ Queue Redis Client Ready');
        this.isConnected = true;
      });

      await this.redisClient.connect();
      this.isConnected = true;
      console.log('✅ Queue Service Connected');
      return true;
    } catch (error) {
      console.error('⚠️ Queue Service Connection Failed:', error.message);
      return false;
    }
  }

  getRedisClient() {
    return this.redisClient;
  }

  getQueueConnection() {
    return {
      host: process.env.REDIS_HOST || '127.0.0.1',
      port: parseInt(process.env.REDIS_PORT || '6379'),
      password: process.env.REDIS_PASSWORD || undefined,
      database: parseInt(process.env.REDIS_DB || '0')
    };
  }

  async createQueue(queueName, options = {}) {
    if (!this.isConnected) {
      throw new Error('Queue service not connected');
    }

    if (this.queues[queueName]) {
      return this.queues[queueName];
    }

    const defaultOptions = {
      connection: this.getQueueConnection(),
      defaultJobOptions: {
        removeOnComplete: { count: 1000, age: 24 * 3600 },
        removeOnFail: { count: 5000, age: 7 * 24 * 3600 },
        attempts: 3,
        backoff: {
          type: 'exponential',
          delay: 1000
        }
      }
    };

    const mergedOptions = { ...defaultOptions, ...options };

    try {
      const queue = new Queue(queueName, mergedOptions);
      this.queues[queueName] = queue;
      console.log(`✅ Queue created: ${queueName}`);
      return queue;
    } catch (error) {
      console.error(`❌ Failed to create queue ${queueName}:`, error);
      throw error;
    }
  }

  async addJob(queueName, jobName, data, options = {}) {
    try {
      const queue = await this.createQueue(queueName);
      const job = await queue.add(jobName, data, options);
      Logger.info(`Job added to ${queueName}: ${jobName}`, { jobId: job.id, data });
      return job;
    } catch (error) {
      console.error(`❌ Failed to add job to ${queueName}:`, error);
      throw error;
    }
  }

  async getQueueStats(queueName) {
    try {
      const queue = this.queues[queueName];
      if (!queue) {
        return null;
      }

      const [waiting, active, completed, failed, delayed] = await Promise.all([
        queue.getWaitingCount(),
        queue.getActiveCount(),
        queue.getCompletedCount(),
        queue.getFailedCount(),
        queue.getDelayedCount()
      ]);

      return {
        waiting,
        active,
        completed,
        failed,
        delayed,
        total: waiting + active + completed + failed + delayed
      };
    } catch (error) {
      console.error(`❌ Failed to get stats for ${queueName}:`, error);
      return null;
    }
  }

  async closeQueue(queueName) {
    try {
      if (this.queues[queueName]) {
        await this.queues[queueName].close();
        delete this.queues[queueName];
        console.log(`✅ Queue closed: ${queueName}`);
      }
    } catch (error) {
      console.error(`❌ Failed to close queue ${queueName}:`, error);
    }
  }

  async pauseQueue(queueName) {
    try {
      const queue = this.queues[queueName];
      if (queue) {
        await queue.pause();
        console.log(`⏸️ Queue paused: ${queueName}`);
      }
    } catch (error) {
      console.error(`❌ Failed to pause queue ${queueName}:`, error);
    }
  }

  async resumeQueue(queueName) {
    try {
      const queue = this.queues[queueName];
      if (queue) {
        await queue.resume();
        console.log(`▶️ Queue resumed: ${queueName}`);
      }
    } catch (error) {
      console.error(`❌ Failed to resume queue ${queueName}:`, error);
    }
  }

  async cleanQueue(queueName, jobsToKeep = 100) {
    try {
      const queue = this.queues[queueName];
      if (queue) {
        await queue.clean(0, jobsToKeep, 'completed');
        await queue.clean(0, jobsToKeep, 'failed');
        console.log(`🧹 Queue cleaned: ${queueName}`);
      }
    } catch (error) {
      console.error(`❌ Failed to clean queue ${queueName}:`, error);
    }
  }

  async disconnect() {
    try {
      for (const queueName in this.queues) {
        await this.closeQueue(queueName);
      }

      if (this.redisClient && this.isConnected) {
        await this.redisClient.quit();
        console.log('📴 Queue Service Disconnected');
      }
      this.isConnected = false;
    } catch (error) {
      console.error('❌ Error disconnecting queue service:', error);
    }
  }

  getConnectedQueues() {
    return Object.keys(this.queues);
  }

  async isHealthy() {
    try {
      if (!this.isConnected || !this.redisClient) {
        return false;
      }

      await this.redisClient.ping();
      return true;
    } catch (error) {
      return false;
    }
  }
}

module.exports = new QueueService();

// ─── FROM: schedulerService.js ────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════
// SERVICE: SchedulerService — Automated cycle scheduler for target audits
// Weekly, 15-Day, Monthly cycle creation and audit
// ═══════════════════════════════════════════════════════════════════════════

const TargetManager = require('../../models/TargetManager');
const User = require('../../models/User');
const AuditLog = require('../../models/AuditLog');
const WalletTransaction = require('../../models/WalletTransaction');

class SchedulerService {
  /**
   * Automatically audit all active targets and create new cycles
   * Called by cron job (can be set to run daily at midnight)
   */
  static async auditAllTargets() {
    console.log('🔄 [SchedulerService] Running target audit...');
    try {
      const activeTargets = await TargetManager.find({ isActive: true });
      let expiredCount = 0;
      let settledCount = 0;

      for (const target of activeTargets) {
        const now = new Date();
        const endDate = new Date(target.cycle.endDate);

        // If cycle has expired
        if (now > endDate) {
          // Auto-settle if target was met
          if (target.isTargetMet && !target.settlement.isSettled) {
            // Process any pending exchange requests
            for (let i = 0; i < target.diamondExchangeRequests.length; i++) {
              const req = target.diamondExchangeRequests[i];
              if (req.status === 'pending') {
                // Credit coins to streamer
                const streamer = await User.findById(target.streamerId);
                if (streamer) {
                  streamer.coins = (streamer.coins || 0) + req.coinAmount;
                  await streamer.save();

                  await WalletTransaction.create({
                    userId: streamer._id,
                    type: 'settlement',
                    amount: req.coinAmount,
                    description: `Auto-settlement: ${req.diamondAmount} diamonds → ${req.coinAmount} coins`,
                    status: 'completed',
                    metadata: { targetId: target._id.toString(), autoSettled: true },
                  });

                  req.status = 'approved';
                  req.processedAt = new Date();
                  req.processedBy = 'SYSTEM_SCHEDULER';
                }
              }
            }

            target.settlement.isSettled = true;
            target.settlement.settledAt = new Date();
            settledCount++;
          }

          target.isActive = false;
          expiredCount++;
          await target.save();
        }
      }

      console.log(`✅ [SchedulerService] Audit complete: ${expiredCount} expired, ${settledCount} auto-settled`);

      await AuditLog.create({
        action: 'SCHEDULER_AUDIT',
        performedBy: 'SYSTEM_SCHEDULER',
        details: `Target audit: ${expiredCount} expired, ${settledCount} auto-settled`,
      });
    } catch (error) {
      console.error('❌ [SchedulerService] Audit error:', error);
    }
  }

  /**
   * Auto-create new weekly/fifteen_day/monthly cycles for all active streamers
   * @param {string} cycleType - 'weekly' | 'fifteen_day' | 'monthly'
   * @param {number} defaultTargetDiamonds - Default target diamonds
   */
  static async autoCreateCyclesForAll(cycleType = 'weekly', defaultTargetDiamonds = 1000) {
    try {
      const streamers = await User.find({ role: 'streamer', isActive: true }).select('uid _id');
      const now = new Date();
      let startDate, endDate;

      switch (cycleType) {
        case 'weekly':
          startDate = new Date(now);
          endDate = new Date(now.getTime() + 7 * 24 * 60 * 60 * 1000);
          break;
        case 'fifteen_day':
          startDate = new Date(now);
          endDate = new Date(now.getTime() + 15 * 24 * 60 * 60 * 1000);
          break;
        case 'monthly':
          startDate = new Date(now);
          endDate = new Date(now.getFullYear(), now.getMonth() + 1, now.getDate());
          break;
        default:
          throw new Error(`Invalid cycle type: ${cycleType}`);
      }

      const targets = streamers.map((s) => ({
        streamerId: s._id,
        streamerUid: s.uid,
        cycle: { cycleType, startDate, endDate, targetDiamonds: defaultTargetDiamonds },
      }));

      if (targets.length > 0) {
        await TargetManager.insertMany(targets);
      }

      console.log(`✅ [SchedulerService] Created ${targets.length} ${cycleType} cycles`);
      return targets.length;
    } catch (error) {
      console.error('❌ [SchedulerService] Auto-create error:', error);
      return 0;
    }
  }

  /**
   * Start the scheduler with a given interval
   * @param {number} intervalMs - Interval in milliseconds (default: 24 hours)
   */
  static startScheduler(intervalMs = 24 * 60 * 60 * 1000) {
    console.log(`⏰ [SchedulerService] Started (interval: ${intervalMs / 1000 / 60 / 60}h)`);
    
    // Run immediately on start
    setTimeout(() => {
      SchedulerService.auditAllTargets();
    }, 5000); // 5 seconds after server start

    // Then run on interval
    setInterval(() => {
      SchedulerService.auditAllTargets();
    }, intervalMs);
  }
}

module.exports = SchedulerService;