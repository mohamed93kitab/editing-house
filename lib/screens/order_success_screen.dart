import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lottie/lottie.dart';

import '../my_theme.dart';
import 'order_list.dart';

class OrderSuccessScreen extends StatefulWidget {
  const OrderSuccessScreen({Key key}) : super(key: key);

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return null;
      },
      child: Scaffold(
        body: Container(
            alignment: Alignment.center,
            height: MediaQuery.of(context).size.height - 90,
            child:  Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset('assets/success.json', width: MediaQuery.of(context).size.width * .8),
                Text(AppLocalizations.of(context).order_placed_successfully, style: TextStyle(
                    fontSize: 24,
                    color: MyTheme.accent_color,
                  fontWeight: FontWeight.bold
                ),),

                // Text(
                //   AppLocalizations.of(context).order_has_been_sent_successfully,
                //   style: TextStyle(
                //       fontSize: 20,
                //       color: MyTheme.accent_color
                //   ),
                // ),

                SizedBox(
                  height: 26,
                ),

                Text(
                  AppLocalizations.of(context).thank_you_for_shopping,
                  style: TextStyle(
                      fontSize: 20,
                      color: MyTheme.accent_color
                  ),
                ),
                SizedBox(
                  height: 16,
                ),

                Text(
                  AppLocalizations.of(context).your_order_is_being_processed,
                  style: TextStyle(
                      fontSize: 20,
                      color: MyTheme.accent_color
                  ),
                ),

                SizedBox(
                  height: 76,
                ),



                Container(
                  child: TextButton(
                    style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        minimumSize: Size(50, 30),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        backgroundColor: MyTheme.accent_color,
                        alignment: Alignment.center
                    ),
                    onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => OrderList(from_checkout: true,))),


                    child: Text(AppLocalizations.of(context).continue_to_orders, style: TextStyle(
                        color: MyTheme.white
                    ),),

                  ),

                  margin: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  padding: EdgeInsets.symmetric(vertical: 8),
                )
              ],
            )),

        //Lottie.network("https://assets10.lottiefiles.com/packages/lf20_rtxcgnqq.json"),
      ),
    );
  }
}
