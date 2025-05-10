
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:game_box/auth/models/UserModel.dart';
import 'package:game_box/auth/models/UserProjection.dart';
import 'package:game_box/auth/services/AuthFirebaseRepository.dart';
import 'package:game_box/repository/CommentaryRepository.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_utils/get_utils.dart';

class UserRepository {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _collection = 'users';

  Future<UserModel?> _getCurrentUserData() async{
    String? uid = await _auth.currentUser?.uid;
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection(_collection)
          .doc(uid)
          .get();

      if (userDoc.exists) {
        return UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
      } else {
        print('Usuario no encontrado en Firestore');
        return null;
      }
    } catch (e) {
      print('Error al obtener los datos del usuario: $e');
      return null;
    }
  }

  Future<UserModel?> _getUserDataByUid(String uid) async{

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection(_collection)
          .doc(uid)
          .get();

      if (userDoc.exists) {
        return UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
      } else {
        print('Usuario no encontrado en Firestore');
        return null;
      }
    } catch (e) {
      print('Error al obtener los datos del usuario: $e');
      return null;
    }
  }

  Future<String?> getUserEmailByUid(String uid) async{
    try {
      DocumentSnapshot userdoc = await FirebaseFirestore.instance
          .collection(_collection)
          .doc(uid)
          .get();
      if (userdoc.exists) {
        return userdoc['email'];
      } else {
        return "Couldn't find the username from database";
      }
    } catch (error) {
      return "There was an error getting the username from database";
    }
  }

  Future<String?> getUserNameByUid(String uid) async{
    try {
      // Acceder a la colección de usuarios en Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection(_collection)
          .doc(uid)
          .get();

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

  Future<String?> getUserImageByUid(String uid) async {
    try {
     DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection(_collection)
         .doc(uid)
         .get();
     if (userDoc.exists) {
       if (userDoc['image'] != null){
         // print('IMAGEN RECOGIDA: ${userDoc['image']}');
         return userDoc['image'];
       } else {
         return null;
       }
     } else {
       print('Usuario no encontrado en Firestore');
       return null;
     }
   } catch (error) {
     print('Error al obtener los datos del usuario: $error');
     return null;
   }
  }
  
  Future<String?> updateName(String uid, String name) async {
    try {

      await FirebaseFirestore.instance
          .collection(_collection)
          .doc(uid)
          .update({'name': name});
      return null;
    } catch (error) {
      return "There was an error updating the name in database, but it isn't your fault";
    }
  }

  Future<String?> updateEmail(String email) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Enviar el correo de verificación
        await user.verifyBeforeUpdateEmail(email);
        print("Correo de verificación enviado a: $email");

        // Starts the pooling to check if the email was verified or not.
        await _checkEmailVerification(user);
        return null;
      } else {
        return "Couldn't update email, because the user isn't authenticated";
      }
    } catch (error) {
      return "There was an error updating the email, but it isn't your fault";
    }
  }

  /// Method to verify if user has verified its email
  Future<void> _checkEmailVerification(User user) async {
    // time interval between iterations (in ms)
    const int checkInterval = 5000;

    while (!user.emailVerified) {
      // waits the checkInterval between each verify
      await Future.delayed(Duration(milliseconds: checkInterval));

      // Reload the users state
      await user.reload();
      user = FirebaseAuth.instance.currentUser!;

      print("Verificando el correo...");
    }

    print("Correo verificado. Actualizando Firestore...");
    // when the email is verified it updates Firestore data
    await _updateUserInFirestore(user.uid, user.email!);
  }

  /// Method to Update Firestore User's email
  Future<void> _updateUserInFirestore(String uid, String email) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'email': email,
      });
      print("Correo en Firestore actualizado correctamente.");
    } catch (error) {
      print('Error al actualizar el correo en Firestore: $error');
    }
  }

  Future<String?> updatePassword(String uid, String pass) async {
    try {
      await FirebaseAuth.instance.currentUser?.updatePassword(pass);
      return null;
    } catch (error) {
      return "There was an error updating the password, but it isn't your fault";
    }
  }

  Future<String?> updateImage(String uid, String image) async {
    try {
      await FirebaseFirestore.instance
          .collection(_collection)
          .doc(uid)
          .update({'image': image});
      return null;
    } catch (error) {
      return "There was an error updating the user's image, but it isn't your fault";
    }
  }

  Future<double?> getWeightById(String id) async {
    try {
      final DocumentSnapshot response = await FirebaseFirestore.instance
          .collection(_collection)
          .doc(id)
          .get();
      if (response.exists) {
        final weight = response['weight'];

        if (weight is double) {
          return weight;
        } else if (weight is int) {
          return weight.toDouble();
        } else if (weight is String) {
          return double.tryParse(weight);
        } else {
          return null;
        }
      } else {
        return null;
      }
    } catch (error) {
      print("There was an error connecting with the database");
      return null;
    }
  }

  Future<String?> getUserRoleByUid(String uid) async {
    try {
      final DocumentSnapshot response = await FirebaseFirestore.instance
          .collection(_collection)
          .doc(uid)
          .get();
      if (response.exists) {
        print("EL ROLE RECOGIDO ES: ${response['role']}");
        return response['role'];
      } else {
        return null;
      }
    } catch (error) {
      print("Hubo un error al conectar a la base de datos: $error");
      return null;
    }
  }

  Future <List<UserModel>?> getAllUsers() async {
    //print("RECOGIENDO TODOS LOS DATOS DE LOS USUARIOS");
    try {
      final QuerySnapshot response = await FirebaseFirestore.instance
          .collection(_collection)
          .get();
      //print("EL FALLO OCURRE DESPUÉS DE LA CONSULTA");
      if (response.docs.isNotEmpty) {

        return response.docs.map((doc) {
          final data = doc.data();
          //print("SE HA RECOGIDO: $data");
          if(data is Map<String, dynamic>) {
            //print("Map recibido: $data");
            return UserModel.fromMap(data);
          } else {
            //print("Documento con Formato inesperado: $doc");
            return null;
          }
        }).whereType<UserModel>().toList();
      } else {
        return null;
      }
    } catch (error) {
      //print("EL ERROR OCURRE EN getAllUsers");
      print("Hubo un error al conectar a la base de datos: $error");
      return null;
    }
  }

  Future<List<UserModel>?> getUsersByQuery(String query) async {
    try{
      final QuerySnapshot response = await FirebaseFirestore.instance
          .collection(_collection)
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: query + '\uf8ff')
          .get();
      if (response.docs.isNotEmpty) {
        return response.docs.map((doc) {
          final data = doc.data();
          if(data is Map<String, dynamic>) {
            return UserModel.fromMap(data);
          } else {
            print("Documento con Formato inesperado: $doc");
            return null;
          }
        }).whereType<UserModel>().toList();
      } else {
        return [];
      }
    } catch (error) {
      print("EL ERROR OCURRE EN getUsersByQuery");
      print("Hubo un error al conectar a la base de datos: $error");
      return null;
    }
  }

  /// This method deletes a user and its comments from database (everything or nothing)
  /// if deletes everything returns true,
  /// if anything miss, deletes nothing and returns false
  Future<bool> deleteUserByUid(String uid) async {
    try {
      CommentaryRepository _commentRepo = CommentaryRepository();
      final batch = await FirebaseFirestore.instance.batch();

      await _commentRepo.deleteAllCommentsByUser(uid, batch);
      final userDocId = FirebaseFirestore.instance.collection(_collection).doc(uid);
      batch.delete(userDocId);
      await batch.commit();

      return true;
    } catch (error) {
      print("Hubo un error al conectar al a base de datos: $error");
      return false;
    }
  }

  Future<bool> banUserByUid(String uid) async {
    try {
      await FirebaseFirestore.instance
          .collection(_collection)
          .doc(uid)
          .update({
            'status': 5, // status 5 = banned
          });
      return true;
    } catch (error) {
      print("Hubo un error al conectar al a base de datos: $error");
      return false;
    }
  }

  Future<bool> unbanUserByUid(String uid) async {
    try {
      await FirebaseFirestore.instance
          .collection(_collection)
          .doc(uid)
          .update({
        'status': 0, // status 0 = regular
      });
      return true;
    } catch (error) {
      print("Hubo un error al conectar al a base de datos: $error");
      return false;
    }
  }

  Future<bool> updateUser(UserModel userData) async {
    String uid = userData.uid;
    print("USUARIO A MODIFICAR: $uid");
    try {
      final DocumentSnapshot oldUser = await FirebaseFirestore.instance
          .collection(_collection)
          .doc(uid)
          .get();
      if (oldUser.exists) {
        if (oldUser.data() != userData.toMap()) {
          await FirebaseFirestore.instance
              .collection(_collection)
              .doc(uid)
              .update(userData.toMap());
        }
        return true;
      } else {
        print("The user with uid: $uid doesn't exists");
        return false;
      }
    } catch (error) {
      print("Hubo un error al conectar con la base de datos: $error");
      return false;
    }
  }

  Future<List<UserProjection>> getUsersUidByQuery(String query) async {
    try {
      final QuerySnapshot response = await FirebaseFirestore.instance
          .collection(_collection)
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: query + '\uf8ff')
          .get();
      if (response.docs.isNotEmpty) {
        List<UserProjection> users = [];
        for(var user in response.docs) {
          users.add(UserProjection.fromMap(user.data() as Map<String, dynamic>));
        }
        return users;
      } else {
        print("NO SE ENCONTRARON USUARIOS CON ESE NOMBRE PARA BUSCAR COMENTARIOS");
        return [];
      }
    } catch (error) {
      print("HUBO UN PROBLEMA AL RECOGER LOS IDs DE USUARIO DE CLOS COMENTARIOS DE LA BASE DE DATOS");
      return [];
    }
  }

  Future<UserModel?> getUserByUid(String id) async {
    try {
      final DocumentSnapshot response = await FirebaseFirestore.instance
          .collection(_collection)
          .doc(id)
          .get();
      if (response.exists) {
        return UserModel.fromMap(response.data() as Map<String, dynamic>);
      } else {
        return null;
      }
    } catch (error) {
      print("HUBO UN ERROR AL RECOGER LOS DATOS DE USUARIO DE LA BASE DE DATOS");
      return null;
    }
  }

}