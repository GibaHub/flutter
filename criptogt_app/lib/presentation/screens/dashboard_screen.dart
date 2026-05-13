import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../core/auth/auth_service.dart';
import '../../core/api/api_client.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiClient _apiClient = ApiClient();
  bool _isLoading = true;
  Map<String, dynamic>? _data;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
    _setupFCM();
  }

  Future<void> _setupFCM() async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        String? token = await messaging.getToken();
        if (token != null) {
          print('FCM Token: $token');
          await _apiClient.post('/notifications/register-token', body: {
            'token': token,
            'platform': 'android', // Ajustar dinamicamente se necessário
          });
        }
      }
      
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (message.notification != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${message.notification!.title}: ${message.notification!.body}'),
              backgroundColor: Colors.green,
            ),
          );
        }
      });
    } catch (e) {
      print('Erro no FCM: $e');
    }
  }

  Future<void> _loadData() async {
    try {
      final response = await _apiClient.get('/dashboard/summary');
      if (response.statusCode == 200) {
        setState(() {
          _data = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        throw Exception('Falha ao carregar dados: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthService>(context).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('CriptoGT Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthService>(context, listen: false).logout();
            },
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Erro: $_error'))
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text('Olá, ${user?['name'] ?? 'Usuário'}!',
                          style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 20),
                      if (_data != null) ...[
                        _buildCard(
                          'Saldo Total Estimado',
                          'US\$ ${(_data!['saldoPorExchange']?['total'] ?? 0).toStringAsFixed(2)}',
                          Colors.blue,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _buildCard(
                                'Ordens Ativas',
                                '${_data!['ordensCompradas'] ?? 0}',
                                Colors.green,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildCard(
                                'Ordens Pendentes',
                                '${_data!['ordensPendentes'] ?? 0}',
                                Colors.orange,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text('Maiores Altas (24h)',
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 10),
                        ...(_data!['topMovers']?['ganhos'] as List? ?? [])
                            .map((m) => ListTile(
                                  title: Text(m['symbol']),
                                  trailing: Text(
                                    '${m['priceChangePercent']}%',
                                    style: const TextStyle(color: Colors.green),
                                  ),
                                  dense: true,
                                )),
                      ]
                    ],
                  ),
                ),
    );
  }

  Widget _buildCard(String title, String value, Color color) {
    return Card(
      elevation: 4,
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 24, color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
