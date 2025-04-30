import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:insta_attend/Constant/constant_asset.dart';
import 'package:insta_attend/Constant/constant_color.dart';
import 'package:insta_attend/Constant/constant_font.dart';

class MessageBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onPickFile, onPickImage, onSend, onRecord;
  MessageBar({
    super.key,
    required this.controller,
    required this.onPickFile,
    required this.onPickImage,
    required this.onSend,
    required this.onRecord
  }) {
    // Listen to changes in the text controller
    controller.addListener(_updateTypingStatus);

    // Initialize isTyping based on whether the controller already has text
    isTyping.value = controller.text.isNotEmpty;
  }

  final RxBool isTyping = false.obs;

  // Update isTyping status based on text field content
  void _updateTypingStatus() {
    isTyping.value = controller.text.isNotEmpty;
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      height: 85,
      padding: EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 12
      ),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                  filled: true,
                  fillColor: Color(0xFFF1F3F8),
                  hintText: "Type a message...",
                  hintStyle: kfBodyMedium.copyWith(color: kcGrey400),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none
                  ),
                  suffixIcon: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: onPickFile,
                        child: SvgPicture.asset(kaAttachment, fit: BoxFit.scaleDown, height: 15, width: 15),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      InkWell(
                        onTap: onPickImage,
                        child: SvgPicture.asset(kaCamera, fit: BoxFit.scaleDown, height: 15, width: 15),
                      ),
                      SizedBox(
                        width: 15,
                      ),
                    ],
                  )
              ),
            ),
          ),
          SizedBox(
            width: 15,
          ),
          Obx(() => InkWell(
            onTap: isTyping.value ? onSend : onRecord,
            child: Container(
              height: 55,
              width: 55,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kcPurple500
              ),
              child: isTyping.value
                  ? SvgPicture.asset(kaSend, fit: BoxFit.scaleDown, height: 20, width: 20)
                  : SvgPicture.asset(kaMic, fit: BoxFit.scaleDown, height: 20, width: 20),
            ),
          )),
        ],
      ),
    );
  }
}