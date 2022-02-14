import 'package:lib_flutter_app/src/configuration.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

/// This class operates the application authentation token.
/// It fetches, stores, validates and deletes the token.
///
/// After any modify operation, the application authentication token's state is updated
/// with a new value or a null value.
///
/// Author: Stijn Leenknegt <stijn@diagro.be>
/// Date: 04/12/2021
class ApplicationAuthenticationTokenNotifier extends StateNotifier<String?>
{

  static const String boxName = 'auth';
  static const String boxKey = 'aat_token';

  /// RiverProvider reference
  final Ref ref;
  Box? box;


  /// Constructor
  ApplicationAuthenticationTokenNotifier(this.ref) : super(null);


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


  /// Set a new token and save it
  Future<void> setToken(String token) async
  {
    state = token;
    await save();
  }


  /// Save a given token in the AAT Hive box.
  Future<void> save() async
  {
    if(state == null || state!.isEmpty) return;
    await checkBox();
    await box!.put(boxKey, state);
  }


  /// Check if the AAT token is valid or not.
  /// This is done with the help of the auth server.
  Future<bool> valid() async
  {
    var headers = {'x-app-id' : ref.read(appId), 'Authorization' : 'Bearer $state', 'Accept' : 'application/json'};
    var url = Uri.http(ref.read(diagroServiceAuthUrl), '/validate/token');
    var response = await http.get(url, headers: headers);

    return response.statusCode == 200;
  }


  /// Get the token from the storage
  /// and set it in the applicationAuthenticationToken provider.
  Future<void> fetch() async
  {
    await checkBox();
    if(box!.isNotEmpty && box!.containsKey(boxKey)) {
      state = box!.get(boxKey);
    }
  }


  /// Delete the token from the Hive storage box.
  /// The application authentication token is set to null.
  Future<void> delete() async
  {
    await checkBox();
    await box!.delete(boxKey);
    state = null;
  }


}


final applicationAuthenticationToken = StateNotifierProvider<ApplicationAuthenticationTokenNotifier, String?>(
        (ref) =>  ApplicationAuthenticationTokenNotifier(ref)
);