import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'package:pinput/pinput.dart';

class MonSmsProAuth extends StatefulWidget {
  final String apiKey;
  final String senderName;
  final String? appName;
  final double paddingSize;
  final int otpLength;
  final Color mainColor;
  final Color buttonTextColor;

  const MonSmsProAuth({
    super.key,
    required this.apiKey,
    required this.senderName,
    this.appName,
    this.paddingSize = 15,
    this.otpLength = 4,
    this.mainColor = Colors.black,
    this.buttonTextColor = Colors.white,
  });

  @override
  State<MonSmsProAuth> createState() => _MonSmsProAuthState();
}

class _MonSmsProAuthState extends State<MonSmsProAuth> {
  PhoneNumber? phoneNumber;
  final controller = TextEditingController();
  final focusNode = FocusNode();
  bool loading = false;

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    super.dispose();
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
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: loading
                  ? null
                  : () {
                      if (phoneNumber == null ||
                          phoneNumber!.isValid() == false) {
                        return;
                      }

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

                      showModalBottomSheet(
                        context: context,
                        showDragHandle: true,
                        useRootNavigator: true,
                        useSafeArea: true,
                        isScrollControlled: true,
                        builder: (context) {
                          return FractionallySizedBox(
                            heightFactor: 0.87,
                            child: Padding(
                              padding: EdgeInsets.only(
                                  left: 15, right: 15, bottom: 15),
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
                                        color:
                                            Colors.black.withValues(alpha: 0.8),
                                        fontSize: 14,
                                      ),
                                      children: [
                                        TextSpan(
                                          text:
                                              " ${phoneNumber?.international}",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        TextSpan(
                                          text:
                                              ". Veuillez le saisir ci-dessous.",
                                          style: TextStyle(
                                            color: Colors.black
                                                .withValues(alpha: 0.8),
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
                                    controller: controller,
                                    focusNode: focusNode,
                                    defaultPinTheme: defaultPinTheme,
                                    showCursor: true,
                                    cursor: cursor,
                                    preFilledWidget: preFilledWidget,
                                    onCompleted: (pin) => debugPrint(pin),
                                  ),
                                  SizedBox(height: 10),
                                  RichText(
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
                                            ..onTap = () {
                                              debugPrint(
                                                  "Envoyer un nouveau code.");
                                            },
                                          style: TextStyle(
                                            color: widget.mainColor,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                      ],
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
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                    onPressed: loading ? null : () {},
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
                            ),
                          );
                        },
                      );
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
