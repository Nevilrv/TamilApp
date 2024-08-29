import 'dart:developer';

import 'package:tamil_app/apiModel/api_services/api_routes.dart';
import 'package:tamil_app/apiModel/api_services/api_service.dart';
import 'package:tamil_app/model/res_model/get_video_model.dart';

class GetAllVideoRepo extends ApiRoutes {
  Future<dynamic> getAllVideoRepo() async {
    var response =
        await ApiService().getResponse(apiType: APIType.aGet, url: getAllVideo);

    log('getVideoResModel ----------- $response');
    log('getVideoResModel URL ----------- $getAllVideo ');

    GetAllVideoResponseModel getAllVideoResponseModel =
        GetAllVideoResponseModel.fromJson(response);
    return getAllVideoResponseModel;
  }
}
