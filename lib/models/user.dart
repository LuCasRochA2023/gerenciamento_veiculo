import 'package:intl/intl.dart';

class User {
  late String _nome;
  late String _genero;
  late DateFormat _dataNascimento;
  late String _rua;
  late String _bairro;
  late int _numero;
  late String _complemento;

  User(
      this._nome,
      this._genero,
      this._dataNascimento,
      this._rua,
      this._bairro,
      this._numero,
      this._complemento,
      );

  String get nome => _nome;
  set nome(String nome) => _nome = nome;

  String get genero => _genero;
  set genero(String genero) => _genero = genero;

  DateFormat get dataNascimento => _dataNascimento;
  set dataNascimento(DateFormat dataNascimento) => _dataNascimento = dataNascimento;

  String get rua => _rua;
  set rua(String rua) => _rua = rua;

  String get bairro => _bairro;
  set bairro(String bairro) => _bairro = bairro;

  int get numero => _numero;
  set numero(int numero) => _numero = numero;

  String get complemento => _complemento;
  set complemento(String complemento) => _complemento = complemento;
}
