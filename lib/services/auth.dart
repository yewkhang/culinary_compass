import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:culinary_compass/models/myuser.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {

  // note: _auth --> _ to denote final property only in this class
  // for accessing any auth methods or properties, use this instance _auth

  // final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseAuth auth;

  AuthService({required this.auth});

  // to create a user object based on Firebase's User (this invocation is initially for verification)
  MyUser? _myUserFromFirebaseUser(User user) {
    return MyUser(
      username: user.email!.split("@")[0],
      uid: user.uid,
      bio: "No Bio",
      profileImageURL: "",
      friendsUID: List<String>.empty(growable: true),
      friendsUsername: List<String>.empty(growable: true)
    );
  }


  // stream to check for auth changes of user
  Stream<MyUser?> get user {
    return auth
      .authStateChanges() // gets Firebase's User
      .map((User? user) => _myUserFromFirebaseUser(user!)); // map to MyUser class
  }

  // method for signing in (email and password)
  Future signInUserEmail(String email, String password) async {
    try {
      UserCredential result = await auth.signInWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      return _myUserFromFirebaseUser(user!);
    } catch(e) {
      print(e.toString());
      return null;
    }
  }

  // method for register with email and password
  Future registerUserEmail(String email, String password) async {
    try {
      UserCredential result = await auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      createInitialFirestoreCollection(email, user!.uid);
      return _myUserFromFirebaseUser(user);
    } catch(e) {
      print(e.toString());
      return null;
    }
  }

  // method for signing out
  Future signOut() async {
    try {
      signOutGoogle(); // if user uses Google to sign in
      return await auth.signOut(); // using Firebase's auth's signOut(), not our defined one
    } catch(e) {
      print(e.toString());
      return null;
    }
  }

  // method for signing in with Google
  Future signInGoogle() async {
    try {

      // begin sign in process
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // obtain auth details from request
      final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;

      // create a new credential for user
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken
      );

      UserCredential result = await auth.signInWithCredential(credential);
      User? user = result.user;

      // logic for dealing with previous google sign-ins, to create firebase user collection
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance.collection('Users').doc(user!.email!).get();
      if (!documentSnapshot.exists) {
        createInitialFirestoreCollection(user.email!, user.uid);
      }

      // sign in
      return await auth.signInWithCredential(credential);

    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // method for signing out with Google
  Future signOutGoogle() async {
    try {
      await GoogleSignIn().signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
  
  // method for resetting password
  Future passwordReset(String email) async {
    try {
      await auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      print(e.toString());
      throw Exception("Exception");
    }
  }

  // method for creating user Firestore collection containing auth details
  Future<void> createInitialFirestoreCollection(String email, String uid) async {
    try {
      await FirebaseFirestore.instance
        .collection("Users")
        .doc(email)
        .set({
          "Username": email.split("@")[0],
          "Bio": "No Bio",
          "UID": uid,
          "Profile Image": "",
          "FriendsUID": List.empty(growable: true),
          "FriendsUsername": List.empty(growable: true)
        });
    } catch (e) {
      print(e.toString());
      throw Exception("Exception");
    }
  }
}