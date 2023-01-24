import 'dart:async';
import 'dart:math';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kadibot/services/firebase_services.dart';
import 'package:kadibot/views/constants/widgets.dart';
import 'package:kadibot/views/home_screen.dart';
import 'package:kadibot/views/passerel.dart';
import 'package:kadibot/views/chat_screen.dart';
import 'package:page_transition/page_transition.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController _nameController = TextEditingController();
  bool _isLogin = false;
  bool _fieldIsVisible = false;
  bool _btnIsVisible = false;
  bool _notSurnameTextInfosIsVisible = false;

  void initState() {
    Future.delayed(Duration(milliseconds: 17400), () {
      setStateIfMounted(() {
        _fieldIsVisible = true;
      });
    });

    Future.delayed(Duration(milliseconds: 17500), () {
      setStateIfMounted(() {
        _btnIsVisible = true;
      });
    });
  }

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Center(
          child: Container(
        margin: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.07,
            ),
            Center(
              child: Container(
                width: 100,
                child: ClipOval(
                  child: Image.asset(
                    "assets/icon.png",
                  ),
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.04,
            ),
            SizedBox(
              child: DefaultTextStyle(
                style: const TextStyle(
                  fontSize: 25.0,
                  fontFamily: 'Agne',
                  color: Colors.grey,
                ),
                child: AnimatedTextKit(
                  isRepeatingAnimation: false,
                  pause: Duration(milliseconds: 10000),
                  animatedTexts: [
                    TypewriterAnimatedText(
                        'Salut, comment tu vas ? Bienvenue , je suis MATHILDE ton assistante virtuelle super intelligente 😊.Tu peux me posez toutes sortes de questions.Je suis là pour trouvez des solutions à tous tes problèmes 😊.Avant de commencer dis moi ton prénom 😁.',
                        speed: Duration(milliseconds: 65)),
                  ],
                  onTap: () {
                    print("Tap Event");
                  },
                ),
              ),
            ),
            Visibility(
                visible: _fieldIsVisible,
                child: TextInputField(
                    hint: "Ton prénom",
                    controller: _nameController,
                    isPasswordfield: false)),
            Visibility(
              visible: _notSurnameTextInfosIsVisible,
              child: SizedBox(
                child: DefaultTextStyle(
                  style: const TextStyle(
                    fontSize: 13.0,
                    fontFamily: 'Agne',
                    color: Colors.red,
                  ),
                  child: AnimatedTextKit(
                    isRepeatingAnimation: false,
                    pause: Duration(milliseconds: 10000),
                    animatedTexts: [
                      TypewriterAnimatedText('Entre ton prénom stp😊.',
                          speed: Duration(milliseconds: 65)),
                    ],
                    onTap: () {
                      print("Tap Event");
                    },
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Visibility(
              visible: _btnIsVisible,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.08,
                child: _isLogin
                    ? SpinKitWave(
                        color: Color(0xFF43d0ca),
                      )
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            primary: Color(0xFF43d0ca)),
                        onPressed: () {
                          login(context);
                        },
                        child: Text("Commencer"),
                      ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.12,
            ),
            Visibility(
                visible: _btnIsVisible,
                child: Center(
                  child: Text(
                    "Developpé par Ingénieur Kinda",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.w400,
                        fontSize: 16),
                  ),
                ))
          ],
        ),
      )),
    ));
  }

  var _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  Future login(BuildContext context) async {
    var name = _nameController.text.trim().toLowerCase() + getRandomString(5);

    if (name != '') {
      setState(() {
        _isLogin = true;
      });
      AuthService _auth = AuthService();
      dynamic result = await _auth.signUpWithName(name);

      if (result == null) {
        setState(() {
          _isLogin = false;
        });
        Fluttertoast.showToast(
            msg: "Erreur de connexion.\nVérifier votre connexion internet.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red[400]!.withOpacity(
              0.5,
            ),
            textColor: Colors.white,
            fontSize: 16.0);
      } else {
        writeUserEmail('$name@gmail.com');
        Navigator.push(
            context,
            PageTransition(
                type: PageTransitionType.rightToLeftJoined,
                duration: Duration(milliseconds: 700),
                childCurrent: LoginScreen(),
                reverseDuration: Duration(milliseconds: 700),
                child: Passerel()));
      }
    } else {
      setState(() {
        _notSurnameTextInfosIsVisible = true;
      });
    }
  }
}
