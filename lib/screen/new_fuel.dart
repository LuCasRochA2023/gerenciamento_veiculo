import 'package:flutter/material.dart';
import 'package:flutter_projeto_p2/dao_firestore.dart';
import 'package:flutter_projeto_p2/models/abastecimento.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class NovoAbastecimento extends StatefulWidget {
  final String veiculoId;
  final String veiculoNome;

  const NovoAbastecimento({Key? key, required this.veiculoId, required this.veiculoNome}) : super(key: key);

  @override
  _NovoAbastecimentoState createState() => _NovoAbastecimentoState();
}

class _NovoAbastecimentoState extends State<NovoAbastecimento> {
  final _formKey = GlobalKey<FormState>();
  final _litrosController = TextEditingController();
  final _kmController = TextEditingController();
  DateTime _dataSelecionada = DateTime.now();

  final _maskFormatter = MaskTextInputFormatter(mask: '##.##', filter: {"#": RegExp(r'[0-9]')});

  @override
  void dispose() {
    _litrosController.dispose();
    _kmController.dispose();
    super.dispose();
  }

  // Função para selecionar a data
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _dataSelecionada) {
      setState(() {
        _dataSelecionada = picked;
      });
    }
  }

  // Função para salvar o abastecimento
  void _salvarAbastecimento() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final abastecimento = Abastecimento(
          _dataSelecionada,
          double.parse(_kmController.text),
          double.parse(_litrosController.text),
        );

        await DaoFirestore.salvarAbastecimento(widget.veiculoId, abastecimento);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Abastecimento registrado com sucesso!'), backgroundColor: Colors.green),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao registrar abastecimento: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Novo Abastecimento - ${widget.veiculoNome}'),
        backgroundColor: Colors.blue[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildDateSelector(context),
              const SizedBox(height: 16),
              _buildKmField(),
              const SizedBox(height: 16),
              _buildLitrosField(),
              const SizedBox(height: 24),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  // Widget para selecionar a data
  Widget _buildDateSelector(BuildContext context) {
    return InkWell(
      onTap: () => _selectDate(context),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Data do Abastecimento',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.calendar_today),
        ),
        child: Text(
          DateFormat('dd/MM/yyyy').format(_dataSelecionada),
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  // Widget para o campo de quilometragem
  Widget _buildKmField() {
    return TextFormField(
      controller: _kmController,
      decoration: const InputDecoration(
        labelText: 'Quilometragem Atual',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.speed),
        suffixText: 'km',
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, insira a quilometragem';
        }
        if (double.tryParse(value) == null) {
          return 'Insira um número válido';
        }
        return null;
      },
    );
  }

  // Widget para o campo de litros abastecidos
  Widget _buildLitrosField() {
    return TextFormField(
      controller: _litrosController,
      decoration: const InputDecoration(
        labelText: 'Litros Abastecidos',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.local_gas_station),
        suffixText: 'L',
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [_maskFormatter],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, insira a quantidade de litros';
        }
        if (double.tryParse(value) == null) {
          return 'Insira um número válido';
        }
        return null;
      },
    );
  }

  // Widget para o botão de salvar
  Widget _buildSaveButton() {
    return ElevatedButton.icon(
      onPressed: _salvarAbastecimento,
      icon: const Icon(Icons.save),
      label: const Text('Salvar Abastecimento'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue[800],
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }
}
