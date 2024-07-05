import 'package:editing_house/app_config.dart';
import 'package:editing_house/my_theme.dart';
import 'package:editing_house/other_config.dart';
import 'package:editing_house/social_config.dart';
import 'package:editing_house/ui_elements/auth_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:editing_house/custom/input_decorations.dart';
import 'package:editing_house/custom/intl_phone_input.dart';
//import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
//import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:editing_house/screens/registration.dart';
import 'package:editing_house/screens/main.dart';
import 'package:editing_house/screens/password_forget.dart';
import 'package:editing_house/custom/toast_component.dart';
import 'package:toast/toast.dart';
import 'package:editing_house/repositories/auth_repository.dart';
import 'package:editing_house/helpers/auth_helper.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:editing_house/helpers/shared_value_helper.dart';
import 'package:editing_house/repositories/profile_repository.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:twitter_login/twitter_login.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:io' show Platform;

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String _login_by = "phone"; //phone or email
  String initialCountry = 'IQ';
  PhoneNumber phoneCode = PhoneNumber(isoCode: 'IQ', dialCode: "+964");
  String _phone = "";

  //controllers
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();


  // Initially password is obscure
  bool _obscureText = true;

  String _password;

  // Toggles the password show status
  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }


  @override
  void initState() {
    //on Splash Screen hide statusbar
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    super.initState();
  }

  @override
  void dispose() {
    //before going to other screen show statusbar
    SystemChrome.setEnabledSystemUIOverlays(
        [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    super.dispose();
  }

  onPressedLogin() async {
    var email = _emailController.text.toString();
    var password = _passwordController.text.toString();

    if (_login_by == 'email' && email == "") {
      ToastComponent.showDialog(AppLocalizations.of(context).login_screen_email_warning, gravity: Toast.center, duration: Toast.lengthLong);
      return;
    } else if (_login_by == 'phone' && _phone == "") {
      ToastComponent.showDialog(AppLocalizations.of(context).login_screen_phone_warning, gravity: Toast.center, duration: Toast.lengthLong);
      return;
    } else if (_login_by == 'phone' && _phone.length < 11) {
      ToastComponent.showDialog("رقم الهاتف يجب أن يكون 11 رقم", gravity: Toast.center, duration: Toast.lengthLong);
      return;
    } else if (password == "") {
      ToastComponent.showDialog(AppLocalizations.of(context).login_screen_password_warning, gravity: Toast.center, duration: Toast.lengthLong);
      return;
    }

    var loginResponse = await AuthRepository()
        .getLoginResponse(_login_by == 'email' ? email : _phone, password);
    if (loginResponse.result == false) {
      ToastComponent.showDialog(loginResponse.message, gravity: Toast.center, duration: Toast.lengthLong);
    } else {

      ToastComponent.showDialog(loginResponse.message, gravity: Toast.center, duration: Toast.lengthLong);
      AuthHelper().setUserData(loginResponse);
      // push notification starts
      // if (OtherConfig.USE_PUSH_NOTIFICATION) {
      //   final FirebaseMessaging _fcm = FirebaseMessaging.instance;
      //
      //   await _fcm.requestPermission(
      //     alert: true,
      //     announcement: false,
      //     badge: true,
      //     carPlay: false,
      //     criticalAlert: false,
      //     provisional: false,
      //     sound: true,
      //   );
      //
      //   String fcmToken = await _fcm.getToken();
      //
      //   if (fcmToken != null) {
      //     print("--fcm token--");
      //     print(fcmToken);
      //     if (is_logged_in.$ == true) {
      //       // update device token
      //       var deviceTokenUpdateResponse = await ProfileRepository()
      //           .getDeviceTokenUpdateResponse(fcmToken);
      //     }
      //   }
      // }

      //push norification ends

      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return Main();
      }));
    }
  }

  // onPressedFacebookLogin() async {
  //   final facebookLogin =await FacebookAuth.instance.login(loginBehavior: LoginBehavior.webOnly);
  //
  //   if (facebookLogin.status == LoginStatus.success) {
  //
  //     // get the user data
  //     // by default we get the userId, email,name and picture
  //     final userData = await FacebookAuth.instance.getUserData();
  //     var loginResponse = await AuthRepository().getSocialLoginResponse("facebook",
  //         userData['name'].toString(), userData['email'].toString(), userData['id'].toString(),access_token: facebookLogin.accessToken.token);
  //     print("..........................${loginResponse.toString()}");
  //     if (loginResponse.result == false) {
  //       ToastComponent.showDialog(loginResponse.message, gravity: Toast.center, duration: Toast.lengthLong);
  //     } else {
  //       ToastComponent.showDialog(loginResponse.message, gravity: Toast.center, duration: Toast.lengthLong);
  //       AuthHelper().setUserData(loginResponse);
  //       Navigator.push(context, MaterialPageRoute(builder: (context) {
  //         return Main();
  //       }));
  //       FacebookAuth.instance.logOut();
  //     }
  //     // final userData = await FacebookAuth.instance.getUserData(fields: "email,birthday,friends,gender,link");
  //
  //   } else {
  //     print("....Facebook auth Failed.........");
  //     print(facebookLogin.status);
  //     print(facebookLogin.message);
  //   }
  //
  //
  //
  // }

  onPressedGoogleLogin() async {
    try {
      final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();


      print(googleUser.toString());

      GoogleSignInAuthentication googleSignInAuthentication =
      await googleUser.authentication;
      String accessToken = googleSignInAuthentication.accessToken;


      var loginResponse = await AuthRepository().getSocialLoginResponse("google",
          googleUser.displayName, googleUser.email, googleUser.id,access_token: accessToken);

      if (loginResponse.result == false) {
        ToastComponent.showDialog(loginResponse.message, gravity: Toast.center, duration: Toast.lengthLong);
      } else {
        ToastComponent.showDialog(loginResponse.message, gravity: Toast.center, duration: Toast.lengthLong);
        AuthHelper().setUserData(loginResponse);
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return Main(go_back:false);
        }));
      }
      GoogleSignIn().disconnect();
    } on Exception catch (e) {
      print("error is ....... $e");
      // TODO
    }



  }

  onPressedTwitterLogin() async {
    try {

      final twitterLogin = new TwitterLogin(
          apiKey: SocialConfig().twitter_consumer_key,
          apiSecretKey:SocialConfig().twitter_consumer_secret,
          redirectURI: 'activeecommerceflutterapp://'

      );
      // Trigger the sign-in flow
      final authResult = await twitterLogin.login();

      var loginResponse = await AuthRepository().getSocialLoginResponse("twitter",
          authResult.user.name, authResult.user.email, authResult.user.id.toString(),access_token: authResult.authToken);
      print(loginResponse);
      if (loginResponse.result == false) {
        ToastComponent.showDialog(loginResponse.message, gravity: Toast.center, duration: Toast.lengthLong);
      } else {
        ToastComponent.showDialog(loginResponse.message, gravity: Toast.center, duration: Toast.lengthLong);
        AuthHelper().setUserData(loginResponse);
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return Main();
        }));
      }
    } on Exception catch (e) {
      print("error is ....... $e");
      // TODO
    }



  }



  String generateNonce([int length = 32]) {
    final charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  signInWithApple() async {
    // To prevent replay attacks with the credential returned from Apple, we
    // include a nonce in the credential request. When signing in with
    // Firebase, the nonce in the id token returned by Apple, is expected to
    // match the sha256 hash of `rawNonce`.
    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);

    // Request credential for the currently signed in Apple account.
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
    );

    // Create an `OAuthCredential` from the credential returned by Apple.
    // final oauthCredential = OAuthProvider("apple.com").credential(
    //   idToken: appleCredential.identityToken,
    //   rawNonce: rawNonce,
    // );
    //print(oauthCredential.accessToken);

    // Sign in the user with Firebase. If the nonce we generated earlier does
    // not match the nonce in `appleCredential.identityToken`, sign in will fail.
    //return await FirebaseAuth.instance.signInWithCredential(oauthCredential);
  }

  @override
  Widget build(BuildContext context) {
    final _screen_height = MediaQuery.of(context).size.height;
    final _screen_width = MediaQuery.of(context).size.width;
    return AuthScreen.buildScreen(context,"${AppLocalizations.of(context).login_screen_login_to} " + AppConfig.app_name ,buildBody(context, _screen_width));

  }

  Widget buildBody(BuildContext context, double _screen_width) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: _screen_width * (3 / 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 14.0),
                child: Text(
                  _login_by == "email" ? AppLocalizations.of(context).login_screen_email : AppLocalizations.of(context).login_screen_phone,
                  style: TextStyle(
                      color: MyTheme.accent_color,
                      fontWeight: FontWeight.w600),
                ),
              ),
              if (_login_by == "email")
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        height: 36,
                        child: TextField(
                          controller: _emailController,
                          autofocus: false,
                          style: TextStyle(color: MyTheme.dark_font_grey),
                          decoration:
                          InputDecorations.buildInputDecoration_1(
                              hint_text: "email@example.com"),

                        ),
                      ),
                      otp_addon_installed.$
                          ? GestureDetector(
                        onTap: () {
                          setState(() {
                            _login_by = "phone";
                          });
                        },
                        child: Text(
                          AppLocalizations.of(context).login_screen_or_login_with_phone,
                          style: TextStyle(
                              color: MyTheme.accent_color,
                              fontStyle: FontStyle.italic,
                              decoration:
                              TextDecoration.underline),
                        ),
                      )
                          : Container()
                    ],
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Container(
                      //   height: 36,
                      //   child: CustomInternationalPhoneNumberInput(
                      //     textStyle: TextStyle(color: Theme.of(context).colorScheme.outline),
                      //     onInputChanged: (PhoneNumber number) {
                      //       print(number.phoneNumber);
                      //       setState(() {
                      //         _phone = number.phoneNumber;
                      //       });
                      //     },
                      //     onInputValidated: (bool value) {
                      //       print(value);
                      //     },
                      //     selectorConfig: SelectorConfig(
                      //       selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                      //       useEmoji: false,
                      //       trailingSpace: false
                      //     ),
                      //     ignoreBlank: false,
                      //     autoValidateMode: AutovalidateMode.disabled,
                      //     selectorTextStyle:
                      //         TextStyle(color: MyTheme.font_grey),
                      //     initialValue: phoneCode,
                      //     textFieldController: _phoneNumberController,
                      //     formatInput: true,
                      //     keyboardType: TextInputType.numberWithOptions(
                      //         signed: true, decimal: true),
                      //     inputDecoration: InputDecorations
                      //         .buildInputDecoration_phone(
                      //             hint_text: "07XXX XXX XXX"),
                      //     validator: (String value) {
                      //       return value.length < 11 ? '' : null;
                      //     },
                      //     maxLength: 11,
                      //     onSaved: (PhoneNumber number) {
                      //       print('On Saved: $number');
                      //     },
                      //   ),
                      // ),
                      Container(
                          height: 60,
                          child: Stack(
                            alignment: Alignment.centerLeft,
                            children: <Widget>[
                              Builder(
                                  builder: (context) {
                                    return Container(
                                      margin: EdgeInsets.only(left: app_language_rtl.$ ? 12 : 0,right: app_language_rtl.$ ? 0 : 12),
                                      alignment: Alignment.centerLeft,
                                      child: Row(
                                        mainAxisAlignment:  app_language_rtl.$ ? MainAxisAlignment.end : MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          app_language_rtl.$ ? Text("964+", style: TextStyle(
                                              color: MyTheme.dark_font_grey,
                                              fontSize: 14
                                          ),) : Container(),
                                          app_language_rtl.$ ? SizedBox(width: 10,) : Container(),
                                          Image.network("https://cdn-icons-png.flaticon.com/512/630/630681.png", width: 35,),
                                          app_language_rtl.$ ? Container() : Text("964+", style: TextStyle(
                                              color: MyTheme.dark_font_grey,
                                              fontSize: 14
                                          ),),
                                          app_language_rtl.$ ? Container() : SizedBox(width: 10,),
                                        ],
                                      ),
                                    );
                                  }
                              ),
                              TextFormField(
                                style: TextStyle(
                                    color: MyTheme.dark_font_grey
                                ),
                                textAlign: TextAlign.left,
                                maxLength: 11,
                                controller: _phoneNumberController,
                                onChanged: (value) {
                                  print(value);
                                  setState(() {
                                    _phone = '+964'+_phoneNumberController.text;
                                  });
                                },
                                keyboardType: TextInputType.numberWithOptions(
                                    signed: true, decimal: true),
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.only(left: 95),
                                  helperStyle: TextStyle(
                                      color: MyTheme.dark_font_grey
                                  ),
                                  hintText: "07XX XXX XXXX",
                                  counterText: "",
                                  prefixStyle: TextStyle(color: Colors.transparent),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: MyTheme.accent_color.withOpacity(.3),
                                        width: 1),
                                    borderRadius: const BorderRadius.all(
                                      const Radius.circular(8.0),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: MyTheme.accent_color,
                                        width: 0.5),
                                    borderRadius: const BorderRadius.all(
                                      const Radius.circular(6.0),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )

                        // CustomInternationalPhoneNumberInput(
                        //   textStyle: TextStyle(
                        //     color: Theme.of(context).colorScheme.outline
                        //   ),
                        //   onInputChanged: (PhoneNumber number) {
                        //     print(number.phoneNumber);
                        //     setState(() {
                        //       _phone = number.phoneNumber;
                        //     });
                        //   },
                        //   onInputValidated: (bool value) {
                        //     print(value);
                        //   },
                        //   selectorConfig: SelectorConfig(
                        //     selectorType: PhoneInputSelectorType.DIALOG,
                        //   ),
                        //   ignoreBlank: false,
                        //   autoValidateMode: AutovalidateMode.disabled,
                        //   selectorTextStyle:
                        //       TextStyle(color: Theme.of(context).colorScheme.outline),
                        //   initialValue: phoneCode,
                        //   textFieldController: _phoneNumberController,
                        //   formatInput: true,
                        //   keyboardType: TextInputType.numberWithOptions(
                        //       signed: true, decimal: true),
                        //   inputDecoration: InputDecorations
                        //       .buildInputDecoration_phone(
                        //           hint_text: "07XXX XXX XXX"),
                        //   validator: (String value) {
                        //     return value.length < 11 ? '' : null;
                        //   },
                        //   maxLength: 11,
                        //   onSaved: (PhoneNumber number) {
                        //     //print('On Saved: $number');
                        //   },
                        // ),
                      ),
                      // GestureDetector(
                      //   onTap: () {
                      //     setState(() {
                      //       _login_by = "email";
                      //     });
                      //   },
                      //   child: Text(
                      //     AppLocalizations.of(context).login_screen_or_login_with_email,
                      //     style: TextStyle(
                      //         color: MyTheme.accent_color,
                      //         fontStyle: FontStyle.italic,
                      //         decoration: TextDecoration.underline),
                      //   ),
                      // )
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(bottom: 18.0),
                child: Text(
                  AppLocalizations.of(context).login_screen_password,
                  style: TextStyle(
                      color: MyTheme.accent_color,
                      fontWeight: FontWeight.w600),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Stack(
                    children: [
                      Container(
                          height: 60,
                          child: TextFormField(
                            obscureText: _obscureText,
                            style: TextStyle(
                                color: MyTheme.dark_font_grey
                            ),
                            controller: _passwordController,
                            maxLength: 35,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: 16),
                              helperStyle: TextStyle(
                                  color: MyTheme.dark_font_grey
                              ),
                              counterText: "",
                              hintText: "• • • • • • • •",
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: MyTheme.accent_color.withOpacity(.3),
                                    width: 1),
                                borderRadius: const BorderRadius.all(
                                  const Radius.circular(8.0),
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: MyTheme.accent_color.withOpacity(.3),
                                    width: 1),
                                borderRadius: const BorderRadius.all(
                                  const Radius.circular(8.0),
                                ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: MyTheme.accent_color.withOpacity(.3),
                                    width: 1),
                                borderRadius: const BorderRadius.all(
                                  const Radius.circular(8.0),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: MyTheme.accent_color,
                                    width: 0.5),
                                borderRadius: const BorderRadius.all(
                                  const Radius.circular(6.0),
                                ),
                              ),
                            ),
                          )

                        // TextFormField(
                        //   onChanged: (value){
                        //     _formKey.currentState.validate();
                        //   },
                        //   controller: _passwordController,
                        //   autofocus: false,
                        //   obscureText: true,
                        //   enableSuggestions: false,
                        //   style: TextStyle(color: Theme.of(context).colorScheme.outline),
                        //   autocorrect: false,
                        //   decoration:
                        //       InputDecorations.buildInputDecoration_1(
                        //           hint_text: "• • • • • • • •"),
                        //   validator: (value){
                        //     if(value.isEmpty){
                        //       return null;
                        //     }else{
                        //       //call function to check password
                        //       bool result = validatePassword(value);
                        //       if(result){
                        //         // create account event
                        //         return null;
                        //       }else{
                        //         return "يجب أن تحتوي على أحرف وأرقام ورموز";
                        //       }
                        //     }
                        //   },
                        // ),
                      ),
                      Align(
                        alignment: app_language_rtl.$ ? Alignment.centerLeft : Alignment.centerRight,
                        child: IconButton(
                            onPressed: _toggle,
                            icon: new Icon(_obscureText ? Icons.visibility_off_outlined : Icons.remove_red_eye_outlined, color: MyTheme.dark_font_grey,)),
                      ),
                      // Text(
                      //   AppLocalizations.of(context).registration_screen_password_length_recommendation,
                      //   style: TextStyle(
                      //       color: MyTheme.textfield_grey,
                      //       fontStyle: FontStyle.italic),
                      // )
                    ],
                  ),
                  // GestureDetector(
                  //   onTap: () {
                  //     Navigator.push(context,
                  //         MaterialPageRoute(builder: (context) {
                  //       return PasswordForget();
                  //     }));
                  //   },
                  //   child: Text(
                  //       AppLocalizations.of(context).login_screen_forgot_password,
                  //     style: TextStyle(
                  //         color: MyTheme.accent_color,
                  //         fontStyle: FontStyle.italic,
                  //         decoration: TextDecoration.underline),
                  //   ),
                  // )
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30.0),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 45,
                  decoration: BoxDecoration(
                      color: MyTheme.accent_color,
                      border: Border.all(
                          color: MyTheme.textfield_grey, width: 1),
                      borderRadius: const BorderRadius.all(
                          Radius.circular(12.0))),
                  child: TextButton(
                    // minWidth: MediaQuery.of(context).size.width,
                    // //height: 50,
                    // color: MyTheme.accent_color,
                    // shape: RoundedRectangleBorder(
                    //     borderRadius: const BorderRadius.all(
                    //         Radius.circular(6.0))),
                    child: Text(
                      AppLocalizations.of(context).login_screen_log_in,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
                    ),
                    onPressed: () {
                      onPressedLogin();
                    },
                  ),
                ),
              ),
              // Padding(
              //   padding: const EdgeInsets.only(top: 15.0,bottom: 15),
              //   child: Center(
              //       child: Text(
              //         AppLocalizations.of(context).login_screen_or_create_new_account,
              //     style: TextStyle(
              //         color: MyTheme.font_grey, fontSize: 12),
              //   )),
              // ),
              TextButton(
                // minWidth: MediaQuery.of(context).size.width,
                // //height: 50,
                // color: MyTheme.amber,
                // shape: RoundedRectangleBorder(
                //     borderRadius: const BorderRadius.all(
                //         Radius.circular(6.0))),
                child: Container(
                  alignment: Alignment.center,
                  height: 45,
                  width: MediaQuery.of(context).size.width,
                  child: Text(
                    AppLocalizations.of(context).login_screen_sign_up,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: MyTheme.accent_color,
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) {
                        return Registration();
                      }));
                },
              ),
              Visibility(
                visible: allow_google_login.$ ||
                    allow_facebook_login.$,
                child: Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Center(
                      child: Text(
                        AppLocalizations.of(context).login_screen_login_with,
                        style: TextStyle(
                            color: MyTheme.font_grey, fontSize: 12),
                      )),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: Center(
                  child: Container(
                    width: 120,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Visibility(
                          visible: allow_google_login.$,
                          child: InkWell(
                            onTap: () {
                              onPressedGoogleLogin();
                            },
                            child: Container(
                              width: 28,
                              child:
                              Image.asset("assets/google_logo.png"),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: allow_facebook_login.$,
                          child: InkWell(
                            onTap: () {
                              //onPressedFacebookLogin();
                            },
                            child: Container(
                              width: 28,
                              child: Image.asset(
                                  "assets/facebook_logo.png"),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: allow_twitter_login.$,
                          child: InkWell(
                            onTap: () {
                              onPressedTwitterLogin();
                            },
                            child: Container(
                              width: 28,
                              child: Image.asset(
                                  "assets/twitter_logo.png"),
                            ),
                          ),
                        ),
                        /*
                                Visibility(
                                  visible: Platform.isIOS,
                                  child: InkWell(
                                    onTap: () {
                                      signInWithApple();
                                    },
                                    child: Container(
                                      width: 28,
                                      child: Image.asset(
                                          "assets/apple_logo.png"),
                                    ),
                                  ),
                                ),*/
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}