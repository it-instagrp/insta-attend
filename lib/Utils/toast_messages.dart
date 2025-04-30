import 'package:flutter/material.dart';
import 'package:insta_attend/Constant/constant_font.dart';
import 'package:toastification/toastification.dart';

void showSuccess(BuildContext context, String message){
  toastification.show(
    backgroundColor: Colors.white,
    alignment: Alignment.topLeft,
    autoCloseDuration: Duration(seconds: 3),
    closeOnClick: true,
    context: context,
    direction: TextDirection.ltr,
      showIcon: false,
    style: ToastificationStyle.flat,
    dragToClose: true,
    title: Text(message, style: kfBodyLarge,),
    type: ToastificationType.success
  );
}

void showError(BuildContext context, String message){
  toastification.show(
    backgroundColor: Colors.white,
    alignment: Alignment.topLeft,
    autoCloseDuration: Duration(seconds: 3),
    closeOnClick: true,
    context: context,
    direction: TextDirection.ltr,
      showIcon: false,
    style: ToastificationStyle.flat,
    dragToClose: true,
    title: Text(message, style: kfBodyLarge,),
    type: ToastificationType.error
  );
}

void showWarning(BuildContext context, String message){
  toastification.show(
    backgroundColor: Colors.white,
    alignment: Alignment.topLeft,
    autoCloseDuration: Duration(seconds: 3),
    closeOnClick: true,
    context: context,
    direction: TextDirection.ltr,
      showIcon: false,
    style: ToastificationStyle.flat,
    dragToClose: true,
    title: Text(message, style: kfBodyLarge,),
    type: ToastificationType.warning
  );
}

void showInfo(BuildContext context, String message){
  toastification.show(
    backgroundColor: Colors.white,
    alignment: Alignment.topLeft,
    autoCloseDuration: Duration(seconds: 3),
    closeOnClick: true,
    context: context,
    direction: TextDirection.ltr,
      showIcon: false,
    style: ToastificationStyle.flat,
    dragToClose: true,
    title: Text(message, style: kfBodyLarge,),
    type: ToastificationType.info
  );
}