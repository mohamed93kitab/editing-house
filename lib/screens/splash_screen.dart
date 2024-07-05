import 'package:editing_house/app_config.dart';
import 'package:editing_house/custom/device_info.dart';
import 'package:editing_house/helpers/addons_helper.dart';
import 'package:editing_house/helpers/auth_helper.dart';
import 'package:editing_house/helpers/business_setting_helper.dart';
import 'package:editing_house/helpers/shared_value_helper.dart';
import 'package:editing_house/my_theme.dart';
import 'package:editing_house/providers/locale_provider.dart';
import 'package:editing_house/screens/main.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  PackageInfo _packageInfo = PackageInfo(
    appName: AppConfig.app_name,
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );

  Future<void> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initPackageInfo();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
        future: getSharedValueHelperData(),
        builder: (context, snapshot) {
          if(snapshot.hasData){
            Future.delayed(Duration(seconds: 3)).then((value) {
              Provider.of<LocaleProvider>(context,listen: false).setLocale(app_mobile_language.$);
              Navigator.pushAndRemoveUntil(context,
                  MaterialPageRoute(builder: (context) {
                    return Main(go_back: false,);
                  },
                  ),(route)=>false,);
            }
            );

          }
          return splashScreen();
        }
    );
  }

  Widget splashScreen() {
    return Container(
      width: DeviceInfo(context).height,
      height: DeviceInfo(context).height,
      color:  MyTheme.splash_screen_color,
      child: InkWell(
        child: Stack(

          // mainAxisAlignment: MainAxisAlignment.start,
          // crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // CircleAvatar(
            //   backgroundColor: Colors.transparent,
            //   child: Hero(
            //     tag: "backgroundImageInSplash",
            //     child: Container(
            //       child: Image.asset(
            //           "assets/splash_login_registration_background_image.png"),
            //     ),
            //   ),
            //   radius: 140.0,
            // ),
            Positioned.fill(
              top: DeviceInfo(context).height/2-102,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Hero(
                      tag: "splashscreenImage",
                      child: Container(
                        height: 162,
                        width: 162,
                       // padding: EdgeInsets.symmetric(horizontal: 12,vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color:  Colors.transparent,
                            width: 1
                          ),
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(8)
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.asset(
                              "assets/splash_screen_logo.png",
                            filterQuality: FilterQuality.low,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5.0),
                    child: Text(
                      AppConfig.app_name,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.0,
                          color: MyTheme.accent_color),
                    ),
                  ),
                  Text(
                    "V " + _packageInfo.version,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.0,
                        color: MyTheme.white,
                    ),
                  ),
                ],
              ),
            ),



            Positioned.fill(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 51.0),
                  child: Text(
                    AppConfig.copyright_text,
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 10.0,
                      color: MyTheme.white,
                    ),
                  ),
                ),
              ),
            ),
/*
            Padding(
              padding: const EdgeInsets.only(top: 120.0),
              child: Container(
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[

                    ],
                  )),
            ),*/
          ],
        ),
      ),
    );
  }

  Future<String>  getSharedValueHelperData()async{
    access_token.load().whenComplete(() {
      AuthHelper().fetch_and_set();
    });
    AddonsHelper().setAddonsData();
    BusinessSettingHelper().setBusinessSettingData();
    await app_language.load();
    await app_mobile_language.load();
    await app_language_rtl.load();

    // print("new splash screen ${app_mobile_language.$}");
    // print("new splash screen app_language_rtl ${app_language_rtl.$}");

    return app_mobile_language.$;

  }
}
