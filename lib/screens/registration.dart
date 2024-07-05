import 'package:editing_house/app_config.dart';
import 'package:editing_house/custom/device_info.dart';
import 'package:editing_house/my_theme.dart';
import 'package:editing_house/screens/common_webview_screen.dart';
import 'package:editing_house/ui_elements/auth_ui.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:editing_house/custom/input_decorations.dart';
import 'package:editing_house/custom/intl_phone_input.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:editing_house/screens/otp.dart';
import 'package:editing_house/screens/login.dart';
import 'package:editing_house/custom/toast_component.dart';
import 'package:toast/toast.dart';
import 'package:editing_house/repositories/auth_repository.dart';
import 'package:editing_house/helpers/shared_value_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:validators/validators.dart';

import '../data_model/city_response.dart';
import '../data_model/country_response.dart';
import '../data_model/state_response.dart';
import '../helpers/auth_helper.dart';
import '../other_config.dart';
import '../repositories/address_repository.dart';
import '../repositories/profile_repository.dart';
import 'main.dart';


class Registration extends StatefulWidget {
  @override
  _RegistrationState createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  String _register_by = "phone"; //phone or email
  String initialCountry = 'IQ';
  PhoneNumber phoneCode = PhoneNumber(isoCode: 'IQ', dialCode: "+964");

  String _phone = "";
  bool _isAgree =true;
  int _choosed_city =0;

