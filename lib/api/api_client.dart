import 'dart:convert';
import 'dart:typed_data';

import 'package:get/get_connect/http/src/request/request.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' as Foundation;
import 'package:http/http.dart' as Http;

import '../util/appContants.dart';


class ApiClient extends GetxService {
  final String appBaseUrl;
  final SharedPreferences sharedPreferences;
  static final String noInternetMessage = 'connection_to_api_server_failed'.tr;
  final int timeoutInSeconds = 30;

  String? token;
  Map<String, String>? _mainHeaders;

  ApiClient({required this.appBaseUrl, required this.sharedPreferences}) {
    token = sharedPreferences.getString(AppContants.token);
    if(Foundation.kDebugMode) {
      print('Token: $token');
    }

    if(token != null) {
      updateHeader(token!);
    }
    else
    {
      updateHeader("");
    }
  }

  void updateHeader(String token) {
    Map<String, String> header = {
      'Content-Type': 'application/json',
    };

    if (token.isNotEmpty) {
      header['Authorization'] = 'Bearer $token';
    }

    _mainHeaders = header;
  }
  Future<Response> getData(String uri, {Map<String, dynamic>? query, Map<String, String>? headers}) async {
    try {
      if(Foundation.kDebugMode) {
        print('====> API Call: $uri\nHeader: $_mainHeaders');
      }
      Http.Response _response = await Http.get(
        Uri.parse(appBaseUrl+uri),
        headers: headers ?? _mainHeaders,
      ).timeout(Duration(seconds: timeoutInSeconds));
      return handleResponse(_response, uri);
    } catch (e) {
      print('------------${e.toString()}');
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response> getDataOther(String uri, {Map<String, dynamic>? query, Map<String, String>? headers}) async {
    try {
      if(Foundation.kDebugMode) {
        print('====> API Call: $uri\nHeader: $_mainHeaders');
      }
      Http.Response _response = await Http.get(
        Uri.parse(uri),
        headers: headers ?? _mainHeaders,
      ).timeout(Duration(seconds: timeoutInSeconds));
      return handleResponse(_response, uri);
    } catch (e) {
      print('------------${e.toString()}');
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response> postData(String uri, dynamic body, {Map<String, String>? headers}) async {
    try {
      if(Foundation.kDebugMode) {
        print('====> API Call: ${appBaseUrl!+uri}\nHeader: $_mainHeaders');
        print('====> API Body: ${jsonEncode(body)}');
      }
      Http.Response _response = await Http.post(
        Uri.parse(appBaseUrl!+uri),
        body: jsonEncode(body),
        headers: headers ?? _mainHeaders,
      ).timeout(Duration(seconds: timeoutInSeconds));
      return handleResponse(_response, uri);
    } catch (e) {
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response> facePost(String uri, dynamic body, {Map<String, String>? headers}) async {
    try {
      if(Foundation.kDebugMode) {
        print('====> API Call: $uri\nHeader: $_mainHeaders');
        print('====> API Body: $body');
      }
      Http.Response _response = await Http.post(
        Uri.parse("https://test.peaksender.com/"+uri),
        body: jsonEncode(body),
        headers: headers ?? _mainHeaders,
      ).timeout(Duration(seconds: timeoutInSeconds));
      return handleResponse(_response, uri);
    } catch (e) {
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }


  Future<Response> putData(String uri, dynamic body, {Map<String, String>? headers}) async {
    try {
      if(Foundation.kDebugMode) {
        print('====> API Call: $uri\nHeader: $_mainHeaders');
        print('====> API Body: $body');
      }
      Http.Response _response = await Http.put(
        Uri.parse(appBaseUrl!+uri),
        body: jsonEncode(body),
        headers: headers ?? _mainHeaders,
      ).timeout(Duration(seconds: timeoutInSeconds));
      return handleResponse(_response, uri);
    } catch (e) {
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response> deleteData(String uri, dynamic body, {Map<String, String>? headers}) async {
    try {
      if(Foundation.kDebugMode) {
        print('====> API Call: $uri\nHeader: $_mainHeaders');
        print('====> API Body: $body');
      }
      Http.Response _response = await Http.delete(
        Uri.parse(appBaseUrl!+uri),
        body: jsonEncode(body),
        headers: headers ?? _mainHeaders,
      ).timeout(Duration(seconds: timeoutInSeconds));
      return handleResponse(_response, uri);
    } catch (e) {
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

/*
  Future<Response> postMultipartData(String uri, Map<String, String> body, List<MultipartBody> multipartBody, {Map<String, String>? headers}) async {
    try {
      if(Foundation.kDebugMode) {
        print('====> API Call: $uri\nHeader: $_mainHeaders');
        print('====> API Body: $body with ${multipartBody.length} picture');
      }
      Http.MultipartRequest _request = Http.MultipartRequest('POST', Uri.parse(appBaseUrl!+uri));
      _request.headers.addAll(headers ?? _mainHeaders!);

      print("file => ${multipartBody.length}");

      if(multipartBody.isNotEmpty && multipartBody.length !=0) {
        for(MultipartBody multipart in multipartBody) {
          if(multipart.file != null) {
            Uint8List _list = await multipart.file.readAsBytes();
            _request.files.add(Http.MultipartFile(
              multipart.key, multipart.file.readAsBytes().asStream(), _list.length,
              filename: '${DateTime.now().toString()}.png',
            ));

          }
        }
      }

      _request.fields.addAll(body);

      Http.Response _response = await Http.Response.fromStream(await _request.send());
      return handleResponse(_response, uri);
    } catch (e) {
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }
*/

/*
  Future<Response> faceVerifyPostData(String uri, Map<String, String> body, List<MultipartBody> multipartBody, {Map<String, String>? headers}) async {
    try {
      if(Foundation.kDebugMode) {
        print('====> API Call: $uri\nHeader: $_mainHeaders');
        print('====> API Body: $body with ${multipartBody.length} picture');
      }
      Http.MultipartRequest _request = Http.MultipartRequest('POST', Uri.parse("https://test.peaksender.com/"+uri));
      _request.headers.addAll(headers ?? _mainHeaders!);

      print("file => ${multipartBody.length}");

      if(multipartBody.isNotEmpty && multipartBody.length !=0) {
        for(MultipartBody multipart in multipartBody) {
          if(multipart.file != null) {
            Uint8List _list = await multipart.file.readAsBytes();
            _request.files.add(Http.MultipartFile(
              multipart.key, multipart.file.readAsBytes().asStream(), _list.length,
              filename: '${DateTime.now().toString()}.png',
            ));

          }
        }
      }

      _request.fields.addAll(body);

      Http.Response _response = await Http.Response.fromStream(await _request.send());
      return handleResponse(_response, uri);
    } catch (e) {
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }
*/


  Response handleResponse(Http.Response response, String uri) {
    dynamic _body;
    try {
      _body = jsonDecode(response.body);
    }catch(e) {}
    Response _response = Response(
      body: _body != null ? _body : response.body, bodyString: response.body.toString(),
      request: Request(headers: response.request!.headers, method: response.request!.method, url: response.request!.url),
      headers: response.headers, statusCode: response.statusCode, statusText: response.reasonPhrase,
    );
    if(_response.statusCode != 200 && _response.body != null && _response.body is !String) {
      if(_response.body.toString().startsWith('{errors: [{code:')) {
        dynamic _errorResponse = jsonDecode(_response.body);
        _response = Response(statusCode: _response.statusCode, body: _response.body, statusText: _errorResponse.errors[0].message);
      }else if(_response.body.toString().startsWith('{message')) {
        _response = Response(statusCode: _response.statusCode, body: _response.body, statusText: _response.body['message']);
      }
    }else if(_response.statusCode != 200 && _response.body == null) {
      _response = Response(statusCode: 0, statusText: noInternetMessage);
    }
    if(Foundation.kDebugMode) {
      print('====> API Response: [${_response.statusCode}] $uri\n${_response.body}');
    }
    return _response;
  }
}

/*
class MultipartBody {
  String key;
  XFile file;

  MultipartBody(this.key);
}*/
