import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../constants/app_colors.dart';

class CadastroClientePage extends StatefulWidget {
  const CadastroClientePage({Key? key}) : super(key: key);

  @override
  State<CadastroClientePage> createState() => _CadastroClientePageState();
}

class _CadastroClientePageState extends State<CadastroClientePage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _rgController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _enderecoController = TextEditingController();
  final TextEditingController _numeroEnderecoController =
      TextEditingController();
  final TextEditingController _complementoController = TextEditingController();
  final TextEditingController _cidadeController = TextEditingController();
  final TextEditingController _ufController = TextEditingController();
  final TextEditingController _dataNascimentoController = TextEditingController();
  final TextEditingController _naturalidadeController = TextEditingController();
  final TextEditingController _ufNascimentoController = TextEditingController();
  final TextEditingController _nomePaiController = TextEditingController();
  final TextEditingController _nomeMaeController = TextEditingController();
  final TextEditingController _rendaController = TextEditingController();
  final TextEditingController _ocupacaoController = TextEditingController();
  final TextEditingController _empresaController = TextEditingController();
  final TextEditingController _cepController = TextEditingController();
  final TextEditingController _bairroController = TextEditingController();
  final TextEditingController _pontoReferenciaController = TextEditingController();

  String _sexo = 'M';
  bool _comprovRenda = true;

  // Animation Controllers
  late AnimationController _fadeController;
  late AnimationController _progressController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _progressAnimation;

  // State variables
  bool _isLoading = false;
  String? _errorMessage;
  String _loadingStatus = 'Preparando cadastro...';

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _progressController.dispose();
    _nomeController.dispose();
    _cpfController.dispose();
    _rgController.dispose();
    _telefoneController.dispose();
    _emailController.dispose();
    _enderecoController.dispose();
    _numeroEnderecoController.dispose();
    _complementoController.dispose();
    _cidadeController.dispose();
    _ufController.dispose();
    _dataNascimentoController.dispose();
    _naturalidadeController.dispose();
    _ufNascimentoController.dispose();
    _nomePaiController.dispose();
    _nomeMaeController.dispose();
    _rendaController.dispose();
    _ocupacaoController.dispose();
    _empresaController.dispose();
    _cepController.dispose();
    _bairroController.dispose();
    _pontoReferenciaController.dispose();
    super.dispose();
  }

  String _onlyDigits(String input) => input.replaceAll(RegExp(r'\\D'), '');

  String _formatDataNascimento(String input) {
    final digits = _onlyDigits(input);
    if (digits.length != 8) return digits;

    final year = int.tryParse(digits.substring(0, 4));
    if (year != null && year >= 1900 && year <= 2100) {
      return digits;
    }

    final dd = digits.substring(0, 2);
    final mm = digits.substring(2, 4);
    final yyyy = digits.substring(4, 8);
    return '$yyyy$mm$dd';
  }

  String _buildNomeReduz(String nome) {
    final reduced = nome.replaceAll(RegExp(r'\\s+'), '');
    if (reduced.length <= 10) return reduced.toUpperCase();
    return reduced.substring(0, 10).toUpperCase();
  }

  Future<void> _cadastrarCliente() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _loadingStatus = 'Validando dados...';
    });

    _progressController.repeat();

    try {
      setState(() {
        _loadingStatus = 'Enviando dados...';
      });

      final payload = <String, dynamic>{
        'nome': _nomeController.text.trim(),
        'nomereduz': _buildNomeReduz(_nomeController.text.trim()),
        'email': _emailController.text.trim(),
        'cpf': _onlyDigits(_cpfController.text),
        'sexo': _sexo,
        'telefone': _onlyDigits(_telefoneController.text),
        'dtnasc': _formatDataNascimento(_dataNascimentoController.text),
        'rg': _rgController.text.trim(),
        'renda': _rendaController.text.trim(),
        'comprvrend': _comprovRenda ? 'S' : 'N',
        'ocupacao': _ocupacaoController.text.trim(),
        'empresa': _empresaController.text.trim(),
        'cep': _onlyDigits(_cepController.text),
        'endereco': _enderecoController.text.trim(),
        'numend': _numeroEnderecoController.text.trim(),
        'complemento': _complementoController.text.trim(),
        'bairro': _bairroController.text.trim(),
        'estado': _ufController.text.trim().toUpperCase(),
        'naturalidade': _naturalidadeController.text.trim(),
        'ufnasc': _ufNascimentoController.text.trim().toUpperCase(),
        'nomemae': _nomeMaeController.text.trim(),
        'nomepai': _nomePaiController.text.trim(),
      };

      final response = await ApiService().postJsonWithAuthUrl(
        'https://appcometa.fortiddns.com/ag/externos/sitecredi/precadinsert',
        payload,
      );

      setState(() {
        _loadingStatus = 'Finalizando cadastro...';
      });

      if (response.statusCode >= 200 && response.statusCode < 300) {
        _progressController.stop();
        _progressController.reset();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Cliente cadastrado com sucesso!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
        
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pop(context);
        });
      } else {
        setState(() {
          _errorMessage =
              'Erro ao cadastrar cliente: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro: $e';
      });
    } finally {
      _progressController.stop();
      _progressController.reset();
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildLoadingIndicator() {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ícone rotativo
              Transform.rotate(
                angle: _progressAnimation.value * 2 * 3.14159,
                child: Icon(
                  Icons.person_add,
                  size: 48,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              
              // Status de carregamento
              Text(
                _loadingStatus,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              
              // Barra de progresso horizontal
              Container(
                width: double.infinity,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: null,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Indicador circular adicional
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorWidget() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Erro no Cadastro',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Erro desconhecido',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _errorMessage = null;
                });
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar Novamente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[400],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon, color: AppColors.primary) : null,
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
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red[400]!, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red[400]!, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey[50],
      labelStyle: TextStyle(
        color: AppColors.primary,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: TextFormField(
          controller: controller,
          decoration: _inputDecoration(label, icon: icon),
          validator: validator,
          keyboardType: keyboardType,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cadastro de Cliente',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: _isLoading
            ? Center(child: _buildLoadingIndicator())
            : _errorMessage != null
                ? Center(child: _buildErrorWidget())
                : FadeTransition(
                    opacity: _fadeAnimation,
                    child: Form(
                      key: _formKey,
                      child: ListView(
                        padding: const EdgeInsets.all(16.0),
                        children: [
                          // Cabeçalho informativo
                          Container(
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.only(bottom: 24),
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.person_add,
                                  color: Colors.white,
                                  size: 32,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Novo Cliente',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'Preencha os dados para cadastrar um novo cliente',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.9),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Seção: Dados Pessoais
                          Container(
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.person,
                                      color: AppColors.primary,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Dados Pessoais',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _buildFormField(
                                  controller: _nomeController,
                                  label: 'Nome Completo',
                                  icon: Icons.person_outline,
                                  validator: (value) => value!.isEmpty ? 'Informe o nome' : null,
                                ),
                                _buildFormField(
                                  controller: _cpfController,
                                  label: 'CPF',
                                  icon: Icons.badge_outlined,
                                  validator: (value) =>
                                      value!.isEmpty ? 'Informe o CPF' : null,
                                  keyboardType: TextInputType.number,
                                ),
                                FadeTransition(
                                  opacity: _fadeAnimation,
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    child: DropdownButtonFormField<String>(
                                      value: _sexo,
                                      decoration: _inputDecoration(
                                        'Sexo',
                                        icon: Icons.wc,
                                      ),
                                      items: const [
                                        DropdownMenuItem(
                                          value: 'M',
                                          child: Text('Masculino'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'F',
                                          child: Text('Feminino'),
                                        ),
                                      ],
                                      onChanged: (v) {
                                        if (v == null) return;
                                        setState(() => _sexo = v);
                                      },
                                    ),
                                  ),
                                ),
                                _buildFormField(
                                  controller: _dataNascimentoController,
                                  label: 'Data de Nascimento',
                                  icon: Icons.calendar_today,
                                  keyboardType: TextInputType.datetime,
                                ),
                                _buildFormField(
                                  controller: _rgController,
                                  label: 'RG',
                                  icon: Icons.badge,
                                ),
                                _buildFormField(
                                  controller: _naturalidadeController,
                                  label: 'Naturalidade',
                                  icon: Icons.place_outlined,
                                ),
                                _buildFormField(
                                  controller: _ufNascimentoController,
                                  label: 'UF Nascimento',
                                  icon: Icons.map_outlined,
                                ),
                                _buildFormField(
                                  controller: _nomePaiController,
                                  label: 'Nome do Pai',
                                  icon: Icons.family_restroom,
                                ),
                                _buildFormField(
                                  controller: _nomeMaeController,
                                  label: 'Nome da Mãe',
                                  icon: Icons.family_restroom,
                                ),
                              ],
                            ),
                          ),

                          // Seção: Profissional
                          Container(
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.work,
                                      color: AppColors.primary,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Profissional',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _buildFormField(
                                  controller: _rendaController,
                                  label: 'Renda',
                                  icon: Icons.attach_money,
                                  keyboardType: TextInputType.number,
                                ),
                                FadeTransition(
                                  opacity: _fadeAnimation,
                                  child: SwitchListTile(
                                    value: _comprovRenda,
                                    onChanged: (v) =>
                                        setState(() => _comprovRenda = v),
                                    title: const Text('Comprovante de Renda'),
                                  ),
                                ),
                                _buildFormField(
                                  controller: _ocupacaoController,
                                  label: 'Ocupação (código)',
                                  icon: Icons.badge_outlined,
                                  keyboardType: TextInputType.number,
                                ),
                                _buildFormField(
                                  controller: _empresaController,
                                  label: 'Empresa',
                                  icon: Icons.apartment,
                                ),
                              ],
                            ),
                          ),

                          // Seção: Contato
                          Container(
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.contact_phone,
                                      color: AppColors.primary,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Contato',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _buildFormField(
                                  controller: _telefoneController,
                                  label: 'Telefone',
                                  icon: Icons.phone,
                                  keyboardType: TextInputType.phone,
                                ),
                                _buildFormField(
                                  controller: _emailController,
                                  label: 'Email',
                                  icon: Icons.email,
                                  keyboardType: TextInputType.emailAddress,
                                ),
                              ],
                            ),
                          ),

                          // Seção: Endereço
                          Container(
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.only(bottom: 24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      color: AppColors.primary,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Endereço',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _buildFormField(
                                  controller: _cepController,
                                  label: 'CEP',
                                  icon: Icons.local_post_office,
                                  keyboardType: TextInputType.number,
                                ),
                                _buildFormField(
                                  controller: _enderecoController,
                                  label: 'Endereço',
                                  icon: Icons.home,
                                ),
                                _buildFormField(
                                  controller: _numeroEnderecoController,
                                  label: 'Número',
                                  icon: Icons.pin,
                                  keyboardType: TextInputType.number,
                                ),
                                _buildFormField(
                                  controller: _complementoController,
                                  label: 'Complemento',
                                  icon: Icons.edit_location_alt,
                                ),
                                _buildFormField(
                                  controller: _bairroController,
                                  label: 'Bairro',
                                  icon: Icons.location_city,
                                ),
                                _buildFormField(
                                  controller: _cidadeController,
                                  label: 'Cidade',
                                  icon: Icons.location_city,
                                ),
                                _buildFormField(
                                  controller: _ufController,
                                  label: 'UF',
                                  icon: Icons.map,
                                ),
                                _buildFormField(
                                  controller: _pontoReferenciaController,
                                  label: 'Ponto de Referência',
                                  icon: Icons.place,
                                ),
                              ],
                            ),
                          ),

                          // Botão de cadastrar
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: Container(
                              width: double.infinity,
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _cadastrarCliente,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.person_add,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Cadastrar Cliente',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }
}
