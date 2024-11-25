import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_projeto_p2/auth_firebase.dart';
import 'package:flutter_projeto_p2/login.dart';
import 'package:flutter_projeto_p2/screen/cadastro_carros.dart';
import 'package:flutter_projeto_p2/screen/historico.dart';
import 'package:flutter_projeto_p2/screen/perfil.dart';

class BasicScaffold extends StatelessWidget {
  final Widget body;

  const BasicScaffold({Key? key, required this.body}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authFirebase = AutenticacaoFirebase();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Over Wheels"),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.white70),
              child: FutureBuilder<User?>(
                  future: FirebaseAuth.instance.authStateChanges().first,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    }
                    if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                      return const Center(
                          child: Text("Erro!", style: TextStyle(color: Colors.red, fontSize: 22)));
                    }
                    final user = snapshot.data!;
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.account_circle, size: 46, color: Colors.blue),
                        const SizedBox(height: 10),
                        Text(
                          user.email ?? "Email indisponível",
                          style: const TextStyle(color: Colors.black, fontSize: 14),
                        ),
                      ],
                    );
                  }),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Home", style: TextStyle(color: Colors.blue)),
              onTap: () {
                Navigator.push(context , MaterialPageRoute(builder: (context)=> Login()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_circle_outline),
              title: const Text("Adicionar veículo"),
              onTap: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => CadastroCarros()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.content_paste_search),
              title: const Text("Histórico de abastecimento"),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Historico()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: const Text("Perfil"),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Perfil()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout_outlined),
              title: const Text("Sair"),
              onTap: () async {
                await authFirebase.signOut();
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (context) => Login()));
              },
            ),
          ],
        ),
      ),
      body: body,
    );
  }
}
