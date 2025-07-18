import 'package:flutter/material.dart';
import 'package:mon_sms_pro_auth/mon_sms_pro_auth_style.dart';
import 'package:mon_sms_pro_auth/otp_view.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'package:mon_sms_pro/mon_sms_pro.dart';

export "mon_sms_pro_auth_style.dart";

class MonSmsProAuth extends StatefulWidget {
  final String apiKey;
  final String senderName;
  final String? appName;
  final int otpLength;

  final MonSmsProAuthStyle style;

  /// For development and testing purpose only.
  ///
  /// This is usefull for Google Play or Apple App Store submission.
  /// It does not send OTP to client but it just compare with the defined one.
  ///
  /// For example, you can use it to test the app with a demo phone number.
  final String? demoPhoneNumber;

  /// For development and testing purpose only.
  ///
  /// This is usefull for Google Play or Apple App Store submission.
  /// It does not send OTP to client but it just compare with the defined one.
  ///
  /// For example, you can use it to test the app with a demo OTP.
  final String? demoOTP;

  /// This function can be use to verify if this user is from the db.
  /// It call the beforeSendOTP and return the result.
  /// If beforeSendOTP is null, it will return true.
  final Future<bool> Function(String phoneNumber)? beforeSendOTP;

  final String onBeforeSendOTPError;

  final Function(String phoneNumber)? onCompleted;

  const MonSmsProAuth({
    super.key,
    required this.apiKey,
    required this.senderName,
    this.style = const MonSmsProAuthStyle(),
    this.appName,
    // this.paddingSize = 15,
    this.otpLength = 4,
    // this.mainColor = Colors.black,
    // this.buttonTextColor = Colors.white,
    // this.buttonRadius = const BorderRadius.all(Radius.circular(15)),
    this.demoPhoneNumber,
    this.demoOTP,
    this.beforeSendOTP,
    this.onBeforeSendOTPError = 'User not found',
    this.onCompleted,
  });

  @override
  State<MonSmsProAuth> createState() => _MonSmsProAuthState();
}

class _MonSmsProAuthState extends State<MonSmsProAuth> {
  PhoneNumber? phoneNumber;
  final controller = TextEditingController();
  final focusNode = FocusNode();
  bool loading = false;
  String? _token;
  late MonSMSPRO _sms;

  @override
  void initState() {
    _sms = MonSMSPRO(apiKey: widget.apiKey);

    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  Future<bool> _sendOTP() async {
    try {
      setState(() => loading = true);

      if (widget.beforeSendOTP != null) {
        if (!(await widget.beforeSendOTP!(phoneNumber!.international))) {
          throw widget.onBeforeSendOTPError;
        }
      }

      if (widget.demoPhoneNumber != null &&
          widget.demoOTP != null &&
          phoneNumber!.international == widget.demoPhoneNumber) {
        setState(() {
          _token = widget.demoOTP;
          loading = false;
        });

        return true;
      } else {
        final otp = await _sms.otp.get(
          GetOtpPayload(
            phoneNumber: phoneNumber!.international,
            appName: widget.appName,
            length: widget.otpLength,
            senderId: widget.senderName,
          ),
        );

        setState(() => loading = false);

        if (otp != null) setState(() => _token = otp.token);

        return true;
      }
    } catch (e) {
      print(e);

      setState(() => loading = false);

      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.style.backgroundColor,
      appBar: AppBar(
        backgroundColor: widget.style.backgroundColor,
        foregroundColor: widget.style.textColor,
      ),
      body: Padding(
        padding: EdgeInsets.only(
          left: widget.style.paddingSize,
          right: widget.style.paddingSize,
          bottom: widget.style.paddingSize,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Entrez Votre Numéro de Téléphone",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: widget.style.textColor,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Nous vous enverrons un code à ${widget.otpLength} chiffres par SMS pour vérifier votre numéro de téléphone.",
              style: TextStyle(
                color: widget.style.textColor.withValues(alpha: 0.8),
                fontSize: 16,
              ),
            ),
            SizedBox(height: 30),
            PhoneFormField(
              autofocus: true,
              initialValue: PhoneNumber.parse('+225'), // or use the controller
              validator: PhoneValidator.compose([
                PhoneValidator.required(
                  context,
                  errorText: "Ce champ est réquis",
                ),
                PhoneValidator.validMobile(
                  context,
                  errorText: "Numéro non valide",
                ),
              ]),
              countrySelectorNavigator: const CountrySelectorNavigator.page(
                countries: [IsoCode.CI],
              ),
              onChanged: (p) => setState(() {
                phoneNumber = p;
              }),
              enabled: !loading,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                height: 1.7,
                color: widget.style.textColor,
              ),
              isCountrySelectionEnabled: true,
              isCountryButtonPersistent: true,
              countryButtonStyle: CountryButtonStyle(
                showDialCode: true,
                showIsoCode: true,
                showFlag: true,
                flagSize: 16,
                showDropdownIcon: false,
                textStyle: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  height: 1,
                  color: widget.style.textColor,
                ),
              ),
            ),
            Expanded(child: SizedBox()),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.style.mainColor,
                foregroundColor: widget.style.buttonTextColor,
                textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                fixedSize: Size.fromHeight(50),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: widget.style.buttonRadius,
                ),
              ),
              onPressed: loading
                  ? null
                  : () async {
                      if (phoneNumber == null || !phoneNumber!.isValid()) {
                        return;
                      }

                      try {
                        if (await _sendOTP()) {
                          if (context.mounted) {
                            final res = await showModalBottomSheet(
                              context: context,
                              showDragHandle: true,
                              useRootNavigator: true,
                              useSafeArea: true,
                              isScrollControlled: true,
                              backgroundColor: widget.style.backgroundColor
                                          .computeLuminance() >
                                      0.5
                                  ? Color.fromARGB(255, 223, 216, 216)
                                  : Color.fromARGB(255, 58, 56, 56),
                              builder: (context) {
                                return FractionallySizedBox(
                                  heightFactor: 0.87,
                                  child: OTPView(
                                    style: widget.style,
                                    otpLength: widget.otpLength,
                                    sms: _sms,
                                    token: _token ?? "",
                                    phoneNumber: phoneNumber!.international,
                                    retry: _sendOTP,
                                    demoOTP: widget.demoOTP,
                                    demoPhoneNumber: widget.demoPhoneNumber,
                                  ),
                                );
                              },
                            );

                            if (res != null) {
                              if (widget.onCompleted != null) {
                                widget.onCompleted!(res);
                              } else {
                                if (context.mounted) {
                                  if (Navigator.canPop(context)) {
                                    Navigator.pop(context, res);
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => res),
                                    );
                                  }
                                }
                              }
                            }
                          }
                        }
                      } catch (e) {
                        print(e);
                        setState(() => loading = false);
                      }
                    },
              child: loading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : Text("Vérifier"),
            ),
          ],
        ),
      ),
    );
  }
}
