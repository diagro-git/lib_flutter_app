import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:lib_flutter_app/src/application_authentication_token.dart';
import 'package:lib_flutter_app/src/authentication_token.dart';
import 'package:lib_flutter_app/src/companies.dart' as diagro_company;
import 'package:lib_flutter_app/src/configuration.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lib_flutter_token/flutter_token.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:app_tracking_transparency/app_tracking_transparency.dart';

import 'package:lib_flutter_app/src/companies.dart';

enum DiagroState
{
  uninitialized, login, company, refresh, authenticated, offline, unauthorized, error
}


class Authenticator
{

  Ref ref;


  Authenticator(this.ref);


  Future<void> loginWithToken() async
  {
    var token = ref.read(authenticationToken);

    if(token == null) {
      ref.read(appState.state).state = DiagroState.login;
    } else {
      var prefferedCompany = ref.read(diagro_company.company);
      var deviceUID = await ref.read(deviceId.future);
      var headers = {
        'x-app-id': ref.read(appId),
        'Authorization': 'Bearer $token',
        'Accept': 'application/json'
      };

      if (deviceUID != null) {
        headers['x-device-uid'] = deviceUID;
      }
      if (prefferedCompany != null) {
        headers['x-company-preffered'] = prefferedCompany.name;
      }

      var url = Uri.https(ref.read(diagroServiceAuthUrl), '/login');
      var response = await http.post(url, headers: headers, body: {});

      if (response.statusCode == 200) {
        await _processLoginResponse(response);
      } else {
        await ref.read(authenticationToken.notifier).delete();
        await ref.read(diagro_company.companies.notifier).delete();
        await ref.read(diagro_company.company.notifier).delete();
        ref
            .read(appState.state)
            .state = DiagroState.login;
      }
    }
  }


  Future<void> loginWithCredentials(String email, String password) async
  {
    var prefferedCompany = ref.read(diagro_company.company);
    var deviceUID = await ref.read(deviceId.future);
    var headers = {'x-app-id' : ref.read(appId), 'Accept' : 'application/json'};

    if(prefferedCompany != null) {
      headers['x-company-preffered'] = prefferedCompany.name;
    }
    if (deviceUID != null) {
      headers['x-device-uid'] = deviceUID;
    }

    var url = Uri.https(ref.read(diagroServiceAuthUrl), '/login');
    var response = await http.post(url, headers: headers, body: {'email' : email, 'password' : password});

    if(response.statusCode == 200) {
      await _processLoginResponse(response);
    } else {
      _error(jsonDecode(response.body)['message']);
    }
  }


  Future<void> company() async
  {
    var token = ref.read(authenticationToken);
    var company = ref.read(diagro_company.company);

    if(company == null) return;

    var headers = {'x-app-id' : ref.read(appId), 'Accept' : 'application/json', 'Authorization' : 'Bearer $token'};
    var url = Uri.https(ref.read(diagroServiceAuthUrl), '/company');
    var response = await http.post(url, headers: headers, body: {'company' : company.name});

    if(response.statusCode == 200) {
      await _processLoginResponse(response);
    } else {
      _error(jsonDecode(response.body)['message']);
    }
  }

  void _error(String message)
  {
    ref.read(errorProvider.state).state = message;

    //save old state
    ref.read(appStateBeforeError.state).state = ref.read(appState);

    ref //set app state to error
        .read(appState.state)
        .state = DiagroState.error;
  }


  Future<void> switchCompany(diagro_company.Company company) async
  {
    var token = ref.read(authenticationToken);
    if(token == null) {
      await ref.read(authenticationToken.notifier).fetch();
      token = ref.read(authenticationToken);
    }

    if(token == null) {
      await logout();
    } else {
      ref.read(diagro_company.company.notifier).setCompany(company);
      ref.read(appState.state).state = DiagroState.refresh;
      await loginWithToken();
    }
  }


  Future<String?> tokenFromDeviceUID() async
  {
    final status = await AppTrackingTransparency.requestTrackingAuthorization();
    if(status == TrackingStatus.authorized || status == TrackingStatus.notSupported) {
      var deviceUID = await ref.read(deviceId.future);

      if (deviceUID != null) {
        var headers = {
          'x-app-id': ref.read(appId),
          'x-device-uid': deviceUID,
          'Accept': 'application/json'
        };

        var url = Uri.https(
            ref.read(diagroServiceAuthUrl), '/token-device-uid');
        var response = await http.post(url, headers: headers, body: {});

        if (response.statusCode == 200) {
          return jsonDecode(response.body)['at'];
        }
      }
    }

    return null;
  }


  Future<void> refresh() async
  {
    await ref.read(applicationAuthenticationToken.notifier).delete();
    await ref.read(authenticationToken.notifier).fetch();
    await ref.read(diagro_company.company.notifier).fetch();

    var token = ref.read(authenticationToken);
    token ??= await tokenFromDeviceUID();

    if(token == null) {
      await ref.read(diagro_company.companies.notifier).delete();
      await ref.read(diagro_company.company.notifier).delete();
      ref
          .read(appState.state)
          .state = DiagroState.login;
    } else {
      await loginWithToken();
    }
  }


