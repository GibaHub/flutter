import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../core/constants.dart';

class TherapiesScreen extends StatefulWidget {
  const TherapiesScreen({super.key});

  @override
  State<TherapiesScreen> createState() => _TherapiesScreenState();
}

class _TherapiesScreenState extends State<TherapiesScreen> {
  final Dio _dio = Dio(BaseOptions(baseUrl: AppConstants.baseUrl));
  bool _isLoading = true;
  String? _error;
  List<dynamic> _therapies = [];

  @override
  void initState() {
    super.initState();
    _loadTherapies();
  }

  Future<void> _loadTherapies() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _dio.get('/therapies');
      setState(() {
        _therapies = response.data as List<dynamic>;
      });
    } catch (e) {
      setState(() {
        _error = 'Não foi possível carregar as terapias.';
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
        title: const Text('Terapias'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadTherapies,
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

    if (_therapies.isEmpty) {
      return const Center(
        child: Text('Nenhuma terapia cadastrada no momento.'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _therapies.length,
      itemBuilder: (context, index) {
        final therapy = _therapies[index] as Map<String, dynamic>;
        final name = therapy['name'] as String? ?? '';
        final description = therapy['description'] as String? ?? '';
        final price = therapy['price']?.toString();
        final duration = therapy['durationMin']?.toString();

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          color: Colors.white.withOpacity(0.05),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                if (price != null)
                  Text(
                    'Valor: R\$ $price',
                    style: const TextStyle(
                      color: Colors.purpleAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                if (duration != null)
                  Text(
                    'Duração: $duration min',
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

