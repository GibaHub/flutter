import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants.dart';
import '../../data/auth_service.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  String? _error;
  List<dynamic> _appointments = [];

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
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

      final response = await dio.get('/appointments/my-appointments');
      setState(() {
        _appointments = response.data as List<dynamic>;
      });
    } catch (e) {
      setState(() {
        _error = 'Não foi possível carregar seus agendamentos.';
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
        title: const Text('Meus Agendamentos'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadAppointments,
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

    if (_appointments.isEmpty) {
      return const Center(
        child: Text('Você ainda não possui agendamentos.'),
      );
    }

    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _appointments.length,
      itemBuilder: (context, index) {
        final appointment = _appointments[index] as Map<String, dynamic>;
        final therapy = appointment['therapy'] as Map<String, dynamic>?;
        final therapist = appointment['therapist'] as Map<String, dynamic>?;
        final dateTimeStr = appointment['dateTime'] as String?;
        final status = appointment['status'] as String? ?? 'PENDING';

        final therapyName = therapy?['name'] as String? ?? 'Terapia';
        final therapistName = therapist?['name'] as String? ?? 'Terapeuta';

        String dateLabel = '';
        if (dateTimeStr != null) {
          try {
            final date = DateTime.parse(dateTimeStr);
            dateLabel = dateFormat.format(date);
          } catch (_) {}
        }

        Color statusColor;
        switch (status) {
          case 'CONFIRMED':
            statusColor = Colors.greenAccent;
            break;
          case 'CANCELED':
            statusColor = Colors.redAccent;
            break;
          default:
            statusColor = Colors.orangeAccent;
        }

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
                Icons.calendar_today,
                color: Colors.deepPurpleAccent,
              ),
            ),
            title: Text(
              therapyName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('Terapeuta: $therapistName'),
                if (dateLabel.isNotEmpty)
                  Text(
                    dateLabel,
                    style: const TextStyle(color: Colors.purpleAccent),
                  ),
                const SizedBox(height: 4),
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

