import 'package:editing_house/app_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:editing_house/data_model/language_list_response.dart';
import 'package:editing_house/helpers/shared_value_helper.dart';

class LanguageRepository {
  Future<LanguageListResponse> getLanguageList() async {
    Uri url = Uri.parse(
        "${AppConfig.BASE_URL}/languages");
    final response = await http.get(url,headers: {
      "App-Language": app_language.$,
    }
    );
    //print(response.body.toString());
    return languageListResponseFromJson(response.body);
  }


}
