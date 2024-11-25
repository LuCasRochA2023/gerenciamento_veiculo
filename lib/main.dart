import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_projeto_p2/dao_firestore.dart';
import 'package:flutter_projeto_p2/firebase_options.dart';
import 'package:flutter_projeto_p2/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  DaoFirestore.inicializa();
  runApp(Login());


}

