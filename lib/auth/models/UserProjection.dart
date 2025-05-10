/// Esta clase se usa para generar instancias de UserProjection, una Proyección de UserModel con las variables Name y uid, de cara al metodo getUsersUidByQuery, del repositorio de usuarios, de cara a hacerlo más ligero para las búsquedas
class UserProjection {

  final String uid;

  /// Metodo contructor para UserProjection
  UserProjection({
    required this.uid,
  });

  ///Metodo para convertir un Map<String, dynamic> en un UserProjection
  factory UserProjection.fromMap(Map<String, dynamic> map) {
    return UserProjection(
      uid: map['uid'],
    );
  }
  /// Metodo para convertir un UserProjection en un Map<String, dynamic>
  Map<String, dynamic> toMap() => {
    'uid': uid,
  };

}