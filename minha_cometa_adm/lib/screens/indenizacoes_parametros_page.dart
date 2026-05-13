import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../constants/app_colors.dart';
import 'indenizacoes_page.dart';

class IndenizacoesParametrosPage extends StatefulWidget {
  const IndenizacoesParametrosPage({super.key});

  @override
  State<IndenizacoesParametrosPage> createState() =>
      _IndenizacoesParametrosPageState();
}

class _IndenizacoesParametrosPageState extends State<IndenizacoesParametrosPage> {
  final _formKey = GlobalKey<FormState>();

  late DateTime _dataDe;
  late DateTime _dataAte;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _dataAte = DateTime(now.year, now.month, now.day);
    _dataDe = DateTime(now.year, now.month, 1);
  }

  String _formatBr(DateTime d) => DateFormat('dd/MM/yyyy').format(d);

  Future<void> _selecionarDataDe() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dataDe,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      _dataDe = DateTime(picked.year, picked.month, picked.day);
      if (_dataDe.isAfter(_dataAte)) {
        _dataAte = _dataDe;
      }
    });
  }

  Future<void> _selecionarDataAte() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dataAte,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      _dataAte = DateTime(picked.year, picked.month, picked.day);
      if (_dataAte.isBefore(_dataDe)) {
        _dataDe = _dataAte;
      }
    });
  }

  void _consultar() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => IndenizacoesPage(dataDe: _dataDe, dataAte: _dataAte),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Indenizações',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.date_range, color: AppColors.primary),
                      const SizedBox(width: 8),
                      const Text(
                        'Parâmetros da Consulta',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _DateField(
                    label: 'Data de',
                    value: _formatBr(_dataDe),
                    onTap: _selecionarDataDe,
                  ),
                  const SizedBox(height: 12),
                  _DateField(
                    label: 'Data até',
                    value: _formatBr(_dataAte),
                    onTap: _selecionarDataAte,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _consultar,
                icon: const Icon(Icons.search),
                label: const Text('Consultar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            Icon(Icons.edit_calendar, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

