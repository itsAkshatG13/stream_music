import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';

class FirebaseClass{
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  // creates or updates users db on fire store
  Future<void> updateFirestoreData(
      String collectionId, String docId, Map<String, dynamic> updateData) {
    return firebaseFirestore
        .collection(collectionId)
        .doc(docId)
        .update(updateData);
  }

  // fetches db data from users collection in fire store
  Future<QuerySnapshot?> getFirestoreData({
    required String collectionId, int? limit, String? textSearch,})async {
    try{
      if (textSearch?.isNotEmpty == true) {
        return await firebaseFirestore
            .collection(collectionId).where('displayname',arrayContains: textSearch).get();
      } else {
        return await firebaseFirestore
            .collection(collectionId).get();
      }
    }
    catch(e) {
      debugPrint("Exception : $e");
    }
    return null;
  }
}