import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:insta_attend/Component/Button/main_button.dart';
import 'package:insta_attend/Constant/constant_asset.dart';
import 'package:insta_attend/Constant/constant_color.dart';
import 'package:insta_attend/Model/version.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class VersionCard extends StatelessWidget {
  final Version version;

  const VersionCard({super.key, required this.version});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15.0),
      width: MediaQuery
          .of(context)
          .size
          .width,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0)
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SvgPicture.asset(
                kaFaq, fit: BoxFit.scaleDown, height: 20, width: 20,),
              SizedBox(
                width: 10.0,
              ),
              Text(formatedDate(version.createdAt ?? "NA"),
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),)
            ],
          ),
          SizedBox(
            height: 10.0,
          ),
          Container(
            padding: EdgeInsets.all(12.0),
            decoration: BoxDecoration(
                color: kcGrey100,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: kcGrey200)
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(version.versionName ?? "NA", style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black
                ),),
                SizedBox(
                  height: 5.0,
                ),
                ...(List.generate(version.features!.length, (index) {
                  final feature = version.features![index];
                  return Text("• ${feature}", style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.black
                  ),);
                })),
                SizedBox(
                  height: 20,
                ),
                Align(
                    alignment: Alignment.centerRight,
                    child: MainButton(label: "Download", onTap: () async{
                      await downloadApp(version.versionLink ?? "NA");
                    })
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  String formatedDate(String date) {
    try {
      final result = DateFormat('dd MMMM yyyy').format(DateTime.parse(date));
      return result;
    } catch (err) {
      print("Something went wrong: " + err.toString());
      return "NA";
    }
  }

  Future<void> downloadApp(String uri) async {
    final Uri url = Uri.parse(uri);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $uri');
    }
  }
}
