import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/livre.dart';

class FirestoreService {
  final CollectionReference _livresRef =
      FirebaseFirestore.instance.collection('livres');

  Stream<List<Livre>> getLivres() {
    return _livresRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Livre.fromFirestore(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }
}