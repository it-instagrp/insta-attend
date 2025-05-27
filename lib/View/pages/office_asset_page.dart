import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:insta_attend/Component/Subpages/asset_section.dart';
import 'package:insta_attend/Constant/constant_asset.dart';
import 'package:insta_attend/Constant/constant_color.dart';
import 'package:get/get.dart';
import 'package:insta_attend/Controller/asset_controller.dart';

class OfficeAssetPage extends StatelessWidget {
  OfficeAssetPage({super.key});

  final AssetController controller = Get.find<AssetController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFFF1F3F8),
        appBar: AppBar(
          backgroundColor: Colors.white,
          leadingWidth: 50,
          leading: InkWell(
            onTap: () => Get.back(),
            child: SizedBox(
              width: 20,
              height: 20,
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: SvgPicture.asset(
                  kaBackButton,
                  fit: BoxFit.scaleDown,
                  width: 10,
                  height: 10,
                ),
              ),
            ),
          ),
          centerTitle: true,
          title: Text(
            "Office Assets",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF101828),
            ),
          ),
        ),
        body: Container(
          margin: EdgeInsets.all(15.0),
          padding: EdgeInsets.all(15.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            color: Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /**** Page Title ****/
              ListTile(
                contentPadding: EdgeInsets.zero,
                isThreeLine: false,
                horizontalTitleGap: 0,
                title: Text(
                  "Assets Information",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  "Your Office Assets Information",
                  style: TextStyle(fontSize: 12, color: kcGrey500),
                ),
              ),

              SizedBox(height: 10),

              /**** Version List ****/
              Expanded(
                child: Obx(
                      () => controller.isLoading.value
                      ? Center(
                    child: CircularProgressIndicator(
                      strokeCap: StrokeCap.round,
                      color: kcPurple600,
                    ),
                  )
                      : controller.assets.isEmpty
                      ? Center(
                    child: Text(
                      "No Assets Allocated to you",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                      : ListView.separated(
                    itemBuilder: (context, index) {
                      final asset = controller.assets[index];
                      return AssetSection(asset: asset);

                    },
                    separatorBuilder: (context, index) =>
                        SizedBox(height: 15.0),
                    itemCount: controller.assets.length,
                  ),
                ),
              ),
            ],
          ),
        )
    );
  }
}
