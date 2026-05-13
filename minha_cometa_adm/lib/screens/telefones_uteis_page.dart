import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_colors.dart'; // Corrigido: era ../utils/app_colors.dart

class TelefonesUteisPage extends StatelessWidget {
  const TelefonesUteisPage({Key? key}) : super(key: key);

  final List<Map<String, String>> telefonesUteis = const [
    {
      'nome': 'Sistemas - Gilberto',
      'telefone': '(11) 96600-7749',
      'whatsapp': '1196600-7749',
    },
    {
      'nome': 'Financeiro - Carmina',
      'telefone': '(71) 99221-0299',
      'whatsapp': '719922-10299',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Telefones Úteis'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [AppColors.backgroundDark, Colors.black]
                : [Colors.grey[100]!, Colors.white],
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: telefonesUteis.length,
          itemBuilder: (context, index) {
            final telefone = telefonesUteis[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      telefone['nome']!,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      telefone['telefone']!,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                _fazerLigacao(telefone['telefone']!),
                            icon: const Icon(Icons.phone, color: Colors.white),
                            label: const Text('Ligar',
                                style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                _abrirWhatsApp(telefone['whatsapp']!),
                            icon: const Icon(Icons.chat, color: Colors.white),
                            label: const Text('WhatsApp',
                                style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF25D366),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
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

  Future<void> _fazerLigacao(String telefone) async {
    final url = 'tel:${telefone.replaceAll(RegExp(r'[^0-9]'), '')}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  Future<void> _abrirWhatsApp(String whatsapp) async {
    final url = 'https://wa.me/55$whatsapp';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }
}
