import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../models/subtask_model.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import 'add_edit_task_screen.dart';

class TaskDetailSheet extends StatefulWidget {
  final TaskModel task;

  const TaskDetailSheet({super.key, required this.task});

  @override
  State<TaskDetailSheet> createState() => _TaskDetailSheetState();
}

class _TaskDetailSheetState extends State<TaskDetailSheet> {
  final _newSubtaskController = TextEditingController();

  @override
  void dispose() {
    _newSubtaskController.dispose();
    super.dispose();
  }

  void _addSubtask(BuildContext context) {
    final text = _newSubtaskController.text.trim();
    if (text.isEmpty) return;

    final taskProvider = context.read<TaskProvider>();
    final task = taskProvider.allTasks.firstWhere(
      (t) => t.id == widget.task.id,
      orElse: () => widget.task,
    );

    taskProvider.updateTask(
      task.copyWith(
        subtasks: [
          ...task.subtasks,
          task.subtasks.isEmpty
              ? SubTaskModel(id: 'st-1', title: text)
              : SubTaskModel(
                  id: 'st-${task.subtasks.length + 1}', title: text),
        ],
      ),
    );
    _newSubtaskController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final task = taskProvider.allTasks.firstWhere(
      (t) => t.id == widget.task.id,
      orElse: () => widget.task,
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = AppTheme.getStatusColor(task.status);
    final priorityColor = AppTheme.getPriorityColor(task.priority);
    final categoryColor = AppTheme.getCategoryColor(task.category);

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Drag handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header Bar with Actions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: categoryColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            task.category,
                            style: TextStyle(
                              color: categoryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: priorityColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Prioritas ${task.priority.label}',
                            style: TextStyle(
                              color: priorityColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          tooltip: 'Edit Tugas',
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () async {
                            Navigator.of(context).pop();
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    AddEditTaskScreen(existingTask: task),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          tooltip: 'Tutup',
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Divider(),

              // Konten Detail
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  children: [
                    // Judul Tugas
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Selector Status Cepat
                    Row(
                      children: [
                        const Text(
                          'Status: ',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<TaskStatus>(
                              value: task.status,
                              isDense: true,
                              items: TaskStatus.values.map((s) {
                                return DropdownMenuItem(
                                  value: s,
                                  child: Text(
                                    s.label,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.getStatusColor(s),
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  taskProvider.updateTaskStatus(task.id, val);
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Deadline Info
                    if (task.dueDate != null) ...[
                      Row(
                        children: [
                          const Icon(Icons.calendar_month_rounded,
                              size: 18, color: AppTheme.primarySeed),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat('EEEE, d MMMM yyyy - HH:mm')
                                .format(task.dueDate!),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Deskripsi
                    if (task.description.isNotEmpty) ...[
                      const Text(
                        'Deskripsi / Catatan:',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF0F172A)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          task.description,
                          style: const TextStyle(fontSize: 14, height: 1.4),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Checklist Sub-tugas
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Checklist Sub-tugas',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${task.completedSubtasksCount}/${task.totalSubtasksCount} Selesai',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white60 : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Progress bar subtasks
                    if (task.totalSubtasksCount > 0) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: task.subtasksProgress,
                          minHeight: 6,
                          backgroundColor:
                              isDark ? Colors.white12 : Colors.black12,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.statusDone),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Subtasks items
                    ...task.subtasks.map((st) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Checkbox(
                              value: st.isCompleted,
                              onChanged: (_) {
                                taskProvider.toggleSubtask(task.id, st.id);
                              },
                            ),
                            Expanded(
                              child: Text(
                                st.title,
                                style: TextStyle(
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

                    // Input Cepat Tambah Subtask
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _newSubtaskController,
                            decoration: const InputDecoration(
                              hintText: 'Tambah langkah sub-tugas...',
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                            ),
                            onSubmitted: (_) => _addSubtask(context),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          style: IconButton.styleFrom(
                              backgroundColor: AppTheme.primarySeed),
                          icon: const Icon(Icons.add_rounded),
                          onPressed: () => _addSubtask(context),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
