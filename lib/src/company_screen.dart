import 'package:flutter/material.dart';
import 'package:lib_flutter_app/flutter_diagro.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lib_flutter_app/src/companies.dart' as diagro_company;


class CompanyScreen extends ConsumerStatefulWidget {
  const CompanyScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => CompanyScreenState();
}

class CompanyScreenState extends ConsumerState<CompanyScreen>
{
  bool busy = false;
  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final companies = ref.watch(diagro_company.companies);
    final company = ref.watch(diagro_company.company);
    var size = MediaQuery.of(context).size;

    return Stack(children: [
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
                height: 300,
                width: size.width,
                padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text("Kies bedrijf",
                          style: GoogleFonts.comfortaa(
                              fontWeight: FontWeight.bold, fontSize: 26)),
                      SizedBox(
                          height: 170,
                          child: Scrollbar(
                              controller: _scrollController,
                              isAlwaysShown: true,
                              child: ListView.builder(
                                  controller: _scrollController,
                                  itemCount: companies.length,
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    final item = companies[index];
                                    return Material(
                                        color: Colors.white,
                                        child: InkWell(
                                            child: ListTile(
                                              title: Text(item.name,
                                                  style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.bold)),
                                              selectedTileColor:
                                              const Color.fromRGBO(
                                                  100, 200, 255, 0.1),
                                              selected: item.id == company?.id,
                                              leading: (item.id == company?.id)
                                                  ? const Icon(Icons.check,
                                                  color: Colors.lightBlue)
                                                  : const Icon(Icons.house),
                                            ),
                                            onTap: () async {
                                              await ref.read(diagro_company.company.notifier).setCompany(item);
                                              setState(() {});
                                            }));
                                  }))),
                      MaterialButton(
                          onPressed: () async {
                            setState(() => busy = true);
                            await ref.read(authenticator).company();
                            setState(() => busy = false);
                          },
                          child: Row(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.spaceEvenly,children: [
                            if(busy) const SizedBox(child: CircularProgressIndicator(color: Colors.white), height: 20, width: 20),
                            const Text("Bedrijf kiezen", style: TextStyle(color: Colors.white, fontSize: 18))
                          ]),
                          color: Colors.lightBlue)
                    ]))
          ])
        ]);
  }
}
