import 'package:firebase_auth/firebase_auth.dart';

class AuthService {

  // note: _auth --> _ to denote final property only in this class
  // for accessing any auth methods or properties, use this instance _auth
  final FirebaseAuth _auth = FirebaseAuth.instance;


  // method for signing in (anonymously)
  Future signInAnon() async {
    // might have error
    try {
      UserCredential userCredentialAnon = await _auth.signInAnonymously();
      User? userAnon = userCredentialAnon.user;
      return userAnon;
    } catch(e) {
      print(e.toString());
      return null;
    }
  }

  // method for signing in (email and password)

  // method for register with email and password

  // method for signing out
}