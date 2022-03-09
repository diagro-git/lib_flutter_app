import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lib_flutter_app/flutter_diagro.dart';
import 'package:line_icons/line_icons.dart';


final companiesDrawerProvider = FutureProvider<List<Company>>((ref) async {
  await ref.read(companies.notifier).getCompaniesFromToken();
  return ref.read(companies);
});

class DiagroDrawer extends ConsumerWidget
{
  const DiagroDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref)
  {
    final u = ref.read(user)!;

    return Drawer(child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(child: Column(children:[
          Center(child: Container(
            height: 100,
            width: 100,
            child: Center(child: Text(u.name.substring(0,1).toUpperCase(), style: const TextStyle(fontSize: 50, color: Colors.white))),
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(80)),
                border: Border.all(color: Colors.white, width: 3),
                color: const Color.fromRGBO(21, 82, 89, 1)
            ),
          )),
          const SizedBox(height: 20),
          Row(children: [
            const Icon(LineIcons.user, size: 24, color: Colors.white70),
            Text(u.name, style: const TextStyle(fontSize: 20, color: Colors.white))
          ]),
          const SizedBox(height: 10),
          Row(children: [
            const Icon(LineIcons.home, size: 24, color: Colors.white70),
            Text(u.company?.name ?? "", style: const TextStyle(fontSize: 20, color: Colors.white))
          ]),
          const SizedBox(height: 20),
          Center(
            child: MaterialButton(child: Row(children: const [Icon(LineIcons.alternateSignOut), Text("   Afmelden")], mainAxisSize: MainAxisSize.min), onPressed: () => ref.read(authenticator).logout(), color: Colors.white, textColor: Colors.lightBlueAccent),
          ),
          const SizedBox(height: 15)]), color: Colors.lightBlueAccent, padding: const EdgeInsets.all(15)),
        const SizedBox(height: 15),
        const Center(child: Text("Bedrijven", style: TextStyle(fontSize: 28, color: Color.fromRGBO(21, 82, 89, 1)))),
        Consumer(builder: (context, ref, child) {
          return ref.watch(companiesDrawerProvider).when(
              data: (companies) {
                var current = u.company!;
                companies = companies.where((element) => element.id != current.id).toList();
                if(companies.isNotEmpty) {
                  return Column(children: [
                    for(var c in companies)
                      MaterialButton(
                          height: 50,
                          onPressed: () =>
                              ref.read(authenticator).switchCompany(c),
                          child: Row(children: [
                            const Icon(LineIcons.alternateExchange),
                            const SizedBox(width: 10),
                            Text(c.name)
                          ])
                      )
                  ]);
                } else {
                  return const Text("Geen andere bedrijven gevonden.", style: TextStyle(fontSize: 14, color: Color.fromRGBO(21, 82, 89, 1)));
                }
              },
              error: (_, __) => Text(_.toString()),
              loading: () => Row(children: const [CircularProgressIndicator(), Text("Bedrijven laden...")])
          );
        }),
        const SizedBox(height: 30),
        const Center(child: Text("Rechten", style: TextStyle(fontSize: 28, color: Color.fromRGBO(21, 82, 89, 1)))),
        _displayAppRights(ref)
      ],
    )
    );
  }


  Widget _displayAppRights(WidgetRef ref)
  {
    final u = ref.read(user)!;
    List<Widget> widgets = [];
    for(var app in u.applications) {
      widgets.add(Row(children: [const Icon(LineIcons.box), Text(app.name)]));
      for(var right in app.permissions.entries) {
        widgets.add(Padding(child: Row(children: [const Icon(LineIcons.key, size: 16), Text(right.key)]), padding: const EdgeInsets.only(left: 15)));
        if(right.value.read) widgets.add(Padding(child: Row(children: const[Icon(LineIcons.checkCircle, size: 16), Text("lezen")]), padding: const EdgeInsets.only(left: 30)));
        if(right.value.create) widgets.add(Padding(child: Row(children: const[Icon(LineIcons.checkCircle, size: 16), Text("toevoegen")]), padding: const EdgeInsets.only(left: 30)));
        if(right.value.update) widgets.add(Padding(child: Row(children: const[Icon(LineIcons.checkCircle, size: 16), Text("wijzigen")]), padding: const EdgeInsets.only(left: 30)));
        if(right.value.delete) widgets.add(Padding(child: Row(children: const[Icon(LineIcons.checkCircle, size: 16), Text("verwijderen")]), padding: const EdgeInsets.only(left: 30)));
        if(right.value.publish) widgets.add(Padding(child: Row(children: const[Icon(LineIcons.checkCircle, size: 16), Text("publishen")]), padding: const EdgeInsets.only(left: 30)));
        if(right.value.export) widgets.add(Padding(child: Row(children: const[Icon(LineIcons.checkCircle, size: 16), Text("exporteren")]), padding: const EdgeInsets.only(left: 30)));
      }
    }

    return Expanded(child: ListView.builder(itemBuilder: (context, index) => widgets[index], itemCount: widgets.length));
  }



}