import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';

class TaskItemCard extends StatefulWidget {
  final TaskModel task;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const TaskItemCard({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    required this.onTap,
  });

  @override
  State<TaskItemCard> createState() => _TaskItemCardState();
}

class _TaskItemCardState extends State<TaskItemCard> {
  bool _isExpanded = false;

  String _formatDueDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);
    final difference = targetDate.difference(today).inDays;

    if (difference == 0) {
      return 'Hari ini';
    } else if (difference == 1) {
      return 'Besok';
    } else if (difference == -1) {
      return 'Terlambat (Kemarin)';
    } else if (difference < -1) {
      return 'Terlambat (${difference.abs()} hari)';
    } else {
      return DateFormat('d MMM yyyy').format(date);
    }
  }

  bool get _isOverdue {
    if (widget.task.dueDate == null || widget.task.isCompleted) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(widget.task.dueDate!.year,
        widget.task.dueDate!.month, widget.task.dueDate!.day);
    return targetDate.isBefore(today);
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final priorityColor = AppTheme.getPriorityColor(task.priority);
    final categoryColor = AppTheme.getCategoryColor(task.category);
    final statusColor = AppTheme.getStatusColor(task.status);

    return Dismissible(
      key: ValueKey(task.id),
      // Dual swipe actions: Left to delete, Right to toggle done
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          // Hapus tugas
          return await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Hapus Tugas'),
              content: Text('Yakin ingin menghapus "${task.title}"?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text('Batal'),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.priorityUrgent,
                  ),
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: const Text('Hapus'),
                ),
              ],
            ),
          );
        } else {
          // Tandai selesai / aktif kembali
          widget.onToggle();
          return false;
        }
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          widget.onDelete();
        }
      },
      // Background swipe kanan (tandai selesai)
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.statusDone,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: Row(
          children: [
            Icon(
              task.isCompleted
                  ? Icons.undo_rounded
                  : Icons.check_circle_outline_rounded,
              color: Colors.white,
              size: 26,
            ),
            const SizedBox(width: 8),
            Text(
              task.isCompleted ? 'Aktifkan Kembali' : 'Tandai Selesai',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      // Background swipe kiri (hapus)
      secondaryBackground: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.priorityUrgent,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 26),
            SizedBox(width: 8),
            Text(
              'Hapus',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: task.isCompleted
              ? (isDark
                  ? const Color(0xFF1E293B).withValues(alpha: 0.6)
                  : const Color(0xFFF1F5F9))
              : (isDark ? const Color(0xFF1E293B) : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: task.isPinned
                ? AppTheme.primarySeed.withValues(alpha: 0.8)
                : task.isCompleted
                    ? Colors.transparent
                    : (isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0)),
            width: task.isPinned ? 1.5 : 1,
          ),
          boxShadow: task.isCompleted
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Checkbox Lingkaran Kustom
                      GestureDetector(
                        onTap: widget.onToggle,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 2, right: 12),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: task.isCompleted
                                  ? AppTheme.statusDone
                                  : Colors.transparent,
                              border: Border.all(
                                color: task.isCompleted
                                    ? AppTheme.statusDone
                                    : (isDark
                                        ? const Color(0xFF64748B)
                                        : const Color(0xFF94A3B8)),
                                width: 2,
                              ),
                            ),
                            child: task.isCompleted
                                ? const Icon(
                                    Icons.check_rounded,
                                    size: 16,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                        ),
                      ),

                      // Detail Tugas
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Judul & Pin Icon
                            Row(
                              children: [
                                if (task.isPinned) ...[
                                  const Icon(
                                    Icons.push_pin_rounded,
                                    size: 15,
                                    color: AppTheme.primarySeed,
                                  ),
                                  const SizedBox(width: 4),
                                ],
                                Expanded(
                                  child: AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 200),
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: task.isCompleted
                                          ? (isDark
                                              ? Colors.white38
                                              : Colors.black38)
                                          : (isDark
                                              ? Colors.white
                                              : const Color(0xFF0F172A)),
                                      decoration: task.isCompleted
                                          ? TextDecoration.lineThrough
                                          : TextDecoration.none,
                                    ),
                                    child: Text(task.title),
                                  ),
                                ),
                              ],
                            ),

                            // Deskripsi
                            if (task.description.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                task.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: task.isCompleted
                                      ? (isDark
                                          ? Colors.white24
                                          : Colors.black26)
                                      : (isDark
                                          ? const Color(0xFF94A3B8)
                                          : const Color(0xFF64748B)),
                                ),
                              ),
                            ],

                            const SizedBox(height: 10),

                            // Badges (Status, Kategori, Prioritas, Deadline)
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                // Badge Status Kanban
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    task.status.label,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: statusColor,
                                    ),
                                  ),
                                ),

                                // Badge Kategori
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color:
                                        categoryColor.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    task.category,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: categoryColor,
                                    ),
                                  ),
                                ),

                                // Badge Prioritas
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color:
                                        priorityColor.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 5,
                                        height: 5,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: priorityColor,
                                        ),
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        task.priority.label,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: priorityColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Tenggat Waktu
                                if (task.dueDate != null)
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.access_time_rounded,
                                        size: 12,
                                        color: _isOverdue
                                            ? AppTheme.priorityUrgent
                                            : (isDark
                                                ? Colors.white60
                                                : const Color(0xFF64748B)),
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        _formatDueDate(task.dueDate!),
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: _isOverdue
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          color: _isOverdue
                                              ? AppTheme.priorityUrgent
                                              : (isDark
                                                  ? Colors.white60
                                                  : const Color(0xFF64748B)),
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Popup Menu
                      PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_vert_rounded,
                          size: 20,
                          color: isDark ? Colors.white54 : Colors.black45,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        onSelected: (value) {
                          if (value == 'edit') {
                            widget.onEdit();
                          } else if (value == 'delete') {
                            widget.onDelete();
                          } else if (value == 'pin') {
                            context.read<TaskProvider>().togglePin(task.id);
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'pin',
                            child: Row(
                              children: [
                                Icon(
                                  task.isPinned
                                      ? Icons.push_pin_outlined
                                      : Icons.push_pin_rounded,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(task.isPinned
                                    ? 'Lepas Sematan'
                                    : 'Sematkan ke Atas'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit_outlined, size: 18),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline,
                                    size: 18, color: AppTheme.priorityUrgent),
                                SizedBox(width: 8),
                                Text('Hapus',
                                    style: TextStyle(
                                        color: AppTheme.priorityUrgent)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Subtasks expandable view
                  if (task.totalSubtasksCount > 0) ...[
                    const Divider(height: 18),
                    InkWell(
                      onTap: () => setState(() => _isExpanded = !_isExpanded),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.checklist_rounded,
                              size: 16,
                              color: AppTheme.primarySeed,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${task.completedSubtasksCount}/${task.totalSubtasksCount} Sub-tugas',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primarySeed,
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              _isExpanded
                                  ? Icons.keyboard_arrow_up_rounded
                                  : Icons.keyboard_arrow_down_rounded,
                              size: 18,
                              color: isDark ? Colors.white60 : Colors.black54,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_isExpanded) ...[
                      const SizedBox(height: 6),
                      ...task.subtasks.map((st) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 12, bottom: 4),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 22,
                                height: 22,
                                child: Checkbox(
                                  value: st.isCompleted,
                                  onChanged: (_) {
                                    context
                                        .read<TaskProvider>()
                                        .toggleSubtask(task.id, st.id);
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  st.title,
                                  style: TextStyle(
                                    fontSize: 12,
                                    decoration: st.isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                    color: st.isCompleted
                                        ? (isDark
                                            ? Colors.white38
                                            : Colors.black38)
                                        : null,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
