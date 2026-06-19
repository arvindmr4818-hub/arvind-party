import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import '../constants/api_constants.dart';

// ============================================================
// ARVIND PARTY WEB — Centralized API Client (Full Admin API)
// ============================================================

class AdminApi {
  static AdminApi get to => AdminApi._();
  static final AdminApi _singleton = AdminApi._();
  factory AdminApi() => _singleton;
  AdminApi._();

  final _box = GetStorage();
  final _client = http.Client();
  static const Duration _timeout = Duration(seconds: 30);

  // ─── Headers ─────────────────────────────────────────────
  Map<String, String> get _headers {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (ApiConstants.adminKey.isNotEmpty) {
      headers['x-admin-key'] = ApiConstants.adminKey;
    }
    final token = _box.read<String>(ApiConstants.tokenStorageKey);
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  String get _apiUrl => ApiConstants.apiUrl;

  // ─── Generic HTTP Methods ────────────────────────────────
  Future<Map<String, dynamic>> _get(String endpoint,
      {Map<String, String>? queryParams}) async {
    var uri = Uri.parse('$_apiUrl$endpoint');
    if (queryParams != null && queryParams.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParams);
    }
    final response = await _client.get(uri, headers: _headers).timeout(_timeout);
    return _handleResponse(response);
  }

