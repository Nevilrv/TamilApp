import 'dart:developer';

import 'package:get/get.dart';
import 'package:tamil_app/apiModel/Repo/get_all_video_repo.dart';
import 'package:tamil_app/apiModel/api_services/api_response.dart';
import 'package:tamil_app/model/res_model/get_video_model.dart';

class GetAllVideoViewModel extends GetxController {
  ApiResponse _apiResponse = ApiResponse.initial(message: 'Initialization');

  ApiResponse get getAllVideoApiResponse => _apiResponse;

  Future<void> getAllVideoViewModel() async {
    _apiResponse = ApiResponse.loading(message: 'Loading');
    update();
    try {
      GetAllVideoResponseModel response =
          await GetAllVideoRepo().getAllVideoRepo();
      log('==GetVideoResModel=>$response');
      _apiResponse = ApiResponse.complete(response);
    } catch (e) {
      _apiResponse = ApiResponse.error(message: e.toString());
      log("==GetVideoResModel=> $e");
    }
    update();
  }
}
