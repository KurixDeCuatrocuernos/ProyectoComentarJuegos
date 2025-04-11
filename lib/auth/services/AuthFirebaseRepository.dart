
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:game_box/firebase_options.dart' as FirebaseOptions;

class AuthFirebaseRepository {

  Future<User?> registerWithEmailAndPassword ({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
      );
      User? user = userCredential.user;


      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': name,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(), // creation account's date
          'weight': 1.0, // User's default weight
          'image': null, // User's default image
          'role': "USER", // User's default role
        });
      }


      return user;
    } catch (e) {
      print(e);
      return null;
    }
  } //registerWithEmailAndPassword

  Future<User?> loginWithEmailAndPassword ({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
      );
      User? user = userCredential.user;
      return user;
    } catch (e) {
      print(e);
      return null;
    }
  } //loginWithEmailAndPassword



  Future<User?> signInWithGoogle() async {
    print("...Trying to singing with google");
    try {

      final GoogleSignIn _googleSignIn = GoogleSignIn(
        clientId: FirebaseOptions.DefaultFirebaseOptions.googleWebClientId,  // Usamos el clientID aquí
      );

      GoogleSignInAccount? googleUser = await _googleSignIn.signInSilently(); // try to sign in with the google account if the user is already logged

      if (googleUser == null) {
        googleUser = await _googleSignIn.signIn(); // Try to signIn if the user didn't sign in with google
      };

      if (googleUser == null) return null; //User cancels Sign in

      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      print("Sign in with google completed");
      return await FirebaseAuth.instance
          .signInWithCredential(credential)
          .then((UserCredential userCredential) {
        User? user = userCredential.user;
        return user;
      });
    } on FirebaseAuthException catch (fe) {
      throw fe;

    } catch(e) {
      print("Error while sign in with google: $e");
      return null;
    }
  }  //signInWithGoogle

  Future<bool> emailExists(String? email) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return true; // The email is in database
      } else {
        return false; // The email is not in database
      }
    } catch (e) {
      print('Error al verificar el email: $e');
      return false;
    }
  }

}  //AuthFirebaseRepository