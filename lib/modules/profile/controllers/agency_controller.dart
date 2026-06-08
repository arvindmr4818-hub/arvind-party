import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/api_client.dart';

class AgencyController extends GetxController {
  final agencyNameController = TextEditingController();
  final ownerUidController = TextEditingController();

  var isLoading = false.obs;
  var isLoadingHosts = false.obs;
  var agencies = <Map<String, dynamic>>[].obs;
  var agencyHosts = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchAgencies();
  }

  Future<void> fetchAgencies() async {
    isLoading.value = true;
    try {
      final data = await ApiClient().get('/agencies');
      if (data is List) {
        final list = <Map<String, dynamic>>[];
        final dataList = data as List<dynamic>;
        for (final e in dataList) {
          list.add(Map<String, dynamic>.from(e));
        }
        agencies.assignAll(list);
      } else if (data is Map && data['success'] == true) {
        final list = <Map<String, dynamic>>[];
        if (data['data'] is List) {
          for (final e in data['data'] as List) {
            list.add(Map<String, dynamic>.from(e));
          }
        }
        agencies.assignAll(list);
      }
    } catch (e) {
      debugPrint('Error fetching agencies: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createAgency() async {
    final name = agencyNameController.text.trim();
    final ownerUid = ownerUidController.text.trim();
    if (name.isEmpty || ownerUid.isEmpty) {
      Get.snackbar('Error', 'Please fill all fields');
      return;
    }
    isLoading.value = true;
    try {
      final data = await ApiClient().post('/agencies/create', {
        'name': name,
        'ownerUid': ownerUid,
      });
      if (data is Map && data['success'] == true) {
        Get.snackbar('Success', 'Agency created successfully!');
        agencyNameController.clear();
        ownerUidController.clear();
        fetchAgencies();
      } else {
        Get.snackbar('Error', data['message'] ?? 'Failed to create agency');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to create agency');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAgencyHosts(String agencyId) async {
    isLoadingHosts.value = true;
    try {
      final data = await ApiClient().get('/agencies/$agencyId/hosts');
      if (data is Map && data['success'] == true) {
        final list = <Map<String, dynamic>>[];
        if (data['data'] is List) {
          for (final e in data['data'] as List) {
            list.add(Map<String, dynamic>.from(e));
          }
        }
        agencyHosts.assignAll(list);
      } else if (data is List) {
        final list = <Map<String, dynamic>>[];
        final dataList = data as List<dynamic>;
        for (final e in dataList) {
          list.add(Map<String, dynamic>.from(e));
        }
        agencyHosts.assignAll(list);
      }
    } catch (e) {
      debugPrint('Error fetching hosts: $e');
    } finally {
      isLoadingHosts.value = false;
    }
  }

  Future<void> disableAgency(String agencyId, String name) async {
    try {
      final data = await ApiClient().post('/agencies/disable', {
        'agencyId': agencyId,
      });
      if (data is Map && data['success'] == true) {
        Get.snackbar('Disabled', '$name has been disabled.');
        fetchAgencies();
      } else {
        Get.snackbar('Error', data['message'] ?? 'Failed to disable');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to disable agency');
    }
  }

  Future<void> deleteAgency(String agencyId, String name) async {
    try {
      final data = await ApiClient().post('/agencies/delete', {
        'agencyId': agencyId,
      });
      if (data is Map && data['success'] == true) {
        Get.snackbar('Deleted', '$name has been permanently deleted.',
            backgroundColor: Colors.redAccent, colorText: Colors.white);
        fetchAgencies();
      } else {
        Get.snackbar('Error', data['message'] ?? 'Failed to delete');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete agency');
    }
  }

  @override
  void onClose() {
    agencyNameController.dispose();
    ownerUidController.dispose();
    super.onClose();
  }
}