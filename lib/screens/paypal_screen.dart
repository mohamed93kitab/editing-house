import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:editing_house/custom/toast_component.dart';
import 'package:toast/toast.dart';
import 'dart:convert';
import 'package:editing_house/repositories/payment_repository.dart';
import 'package:editing_house/my_theme.dart';
//import 'package:webview_flutter/webview_flutter.dart';
import 'package:editing_house/screens/order_list.dart';
import 'package:editing_house/screens/wallet.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:editing_house/helpers/shared_value_helper.dart';


class PaypalScreen extends StatefulWidget {
  double amount;
  String payment_type;
  String payment_method_key;

  PaypalScreen(
      {Key key,
      this.amount = 0.00,
      this.payment_type = "",
      this.payment_method_key = ""})
      : super(key: key);

  @override
  _PaypalScreenState createState() => _PaypalScreenState();
}

class _PaypalScreenState extends State<PaypalScreen> {
  int _combined_order_id = 0;
  bool _order_init = false;
  String _initial_url = "";
  bool _initial_url_fetched = false;

  // WebViewController _webViewController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if (widget.payment_type == "cart_payment") {
      createOrder();
    }

    if (widget.payment_type != "cart_payment") {
      // on cart payment need proper order id
      getSetInitialUrl();
    }
  }

  createOrder() async {
    var orderCreateResponse = await PaymentRepository()
        .getOrderCreateResponse(widget.payment_method_key);

    if (orderCreateResponse.result == false) {
      ToastComponent.showDialog(orderCreateResponse.message, gravity: Toast.center, duration: Toast.lengthLong);
      Navigator.of(context).pop();
      return;
    }

    _combined_order_id = orderCreateResponse.combined_order_id;
    _order_init = true;
    setState(() {});

    getSetInitialUrl();
  }

  getSetInitialUrl() async {
    var paypalUrlResponse = await PaymentRepository().getPaypalUrlResponse(
        widget.payment_type, _combined_order_id, widget.amount);

    if (paypalUrlResponse.result == false) {
      ToastComponent.showDialog(paypalUrlResponse.message, gravity: Toast.center, duration: Toast.lengthLong);
      Navigator.of(context).pop();
      return;
    }

    _initial_url = paypalUrlResponse.url;
    _initial_url_fetched = true;


    setState(() {});

    print(_initial_url);
    print(_initial_url_fetched);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: app_language_rtl.$ ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: buildAppBar(context),
        body: buildBody(),
      ),
    );
  }

  // void getData() {
  //   _webViewController
  //       .evaluateJavascript("document.body.innerText")
  //       .then((data) {
  //     var decodedJSON = jsonDecode(data);
  //     Map<String, dynamic> responseJSON = jsonDecode(decodedJSON);
  //     //print(data.toString());
  //     if (responseJSON["result"] == false) {
  //       Toast.show(responseJSON["message"],
  //           duration: Toast.lengthLong, gravity: Toast.center);
  //       Navigator.pop(context);
  //     } else if (responseJSON["result"] == true) {
  //       Toast.show(responseJSON["message"],
  //           duration: Toast.lengthLong, gravity: Toast.center);
  //
  //       if (widget.payment_type == "cart_payment") {
  //         Navigator.push(context, MaterialPageRoute(builder: (context) {
  //           return OrderList(from_checkout: true);
  //         }));
  //       } else if (widget.payment_type == "wallet_payment") {
  //         Navigator.push(context, MaterialPageRoute(builder: (context) {
  //           return Wallet(from_recharge: true);
  //         }));
  //       }
  //     }
  //   });
  // }

  buildBody() {
    if (_order_init == false &&
        _combined_order_id == 0 &&
        widget.payment_type == "cart_payment") {
      return Container(
        child: Center(
          child: Text(AppLocalizations.of(context).common_creating_order),
        ),
      );
    } else if (_initial_url_fetched == false) {
      return Container(
        child: Center(
          child: Text(AppLocalizations.of(context).paypal_screen_fetching_paypal_url),
        ),
      );
    } else {
      return SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          // child: WebView(
          //   debuggingEnabled: false,
          //   javascriptMode: JavascriptMode.unrestricted,
          //   onWebViewCreated: (controller) {
          //     _webViewController = controller;
          //     _webViewController.loadUrl(_initial_url);
          //   },
          //   onWebResourceError: (error) {},
          //   onPageFinished: (page) {
          //     //print(page.toString());
          //
          //     if (page.contains("/paypal/payment/done")) {
          //       getData();
          //     } else if (page.contains("/paypal/payment/cancel")) {
          //       ToastComponent.showDialog("Payment cancelled", gravity: Toast.center, duration: Toast.lengthLong);
          //       Navigator.of(context).pop();
          //       return;
          //     }
          //   },
          // ),
        ),
      );
    }
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
backgroundColor: Colors.white,
      centerTitle: true,
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(CupertinoIcons.arrow_left, color: MyTheme.dark_grey),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      title: Text(
          AppLocalizations.of(context).paypal_screen_pay_with_paypal,
        style: TextStyle(fontSize: 16, color: MyTheme.accent_color),
      ),
      elevation: 0.0,
      titleSpacing: 0,
    );
  }
}
