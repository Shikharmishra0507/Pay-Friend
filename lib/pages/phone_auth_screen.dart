import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';

import 'package:firebase_auth/firebase_auth.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({Key? key}) : super(key: key);

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  bool _isLoading = false;
  TextEditingController _contactField = TextEditingController();
  List<String> otp = ['?', '?', '?', '?', '?', '?'];
  String countryCode = "+91";
  bool validated = false;
  bool codeSent = false;
  FirebaseAuth auth = FirebaseAuth.instance;
  int? userResendToken;
  String? userVerificationId;
  TextEditingController _otpController = TextEditingController();
  final GlobalKey<FormState> _contactFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _otpFormKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool resendCodeRequest = false;
  void showSnackbar(BuildContext context, String text, bool error) {
    var snackBar = SnackBar(
      content: Text(text),
      backgroundColor: error ? Colors.red : Colors.green,
      duration: const Duration(seconds: 10),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> phoneSignIn(BuildContext context) async {
    if ( (_contactFormKey.currentState==null || !_contactFormKey.currentState!.validate()) && !resendCodeRequest) return;
    if(_contactFormKey.currentState!=null)_contactFormKey.currentState?.save();
    String userPhoneNumber = countryCode + _contactField.text;
    setState(() {
      isLoading = true;
    });
    if (resendCodeRequest) showSnackbar(context, "Sending", false);
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        timeout: const Duration(milliseconds: 60000),
        phoneNumber: userPhoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {},
        codeSent: (String verificationId, int? resendToken) async {
          userVerificationId = verificationId;
          setState(() {
            codeSent = true;
            userResendToken = resendToken;
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
        forceResendingToken: userResendToken,
      );
    } catch (e) {}
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : codeSent
            ? Scaffold(
                resizeToAvoidBottomInset: false,
                backgroundColor: Color(0xfff7f6fb),
                body: SafeArea(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 18,
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                        const Text(
                          'Verification',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text("Otp is sent to your " + _contactField.text),
                        const SizedBox(
                          height: 5,
                        ),
                        const Text(
                          "Enter your OTP code number",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black38,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(
                          height: 28,
                        ),
                        Container(
                          padding: EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Expanded(
                                      child: _textFieldOTP(
                                          first: true,
                                          last: false,
                                          index: 0,
                                          otp: otp)),
                                  Expanded(
                                      child: _textFieldOTP(
                                          first: false,
                                          last: false,
                                          index: 1,
                                          otp: otp)),
                                  Expanded(
                                      child: _textFieldOTP(
                                          first: false,
                                          last: false,
                                          index: 2,
                                          otp: otp)),
                                  Expanded(
                                      child: _textFieldOTP(
                                          first: false,
                                          last: false,
                                          index: 3,
                                          otp: otp)),
                                  Expanded(
                                      child: _textFieldOTP(
                                          first: false,
                                          last: false,
                                          index: 4,
                                          otp: otp)),
                                  Expanded(
                                      child: _textFieldOTP(
                                          first: false,
                                          last: true,
                                          index: 5,
                                          otp: otp)),
                                ],
                              ),
                              const SizedBox(
                                height: 22,
                              ),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                    bool validOtp = true;
                                    String userOtp = "";
                                    for (int i = 0; i < otp.length; i++) {
                                      if (otp[i] == '?') {
                                        validOtp = false;
                                        break;
                                      }
                                      userOtp = userOtp + otp.elementAt(i);
                                    }

                                    if (!validOtp) {
                                      showSnackbar(
                                          context, "OTP is not correct", true);
                                      return;
                                    }
                                    setState(() {
                                      isLoading = true;
                                    });

                                    PhoneAuthCredential credential =
                                        PhoneAuthProvider.credential(
                                            verificationId: userVerificationId!,
                                            smsCode: userOtp);
                                    try {
                                      await auth
                                          .signInWithCredential(credential);
                                          
                                      showSnackbar(
                                          context, "Successfull", false);

                                    } catch (e) {
                                      showSnackbar(context, e.toString(), true);
                                    }
                                    setState(() {
                                      isLoading = false;
                                    });
                                  },
                                  style: ButtonStyle(
                                    foregroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.white),
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.purple),
                                    shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(24.0),
                                      ),
                                    ),
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.all(14.0),
                                    child: Text(
                                      'Verify',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 18,
                        ),
                        const Text(
                          "Didn't you receive any code?",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black38,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(
                          height: 18,
                        ),
                        TextButton(
                          child: const Text(
                            "Resend New Code",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          onPressed: () {
                            phoneSignIn(context);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : Scaffold(
                
                body: Stack(children: [
                  Positioned.fill
                  
                  (top:0,left:0,bottom:200,
                    child: Container(color:Colors.blueAccent,
                    child:Align(
                      alignment: Alignment.topCenter,
                      child:Padding(
                        padding:EdgeInsets.only(top:30),
                        child:Text("Welcome!", style: TextStyle(fontSize: 30)),)))),
                  Positioned.fill(
                    bottom: 50,
                    top: 140,
                    left:30,
                    right:30,
                    child: Container(
                      height: 300,
                      
                      decoration: const BoxDecoration(boxShadow: [
                        BoxShadow(
                            blurRadius: 10,
                            spreadRadius: 2,
                            color: Colors.black)
                      ], color: Colors.white),
                      child: Form(
                        key: _contactFormKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            const Text(
                              "Login",
                              style: TextStyle(fontSize: 25),
                            ),
                            Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    const Flexible(
                                        flex: 1,
                                        child: Padding(
                                          padding: EdgeInsets.only(left: 10.0),
                                          child: Text("Country",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16)),
                                        )),
                                    Flexible(
                                      flex: 3,
                                      child: Padding(
                                        padding: EdgeInsets.only(left: 10.0),
                                        child: GestureDetector(
                                            onTap: () {
                                              showCountryPicker(
                                                context: context,
                                                showPhoneCode:
                                                    true, // optional. Shows phone code before the country name.
                                                onSelect: (Country country) {
                                                  setState(() {
                                                    countryCode =
                                                        country.phoneCode;
                                                  });
                                                },
                                              );
                                            },
                                            child: Row(children: [
                                              Text(countryCode),
                                              const Icon(Icons.arrow_drop_down),
                                            ])),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      const Flexible(
                                          flex: 1,
                                          child: Padding(
                                            padding: EdgeInsets.only(left: 10.0),
                                            child: Text("Contact",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16)),
                                          )),
                                      Flexible(
                                        flex: 3,
                                        child: Padding(
                                          padding: EdgeInsets.only(left: 10.0),
                                          child: TextFormField(
                                            keyboardType: TextInputType.phone,
                                            validator: (String? phone) {
                                              if (phone == null ||
                                                  phone.isEmpty ||
                                                  phone.length != 10) {
                                                return "Enter valid Phone Number";
                                              }
                                        
                                              return null;
                                            },
                                            controller: _contactField,
                                            decoration: const InputDecoration(
                                                hintText:
                                                    "Enter your contact number"),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            ElevatedButton(
                                style: ButtonStyle(
                                  
                                    fixedSize: MaterialStateProperty.all(
                                        const Size(260, 10)),
                                    shape: MaterialStateProperty.all(
                                        RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(18.0),
                                            ))),
                                onPressed: () {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                  phoneSignIn(context);
                                },
                                child: const Text("Send OTP"))
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                ]));
  }

  Widget _textFieldOTP(
      {required bool first,
      required bool last,
      required int index,
      required List<String> otp}) {
    return Container(
      height: 85,
      child: AspectRatio(
        aspectRatio: 1.0,
        child: TextFormField(
          keyboardType: TextInputType.phone,
          autofocus: true,
          onChanged: (value) {
            if (value.length == 1 && last == false) {
              FocusScope.of(context).nextFocus();
            }
            if (value.length == 0 && first == false) {
              FocusScope.of(context).previousFocus();
            }

            otp[index] = value;
          },
          showCursor: false,
          readOnly: false,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          maxLength: 1,
          decoration: InputDecoration(
            counter: Offstage(),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(width: 2, color: Colors.black12),
                borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(width: 2, color: Colors.purple),
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }
}
