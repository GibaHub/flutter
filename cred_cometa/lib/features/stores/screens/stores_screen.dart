import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class StoresScreen extends StatelessWidget {
  const StoresScreen({super.key});

  final List<Map<String, String>> stores = const [
    {
      'nome': 'Ingred Comércio de Calçados LTDA - Loja 01',
      'endereco':
          'Avenida Getúlio Vargas, 20, Centro, Camaçari- Bahia - CEP 42.800-037',
      'telefone': '(71)3507-7600 Celular: (71) 99221-0262 (Dilma / Tamires)',
      'email': 'Loja01@lojascometa.com.br',
    },
    {
      'nome': 'Pé da Moda Calçados LTDA - Loja 02',
      'endereco':
          'Rua 13 de maio, 108, Centro, Candeias – Bahia, CEP 43.800-000',
      'telefone':
          '(71)3601-7096/ 3601-5164 Celular: (71)99221-0255 (Jair/ Vânia)',
      'email': 'Loja02@lojascometa.com.br',
    },
    {
      'nome': 'Comercial de Calçados IJS LTDA - Loja 03',
      'endereco': 'Rua JJ Seabra, 74, Centro, Pojuca, Bahia, CEP: 48.120-000',
      'telefone': '(71)3645-3393/ 3645-5735 Celular:(71) 99221-0146',
      'email': 'Loja03@lojascometa.com.br',
    },
    {
      'nome': 'Comercial de Tecidos Dias D’ávila LTDA - Loja 04',
      'endereco':
          'Praça ACM (Av. Brasil), 95, Centro, Dias D’Ávila, Bahia, CEP 42.850-000',
      'telefone':
          '(71)3625-2345 Celular: (71) 99221-0246 (Anderson Raydan/ Elaine/Sebastião)',
      'email': 'Loja04@lojascometa.com.br',
    },
    {
      'nome': 'Calçados Minas Bahia LTDA - Loja 05',
      'endereco':
          'Praça ACM (Av. Brasil), 60, Centro, Dias D’avila, Bahia, CEP 42.850-000',
      'telefone': '(71)3625-3847 Celular: (71) 99221-0279 (Bruno/Fabíola)',
      'email': 'Loja05@lojascometa.com.br',
    },
    {
      'nome': 'J.B.R Comercio de Calçados LTDA -  Loja 06',
      'endereco':
          'Rua Gov. Gonçalves, 230, Centro, Valença, Bahia, CEP 45.400-000',
      'telefone':
          '(75)3641-6363/ 3641-6999 Celular: (71) 99221-0256 (Ueder /Urania)',
      'email': 'Loja06@lojascometa.com.br',
    },
    {
      'nome': 'Lafex comercial de calçados e confecções LTDA - Loja 09',
      'endereco':
          'Praça 07 de setembro, 462- Centro, Santo Estevão, Bahia, CEP 44.190-000',
      'telefone':
          '(75) 3245-3407 Celular: (71) 99221-0152 (Ézio Raydan/ Kênia/ Pedro)',
      'email': 'Loja09@lojascometa.com.br',
    },
    {
      'nome': 'Costa Souza comercial de tecidos e confecções LTDA - Loja 10',
      'endereco':
          'Av. Alberto Passos, 81, Centro, Cruz das Almas, Bahia, CEP 44.380-000',
      'telefone':
          '(75) 3621-1650/ 3621-5188 Celular: (71) 99221-0140 (Fernando / Victor)',
      'email': 'Loja10@lojascometa.com.br',
    },
    {
      'nome': 'J.R Comércio de Confecções LTDA - Loja 12',
      'endereco':
          'Av. Getúlio Vargas, 167- Centro,Camaçari , Bahia, CEP 42.800-037',
      'telefone': '(71) 3644-2904 Celular: (71) 99181-0764 (Emerson/ Aline)',
      'email': 'Loja12@lojascometa.com.br',
    },
    {
      'nome': 'Pojuca Comércio de Confecções LTDA  - Loja 13',
      'endereco': 'Rua JJ Seabra, 23, Centro, Pojuca, Bahia, CEP 48.120-000',
      'telefone': '(71) 3645-3658 Celular: (71) 99221-0351 (Paulo/ Elaiane)',
      'email': 'Loja13@lojascometa.com.br',
    },
    {
      'nome': 'Comercial de Calçados Sete LTDA - Loja 14',
      'endereco':
          'Rua Monsenhor Messias,243,Centro,Sete Lagoas,Minas Gerais, CEP 35.700-041',
      'telefone':
          '(31) 3773-3072 / 3776-8621 Celular: (71) 99221-0302 (Edvânio/Luciana)',
      'email': 'Loja14@lojascometa.com.br',
    },
    {
      'nome': 'Sebe Comercial de Calçados e Confecções LTDA - Loja 15',
      'endereco':
          'Rua Doutor Antonio Muniz, 64, Centro, Ituberá, Bahia, CEP 45.435-000',
      'telefone':
          '(73) 3256-3151 Celular: (71) 98209-5825 / 98194-6104 (Júnior /Ana Flávia)',
      'email': 'Loja15@lojascometa.com.br',
    },
    {
      'nome': 'Comercial de Calçados Souza e Pereira LTDA - Loja 16',
      'endereco':
          'Rua São Francisco, 351, Centro, Montes Claros, Minas Gerais CEP 39.400-048',
      'telefone':
          '(38)3216-9610 Celular:(71)98287-9984/ 99221-0148 (Daiane/José Paulo/Michele)',
      'email': 'Loja16@lojascometa.com.br',
    },
    {
      'nome': 'JJCR Comercio de Confecções LTDA - Loja 19',
      'endereco':
          'AV. Antônio Paterson, 195, Triângulo, Candeias – Bahia CEP 43.815-055',
      'telefone':
          '71-3601-9633 Celular: (71) 99732-0643 (Fábio Junior / Juliana)',
      'email': 'Loja19@lojascometa.com.br',
    },
    {
      'nome': 'Fabex Comercial de Calçados e Confecções LTDA - Loja 20',
      'endereco': 'Rua 13 de Maio, 47, Centro, Ituberá, Bahia, CEP 45.435-000',
      'telefone': '73-3256-3474 Celular: (71) 99743-8534 (Andréia/ Raquel)',
      'email': 'Loja20@lojascometa.com.br',
    },
    {
      'nome': 'JGR Comércio de Confecções e Calçados LTDA - Loja 21',
      'endereco':
          'Avenida Rui Barbosa, 191, Centro, Simões Filho, Bahia, CEP 43.700-000',
      'telefone': '71- 3045-0212 Celular: (71) 99719-7455 (Daniel/ Annes)',
      'email': 'Loja21@lojascometa.com.br',
    },
    {
      'nome': 'Valentina Comércio de Calçados LTDA - Loja 22',
      'endereco':
          'Rua Adelina de Sá, 03, Centro, Camaçari, Bahia, CEP 42.800-037',
      'telefone':
          '(71) 3623-5630/ 3621-5573 Celular: (71) 99722-0321 (Viviane/ Adriana/Virginia)',
      'email': 'Loja22@lojascometa.com.br',
    },
    {
      'nome':
          'Gabriela Rabelo Comércio de Confecções e Calçados Ltda - Loja 24',
      'endereco': 'Rua Landulfo Alves, 23, Centro, Gandú – BA CEP: 45450-000',
      'telefone': '(73) 3254-0054 Celular: (71) 99904-0149 (Junior / Carla)',
      'email': 'Loja24@lojascometa.com.br',
    },
    {
      'nome': 'Drall Comercial de Calçados e Confecções LTDA - Loja 25',
      'endereco': 'Drall Comercial de Calçados e Confecções LTDA',
      'telefone': '(73) 3540-1138 Celular: (38) 99907-0715 (Douglas/Poliane)',
      'email': 'Loja25@lojascometa.com.br',
    },
    {
      'nome': 'Graciosa Comércio de Confecções e Calçados LTDA - Loja 26',
      'endereco': 'Rua Landulfo Alves, 56, Centro, Gandú– BA CEP: 45450-000',
      'telefone': '(73) 3254-0506 Celular: (71) 99951-1767 (Pedro/Marina)',
      'email': 'Loja26@lojascometa.com.br',
    },
    {
      'nome': 'KEFLA COMERCIAL DE CALCADOS E CONFECCOES LTDA - Loja 28',
      'endereco':
          'Praça São Roque, S/N, Centro, Presidente Tancredo Neves– BA CEP: 45416-000',
      'telefone': '(73) 3540-1442 Celular: (38) 99926-8794 (Guilherme/Jéssica)',
      'email': 'Loja28@lojascometa.com.br',
    },
    {
      'nome': 'RABELO COMERCIO DE CALÇADOS E CONFECÇOES LTDA - Loja 29',
      'endereco':
          'Rua Lauro de Freitas, 33, Centro, Cachoeira- BA CEP: 44.300-000',
      'telefone':
          '(75) 3425 4814 Celular: (75) 99926-9860 (Carmem/Ruy/Fernando)',
      'email': 'Loja29@lojascometa.com.br',
    },
    {
      'nome': 'AQUARELA COMERCIO DE CALCADOS E CONFECCOES LTDA - Loja 31',
      'endereco':
          'Rua N Nova Pojuca, S/n, Nova Pojuca, Pojuca-BA CEP: 48.120-000',
      'telefone': '(71) 3507-7620',
      'email': 'Loja31@lojascometa.com.br',
    },
    {
      'nome': 'COMETA ADMINISTRAÇÃO EMPRESARIAL - MATRIZ',
      'endereco':
          'RUA ADELINA DE SÁ, S/N, ANDAR 2; SALAS: 01/02, CENTRO, CAMACARI, BA, CEP 42.800-051',
      'telefone': '(71) 3507-7609',
      'email': 'carmina@lojascometa.com.br',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Nossas Lojas",
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.grey[100],
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: stores.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final store = stores[index];
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    store['nome']!,
                    style: GoogleFonts.lato(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.location_on, store['endereco']!),
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.phone, store['telefone']!),
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.email, store['email']!),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.lato(color: Colors.grey[800], fontSize: 14),
          ),
        ),
      ],
    );
  }
}
