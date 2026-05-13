import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';

class StoresScreen extends StatelessWidget {
  const StoresScreen({super.key});

  final List<Map<String, String>> _stores = const [
    {
      'name': 'Lojas Cometa - Centro',
      'address': 'Rua XV de Novembro, 100 - Centro',
      'city': 'São Paulo - SP',
      'phone': '(11) 3333-4444',
      'lat': '-23.5505',
      'lng': '-46.6333',
    },
    {
      'name': 'Lojas Cometa - Shopping Plaza',
      'address': 'Av. Paulista, 2000 - Loja 45',
      'city': 'São Paulo - SP',
      'phone': '(11) 3333-5555',
      'lat': '-23.5505',
      'lng': '-46.6333',
    },
    {
      'name': 'Lojas Cometa - Zona Sul',
      'address': 'Av. Santo Amaro, 500',
      'city': 'São Paulo - SP',
      'phone': '(11) 3333-6666',
      'lat': '-23.5505',
      'lng': '-46.6333',
    },
  ];

  Future<void> _openMap(String lat, String lng) async {
    final Uri url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _callStore(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    final Uri url = Uri.parse('tel:$cleanPhone');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nossas Lojas')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _stores.length,
        itemBuilder: (context, index) {
          final store = _stores[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.store, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          store['name']!,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 20,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(store['address']!),
                            Text(
                              store['city']!,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.phone_outlined,
                        size: 20,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(store['phone']!),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _callStore(store['phone']!),
                        icon: const Icon(Icons.phone),
                        label: const Text('Ligar'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () => _openMap(store['lat']!, store['lng']!),
                        icon: const Icon(Icons.map),
                        label: const Text('Mapa'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
