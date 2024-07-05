import 'dart:async';
import 'dart:io';

import 'package:editing_house/custom/common_functions.dart';
import 'package:editing_house/my_theme.dart';
import 'package:editing_house/presenter/bottom_appbar_index.dart';
import 'package:editing_house/presenter/cart_counter.dart';
import 'package:editing_house/repositories/cart_repository.dart';
import 'package:editing_house/screens/cart.dart';
import 'package:editing_house/screens/category_list.dart';
import 'package:editing_house/screens/home.dart';
import 'package:editing_house/screens/login.dart';
import 'package:editing_house/screens/profile.dart';
import 'package:editing_house/screens/wishlist.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:editing_house/helpers/shared_value_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:badges/badges.dart' as badges;
import 'package:route_transitions/route_transitions.dart';

import 'filter.dart';

class Main extends StatefulWidget {
  Main({Key key, go_back = true}) : super(key: key);

  bool go_back;

  @override
  _MainState createState() => _MainState();
}

class _MainState extends State<Main> {
  int _currentIndex = 0;
  //int _cartCount = 0;

  BottomAppbarIndex bottomAppbarIndex = BottomAppbarIndex();


  var _children = [];


  void onTapped(int i) {
    if (!is_logged_in.$ && (i == 4 || i == 2)) {
      
      Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
      return;
    }

    if(i== 4){
      app_language_rtl.$ ?slideLeftWidget(newPage: Profile(), context: context):slideRightWidget(newPage: Profile(), context: context);
      return;
    }

    setState(() {
      _currentIndex = i;
    });
    //print("i$i");
  }


  void initState() {
    _children = [
      Home(),
      CategoryList(
        is_base_category: true,
      ),
      Cart(has_bottomnav: false,),
      Filter(),
      Profile(),
    ];
    // TODO: implement initState
    //re appear statusbar in case it was not there in the previous page
    SystemChrome.setEnabledSystemUIOverlays(
        [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    super.initState();
  }

  @override
  Widget build(BuildContext context){
    return WillPopScope(
      onWillPop: () async {
        //print("_currentIndex");
        if (_currentIndex != 0) {
          setState(() {
            _currentIndex = 0;
          });
          return false;
        } else {
          CommonFunctions(context).appExitDialog();
        }
        return widget.go_back;
      },
      child: Directionality(
        textDirection:
            app_language_rtl.$ ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(
          extendBody: true,
          body: _children[_currentIndex],
          bottomNavigationBar: BottomAppBar(
            color: Colors.transparent,

            clipBehavior: Clip.antiAlias,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
              child: SizedBox(
                height: 84,
                child: BottomNavigationBar(
                  type: BottomNavigationBarType.fixed,
                  onTap: onTapped,
                  currentIndex:_currentIndex,
                  backgroundColor: Colors.white.withOpacity(0.95),
                  unselectedItemColor: Color.fromRGBO(168, 175, 179, 1),
                  selectedItemColor: MyTheme.accent_color,
                  selectedLabelStyle: TextStyle(fontWeight:FontWeight.w700,color: MyTheme.accent_color,fontSize: 12 ),
                  unselectedLabelStyle: TextStyle(fontWeight:FontWeight.w400,color:Color.fromRGBO(168, 175, 179, 1),fontSize: 12 ),

                  items: [
                    BottomNavigationBarItem(
                        icon: Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Image.asset(
                            "assets/home.png",
                            color: _currentIndex == 0
                                ? Theme.of(context).accentColor
                                : Color.fromRGBO(153, 153, 153, 1),
                            height: 16,
                          ),
                        ),
                        label:  AppLocalizations.of(context)
                            .main_screen_bottom_navigation_home),
                    BottomNavigationBarItem(
                        icon: Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Image.asset(
                            "assets/categories.png",
                            color: _currentIndex == 1
                                ? Theme.of(context).accentColor
                                : Color.fromRGBO(153, 153, 153, 1),
                            height: 16,
                          ),
                        ),
                        label: AppLocalizations.of(context)
                            .main_screen_bottom_navigation_categories),

                    BottomNavigationBarItem(
                      icon: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: MyTheme.accent_color,
                          borderRadius: BorderRadius.circular(33)
                        ),
                        padding: const EdgeInsets.all(15.0),
                        child: Image.asset(
                          "assets/cart.png",
                          color: MyTheme.white,
                          height: 16,
                        ),
                      ),
                      label: "",
                    ),

                    BottomNavigationBarItem(
                      icon: Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Image.asset(
                          "assets/search.png",
                          color: _currentIndex == 3
                              ? Theme.of(context).accentColor
                              : Color.fromRGBO(153, 153, 153, 1),
                          height: 16,
                        ),
                      ),
                      label: AppLocalizations.of(context)
                          .home_screen_search,
                    ),


                    BottomNavigationBarItem(
                      icon: Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Image.asset(
                          "assets/profile.png",
                          color: _currentIndex == 4
                              ? Theme.of(context).accentColor
                              : Color.fromRGBO(153, 153, 153, 1),
                          height: 16,
                        ),
                      ),
                      label: AppLocalizations.of(context)
                          .main_screen_bottom_navigation_profile,
                    ),



                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }


}
