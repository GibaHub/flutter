import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
// Remover: import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../constants/app_colors.dart';

import '../providers/auth_provider.dart';

class DetalhesClientePage extends StatefulWidget {
  final Map<String, dynamic> cliente;

  const DetalhesClientePage({
    Key? key,
    required this.cliente,
  }) : super(key: key);

  @override
  State<DetalhesClientePage> createState() => _DetalhesClientePageState();
}

class _DetalhesClientePageState extends State<DetalhesClientePage>
    with TickerProviderStateMixin {
  // Variáveis de estado
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  late AnimationController _rotationController;

  Map<String, dynamic>? dadosCliente;
  bool isLoading = true;
  bool isError = false;
  String _loadingStatus = 'Carregando dados do cliente...';
  final TextEditingController _novoLimiteController = TextEditingController();
  String _nomeUsuario = 'Usuário não identificado';

  // Getters
  String get codigo => widget.cliente['id'] ?? '';
  String get filial => widget.cliente['filial'] ?? '';
  String get limite {
    if (widget.cliente['limite'] != null &&
        widget.cliente['limite'].toString().isNotEmpty) {
      return widget.cliente['limite'].toString();
    }
    return widget.cliente['limite_atual']?.toString() ?? '0';
  }

  // REMOVER estas duas linhas:
  // // Métodos...
  // }

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _buscarDados();
    _carregarNomeUsuario();
  }

  // Método para carregar o nome do usuário
  Future<void> _carregarNomeUsuario() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.currentUser;
      if (user != null) {
        setState(() {
          _nomeUsuario = user.apelido.isNotEmpty ? user.apelido : user.nome;
        });
      }
    } catch (e) {
      debugPrint('Erro ao carregar nome do usuário: $e');
    }
  }

  String _cleanNumeric(dynamic value) {
    if (value == null) return '0';
    String str = value.toString();
    // Remove R$, espaços, pontos de milhares
    str = str.replaceAll('R\$', '').replaceAll(' ', '').replaceAll('.', '');
    // Substitui vírgula por ponto para parse
    str = str.replaceAll(',', '.');
    double? d = double.tryParse(str);
    if (d == null) return '0';
    // Se for inteiro, retorna sem .0
    if (d == d.toInt()) return d.toInt().toString();
    return d.toString();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _rotationController.dispose();
    _novoLimiteController.dispose();
    super.dispose();
  }

  void _mostrarLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 2,
                  ),
                ),
                const SizedBox(width: 20),
                const Expanded(
                  child: Text(
                    "Processando...",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _buscarDados() async {
    setState(() {
      isLoading = true;
      isError = false;
      _loadingStatus = 'Carregando dados do cliente...';
    });

    _animationController.repeat();
    _rotationController.repeat();

    try {
      setState(() {
        _loadingStatus = 'Buscando dados do cliente...';
      });

      await Future.delayed(const Duration(milliseconds: 500));

      final response = await ApiService().getWithAuth(
        '/appcometa/clientes/ClientDataSearch?filial=$filial&id=$codigo',
      );

      setState(() {
        _loadingStatus = 'Processando informações...';
      });

      await Future.delayed(const Duration(milliseconds: 300));

      if (mounted) {
        setState(() {
          dadosCliente = response;
          isLoading = false;
          _loadingStatus = 'Concluído!';
        });
      }

      _animationController.stop();
      _rotationController.stop();
    } catch (e) {
      if (mounted) {
        setState(() {
          isError = true;
          isLoading = false;
          _loadingStatus = 'Erro ao carregar dados';
        });
      }

      _animationController.stop();
      _rotationController.stop();
    }
  }

  void _mostrarDialogoRedefinir() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.edit,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Redefinir Limite',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _novoLimiteController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Novo Limite Autorizado',
                  prefixText: 'R\$ ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _redefinirLimite();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLoadingWidget() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: isDark ? AppColors.backgroundDark : Colors.transparent,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Ícone animado
          AnimatedBuilder(
            animation: _rotationController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationController.value * 2 * 3.14159,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Icon(
                    Icons.person_search,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // Barra de progresso
          Container(
            width: double.infinity,
            height: 6,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.grey[300],
              borderRadius: BorderRadius.circular(3),
            ),
            child: AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _progressAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                      ),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Status text
          Text(
            _loadingStatus,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.onSurfaceDark : Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Indicador circular
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: isDark ? AppColors.surfaceDark : Colors.white,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: isDark
              ? null
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    Colors.grey[50]!,
                  ],
                ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value,
      {IconData? icon, Color? valueColor}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 20,
              color: AppColors.primary.withOpacity(0.7),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.onSurfaceDark : Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: valueColor ?? (isDark ? Colors.white : Colors.black87),
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required VoidCallback onPressed,
    required IconData icon,
    required Color color,
    bool isOutlined = false,
  }) {
    return Expanded(
      child: Container(
        height: 48,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: isOutlined
            ? OutlinedButton.icon(
                onPressed: onPressed,
                icon: Icon(icon, size: 18),
                label: Text(label),
                style: OutlinedButton.styleFrom(
                  foregroundColor: color,
                  side: BorderSide(color: color),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              )
            : ElevatedButton.icon(
                onPressed: onPressed,
                icon: Icon(icon, size: 18),
                label: Text(label),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Detalhes do Cliente',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: isDark
            ? null
            : Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
              ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _buscarDados,
          ),
        ],
      ),
      body: isLoading
          ? _buildLoadingWidget()
          : isError
              ? _buildErrorWidget()
              : _buildContent(),
    );
  }

  Widget _buildErrorWidget() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black26 : Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[50]?.withOpacity(isDark ? 0.1 : 1.0),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.error_outline,
                color: Colors.red[400],
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar dados',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Não foi possível carregar os dados do cliente. Verifique sua conexão e tente novamente.',
              style: TextStyle(
                color: isDark ? AppColors.onSurfaceDark : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _buscarDados,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar Novamente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
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

  Widget _buildContent() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (kDebugMode) {
      debugPrint('=== DEBUG DETALHES CLIENTE ===');
      debugPrint('widget.cliente: ${widget.cliente}');
      debugPrint('dadosCliente: $dadosCliente');
    }

    // Função para limpar formatação monetária
    double parseMoneyValue(String? value) {
      if (value == null || value.isEmpty) return 0;
      // Remove R$, espaços, pontos de milhares e substitui vírgula por ponto
      String cleanValue = value
          .replaceAll('R\$', '')
          .replaceAll(' ', '')
          .replaceAll('.', '')
          .replaceAll(',', '.');
      return double.tryParse(cleanValue) ?? 0;
    }

    // Buscar limite atual da API (formatado) ou dos dados passados (não formatado)
    final limiteAtual = dadosCliente?['LIMITE'] != null
        ? parseMoneyValue(dadosCliente!['LIMITE'].toString())
        : parseMoneyValue(widget.cliente['limite_atual']?.toString() ?? '0');

    // Buscar limite solicitado dos dados passados (também pode estar formatado)
    final limiteSolicitado =
        parseMoneyValue(widget.cliente['limite']?.toString() ?? '0');

    if (kDebugMode) {
      debugPrint('dadosCliente[LIMITE]: ${dadosCliente?['LIMITE']}');
      debugPrint(
          'widget.cliente[limite_atual]: ${widget.cliente['limite_atual']}');
      debugPrint('widget.cliente[limite]: ${widget.cliente['limite']}');
      debugPrint('limiteAtual calculado: $limiteAtual');
      debugPrint('limiteSolicitado calculado: $limiteSolicitado');
      debugPrint('==============================');
    }

    final isAumento = limiteSolicitado > limiteAtual;

    return RefreshIndicator(
      onRefresh: _buscarDados,
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header do cliente
            _buildInfoCard(
              'Informações do Cliente',
              [
                _buildInfoRow(
                  'Nome:',
                  dadosCliente?['NOME'] ?? '---',
                  icon: Icons.person,
                ),
                _buildInfoRow(
                  'Código:',
                  dadosCliente?['CODIGO'] ?? '---',
                  icon: Icons.tag,
                ),
                _buildInfoRow(
                  'Filial:',
                  filial, // Usar 'filial' em vez de 'widget.filial'
                  icon: Icons.business,
                ),
              ],
            ),

            // Informações de limite
            _buildInfoCard(
              'Análise de Limite',
              [
                _buildInfoRow(
                  'Limite Atual:',
                  'R\$ ${limiteAtual.toStringAsFixed(2).replaceAll('.', ',')}',
                  icon: Icons.account_balance_wallet,
                ),
                _buildInfoRow(
                  'Limite Solicitado:',
                  'R\$ ${limiteSolicitado.toStringAsFixed(2).replaceAll('.', ',')}',
                  icon: isAumento ? Icons.trending_up : Icons.trending_down,
                  valueColor:
                      isAumento ? Colors.green[700] : Colors.orange[700],
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? (isAumento
                            ? Colors.green[900]!.withOpacity(0.3)
                            : Colors.orange[900]!.withOpacity(0.3))
                        : (isAumento ? Colors.green[50] : Colors.orange[50]),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark
                          ? (isAumento
                              ? Colors.green[700]!
                              : Colors.orange[700]!)
                          : (isAumento
                              ? Colors.green[200]!
                              : Colors.orange[200]!),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isAumento ? Icons.arrow_upward : Icons.arrow_downward,
                        color:
                            isAumento ? Colors.green[700] : Colors.orange[700],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isAumento
                            ? 'Solicitação de AUMENTO'
                            : 'Solicitação de REDUÇÃO',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isAumento
                              ? Colors.green[700]
                              : Colors.orange[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Informações financeiras
            _buildInfoCard(
              'Situação Financeira',
              [
                _buildInfoRow(
                  'Vendas:',
                  dadosCliente?['VENDAS'] ?? '---',
                  icon: Icons.shopping_cart,
                ),
                _buildInfoRow(
                  'Total Pago:',
                  dadosCliente?['TOTAL_PAGO'] ?? '---',
                  icon: Icons.payment,
                  valueColor: Colors.green[700],
                ),
                _buildInfoRow(
                  'Total Aberto:',
                  dadosCliente?['TOTAL_ABERTO'] ?? '---',
                  icon: Icons.pending_actions,
                  valueColor: Colors.orange[700],
                ),
                _buildInfoRow(
                  'Valor em Atraso:',
                  dadosCliente?['VALOR_ATRASO'] ?? '---',
                  icon: Icons.warning,
                  valueColor: Colors.red[700],
                ),
              ],
            ),

            // Informações de atraso
            _buildInfoCard(
              'Histórico de Pagamentos',
              [
                _buildInfoRow(
                  'Média de Atraso:',
                  dadosCliente?['MEDIA_ATRASO'] ?? '---',
                  icon: Icons.schedule,
                ),
                _buildInfoRow(
                  'Títulos em Atraso:',
                  dadosCliente?['TITULOS_ATRASO'] ?? '---',
                  icon: Icons.receipt_long,
                ),
                _buildInfoRow(
                  'Total Desconto:',
                  dadosCliente?['TOTAL_DESCONTO'] ?? '---',
                  icon: Icons.discount,
                ),
                _buildInfoRow(
                  'Total Juros:',
                  dadosCliente?['TOTAL_JUROS'] ?? '---',
                  icon: Icons.percent,
                ),
                _buildInfoRow(
                  'Tempo Limite:',
                  dadosCliente?['TEMPO_LIMITE'] ?? '---',
                  icon: Icons.timer,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Botões de ação
            Row(
              children: [
                _buildActionButton(
                  label: 'Aprovar',
                  onPressed: _aprovarLimite,
                  icon: Icons.check_circle,
                  color: Colors.green,
                ),
                _buildActionButton(
                  label: 'Recusar',
                  onPressed: _recusarLimite,
                  icon: Icons.cancel,
                  color: Colors.red,
                  isOutlined: true,
                ),
                _buildActionButton(
                  label: 'Redefinir',
                  onPressed: _mostrarDialogoRedefinir,
                  icon: Icons.edit,
                  color: AppColors.primary,
                  isOutlined: true,
                ),
              ],
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _aprovarLimite() async {
    _mostrarLoadingDialog();
    try {
      final lim = _cleanNumeric(limite);
      final limAtu = _cleanNumeric(dadosCliente?['LIMITE']);

      if (kDebugMode) {
        debugPrint(
            'DetalhesCliente: Aprovando Limite. Novo: $lim, Atual: $limAtu');
      }

      final body = {
        'user': _nomeUsuario.toUpperCase(),
        'filial': filial.padLeft(2, '0'),
        'id': codigo.padLeft(6, '0'),
        'limite': lim,
        'limite_atual': limAtu,
      };
      await ApiService()
          .puttWithAuth('/appcometa/clientes/customerdataupdate', body);

      if (!mounted) return;
      Navigator.pop(context); // Fecha loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Limite aprovado com sucesso!'),
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
        Navigator.pop(context, true);
      });
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text('Erro: $e')),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  Future<void> _recusarLimite() async {
    _mostrarLoadingDialog();
    try {
      final body = {
        'user': _nomeUsuario.toUpperCase(),
        'filial': filial.padLeft(2, '0'),
        'id': codigo.padLeft(6, '0'),
        'limite': '0',
        'limite_atual': _cleanNumeric(dadosCliente?['LIMITE']),
      };
      await ApiService()
          .puttWithAuth('/appcometa/clientes/customerdataupdate', body);

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.info, color: Colors.white),
              SizedBox(width: 8),
              Text('Limite recusado com sucesso!'),
            ],
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pop(context, true);
      });
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text('Erro: $e')),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  Future<void> _redefinirLimite() async {
    _mostrarLoadingDialog();
    try {
      final body = {
        'user': _nomeUsuario.toUpperCase(),
        'filial': filial.padLeft(2, '0'),
        'id': codigo.padLeft(6, '0'),
        'limite': _cleanNumeric(_novoLimiteController.text),
        'limite_atual': _cleanNumeric(dadosCliente?['LIMITE']),
      };

      await ApiService()
          .puttWithAuth('/appcometa/clientes/customerdataupdate', body);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.edit, color: Colors.white),
              SizedBox(width: 8),
              Text('Limite redefinido com sucesso!'),
            ],
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pop(context, true);
      });
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text('Erro: $e')),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }
}
