// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/routes/app_pages.dart
// ARVIND PARTY - MASTER ROUTE TABLE
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';

// Splash
import '../features/splash/presentation/views/splash_screen.dart';
import '../features/splash/presentation/bindings/splash_binding.dart';

// Auth
import '../features/auth/presentation/views/login_screen.dart';
import '../features/auth/presentation/views/signup_screen.dart';
import '../features/auth/presentation/views/phone_auth_screen.dart';
import '../features/auth/presentation/views/otp_screen.dart';
import '../features/auth/presentation/bindings/auth_binding.dart';

// Home
import '../features/home/presentation/views/home_screen.dart';
import '../features/home/presentation/bindings/home_binding.dart';

// Profile
import '../features/profile/presentation/views/profile_screen.dart';
import '../features/profile/presentation/views/complete_profile_screen.dart';
import '../features/profile/presentation/views/transaction_history_screen.dart';
import '../features/profile/presentation/views/user_profile_view.dart';
import '../features/profile/presentation/views/mission_screen.dart' as profile_mission;
import '../features/profile/presentation/bindings/profile_binding.dart';

// User Profile System
import '../features/user_profile/views/my_profile_screen.dart';
import '../features/user_profile/views/other_profile_screen.dart';
import '../features/user_profile/views/edit_profile_screen.dart';
import '../features/user_profile/models/user_profile_model.dart';
import '../features/user_profile/bindings/profile_binding.dart' as user_profile_binding;

// Wallet
import '../features/wallet/presentation/views/wallet_screen.dart';
import '../features/wallet/presentation/views/withdrawal_screen.dart';
import '../features/wallet/presentation/views/withdrawal_management_view.dart';
import '../features/wallet/presentation/bindings/wallet_binding.dart';

// Lucky Draw
import '../features/lucky_draw/presentation/views/lucky_draw_screen.dart';
import '../features/lucky_draw/presentation/bindings/lucky_draw_binding.dart';

// Events
import '../features/events/presentation/views/events_screen.dart';
import '../features/events/presentation/bindings/events_binding.dart';

// Search
import '../features/search/presentation/views/search_screen.dart' as search_screen;
import '../features/search/presentation/bindings/search_binding.dart';

// User Center
import '../features/wallet/presentation/views/user_center_screen.dart';

// VIP System
import '../features/vip_system/views/vip_screen.dart';
import '../features/vip_system/bindings/vip_binding.dart';

// Ranking
import '../features/ranking/presentation/views/game_leaderboard_screen.dart';
import '../features/ranking/presentation/bindings/ranking_binding.dart';

// Shop
import '../features/shop/presentation/views/shop_screen.dart';
import '../features/shop/presentation/bindings/shop_binding.dart';

// Room
import '../features/room/views/room_list_screen.dart';
import '../features/room/views/room_detail_screen.dart';
import '../features/room/bindings/room_binding.dart';

// Gift
import '../features/gift/presentation/views/gift_history_screen.dart';
import '../features/gift/presentation/views/gift_ranking_screen.dart';
import '../features/gift/views/gift_screen.dart';
import '../features/gift/presentation/bindings/gift_binding.dart';

// Chat
import '../features/chat/views/room_chat_screen.dart';

import '../features/chat/bindings/chat_binding.dart';

// Friend
import '../features/friend/views/friend_screen.dart';
import '../features/friend/views/friend_search_screen.dart';
import '../features/friend/bindings/friend_binding.dart';

// Block
import '../features/block/views/blacklist_screen.dart';
import '../features/block/bindings/block_binding.dart';

// Notification (merged - using the notification feature)
import '../features/notifications/presentation/views/notification_screen.dart';
import '../features/notifications/presentation/bindings/notifications_binding.dart';

// Family
import '../features/family/presentation/views/family_screen.dart';
import '../features/family/presentation/views/family_chat_screen.dart';
import '../features/family/presentation/views/family_members_screen.dart';
import '../features/family/presentation/views/family_events_screen.dart';
import '../features/family/presentation/views/family_ranking_screen.dart';
import '../features/family/presentation/views/family_settings_screen.dart';
import '../features/family/presentation/views/create_family_screen.dart';
import '../features/family/presentation/bindings/family_binding.dart';

// Coin Seller
import '../features/cp/presentation/views/coin_seller_home_screen.dart';
import '../features/cp/presentation/bindings/coin_seller_binding.dart';

