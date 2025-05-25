import 'package:get/get.dart';
import 'package:insta_attend/API/Repository/asset_repository.dart';
import 'package:insta_attend/Model/asset.dart';
import 'package:insta_attend/Utils/toast_messages.dart';

class AssetController extends GetxController {
  final AssetRepository assetRepo;
  AssetController({required this.assetRepo});

  RxBool isLoading = false.obs;
  RxList<Asset> assets = <Asset>[].obs;

  onInit() {
    super.onInit();
    getMyAssets();
  }

  Future<void> getMyAssets() async {
    try {
      Response response = await assetRepo.getMyAssets();
      if (response.statusCode == 200) {
        List<dynamic> dataList = response.body['data'] as List<dynamic>;
        List<Asset> list = dataList.map((json) => Asset.fromJson(json)).toList();
        assets.assignAll(list);
      } else {
        showError(Get.context!, response.body['message']);
      }
    } catch (err) {
      showError(Get.context!, "Something went wrong");
      print("Exception: "+err.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
