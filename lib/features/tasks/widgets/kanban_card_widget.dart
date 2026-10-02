import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../models/task_model.dart';

class KanbanCardWidget extends StatelessWidget {
  final TaskModel task;
  final Function(TaskStatus) onMoveStatus;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const KanbanCardWidget({
    super.key,
    required this.task,
    required this.onMoveStatus,
    required this.onEdit,
    required this.onDelete,
    required this.onTap,
  });

  bool get _isOverdue {
    if (task.dueDate == null || task.status == TaskStatus.done) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate =
        DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
    return targetDate.isBefore(today);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final priorityColor = AppTheme.getPriorityColor(task.priority);
    final categoryColor = AppTheme.getCategoryColor(task.category);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: task.isPinned
              ? AppTheme.primarySeed.withValues(alpha: 0.6)
              : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          width: task.isPinned ? 1.5 : 1,
        ),
      ),
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Tag (Kategori & Pinned & Menu)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: categoryColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          task.category,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: categoryColor,
                          ),
                        ),
                      ),
                      if (task.isPinned) ...[
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.push_pin_rounded,
                          size: 14,
                          color: AppTheme.primarySeed,
                        ),
                      ],
                    ],
                  ),

                  // Menu Aksi Pindah Kolom & Edit
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_horiz_rounded,
                      size: 20,
                      color: isDark ? Colors.white54 : Colors.black45,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onSelected: (action) {
                      if (action == 'edit') {
                        onEdit();
                      } else if (action == 'delete') {
                        onDelete();
                      } else if (action == 'to_todo') {
                        onMoveStatus(TaskStatus.todo);
                      } else if (action == 'to_progress') {
                        onMoveStatus(TaskStatus.inProgress);
                      } else if (action == 'to_review') {
                        onMoveStatus(TaskStatus.inReview);
                      } else if (action == 'to_done') {
                        onMoveStatus(TaskStatus.done);
                      }
                    },
                    itemBuilder: (context) => [
                      if (task.status != TaskStatus.todo)
                        const PopupMenuItem(
                          value: 'to_todo',
                          child: Row(
                            children: [
                              Icon(Icons.radio_button_unchecked, size: 18),
                              SizedBox(width: 8),
                              Text('Pindah ke To Do'),
                            ],
                          ),
                        ),
                      if (task.status != TaskStatus.inProgress)
                        const PopupMenuItem(
                          value: 'to_progress',
                          child: Row(
                            children: [
                              Icon(Icons.timelapse_rounded,
                                  size: 18, color: Colors.blue),
                              SizedBox(width: 8),
                              Text('Pindah ke In Progress'),
                            ],
                          ),
                        ),
                      if (task.status != TaskStatus.inReview)
                        const PopupMenuItem(
                          value: 'to_review',
                          child: Row(
                            children: [
                              Icon(Icons.rate_review_outlined,
                                  size: 18, color: Colors.purple),
                              SizedBox(width: 8),
                              Text('Pindah ke In Review'),
                            ],
                          ),
                        ),
                      if (task.status != TaskStatus.done)
                        const PopupMenuItem(
                          value: 'to_done',
                          child: Row(
                            children: [
                              Icon(Icons.check_circle_outline,
                                  size: 18, color: Colors.green),
                              SizedBox(width: 8),
                              Text('Pindah ke Done'),
                            ],
                          ),
                        ),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined, size: 18),
                            SizedBox(width: 8),
                            Text('Edit Tugas'),
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

              const SizedBox(height: 8),

              // Judul Tugas
              Text(
                task.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  decoration: task.isCompleted
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                  color: task.isCompleted
                      ? (isDark ? Colors.white38 : Colors.black38)
                      : (isDark ? Colors.white : const Color(0xFF0F172A)),
                ),
              ),

              // Deskripsi
              if (task.description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  task.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white60 : const Color(0xFF64748B),
                  ),
                ),
              ],

              // Subtasks Progress
              if (task.totalSubtasksCount > 0) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      Icons.checklist_rounded,
                      size: 15,
                      color: isDark ? Colors.white54 : const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${task.completedSubtasksCount}/${task.totalSubtasksCount} Sub-tugas',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color:
                            isDark ? Colors.white54 : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: task.subtasksProgress,
                          minHeight: 5,
                          backgroundColor:
                              isDark ? Colors.white12 : Colors.black12,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            task.subtasksProgress == 1.0
                                ? AppTheme.statusDone
                                : AppTheme.primarySeed,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 12),

              // Footer: Prioritas & Deadline
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: priorityColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: priorityColor,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          task.priority.label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: priorityColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (task.dueDate != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 12,
                          color: _isOverdue
                              ? AppTheme.priorityUrgent
                              : (isDark
                                  ? Colors.white60
                                  : const Color(0xFF64748B)),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('d MMM').format(task.dueDate!),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: _isOverdue
                                ? FontWeight.bold
                                : FontWeight.w500,
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
      ),
    );
  }
}
