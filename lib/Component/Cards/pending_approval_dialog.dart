import 'package:flutter/material.dart';
import 'package:insta_attend/Constant/constant_color.dart';
import 'package:insta_attend/Constant/constant_font.dart';
import 'package:insta_attend/Component/Button/main_button.dart';

class PendingApprovalDialog extends StatelessWidget {
  final String message;
  final VoidCallback? onOkayTap;

  const PendingApprovalDialog({
    super.key,
    this.message =
    "Your account registration is currently pending admin approval. Please wait until your administrator grants access.",
    this.onOkayTap,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 4,
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: kcWarning50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.hourglass_top_rounded,
                size: 36,
                color: kcWarning600,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Approval Pending",
              style: kfTitleLarge.copyWith(
                color: kcGrey900,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: kfBodySmall.copyWith(
                color: kcGrey600,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: MainButton(
                label: "Got It",
                onTap: onOkayTap ?? () => Navigator.of(context).pop(),
                buttonSize: ButtonSize.sm,
              ),
            ),
          ],
        ),
      ),
    );
  }
}