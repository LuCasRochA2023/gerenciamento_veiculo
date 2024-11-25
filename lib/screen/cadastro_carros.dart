import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_projeto_p2/controller/veiculo_controller.dart';
import 'package:flutter_projeto_p2/screen/base_page.dart';

class CadastroCarros extends StatefulWidget {
  const CadastroCarros({Key?key}): super(key: key);

  @override
  State<CadastroCarros> createState() => _CadastroCarrosState();
}

class _CadastroCarrosState extends State<CadastroCarros> {
  final _formKey = GlobalKey<FormState>();
  final _controller = VeiculoController();
  final _nomeController = TextEditingController();
  final _modeloController = TextEditingController();
  final _placaController = TextEditingController();
  final _anoController = TextEditingController();
  final _kmController = TextEditingController();
  bool _isLoading = false;
   @override
  void dispose() {
    _nomeController.dispose();
    _modeloController.dispose();
    _placaController.dispose();
    _anoController.dispose();
    _kmController.dispose();
    super.dispose();
  }
  void _mostrarErro(String mensagem) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.red,
      ),
    );
  }
  Future<void> _cadastrarVeiculo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final placaFormatada = _controller.formatarPlaca(_placaController.text);
      final placaExiste = await _controller.verificarPlacaExistente(placaFormatada);

      if (placaExiste) {
        _mostrarErro('Já existe um veículo cadastrado com essa placa');
        return;
      }

      await _controller.Cadastrar(
        nome: _nomeController.text.trim(),
        modelo: _modeloController.text.trim(),
        placa: placaFormatada,
        ano: int.parse(_anoController.text),
        km: double.parse(_kmController.text.replaceAll(',', '.')),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veículo cadastrado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      _mostrarErro(e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return BasicScaffold(body: SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome do Veículo',
                hintText: 'Ex: Meu Carro',
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Digite a descrição do veículo';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _modeloController,
              decoration: const InputDecoration(
                labelText: 'Modelo',
                hintText: 'Ex: Fiesta',
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Digite o modelo do veículo';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _placaController,
              decoration: const InputDecoration(
                labelText: 'Placa',
                hintText: 'Ex: PLA1234',
              ),
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                LengthLimitingTextInputFormatter(7),
              ],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Digite a placa do veículo';
                }
                try {
                  _controller.formatarPlaca(value);
                  return null;
                } catch (e) {
                  return e.toString();
                }
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _anoController,
              decoration: const InputDecoration(
                labelText: 'Ano',
                hintText: 'Ex: 2024',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Digite o ano do veículo';
                }
                final ano = int.tryParse(value);
                if (ano == null) {
                  return 'Ano inválido';
                }
                if (ano < 1900 || ano > DateTime.now().year + 1) {
                  return 'Ano fora do intervalo permitido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _kmController,
              decoration: const InputDecoration(
                labelText: 'Quilometragem',
                hintText: 'Ex: 30000',
                suffixText: 'km',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Digite a quilometragem do veículo';
                }
                final km = double.tryParse(value.replaceAll(',', '.'));
                if (km == null) {
                  return 'Quilometragem inválida';
                }
                if (km < 0) {
                  return 'Quilometragem não pode ser negativa';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _isLoading ? null : _cadastrarVeiculo,
              child: _isLoading
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
                  : const Text('Cadastrar Veículo'),
            ),
          ],
        ),
      ),
    ),
    );
  }

  }

