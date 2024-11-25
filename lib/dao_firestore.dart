import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_projeto_p2/firebase_options.dart';
import 'package:flutter_projeto_p2/models/abastecimento.dart';
import 'package:flutter_projeto_p2/models/veiculo.dart';

class DaoFirestore {
  static final FirebaseFirestore db = FirebaseFirestore.instance;
  static final FirebaseAuth auth = FirebaseAuth.instance;

  static String? get currentUserId {
    return auth.currentUser?.uid;
  }
  static void inicializa() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }  static Stream<List<Veiculo>> getVeiculos() {
    final userId = currentUserId;
    if (userId == null) throw Exception('Usuário não autenticado');

    return db
        .collection('users')
        .doc(userId)
        .collection('veiculos')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
      return Veiculo(
        doc['nome'],
        doc['modelo'],
        doc['placa'],
        doc['ano'],
        doc['km'],
      )..mediaConsumo = doc['mediaConsumo'] ?? 0.0;
    }).toList());
  }
  static Future<Veiculo?> getVeiculo(String veiculoId) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('Usuário não autenticado');

    final doc = await db
        .collection('users')
        .doc(userId)
        .collection('veiculos')
        .doc(veiculoId)
        .get();

    if (doc.exists && doc.data() != null) {
      return Veiculo(
        doc['nome'],
        doc['modelo'],
        doc['placa'],
        doc['ano'],
        doc['km'],
      )..mediaConsumo = doc['mediaConsumo'] ?? 0.0;
    }
    return null;
  }
  static Future<void> salvarVeiculo(Veiculo veiculo) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('Usuário não autenticado');

    final Map<String, dynamic> veiculoData = {
      'nome': veiculo.nome,
      'modelo': veiculo.modelo,
      'placa': veiculo.placa,
      'ano': veiculo.ano,
      'km': veiculo.km,
    };

    if (veiculo.mediaConsumo != null) {
      veiculoData['mediaConsumo'] = veiculo.mediaConsumo;
    }

    await db
        .collection('users')
        .doc(userId)
        .collection('veiculos')
        .add(veiculoData);
  }


  static Future<void> atualizarVeiculo(String veiculoId, Veiculo veiculo) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('Usuário não autenticado');

    await db
        .collection('users')
        .doc(userId)
        .collection('veiculos')
        .doc(veiculoId)
        .update({
      'nome': veiculo.nome,
      'modelo': veiculo.modelo,
      'placa': veiculo.placa,
      'ano': veiculo.ano,
      'km': veiculo.km,
      'mediaConsumo': veiculo.mediaConsumo,
    });
  }
  static Future<void> salvarAbastecimento(
      String veiculoId, Abastecimento abastecimento) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('Usuário não autenticado');

    print('Salvando abastecimento para o veículo $veiculoId do usuário $userId');

    await db.runTransaction((transaction) async {
      final veiculoRef = db
          .collection('users')
          .doc(userId)
          .collection('veiculos')
          .doc(veiculoId);

      final veiculoDoc = await transaction.get(veiculoRef);

      if (!veiculoDoc.exists) {
        throw Exception('Veículo $veiculoId não encontrado.');
      }

      print('Veículo encontrado, iniciando cálculo de média');

      double kmAnterior = double.parse(veiculoDoc.data()?['km'].toString() ?? '0.0');
      double kmAtual = abastecimento.quilometragemAtual;
      double litros = abastecimento.litros;

      if (kmAtual < kmAnterior) {
        throw Exception('A quilometragem atual não pode ser menor que a anterior');
      }

      final kmPercorrido = kmAtual - kmAnterior;
      final mediaConsumo = kmPercorrido / litros;

      print('Km percorrido: $kmPercorrido, Média de consumo: $mediaConsumo');

      transaction.update(veiculoRef, {
        'km': kmAtual,
        'mediaConsumo': mediaConsumo,
      });

      final abastecimentoRef = veiculoRef.collection('abastecimentos').doc();
      transaction.set(abastecimentoRef, {
        'data': Timestamp.fromDate(abastecimento.data),
        'quilometragemAtual': kmAtual,
        'litros': litros,
      });

      print('Abastecimento salvo com sucesso.');
    }).catchError((e) {
      print('Erro na transação: $e');
    });
  }

  static Future<void> excluirVeiculo(String veiculoId) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('Usuário não autenticado');

    final veiculoRef = db
        .collection('users')
        .doc(userId)
        .collection('veiculos')
        .doc(veiculoId);

    final abastecimentosSnapshot =
    await veiculoRef.collection('abastecimentos').get();
    for (var doc in abastecimentosSnapshot.docs) {
      await doc.reference.delete();
    }

    await veiculoRef.delete();
    print("Veículo e abastecimentos excluídos com sucesso!");
  }
  static Stream<List<Abastecimento>> getAbastecimentos(String placa) {
    final userId = currentUserId;
    if (userId == null) throw Exception('Usuário não autenticado');

    print('Buscando abastecimentos para o veículo com placa $placa do usuário $userId');

    return db
        .collection('users')
        .doc(userId)
        .collection('veiculos')
        .where('placa', isEqualTo: placa)  // Busca o veículo pela placa
        .snapshots()
        .asyncMap((veiculosSnapshot) async {
      if (veiculosSnapshot.docs.isEmpty) {
        print('Nenhum veículo encontrado com a placa $placa');
        return [];
      }

      final veiculoDoc = veiculosSnapshot.docs.first;
      final veiculoId = veiculoDoc.id;
      print('Veículo encontrado com ID: $veiculoId');

      final abastecimentosSnapshot = await db
          .collection('users')
          .doc(userId)
          .collection('veiculos')
          .doc(veiculoId)
          .collection('abastecimentos')
          .orderBy('data', descending: true)
          .get();

      print('Encontrados ${abastecimentosSnapshot.docs.length} abastecimentos');

      return abastecimentosSnapshot.docs.map((doc) {
        final data = (doc['data'] as Timestamp).toDate();
        final quilometragemAtual = double.parse(doc['quilometragemAtual'].toString());
        final litros = double.parse(doc['litros'].toString());

        print('Processando abastecimento: Data: $data, Km: $quilometragemAtual, Litros: $litros');

        return Abastecimento(
          data,
          quilometragemAtual,
          litros,
        );
      }).toList();
    });
  }
}