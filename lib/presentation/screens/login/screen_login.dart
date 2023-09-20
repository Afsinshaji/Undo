import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:google_fonts/google_fonts.dart';

var animationLink =
    'https://public.rive.app/community/runtime-files/3645-7621-remix-of-login-machine.riv';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  static ValueNotifier<bool> showOtpSection = ValueNotifier(false);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  StateMachineController? stateMachineController;
  Artboard? artboard;
  SMITrigger? failTrigger, successTrigger;
  SMIBool? isHandsUp, isChecking;
  SMINumber? lookNum;

  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
          child: Center(
        child: SingleChildScrollView(
          child: Column(children: [
            if (artboard != null)
              SizedBox(
                width: size.width - 50,
                height: size.height / 4,
                child: Rive(artboard: artboard!),
              ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                boxShadow: const [BoxShadow(color: Colors.blueGrey)],
                borderRadius: BorderRadius.circular(15),
                color: Colors.white,
              ),
              child: ValueListenableBuilder(
                  valueListenable: LoginScreen.showOtpSection,
                  builder: (context, showOtpSection, _) {
                      final otpSection = showOtpSection == true
                          ? OtpSection()
                          : const SizedBox();

                    return Column(
                      children: [
                        PhoneNumberSection(screenWidth: size.width),
                        AnimatedSwitcher(
                          duration: const Duration(seconds: 5),
                          child:otpSection
                     
                        // showOtpSection == true
                        //     ? OtpSection()
                        //     : const SizedBox(),
                        ),
                        LoginButtonSection(
                          screenWidth: size.width,
                        )
                      ],
                    );
                  }),
            )
          ]),
        ),
      )),
    );
  }

  void lookAround() {
    isChecking?.change(true);
    isHandsUp?.change(false);
    lookNum?.change(0);
  }

  void moveEyes(value) {
    lookNum?.change(value.length.toDouble());
  }

  void handsUpOnEyes() {
    isHandsUp?.change(true);
    isChecking?.change(false);
  }

  void click(var a) {
    isChecking?.change(false);
    isHandsUp?.change(false);
    if (a == 1) {
      successTrigger?.fire();
    } else {
      failTrigger?.fire();
    }
    setState(() {});
  }

  init() async {
    final file = await RiveFile.network(animationLink);
    final art = file.mainArtboard;
    stateMachineController =
        StateMachineController.fromArtboard(art, "Login Machine");
    if (stateMachineController != null) {
      art.addController(stateMachineController!);
      for (var element in stateMachineController!.inputs) {
        if (element.name == "isChecking") {
          isChecking = element as SMIBool;
        } else if (element.name == "isHandsUp") {
          isHandsUp = element as SMIBool;
        } else if (element.name == "trigSuccess") {
          successTrigger = element as SMITrigger;
        } else if (element.name == "trigFail") {
          failTrigger = element as SMITrigger;
        } else if (element.name == "numLook") {
          lookNum = element as SMINumber;
        }
      }
    }
    setState(() {
      artboard = art;
    });
  }
}

class LoginButtonSection extends StatelessWidget {
  const LoginButtonSection({
    super.key,
    required this.screenWidth,
  });
  final double screenWidth;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 20,
        ),
        Center(
          child: ValidateButton(
            buttonText: 'Get OTP',
            onTap: () {
              LoginScreen.showOtpSection.value = true;
            },
            buttonWidth: screenWidth / 4,
          ),
        ),
        const SizedBox(
          height: 20,
        )
      ],
    );
  }
}

class OtpSection extends StatelessWidget {
  OtpSection({
    super.key,
  });
  final List<FocusNode> focusNodes = List.generate(6, (index) => FocusNode());

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Enter your OTP',
        ),
        Row(
          children: List.generate(
            4,
            (index) => OtpTextfield(
              index: index,
              focusNodes: focusNodes,
            ),
          ),
        ),
      ],
    );
  }
}

