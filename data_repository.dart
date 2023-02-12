import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
// レポジトリクラス.
class DataRepository {
  // Firestoreのコレクションにアクセスする変数.
  final collection = FirebaseFirestore.instance.collection('item');
  // Streamで全てのデータを取得するメソッド.
  Stream<QuerySnapshot> getStream() {
    return collection.snapshots();
  }
  // Firestoreにデータを追加するメソッド.
  Future<DocumentReference> addItem(String title, String description) async {
    final now = DateTime.now();
    return await collection.add({
      'title': title,
      'description': description,
      'createdAt': Timestamp.fromDate(now),
    });
  }
  // Firestoreのデータを更新するメソッド.
  Future<void> updateItem(String id, String title, String description) async {
    final now = DateTime.now();
    await collection.doc(id).update({
      'title': title,
      'description': description,
      'updatedAt': Timestamp.fromDate(now),
    });
  }
  // Firestoreのデータを削除するメソッド.
  Future<void> deleteItem(String id) async {
    await collection.doc(id).delete();
  }
}
