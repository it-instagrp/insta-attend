import 'package:get/get.dart';
import 'package:insta_attend/API/Repository/version_repository.dart';
import 'package:insta_attend/Model/version.dart';

import '../Utils/toast_messages.dart';

class VersionController extends GetxController{
  final VersionRepository versionRepo;
  VersionController({required this.versionRepo});

  RxBool isLoading = false.obs;
  RxList<Version> versionList = <Version>[].obs;

  onInit() {
    super.onInit();
    getVersionList();
  }

  Future<void> getVersionList() async {
    try {
      isLoading.value = true;
      Response response = await versionRepo.getVersionList();

      if (response.statusCode == 200) {
        List<dynamic> dataList = response.body['data'] as List<dynamic>;

        List<Version> list = dataList
            .map((json) => Version.fromJson(json))
            .toList();

        // Sort by createdAt descending
        list.sort((a, b) {
          DateTime dateA = DateTime.tryParse(a.createdAt ?? '') ?? DateTime(0);
          DateTime dateB = DateTime.tryParse(b.createdAt ?? '') ?? DateTime(0);
          return dateB.compareTo(dateA); // Latest first
        });

        versionList.assignAll(list);
      } else {
        showError(Get.context!, response.body['message']);
      }
    } catch (err) {
      showError(Get.context!, "Something went wrong");
      print("Exception: $err");
    } finally {
      isLoading.value = false;
    }
  }
}