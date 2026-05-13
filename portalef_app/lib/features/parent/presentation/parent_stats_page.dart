import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../data/parent_repository.dart';
import '../domain/parent_stats.dart';
import 'parent_scaffold.dart';

final parentStatsProvider = FutureProvider.family<ParentStats, int>((
  ref,
  studentId,
) async {
  return ref.watch(parentRepositoryProvider).getStats(studentId: studentId);
});

class ParentStatsPage extends ConsumerWidget {
  const ParentStatsPage({super.key, required this.studentId});

  final int? studentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = studentId;
    if (id == null) {
      return ParentScaffold(
        selectedIndex: 1,
        title: 'Estatísticas',
        body: const Center(child: Text('studentId ausente')),
      );
    }

    final statsAsync = ref.watch(parentStatsProvider(id));

    return ParentScaffold(
      selectedIndex: 1,
      title: 'Estatísticas',
      studentId: id,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(parentStatsProvider(id));
          await ref.read(parentStatsProvider(id).future);
        },
        child: statsAsync.when(
          data: (stats) {
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _GlobalGrid(stats: stats.global),
                const SizedBox(height: 12),
                _EvolutionCard(points: stats.evolution),
                const SizedBox(height: 12),
                _SubjectsCard(subjects: stats.subjects),
                const SizedBox(height: 12),
                _RecentCard(recent: stats.recent),
              ],
            );
          },
          error: (error, _) {
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('Erro ao carregar estatísticas: $error'),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}

class _GlobalGrid extends StatelessWidget {
  const _GlobalGrid({required this.stats});

  final ParentGlobalStats stats;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.35,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _KpiCard(
          title: 'Tempo (mês)',
          value: '${stats.tempoTotal} min',
          icon: PhosphorIconsRegular.clock,
        ),
        _KpiCard(
          title: 'Média acertos',
          value: '${stats.mediaAcertos}%',
          icon: PhosphorIconsRegular.percent,
        ),
        _KpiCard(
          title: 'Trilha',
          value: '${stats.progressoTrilha}%',
          icon: PhosphorIconsRegular.trendUp,
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryTeal.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppColors.primaryTeal),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(title, style: const TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _EvolutionCard extends StatelessWidget {
  const _EvolutionCard({required this.points});

  final List<ParentEvolutionPoint> points;

  @override
  Widget build(BuildContext context) {
    final spots = <FlSpot>[];
    for (var i = 0; i < points.length; i += 1) {
      spots.add(FlSpot(i.toDouble(), points[i].nota.toDouble()));
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Evolução (nota por semana)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child:
                  points.isEmpty
                      ? Center(
                        child: Text(
                          'Sem dados',
                          style: TextStyle(
                            color: AppColors.darkBg.withValues(alpha: 0.7),
                          ),
                        ),
                      )
                      : LineChart(
                        LineChartData(
                          minY: 0,
                          maxY: 10,
                          gridData: const FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                          titlesData: FlTitlesData(
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            leftTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 26,
                                interval: 1,
                                getTitlesWidget: (value, meta) {
                                  final i = value.toInt();
                                  if (i < 0 || i >= points.length) {
                                    return const SizedBox.shrink();
                                  }
                                  final label = points[i].label ?? '';
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      label,
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          lineBarsData: [
                            LineChartBarData(
                              spots: spots,
                              isCurved: true,
                              color: AppColors.primaryTeal,
                              barWidth: 3,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                color: AppColors.primaryTeal.withValues(
                                  alpha: 0.12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubjectsCard extends StatelessWidget {
  const _SubjectsCard({required this.subjects});

  final List<ParentSubjectStat> subjects;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Distribuição por matéria',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            if (subjects.isEmpty)
              const Text(
                'Sem dados',
                style: TextStyle(color: AppColors.textSecondary),
              )
            else
              for (final s in subjects.take(8))
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(s.subject.isEmpty ? '—' : s.subject),
                      ),
                      Text(
                        '${s.hours}h',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${s.count}',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _RecentCard extends StatelessWidget {
  const _RecentCard({required this.recent});

  final List<ParentRecentActivity> recent;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Atividades recentes',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            if (recent.isEmpty)
              const Text(
                'Sem dados',
                style: TextStyle(color: AppColors.textSecondary),
              )
            else
              for (final r in recent)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        margin: const EdgeInsets.only(top: 6),
                        decoration: const BoxDecoration(
                          color: AppColors.primaryTeal,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              r.titulo.isEmpty ? '—' : r.titulo,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              [
                                if (r.materia.isNotEmpty) r.materia,
                                if (r.tipo.isNotEmpty) r.tipo,
                                if (r.dataRegistro != null)
                                  _formatDate(r.dataRegistro!),
                              ].join(' • '),
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${(r.tempoEstudoDiario / 60).round()} min • ${r.acertos}/${r.questoesRespondidas} acertos',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

String _formatDate(DateTime date) {
  final d = date.toLocal();
  final dd = d.day.toString().padLeft(2, '0');
  final mm = d.month.toString().padLeft(2, '0');
  final yyyy = d.year.toString();
  return '$dd/$mm/$yyyy';
}
