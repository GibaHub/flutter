import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import 'inadimplencia_resultados_page.dart';

class InadimplenciaParametrosPage extends StatefulWidget {
  const InadimplenciaParametrosPage({Key? key}) : super(key: key);

  @override
  State<InadimplenciaParametrosPage> createState() => _InadimplenciaParametrosPageState();
}

class _InadimplenciaParametrosPageState extends State<InadimplenciaParametrosPage> {
  final _formKey = GlobalKey<FormState>();
  final _vendasDeController = TextEditingController();
  final _vendasAteController = TextEditingController();
  final _vencimentoDeController = TextEditingController();
  final _vencimentoAteController = TextEditingController();
  
  DateTime? _vendasDe;
  DateTime? _vendasAte;
  DateTime? _vencimentoDe;
  DateTime? _vencimentoAte;

  @override
  void dispose() {
    _vendasDeController.dispose();
    _vendasAteController.dispose();
    _vencimentoDeController.dispose();
    _vencimentoAteController.dispose();
    super.dispose();
  }

  Future<void> _selecionarData(BuildContext context, TextEditingController controller, 
      Function(DateTime) onDateSelected) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('dd/MM/yyyy').format(picked);
        onDateSelected(picked);
      });
    }
  }

  String _formatarDataParaApi(DateTime data) {
    return DateFormat('yyyy-MM-dd').format(data);
  }

  void _consultarInadimplencia() {
    if (_formKey.currentState!.validate()) {
      final parametros = {
        'emissde': _formatarDataParaApi(_vendasDe!),
        'emissate': _formatarDataParaApi(_vendasAte!),
        'vencde': _formatarDataParaApi(_vencimentoDe!),
        'vencate': _formatarDataParaApi(_vencimentoAte!),
      };

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => InadimplenciaResultadosPage(parametros: parametros),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parâmetros de Inadimplência'),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Período de Vendas',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _vendasDeController,
                        decoration: const InputDecoration(
                          labelText: 'Vendas de *',
                          hintText: 'Selecione a data inicial',
                          prefixIcon: Icon(Icons.calendar_today),
                          border: OutlineInputBorder(),
                        ),
                        readOnly: true,
                        onTap: () => _selecionarData(context, _vendasDeController, (data) {
                          _vendasDe = data;
                        }),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Campo obrigatório';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _vendasAteController,
                        decoration: const InputDecoration(
                          labelText: 'Vendas até *',
                          hintText: 'Selecione a data final',
                          prefixIcon: Icon(Icons.calendar_today),
                          border: OutlineInputBorder(),
                        ),
                        readOnly: true,
                        onTap: () => _selecionarData(context, _vendasAteController, (data) {
                          _vendasAte = data;
                        }),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Campo obrigatório';
                          }
                          if (_vendasDe != null && _vendasAte != null && _vendasAte!.isBefore(_vendasDe!)) {
                            return 'Data final deve ser posterior à data inicial';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Período de Vencimento',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _vencimentoDeController,
                        decoration: const InputDecoration(
                          labelText: 'Vencimento de *',
                          hintText: 'Selecione a data inicial',
                          prefixIcon: Icon(Icons.calendar_today),
                          border: OutlineInputBorder(),
                        ),
                        readOnly: true,
                        onTap: () => _selecionarData(context, _vencimentoDeController, (data) {
                          _vencimentoDe = data;
                        }),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Campo obrigatório';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _vencimentoAteController,
                        decoration: const InputDecoration(
                          labelText: 'Vencimento até *',
                          hintText: 'Selecione a data final',
                          prefixIcon: Icon(Icons.calendar_today),
                          border: OutlineInputBorder(),
                        ),
                        readOnly: true,
                        onTap: () => _selecionarData(context, _vencimentoAteController, (data) {
                          _vencimentoAte = data;
                        }),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Campo obrigatório';
                          }
                          if (_vencimentoDe != null && _vencimentoAte != null && _vencimentoAte!.isBefore(_vencimentoDe!)) {
                            return 'Data final deve ser posterior à data inicial';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _consultarInadimplencia,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Consultar Inadimplência',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '* Campos obrigatórios',
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}