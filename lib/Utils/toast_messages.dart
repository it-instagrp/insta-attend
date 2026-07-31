import 'package:flutter/material.dart';
import 'package:insta_attend/API/app_constants.dart';
import 'package:insta_attend/Constant/constant_font.dart';
import 'package:toastification/toastification.dart';

/// Helper getter to fetch the active top-level context safely from the global key pipeline
BuildContext? get _safeContext => globalNavigatorKey.currentContext;

void showSuccess(String message) {
  final ctx = _safeContext;
  if (ctx == null) return;

  toastification.show(
    backgroundColor: Colors.white,
    alignment: Alignment.topLeft,
    autoCloseDuration: const Duration(seconds: 3),
    closeOnClick: true,
    context: ctx,
    direction: TextDirection.ltr,
    showIcon: false,
    style: ToastificationStyle.flat,
    dragToClose: true,
    title: Text(message, style: kfBodyLarge),
    type: ToastificationType.success,
  );
}

void showError(String message) {
  final ctx = _safeContext;
  if (ctx == null) return;

  toastification.show(
    backgroundColor: Colors.white,
    alignment: Alignment.topLeft,
    autoCloseDuration: const Duration(seconds: 3),
    closeOnClick: true,
    context: ctx,
    direction: TextDirection.ltr,
    showIcon: false,
    style: ToastificationStyle.flat,
    dragToClose: true,
    title: Text(message, style: kfBodyLarge),
    type: ToastificationType.error,
  );
}

void showWarning(String message) {
  final ctx = _safeContext;
  if (ctx == null) return;

  toastification.show(
    backgroundColor: Colors.white,
    alignment: Alignment.topLeft,
    autoCloseDuration: const Duration(seconds: 3),
    closeOnClick: true,
    context: ctx,
    direction: TextDirection.ltr,
    showIcon: false,
    style: ToastificationStyle.flat,
    dragToClose: true,
    title: Text(message, style: kfBodyLarge),
    type: ToastificationType.warning,
  );
}

void showInfo(String message) {
  final ctx = _safeContext;
  if (ctx == null) return;

  toastification.show(
    backgroundColor: Colors.white,
    alignment: Alignment.topLeft,
    autoCloseDuration: const Duration(seconds: 3),
    closeOnClick: true,
    context: ctx,
    direction: TextDirection.ltr,
    showIcon: false,
    style: ToastificationStyle.flat,
    dragToClose: true,
    title: Text(message, style: kfBodyLarge),
    type: ToastificationType.info,
  );
}
