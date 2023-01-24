import 'dart:convert';

import 'package:avatar_glow/avatar_glow.dart';

import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

import 'package:flutter_tts/flutter_tts.dart';

import 'package:kadibot/services/api_services.dart';
import 'package:kadibot/models/chat_model.dart';
import 'package:kadibot/services/firebase_services.dart';
import 'package:kadibot/views/change_theme.dart';
import 'package:kadibot/views/constants/colors.dart';

import 'package:kadibot/views/settings_screen.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'package:flutter_advanced_networkimage_2/provider.dart';
import 'package:flutter_advanced_networkimage_2/transition.dart';
import 'package:video_player/video_player.dart';

class ChatPage extends StatefulWidget {
  final List<ChatMessage>? chatStream;
  final String? chatListId;

  ChatPage({
    Key? key,
    this.chatStream,
    this.chatListId,
  });
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController _tec = TextEditingController();
  ScrollController scrollController = ScrollController();
  bool isRecording = false, isSending = false;
  FlutterTts tts = FlutterTts();

  List<ChatMessage> messages = [];
  String discussionId = '';
  String chatListId = '';
  SpeechToText speechToText = SpeechToText();
  var text = "";
  var isListening = false;
  var isResponding = false;

  void initState() {
    super.initState();
    readDiscussionId().then((String result) {
      setState(() {
        discussionId = result;
      });
    });

    if (widget.chatListId == '') {
      readchatListId().then((String result) {
        setState(() {
          chatListId = result;
        });
      });
    }
    setState(() {
      messages = widget.chatStream!;
      chatListId = widget.chatListId!;
    });
  }

  void showSettingPage(
    BuildContext context,
  ) {
    showModalBottomSheet(
        backgroundColor: Colors.black.withOpacity(0.7),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
        context: context,
        isScrollControlled: true,
        builder: (context) => SettingPage());
  }

  void dispose() {
    super.dispose();
    tts.stop();
  }

