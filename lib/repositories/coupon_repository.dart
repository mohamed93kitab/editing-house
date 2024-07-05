import 'package:editing_house/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dart:convert';

import 'package:editing_house/data_model/coupon_apply_response.dart';
import 'package:editing_house/data_model/coupon_remove_response.dart';
import 'package:editing_house/helpers/shared_value_helper.dart';

class CouponRepository {
  Future<CouponApplyResponse> getCouponApplyResponse(
      @required String coupon_code) async {
    var post_body =
        jsonEncode({"user_id": "${user_id.$}", "coupon_code": "$coupon_code"});

    Uri url = Uri.parse("${AppConfig.BASE_URL}/coupon-apply");
    final response = await http.post(url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${access_token.$}",
          "App-Language": app_language.$
        },
        body: post_body);

    return couponApplyResponseFromJson(response.body);
  }

  Future<CouponRemoveResponse> getCouponRemoveResponse() async {
    var post_body = jsonEncode({"user_id": "${user_id.$}"});

    Uri url = Uri.parse("${AppConfig.BASE_URL}/coupon-remove");
    final response = await http.post(url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${access_token.$}",
          "App-Language": app_language.$
        },
        body: post_body);

    return couponRemoveResponseFromJson(response.body);
  }
}
