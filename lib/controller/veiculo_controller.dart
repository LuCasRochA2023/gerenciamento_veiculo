import 'package:flutter_projeto_p2/dao_firestore.dart';
import 'package:flutter_projeto_p2/models/veiculo.dart';

class VeiculoController{
  Stream<List<Veiculo>> get veiculos => DaoFirestore.getVeiculos();

  Future<void>Cadastrar({
    required String nome,
    required String modelo,
    required String placa,
    required int ano,
    required double km
}) async{
    try{
    final veiculo = Veiculo(nome, modelo, placa, ano, km);
  await DaoFirestore.salvarVeiculo(veiculo);
    }catch(e){
      throw new Exception(e.toString());
    };

  }
  String formatarPlaca(String placa) {

    if (placa.length != 7) {
      throw Exception('Erro! A placa não pode conter menos de 7 caracteres!');
    }

    return placa;
  }
  Future<bool> verificarPlacaExistente(String placa) async {
    try {
      final veiculosStream = DaoFirestore.getVeiculos();
      final veiculos = await veiculosStream.first;

      return veiculos.any((veiculo) =>
      veiculo.placa.toLowerCase() == placa.toLowerCase()
      );
    } catch (e) {
      throw Exception('Erro ao verificar placa: ${e.toString()}');
    }
  }
  Future<void> editarVeiculo({
    required String veiculoId,
    required String nome,
    required String modelo,
    required String placa,
    required int ano,
    required double km,
    double mediaConsumo = 0.0,
  }) async {
    try {
      final veiculo = Veiculo(
        nome,
        modelo,
        placa,
        ano,
        km,
      )..mediaConsumo = mediaConsumo;

      await DaoFirestore.atualizarVeiculo(veiculoId, veiculo);
    } catch (e) {
      throw Exception('Erro ao editar veículo: ${e.toString()}');
    }
  }

}
