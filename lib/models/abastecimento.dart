import 'package:cloud_firestore/cloud_firestore.dart';

class Abastecimento {
  late DateTime _data;
  late double _quilometragemAtual;
  late double _litros;

  Abastecimento(this._data, this._quilometragemAtual, this._litros);

  set litros(double litros) {
    _litros = litros;
  }

  set quilometragemAtual(double quilometragem) {
    _quilometragemAtual = quilometragem;
  }
  set data(DateTime data) {
    _data = data;
  }

  double get litros => _litros;
  double get quilometragemAtual => _quilometragemAtual;
  DateTime get data => _data;

  factory Abastecimento.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Abastecimento(
      (data['data'] as Timestamp).toDate(),
      (data['quilometragemAtual'] as num).toDouble(),
      (data['litros'] as num).toDouble(),
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'data': _data,
      'quilometragemAtual': _quilometragemAtual,
      'litros': _litros,
    };
  }
}