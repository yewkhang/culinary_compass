import 'package:culinary_compass/firebase_options.dart';
import 'package:culinary_compass/services/auth.dart';
import 'package:culinary_compass/wrapper.dart';
import 'package:culinary_compass/models/myuser.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';

// main.dart is the root widget file
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp(auth: AuthService(auth: FirebaseAuth.instance), imagePicker: ImagePicker()));
}

class MyApp extends StatelessWidget {
  final AuthService auth;
  final ImagePicker imagePicker;
  const MyApp({super.key, required this.auth, required this.imagePicker});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // by wrapping MaterialApp() inside Provider, all descendant widgets can access MyUser Stream
    return StreamProvider<MyUser?>.value(
      catchError: (_, __) {},
      initialData: null, // self-explanatory, set initial to nothing (null)
      value: AuthService(auth: FirebaseAuth.instance).user, // to access the MyUser Stream
      child: GetMaterialApp(
        home: Wrapper(imagePicker: imagePicker),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
