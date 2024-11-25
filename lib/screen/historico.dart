import 'package:flutter/material.dart';
import 'package:flutter_projeto_p2/controller/veiculo_controller.dart';
import 'package:flutter_projeto_p2/screen/base_page.dart';
import 'package:intl/intl.dart';
import '../models/veiculo.dart';
import '../models/abastecimento.dart';
import '../dao_firestore.dart'; // Certifique-se de ter o arquivo correto para 'DaoFirestore'

class Historico extends StatefulWidget {
  const Historico({Key? key}) : super(key: key);

  @override
  State<Historico> createState() => _HistoricoState();
}

class _HistoricoState extends State<Historico> {
  late Stream<List<Veiculo>> veiculosStream;

  @override
  void initState() {
    super.initState();
    veiculosStream = VeiculoController().veiculos;
  }

  @override
  Widget build(BuildContext context) {
    return BasicScaffold(
      body: StreamBuilder<List<Veiculo>>(
        stream: veiculosStream,
        builder: (context, snapshotVeiculos) {
          if (snapshotVeiculos.hasError) {
            return Center(
              child: Text('Erro ao carregar veículos: ${snapshotVeiculos.error}'),
            );
          }

          if (snapshotVeiculos.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshotVeiculos.hasData || snapshotVeiculos.data!.isEmpty) {
            return const Center(child: Text('Nenhum veículo encontrado'));
          }

          return SingleChildScrollView(
            child: Column(
              children: snapshotVeiculos.data!.map((veiculo) {
                return StreamBuilder<List<Abastecimento>>(
                  stream: DaoFirestore.getAbastecimentos(veiculo.placa),
                  builder: (context, snapshotAbastecimentos) {
                    if (snapshotAbastecimentos.hasError) {
                      return Card(
                        margin: const EdgeInsets.all(8),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                              'Erro ao carregar abastecimentos: ${snapshotAbastecimentos.error}'),
                        ),
                      );
                    }

                    if (snapshotAbastecimentos.connectionState == ConnectionState.waiting) {
                      return Card(
                        margin: const EdgeInsets.all(8),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: const Center(child: CircularProgressIndicator()),
                        ),
                      );
                    }

                    final abastecimentos = snapshotAbastecimentos.data ?? [];
                    if (abastecimentos.isEmpty) {
                      return Card(
                        margin: const EdgeInsets.all(8),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                              'Nenhum abastecimento para ${veiculo.modelo} - ${veiculo.placa}'),
                        ),
                      );
                    }

                    return Column(
                      children: abastecimentos.map((abastecimento) {
                        return Card(
                          margin: const EdgeInsets.all(8),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${veiculo.nome} - ${veiculo.modelo}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Placa: ${veiculo.placa}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                                const Divider(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      DateFormat('dd/MM/yyyy HH:mm').format(abastecimento.data),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Quilometragem: ${abastecimento.quilometragemAtual.toStringAsFixed(1)} km',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    Text(
                                      'Litros: ${abastecimento.litros.toStringAsFixed(2)} L',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
