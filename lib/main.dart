import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:editing_house/helpers/shared_value_helper.dart';
import 'package:editing_house/other_config.dart';
import 'package:editing_house/screens/product_details.dart';
import 'package:editing_house/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:editing_house/my_theme.dart';
import 'package:shared_value/shared_value.dart';
import 'dart:async';
import 'app_config.dart';
import 'package:editing_house/services/push_notification_service.dart';
import 'package:one_context/one_context.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:editing_house/providers/locale_provider.dart';
import 'lang_config.dart';
import 'package:firebase_core/firebase_core.dart';


main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);


  // AddonsHelper().setAddonsData();
  // BusinessSettingHelper().setBusinessSettingData();
  // app_language.load();
  // app_mobile_language.load();
  // app_language_rtl.load();
  //
  // access_token.load().whenComplete(() {
  //   AuthHelper().fetch_and_set();
  // });

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
  ));

  runApp(
    SharedValue.wrapApp(
      MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {


  @override
  void initState() {
    super.initState();
    initOnesignal();


    Future.delayed(Duration.zero).then((value) async{

      // Firebase.initializeApp().then((value){
      //   if (OtherConfig.USE_PUSH_NOTIFICATION) {
      //     Future.delayed(Duration(milliseconds: 10), () async {
      //       PushNotificationService().initialise();
      //     });
      //   }
      // });

    });

  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ],
        child: Consumer<LocaleProvider>(builder: (context, provider, snapshot) {
          return MaterialApp(
            builder: OneContext().builder,
            navigatorKey: OneContext().navigator.key,
            title: AppConfig.app_name,
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primaryColor: MyTheme.white,
              scaffoldBackgroundColor: MyTheme.white,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              accentColor: MyTheme.accent_color,
              /*textTheme: TextTheme(
              bodyText1: TextStyle(),
              bodyText2: TextStyle(fontSize: 12.0),
            )*/
              //
              // the below code is getting fonts from http
              textTheme: app_language_rtl.$ ? GoogleFonts.cairoTextTheme(textTheme).copyWith(
                bodyText1:
                    GoogleFonts.cairo(textStyle: textTheme.bodyText1),
                bodyText2: GoogleFonts.cairo(
                    textStyle: textTheme.bodyText2, fontSize: 12),
              ) : GoogleFonts.publicSansTextTheme(textTheme).copyWith(
                bodyText1:
                GoogleFonts.publicSans(textStyle: textTheme.bodyText1),
                bodyText2: GoogleFonts.publicSans(
                    textStyle: textTheme.bodyText2, fontSize: 12),
              ),
            ),
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              AppLocalizations.delegate,
            ],
            locale: provider.locale,
            supportedLocales: LangConfig().supportedLocales(),
            home: SplashScreen(),
            // home: Splash(),
          );
        }));
  }

  void initOnesignal() {
    //Remove this method to stop OneSignal Debugging
    OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);
    OneSignal.shared.setAppId("b8ab303f-5d27-4fed-974b-4c2b62dc1a20");
    // The promptForPushNotificationsWithUserResponse function will show the iOS push notification prompt. We recommend removing the following code and instead using an In-App Message to prompt for notification permission
    OneSignal.shared.promptUserForPushNotificationPermission().then((accepted) {
      print("Accepted permission: $accepted");
    });
    OneSignal.shared.setNotificationWillShowInForegroundHandler(
            (OSNotificationReceivedEvent event) {
          // Will be called whenever a notification is received in foreground
          // Display Notification, pass null param for not displaying the notification
          event.complete(event.notification);
        });
    OneSignal.shared
        .setNotificationOpenedHandler((OSNotificationOpenedResult result) {
      // Will be called whenever a notification is opened/button pressed.
    });
    OneSignal.shared.setPermissionObserver((OSPermissionStateChanges changes) {
      // Will be called whenever the permission changes
      // (ie. user taps Allow on the permission prompt in iOS)
    });
    OneSignal.shared
        .setSubscriptionObserver((OSSubscriptionStateChanges changes) {
      // Will be called whenever the subscription changes
      // (ie. user gets registered with OneSignal and gets a user ID)
    });
    OneSignal.shared.setEmailSubscriptionObserver(
            (OSEmailSubscriptionStateChanges emailChanges) {
          // Will be called whenever then user's email subscription changes
          // (ie. OneSignal.setEmail(email) is called and the user gets registered
        });

    OneSignal.shared
        .setNotificationOpenedHandler((OSNotificationOpenedResult result) {
      var id = result.notification.additionalData['product_id'];

      print("================================================="+id);
      if(id != null) {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => ProductDetails(id: id,)));
      }

    });


  }
}