  Future<void> logout() async
  {
    var token = ref.read(authenticationToken);
    if(token == null) {
      await ref.read(authenticationToken.notifier).fetch();
      token = ref.read(authenticationToken);
    }

    var headers = {'x-app-id' : ref.read(appId), 'Accept' : 'application/json', 'Authorization' : 'Bearer $token'};
    var url = Uri.https(ref.read(diagroServiceAuthUrl), '/logout');
    var response = await http.post(url, headers: headers, body: {});

    if(response.statusCode == 200) {
      await ref.read(applicationAuthenticationToken.notifier).delete();
      await ref.read(authenticationToken.notifier).delete();
      await ref.read(diagro_company.companies.notifier).delete();
      await ref.read(diagro_company.company.notifier).delete();

      ref.read(appState.state).state = DiagroState.login;
    } else {
      _error(jsonDecode(response.body)['message']);
    }
  }


  Future<void> _processLoginResponse(http.Response response) async
  {
    var body = jsonDecode(response.body);
    if(body is Map) {
      if(body.containsKey('at')) {
        await ref.read(authenticationToken.notifier).setToken(body['at']);
      }

      if(body.containsKey('aat') && body['aat'] != null) {
        ref.read(applicationAuthenticationToken.notifier).setToken(body['aat']);
        ref.read(user.state).state = AppAuthToken.decode(body['aat']).user;
        ref.read(appState.state).state = DiagroState.authenticated;
      } else if(body.containsKey('companies')) {
        await ref.read(diagro_company.companies.notifier).addAll(
            diagro_company.Company.fromJson(body['companies'])
        );
        await ref.read(diagro_company.company.notifier).setCompany(null);
        ref.read(appState.state).state = DiagroState.company;
      } else {
        await ref.read(applicationAuthenticationToken.notifier).delete();
        await ref.read(diagro_company.companies.notifier).delete();
        await ref.read(diagro_company.company.notifier).delete();
        _error("Account heeft geen toegang tot deze applicatie!");
      }
    }
  }


}

final user = StateProvider<User?>((ref) => null);
final appState = StateProvider<DiagroState>((ref) => DiagroState.uninitialized);
final appStateBeforeOffline = StateProvider<DiagroState>((ref) => DiagroState.uninitialized);
final appStateBeforeError = StateProvider<DiagroState>((ref) => DiagroState.uninitialized);
final appStateBeforeUnauthorized = StateProvider<DiagroState>((ref) => DiagroState.uninitialized);
final authenticator = Provider((ref) => Authenticator(ref));
final errorProvider = StateProvider<String>((ref) => "");
final deviceId = FutureProvider<String?>((ref) async {
  if(Platform.isAndroid) {
    AndroidDeviceInfo info = await DeviceInfoPlugin().androidInfo;
    return info.androidId;
  } else if(Platform.isIOS) {
    IosDeviceInfo info = await DeviceInfoPlugin().iosInfo;
    return info.identifierForVendor;
  } else if(Platform.isLinux) {
    LinuxDeviceInfo info = await DeviceInfoPlugin().linuxInfo;
    return info.machineId;
  }
});

final appIniter = FutureProvider<void>((ref) async {
  //hive initialisation
  Hive.registerAdapter(CompanyAdapter());
  await Hive.initFlutter();

  //network initialisation
  var conn = await Connectivity().checkConnectivity();
  if(conn == ConnectivityResult.none) {
    ref.read(appState.state).state = DiagroState.offline;
  }

  Connectivity().onConnectivityChanged.listen((event) {
    final state = ref.read(appState);
    if(event == ConnectivityResult.none) {
      if(state != DiagroState.offline) {
        ref //save current state
            .read(appStateBeforeOffline.state)
            .state = state;
        ref //set app state to offline
            .read(appState.state)
            .state = DiagroState.offline;
      }
    } else {
      if(state == DiagroState.offline) {
        ref //set app state to before the offline state
            .read(appState.state)
            .state = ref.read(appStateBeforeOffline);
      }
    }
  });

  //authentication initialisation
  if(conn != ConnectivityResult.none) { //only if online
    await ref.read(applicationAuthenticationToken.notifier).fetch();
    var aat = ref.read(applicationAuthenticationToken);
    if (aat != null && aat.isNotEmpty) {
      bool valid = await ref.read(applicationAuthenticationToken.notifier)
          .valid();
      if (valid) {
        try {
          var aatToken = AppAuthToken.decode(aat);
          if (aatToken.user != null) {
            ref
                .read(user.state)
                .state = aatToken.user;
            ref
                .read(appState.state)
                .state = DiagroState.authenticated;
          } else {
            await ref.read(authenticator).refresh();
          }
        }
        catch (e) {
          await ref.read(authenticator).refresh();
        }
      } else {
        await ref.read(authenticator).refresh();
      }
    } else {
      await ref.read(authenticator).refresh();
    }
  }
});