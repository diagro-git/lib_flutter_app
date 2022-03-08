import 'package:flutter/material.dart';
import 'package:lib_flutter_app/flutter_diagro.dart';
import 'package:lib_flutter_app/src/diagro.dart';
import 'package:lib_flutter_app/src/error_screen.dart';
import 'package:lib_flutter_app/src/offline_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lib_flutter_app/src/unauthorized_screen.dart';


class DiagroApp extends ConsumerWidget
{

  final Widget app;


  const DiagroApp(this.app, {Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context, WidgetRef ref)
  {
    final state = ref.watch(appState);

    if(state == DiagroState.uninitialized) {
      return ref.read(appIniter).when(
          data: (_) => const WaitingApp(),
          error: (error, stack) => const WaitingApp(),
          loading: () => const WaitingApp()
      );
    } else if(state == DiagroState.refresh) {
      return const WaitingApp();
    } else if(state == DiagroState.login) {
      return const LoginApp();
    } else if(state == DiagroState.company) {
      return const CompanyApp();
    } else if(state == DiagroState.authenticated) {
      return app;
    } else if(state == DiagroState.offline) {
      return const OfflineApp();
    } else if(state == DiagroState.unauthorized) {
      return const UnauthorizedApp();
    } else if(state == DiagroState.error) {
      return const ErrorApp();
    } else {
      throw Exception("Unknown Diagro application state!");
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


class UnauthorizedApp extends StatelessWidget
{
  const UnauthorizedApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            body: UnauthorizedScreen()
        )
    );
  }

}


class ErrorApp extends StatelessWidget
{
  const ErrorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            body: ErrorScreen()
        )
    );
  }

}