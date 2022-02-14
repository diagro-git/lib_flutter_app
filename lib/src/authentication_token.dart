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
  final HiveInterface hive = HiveImpl();


  /// Constructor
  AuthenticationTokenNotifier(this.ref) : super(null);


  /// Set a new token
  Future<void> setToken(String token) async
  {
    state = token;
    save();
  }


  /// Save a given token in the AT Hive box.
  /// This box is located in an external storage
  /// so other apps can access this token.
  Future<void> save() async
  {
    if(state == null || state!.isEmpty) return;

    var box = await _getHiveBox();
    await box.put(boxKey, state);
    await hive.close();
  }


  /// Check if the AT token is valid or not.
  /// This is done with the help of the auth server.
  Future<bool> valid() async
  {
    var headers = {'x-app-id' : ref.read(appId), 'Authorization' : 'Bearer $state', 'Accept' : 'application/json'};
    var url = Uri.http(ref.read(diagroServiceAuthUrl), '/validate/user-token');
    var response = await http.get(url, headers: headers);

    return response.statusCode == 200;
  }


  /// Get the token from the storage
  /// and set it in the state
  Future<void> fetch() async
  {
    var box = await _getHiveBox();
    if(box.isNotEmpty && box.containsKey(boxKey)) {
       state = box.get('at_token');
    }
    await hive.close();
  }


  /// Delete the token from the Hive storage box.
  /// The authentication token is set to null.
  Future<void> delete() async
  {
    var box = await _getHiveBox();
    await box.delete(boxKey);
    hive.close();

    state = null;
  }


  /// Get the Hive box for the token.
  Future<Box> _getHiveBox() async
  {
    await _createDiagroDirectoryIfNotExists();
    hive.init(await _getDiagroPath());
    return await hive.openBox(boxName);
  }


  /// Create the external directory if it doesn't exits.
  Future<void> _createDiagroDirectoryIfNotExists() async
  {
    var status = await permission_flutter.Permission.storage.status;
    if(! status.isGranted) {
      await [permission_flutter.Permission.storage].request();
    }

    status = await permission_flutter.Permission.storage.status;
    if(status.isGranted) {
      var dir = Directory(await _getDiagroPath());
      if (! dir.existsSync()) {
        dir.createSync(recursive: true);
      }
    }
  }


  /// Get the external path of the device.
  /// Android, iOS are different locations.
  Future<String?> _getStoragePath() async
  {
    var path = await ExternalPath.getExternalStorageDirectories();
    if(path.isNotEmpty) {
      return path[0];
    }

    return null;
  }


  /// Get the path of the Diagro folder on the external storage.
  Future<String> _getDiagroPath() async
  {
    var path = await _getStoragePath();
    if(path != null) {
      if(! path.endsWith('/')) path += '/';
      return '${path}diagro';
    }

    return '/diagro';
  }

}


final authenticationToken = StateNotifierProvider<AuthenticationTokenNotifier, String?>(
        (ref) => AuthenticationTokenNotifier(ref)
);