  Future<List<dynamic>> _getList(String endpoint,
      {Map<String, String>? queryParams}) async {
    var uri = Uri.parse('$_apiUrl$endpoint');
    if (queryParams != null && queryParams.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParams);
    }
    final response = await _client.get(uri, headers: _headers).timeout(_timeout);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return [];
      final decoded = jsonDecode(response.body);
      if (decoded is List) return decoded;
      if (decoded is Map && decoded['data'] is List) return decoded['data'] as List;
      if (decoded is Map) {
        // Check for common list wrappers
        for (final key in ['data', 'results', 'items', 'list', 'records']) {
          if (decoded[key] is List) return decoded[key] as List;
        }
      }
      return [];
    }
    throw _parseError(response);
  }

  Future<Map<String, dynamic>> _post(String endpoint,
      {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('$_apiUrl$endpoint');
    final response = await _client
        .post(uri,
            headers: _headers, body: body != null ? jsonEncode(body) : null)
        .timeout(_timeout);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> _put(String endpoint,
      {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('$_apiUrl$endpoint');
    final response = await _client
        .put(uri,
            headers: _headers, body: body != null ? jsonEncode(body) : null)
        .timeout(_timeout);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> _delete(String endpoint) async {
    final uri = Uri.parse('$_apiUrl$endpoint');
    final response =
        await _client.delete(uri, headers: _headers).timeout(_timeout);
    return _handleResponse(response);
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {'status': 'success'};
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw _parseError(response);
  }

  ApiException _parseError(http.Response response) {
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return ApiException(
        statusCode: response.statusCode,
        message: body['message']?.toString() ?? 'Unknown error',
        data: body,
      );
    } catch (_) {
      return ApiException(
        statusCode: response.statusCode,
        message: 'HTTP ${response.statusCode}: ${response.reasonPhrase}',
      );
    }
  }

  // ═══════════════════════════════════════════════════════════
  // AUTH
  // ═══════════════════════════════════════════════════════════
  Future<Map<String, dynamic>> staffLogin(
      String loginId, String password) async {
    return _post(ApiConstants.staffLogin, body: {
      'login_id': loginId,
      'password': password,
    });
  }

  Future<Map<String, dynamic>> firebaseLogin(String idToken) async {
    return _post(ApiConstants.firebaseLogin, body: {
      'id_token': idToken,
    });
  }

  Future<Map<String, dynamic>> adminAuthLogin(
      String email, String password) async {
    return _post(ApiConstants.adminAuthLogin, body: {
      'email': email,
      'password': password,
    });
  }

  Future<Map<String, dynamic>> adminAuthRefresh(String refreshToken) async {
    return _post(ApiConstants.adminAuthRefresh, body: {
      'refresh_token': refreshToken,
    });
  }

  Future<Map<String, dynamic>> adminAuthLogout() async {
    return _post(ApiConstants.adminAuthLogout);
  }

  // ═══════════════════════════════════════════════════════════
  // DASHBOARD
  // ═══════════════════════════════════════════════════════════
  Future<Map<String, dynamic>> getDashboardStats() async {
    return _get(ApiConstants.adminStats);
  }

  Future<Map<String, dynamic>> getDashboardActivity() async {
    return _get(ApiConstants.dashboardActivity);
  }

  Future<Map<String, dynamic>> getLiveRooms() async {
    return _get(ApiConstants.liveRooms);
  }

  // ═══════════════════════════════════════════════════════════
  // USER MANAGEMENT
  // ═══════════════════════════════════════════════════════════
  Future<Map<String, dynamic>> getUsers(
      {int page = 1, int limit = 20, String? search}) async {
    final params = <String, String>{
      'page': page.toString(),
      'limit': limit.toString()
    };
    if (search != null && search.isNotEmpty) params['search'] = search;
    return _get(ApiConstants.users, queryParams: params);
  }

  Future<Map<String, dynamic>> getUserDetail(String userId) async {
    return _get('${ApiConstants.userDetail}/$userId');
  }

  Future<Map<String, dynamic>> blockUser(String userId) async {
    return _post('${ApiConstants.userBlock}/$userId');
  }

  Future<Map<String, dynamic>> unblockUser(String userId) async {
    return _post('${ApiConstants.userUnblock}/$userId');
  }

  Future<Map<String, dynamic>> verifyUser(String userId) async {
    return _put('${ApiConstants.userVerify}/$userId');
  }

  Future<Map<String, dynamic>> adjustUserCoins(
      String userId, int amount, String reason) async {
    return _post('${ApiConstants.userAdjustCoins}/$userId', body: {
      'amount': amount,
      'reason': reason,
    });
  }

  Future<Map<String, dynamic>> updateUserBalance(
      String userId,
      {required int coins, required int diamonds}) async {
    return _post('${ApiConstants.userBalance}/$userId', body: {
      'coins': coins,
      'diamonds': diamonds,
    });
  }

  // ═══════════════════════════════════════════════════════════
  // ROOM MANAGEMENT
  // ═══════════════════════════════════════════════════════════
  Future<List<dynamic>> getRooms({Map<String, String>? params}) async {
    return _getList(ApiConstants.rooms, queryParams: params);
  }

  Future<Map<String, dynamic>> getRoomDetail(String roomId) async {
    return _get('${ApiConstants.rooms}/$roomId');
  }

  Future<Map<String, dynamic>> closeRoom(String roomId) async {
    return _post('${ApiConstants.roomClose}/$roomId');
  }

  Future<Map<String, dynamic>> banRoom(String roomId) async {
    return _post('${ApiConstants.roomBan}/$roomId');
  }

  Future<Map<String, dynamic>> deleteRoom(String roomId) async {
    return _delete('${ApiConstants.rooms}/$roomId');
  }

  // ═══════════════════════════════════════════════════════════
  // GIFT MANAGEMENT
  // ═══════════════════════════════════════════════════════════
  Future<List<dynamic>> getGifts() async {
    return _getList(ApiConstants.gifts);
  }

  Future<Map<String, dynamic>> addGift(Map<String, dynamic> giftData) async {
    return _post(ApiConstants.gifts, body: giftData);
  }

  Future<Map<String, dynamic>> updateGift(
      String giftId, Map<String, dynamic> giftData) async {
    return _put('${ApiConstants.gifts}/$giftId', body: giftData);
  }

  Future<Map<String, dynamic>> deleteGift(String giftId) async {
    return _delete('${ApiConstants.gifts}/$giftId');
  }

  // ═══════════════════════════════════════════════════════════
  // WALLET MANAGEMENT
  // ═══════════════════════════════════════════════════════════
  Future<List<dynamic>> getWallets({Map<String, String>? params}) async {
    return _getList(ApiConstants.wallets, queryParams: params);
  }

  Future<Map<String, dynamic>> getWalletDetail(String userId) async {
    return _get('${ApiConstants.wallets}/$userId');
  }

  Future<Map<String, dynamic>> adjustWallet(
      String userId, int amount, String reason) async {
    return _post('${ApiConstants.walletAdjust}/$userId', body: {
      'amount': amount,
      'reason': reason,
    });
  }

  // ═══════════════════════════════════════════════════════════
  // WITHDRAWALS
  // ═══════════════════════════════════════════════════════════
  Future<List<dynamic>> getWithdrawals({Map<String, String>? params}) async {
    return _getList(ApiConstants.pendingWithdrawals, queryParams: params);
  }

  Future<Map<String, dynamic>> approveWithdrawal(String withdrawalId) async {
    return _post('${ApiConstants.withdrawalApprove}/$withdrawalId');
  }

  Future<Map<String, dynamic>> rejectWithdrawal(
      String withdrawalId, String reason) async {
    return _post('${ApiConstants.withdrawalReject}/$withdrawalId', body: {
      'reason': reason,
    });
  }

  Future<Map<String, dynamic>> processWithdrawal(
      String withdrawalId, String action) async {
    return _post('${ApiConstants.processWithdrawal}/$withdrawalId', body: {
      'action': action,
    });
  }

  // ═══════════════════════════════════════════════════════════
  // RECHARGE HISTORY
  // ═══════════════════════════════════════════════════════════
  Future<List<dynamic>> getRecharges({Map<String, String>? params}) async {
    return _getList(ApiConstants.recharges, queryParams: params);
  }

  // ═══════════════════════════════════════════════════════════
  // STAFF / ADMIN MANAGEMENT
  // ═══════════════════════════════════════════════════════════
  Future<List<dynamic>> getStaffList() async {
    return _getList(ApiConstants.staffList);
  }

  Future<Map<String, dynamic>> createStaff(
      Map<String, dynamic> staffData) async {
    return _post(ApiConstants.staffCreate, body: staffData);
  }

  Future<Map<String, dynamic>> updateStaff(
      String staffId, Map<String, dynamic> staffData) async {
    return _put('${ApiConstants.staffUpdate}/$staffId', body: staffData);
  }

  Future<Map<String, dynamic>> deleteStaff(String staffId) async {
    return _delete('${ApiConstants.staffDelete}/$staffId');
  }

  Future<Map<String, dynamic>> searchUser(String uid) async {
    return _post(ApiConstants.staffSearchUser, body: {'uid': uid});
  }

  Future<List<dynamic>> getAdminRoles() async {
    return _getList(ApiConstants.adminRoles);
  }

  Future<Map<String, dynamic>> createAdminRole(
      Map<String, dynamic> roleData) async {
    return _post(ApiConstants.adminRoleCreate, body: roleData);
  }

  Future<Map<String, dynamic>> updateAdminRole(
      String roleId, Map<String, dynamic> roleData) async {
    return _put('${ApiConstants.adminRoleUpdate}/$roleId', body: roleData);
  }

  // ═══════════════════════════════════════════════════════════
  // VIP MANAGEMENT
  // ═══════════════════════════════════════════════════════════
  Future<List<dynamic>> getVipPlans() async {
    return _getList(ApiConstants.vipPlans);
  }

  Future<Map<String, dynamic>> createVipPlan(
      Map<String, dynamic> planData) async {
    return _post(ApiConstants.vipPlanCreate, body: planData);
  }

  Future<Map<String, dynamic>> updateVipPlan(
      String planId, Map<String, dynamic> planData) async {
    return _put('${ApiConstants.vipPlanUpdate}/$planId', body: planData);
  }

  // ═══════════════════════════════════════════════════════════
  // AGENCY MANAGEMENT
  // ═══════════════════════════════════════════════════════════
  Future<List<dynamic>> getAgencies({Map<String, String>? params}) async {
    return _getList(ApiConstants.agencies, queryParams: params);
  }

  Future<Map<String, dynamic>> approveAgency(String agencyId) async {
    return _post('${ApiConstants.agencyApprove}/$agencyId');
  }

  Future<Map<String, dynamic>> revokeAgency(String agencyId) async {
    return _post('${ApiConstants.agencyRevoke}/$agencyId');
  }

  // ═══════════════════════════════════════════════════════════
  // FAMILY MANAGEMENT
  // ═══════════════════════════════════════════════════════════
  Future<List<dynamic>> getFamilies({Map<String, String>? params}) async {
    return _getList(ApiConstants.families, queryParams: params);
  }

  Future<Map<String, dynamic>> deleteFamily(String familyId) async {
    return _delete('${ApiConstants.families}/$familyId');
  }

  // ═══════════════════════════════════════════════════════════
  // REPORTS
  // ═══════════════════════════════════════════════════════════
  Future<List<dynamic>> getReports({Map<String, String>? params}) async {
    return _getList(ApiConstants.reports, queryParams: params);
  }

  Future<Map<String, dynamic>> resolveReport(String reportId) async {
    return _post('${ApiConstants.reportResolve}/$reportId');
  }

  Future<Map<String, dynamic>> deleteReport(String reportId) async {
    return _delete('${ApiConstants.reports}/$reportId');
  }

  // ═══════════════════════════════════════════════════════════
  // BANS
  // ═══════════════════════════════════════════════════════════
  Future<List<dynamic>> getBans({Map<String, String>? params}) async {
    return _getList(ApiConstants.bans, queryParams: params);
  }

  Future<Map<String, dynamic>> createBan(Map<String, dynamic> banData) async {
    return _post(ApiConstants.bans, body: banData);
  }

  Future<Map<String, dynamic>> liftBan(String banId) async {
    return _delete('${ApiConstants.bans}/$banId');
  }

  // ═══════════════════════════════════════════════════════════
  // NOTIFICATIONS
  // ═══════════════════════════════════════════════════════════
  Future<Map<String, dynamic>> sendNotification(
      Map<String, dynamic> notificationData) async {
    return _post(ApiConstants.notificationSend, body: notificationData);
  }

  Future<List<dynamic>> getNotificationHistory(
      {Map<String, String>? params}) async {
    return _getList(ApiConstants.notificationHistory, queryParams: params);
  }

  // ═══════════════════════════════════════════════════════════
  // ANNOUNCEMENTS
  // ═══════════════════════════════════════════════════════════
  Future<Map<String, dynamic>> sendAnnouncement({
    required String title,
    required String message,
    String? targetAudience,
  }) async {
    final body = <String, dynamic>{
      'title': title,
      'message': message,
    };
    if (targetAudience != null) body['target_audience'] = targetAudience;
    return _post(ApiConstants.announcement, body: body);
  }

  Future<List<dynamic>> getAnnouncements() async {
    return _getList(ApiConstants.announcements);
  }

  // ═══════════════════════════════════════════════════════════
  // AUDIT LOGS
  // ═══════════════════════════════════════════════════════════
  Future<List<dynamic>> getAuditLogs({Map<String, String>? params}) async {
    return _getList(ApiConstants.auditLogs, queryParams: params);
  }

  // ═══════════════════════════════════════════════════════════
  // EVENTS
  // ═══════════════════════════════════════════════════════════
  Future<List<dynamic>> getEvents({Map<String, String>? params}) async {
    return _getList(ApiConstants.events, queryParams: params);
  }

  Future<Map<String, dynamic>> createEvent(
      Map<String, dynamic> eventData) async {
    return _post(ApiConstants.events, body: eventData);
  }

  Future<Map<String, dynamic>> updateEvent(
      String eventId, Map<String, dynamic> eventData) async {
    return _put('${ApiConstants.events}/$eventId', body: eventData);
  }

  Future<Map<String, dynamic>> deleteEvent(String eventId) async {
    return _delete('${ApiConstants.events}/$eventId');
  }

  // ═══════════════════════════════════════════════════════════
  // LEADERBOARD
  // ═══════════════════════════════════════════════════════════
  Future<List<dynamic>> getLeaderboard({Map<String, String>? params}) async {
    return _getList(ApiConstants.leaderboard, queryParams: params);
  }

  Future<Map<String, dynamic>> resetLeaderboard() async {
    return _post(ApiConstants.leaderboardReset);
  }

  // ═══════════════════════════════════════════════════════════
  // SUPPORT TICKETS
  // ═══════════════════════════════════════════════════════════
  Future<List<dynamic>> getSupportTickets(
      {Map<String, String>? params}) async {
    return _getList(ApiConstants.supportTickets, queryParams: params);
  }

  Future<Map<String, dynamic>> replyToTicket(
      String ticketId, String message) async {
    return _post('${ApiConstants.supportTicketReply}/$ticketId', body: {
      'message': message,
    });
  }

  // ═══════════════════════════════════════════════════════════
  // SECURITY
  // ═══════════════════════════════════════════════════════════
  Future<List<dynamic>> getSecurityLogins({Map<String, String>? params}) async {
    return _getList(ApiConstants.securityLogins, queryParams: params);
  }

  Future<Map<String, dynamic>> blockIp(String ipAddress, String reason) async {
    return _post(ApiConstants.securityBlockIp, body: {
      'ip': ipAddress,
      'reason': reason,
    });
  }

  // ═══════════════════════════════════════════════════════════
  // COINS & REWARDS
  // ═══════════════════════════════════════════════════════════
  Future<Map<String, dynamic>> generateCoins(
      String uid, int amount, String reason) async {
    return _post(ApiConstants.coinGenerate, body: {
      'uid': uid,
      'amount': amount,
      'reason': reason,
    });
  }

  Future<Map<String, dynamic>> deductCoins(
      String uid, int amount, String reason) async {
    return _post(ApiConstants.coinDeduct, body: {
      'uid': uid,
      'amount': amount,
      'reason': reason,
    });
  }

  Future<Map<String, dynamic>> sendReward({
    required String uid,
    required String rewardType,
    String? itemId,
    int? quantity,
  }) async {
    final body = <String, dynamic>{
      'uid': uid,
      'reward_type': rewardType,
    };
    if (itemId != null) body['item_id'] = itemId;
    if (quantity != null) body['quantity'] = quantity;
    return _post(ApiConstants.rewardSend, body: body);
  }

  // ═══════════════════════════════════════════════════════════
  // SETTINGS
  // ═══════════════════════════════════════════════════════════
  Future<Map<String, dynamic>> getSettings() async {
    return _get(ApiConstants.settings);
  }

  Future<Map<String, dynamic>> updateSettings(
      Map<String, dynamic> settingsData) async {
    return _put(ApiConstants.settings, body: settingsData);
  }

  // ═══════════════════════════════════════════════════════════
  // COIN ORDERS
  // ═══════════════════════════════════════════════════════════
  Future<List<dynamic>> getCoinOrders({Map<String, String>? params}) async {
    return _getList(ApiConstants.coinOrders, queryParams: params);
  }
}

// ─── API Exception ─────────────────────────────────────────
class ApiException implements Exception {
  final int statusCode;
  final String message;
  final Map<String, dynamic>? data;

  ApiException({
    required this.statusCode,
    required this.message,
    this.data,
  });

  @override
  String toString() => 'ApiException($statusCode): $message';
}