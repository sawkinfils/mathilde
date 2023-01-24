import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:kadibot/models/chat_model.dart';

//creation d'un fichier en local pour les informations de l'espace de discussion
writeChatListId(String email) async {
  final Directory directory = await getApplicationDocumentsDirectory();
  final File file = File('${directory.path}/chatList.txt');
  await file.writeAsString(email);
}

//creation d'un fichier en local pour les informations de l'espace de discussion
writeDiscussionId(String email) async {
  final Directory directory = await getApplicationDocumentsDirectory();
  final File file = File('${directory.path}/discussion.txt');
  await file.writeAsString(email);
}

//creation d'un fichier en local pour les informations de l'utilisateur
writeUserEmail(String email) async {
  final Directory directory = await getApplicationDocumentsDirectory();
  final File file = File('${directory.path}/user.txt');
  await file.writeAsString(email);
}

//reccupération  des informations de l'espace de discussion
Future<String> readDiscussionId() async {
  String text = '';
  try {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/discussion.txt');
    text = await file.readAsString();
  } catch (e) {
    print("Couldn't read file");
  }
  return text;
}

//reccupération  des informations de l'espace de discussion
Future<String> readchatListId() async {
  String text = '';
  try {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/chatList.txt');
    text = await file.readAsString();
  } catch (e) {
    print("Couldn't read file");
  }
  return text;
}

//reccupération  des informations de l'utilisateur
Future<String> readUserEmail() async {
  String text = '';
  try {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/user.txt');
    text = await file.readAsString();
  } catch (e) {
    print("Couldn't read file");
  }
  return text;
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference users = FirebaseFirestore.instance.collection('users');
  CollectionReference discussions =
      FirebaseFirestore.instance.collection('discussions');

  Stream<User?> get user => _auth.authStateChanges();

//Enrollement d'un nouvel utilisateur
  Future signUpWithName(
    String name,
  ) async {
    try {
      //Creation d'un nouvel utilisateur avec une adresse email et un mot de passe
      final UserCredential authResult =
          await _auth.createUserWithEmailAndPassword(
              email: '$name@gmail.com', password: '$name@12345678');

      //Renvoyer l'utilisateur couramment  connecté en sortie
      final User? user = await authResult.user;
      addNewUser(name);

      addDiscussionsSpace("$name@gmail.com");
      return user;
    } catch (error) {
      print(error);
    }
  }
//Ajout d'un nouvel utilisateur

  void addNewUser(String name) {
    users.add({
      "name": '$name',
      "password": '$name@12345678',
      "email": '$name@gmail.com'
    });
  }

  void addDiscussionsSpace(String user) {
    discussions.add({
      "user": '$user',
      "discussions": [],
    });
  }
  //Deconnexion de l'utilisateur connecté

  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      return null;
    }
  }
}

class DataBaseService {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference discussions =
      FirebaseFirestore.instance.collection('discussions');

  void registerDiscussion(String user, String libelle, ChatMessage chat) {
    discussions.add({
      "user": '$user',
      "discussions": [
        {
          "libelle": '$libelle',
          "chatStream": [
            {"type": chat.type, "user": chat.user, "text": chat.text}
          ]
        }
      ],
    });
  }

  void updateDisscussionList(String discussionId, String chatListId, messages) {
    discussions.doc(discussionId).collection("chatList").doc(chatListId).update(
        {"chatStream": messages.map((message) => message.toJson()).toList()});
  }

  var _chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
  String addDisscussion(String discussionId, messages) {
    var libelle = getRandomString(2);
    String chatListId = getRandomString(20);

    writeChatListId(chatListId);
    discussions.doc(discussionId).collection("chatList").doc(chatListId).set({
      "libelle": messages
          .map((message) => message.toJson())
          .toList()[0]['text']
          .toString()
          .split(' ')
          .first,
      "chatStream": messages.map((message) => message.toJson()).toList()
    });

    return chatListId;
  }
}
