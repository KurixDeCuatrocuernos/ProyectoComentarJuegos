
import 'package:cloud_firestore/cloud_firestore.dart';

class GameApiProjection {
  final int? id;
  final String? name;
  final int? coverId;
  final Timestamp? first_release_date;
  final String? url;

  GameApiProjection({
    this.id,
    this.name,
    this.coverId,
    this.first_release_date,
    this.url,
  });

  factory GameApiProjection.fromMap(Map<String, dynamic> map) {
    return GameApiProjection(
      id: map['id'],
      name: map['name'],
      coverId: map['cover'],
      first_release_date: map['first_release_date'] != null ? Timestamp.fromMillisecondsSinceEpoch(map['first_release_date']) : null,
      url: map['url'],
    );
  }

}