import 'package:flutter/material.dart';
import 'utils.dart';
import 'mon_sms_pro_auth_style.dart';
import 'mon_sms_pro_auth_screen.dart';

Future<String?> showAuthScreen(
  BuildContext context, {
  required String apiKey,
  required String senderName,
  String? appName,
  String? demoOTP,
  String? demoPhoneNumber,
  int? otpLength,
  MonSmsProAuthStyle? style,
  Future<bool> Function(String phoneNumber)? beforeSendOTP,
  String? onBeforeSendOTPError,
  void Function(String phoneNumber)? onCompleted,
  MonSmsProAuthNavigationMode navigationMode = MonSmsProAuthNavigationMode.push,
}) async {
  return await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => MonSmsProAuthScreen(
        apiKey: apiKey,
        senderName: senderName,
        appName: appName,
        demoOTP: demoOTP,
        demoPhoneNumber: demoPhoneNumber,
        otpLength: otpLength ?? 4,
        beforeSendOTP: beforeSendOTP,
        onBeforeSendOTPError: onBeforeSendOTPError ?? "",
        onCompleted: onCompleted,
        style: style ??
            MonSmsProAuthStyle(
              paddingSize: 15,
              mainColor: Theme.of(context).primaryColor,
            ),
      ),
    ),
  );
}
