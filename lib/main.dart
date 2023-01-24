import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:kadibot/services/firebase_services.dart';
import 'package:kadibot/services/tts.dart';
import 'package:kadibot/views/change_theme.dart';
import 'package:kadibot/views/login_screen.dart';
import 'package:kadibot/views/passerel.dart';
import 'package:provider/provider.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  TextToSpeech.initTTS();

  await Firebase.initializeApp();

  runApp(MultiProvider(
    providers: [
      StreamProvider.value(initialData: null, value: AuthService().user)
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  DarkThemeProvider themeChangeProvider = new DarkThemeProvider();

  @override
  void initState() {
    super.initState();
    getCurrentAppTheme();
  }

  void getCurrentAppTheme() async {
    themeChangeProvider.darkTheme =
        await themeChangeProvider.darkThemePreference.getTheme();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        return themeChangeProvider;
      },
      child: Consumer<DarkThemeProvider>(
        builder: (context, value, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: Styles.themeData(themeChangeProvider.darkTheme, context),
            home: Passerel(),
          );
        },
      ),
    );
  }
}
