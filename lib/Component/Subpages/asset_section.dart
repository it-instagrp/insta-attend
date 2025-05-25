import 'package:flutter/material.dart';
import 'package:insta_attend/Component/Fields/custom_textfield.dart';
import 'package:insta_attend/Constant/constant_asset.dart';
import 'package:insta_attend/Constant/constant_color.dart';
import 'package:insta_attend/Model/asset.dart';
import 'package:intl/intl.dart';

class AssetSection extends StatelessWidget {
  final Asset asset;
  const AssetSection({super.key, required this.asset});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 10.0,
          ),
          Text(asset.assetName ?? " ", style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: kcGrey600
          ),),
          SizedBox(
            height: 10.0,
          ),
          CustomTextfield(title: "Asset Name", hintText: "Asset Name", icon: kaAssetNameIcon, controller: TextEditingController(text: asset.assetName), isDisabled: true,),
          SizedBox(
            height: 10.0,
          ),
          CustomTextfield(title: "Asset Brand", hintText: "Asset Brand", icon: kaAssetBrandIcon, controller: TextEditingController(text: asset.assetBrand), isDisabled: true,),
          SizedBox(
            height: 10.0,
          ),
          CustomTextfield(title: "Warranty Status", hintText: "Warranty Status", icon: kaWarrantyIcon, controller: TextEditingController(text: asset.assetWarrantyStatus), isDisabled: true,),
          SizedBox(
            height: 10.0,
          ),
          CustomTextfield(title: "Allotted Date", hintText: "Allotted Date", icon: kaAllottedDateIcon, controller: TextEditingController(text: formatedDate(asset.allotedDate ?? (DateTime.now()).toString())), isDisabled: true,),
          SizedBox(
            height: 10.0,
          ),
          CustomTextfield(title: "Return Date", hintText: "Return Date", icon: kaReturnDateIcon, controller: TextEditingController(text: formatedDate(asset.returnDate ?? "NA")), isDisabled: true,),
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
}
