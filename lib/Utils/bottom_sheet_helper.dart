import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../Component/Button/custom_button.dart';
import '../Constant/constant_color.dart';
import '../Constant/constant_font.dart';

void showCustomBottomSheet({
  required BuildContext context,
  required String title,
  required String description,
  required String topIconAsset,
  required Widget primaryButton,
  bool showSecondaryButton = true,
  String secondaryButtonLabel = "No, Let me check",
  VoidCallback? onSecondaryAction,
  bool isSecondaryDestructive = false,
  Widget? additionalContent,
}) {
  showModalBottomSheet(
    barrierColor: Colors.black.withAlpha(180),
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 50),
              padding: const EdgeInsets.all(20.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      description,
                      style: kfBodyMedium.copyWith(color: kcGrey400),
                    ),
                  ),
                  if (additionalContent != null) ...[
                    const SizedBox(height: 30),
                    additionalContent,
                  ],
                  const SizedBox(height: 30),
                  SizedBox(
                    height: 45,
                    width: double.infinity,
                    child: primaryButton,
                  ),
                  if (showSecondaryButton) ...[
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 45,
                      width: double.infinity,
                      child: CustomButton(
                        label: secondaryButtonLabel,
                        onPressed:
                            onSecondaryAction ?? () => Navigator.pop(context),
                        hierarchy: ButtonHierarchy.secondary,
                        destructive: isSecondaryDestructive,
                      ),
                    ),
                  ],
                  const SizedBox(height: 30),
                ],
              ),
            ),
            Positioned(
              top: 0,
              child: SvgPicture.asset(topIconAsset, width: 100, height: 100),
            ),
          ],
        ),
      );
    },
  );
}
