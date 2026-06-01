import 'package:get/get.dart';
import '../models/user_model.dart';

class ProfileController extends GetxController {
  RxString userName = "Arvind".obs;
  RxString userId = "100001".obs;
  RxInt level = 1.obs;
  RxBool isVip = false.obs;
  RxInt followers = 0.obs;
  RxInt following = 0.obs;

  Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  @override
  void onInit() {
    super.onInit();
    loadCurrentUser();
  }

  void loadCurrentUser() {
    currentUser.value = UserModel(
      id: "100001",
      name: "Arvind",
      avatar: "",
      level: 1,
      isVip: false,
      followers: 0,
      following: 0,
    );

    userName.value = currentUser.value!.name;
    userId.value = currentUser.value!.id;
    level.value = currentUser.value!.level;
    isVip.value = currentUser.value!.isVip;
    followers.value = currentUser.value!.followers;
    following.value = currentUser.value!.following;
  }
}
