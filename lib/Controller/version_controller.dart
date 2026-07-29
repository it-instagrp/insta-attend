import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:insta_attend/API/Repository/version_repository.dart';
import 'package:insta_attend/Model/version.dart';
import 'package:insta_attend/Utils/toast_messages.dart';

class VersionController extends GetxController {
  final VersionRepository versionRepo;
  VersionController({required this.versionRepo});

  // Reactive State Variables
  RxBool isVersionLoading = false.obs;
  RxList<Version> versionList = <Version>[].obs;

  @override
  void onInit() {
    super.onInit();
    getVersionList();
  }

  /// Fetch application release version history
  Future<void> getVersionList() async {
    try {
      isVersionLoading.value = true;
      Response response = await versionRepo.getVersionList();

      if (response.statusCode == 200 && response.body?['data'] != null) {
        List<dynamic> dataList = response.body['data'] as List<dynamic>;

        List<Version> list =
        dataList.map((json) => Version.fromJson(json)).toList();

        // Sort by createdAt descending (latest first)
        list.sort((a, b) {
          DateTime dateA = DateTime.tryParse(a.createdAt ?? '') ?? DateTime(0);
          DateTime dateB = DateTime.tryParse(b.createdAt ?? '') ?? DateTime(0);
          return dateB.compareTo(dateA);
        });

        versionList.assignAll(list);
      } else {
        showError(response.body?['message'] ?? "Failed to fetch version list");
      }
    } catch (err) {
      showError("Something went wrong");
      debugPrint("Exception in getVersionList: $err");
    } finally {
      isVersionLoading.value = false;
    }
  }
}