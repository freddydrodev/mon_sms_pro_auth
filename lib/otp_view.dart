import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mon_sms_pro/mon_sms_pro.dart';
import 'package:mon_sms_pro_auth/mon_sms_pro_auth_style.dart';
import 'package:pinput/pinput.dart';
import 'package:mon_sms_pro_auth/count_down.dart';

class OTPView extends StatefulWidget {
  // final double paddingSize;
  final int otpLength;
  // final Color mainColor;
  // final Color buttonTextColor;
  final MonSMSPRO sms;
  final String token;
  final String phoneNumber;
  final Future Function() retry;
  // final BorderRadius buttonRadius;
  final String? demoPhoneNumber;
  final String? demoOTP;
  final MonSmsProAuthStyle style;

  const OTPView({
    super.key,
    // required this.paddingSize,
    required this.otpLength,
    // required this.mainColor,
    // required this.buttonTextColor,
    required this.sms,
    required this.token,
    required this.phoneNumber,
    required this.retry,
    // required this.buttonRadius,
    required this.style,
    this.demoPhoneNumber,
    this.demoOTP,
  });

  @override
  State<OTPView> createState() => OTPViewState();
}

class OTPViewState extends State<OTPView> {
  bool loading = false;

  final _controller = TextEditingController();

  final _focusNode = FocusNode();

  bool _canRetry = false;

  final GlobalKey<CountDownState> _countDownKey = GlobalKey<CountDownState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  verify() async {
    if (_controller.text.trim().length != widget.otpLength) {
      return;
    }

    if (widget.demoPhoneNumber != null &&
        widget.demoOTP != null &&
        widget.phoneNumber == widget.demoPhoneNumber &&
        _controller.text == widget.demoOTP) {
      Navigator.pop(
        context,
        widget.phoneNumber,
      );
    } else {
      try {
        final res = await widget.sms.otp.verify(
          VerifyOtpPayload(
            phoneNumber: widget.phoneNumber,
            token: widget.token,
            otp: _controller.text,
          ),
        );

        if (mounted) {
          Navigator.pop(
            context,
            res.data?.phoneNumber,
          );
        }
      } catch (e) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        color: widget.style.textColor,
      ),
      decoration: const BoxDecoration(),
    );

    final cursor = Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 56,
          height: 3,
          decoration: BoxDecoration(
            color: widget.style.mainColor,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ],
    );

    final preFilledWidget = Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 56,
          height: 3,
          decoration: BoxDecoration(
            color: widget.style.textColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ],
    );

    return Padding(
      padding: EdgeInsets.only(left: 15, right: 15, bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Vérification du Numéro de Téléphone",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: widget.style.textColor,
            ),
          ),
          SizedBox(height: 10),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              text:
                  "Nous avons envoyé un code à ${widget.otpLength} chiffres par SMS au",
              style: TextStyle(
                color: widget.style.textColor.withValues(alpha: 0.8),
                fontSize: 14,
              ),
              children: [
                TextSpan(
                  text: " ${widget.phoneNumber}",
                  style: TextStyle(
                    color: widget.style.textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: ". Veuillez le saisir ci-dessous.",
                  style: TextStyle(
                    color: widget.style.textColor.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Pinput(
            autofocus: true,
            length: widget.otpLength,
            pinAnimationType: PinAnimationType.slide,
            controller: _controller,
            focusNode: _focusNode,
            defaultPinTheme: defaultPinTheme,
            showCursor: true,
            cursor: cursor,
            preFilledWidget: preFilledWidget,
            onCompleted: (pin) async => await verify(),
          ),
          SizedBox(height: 10),
          Center(
            child: CountDown(
              key: _countDownKey,
              duration: Duration(minutes: 1),
              replacement: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: "Vous n'avez pas reçu de code ? ",
                  style: TextStyle(
                    color: widget.style.textColor.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                  children: [
                    TextSpan(
                      text: "Envoyer un nouveau code.",
                      recognizer: TapGestureRecognizer()
                        ..onTap = _canRetry
                            ? () async {
                                setState(() => loading = true);

                                await widget.retry();
                                setState(() => loading = false);

                                _countDownKey.currentState?.restart();
                                setState(() {
                                  _canRetry = false;
                                });
                              }
                            : null,
                      style: TextStyle(
                        color: _canRetry
                            ? widget.style.mainColor
                            : widget.style.textColor.withValues(alpha: 0.3),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        decoration: _canRetry
                            ? TextDecoration.underline
                            : TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
              style: TextStyle(
                color: widget.style.textColor.withValues(alpha: 0.8),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              separatorStyle: TextStyle(
                color: widget.style.textColor.withValues(alpha: 0.8),
                fontSize: 14,
              ),
              onDone: () {
                setState(() {
                  _canRetry = true;
                });
              },
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.style.mainColor,
              foregroundColor: widget.style.buttonTextColor,
              textStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              fixedSize: Size.fromHeight(50),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: widget.style.buttonRadius,
              ),
            ),
            onPressed: loading ? null : verify,
            child: loading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : Text("Continuer"),
          ),
        ],
      ),
    );
  }
}
