import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lib_flutter_app/flutter_diagro.dart';
import 'package:http/http.dart' as http;

part 'companies.g.dart';

@HiveType(typeId: 0)
class Company extends HiveObject
{
  @HiveField(0)
  int id;

  @HiveField(1)
  String name;

  Company({required this.id, required this.name});

  static List<Company> fromJson(List<dynamic> json)
  {
    List<Company> list = [];
    for(var item in json) {
      list.add(Company(id: item['id'], name: item['name']));
    }
    return list;
  }
}

/// Keeps the list of companies.
///
/// Author: Stijn Leenknegt <stijn@diagro.be>
/// Date: 04/12/2021
class CompaniesNotifier extends StateNotifier<List<Company>>
{

  static const String boxName = 'auth';
  static const String boxKey = 'companies';

  /// RiverProvider reference
  final Ref ref;
  Box? box;


  /// Constructor
  CompaniesNotifier(this.ref): super([]);


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


  /// Add a company to the list.
  void add(Company company)
  {
    state[state.length] = company;
  }


  /// Set the state to the given companies and save them.
  Future<void> addAll(List<Company> companies) async
  {
    state = companies;
    await save();
  }


  /// Save a given list of companies in the Hive box.
  Future<void> save() async
  {
    await checkBox();
    await box!.put(boxKey, state);
  }


  /// Get the token from the storage
  /// and set it in the authenticationToken provider.
  Future<void> fetch() async
  {
    await checkBox();
    if(box!.isNotEmpty && box!.containsKey(boxKey)) {
      state = box!.get(boxKey);
    }
  }


  /// Delete the companies
  Future<void> delete() async
  {
    await checkBox();
    await box!.delete(boxKey);
    state = [];
  }


  Future<void> getCompaniesFromToken() async
  {
    var token = ref.read(authenticationToken);
    /**
     * Token can be null because the app hasn't fetched the AT token yet.
     * This is because the AAT was loaded and is still valid.
     * So the AT isn't read. Only when it's invalid.
     */
    if(token == null) await ref.read(authenticationToken.notifier).fetch();
    token = ref.read(authenticationToken);
    var headers = {'x-app-id' : ref.read(appId), 'Accept' : 'application/json', 'Authorization' : 'Bearer $token'};
    var url = Uri.https(ref.read(diagroServiceAuthUrl), '/companies');
    var response = await http.get(url, headers: headers);
    if(response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      if(json.containsKey('companies')) {
        state = Company.fromJson(json['companies']);
      }
    }
  }


}


/// Save the selected company as preferred company
/// When refreshing the token, this is send as preferred company
class CompanyNotifier extends StateNotifier<Company?>
{

  static const String boxName = 'auth';
  static const String boxKey = 'company';

  Box? box;


  CompanyNotifier() : super(null);


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


  /// Save a given list of companies in the Hive box.
  Future<void> save() async
  {
    await checkBox();
    await box!.put(boxKey, state);
  }


  /// Change the preferred company and save it
  Future<void> setCompany(Company? c) async
  {
    state = c;
    await save();
  }


  /// Get the token from the storage
  /// and set it in the authenticationToken provider.
  Future<void> fetch() async
  {
    await checkBox();
    if(box!.isNotEmpty && box!.containsKey(boxKey)) {
      state = box!.get(boxKey);
    }
  }


  /// Delete the companies
  Future<void> delete() async
  {
    await checkBox();
    await box!.delete(boxKey);
    state = null;
  }


}


final companies = StateNotifierProvider<CompaniesNotifier, List<Company>>(
        (ref) => CompaniesNotifier(ref)
);

final company = StateNotifierProvider<CompanyNotifier, Company?>(
        (ref) => CompanyNotifier()
);