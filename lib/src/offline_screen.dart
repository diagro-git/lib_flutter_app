import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';


class OfflineScreen extends ConsumerWidget
{
  const OfflineScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
        body: Stack(children: [
      Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/bg.jpg'), fit: BoxFit.cover)),
        height: size.height,
        width: size.width,
      ),
      Column(mainAxisAlignment: MainAxisAlignment.end, children: [
        Container(
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20)),
                color: Colors.white),
            height: 150,
            width: size.width,
            padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text("Offline",
                      style: GoogleFonts.comfortaa(
                          fontWeight: FontWeight.bold, fontSize: 26)),
                  Text("Deze app heeft internet verbinding nodig om te werken! Is er terug internet verbinding? Dan zou deze melding moeten verdwijnen.", style: GoogleFonts.comfortaa(fontSize: 14))
                ]))
      ])
    ]));
  }
}
