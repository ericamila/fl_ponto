import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/registro.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveUserInfo(String token, String name) async {
    await _db.collection("accessId").doc(token).set({
      "accessToken": token,
      "name": name,
    });
  }

  Future<void> registrarPonto(String token, Registro registro) async {
    // Sanitizar o ID removendo caracteres proibidos no Firestore (como /)
    final docId = "${registro.data}_${registro.hora}".replaceAll('/', '-');
    
    await _db
        .collection(token)
        .doc(docId)
        .set(registro.toMap());
  }

  Stream<List<Registro>> getRegistros(String token, int month) {
    return _db
        .collection(token)
        .where("mes", isEqualTo: month)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Registro.fromMap(doc.data(), id: doc.id);
      }).toList();
    });
  }
}
