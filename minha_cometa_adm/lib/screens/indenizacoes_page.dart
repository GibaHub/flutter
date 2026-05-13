import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:minha_cometa_adm/constants/app_colors.dart';
import 'package:minha_cometa_adm/services/api_service.dart';
import 'package:minha_cometa_adm/providers/auth_provider.dart';
import 'package:minha_cometa_adm/services/permission_service.dart';

class IndenizacoesPage extends StatefulWidget {
  final DateTime dataDe;
  final DateTime dataAte;

  const IndenizacoesPage({
    super.key,
    required this.dataDe,
    required this.dataAte,
  });

  @override
  State<IndenizacoesPage> createState() => _IndenizacoesPageState();
}

class _IndenizacoesPageState extends State<IndenizacoesPage> {
  final ApiService _api = ApiService();

  bool _loading = true;
  String? _error;
  List<_ResumoPorFilial> _resumo = const [];

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final df = DateFormat('yyyyMMdd');
      final de = df.format(widget.dataDe);
      final ate = df.format(widget.dataAte);

      final data = await _api.postWithAuth(
        '/appcometa/estoque/consultaindenizacacao',
        {
          'data_de': de,
          'data_ate': ate,
        },
      );

      final resumo = _parseResumoPorFilial(data);
      final user =
          Provider.of<AuthProvider>(context, listen: false).currentUser;
      final resumoFiltrado = user == null
          ? <_ResumoPorFilial>[]
          : resumo
              .where((e) => PermissionService().hasFilialAccess(user, e.filial))
              .toList();
      if (!mounted) return;
      setState(() {
        _resumo = resumoFiltrado..sort((a, b) => a.filial.compareTo(b.filial));
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  List<_ResumoPorFilial> _parseResumoPorFilial(dynamic data) {
    if (data is Map<String, dynamic>) {
      final raw = data['resumo_por_filial'];
      if (raw is List) {
        return raw
            .whereType<Map>()
            .map((e) => _ResumoPorFilial.fromJson(
                  Map<String, dynamic>.from(e),
                ))
            .toList();
      }
    }

    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => _ResumoPorFilial.fromJson(
                Map<String, dynamic>.from(e),
              ))
          .toList();
    }

    return const [];
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Indenização de Lojas'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 56, color: Colors.red),
                        const SizedBox(height: 12),
                        Text(
                          'Erro ao carregar indenizações',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.red.shade700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.black54),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _carregar,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Recarregar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _carregar,
                  color: AppColors.primary,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    itemCount: _resumo.length,
                    itemBuilder: (context, index) {
                      final item = _resumo[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        elevation: 6,
                        color: const Color(0xFFF1EEEE),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Loja ${item.filial}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _LinhaValor(
                                label: 'Total em Aberto',
                                value: currency.format(item.aberto),
                              ),
                              _LinhaValor(
                                label: 'Total Fechado',
                                value: currency.format(item.fechado),
                              ),
                              _LinhaValor(
                                label: 'A Receber',
                                value: currency.format(item.aReceber),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

class _LinhaValor extends StatelessWidget {
  final String label;
  final String value;

  const _LinhaValor({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 15),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _ResumoPorFilial {
  final String filial;
  final double aberto;
  final double fechado;
  final double aReceber;

  const _ResumoPorFilial({
    required this.filial,
    required this.aberto,
    required this.fechado,
    required this.aReceber,
  });

  static String _normalizeFilial(dynamic value) {
    final raw = (value ?? '').toString().trim();
    if (raw.isEmpty) return '';

    final leadingMatch =
        RegExp(r'^\s*(?:LOJA\s*)?(\d{1,2})\b', caseSensitive: false)
            .firstMatch(raw);
    if (leadingMatch != null) {
      return leadingMatch.group(1)!.padLeft(2, '0');
    }

    final anyMatch = RegExp(r'(\d{1,2})').firstMatch(raw);
    if (anyMatch != null) {
      return anyMatch.group(1)!.padLeft(2, '0');
    }

    return raw.padLeft(2, '0');
  }

  factory _ResumoPorFilial.fromJson(Map<String, dynamic> json) {
    return _ResumoPorFilial(
      filial: _normalizeFilial(json['filial']),
      aberto: _toDouble(json['aberto']),
      fechado: _toDouble(json['fechado']),
      aReceber: _toDouble(json['a_receber']),
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    final str = value.toString().replaceAll('.', '').replaceAll(',', '.');
    return double.tryParse(str) ?? 0;
  }
}