// Agency
import '../features/agency/presentation/views/agency_home_screen.dart';
import '../features/agency/presentation/views/agency_members_screen.dart';
import '../features/agency/presentation/views/agency_events_screen.dart';
import '../features/agency/presentation/views/agency_analytics_screen.dart';
import '../features/agency/presentation/views/agency_salary_screen.dart';
import '../features/agency/presentation/views/agency_ranking_screen.dart';
import '../features/agency/presentation/views/agency_settings_screen.dart';
import '../features/agency/presentation/views/create_agency_screen.dart';
import '../features/agency/presentation/bindings/agency_binding.dart';

import 'app_routes.dart';

class AppPages {
  static final pages = [
    // ─── SPLASH ───────────────────────────────────────────
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      binding: SplashBinding(),
    ),

    // ─── AUTH ─────────────────────────────────────────────
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.signup,
      page: () => const SignupScreen(),
      binding: AuthBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.phoneAuth,
      page: () => const PhoneAuthScreen(),
      binding: AuthBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.otp,
      page: () => const OtpScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.completeProfile,
      page: () => CompleteProfileScreen(),
      binding: ProfileBinding(),
    ),

    // ─── HOME ─────────────────────────────────────────────
    GetPage(
      name: AppRoutes.home,
      page: () => HomeScreen(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.search,
      page: () => const search_screen.GlobalSearchScreen(),
      binding: SearchBinding(),
    ),
    GetPage(
      name: AppRoutes.vip,
      page: () => const VIPScreen(),
      binding: VIPBinding(),
    ),

    // ─── PROFILE ──────────────────────────────────────────
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileScreen(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.userProfile,
      page: () => const UserProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.dailyMissions,
      page: () => const profile_mission.MissionScreen(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.walletHistory,
      page: () => const TransactionHistoryScreen(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.myProfile,
      page: () => const MyProfileScreen(),
      binding: user_profile_binding.ProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.otherProfile,
      page: () => const OtherProfileScreen(userId: ''),
      binding: user_profile_binding.ProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.editProfile,
      page: () => EditProfileScreen(profile: UserProfile(userId: '', username: '', createdAt: DateTime.now())),
      binding: user_profile_binding.ProfileBinding(),
    ),

    // ─── WALLET ───────────────────────────────────────────
    GetPage(
      name: AppRoutes.wallet,
      page: () => const WalletScreen(),
      binding: WalletBinding(),
    ),
    GetPage(
      name: AppRoutes.withdrawal,
      page: () => const WithdrawalScreen(),
      binding: WalletBinding(),
    ),
    GetPage(
      name: AppRoutes.withdrawalManagement,
      page: () => const WithdrawalManagementView(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.shop,
      page: () => const ShopScreen(),
      binding: ShopBinding(),
    ),

    // ─── LUCKY DRAW ──────────────────────────────────────
    GetPage(
      name: AppRoutes.luckySpin,
      page: () => const LuckyDrawScreen(),
      binding: LuckyDrawBinding(),
    ),
    GetPage(
      name: AppRoutes.gameCenter,
      page: () => const GameLeaderboardScreen(),
      binding: RankingBinding(),
    ),

    // ─── EVENTS ──────────────────────────────────────────
    GetPage(
      name: AppRoutes.eventListing,
      page: () => const EventsScreen(),
      binding: EventsBinding(),
    ),

    // ─── NOTIFICATIONS ──────────────────────────────────
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationScreen(),
      binding: NotificationsBinding(),
    ),

    // ─── USER CENTER ─────────────────────────────────────
    GetPage(
      name: AppRoutes.userCenter,
      page: () => const UserCenterScreen(),
      binding: WalletBinding(),
    ),

    // ─── ROOM ──────────────────────────────────────────────
    GetPage(
      name: AppRoutes.roomList,
      page: () => RoomListScreen(),
      binding: RoomBinding(),
    ),
    GetPage(
      name: AppRoutes.roomDetail,
      page: () => const RoomDetailScreen(),
      binding: RoomBinding(),
    ),
    GetPage(
      name: AppRoutes.voiceRoom,
      page: () => RoomListScreen(),
      binding: RoomBinding(),
      transition: Transition.downToUp,
    ),
    GetPage(
      name: AppRoutes.giftStatistics,
      page: () => const GiftHistoryScreen(),
      binding: GiftBinding(),
    ),
    GetPage(
      name: AppRoutes.giftLeaderboard,
      page: () => const GiftRankingScreen(),
      binding: GiftBinding(),
    ),
    GetPage(
      name: AppRoutes.giftShop,
      page: () => const GiftScreen(),
      binding: GiftBinding(),
    ),

    // ─── CHAT ─────────────────────────────────────────────
    GetPage(
      name: AppRoutes.chat,
      page: () => const RoomChatScreen(roomId: 'room1', roomName: 'Chat'),
      binding: ChatBinding(),
    ),

    // ─── FRIEND ───────────────────────────────────────────
    GetPage(
      name: AppRoutes.friends,
      page: () => const FriendScreen(),
      binding: FriendBinding(),
    ),
    GetPage(
      name: AppRoutes.friendSearch,
      page: () => const FriendSearchScreen(),
      binding: FriendBinding(),
    ),

    // ─── BLOCK ────────────────────────────────────────────
    GetPage(
      name: AppRoutes.blacklist,
      page: () => const BlacklistScreen(),
      binding: BlockBinding(),
    ),

    // ─── FAMILY ───────────────────────────────────────────
    GetPage(
      name: AppRoutes.family,
      page: () => const FamilyScreen(),
      binding: FamilyBinding(),
    ),
    GetPage(
      name: AppRoutes.familyCreation,
      page: () => const CreateFamilyScreen(),
      binding: FamilyBinding(),
    ),
    GetPage(
      name: AppRoutes.familyChat,
      page: () => const FamilyChatScreen(),
      binding: FamilyBinding(),
    ),
    GetPage(
      name: AppRoutes.familyMembers,
      page: () => const FamilyMembersScreen(),
      binding: FamilyBinding(),
    ),
    GetPage(
      name: AppRoutes.familyTasks,
      page: () => const FamilyEventsScreen(),
      binding: FamilyBinding(),
    ),
    GetPage(
      name: AppRoutes.familyRankingPage,
      page: () => const FamilyRankingScreen(),
      binding: FamilyBinding(),
    ),
    GetPage(
      name: AppRoutes.familyWars,
      page: () => const FamilySettingsScreen(),
      binding: FamilyBinding(),
    ),

    // ─── COIN SELLER ─────────────────────────────────────
    GetPage(
      name: AppRoutes.coinSeller,
      page: () => const CoinSellerHomeScreen(),
      binding: CoinSellerBinding(),
    ),
    GetPage(
      name: AppRoutes.coinSellerProfile,
      page: () => const CoinSellerProfileScreen(),
      binding: CoinSellerBinding(),
    ),
    GetPage(
      name: AppRoutes.coinSellerRanking,
      page: () => const CoinSellerRankingScreen(),
      binding: CoinSellerBinding(),
    ),
    GetPage(
      name: AppRoutes.rechargeHistory,
      page: () => const RechargeHistoryScreen(),
      binding: CoinSellerBinding(),
    ),
    GetPage(
      name: AppRoutes.settlementHistory,
      page: () => const SettlementHistoryScreen(),
      binding: CoinSellerBinding(),
    ),

    // ─── AGENCY ───────────────────────────────────────────
    GetPage(
      name: AppRoutes.agency,
      page: () => const AgencyHomeScreen(),
      binding: AgencyBinding(),
    ),
    GetPage(
      name: AppRoutes.agencyCreation,
      page: () => const CreateAgencyScreen(),
      binding: AgencyBinding(),
    ),
    GetPage(
      name: AppRoutes.agencyHosts,
      page: () => const AgencyMembersScreen(),
      binding: AgencyBinding(),
    ),
    GetPage(
      name: AppRoutes.agencyEarnings,
      page: () => const AgencyAnalyticsScreen(),
      binding: AgencyBinding(),
    ),
    GetPage(
      name: AppRoutes.eventHistory,
      page: () => const AgencyEventsScreen(),
      binding: AgencyBinding(),
    ),
    GetPage(
      name: AppRoutes.agencyWallet,
      page: () => const AgencySalaryScreen(),
      binding: AgencyBinding(),
    ),
    GetPage(
      name: AppRoutes.agencyRanking,
      page: () => const AgencyRankingScreen(),
      binding: AgencyBinding(),
    ),
    GetPage(
      name: AppRoutes.agencyLeaderboard,
      page: () => const AgencySettingsScreen(),
      binding: AgencyBinding(),
    ),
  ];
}