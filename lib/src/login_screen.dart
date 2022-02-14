import 'package:flutter/material.dart';
import 'package:lib_flutter_app/src/diagro.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends ConsumerStatefulWidget
{

  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => LoginScreenState();

}

class LoginScreenState extends ConsumerState<LoginScreen>
{
  bool busy = false;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
                image: DecorationImage(image: AssetImage('assets/bg.jpg'), fit: BoxFit.cover)
            ),
            height: size.height,
            width: size.width,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                    color: Colors.white
                ),
                height: 300,
                width: size.width,
                padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
                child: Form(key: _formKey, child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text("Aanmelden", style: GoogleFonts.comfortaa(fontWeight: FontWeight.bold, fontSize: 26)),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(icon: Icon(Icons.mail), hintText: "E-mailadres", labelText: "E-mailadres"),
                      ),
                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(icon: Icon(Icons.vpn_key_rounded), hintText: "Wachtwoord", labelText: "Wachtwoord"),
                        obscureText: true,
                      ),
                      MaterialButton(onPressed: () async {
                        setState(() => busy = true);
                        await ref.read(authenticator).loginWithCredentials(_emailController.text, _passwordController.text);
                        setState(() => busy = false);
                        },
                          child: Row(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.spaceEvenly,children: [
                            if(busy) const SizedBox(child: CircularProgressIndicator(color: Colors.white), height: 20, width: 20),
                            const Text("Aanmelden", style: TextStyle(color: Colors.white, fontSize: 18))
                          ]),
                          color: Colors.lightBlue
                      )
                    ],
                  ),
                )
              )
            ],
          )
        ],
      ),
    );
  }
}