class OtpTextfield extends StatefulWidget {
  const OtpTextfield({
    super.key,
    required this.index,
    required this.focusNodes,
  });
  final int index;
  final List focusNodes;

  @override
  State<OtpTextfield> createState() => _OtpTextfieldState();
}

class _OtpTextfieldState extends State<OtpTextfield> {
  Color containerColor = Colors.black.withOpacity(0.15);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal:8.0,vertical: 4),
      height: 60,
      width: 60,
      decoration: BoxDecoration(
        boxShadow: [
                BoxShadow(
                  blurStyle: BlurStyle.normal,
                  blurRadius: 10,
                    color: Colors.black.withOpacity(.18), offset: Offset(10, 5))
              ],
          color: containerColor, borderRadius: BorderRadius.circular(35)),
      padding: const EdgeInsets.all(10),
      child: TextField(
        textAlign: TextAlign.center,
        focusNode: widget.focusNodes[widget.index],
        maxLength: 1,
        showCursor: false,
        decoration: const InputDecoration(
          // filled: true,
          hoverColor: Colors.black,
          focusColor: Colors.black,
          fillColor: Colors.grey,
          counterText: '',
          border: InputBorder.none,
        ),
        style: GoogleFonts.crimsonText(
            textStyle: const TextStyle(
          letterSpacing: 2.5,
          fontSize: 22,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        )),
        keyboardType: TextInputType.number,
        onChanged: (value) {
          if (value.isNotEmpty) {
            setState(() {
              containerColor = Colors.black;
            });

            if (widget.index < 4) {
              FocusScope.of(context)
                  .requestFocus(widget.focusNodes[widget.index + 1]);
            } else {
              //String otp = controllers.join();
            }
          }
        },
      ),
    );
  }
}

class PhoneNumberSection extends StatelessWidget {
  const PhoneNumberSection({
    super.key,
    required this.screenWidth,
  });
  final double screenWidth;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 20,
        ),
        Text(
          'Enter your number',
          style: GoogleFonts.poppins(
            textStyle: TextStyle(
              letterSpacing: .5,
              fontSize: 12,
              color: Colors.black.withOpacity(0.5),
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Container(
          decoration: BoxDecoration(
              boxShadow:  [
                BoxShadow(
                  blurStyle: BlurStyle.normal,
                  blurRadius: 10,
                    color: Colors.black.withOpacity(.18), offset: Offset(10, 5))
              ],
              color: Colors.black.withOpacity(0.13),
              borderRadius: BorderRadius.circular(15)),
          padding: const EdgeInsets.all(10),
          height: 80,
          width: 300,
          child: TextField(
            maxLength: 10,
            textAlign: TextAlign.start,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(0),
              fillColor: Colors.grey,
              prefix: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Text(
                  '+91',
                  style: GoogleFonts.crimsonText(
                    textStyle: const TextStyle(
                      letterSpacing: 1,
                      fontSize: 21,
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            style: GoogleFonts.crimsonText(
                textStyle: const TextStyle(
              letterSpacing: 5.5,
              fontSize: 21,
              color: Colors.black,
              fontWeight: FontWeight.w700,
            )),
            keyboardType: TextInputType.number,
          ),
        ),
      ],
    );
  }
}

class ValidateButton extends StatelessWidget {
  const ValidateButton(
      {super.key,
      required this.buttonText,
      required this.onTap,
      required this.buttonWidth});
  final String buttonText;
  final Function() onTap;
  final double buttonWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: buttonWidth,
      decoration: BoxDecoration(
          boxShadow: const [BoxShadow(color: Colors.black)],
          borderRadius: BorderRadius.circular(20),
          color: Colors.black),
      child: TextButton(
        onPressed: onTap,
        child: Text(
          buttonText,
          style: GoogleFonts.poppins(
            textStyle: const TextStyle(
              letterSpacing: .5,
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
