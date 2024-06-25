import 'package:culinary_compass/firebase_options.dart';
import 'package:culinary_compass/services/auth.dart';
import 'package:culinary_compass/wrapper.dart';
import 'package:culinary_compass/models/myuser.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';

// main.dart is the root widget file
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // by wrapping MaterialApp() inside Provider, all descendant widgets can access MyUser Stream
    return StreamProvider<MyUser?>.value(
      catchError: (_, __) {},
      initialData: null, // self-explanatory, set initial to nothing (null)
      value: AuthService().user, // to access the MyUser Stream
      child: GetMaterialApp(
        home: Wrapper(),
      ),
    );
  }
}
