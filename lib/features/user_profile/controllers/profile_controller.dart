import "package:get/get.dart";
import "package:get_storage/get_storage.dart";
import "../models/user_profile_model.dart";
import "../repositories/profile_repository.dart";

class ProfileController extends GetxController {
  final profileRepository = ProfileRepository();
  final storage = GetStorage();

  var myProfile = Rxn<UserProfile>();
  var isLoading = false.obs;
  var errorMessage = "".obs;
  var profileStats = Rxn<ProfileStats>();

  @override
  void onInit() {
    super.onInit();
    fetchMyProfile();
  }

  void fetchMyProfile() async {
    isLoading.value = true;
    errorMessage.value = "";

    try {
      final profile = await profileRepository.getMyProfile();
      myProfile.value = profile;
      await storage.write("userProfile", profile.toJson());
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void updateProfile({
    String? nickname,
    String? bio,
    String? gender,
    String? country,
    String? language,
    DateTime? birthday,
    String? website,
    List<String>? interests,
    bool? isPrivate,
  }) async {
    isLoading.value = true;
    errorMessage.value = "";

    try {
      final updatedProfile = await profileRepository.updateProfile(
        nickname: nickname,
        bio: bio,
        gender: gender,
        country: country,
        language: language,
        birthday: birthday,
        website: website,
        interests: interests,
        isPrivate: isPrivate,
      );

      myProfile.value = updatedProfile;
      await storage.write("userProfile", updatedProfile.toJson());
      Get.snackbar("Success", "Profile updated");
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void uploadAvatar(String filePath) async {
    isLoading.value = true;

    try {
      final avatarUrl = await profileRepository.uploadAvatar(filePath);
      if (myProfile.value != null) {
        myProfile.value = UserProfile(
          userId: myProfile.value!.userId,
          username: myProfile.value!.username,
          avatar: avatarUrl,
          createdAt: myProfile.value!.createdAt,
          nickname: myProfile.value!.nickname,
          bio: myProfile.value!.bio,
          coverImage: myProfile.value!.coverImage,
          gender: myProfile.value!.gender,
          country: myProfile.value!.country,
          language: myProfile.value!.language,
          birthday: myProfile.value!.birthday,
          isVerified: myProfile.value!.isVerified,
          vipTier: myProfile.value!.vipTier,
        );
      }
      Get.snackbar("Success", "Avatar uploaded");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void uploadCoverImage(String filePath) async {
    isLoading.value = true;

    try {
      final coverUrl = await profileRepository.uploadCoverImage(filePath);
      if (myProfile.value != null) {
        myProfile.value = UserProfile(
          userId: myProfile.value!.userId,
          username: myProfile.value!.username,
          coverImage: coverUrl,
          createdAt: myProfile.value!.createdAt,
          nickname: myProfile.value!.nickname,
          avatar: myProfile.value!.avatar,
          bio: myProfile.value!.bio,
          gender: myProfile.value!.gender,
          country: myProfile.value!.country,
          language: myProfile.value!.language,
          birthday: myProfile.value!.birthday,
          isVerified: myProfile.value!.isVerified,
          vipTier: myProfile.value!.vipTier,
        );
      }
      Get.snackbar("Success", "Cover image uploaded");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void setPrivacy(bool isPrivate) async {
    try {
      await profileRepository.setPrivacyStatus(isPrivate);
      if (myProfile.value != null) {
        myProfile.value = UserProfile(
          userId: myProfile.value!.userId,
          username: myProfile.value!.username,
          isPrivate: isPrivate,
          createdAt: myProfile.value!.createdAt,
          nickname: myProfile.value!.nickname,
          avatar: myProfile.value!.avatar,
          bio: myProfile.value!.bio,
          coverImage: myProfile.value!.coverImage,
          gender: myProfile.value!.gender,
          country: myProfile.value!.country,
          language: myProfile.value!.language,
          birthday: myProfile.value!.birthday,
          isVerified: myProfile.value!.isVerified,
          vipTier: myProfile.value!.vipTier,
        );
      }
      Get.snackbar("Success", isPrivate ? "Profile is now private" : "Profile is now public");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }
}

class OtherUserController extends GetxController {
  final profileRepository = ProfileRepository();

  var userProfile = Rxn<UserProfile>();
  var userStats = Rxn<ProfileStats>();
  var followers = <UserProfile>[].obs;
  var following = <UserProfile>[].obs;
  var isLoading = false.obs;
  var isFollowing = false.obs;

  void fetchUserProfile(String userId) async {
    isLoading.value = true;

    try {
      final profile = await profileRepository.getUserProfile(userId);
      userProfile.value = profile;
      isFollowing.value = profile.isFollowedByMe;

      final stats = await profileRepository.getProfileStats(userId);
      userStats.value = stats;
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
    finally {
      isLoading.value = false;
    }
  }

  void followUser(String userId) async {
    try {
      await profileRepository.followUser(userId);
      isFollowing.value = true;
      if (userProfile.value != null) {
        userProfile.value = UserProfile(
          userId: userProfile.value!.userId,
          username: userProfile.value!.username,
          followersCount: userProfile.value!.followersCount + 1,
          createdAt: userProfile.value!.createdAt,
          nickname: userProfile.value!.nickname,
          avatar: userProfile.value!.avatar,
          bio: userProfile.value!.bio,
          coverImage: userProfile.value!.coverImage,
          gender: userProfile.value!.gender,
          country: userProfile.value!.country,
          language: userProfile.value!.language,
          birthday: userProfile.value!.birthday,
          isVerified: userProfile.value!.isVerified,
          vipTier: userProfile.value!.vipTier,
        );
      }
      Get.snackbar("Success", "User followed");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  void unfollowUser(String userId) async {
    try {
      await profileRepository.unfollowUser(userId);
      isFollowing.value = false;
      Get.snackbar("Success", "User unfollowed");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  void blockUser(String userId) async {
    try {
      await profileRepository.blockUser(userId);
      Get.snackbar("Success", "User blocked");
      Get.back();
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  void fetchFollowers(String userId) async {
    try {
      final followersList = await profileRepository.getFollowers(userId);
      followers.value = followersList;
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  void fetchFollowing(String userId) async {
    try {
      final followingList = await profileRepository.getFollowing(userId);
      following.value = followingList;
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }
}
