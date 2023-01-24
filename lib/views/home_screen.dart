import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:kadibot/models/chat_model.dart';
import 'package:kadibot/services/firebase_services.dart';
import 'package:kadibot/views/chat_screen.dart';
import 'package:kadibot/views/constants/colors.dart';
import 'package:kadibot/views/settings_screen.dart';

import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'change_theme.dart';

class HomeSCreen extends StatefulWidget {
  final String userEmail;

  const HomeSCreen({Key? key, required this.userEmail});
  @override
  _HomeSCreenState createState() => _HomeSCreenState();
}

class _HomeSCreenState extends State<HomeSCreen> {
  List<ChatList> chatList = [];
  @override
  void initState() {
    super.initState();
    print("UserId" + widget.userEmail);
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

  DataBaseService _services = DataBaseService();
  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        leadingWidth: 45,
        centerTitle: true,
        leading: CircleAvatar(
          backgroundColor: Colors.white,
          child: ClipOval(
              child: Image.asset(
            "assets/icon.png",
          )),
        ),
        title: Text("Assistante Mathilde"),
        actions: [
          IconButton(
            icon: Icon(Icons.power_settings_new),
            onPressed: () async {},
          ),
          // CONTRIBUTION ON THIS IS WELCOMED FOR FLUTTER ENTHUSIATS
          InkWell(
            onTap: () {
              optionsList(themeChange.darkTheme);
            },
            child: Container(
              padding: EdgeInsets.all(10),
              child: Icon(Icons.more_vert),
            ),
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
        child: Stack(
          children: [
            buildFloatingSearchBar(themeChange.darkTheme),
            Positioned(
              top: 70,
              child: Container(
                  height: MediaQuery.of(context).size.height * 0.8,
                  width: MediaQuery.of(context).size.width,
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('discussions')
                        .where('user', isEqualTo: widget.userEmail)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasError) {
                        return Text('Something went wrong');
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return SpinKitCircle(
                          color: Color(0xFF43d0ca),
                        );
                      }

                      return ListView(
                        physics: BouncingScrollPhysics(),
                        children: snapshot.data!.docs
                            .map((DocumentSnapshot document) {
                          Map<String, dynamic> data =
                              document.data()! as Map<String, dynamic>;

                          print(document.id);
                          writeDiscussionId(document.id);

                          return Container(
                              height: MediaQuery.of(context).size.height * 0.9,
                              child: buildChatList(
                                document.id,
                                data["user"],
                              ));
                        }).toList(),
                      );
                    },
                  )),
            ),
            buildFloatingSearchBar(themeChange.darkTheme),
          ],
        ),
      ),
      // CONTRIBUTION ON THIS IS WELCOMED FOR FLUTTER ENTHUSIATS
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF43d0ca),
        onPressed: () {
          Navigator.push(
              context,
              PageTransition(
                  type: PageTransitionType.rightToLeftJoined,
                  duration: Duration(milliseconds: 700),
                  reverseDuration: Duration(milliseconds: 700),
                  childCurrent: HomeSCreen(userEmail: widget.userEmail),
                  child: ChatPage(
                    chatStream: [],
                    chatListId: '',
                  )));
        },
        child: Icon(
          Icons.message,
          color: Colors.white,
        ),
      ),
    );
  }

  buildChatList(String docId, String user) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("discussions")
          .doc(docId)
          .collection("chatList")
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("");
        }

        return snapshot.data!.size == 0
            ? Center(
                child: Text("Aucune conversation, Démarrer une nouvelle ."),
              )
            : ListView(
                physics: BouncingScrollPhysics(),
                children: snapshot.data!.docs.map((DocumentSnapshot document) {
                  Map<String, dynamic> data =
                      document.data()! as Map<String, dynamic>;

                  print(data.length);
                  return DiscussionItem(
                      userEmail: widget.userEmail,
                      discussion: List<ChatMessage>.from(data['chatStream']
                          .map((x) => ChatMessage.fromJson(x))),
                      libelle: data['libelle'],
                      discussionId: docId,
                      chatListId: document.id);
                }).toList(),
              );
      },
    );
  }

  // CONTRIBUTION ON THIS IS WELCOMED FOR FLUTTER ENTHUSIATS
  Widget buildFloatingSearchBar(theme) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    List<dynamic> searchResult = [];
    return FloatingSearchBar(
      borderRadius: BorderRadius.circular(30),
      hint: 'Rechercher une discussion...',
      hintStyle: TextStyle(color: Colors.grey),
      queryStyle: TextStyle(color: Colors.black),
      scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
      transitionDuration: const Duration(milliseconds: 500),
      transitionCurve: Curves.easeInOut,
      physics: const BouncingScrollPhysics(),
      axisAlignment: isPortrait ? 0.0 : -1.0,
      openAxisAlignment: 0.0,
      width: isPortrait ? 600 : 500,
      backgroundColor: Colors.white,
      debounceDelay: const Duration(milliseconds: 500),
      onQueryChanged: (query) {},
      backdropColor: Color(0xFF43d0ca),
      automaticallyImplyBackButton: false,
      transition: CircularFloatingSearchBarTransition(),
      actions: [
        FloatingSearchBarAction.back(
          color: Color(0xFF43d0ca),
          showIfClosed: false,
        ),
        FloatingSearchBarAction.searchToClear(
          color: Color(0xFF43d0ca),
          showIfClosed: true,
        ),
      ],
      builder: (context, transition) {
        return ClipRRect(
          child: Material(
              color: Colors.white,
              elevation: 4.0,
              child: Container(
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(20)),
                height: MediaQuery.of(context).size.height * 0.9,
                child: ListView.builder(
                  itemCount: 0,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {},
                      child: Container(
                        margin:
                            EdgeInsets.symmetric(horizontal: 38, vertical: 10),
                        padding: EdgeInsets.all(10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: theme ? Colors.black : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(blurRadius: 2, color: Colors.grey)
                            ]),
                        height: 60,
                        width: 300,
                        child: Text(
                          ' ',
                          maxLines: 3,
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                    );
                  },
                ),
              )),
        );
      },
    );
  }
}

