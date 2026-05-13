import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';

class CreditRegistrationScreen extends StatefulWidget {
  const CreditRegistrationScreen({super.key});

  @override
  State<CreditRegistrationScreen> createState() =>
      _CreditRegistrationScreenState();
}

class _CreditRegistrationScreenState extends State<CreditRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _fatherNameController = TextEditingController();
  final _motherNameController = TextEditingController();
  final _cpfController = TextEditingController();
  final _rgController = TextEditingController();
  final _ufBirthController = TextEditingController();
  final _naturalnessController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _genderController = TextEditingController();
  final _cepController = TextEditingController();
  final _addressController = TextEditingController();
  final _numberController = TextEditingController();
  final _complementController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _professionController = TextEditingController();
  final _incomeController = TextEditingController();

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Abertura de Crediário"),
        leading:
            Navigator.canPop(context)
                ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                )
                : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Complete seu cadastro",
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Precisamos de mais algumas informações para analisar seu crédito.",
                style: GoogleFonts.lato(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              const SizedBox(height: 24),

              _buildSectionTitle("Dados Pessoais"),
              const SizedBox(height: 16),
              _buildInput(label: "Nome Completo", controller: _nameController),
              const SizedBox(height: 16),
              _buildInput(
                label: "Email",
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              _buildInput(
                label: "Nome do Pai",
                controller: _fatherNameController,
              ),
              const SizedBox(height: 16),
              _buildInput(
                label: "Nome da Mãe",
                controller: _motherNameController,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildInput(
                      label: "CPF",
                      controller: _cpfController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        CpfInputFormatter(),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInput(label: "RG", controller: _rgController),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildInput(label: "Sexo", controller: _genderController),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildInput(
                      label: "UF Nascimento",
                      controller: _ufBirthController,
                      inputFormatters: [LengthLimitingTextInputFormatter(2)],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInput(
                      label: "Naturalidade",
                      controller: _naturalnessController,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildInput(
                      label: "Data de Nascimento",
                      controller: _birthDateController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        DataInputFormatter(),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInput(
                      label: "Celular",
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        TelefoneInputFormatter(),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              _buildSectionTitle("Endereço"),
              const SizedBox(height: 16),
              _buildInput(
                label: "CEP",
                controller: _cepController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  CepInputFormatter(),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildInput(
                      label: "Logradouro",
                      controller: _addressController,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: _buildInput(
                      label: "Número",
                      controller: _numberController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildInput(
                label: "Complemento (Opcional)",
                controller: _complementController,
              ),
              const SizedBox(height: 16),
              _buildInput(label: "Bairro", controller: _neighborhoodController),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildInput(
                      label: "Cidade",
                      controller: _cityController,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: _buildInput(
                      label: "UF",
                      controller: _stateController,
                      inputFormatters: [LengthLimitingTextInputFormatter(2)],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),
              _buildSectionTitle("Dados Profissionais"),
              const SizedBox(height: 16),
              _buildInput(
                label: "Profissão",
                controller: _professionController,
              ),
              const SizedBox(height: 16),
              _buildInput(
                label: "Renda Mensal",
                controller: _incomeController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  RealInputFormatter(moeda: true),
                ],
              ),

              const SizedBox(height: 32),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isLoading ? null : _handleSubmit,
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                            "ENVIAR SOLICITAÇÃO",
                            style: GoogleFonts.lato(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.montserrat(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildInput({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.lato(color: Colors.grey[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          if (label.contains("Opcional")) return null;
          return "Campo obrigatório";
        }
        return null;
      },
    );
  }

  void _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        setState(() => _isLoading = false);
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text("Solicitação Enviada"),
                content: const Text(
                  "Seus dados foram enviados para análise. Entraremos em contato em breve.",
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                      Navigator.pop(context); // Go back to home
                    },
                    child: const Text("OK"),
                  ),
                ],
              ),
        );
      }
    }
  }
}
