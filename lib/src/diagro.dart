import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:lib_flutter_app/src/application_authentication_token.dart';
import 'package:lib_flutter_app/src/authentication_token.dart';
import 'package:lib_flutter_app/src/companies.dart' as diagro_company;
import 'package:lib_flutter_app/src/configuration.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lib_flutter_token/flutter_token.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

import 'companies.dart';

enum DiagroState
{
  uninitialized, login, company, refresh, authenticated, offline
}


class Authenticator
{

  Ref ref;


  Authenticator(this.ref);


  Future<void> loginWithToken() async
  {
    var token = ref.read(authenticationToken);
    var prefferedCompany = ref.read(diagro_company.company);

    if(token == null) {
      ref.read(appState.state).state = DiagroState.login;
    } else {
      var headers = {
        'x-app-id': ref.read(appId),
        'Authorization': 'Bearer $token',
        'Accept': 'application/json'
      };
      if (prefferedCompany != null) {
        headers['x-company-preffered'] = prefferedCompany.name;
      }
      var url = Uri.http(ref.read(diagroServiceAuthUrl), '/login');
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
    var headers = {'x-app-id' : ref.read(appId), 'Accept' : 'application/json'};
    if(prefferedCompany != null) {
      headers['x-company-preffered'] = prefferedCompany.name;
    }
    var url = Uri.http(ref.read(diagroServiceAuthUrl), '/login');
    var response = await http.post(url, headers: headers, body: {'email' : email, 'password' : password});

    if(response.statusCode == 200) {
      await _processLoginResponse(response);
    }
  }


  Future<void> company() async
  {
    var token = ref.read(authenticationToken);
    var company = ref.read(diagro_company.company);

    if(company == null) return;

    var headers = {'x-app-id' : ref.read(appId), 'Accept' : 'application/json', 'Authorization' : 'Bearer $token'};
    var url = Uri.http(ref.read(diagroServiceAuthUrl), '/company');
    var response = await http.post(url, headers: headers, body: {'company' : company.name});

    if(response.statusCode == 200) {
      await _processLoginResponse(response);
    }
  }


  Future<void> refresh() async
  {
    await ref.read(applicationAuthenticationToken.notifier).delete();
    await ref.read(authenticationToken.notifier).fetch();
    await ref.read(diagro_company.company.notifier).fetch();

    var token = ref.read(authenticationToken);
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
    var url = Uri.http(ref.read(diagroServiceAuthUrl), '/logout');
    var response = await http.post(url, headers: headers, body: {});

    if(response.statusCode == 200) {
      await ref.read(applicationAuthenticationToken.notifier).delete();
      await ref.read(authenticationToken.notifier).delete();
      await ref.read(diagro_company.companies.notifier).delete();
      await ref.read(diagro_company.company.notifier).delete();

      ref.read(appState.state).state = DiagroState.login;
    }
  }


  Future<void> _processLoginResponse(http.Response response) async
  {
    var body = jsonDecode(response.body);
    if(body is Map) {
      if(body.containsKey('at')) {
        await ref.read(authenticationToken.notifier).setToken(body['at']);
      }

      if(body.containsKey('aat')) {
        ref.read(applicationAuthenticationToken.notifier).setToken(body['aat']);
        ref.read(user.state).state = AppAuthToken.decode(body['aat']).user;
        ref.read(appState.state).state = DiagroState.authenticated;
      } else if(body.containsKey('companies')) {
        await ref.read(diagro_company.companies.notifier).addAll(
            diagro_company.Company.fromJson(body['companies'])
        );
        await ref.read(diagro_company.company.notifier).setCompany(null);
        ref.read(appState.state).state = DiagroState.company;
      }
    }
  }


}

final user = StateProvider<User?>((ref) => null);
final appState = StateProvider<DiagroState>((ref) => DiagroState.uninitialized);
final appStateBeforeOffline = StateProvider<DiagroState>((ref) => DiagroState.uninitialized);
final authenticator = Provider((ref) => Authenticator(ref));

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