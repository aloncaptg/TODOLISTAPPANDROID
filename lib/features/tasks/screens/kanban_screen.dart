import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../widgets/kanban_column_widget.dart';
import 'add_edit_task_screen.dart';
import 'task_detail_sheet.dart';

class KanbanScreen extends StatefulWidget {
  const KanbanScreen({super.key});

  @override
  State<KanbanScreen> createState() => _KanbanScreenState();
}

class _KanbanScreenState extends State<KanbanScreen> {
  late PageController _pageController;
  int _selectedTabIndex = 0;

  final List<TaskStatus> _columns = [
    TaskStatus.todo,
    TaskStatus.inProgress,
    TaskStatus.inReview,
    TaskStatus.done,
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.9);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _openAddTask(BuildContext context,
      {TaskStatus initialStatus = TaskStatus.todo}) async {
    final newTask = await Navigator.of(context).push<TaskModel>(
      MaterialPageRoute(
        builder: (_) => AddEditTaskScreen(initialStatus: initialStatus),
      ),
    );

    if (newTask != null && context.mounted) {
      context.read<TaskProvider>().addTask(newTask);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Tugas "${newTask.title}" ditambahkan ke ${newTask.status.label}!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _openEditTask(BuildContext context, TaskModel task) async {
    final updatedTask = await Navigator.of(context).push<TaskModel>(
      MaterialPageRoute(
        builder: (_) => AddEditTaskScreen(existingTask: task),
      ),
    );

    if (updatedTask != null && context.mounted) {
      context.read<TaskProvider>().updateTask(updatedTask);
    }
  }

  void _showDetailSheet(BuildContext context, TaskModel task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TaskDetailSheet(task: task),
    );
  }

  void _deleteTask(BuildContext context, TaskModel task) {
    final taskProvider = context.read<TaskProvider>();
    taskProvider.deleteTask(task.id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${task.title}" dihapus'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'BATALKAN',
          textColor: const Color(0xFF38BDF8),
          onPressed: () {
            taskProvider.addTask(task);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kanban Board'),
        actions: [
          IconButton(
            tooltip: 'Tambah Tugas',
            icon: const Icon(Icons.add_task_rounded),
            onPressed: () => _openAddTask(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Segmented 4 Tab Status Switcher
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1E293B)
                  : const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: List.generate(_columns.length, (index) {
                final colStatus = _columns[index];
                final isSelected = _selectedTabIndex == index;
                final colTasks = taskProvider.tasksByStatus(colStatus);
                final statusColor = AppTheme.getStatusColor(colStatus);

                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _selectedTabIndex = index);
                      _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark ? const Color(0xFF334155) : Colors.white)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : [],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: statusColor,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${colTasks.length}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: statusColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            colStatus.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: isSelected
                                  ? (isDark
                                      ? Colors.white
                                      : const Color(0xFF0F172A))
                                  : (isDark
                                      ? Colors.white60
                                      : const Color(0xFF64748B)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          // Papan Kolom Kanban PageView
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _columns.length,
              onPageChanged: (index) {
                setState(() => _selectedTabIndex = index);
              },
              itemBuilder: (context, index) {
                final status = _columns[index];
                final tasks = taskProvider.tasksByStatus(status);

                return KanbanColumnWidget(
                  status: status,
                  tasks: tasks,
                  onTaskDropped: (taskId, newStatus) {
                    taskProvider.updateTaskStatus(taskId, newStatus);
                  },
                  onEditTask: (task) => _openEditTask(context, task),
                  onDeleteTask: (task) => _deleteTask(context, task),
                  onTapTask: (task) => _showDetailSheet(context, task),
                  onAddTaskInColumn: () =>
                      _openAddTask(context, initialStatus: status),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
