import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'diagro.dart';

class API
{

  Ref ref;

  API(this.ref);

  Future<void> _tokenRevokedHandler() async
  {
    await ref.read(authenticator).refresh();
  }

  void _unauthorizedHandler()
  {
    //save old state
    ref.read(appStateBeforeUnauthorized.state).state = ref.read(appState);

    ref //set app state to unauthorized
        .read(appState.state)
        .state = DiagroState.unauthorized;
  }

  void _otherErrorHandler(http.Response response)
  {
    try {
      var json = jsonDecode(response.body);
      if(json is Map && json.containsKey('message')) {
        ref.read(errorProvider.state).state = json['message'];
      } else {
        ref.read(errorProvider.state).state = response.body;
      }
    } on FormatException {
      ref.read(errorProvider.state).state = response.body;
    }

    //save old state
    ref.read(appStateBeforeError.state).state = ref.read(appState);

    ref //set app state to error
        .read(appState.state)
        .state = DiagroState.error;
  }

  dynamic _responseHandler(http.Response response, String? wrap)
  {
    if(response.statusCode == 200) {
      try {
        var json = jsonDecode(response.body);
        if (json is Map && wrap != null && json.containsKey(wrap)) {
          return json[wrap];
        }
        return json;
      } on FormatException {
        return response;
      }
    }

    _errorHandler(response);
  }

  Future<void> _errorHandler(http.Response response) async
  {
   if(response.statusCode == 403 || response.statusCode == 401) { //Unauthorized
      _unauthorizedHandler();
   } else if(response.statusCode == 406) { //Token expired
     await _tokenRevokedHandler();
   } else { //Server error or something else.
     _otherErrorHandler(response);
   }
  }

  Future<dynamic> get(Uri url, {Map<String, String>? headers, String? wrap = 'data'}) async
  => _responseHandler(await http.get(url, headers: headers), wrap);

  Future<dynamic> put(Uri url, Object? body, {Map<String, String>? headers, String? wrap = 'data'}) async
  => _responseHandler(await http.put(url, headers: headers, body: body), wrap);

  Future<dynamic> post(Uri url, Object? body, {Map<String, String>? headers, String? wrap = 'data'}) async
    => _responseHandler(await http.post(url, headers: headers, body: body), wrap);

  Future<dynamic> delete(Uri url, Object? body, {Map<String, String>? headers, String? wrap = 'data'}) async
    => _responseHandler(await http.delete(url, headers: headers, body: body), wrap);

}


final apiProvider = Provider<API>((ref) => API(ref));