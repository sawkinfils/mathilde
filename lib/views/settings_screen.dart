import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:kadibot/views/change_theme.dart';
import 'package:provider/provider.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  String? mounthSelected;
  bool darkMode = false;

  final List<String> language = [
    'Français',
  ];
  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return Scaffold(
      body: Container(
          margin: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.06),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "À propos",
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              Container(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Langue",
                        style: TextStyle(fontSize: 18),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 10),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              textStyle: TextStyle(color: Colors.black)),
                          onPressed: () {},
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton2(
                              isExpanded: true,
                              hint: Text(
                                'Français',
                                style: TextStyle(color: Colors.black),
                              ),
                              items: language
                                  .map((item) => DropdownMenuItem<String>(
                                        value: item,
                                        child: Text(
                                          item,
                                          style: const TextStyle(
                                            fontSize: 14,
                                          ),
                                        ),
                                      ))
                                  .toList(),
                              value: mounthSelected,
                              onChanged: (value) {
                                setState(() {
                                  mounthSelected = value;
                                });
                              },
                              buttonHeight: 40,
                              buttonWidth: 100,
                              itemHeight: 40,
                            ),
                          ),
                        ),
                      ),
                    ]),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Mode sombre",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Switch(
                          activeColor: Color(0xFF43d0ca),
                          value: themeChange.darkTheme,
                          onChanged: (bool value) {
                            themeChange.darkTheme = value;
                          })
                    ]),
              ),
              SizedBox(
                height: 30,
              ),
              Center(
                child: Text(
                  "Avec Mathilde profitez de la vie😋",
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.w500),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Container(
                child: RichText(
                    text: TextSpan(
                        style: TextStyle(
                            fontSize: 16,
                            color: themeChange.darkTheme
                                ? Colors.white
                                : Colors.black),
                        text: "Ceci est la première ",
                        children: [
                      TextSpan(
                          text: "version 1.0.0\n",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: "Nous continuerons à "),
                      TextSpan(
                          text: "developper l'application, ",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(
                          text: "afin d'ajouter d'autres fonctionalités.\n\n"),
                      TextSpan(text: "fonctionnalités à venir :\n"),
                    ])),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "- Demander du contenu multimedia (musique,vidéos,images...) 🎶 📽 🖼",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "- Changer la langue de l'application",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "- Contrôle vocal de votre smartphone 🗣",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "- et plus...",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ]),
              ),
              SizedBox(
                height: 40,
              ),
              Center(
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(
                    "All data provided by ",
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                  Text(
                    "OpenAI",
                    style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold),
                  ),
                  Column(
                    children: [
                      Image.asset(
                        "assets/logo (2).png",
                        scale: 15,
                      )
                    ],
                  )
                ]),
              ),
              Expanded(child: Container()),
              Center(
                child: Text(
                  "Developpé par Ingénieur Kinda",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16),
                ),
              ),
              SizedBox(
                height: 10,
              )
            ],
          )),
    );
  }
}
