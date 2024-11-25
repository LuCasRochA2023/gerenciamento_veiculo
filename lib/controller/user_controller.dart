import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> salvarDadosPerfil({
    required String nome,
    required String genero,
    required DateTime dataNascimento,
    required String rua,
    required String bairro,
    required String numero,
    required String complemento,
  }) async {
    try {
      final user = _auth.currentUser;

      if (user == null) {
        throw Exception("Usuário não autenticado.");
      }

      final uid = user.uid;

      final dadosPerfil = {
        'nome': nome,
        'genero': genero,
        'dataNascimento': dataNascimento.toIso8601String(),
        'rua': rua,
        'bairro': bairro,
        'numero': numero,
        'complemento': complemento,
      };

      await _firestore.collection('usuarios').doc(uid).set(dadosPerfil, SetOptions(merge: true));
    } catch (e) {
      throw Exception("Erro ao salvar os dados do perfil: $e");
    }
  }

  Future<Map<String, dynamic>?> carregarDadosPerfil() async {
    try {
      final user = _auth.currentUser;

      if (user == null) {
        throw Exception("Usuário não autenticado.");
      }

      final uid = user.uid;

      final snapshot = await _firestore.collection('usuarios').doc(uid).get();

      if (snapshot.exists) {
        return snapshot.data();
      }

      return null;
    } catch (e) {
      throw Exception("Erro ao carregar os dados do perfil: $e");
    }
  }
}
