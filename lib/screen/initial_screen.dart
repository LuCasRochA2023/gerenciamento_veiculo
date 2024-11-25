import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_projeto_p2/dao_firestore.dart';
import 'package:flutter_projeto_p2/models/veiculo.dart';
import 'package:flutter_projeto_p2/screen/base_page.dart';
import 'package:flutter_projeto_p2/screen/cadastro_carros.dart';
import 'package:flutter_projeto_p2/screen/edit_screen.dart';
import 'package:flutter_projeto_p2/screen/new_fuel.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Over Wheels",
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BasicScaffold(
      body: const VehicleList(),
    );
  }
}

class VehicleList extends StatelessWidget {
  const VehicleList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .collection('veiculos')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text(
              "Erro!",
              style: TextStyle(fontSize: 18, color: Colors.blue),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.directions_car_outlined, size: 64),
                const SizedBox(height: 14),
                const Text(
                  'Nenhum carro cadastrado!',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 15),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CadastroCarros(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("Adicionar"),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final data = doc.data() as Map<String, dynamic>;

            return Card(
              child: ListTile(
                leading: const Icon(Icons.directions_car, size: 34),
                title: Text(data['nome']),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Placa: ${data['placa']}'),
                    Text(
                      'Kms rodados: ${data['km']?.toStringAsFixed(2) ?? "N/A"} km/L',
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NovoAbastecimento(
                        veiculoId: doc.id,
                        veiculoNome: data['nome'],
                      ),
                    ),
                  );
                },
                trailing: PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: 7),
                          Text('Editar'),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 7),
                          Text(
                            'Excluir',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (String value) async {
                    if (value == 'delete') {
                      bool? confirm = await showDialog<bool>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text(
                                'Tem certeza que deseja excluir esse veículo?'),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('Cancelar'),
                                onPressed: () => Navigator.of(context).pop(false),
                              ),
                              TextButton(
                                child: const Text('Excluir'),
                                onPressed: () => Navigator.of(context).pop(true),
                              ),
                            ],
                          );
                        },
                      );

                      if (confirm == true) {
                        try {
                          await DaoFirestore.excluirVeiculo(doc.id);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Erro ao excluir veículo: $e'),
                            ),
                          );
                        }
                      }
                    } else if (value == 'edit') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditarVeiculoScreen(
                            veiculoId: doc.id,
                            veiculo: Veiculo(
                              data['nome'],
                              data['modelo'],
                              data['placa'],
                              data['ano'],
                              data['km'],
                            ),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
  }