  //controllers
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _passwordConfirmController = TextEditingController();


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
    getCountry();
  }

  getCountry() async {
    var countryResponse = await AddressRepository()
        .getCountryList(name: "Iraq");
    return countryResponse.countries;
  }

  final _formKey = GlobalKey<FormState>();


  RegExp pass_valid = RegExp(r"(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*\W)");
  double password_strength = 0;

  City _selected_city;
  Country _selected_country;
  MyState _selected_state;

  bool _isInitial = true;
  List<dynamic> _shippingAddressList = [];

  //controllers for add purpose
  TextEditingController _addressController = TextEditingController();
  TextEditingController _postalCodeController = TextEditingController();
  TextEditingController _cityController = TextEditingController();
  TextEditingController _stateController = TextEditingController();
  TextEditingController _countryController = TextEditingController();

  bool validatePassword(String pass){
    String _password = pass.trim();
    if(_password.isEmpty){
      setState(() {
        password_strength = 0;
      });
    }else if(_password.length < 6 ){
      setState(() {
        password_strength = 1 / 4;
      });
    }else if(_password.length < 8){
      setState(() {
        password_strength = 2 / 4;
      });
    }else{
      if(pass_valid.hasMatch(_password)){
        setState(() {
          password_strength = 4 / 4;
        });
        return true;
      }else{
        setState(() {
          password_strength = 3 / 4;
        });
        return false;
      }
    }
    return false;
  }

  @override
  void dispose() {
    //before going to other screen show statusbar
    SystemChrome.setEnabledSystemUIOverlays(
        [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    super.dispose();
  }



  onPressSignUp() async {
    var name = _nameController.text.toString();
    var email = _emailController.text.toString();
    var password = _passwordController.text.toString();
    var password_confirm = _passwordConfirmController.text.toString();
    var _phone = '+964' + _phoneNumberController.text.toString();

    if (name == "") {
      ToastComponent.showDialog(AppLocalizations.of(context).registration_screen_name_warning, gravity: Toast.center, duration: Toast.lengthLong);
      return;
    } else if (_register_by == 'email' &&( email == "" || !isEmail(email))) {
      ToastComponent.showDialog(AppLocalizations.of(context).registration_screen_email_warning, gravity: Toast.center, duration: Toast.lengthLong);
      return;
    } else if (_register_by == 'phone' && _phone == "") {
      ToastComponent.showDialog(AppLocalizations.of(context).registration_screen_phone_warning, gravity: Toast.center, duration: Toast.lengthLong);
      return;
    } else if (_register_by == 'phone' && _phone.length < 11) {
      ToastComponent.showDialog("رقم الهاتف يجب أن يكون 11 رقم", gravity: Toast.center, duration: Toast.lengthLong);
      return;
    } else if (password == "") {
      ToastComponent.showDialog(AppLocalizations.of(context).registration_screen_password_warning, gravity: Toast.center, duration: Toast.lengthLong);
      return;
    } else if (password_confirm == "") {
      ToastComponent.showDialog(AppLocalizations.of(context).registration_screen_password_confirm_warning, gravity: Toast.center, duration: Toast.lengthLong);
      return;
    } else if (password.length < 8) {
      ToastComponent.showDialog(
          AppLocalizations.of(context).registration_screen_password_length_warning, gravity: Toast.center, duration: Toast.lengthLong);
      return;
    } else if (password != password_confirm) {
      ToastComponent.showDialog(AppLocalizations.of(context).registration_screen_password_match_warning, gravity: Toast.center, duration: Toast.lengthLong);
      return;
    }

    var signupResponse = await AuthRepository().getSignupResponse(
        name,
        _register_by == 'email' ? email : _phone,
        password,
        password_confirm,
        _register_by);

    if (signupResponse.result == false) {
      ToastComponent.showDialog(signupResponse.message, gravity: Toast.center, duration: Toast.lengthLong);
    } else {
      //ToastComponent.showDialog(signupResponse.message, gravity: Toast.center, duration: Toast.lengthLong);
      onPressLogin();

    }
  }

  onPressLogin() async {

    var password = _passwordController.text.toString();
    var _phone_number = '+964' + _phoneNumberController.text.toString();


    var loginResponse = await AuthRepository()
        .getLoginResponse(_phone_number, password);
    if (loginResponse.result == false) {
      ToastComponent.showDialog(loginResponse.message, gravity: Toast.center, duration: Toast.lengthLong);
    } else {

      ToastComponent.showDialog(loginResponse.message, gravity: Toast.center, duration: Toast.lengthLong);
      AuthHelper().setUserData(loginResponse);
      //push norification ends
      onAddressAdd(context);

    }
  }

  onAddressAdd(context) async {
    var address = _addressController.text.toString();
    var postal_code = _postalCodeController.text.toString();

    print("============================"+access_token.$.toString());
    print("============================"+user_id.$.toString());

    if (address == "") {
      ToastComponent.showDialog(
          AppLocalizations.of(context).address_screen_address_warning,
          gravity: Toast.center,
          duration: Toast.lengthLong);
      return;
    }

    // if (_selected_country == null) {
    //   ToastComponent.showDialog(
    //       AppLocalizations.of(context).address_screen_country_warning,
    //       gravity: Toast.center,
    //       duration: Toast.lengthLong);
    //   return;
    // }
    //
    if (_selected_state == null) {
      ToastComponent.showDialog(
          AppLocalizations.of(context).address_screen_state_warning,
          gravity: Toast.center,
          duration: Toast.lengthLong);
      return;
    }

    // if (_selected_city == null) {
    //   ToastComponent.showDialog(
    //       AppLocalizations.of(context).address_screen_city_warning,
    //       gravity: Toast.center,
    //       duration: Toast.lengthLong);
    //   return;
    // }

    if(_selected_state.id == 1730) {
      setState(() {
        _choosed_city = 21793;
        print("++++++++++++++++++++++++++++++"+_choosed_city.toString());
      });
    }else if(_selected_state.id == 1745) {
      setState(() {
        _choosed_city = 48366;
        print("++++++++++++++++++++++++++++++" + _choosed_city.toString());
      });
    }else if(_selected_state.id == 1731) {
      setState(() {
        _choosed_city = 21794;
        print("++++++++++++++++++++++++++++++" + _choosed_city.toString());
      });
    }else if(_selected_state.id == 1732) {
      setState(() {
        _choosed_city = 48358;
        print("++++++++++++++++++++++++++++++" + _choosed_city.toString());
      });
    }else if(_selected_state.id == 1733) {
      setState(() {
        _choosed_city = 48359;
        print("++++++++++++++++++++++++++++++" + _choosed_city.toString());
      });
    }else if(_selected_state.id == 1735) {
      setState(() {
        _choosed_city = 21807;
        print("++++++++++++++++++++++++++++++" + _choosed_city.toString());
      });
    }else if(_selected_state.id == 1736) {
      setState(() {
        _choosed_city = 21809;
        print("++++++++++++++++++++++++++++++" + _choosed_city.toString());
      });
    }else if(_selected_state.id == 1738) {
      setState(() {
        _choosed_city = 48360;
        print("++++++++++++++++++++++++++++++" + _choosed_city.toString());
      });
    }else if(_selected_state.id == 1739) {
      setState(() {
        _choosed_city = 48361;
        print("++++++++++++++++++++++++++++++" + _choosed_city.toString());
      });
    }else if(_selected_state.id == 1740) {
      setState(() {
        _choosed_city = 48362;
        print("++++++++++++++++++++++++++++++" + _choosed_city.toString());
      });
    }else if(_selected_state.id == 1741) {
      setState(() {
        _choosed_city = 48363;
        print("++++++++++++++++++++++++++++++" + _choosed_city.toString());
      });
    }else if(_selected_state.id == 1742) {
      setState(() {
        _choosed_city = 48364;
        print("++++++++++++++++++++++++++++++" + _choosed_city.toString());
      });
    }else if(_selected_state.id == 1743) {
      setState(() {
        _choosed_city = 21844;
        print("++++++++++++++++++++++++++++++" + _choosed_city.toString());
      });
    }else if(_selected_state.id == 1744) {
      setState(() {
        _choosed_city = 48365;
        print("++++++++++++++++++++++++++++++" + _choosed_city.toString());
      });
    }else if(_selected_state.id == 1745) {
      setState(() {
        _choosed_city = 48366;
        print("++++++++++++++++++++++++++++++" + _choosed_city.toString());
      });
    }else if(_selected_state.id == 1746) {
      setState(() {
        _choosed_city = 21858;
        print("++++++++++++++++++++++++++++++" + _choosed_city.toString());
      });
    }else if(_selected_state.id == 1747) {
      setState(() {
        _choosed_city = 21864;
        print("++++++++++++++++++++++++++++++" + _choosed_city.toString());
      });
    }else if(_selected_state.id == 1748) {
      setState(() {
        _choosed_city = 21866;
        print("++++++++++++++++++++++++++++++" + _choosed_city.toString());
      });
    }

    var addressAddResponse = await AddressRepository().getAddressAddResponse(
      address: address,
      country_id: 104,
      state_id: _selected_state.id,
      city_id: _choosed_city,
      postal_code: postal_code,
      phone: _phoneNumberController.text.toString(),
    );

    if (addressAddResponse.result == false) {
      ToastComponent.showDialog(addressAddResponse.message,
          gravity: Toast.center, duration: Toast.lengthLong);
      return;
    }

    ToastComponent.showDialog(addressAddResponse.message,
        gravity: Toast.center, duration: Toast.lengthLong);

    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return Main();
    }));
  }




  onSelectCountryDuringAdd(country) {
    if (_selected_country != null && country.id == _selected_country.id) {
      setState(() {
        _countryController.text = country.name;
      });
      return;
    }
    _selected_country = country;
    _selected_state = null;
    _selected_city = null;
    setState(() {});

    setState(() {
      _countryController.text = country.name;
      _stateController.text = "";
      _cityController.text = "";
    });
  }

  onSelectStateDuringAdd(state) {
    if (_selected_state != null && state.id == _selected_state.id) {
      setState(() {
        _stateController.text = state.name;
      });
      return;
    }
    _selected_state = state;
    _selected_city = null;
    setState(() {
      _stateController.text = state.name;
      _cityController.text = "";
    });

  }

  onSelectCityDuringAdd(city) {
    if (_selected_city != null && city.id == _selected_city.id) {
      setState(() {
        _cityController.text = city.name;
      });
      return;
    }
    _selected_city = city;
    setState(() {
      _cityController.text = city.name;
    });
  }

  @override
  Widget build(BuildContext context) {
    final _screen_height = MediaQuery.of(context).size.height;
    final _screen_width = MediaQuery.of(context).size.width;
    return AuthScreen.buildScreen(context,
        "${AppLocalizations.of(context).registration_screen_join} " + AppConfig.app_name,
        buildBody(context, _screen_width));
  }

  Column buildBody(BuildContext context, double _screen_width) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: _screen_width * (3 / 4),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Text(
                    AppLocalizations.of(context).registration_screen_name,
                    style: TextStyle(
                        color: MyTheme.accent_color,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Container(
                    height: 60,
                    child: TextField(
                      style: TextStyle(
                          color: MyTheme.dark_font_grey
                      ),
                      controller: _nameController,
                      maxLength: 20,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                        helperStyle: TextStyle(
                            color: MyTheme.dark_font_grey
                        ),
                        counterText: "",
                        hintText: "الأسم الكامل",
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
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Text(
                    _register_by == "email" ? AppLocalizations.of(context).registration_screen_email : AppLocalizations.of(context).registration_screen_phone,
                    style: TextStyle(
                        color: MyTheme.accent_color,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                if (_register_by == "email")
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          height: 60,
                          child: TextField(
                            controller: _emailController,
                            autofocus: false,

                            style: TextStyle(color: MyTheme.dark_font_grey),
                            decoration:
                            InputDecorations.buildInputDecoration_1(
                                hint_text: "email@example.com"),
                          ),
                        ),
                        // otp_addon_installed.$
                        //     ? GestureDetector(
                        //         onTap: () {
                        //           setState(() {
                        //             _register_by = "phone";
                        //           });
                        //         },
                        //         child: Text(
                        //           AppLocalizations.of(context).registration_screen_or_register_with_phone,
                        //           style: TextStyle(
                        //               color: MyTheme.accent_color,
                        //               fontStyle: FontStyle.italic,
                        //               decoration:
                        //                   TextDecoration.underline),
                        //         ),
                        //       )
                        //     : Container()
                      ],
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(bottom: 0.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
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
                        //       _register_by = "email";
                        //     });
                        //   },
                        //   child: Text(
                        //     AppLocalizations.of(context).registration_screen_or_register_with_email,
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
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                      AppLocalizations.of(context)
                          .order_details_screen_phone2,
                      style: TextStyle(
                          color: MyTheme.accent_color)),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: [
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
                        controller: _postalCodeController,
                        keyboardType: TextInputType.numberWithOptions(
                            signed: true, decimal: true),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(left: 95),
                          helperStyle: TextStyle(
                              color: MyTheme.dark_font_grey
                          ),
                          counterText: "",
                          hintText: "07XX XXX XXXX",
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
                  ),

                  // Container(
                  //   height: 40,
                  //   child: TextField(
                  //     controller: _postalCodeController,
                  //     autofocus: false,
                  //     decoration: buildAddressInputDecoration(context, AppLocalizations.of(context)
                  //         .order_details_screen_phone2),
                  //   ),
                  // ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Text(
                    AppLocalizations.of(context).registration_screen_password,
                    style: TextStyle(
                        color: MyTheme.accent_color,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Stack(
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
                            validator: (value){
                              // return value.length < 8 ? 'يجب أن تكون 8 أرقام على الأقل' : null;
                              if(value.length <= 7) {
                                return 'يجب أن تكون 8 أرقام أو أحرف على الأقل';
                              }else {
                                return null;
                              }
                              // if(value.isEmpty){
                              //   return null;
                              // }else{
                              //   //call function to check password
                              //   bool result = validatePassword(value);
                              //   if(result){
                              //     // create account event
                              //     return null;
                              //   }else{
                              //     return "يجب أن تحتوي على أحرف وأرقام ورموز";
                              //   }
                              // }
                            },
                            onChanged: (value){
                              _formKey.currentState.validate();
                            },
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
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Text(
                    AppLocalizations.of(context).registration_screen_retype_password,
                    style: TextStyle(
                        color: MyTheme.accent_color,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Stack(
                    children: [
                      Container(
                          height: 60,
                          child:  TextField(
                            obscureText: _obscureText,
                            style: TextStyle(
                                color: MyTheme.dark_font_grey
                            ),
                            controller: _passwordConfirmController,
                            maxLength: 35,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: 16),
                              helperStyle: TextStyle(
                                  color: MyTheme.dark_font_grey
                              ),
                              counterText: "",
                              hintText: "• • • • • • • •",
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
                          )

                        // TextField(
                        //   controller: _passwordConfirmController,
                        //   autofocus: false,
                        //   obscureText: true,
                        //   enableSuggestions: false,
                        //   autocorrect: false,
                        //   style: TextStyle(color: Theme.of(context).colorScheme.outline),
                        //   decoration: InputDecorations.buildInputDecoration_1(
                        //       hint_text: "• • • • • • • •"),
                        // ),
                      ),

                      Align(
                        alignment: app_language_rtl.$ ? Alignment.centerLeft : Alignment.centerRight,
                        child: IconButton(
                            onPressed: _toggle,
                            icon: new Icon(_obscureText ? Icons.visibility_off_outlined : Icons.remove_red_eye_outlined, color: MyTheme.dark_font_grey,)),
                      ),
                    ],
                  ),
                ),
                // Padding(
                //   padding: const EdgeInsets.all(12.0),
                //   child: LinearProgressIndicator(
                //     semanticsLabel: "test",
                //     value: password_strength,
                //     backgroundColor: Colors.grey[300],
                //     minHeight: 5,
                //     color: password_strength <= 1 / 4
                //         ? Colors.red
                //         : password_strength == 2 / 4
                //         ? Colors.yellow
                //         : password_strength == 3 / 4
                //         ? Colors.blue
                //         : Colors.green,
                //   ),
                // ),
                Divider(
                  height: 15,
                  thickness: 1,
                ),


                // Padding(
                //   padding: const EdgeInsets.only(bottom: 8.0),
                //   child: Text(
                //       "${AppLocalizations.of(context).address_screen_country} *",
                //       style: TextStyle(
                //           color: MyTheme.font_grey, fontSize: 12)),
                // ),
                // Padding(
                //   padding: const EdgeInsets.only(bottom: 16.0),
                //   child: Container(
                //     height: 60,
                //     child: TypeAheadField(
                //       suggestionsCallback: (name) async {
                //         var countryResponse = await AddressRepository()
                //             .getCountryList(name: "Iraq");
                //         return countryResponse.countries;
                //       },
                //       loadingBuilder: (context) {
                //         return Container(
                //           height: 50,
                //           child: Center(
                //               child: Text(
                //                   AppLocalizations.of(context)
                //                       .address_screen_loading_countries,
                //                   style: TextStyle(
                //                       color: MyTheme.medium_grey))),
                //         );
                //       },
                //       itemBuilder: (context, country) {
                //         //print(suggestion.toString());
                //         return ListTile(
                //           dense: true,
                //           title: Text(
                //             country.name,
                //             style: TextStyle(color: MyTheme.font_grey),
                //           ),
                //         );
                //       },
                //       noItemsFoundBuilder: (context) {
                //         return Container(
                //           height: 50,
                //           child: Center(
                //               child: Text(
                //                   AppLocalizations.of(context)
                //                       .address_screen_no_country_available,
                //                   style: TextStyle(
                //                       color: MyTheme.medium_grey))),
                //         );
                //       },
                //       onSuggestionSelected: (country) {
                //         onSelectCountryDuringAdd(country);
                //       },
                //       textFieldConfiguration: TextFieldConfiguration(
                //         onTap: () {},
                //         //autofocus: true,
                //         controller: _countryController,
                //         onSubmitted: (txt) {
                //           // keep this blank
                //         },
                //         decoration: InputDecoration(
                //           contentPadding: EdgeInsets.symmetric(horizontal: 16),
                //           helperStyle: TextStyle(
                //               color: Theme.of(context).colorScheme.outline
                //           ),
                //           counterText: "",
                //           hintText: AppLocalizations.of(context)
                //               .address_screen_enter_country,
                //           prefixStyle: TextStyle(color: Colors.transparent),
                //           enabledBorder: OutlineInputBorder(
                //             borderSide: BorderSide(
                //                 color: MyTheme.accent_color.withOpacity(.3),
                //                 width: 1),
                //             borderRadius: const BorderRadius.all(
                //               const Radius.circular(8.0),
                //             ),
                //           ),
                //           focusedBorder: OutlineInputBorder(
                //             borderSide: BorderSide(
                //                 color: MyTheme.accent_color,
                //                 width: 0.5),
                //             borderRadius: const BorderRadius.all(
                //               const Radius.circular(6.0),
                //             ),
                //           ),
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                      "${AppLocalizations.of(context).address_screen_state} *",
                      style: TextStyle(
                          color: MyTheme.accent_color)),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Container(
                    height: 40,
                    child: TypeAheadField(
                      suggestionsCallback: (name) async {
                        // if (_selected_country == null) {
                        //   var stateResponse = await AddressRepository()
                        //       .getStateListByCountry(); // blank response
                        //   return stateResponse.states;
                        // }
                        var stateResponse = await AddressRepository()
                            .getStateListByCountry(
                            country_id: 104,
                           );
                        return stateResponse.states;
                      },
                      loadingBuilder: (context) {
                        return Container(
                          height: 50,
                          child: Center(
                              child: Text(
                                  AppLocalizations.of(context)
                                      .address_screen_loading_states,
                                  style: TextStyle(
                                      color: MyTheme.medium_grey))),
                        );
                      },
                      itemBuilder: (context, state) {
                        //print(suggestion.toString());
                        return ListTile(
                          dense: true,
                          title: Text(
                            state.name,
                            style: TextStyle(color: MyTheme.font_grey),
                          ),
                        );
                      },
                      noItemsFoundBuilder: (context) {
                        return Container(
                          height: 50,
                          child: Center(
                              child: Text(
                                  AppLocalizations.of(context)
                                      .address_screen_no_state_available,
                                  style: TextStyle(
                                      color: MyTheme.medium_grey))),
                        );
                      },
                      onSuggestionSelected: (state) {
                        onSelectStateDuringAdd(state);
                      },
                      textFieldConfiguration: TextFieldConfiguration(
                        onTap: () {},
                        //autofocus: true,
                        controller: _stateController,
                        onSubmitted: (txt) {
                          // _searchKey = txt;
                          // setState(() {});
                          // _onSearchSubmit();
                        },
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 16),
                          helperStyle: TextStyle(
                              color: MyTheme.dark_font_grey
                          ),
                          counterText: "",
                          hintText: AppLocalizations.of(context)
                              .address_screen_enter_state,
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
                    ),
                  ),
                ),
                // Padding(
                //   padding: const EdgeInsets.only(bottom: 8.0),
                //   child: Text(
                //       "${AppLocalizations.of(context).address_screen_city} *",
                //       style: TextStyle(
                //           color: MyTheme.accent_color)),
                // ),
                // Padding(
                //   padding: const EdgeInsets.only(bottom: 16.0),
                //   child: Container(
                //     height: 40,
                //     child: TypeAheadField(
                //       suggestionsCallback: (name) async {
                //         if (_selected_state == null) {
                //           var cityResponse = await AddressRepository()
                //               .getCityListByState(); // blank response
                //           return cityResponse.cities;
                //         }
                //         var cityResponse = await AddressRepository()
                //             .getCityListByState(
                //             state_id: _selected_state.id, name: name);
                //         return cityResponse.cities;
                //       },
                //       loadingBuilder: (context) {
                //         return Container(
                //           height: 50,
                //           child: Center(
                //               child: Text(
                //                   AppLocalizations.of(context)
                //                       .address_screen_loading_cities,
                //                   style: TextStyle(
                //                       color: MyTheme.medium_grey))),
                //         );
                //       },
                //       itemBuilder: (context, city) {
                //         //print(suggestion.toString());
                //         return ListTile(
                //           dense: true,
                //           title: Text(
                //             city.name,
                //             style: TextStyle(color: MyTheme.font_grey),
                //           ),
                //         );
                //       },
                //       noItemsFoundBuilder: (context) {
                //         return Container(
                //           height: 50,
                //           child: Center(
                //               child: Text(
                //                   AppLocalizations.of(context)
                //                       .address_screen_no_city_available,
                //                   style: TextStyle(
                //                       color: MyTheme.medium_grey))),
                //         );
                //       },
                //       onSuggestionSelected: (city) {
                //         onSelectCityDuringAdd(city);
                //       },
                //       textFieldConfiguration: TextFieldConfiguration(
                //         onTap: () {},
                //         //autofocus: true,
                //         controller: _cityController,
                //         onSubmitted: (txt) {
                //           // keep blank
                //         },
                //         decoration: InputDecoration(
                //           contentPadding: EdgeInsets.symmetric(horizontal: 16),
                //           helperStyle: TextStyle(
                //               color: Theme.of(context).colorScheme.outline
                //           ),
                //           counterText: "",
                //           hintText: AppLocalizations.of(context)
                //               .address_screen_enter_city,
                //           prefixStyle: TextStyle(color: Colors.transparent),
                //           enabledBorder: OutlineInputBorder(
                //             borderSide: BorderSide(
                //                 color: MyTheme.accent_color.withOpacity(.3),
                //                 width: 1),
                //             borderRadius: const BorderRadius.all(
                //               const Radius.circular(8.0),
                //             ),
                //           ),
                //           focusedBorder: OutlineInputBorder(
                //             borderSide: BorderSide(
                //                 color: MyTheme.accent_color,
                //                 width: 0.5),
                //             borderRadius: const BorderRadius.all(
                //               const Radius.circular(6.0),
                //             ),
                //           ),
                //         ),
                //       ),
                //     ),
                //   ),
                // ),


                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                      "${AppLocalizations.of(context).address_screen_address} *",
                      style: TextStyle(
                          color: MyTheme.accent_color)),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Container(
                    height: 55,
                    child: TextField(
                      controller: _addressController,
                      autofocus: false,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                        helperStyle: TextStyle(
                            color: MyTheme.dark_font_grey
                        ),
                        counterText: "",
                        hintText: AppLocalizations.of(context)
                            .address_screen_enter_address,
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
                  ),
                ),





                // Padding(
                //   padding: const EdgeInsets.only(top: 20.0),
                //   child: Row(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: [
                //       Container(
                //           height: 15,
                //           width: 15,
                //           margin: EdgeInsets.only(left: app_language_rtl.$ ? 6 : 0,right: app_language_rtl.$ ? 0 : 6,),
                //           child: Checkbox(
                //             checkColor: MyTheme.accent_color,
                //             shape: RoundedRectangleBorder(
                //                 borderRadius: BorderRadius.circular(6)),
                //               value: _isAgree, onChanged: (newValue){
                //               _isAgree = newValue;
                //               setState((){});
                //           }),),
                //
                //       Padding(
                //         padding: const EdgeInsets.only(left: 8.0),
                //         child: Container(
                //           width: DeviceInfo(context).width-130,
                //           child: RichText(
                //             maxLines: 2,
                //               text: TextSpan(
                //             style: TextStyle(color: MyTheme.font_grey,fontSize: 12),
                //            children: [
                //              TextSpan(
                //               text: AppLocalizations.of(context).i_agree_to_the,
                //              ),
                //
                //              TextSpan(
                //                recognizer: TapGestureRecognizer()..onTap=(){
                //                  Navigator.push(context, MaterialPageRoute(
                //                      builder: (context)=>
                //                          ContentPage(slug: "terms", title: "Terms Conditions"),
                //                          // CommonWebviewScreen(page_name: "Terms Conditions",url: "${AppConfig.RAW_BASE_URL}/mobile-page/terms",)
                //                  ));
                //
                //                },
                //                  style: TextStyle(color: MyTheme.accent_color),
                //               text: AppLocalizations.of(context).terms_conditions,
                //              ),
                //              TextSpan(
                //               text: app_language_rtl.$ ? " و " :" & ",
                //              ),
                //              TextSpan(
                //                  recognizer: TapGestureRecognizer()..onTap=(){
                //                    Navigator.push(context, MaterialPageRoute(builder: (context)=>
                //                        ContentPage(slug: "privacy-policy", title: "Privacy Policy"),
                //                       // CommonWebviewScreen(page_name: "Privacy Policy",url: "${AppConfig.RAW_BASE_URL}/mobile-page/privacy-policy",)
                //                    ));
                //
                //
                //                  },
                //               text: AppLocalizations.of(context).privacy_policy,
                //                  style: TextStyle(color: MyTheme.accent_color),
                //
                //              )
                //            ]
                //           )),
                //         ),
                //       )
                //     ],
                //   ),
                // ),

                Padding(
                  padding: const EdgeInsets.only(top: 30.0),
                  child: Container(
                    height: 45,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        color: MyTheme.accent_color,
                        borderRadius: BorderRadius.circular(12)
                    ),
                    child: TextButton(
                      // minWidth: MediaQuery.of(context).size.width,
                      // disabledColor: MyTheme.grey_153,
                      // //height: 50,
                      // color: MyTheme.accent_color,
                      // shape: RoundedRectangleBorder(
                      //     borderRadius: const BorderRadius.all(
                      //         Radius.circular(6.0))),
                      child: Text(
                        AppLocalizations.of(context).registration_screen_register_sign_up,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600),
                      ),
                      onPressed: _isAgree? () {
                        // password_strength != 1 ? null :
                        onPressSignUp();
                      }:null,
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                          child: Text(
                            AppLocalizations.of(context).registration_screen_already_have_account,
                            style: TextStyle(
                                color: MyTheme.font_grey, fontSize: 12),
                          )),
                      SizedBox(width: 10,),

                      InkWell(
                        child: Text(
                          AppLocalizations.of(context).registration_screen_log_in,
                          style: TextStyle(
                              color:MyTheme.accent_color,
                              fontSize: 14,
                              fontWeight: FontWeight.w600),
                        ),
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                                return Login();
                              }));
                        },
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  InputDecoration buildAddressInputDecoration(BuildContext context,hintText) {
    return InputDecoration(
      filled: true,
      fillColor: MyTheme.light_grey,
      hintText: hintText,
      hintStyle: TextStyle(fontSize: 12.0, color: MyTheme.textfield_grey),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: MyTheme.noColor, width: 0.5),
        borderRadius: const BorderRadius.all(
          const Radius.circular(8.0),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: MyTheme.noColor, width: 1.0),
        borderRadius: const BorderRadius.all(
          const Radius.circular(8.0),
        ),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16),
      counterText: "",
    );
  }

}