  optionsList(theme) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
          500,
          MediaQuery.of(context).size.height * 0.1,
          4,
          20), //here you can specify the location,
      items: [
        PopupMenuItem(
          value: 0,
          onTap: () {},
          child: Container(
              child: Row(
            children: [
              Icon(Icons.info_outline),
              SizedBox(
                width: 10,
              ),
              Text(
                "À propos",
                style: TextStyle(
                  fontSize: 17,
                ),
              )
            ],
          )),
        ),
      ],
    ).then((value) {
      if (value == 0) {
        showSettingPage(context);
      } else {}
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leadingWidth: 45,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            padding: EdgeInsets.all(10),
            child: Icon(Icons.arrow_back),
          ),
        ),
        title: Text("Assistante Mathilde"),
        centerTitle: true,
        actions: [
          InkWell(
            onTap: () {
              optionsList(themeChange.darkTheme);
            },
            child: Container(
              padding: EdgeInsets.all(10),
              child: Icon(Icons.more_vert),
            ),
          ),
          SizedBox(
            width: 5,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage(themeChange.darkTheme
                    ? 'assets/dark-crop.png'
                    : 'assets/light-crop.jpg'))),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                controller: scrollController,
                reverse: true,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  List<ChatMessage> reversedMessages =
                      messages.reversed.toList();

                  return ChatBubble(chat: reversedMessages[index]);
                },
              ),
            ),
            SizedBox(
              height: 10,
            ),
            isSending
                ? LinearProgressIndicator(
                    backgroundColor: Colors.grey[100],
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF43d0ca)),
                  )
                : SizedBox(),
            Container(
              color: themeChange.darkTheme ? Colors.white24 : Colors.black26,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.all(5),
                      padding: EdgeInsets.fromLTRB(10, 0, 5, 0),
                      decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(20)),
                      child: TextField(
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                            hintStyle: TextStyle(color: Colors.black),
                            hintText: 'Ecrire ici',
                            border: InputBorder.none),
                        controller: _tec,
                      ),
                    ),
                  ),
                  Container(
                      height: 40,
                      margin: EdgeInsets.fromLTRB(5, 5, 10, 5),
                      decoration: BoxDecoration(boxShadow: [
                        BoxShadow(
                            color: isRecording
                                ? (themeChange.darkTheme
                                    ? Colors.black
                                    : Colors.white)
                                : (themeChange.darkTheme
                                    ? Colors.white12
                                    : Colors.black12),
                            spreadRadius: 4)
                      ], color: Color(0xFF43d0ca), shape: BoxShape.circle),
                      child: AvatarGlow(
                        endRadius: 30.0,
                        animate: isListening,
                        duration: const Duration(milliseconds: 2000),
                        glowColor: bgColor,
                        repeat: true,
                        repeatPauseDuration: const Duration(milliseconds: 100),
                        showTwoGlows: true,
                        child: GestureDetector(
                          onTapDown: (details) async {
                            if (!isListening) {
                              var available = await speechToText.initialize();

                              if (available) {
                                setState(() {
                                  isListening = true;
                                  speechToText.listen(onResult: ((result) {
                                    if (result.recognizedWords.isNotEmpty) {
                                      setState(() {
                                        text = result.recognizedWords + " ?";
                                      });
                                    } else {}
                                  }));
                                });
                              }
                            }
                          },
                          onTapUp: ((details) async {
                            sendAudioMsg(
                              discussionId,
                              chatListId,
                            );
                          }),
                          child: CircleAvatar(
                            backgroundColor: Color(0xFF43d0ca),
                            radius: 35,
                            child: Icon(
                              isListening ? Icons.mic : Icons.mic_none,
                              color: themeChange.darkTheme
                                  ? Colors.black
                                  : Colors.white,
                            ),
                          ),
                        ),
                      )),
                  Container(
                    height: 40,
                    margin: EdgeInsets.fromLTRB(5, 5, 10, 5),
                    decoration: BoxDecoration(
                        color: Color(0xFF43d0ca), shape: BoxShape.circle),
                    child: IconButton(
                      icon: Icon(
                        Icons.send,
                        color:
                            themeChange.darkTheme ? Colors.black : Colors.white,
                        size: 20,
                      ),
                      onPressed: () {
                        sendMsg(
                          discussionId,
                          chatListId,
                        );
                        _tec.clear();
                      },
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  sendMsg(
    String discussionId,
    String chatListId,
  ) async {
    setState(() {
      isSending = true;
    });

    print('here');

    if (_tec.text.trim().isNotEmpty) {
      FlutterRingtonePlayer.play(fromAsset: "assets/user-send.m4a");

      if (messages.isEmpty) {
        messages.add(
            ChatMessage(text: _tec.text.trim(), type: "text", user: 'user'));
        var result = DataBaseService().addDisscussion(discussionId, messages);
        setState(() {
          chatListId = result;
        });
      } else {
        messages.add(
            ChatMessage(text: _tec.text.trim(), type: "text", user: 'user'));
        DataBaseService()
            .updateDisscussionList(discussionId, chatListId, messages);
      }
      scrollController.animateTo(0.0,
          duration: Duration(milliseconds: 500), curve: Curves.bounceInOut);
      setState(() {
        isSending = false;
        isResponding = true;
      });

      var msg = await ApiServices.sendMessage(_tec.text.trim());
      msg = msg.trim();
      FlutterRingtonePlayer.play(fromAsset: "assets/bot-send.m4a");

      if (messages.isEmpty) {
        messages.add(ChatMessage(text: msg, type: "text", user: 'bot'));
        var result = DataBaseService().addDisscussion(discussionId, messages);

        setState(() {
          chatListId = result;
        });
      } else {
        messages.add(ChatMessage(text: msg, type: "text", user: 'bot'));
        DataBaseService()
            .updateDisscussionList(discussionId, chatListId, messages);
      }

      scrollController.animateTo(0.0,
          duration: Duration(milliseconds: 500), curve: Curves.bounceInOut);

      setState(() {
        isResponding = false;
      });
    } else {
      print("Hello");
    }
  }

  sendAudioMsg(
    String discussionId,
    String chatListId,
  ) async {
    setState(() {
      isSending = true;

      isListening = false;
    });

    if (text.trim().isNotEmpty) {
      FlutterRingtonePlayer.play(fromAsset: "assets/user-send.m4a");
      if (messages.isEmpty) {
        messages.add(
            ChatMessage(text: _tec.text.trim(), type: "audio", user: 'user'));
        var result = DataBaseService().addDisscussion(discussionId, messages);
        setState(() {
          chatListId = result;
        });
      } else {
        messages.add(
            ChatMessage(text: _tec.text.trim(), type: "audio", user: 'user'));
        DataBaseService()
            .updateDisscussionList(discussionId, chatListId, messages);
      }

      scrollController.animateTo(0.0,
          duration: Duration(milliseconds: 500), curve: Curves.bounceInOut);
      setState(() {
        isSending = false;
        isResponding = true;
      });

      var msg = await ApiServices.sendMessage(text.trim());
      msg = msg.trim();
      FlutterRingtonePlayer.play(fromAsset: "assets/bot-send.m4a");

      if (messages.isEmpty) {
        messages.add(ChatMessage(text: msg, type: "audio", user: 'bot'));
        var result = DataBaseService().addDisscussion(discussionId, messages);
        setState(() {
          chatListId = result;
        });
      } else {
        messages.add(ChatMessage(text: msg, type: "audio", user: 'bot'));
        DataBaseService()
            .updateDisscussionList(discussionId, chatListId, messages);
      }
      scrollController.animateTo(0.0,
          duration: Duration(milliseconds: 500), curve: Curves.bounceInOut);

      setState(() {
        isResponding = false;
        text = '';
      });
    } else {
      print("Hello");
    }
  }
}

class ChatBubble extends StatefulWidget {
  final ChatMessage chat;
  ChatBubble({
    super.key,
    required this.chat,
  });

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  FlutterTts tts = FlutterTts();
  bool isPlayingMsg = false;

  List<String?> _imageLinks = [];
  List<String?> _videoLinks = [];
  List<VideoPlayerController> _controllers = [];

  void initState() {
    super.initState();
    setState(() {
      _imageLinks = _extractImageLinks(widget.chat.text.toString());
      _videoLinks = _extractVideoLinks(widget.chat.text.toString());
      _controllers = _videoLinks
          .map((link) => VideoPlayerController.network(link!))
          .toList();
      _controllers.forEach(
          (controller) => controller.initialize().then((_) => setState(() {})));
    });

    print("Images: " + _imageLinks.toString());
  }

  @override
  void dispose() {
    _controllers.forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var day = DateTime.now().day.toString();
    var month = DateTime.now().month.toString();
    var year = DateTime.now().year.toString().substring(2);
    var date = day + '-' + month + '-' + year;
    var hour = DateTime.now().hour;
    var min = DateTime.now().minute;
    var ampm;
    if (hour > 12) {
      hour = hour % 12;
      ampm = ' pm';
    } else if (hour == 12) {
      ampm = ' pm';
    } else if (hour == 0) {
      hour = 12;
      ampm = ' am';
    } else {
      ampm = ' am';
    }
    return widget.chat.type == 'audio'
        ? Padding(
            padding: EdgeInsets.only(
                top: 8,
                left: ((widget.chat.user == 'user') ? 64 : 10),
                right: ((widget.chat.user == 'user') ? 10 : 64)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor:
                      widget.chat.user == 'bot' ? Colors.white : bgColor,
                  child: widget.chat.user == 'bot'
                      ? ClipOval(
                          child: Image.asset(
                            "assets/icon.png",
                          ),
                        )
                      : Icon(
                          Icons.person,
                          color: Colors.white,
                        ),
                ),
                const SizedBox(
                  width: 12,
                ),
                Expanded(
                    child: Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                      color: widget.chat.user == 'bot' ? Colors.white : bgColor,
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                          bottomLeft: Radius.circular(12))),
                  child: GestureDetector(
                      onTap: () async {
                        play(widget.chat.text!);
                      },
                      onSecondaryTap: () {},
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Icon(
                                isPlayingMsg ? Icons.pause : Icons.play_arrow,
                                color: Colors.black,
                              ),
                              Text(
                                'Audio-${DateTime.now().hour}: ${DateTime.now().minute}',
                                maxLines: 10,
                                style: TextStyle(color: Colors.black),
                              ),
                            ],
                          ),
                          Text(
                            date +
                                " " +
                                hour.toString() +
                                ":" +
                                min.toString() +
                                ampm,
                            style: TextStyle(fontSize: 10, color: Colors.black),
                          )
                        ],
                      )),
                ))
              ],
            ),
          )
        : Padding(
            padding: EdgeInsets.only(
                top: 8,
                left: ((widget.chat.user == 'user') ? 64 : 10),
                right: ((widget.chat.user == 'user') ? 10 : 64)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor:
                      widget.chat.user == 'bot' ? Colors.white : bgColor,
                  child: widget.chat.user == 'bot'
                      ? ClipOval(
                          child: Image.asset(
                            "assets/icon.png",
                          ),
                        )
                      : Icon(
                          Icons.person,
                          color: Colors.white,
                        ),
                ),
                const SizedBox(
                  width: 12,
                ),
                Expanded(
                    child: Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                      color: widget.chat.user == 'bot' ? Colors.white : bgColor,
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                          bottomLeft: Radius.circular(12))),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.chat.text!,
                          style: TextStyle(
                              color: widget.chat.user == 'bot'
                                  ? chatBgColor
                                  : textColor,
                              fontSize: 15,
                              fontWeight: widget.chat.user == 'bot'
                                  ? FontWeight.w600
                                  : FontWeight.w400),
                        ),
                        if (_imageLinks.length > 0)
                          Container(
                            height: MediaQuery.of(context).size.height * 0.3,
                            child: ListView.builder(
                              itemCount: _imageLinks.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  padding: EdgeInsets.all(8.0),
                                  child: TransitionToImage(
                                    image: AdvancedNetworkImage(
                                      _imageLinks[index]!,
                                      useDiskCache: true,
                                    ),
                                    loadingWidget: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                );
                              },
                            ),
                          ),
                        if (_videoLinks.length > 0)
                          Container(
                            height: MediaQuery.of(context).size.height * 0.3,
                            child: ListView.builder(
                              itemCount: _videoLinks.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  padding: EdgeInsets.all(8.0),
                                  child: AspectRatio(
                                    aspectRatio:
                                        _controllers[index].value.aspectRatio,
                                    child: VideoPlayer(_controllers[index]),
                                  ),
                                );
                              },
                            ),
                          )
                      ]),
                ))
              ],
            ),
          );
  }

  void play(String msg) async {
    setState(() {
      isPlayingMsg = true;
    });
    await tts.speak(msg);
  }

  void stop() async {
    var result = await tts.stop();
    if (result == 1) {
      setState(() {
        isPlayingMsg = false;
      });
    }
  }

  List<String?> _extractImageLinks(String text) {
    // Utilisez une expression régulière pour extraire les liens d'images
    RegExp exp = RegExp(
        r"(https?|ftp|file)://[-A-Za-z0-9+&@#/%?=~_|!:,.;]+[-A-Za-z0-9+&@#/%=~_|]");
    Iterable<RegExpMatch> matches = exp.allMatches(text);
    return matches.map((match) => match.group(0)).toList();
  }

  List<String?> _extractVideoLinks(String text) {
    // Utilisez une expression régulière pour extraire les liens de vidéos
    RegExp exp = RegExp(
        r"(https?|ftp|file)://[-A-Za-z0-9+&@#/%?=~_|!:,.;]+[-A-Za-z0-9+&@#/%=~_|]");
    Iterable<RegExpMatch> matches = exp.allMatches(text);
    return matches.map((match) => match.group(0)).toList();
  }
}
