import 'package:culinary_compass/models/myuser.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
  Future signInUserEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
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
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      return _myUserFromFirebaseUser(user!);
    } catch(e) {
      print(e.toString());
      return null;
    }
  }

  // method for signing out
  Future signOut() async {
    try {
      signOutGoogle(); // if user uses Google to sign in
      return await _auth.signOut(); // using Firebase's auth's signOut(), not our defined one
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

      // sign in
      return await _auth.signInWithCredential(credential);

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
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      print(e.toString());
      throw Exception("Exception");
    }
  }
}