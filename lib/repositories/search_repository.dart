import 'package:editing_house/app_config.dart';
import 'package:http/http.dart' as http;

import 'package:editing_house/data_model/search_suggestion_response.dart';
import 'package:editing_house/helpers/shared_value_helper.dart';

class SearchRepository {
  Future<List<SearchSuggestionResponse>> getSearchSuggestionListResponse(
      {query_key = "", type = "product"}) async {
    Uri url = Uri.parse(
        "${AppConfig.BASE_URL}/get-search-suggestions?query_key=$query_key&type=$type");
    final response = await http.get(
      url,
      headers: {
        "App-Language": app_language.$,
      },
    );
    //print(url);
    //print(response.body.toString());
    return searchSuggestionResponseFromJson(response.body);
  }
}
