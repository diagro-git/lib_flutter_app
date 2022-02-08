import 'package:flutter/material.dart';
import 'package:flutter_diagro/flutter_diagro.dart';
import 'package:flutter_diagro/src/diagro.dart';
import 'package:flutter_diagro/src/offline_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class DiagroApp extends ConsumerWidget
{

  final Widget app;


  const DiagroApp(this.app, {Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context, WidgetRef ref)
  {
    final state = ref.watch(appState);

    if(state == DiagroState.UNINITIALIZED) {
      return ref.read(appIniter).when(
          data: (_) => const WaitingApp(),
          error: (error, stack) => const WaitingApp(),
          loading: () => const WaitingApp()
      );
    } else if(state == DiagroState.REFRESH) {
      return const WaitingApp();
    } else if(state == DiagroState.LOGIN) {
      return const LoginApp();
    } else if(state == DiagroState.COMPANY) {
      return const CompanyApp();
    } else if(state == DiagroState.AUTHENTICATED) {
      return app;
    } else if(state == DiagroState.OFFLINE) {
      return const OfflineApp();
    } else {
      throw Exception("Unknonw Diagro application state!");
    }
  }

}


class WaitingApp extends StatelessWidget
{
  const WaitingApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            body: Center(
                child: CircularProgressIndicator()
            )
        )
    );
  }

}


class LoginApp extends StatelessWidget
{
  const LoginApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            body: LoginScreen()
        )
    );
  }

}


class CompanyApp extends StatelessWidget
{
  const CompanyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            body: CompanyScreen()
        )
    );
  }

}


class OfflineApp extends StatelessWidget
{
  const OfflineApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            body: OfflineScreen()
        )
    );
  }

}