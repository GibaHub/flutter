import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants.dart';
import '../../data/auth_service.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  String? _error;
  List<dynamic> _orders = [];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final token = await _authService.getToken();
      if (token == null) {
        setState(() {
          _error = 'Sessão expirada. Faça login novamente.';
        });
        return;
      }

      final dio = Dio(BaseOptions(baseUrl: AppConstants.baseUrl));
      dio.options.headers['Authorization'] = 'Bearer $token';

      final response = await dio.get('/orders/my-orders');
      setState(() {
        _orders = response.data as List<dynamic>;
      });
    } catch (e) {
      setState(() {
        _error = 'Não foi possível carregar suas compras.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Compras'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadOrders,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            _error!,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_orders.isEmpty) {
      return const Center(
        child: Text('Você ainda não possui compras.'),
      );
    }

    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _orders.length,
      itemBuilder: (context, index) {
        final order = _orders[index] as Map<String, dynamic>;
        final total = order['total']?.toString();
        final status = order['status'] as String? ?? 'PENDING';
        final createdAtStr = order['createdAt'] as String?;
        final items = order['items'] as List<dynamic>? ?? [];

        String dateLabel = '';
        if (createdAtStr != null) {
          try {
            final date = DateTime.parse(createdAtStr);
            dateLabel = dateFormat.format(date);
          } catch (_) {}
        }

        Color statusColor;
        switch (status) {
          case 'PAID':
          case 'DELIVERED':
            statusColor = Colors.greenAccent;
            break;
          case 'CANCELED':
            statusColor = Colors.redAccent;
            break;
          default:
            statusColor = Colors.orangeAccent;
        }

        final productsLabel = items
            .map((item) {
              final product = (item as Map<String, dynamic>)['product']
                  as Map<String, dynamic>?;
              final name = product?['name'] as String? ?? 'Produto';
              final quantity = item['quantity']?.toString() ?? '1';
              return '$name (x$quantity)';
            })
            .join(', ');

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          color: Colors.white.withOpacity(0.05),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                color: Colors.deepPurpleAccent,
              ),
            ),
            title: Text(
              'Pedido #${index + 1}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (dateLabel.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(dateLabel),
                ],
                if (productsLabel.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    productsLabel,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 4),
                if (total != null)
                  Text(
                    'Total: R\$ $total',
                    style: const TextStyle(
                      color: Colors.purpleAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                Text(
                  'Status: $status',
                  style: TextStyle(color: statusColor),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