class DiscussionItem extends StatefulWidget {
  final String libelle;
  final String discussionId;
  final String chatListId;
  final List<ChatMessage> discussion;

  final String userEmail;

  DiscussionItem(
      {super.key,
      required this.discussion,
      required this.userEmail,
      required this.libelle,
      required this.chatListId,
      required this.discussionId});

  @override
  State<DiscussionItem> createState() => _DiscussionItemState();
}

class _DiscussionItemState extends State<DiscussionItem> {
  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      color: themeChange.darkTheme ? Color(0xFF272d29) : Color(0xFF43d0ca),
      child: Padding(
        padding: EdgeInsets.all(5),
        child: Container(
            child: ListTile(
          leading: GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    PageTransition(
                        type: PageTransitionType.rightToLeftJoined,
                        duration: Duration(milliseconds: 700),
                        reverseDuration: Duration(milliseconds: 700),
                        childCurrent: HomeSCreen(userEmail: widget.userEmail),
                        child: ChatPage(
                          chatStream: widget.discussion,
                          chatListId: widget.chatListId,
                        )));
              },
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  widget.libelle
                      .substring(0,
                          widget.libelle.length < 2 ? widget.libelle.length : 2)
                      .toUpperCase(),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              )),
          title: GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  PageTransition(
                      type: PageTransitionType.rightToLeftJoined,
                      duration: Duration(milliseconds: 700),
                      reverseDuration: Duration(milliseconds: 700),
                      childCurrent: HomeSCreen(userEmail: widget.userEmail),
                      child: ChatPage(
                        chatStream: widget.discussion,
                        chatListId: widget.chatListId,
                      )));
            },
            child: Text(
              widget.libelle,
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          trailing: InkWell(
              child: Icon(
            Icons.close,
            color: Colors.white,
            size: 25,
          )),
        )),
      ),
    );
  }
}
