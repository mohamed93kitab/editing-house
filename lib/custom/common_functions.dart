import 'dart:io';
import 'package:editing_house/helpers/shared_value_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CommonFunctions{
  BuildContext context;

  CommonFunctions(this.context);

  appExitDialog() {
    showDialog(
        context: context,
        builder: (context) => Directionality(
          textDirection: app_language_rtl.$ ? TextDirection.rtl : TextDirection.ltr,
          child: AlertDialog(
            content: Text(AppLocalizations.of(context).home_screen_close_app),
            actions: [
              TextButton(
                  onPressed: () {
                    Platform.isAndroid ? SystemNavigator.pop() : exit(0);
                  },
                  child: Text(AppLocalizations.of(context).common_yes)),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(AppLocalizations.of(context).common_no)),
            ],
          ),
        ));
  }


}