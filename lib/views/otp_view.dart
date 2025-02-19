import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mon_sms_pro/mon_sms_pro.dart';
import 'package:pinput/pinput.dart';
import 'package:slide_countdown/slide_countdown.dart';

class OTPView extends StatefulWidget {
  final double paddingSize;
  final int otpLength;
  final Color mainColor;
  final Color buttonTextColor;
  final MonSMSPRO sms;
  final String token;
  final String phoneNumber;
  final Future Function() retry;
  final BorderRadius buttonRadius;

  const OTPView({
    super.key,
    required this.paddingSize,
    required this.otpLength,
    required this.mainColor,
    required this.buttonTextColor,
    required this.sms,
    required this.token,
    required this.phoneNumber,
    required this.retry,
    required this.buttonRadius,
  });

  @override
  State<OTPView> createState() => OTPViewState();
}

class OTPViewState extends State<OTPView> {
  bool loading = false;

  final _controller = TextEditingController();

  final _focusNode = FocusNode();

  // Duration duration = Duration(minutes: 1);

  bool _canRetry = false;

  late final StreamDuration _streamDuration;

  @override
  void initState() {
    super.initState();
    _streamDuration = StreamDuration(
      config: StreamDurationConfig(
          countDownConfig: CountDownConfig(
            duration: Duration(seconds: 60),
          ),
          onDone: () {
            setState(() {
              _canRetry = true;
            });
          }),
    );
  }

  @override
  void dispose() {
    _streamDuration.dispose();
    super.dispose();
  }

  verify() async {
    if (_controller.text.trim().length != widget.otpLength) {
      return;
    }

    try {
      setState(
        () => loading = true,
      );

      final OTPModel res = await widget.sms.otp.verify(
        VerifyOtpPayload(
          phoneNumber: widget.phoneNumber,
          token: widget.token,
          otp: _controller.text,
        ),
      );

      setState(
        () => loading = false,
      );

      if (mounted) {
        Navigator.pop(
          context,
          res.phoneNumber,
        );
      }
    } catch (e) {
      setState(() {
        loading = false;
      });
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
            color: widget.mainColor,
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
            color: Colors.black12,
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
              color: Colors.black,
            ),
          ),
          SizedBox(height: 10),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              text:
                  "Nous avons envoyé un code à ${widget.otpLength} chiffres par SMS au",
              style: TextStyle(
                color: Colors.black.withValues(alpha: 0.8),
                fontSize: 14,
              ),
              children: [
                TextSpan(
                  text: " ${widget.phoneNumber}",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: ". Veuillez le saisir ci-dessous.",
                  style: TextStyle(
                    color: Colors.black.withValues(alpha: 0.8),
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
            child: SlideCountdown(
              replacement: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: "Vous n'avez pas reçu de code ? ",
                  style: TextStyle(
                    color: Colors.black87,
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

                                _streamDuration.add(
                                  const Duration(seconds: 60),
                                );

                                _streamDuration.play();

                                setState(() {
                                  _canRetry = false;
                                });
                              }
                            : null,
                      style: TextStyle(
                        color: _canRetry ? widget.mainColor : Colors.black26,
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
              streamDuration: _streamDuration,
              duration: Duration(minutes: 1),
              shouldShowMinutes: (p) => true,
              shouldShowSeconds: (p) => true,
              decoration: const BoxDecoration(),
              style: TextStyle(
                color: Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              separatorStyle: TextStyle(
                color: Colors.black87,
                fontSize: 14,
              ),
              onDone: () {
                print('ok');
                setState(() {
                  _canRetry = true;
                });
              },
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.mainColor,
              foregroundColor: widget.buttonTextColor,
              textStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              fixedSize: Size.fromHeight(50),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: widget.buttonRadius,
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
