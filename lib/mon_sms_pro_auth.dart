import 'package:flutter/material.dart';
import 'package:mon_sms_pro_auth/views/otp_view.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'package:mon_sms_pro/mon_sms_pro.dart';

class MonSmsProAuth extends StatefulWidget {
  final String apiKey;
  final String senderName;
  final String? appName;
  final double paddingSize;
  final int otpLength;
  final Color mainColor;
  final Color buttonTextColor;
  final BorderRadius buttonRadius;

  const MonSmsProAuth({
    super.key,
    required this.apiKey,
    required this.senderName,
    this.appName,
    this.paddingSize = 15,
    this.otpLength = 4,
    this.mainColor = Colors.black,
    this.buttonTextColor = Colors.white,
    this.buttonRadius = const BorderRadius.all(Radius.circular(15)),
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

  Future _sendOTP() async {
    setState(() => loading = true);

    final otp = await _sms.otp.get(
      GetOtpPayload(
        phoneNumber: phoneNumber!.international,
        appName: widget.appName,
        length: widget.otpLength,
        senderId: widget.senderName,
      ),
    );

    setState(() => loading = false);

    if (otp != null) {
      setState(() {
        _token = otp.token;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: EdgeInsets.only(
          left: widget.paddingSize,
          right: widget.paddingSize,
          bottom: widget.paddingSize,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Entrez Votre Numéro de Téléphone",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Nous vous enverrons un code à ${widget.otpLength} chiffres par SMS pour vérifier votre numéro de téléphone.",
              style: TextStyle(
                color: Colors.black87,
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
                PhoneValidator.validMobile(context,
                    errorText: "Numéro non valide"),
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
              ),
              isCountrySelectionEnabled: true,
              isCountryButtonPersistent: true,
              countryButtonStyle: const CountryButtonStyle(
                showDialCode: true,
                showIsoCode: true,
                showFlag: true,
                flagSize: 16,
                showDropdownIcon: false,
                textStyle: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
              ),
            ),
            Expanded(child: SizedBox()),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.mainColor,
                foregroundColor: widget.buttonTextColor,
                textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                fixedSize: Size.fromHeight(50),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: widget.buttonRadius,
                ),
              ),
              onPressed: loading
                  ? null
                  : () async {
                      if (phoneNumber == null || !phoneNumber!.isValid()) {
                        return;
                      }

                      try {
                        await _sendOTP();

                        if (context.mounted) {
                          final res = await showModalBottomSheet(
                            context: context,
                            showDragHandle: true,
                            useRootNavigator: true,
                            useSafeArea: true,
                            isScrollControlled: true,
                            builder: (context) {
                              return FractionallySizedBox(
                                heightFactor: 0.87,
                                child: OTPView(
                                  paddingSize: widget.paddingSize,
                                  otpLength: widget.otpLength,
                                  mainColor: widget.mainColor,
                                  buttonTextColor: widget.buttonTextColor,
                                  sms: _sms,
                                  token: _token ?? "",
                                  phoneNumber: phoneNumber!.international,
                                  retry: _sendOTP,
                                  buttonRadius: widget.buttonRadius,
                                ),
                              );
                            },
                          );

                          if (res != null) {
                            if (context.mounted) {
                              Navigator.pop(context, res);
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
