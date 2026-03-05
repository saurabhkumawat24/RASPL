
import 'package:get/get.dart';

import '../util/custom_snackbar.dart';




class ApiChecker {
  static void checkApi(Response response,{bool getXSnackBar = false}) {
    if(response.statusCode == 401) {
      showCustomSnackBar(response.statusText, getXSnackBar: getXSnackBar,isError: true);
      // Get.offAllNamed(RouteHelper.getSignInRoute(RouteHelper.splash));
    }
    else if(response.statusCode == 403 || response.statusCode == 404)
    {
      showCustomSnackBar(response.body["message"], getXSnackBar: getXSnackBar,isError: true);
      //Get.offAllNamed(RouteHelper.login);
    }

    else {
      showCustomSnackBar(response.statusText, getXSnackBar: getXSnackBar,isError: true);
    }
  }
}
