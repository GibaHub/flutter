import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/pix_key_model.dart';
import '../models/store_group_model.dart';
import '../models/installment_model.dart';
import '../models/installment_data.dart';
import '../../core/constants/api_constants.dart';

class InstallmentRepositoryImpl {
  final Dio _dio;

  String? _accessToken;

  InstallmentRepositoryImpl(this._dio);

  Future<void> _authenticate() async {
    final response = await _dio.post(
      '${ApiConstants.baseUrl}${ApiConstants.authEndpoint}',
      queryParameters: {
        'grant_type': 'password',
        'username': 'cometa.service',
        'password': '103020',
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = response.data;
      _accessToken = data['access_token'];
    } else {
      throw Exception('Failed to authenticate: ${response.statusCode}');
    }
  }

  Future<InstallmentData> getInstallments(String cpf) async {
    int attempts = 0;
    while (attempts < 3) {
      try {
        attempts++;
        // Mock bypass
        if (cpf.startsWith('999')) {
          return _getMockData();
        }

        if (_accessToken == null) {
          await _authenticate();
        }

        final cleanCpf = cpf.replaceAll(RegExp(r'\D'), '');

        final response = await _dio.get(
          '${ApiConstants.baseUrl}${ApiConstants.getClient}',
          queryParameters: {'CPF': cleanCpf},
          options: Options(
            headers: {'Authorization': 'Bearer $_accessToken'},
            responseType: ResponseType.plain, // Get raw string to fix JSON
          ),
        );

        if (response.statusCode == 200 && response.data != null) {
          // Fix potentially invalid JSON (trailing commas)
          String rawJson = response.data.toString();

          // Remove BOM if present
          if (rawJson.startsWith('\uFEFF')) {
            rawJson = rawJson.substring(1);
          }

          // Remove trailing comma before ] or }
          rawJson = rawJson.replaceAllMapped(
            RegExp(r',\s*([\]}])'),
            (Match m) => '${m[1]}',
          );

          // Fix missing comma between objects } {
          rawJson = rawJson.replaceAllMapped(
            RegExp(r'\}\s*\{'),
            (Match m) => '}, {',
          );

          try {
            final Map<String, dynamic> data = jsonDecode(rawJson);

            final String clientCode = data['CODIGO'] ?? '';
            final String clientName = data['NOME'] ?? '';
            final List<dynamic> items = data['ITEMS'] ?? [];
            final List<dynamic> chaves = data['CHAVES'] ?? [];

            final List<PixKeyModel> pixKeys =
                chaves.map((e) => PixKeyModel.fromJson(e)).toList();

            final Map<String, List<InstallmentModel>> grouped = {};

            for (var item in items) {
              final storeName = item['FILIAL'] ?? 'Loja Desconhecida';

              // Parse values (format "999.999,99")
              String valStr = item['SALDO_A_PAGAR'] ?? '0,00';
              valStr = valStr.replaceAll('.', '').replaceAll(',', '.');
              final double value = double.tryParse(valStr) ?? 0.0;

              String intStr = item['JUROS_A_PAGAR'] ?? '0,00';
              intStr = intStr.replaceAll('.', '').replaceAll(',', '.');
              final double interest = double.tryParse(intStr) ?? 0.0;

              final installment = InstallmentModel(
                id:
                    '${item['PREFIXO'] ?? ''}|${item['NUMERO'] ?? ''}|${item['PARCELA'] ?? ''}|${item['TIPO'] ?? ''}',
                description:
                    'Fat: ${item['NUMERO'] ?? ''} Parc: ${item['PARCELA'] ?? ''}',
                value: value,
                dueDate: item['DATA_DE_VENCIMENTO'] ?? '',
                status: 'OPEN',
                prefix: item['PREFIXO'] ?? '',
                number: item['NUMERO'] ?? '',
                installment: item['PARCELA'] ?? '',
                type: item['TIPO'] ?? '',
                interest: interest,
                isSelected: false,
              );

              if (!grouped.containsKey(storeName)) {
                grouped[storeName] = [];
              }
              grouped[storeName]!.add(installment);
            }

            final storeGroups =
                grouped.entries.map((entry) {
                  int storeId = 0;
                  String extractedFilial = entry.key.trim();

                  final match = RegExp(r'Loja (\d+)').firstMatch(entry.key);
                  if (match != null) {
                    storeId = int.tryParse(match.group(1)!) ?? 0;
                    extractedFilial = match.group(1)!;
                  }

                  return StoreGroupModel(
                    storeName: entry.key.trim(),
                    storeId: storeId,
                    filialCode: extractedFilial,
                    items:
                        entry.value
                          ..sort((a, b) => a.dueDateDt.compareTo(b.dueDateDt)),
                  );
                }).toList();

            return InstallmentData(
              clientCode: clientCode,
              clientName: clientName,
              storeGroups: storeGroups,
              pixKeys: pixKeys,
            );
          } catch (e) {
            debugPrint("JSON Parse Error: $e");
            debugPrint("Raw JSON: $rawJson");
            throw FormatException("Erro ao processar dados do servidor: $e");
          }
        }

        throw Exception(
          'Failed to load data from API: Status ${response.statusCode}',
        );
      } on DioException catch (e) {
        if (e.response?.statusCode == 500 && attempts < 3) {
          debugPrint('Error 500, retrying... (Attempt $attempts)');
          await Future.delayed(const Duration(seconds: 1));
          continue;
        }
        debugPrint('Error fetching installments: $e');
        rethrow;
      } catch (e) {
        debugPrint('Error fetching installments: $e');
        rethrow;
      }
    }
    throw Exception('Failed to load data after 3 attempts');
  }

  Future<InstallmentData> _getMockData() async {
    await Future.delayed(const Duration(seconds: 1));
    final items = [
      {
        "id": "A100",
        "description": "TV Samsung - Parc 5/10",
        "value": 150.00,
        "due_date": "2023-12-20",
        "status": "OPEN",
      },
      {
        "id": "A101",
        "description": "TV Samsung - Parc 6/10",
        "value": 150.00,
        "due_date": "2024-01-20",
        "status": "OPEN",
      },
    ];
    return InstallmentData(
      clientCode: '000001',
      clientName: 'Mock Client',
      storeGroups: [
        StoreGroupModel(
          storeName: 'Lojas Cometa - Centro',
          storeId: 101,
          items: items.map((e) => InstallmentModel.fromJson(e)).toList(),
        ),
      ],
    );
  }

  Future<Map<String, dynamic>> payWithPix({
    required List<InstallmentModel> installments,
    required String cpf,
    required String clientCode,
    required String clientName,
    required String filial,
    required double totalAmount,
  }) async {
    int attempts = 0;
    while (attempts < 3) {
      try {
        attempts++;
        if (cpf.startsWith('999')) {
          await Future.delayed(const Duration(seconds: 2));
          return {
            "transaction_id": "998877",
            "pix_copy_paste":
                "00020126360014BR.GOV.BCB.PIX.FAKE.CODE.FOR.TESTING",
            "qr_code_base64": "",
          };
        }

        if (_accessToken == null) {
          await _authenticate();
        }

        final cleanCpf = cpf.replaceAll(RegExp(r'\D'), '');

        final double totalInterest = installments.fold(
          0.0,
          (sum, i) => sum + i.interest,
        );

        final titulos =
            installments
                .map(
                  (i) => {
                    "FILIAL": filial,
                    "PREFIXO": i.prefix,
                    "NUMERO": i.number,
                    "PARCELA": i.installment,
                    "TIPO": i.type,
                    "VALOR": i.value.toStringAsFixed(2).replaceAll('.', ','),
                    "JUROS": i.interest.toStringAsFixed(2).replaceAll('.', ','),
                  },
                )
                .toList();

        final body = {
          "FILIAL": filial,
          "CODIGO": clientCode,
          "NOME": clientName,
          "CPF": cleanCpf,
          "TITULOS": titulos,
          "TOTAIS": [
            {
              "VALOR_TOTAL": totalAmount
                  .toStringAsFixed(2)
                  .replaceAll('.', ','),
              "TOTAL_JUROS": totalInterest
                  .toStringAsFixed(2)
                  .replaceAll('.', ','),
            },
          ],
        };

        final response = await _dio.post(
          '${ApiConstants.baseUrl}${ApiConstants.postPayment}',
          data: body,
          options: Options(headers: {'Authorization': 'Bearer $_accessToken'}),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          final data = response.data;

          String? pixCode;

          // Try to find the PIX code in various possible fields
          if (data is Map) {
            pixCode =
                data['Chave'] ??
                data['CHAVE_PIX'] ??
                data['qrcode'] ??
                data['brcode'] ??
                data['pix_copy_paste'];

            if (pixCode == null &&
                data['_messages'] != null &&
                (data['_messages'] as List).isNotEmpty) {
              final msg = data['_messages'][0];
              if (msg is Map) {
                pixCode =
                    msg['Chave'] ??
                    msg['CHAVE_PIX'] ??
                    msg['qrcode'] ??
                    msg['brcode'] ??
                    msg['pix_copy_paste'];
              }
            }
          }

          if (pixCode != null) {
            return {
              "pix_copy_paste": pixCode,
              "transaction_id": "API-${DateTime.now().millisecondsSinceEpoch}",
            };
          }
        }
        throw Exception(
          'Failed to generate PIX: ${response.statusCode} - No PIX code found in response',
        );
      } on DioException catch (e) {
        if (e.response?.statusCode == 500 && attempts < 3) {
          debugPrint(
            'Error 500 in PIX generation, retrying... (Attempt $attempts)',
          );
          await Future.delayed(const Duration(seconds: 1));
          continue;
        }
        debugPrint('Error paying: $e');
        rethrow;
      } catch (e) {
        debugPrint('Error paying: $e');
        rethrow;
      }
    }
    throw Exception('Failed to generate PIX after 3 attempts');
  }
}
