// ============================================================
// ARVIND PARTY WEB — Role & Permission Constants
// ============================================================

/// All admin/staff roles in the system
enum AppRole {
  ownerWeb,
  ownerAssistantUid,
  appAdminWeb,
  adminUid,
  adminAssistantUid,
  csLeaderUid,
  csCustomerServiceUid,
  bdUid,
  superCoinSellerUid,
  normalCoinSellerUid,
  globalManagerWeb,
  globalManagerAssistantUid,
  countryManagerWeb,
  countryManagerAssistantUid;

  String get displayName {
    switch (this) {
      case AppRole.ownerWeb:
        return 'OWNER.WEB';
      case AppRole.ownerAssistantUid:
        return 'OWNER_ASSISTANT';
      case AppRole.appAdminWeb:
        return 'APP_ADMIN.WEB';
      case AppRole.adminUid:
        return 'ADMIN';
      case AppRole.adminAssistantUid:
        return 'ADMIN_ASSISTANT';
      case AppRole.csLeaderUid:
        return 'CS_LEADER';
      case AppRole.csCustomerServiceUid:
        return 'CS_CUSTOMER_SERVICE';
      case AppRole.bdUid:
        return 'BD';
      case AppRole.superCoinSellerUid:
        return 'SUPER_COIN_SELLER';
      case AppRole.normalCoinSellerUid:
        return 'NORMAL_COIN_SELLER';
      case AppRole.globalManagerWeb:
        return 'GLOBAL_MANAGER.WEB';
      case AppRole.globalManagerAssistantUid:
        return 'GLOBAL_MANAGER_ASSISTANT';
      case AppRole.countryManagerWeb:
        return 'COUNTRY_MANAGER.WEB';
      case AppRole.countryManagerAssistantUid:
        return 'COUNTRY_MANAGER_ASSISTANT';
    }
  }

  /// Returns the role from a storage-friendly string key
  static AppRole fromString(String value) {
    return AppRole.values.firstWhere(
      (e) => e.name == value,
      orElse: () => AppRole.appAdminWeb,
    );
  }

  /// Returns the storage-friendly string key
  String get storageKey => name;
}

/// Permission levels for each module
enum PermissionLevel {
  off,
  viewOnly,
  edit,
  fullControl;

  String get displayName {
    switch (this) {
      case PermissionLevel.off:
        return 'Off';
      case PermissionLevel.viewOnly:
        return 'View Only';
      case PermissionLevel.edit:
        return 'Edit';
      case PermissionLevel.fullControl:
        return 'Full Control';
    }
  }

  bool get isAllowed => this != PermissionLevel.off;
  bool get canEdit => this == PermissionLevel.edit || this == PermissionLevel.fullControl;
  bool get isFullControl => this == PermissionLevel.fullControl;

  static PermissionLevel fromString(String value) {
    return PermissionLevel.values.firstWhere(
      (e) => e.name == value,
      orElse: () => PermissionLevel.off,
    );
  }
}

/// System modules that can be permission-controlled
enum AppModule {
  dashboard,
  user,
  room,
  wallet,
  gift,
  family,
  agency,
  cp,
  vip,
  seller,
  event,
  analytics,
  notification,
  system;

  String get displayName {
    switch (this) {
      case AppModule.dashboard:
        return 'Dashboard';
      case AppModule.user:
        return 'User Management';
      case AppModule.room:
        return 'Room Management';
      case AppModule.wallet:
        return 'Wallet';
      case AppModule.gift:
        return 'Gift Management';
      case AppModule.family:
        return 'Family';
      case AppModule.agency:
        return 'Agency';
      case AppModule.cp:
        return 'CP';
      case AppModule.vip:
        return 'VIP / Rewards';
      case AppModule.seller:
        return 'Coin Seller';
      case AppModule.event:
        return 'Events';
      case AppModule.analytics:
        return 'Analytics';
      case AppModule.notification:
        return 'Notifications';
      case AppModule.system:
        return 'System Settings';
    }
  }

  static AppModule fromString(String value) {
    return AppModule.values.firstWhere(
      (e) => e.name == value,
      orElse: () => AppModule.dashboard,
    );
  }
}

/// Static permission checker utility
class AppPermissions {
  /// Returns true if the given permission level is >= the required minimum
  static bool hasPermission(PermissionLevel assigned, PermissionLevel required) {
    return assigned.index >= required.index;
  }

  /// Default permission levels for each role on each module
  static PermissionLevel defaultPermissionForRole(AppRole role, AppModule module) {
    // Owner gets full control on everything
    if (role == AppRole.ownerWeb) {
      return PermissionLevel.fullControl;
    }

    // Dashboard is view-only for non-owner roles by default
    if (module == AppModule.dashboard) {
      return PermissionLevel.viewOnly;
    }

    return PermissionLevel.off;
  }
}