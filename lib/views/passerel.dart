import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kadibot/services/firebase_services.dart';
import 'package:kadibot/views/home_screen.dart';
import 'package:kadibot/views/login_screen.dart';

import 'package:provider/provider.dart';

class Passerel extends StatefulWidget {
  Passerel({
    super.key,
  });

  @override
  State<Passerel> createState() => _PasserelState();
}

class _PasserelState extends State<Passerel> {
  String userEmail = '';

  void initState() {
    super.initState();
    readUserEmail().then((String result) {
      setState(() {
        userEmail = result;
      });
    });

    print("UserEmail from Passerelle: " + userEmail);
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    return user == null
        ? LoginScreen()
        : HomeSCreen(
            userEmail: userEmail,
          );
  }
}
