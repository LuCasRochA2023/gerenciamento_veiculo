import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AutenticacaoFirebase {
  Future<String> signInWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      return "Usuário autenticado: ${userCredential.user!.uid}";
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return "Usuário não encontrado";
      } else if (e.code == 'wrong-password') {
        return "Senha incorreta";
      }
      return "Erro de autenticação";
    }
  }


  Future<String> signIn(String email, String password) async {
    final response = await http.post(
      Uri.parse('https://sua-api.com/login'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"email": email, "password": password}),
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      String token = data['token'];
      return "Autenticação bem-sucedida, token: $token";
    } else {
      return "Erro de autenticação";
    }
  }
  Future<String> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      return "Usuário desconectado com sucesso";
    } catch (e) {
      return "Erro ao desconectar: $e";
    }
  }

  Future<String> registerWithEmailPassword(String email,
      String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      return "Usuário registrado com sucesso: ${userCredential.user!.uid}";
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return "A senha é muito fraca.";
      } else if (e.code == 'email-already-in-use') {
        return "A conta já existe para esse email.";
      }
      return "Erro de registro";
    } catch (e) {
      return "Erro: $e";
    }
  }


  Future<bool> isUserLoggedIn() async {
    User? user = FirebaseAuth.instance.currentUser;
    return user !=
        null;
  }
}