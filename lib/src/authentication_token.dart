import 'dart:io';

import 'package:external_path/external_path.dart';
import 'package:lib_flutter_app/src/configuration.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:permission_handler/permission_handler.dart' as permission_flutter;
import 'package:http/http.dart' as http;
import 'package:hive/src/hive_impl.dart';

/// This class operates the authentation token.
/// It fetches, stores, validates and deletes the token.
///
/// After any modify operation, the authentication token's state is updated
/// with a new value or a null value.
///
/// Author: Stijn Leenknegt <stijn@diagro.be>
/// Date: 04/12/2021
class AuthenticationTokenNotifier extends StateNotifier<String?>
{

  static const String boxName = 'auth';
  static const String boxKey = 'at_token';


  /// RiverPod reference
  final Ref ref;
  Box? box;


  /// Constructor
  AuthenticationTokenNotifier(this.ref) : super(null);


  Future<void> checkBox() async
  {
    box ??= await Hive.openBox(boxName);
  }


  Future<void> closeHive() async
  {
    if(box != null && box!.isOpen) {
      await box!.close();
    }
  }


  /// Set a new token
  Future<void> setToken(String token) async
  {
    state = token;
    await save();
  }


  /// Save a given token in the AT Hive box.
  /// This box is located in an external storage
  /// so other apps can access this token.
  Future<void> save() async
  {
    if(state == null || state!.isEmpty) return;
    await checkBox();
    await box!.put(boxKey, state);
  }


  /// Check if the AT token is valid or not.
  /// This is done with the help of the auth server.
  Future<bool> valid() async
  {
    var headers = {'x-app-id' : ref.read(appId), 'Authorization' : 'Bearer $state', 'Accept' : 'application/json'};
    var url = Uri.https(ref.read(diagroServiceAuthUrl), '/validate/user-token');
    var response = await http.get(url, headers: headers);

    return response.statusCode == 200;
  }


  /// Get the token from the storage
  /// and set it in the state
  Future<bool> fetch() async
  {
    bool fetched = false;
    await checkBox();
    if(box!.isNotEmpty && box!.containsKey(boxKey)) {
       state = box!.get(boxKey);
       fetched = true;
    }
    return fetched;
  }


  /// Delete the token from the Hive storage box.
  /// The authentication token is set to null.
  Future<void> delete() async
  {
    await checkBox();
    await box!.delete(boxKey);

    state = null;
  }
}


final authenticationToken = StateNotifierProvider<AuthenticationTokenNotifier, String?>(
        (ref) => AuthenticationTokenNotifier(ref)
);