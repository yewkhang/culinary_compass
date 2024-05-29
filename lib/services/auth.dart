import 'package:culinary_compass/models/myuser.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {

  // note: _auth --> _ to denote final property only in this class
  // for accessing any auth methods or properties, use this instance _auth
  final FirebaseAuth _auth = FirebaseAuth.instance;


  // create user object based on Firebase's User
  MyUser? _myUserFromFirebaseUser(User user) {
    return MyUser(uid: user.uid);
  //  return user != null ? MyUser(uid: user.uid) : null; (old code?)
  }


  // stream to check for auth changes of user
  Stream<MyUser?> get user {
    return _auth
      .authStateChanges() // gets Firebase's User
      .map((User? user) => _myUserFromFirebaseUser(user!)); // map to our simplified MyUser
  }


  // method for signing in (anonymously)
  Future signInAnon() async {
    // might have error
    try {
      UserCredential userCredentialAnon = await _auth.signInAnonymously();
      User? userAnon = userCredentialAnon.user;
      return _myUserFromFirebaseUser(userAnon!);
    } catch(e) {
      print(e.toString());
      return null;
    }
  }

  // method for signing in (email and password)

  // method for register with email and password

  // method for signing out
  Future signOut() async {
    try {
      return await _auth.signOut(); // using Firebase's auth's signOut(), not our defined one
    } catch(e) {
      print(e.toString());
      return null;
    }
  }
}