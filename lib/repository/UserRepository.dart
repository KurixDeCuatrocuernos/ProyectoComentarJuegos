
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';

class UserRepository {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> _getCurrentUserData() async{
    String? uid = await _auth.currentUser?.uid;
    DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
    try {
      // Acceder a la colección de usuarios en Firestore
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();

      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>;
      } else {
        print('Usuario no encontrado en Firestore');
        return null;
      }
    } catch (e) {
      print('Error al obtener los datos del usuario: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> _getUserDataByUid(String uid) async{
    DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
    try {
      // Acceder a la colección de usuarios en Firestore
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();

      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>;
      } else {
        print('Usuario no encontrado en Firestore');
        return null;
      }
    } catch (e) {
      print('Error al obtener los datos del usuario: $e');
      return null;
    }
  }

  Future<String?> getUserNameByUid(String uid) async{
    DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
    try {
      // Acceder a la colección de usuarios en Firestore
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();

      if (userDoc.exists) {
        return userDoc['name'];
      } else {
        print('Usuario no encontrado en Firestore');
        return null;
      }
    } catch (e) {
      print('Error al obtener los datos del usuario: $e');
      return null;
    }
  }

}