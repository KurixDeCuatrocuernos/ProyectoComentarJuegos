
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {

  final String uid;
  final String email;
  final String name;
  final String role;
  final int status;
  final double weight;
  final String? image;
  final Timestamp? createdAt;

  /// Constructor para UsuarioModel
  const UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    required this.status,
    required this.weight,
    this.image,
    this.createdAt,
  });

  /// Metodo para convertir un Map<String, dynamic> en una instancia de UsuarioModel
  factory UserModel.fromMap(Map<String, dynamic> map) {
    if (map['uid'] == null) {
      throw ArgumentError("Falta el uid de usuario");
    }
    if (map['email'] == null) {
      throw ArgumentError("Falta el email de usuario");
    }
    if (map['name'] == null) {
      throw ArgumentError("Falta el name de usuario");
    }
    if (map['role'] == null) {
      throw ArgumentError("Falta el role de usuario");
    }
    if (map['weight'] == null) {
      throw ArgumentError("Falta el weight de usuario");
    }
    if (map['image'] == null) {
      throw ArgumentError("Falta el image de usuario");
    }
    if (map['createdAt'] == null) {
      throw ArgumentError("Falta el createdAt de usuario");
    }
    return UserModel(
      uid: map['uid'],
      email: map['email'],
      name: map['name'],
      role: map['role'],
      status: (map['status'] ?? 0) as int,
      weight: (map['weight'] as num).toDouble(),
      image: map['image'],
      createdAt: map['createdAt'],
    );
  }
  /// Metodo para convertir un UsuarioModel en un Map<String,dynamic> de cara a subir sus datos a Firebase
  Map<String, dynamic> toMap() => {
    'uid': uid,
    'email': email,
    'name': name[0].toUpperCase()+name.substring(1).toLowerCase(), // convertimos la primera letra en mayúscula
    'role': role.toUpperCase(),
    'status': status.toInt(),
    'weight': weight.toDouble(),
    'image': image ?? "null",
    if (createdAt!= null) 'createdAt': createdAt,
  };

}
