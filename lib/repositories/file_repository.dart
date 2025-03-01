import 'package:editing_house/app_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:editing_house/data_model/simple_image_upload_response.dart';
import 'package:editing_house/helpers/shared_value_helper.dart';
import 'package:flutter/foundation.dart';

class FileRepository {
  Future<SimpleImageUploadResponse> getSimpleImageUploadResponse(
      @required String image, @required String filename) async {
    var post_body = jsonEncode({"image": "${image}", "filename": "$filename"});
    //print(post_body.toString());

    Uri url = Uri.parse("${AppConfig.BASE_URL}/file/image-upload");
    final response = await http.post(url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${access_token.$}",
          "App-Language": app_language.$
        },
        body: post_body);

    //print(response.body.toString());
    return simpleImageUploadResponseFromJson(response.body);
  }
}
