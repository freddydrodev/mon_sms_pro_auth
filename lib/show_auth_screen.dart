import 'package:flutter/material.dart';
import 'package:mon_sms_pro_auth/mon_sms_pro_auth.dart';
import 'package:phone_form_field/phone_form_field.dart';

Future<PhoneNumber?> showAuthScreen(
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
}) async {
  return await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => MonSmsProAuth(
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
