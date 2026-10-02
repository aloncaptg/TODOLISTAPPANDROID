import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/task_provider.dart';

class EmptyStateWidget extends StatelessWidget {
  final TaskFilterStatus filterStatus;
  final bool hasSearchOrFilter;
  final VoidCallback onAddTask;

  const EmptyStateWidget({
    super.key,
    required this.filterStatus,
    required this.hasSearchOrFilter,
    required this.onAddTask,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    IconData icon;
    String title;
    String subtitle;

    if (hasSearchOrFilter) {
      icon = Icons.search_off_rounded;
      title = 'Tidak Ada Tugas yang Cocok';
      subtitle = 'Coba sesuaikan kata kunci, kategori, atau filter prioritas Anda.';
    } else {
      switch (filterStatus) {
        case TaskFilterStatus.done:
          icon = Icons.assignment_turned_in_outlined;
          title = 'Belum Ada Tugas Selesai';
          subtitle = 'Selesaikan tugas dari papan Kanban atau centang tugas di daftar!';
          break;
        case TaskFilterStatus.inReview:
          icon = Icons.rate_review_outlined;
          title = 'Tidak Ada Tugas dalam Review';
          subtitle = 'Tugas yang sedang ditinjau akan muncul di sini.';
          break;
        case TaskFilterStatus.inProgress:
          icon = Icons.timelapse_rounded;
          title = 'Tidak Ada yang Sedang Dikerjakan';
          subtitle = 'Pilih tugas dari kolom To Do dan mulai kerjakan!';
          break;
        case TaskFilterStatus.todo:
          icon = Icons.celebration_rounded;
          title = 'Antrean To Do Kosong!';
          subtitle = 'Bagus! Semua tugas telah diproses atau dipindahkan.';
          break;
        case TaskFilterStatus.all:
          icon = Icons.task_alt_rounded;
          title = 'Workspace Masih Kosong';
          subtitle = 'Mulai kelola tugas harian dan proyek Anda dengan menekan tombol di bawah!';
          break;
      }
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppTheme.primarySeed.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 52,
                color: AppTheme.primarySeed,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white60 : const Color(0xFF64748B),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            if (!hasSearchOrFilter)
              FilledButton.icon(
                onPressed: onAddTask,
                icon: const Icon(Icons.add_rounded, size: 20),
                label: const Text('Buat Tugas Baru'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primarySeed,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
