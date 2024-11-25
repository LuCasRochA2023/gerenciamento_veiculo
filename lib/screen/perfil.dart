import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_projeto_p2/controller/user_controller.dart';
import 'package:flutter_projeto_p2/screen/base_page.dart';
import 'package:intl/intl.dart';

class Perfil extends StatefulWidget {
  const Perfil({Key? key}) : super(key: key);

  @override
  State<Perfil> createState() => _PerfilState();
}

class _PerfilState extends State<Perfil> {
  final _nomeController = TextEditingController();
  final _generoController = TextEditingController();
  final _ruaController = TextEditingController();
  final _bairroController = TextEditingController();
  final _numeroController = TextEditingController();
  final _complementoController = TextEditingController();
  final _userController = UserController();
  DateTime? _dataNascimento;

  @override
  void initState() {
    super.initState();
    _carregarDadosUsuario();
  }

  Future<void> _carregarDadosUsuario() async {
    try {
      final dados = await _userController.carregarDadosPerfil();
      if (dados != null) {
        setState(() {
          _nomeController.text = dados['nome'] ?? '';
          _generoController.text = dados['genero'] ?? '';
          _ruaController.text = dados['rua'] ?? '';
          _bairroController.text = dados['bairro'] ?? '';
          _numeroController.text = dados['numero'] ?? '';
          _complementoController.text = dados['complemento'] ?? '';
          _dataNascimento = dados['dataNascimento'] != null
              ? DateTime.parse(dados['dataNascimento'])
              : null;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar dados: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _salvarDados() async {
    if (_dataNascimento != null) {
      try {
        await _userController.salvarDadosPerfil(
          nome: _nomeController.text,
          genero: _generoController.text,
          dataNascimento: _dataNascimento!,
          rua: _ruaController.text,
          bairro: _bairroController.text,
          numero: _numeroController.text,
          complemento: _complementoController.text,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Informações salvas com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar dados: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione uma data de nascimento.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dataNascimento ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _dataNascimento) {
      setState(() {
        _dataNascimento = picked;
      });
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _generoController.dispose();
    _ruaController.dispose();
    _bairroController.dispose();
    _numeroController.dispose();
    _complementoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BasicScaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    const Icon(Icons.account_circle, size: 96),
                    FutureBuilder<User?>(
                      future: FirebaseAuth.instance.authStateChanges().first,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const CircularProgressIndicator();
                        }
                        final user = snapshot.data!;
                        return Text(
                          user.email ?? "Email indisponível",
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Campos de formulário
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _generoController,
                decoration: const InputDecoration(
                  labelText: 'Gênero',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Data de Nascimento',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _dataNascimento != null
                        ? DateFormat('dd/MM/yyyy').format(_dataNascimento!)
                        : 'Selecione uma data',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _ruaController,
                decoration: const InputDecoration(
                  labelText: 'Rua',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _bairroController,
                decoration: const InputDecoration(
                  labelText: 'Bairro',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _numeroController,
                decoration: const InputDecoration(
                  labelText: 'Número',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _complementoController,
                decoration: const InputDecoration(
                  labelText: 'Complemento',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: _salvarDados,
                  child: const Text('Salvar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
