import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/livre.dart';

class FirestoreService {
  final CollectionReference _livresRef =
      FirebaseFirestore.instance.collection('Livres');

  Stream<List<Livre>> getLivres() {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return _livresRef
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Livre.fromFirestore(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }
}