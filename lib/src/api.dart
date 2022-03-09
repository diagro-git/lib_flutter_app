import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lib_flutter_app/flutter_diagro.dart';

import 'package:lib_flutter_app/src/diagro.dart';

class API
{

  Ref ref;

  API(this.ref);

  String? wrap;

  Future<void> _tokenRevokedHandler(http.Response response, String? wrap) async
  {
    await ref.read(authenticator).refresh();

    if(ref.read(appState) == DiagroState.authenticated) { //refresh complete, otherwhise state is login.
      //do the request again
      var req = response.request! as http.Request;
      //set new AAT token in the request
      req.headers.update('Authorization', (value) => "Bearer ${ref.read(applicationAuthenticationToken)!}");

      //can't send req because it's final, get through a new request
      if(req.method == 'POST') {
        return await post(req.url, (req.headers.containsKey('content-type') && req.headers['content-type']!.contains('application/x-www-form-urlencoded')) ? req.bodyFields : null, headers: req.headers, wrap: wrap);
      } else if(req.method == 'PUT') {
        return await put(req.url, (req.headers.containsKey('content-type') && req.headers['content-type']!.contains('application/x-www-form-urlencoded')) ? req.bodyFields : null, headers: req.headers, wrap: wrap);
      } else if(req.method == 'DELETE') {
        return await delete(req.url, (req.headers.containsKey('content-type') && req.headers['content-type']!.contains('application/x-www-form-urlencoded')) ? req.bodyFields : null, headers: req.headers, wrap: wrap);
      } else if(req.method == 'GET') {
        return await get(req.url, headers: req.headers, wrap: wrap);
      }
    }
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

  dynamic _responseHandler(http.Response response, String? wrap) async
  {
    if(response.statusCode == 200 || response.statusCode == 201) {
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

    return await _errorHandler(response, wrap);
  }

  Future<void> _errorHandler(http.Response response, String? wrap) async
  {
   if(response.statusCode == 403 || response.statusCode == 401) { //Unauthorized
      _unauthorizedHandler();
   } else if(response.statusCode == 406) { //Token expired
     return await _tokenRevokedHandler(response, wrap);
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