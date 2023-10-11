import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../login_page.dart';

class AuthService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;



  Future<User?> register(String email, String password,
      BuildContext context) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      CollectionReference<Object?> usersCollection = firestore.collection(
          'users');

      DocumentReference<Object?> userDoc = usersCollection.doc(
          userCredential.user?.uid);
      userDoc.set({
        'email': userCredential.user!.email.toString(),
        'uid': userCredential.user!.uid,
      });
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.message.toString()), backgroundColor: Colors.red,));
    }
    return null;
  }


  Future<User?> login(String email, String password,
      BuildContext context) async {
    try {
      final UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      CollectionReference<Object?> usersCollection = firestore.collection(
          'users');

      DocumentReference<Object?> userDoc = usersCollection.doc(
          userCredential.user?.uid);
      userDoc.set({
        'email': userCredential.user?.email.toString(),
        'uid': userCredential.user?.uid,
      });
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        debugPrint('No user found for that email.');
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.message.toString()), backgroundColor: Colors.red,));
    }
    return null;
  }


  Future<User?> signInWithGoogle() async {
    try {
      GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser != null) {
        GoogleSignInAuthentication? googleAuth = await googleUser
            .authentication;
        AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithCredential(credential);
        CollectionReference<Object?> usersCollection = firestore.collection(
            'users');
        DocumentReference<Object?> userDoc = usersCollection.doc(
            userCredential.user?.uid);
        userDoc.set({
          'email': userCredential.user!.email,
          'uid': userCredential.user!.uid,
        });
        return userCredential.user;
      }
    } catch (e) {
      debugPrint('$e');
    }
    return null;
  }


  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  Future insertTodoUser(Timestamp create, String title, String time,
      bool isDone) async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    var ui = auth.currentUser?.uid;
    final CollectionReference collection = FirebaseFirestore.instance
        .collection('users');
    final DocumentReference document = collection.doc(ui);
    final CollectionReference subCollection = document.collection('todo');

    await subCollection.add({
      'create': create,
      'isDone': isDone,
      'time': time,
      'title': title,
    });
  }

  Future deleteUser(BuildContext context) async {
    try {
      await firebaseAuth.currentUser?.delete();
    } on FirebaseAuthException catch (e) {
      debugPrint('$e');

      if (e.code == "requires-recent-login") {
        await _reAuthenticateAndDelete();
      } else {
      }
    } catch (e) {
      debugPrint('$e');
    }
    var uid = firebaseAuth.currentUser?.uid;
    var docRef = FirebaseFirestore.instance.collection('users').doc(uid);
    await firebaseAuth.currentUser?.delete();
    await docRef.delete();
    if(context.mounted) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()), (
          route) => false);
    }
  }

  Future<void> _reAuthenticateAndDelete() async {
    try {
      final providerData = firebaseAuth.currentUser?.providerData.first;

      if (GoogleAuthProvider().providerId == providerData?.providerId) {
        await firebaseAuth.currentUser!
            .reauthenticateWithProvider(GoogleAuthProvider());
      }
      else if (EmailAuthProvider.PROVIDER_ID == providerData?.providerId) {
        await firebaseAuth.currentUser!
            .reauthenticateWithProvider(EmailAuthProvider as OAuthProvider);
      }

      await firebaseAuth.currentUser?.delete();
    } catch (e) {
      // Handle exceptions
    }
  }

  Future del(BuildContext context) async {
    try {
      await firestore.collection('users').doc(
          FirebaseAuth.instance.currentUser!.uid).delete();
      if(context.mounted) {
        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (context) => LoginScreen()), (
                route) => false);
      }
      await FirebaseAuth.instance.currentUser!.unlink(
          EmailAuthProvider.PROVIDER_ID);
      await FirebaseAuth.instance.currentUser!.unlink(
          GoogleAuthProvider.PROVIDER_ID);
    } catch (e) {
      debugPrint('$e');

    }
  }
}
