import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../models/task_model.dart';
import 'kanban_card_widget.dart';

class KanbanColumnWidget extends StatelessWidget {
  final TaskStatus status;
  final List<TaskModel> tasks;
  final Function(String taskId, TaskStatus newStatus) onTaskDropped;
  final Function(TaskModel task) onEditTask;
  final Function(TaskModel task) onDeleteTask;
  final Function(TaskModel task) onTapTask;
  final VoidCallback onAddTaskInColumn;

  const KanbanColumnWidget({
    super.key,
    required this.status,
    required this.tasks,
    required this.onTaskDropped,
    required this.onEditTask,
    required this.onDeleteTask,
    required this.onTapTask,
    required this.onAddTaskInColumn,
  });

  IconData get _statusIcon {
    switch (status) {
      case TaskStatus.todo:
        return Icons.radio_button_unchecked_rounded;
      case TaskStatus.inProgress:
        return Icons.timelapse_rounded;
      case TaskStatus.inReview:
        return Icons.rate_review_outlined;
      case TaskStatus.done:
        return Icons.check_circle_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = AppTheme.getStatusColor(status);

    return DragTarget<TaskModel>(
      onWillAcceptWithDetails: (details) => details.data.status != status,
      onAcceptWithDetails: (details) {
        onTaskDropped(details.data.id, status);
      },
      builder: (context, candidateData, rejectedData) {
        final isHovered = candidateData.isNotEmpty;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isHovered
                ? statusColor.withValues(alpha: 0.12)
                : (isDark
                    ? const Color(0xFF1E293B).withValues(alpha: 0.6)
                    : const Color(0xFFF1F5F9)),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isHovered
                  ? statusColor
                  : (isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFE2E8F0)),
              width: isHovered ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Kolom
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(_statusIcon, color: statusColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        status.label,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${tasks.length}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_rounded, size: 22),
                    tooltip: 'Tambah di ${status.label}',
                    onPressed: onAddTaskInColumn,
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Daftar Kartu Tugas
              Expanded(
                child: tasks.isEmpty
                    ? Center(
                        child: Text(
                          'Tarik tugas ke sini atau\ntekan + untuk menambah',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white38 : Colors.black38,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: tasks.length,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          final task = tasks[index];

                          return LongPressDraggable<TaskModel>(
                            data: task,
                            feedback: Material(
                              elevation: 8,
                              borderRadius: BorderRadius.circular(14),
                              color: Colors.transparent,
                              child: ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxWidth: 280),
                                child: KanbanCardWidget(
                                  task: task,
                                  onMoveStatus: (_) {},
                                  onEdit: () {},
                                  onDelete: () {},
                                  onTap: () {},
                                ),
                              ),
                            ),
                            childWhenDragging: Opacity(
                              opacity: 0.35,
                              child: KanbanCardWidget(
                                task: task,
                                onMoveStatus: (s) =>
                                    onTaskDropped(task.id, s),
                                onEdit: () => onEditTask(task),
                                onDelete: () => onDeleteTask(task),
                                onTap: () => onTapTask(task),
                              ),
                            ),
                            child: KanbanCardWidget(
                              task: task,
                              onMoveStatus: (s) =>
                                    onTaskDropped(task.id, s),
                              onEdit: () => onEditTask(task),
                              onDelete: () => onDeleteTask(task),
                              onTap: () => onTapTask(task),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
