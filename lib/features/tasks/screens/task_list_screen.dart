import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/theme_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../widgets/dashboard_stats_card.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/filter_sort_bar.dart';
import '../widgets/task_item_card.dart';
import 'add_edit_task_screen.dart';
import 'settings_screen.dart';
import 'task_detail_sheet.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openAddTask(BuildContext context) async {
    final newTask = await Navigator.of(context).push<TaskModel>(
      MaterialPageRoute(
        builder: (_) => const AddEditTaskScreen(),
      ),
    );

    if (newTask != null && context.mounted) {
      context.read<TaskProvider>().addTask(newTask);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tugas "${newTask.title}" berhasil ditambahkan!'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tugas "${updatedTask.title}" berhasil diperbarui!'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
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

  void _deleteTaskWithUndo(BuildContext context, TaskModel task) {
    final taskProvider = context.read<TaskProvider>();
    taskProvider.deleteTask(task.id);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${task.title}" dihapus'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
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
    final themeProvider = context.watch<ThemeProvider>();
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filteredTasks = taskProvider.filteredTasks;
    final hasSearchOrFilter = _searchController.text.isNotEmpty ||
        taskProvider.selectedCategory != null ||
        taskProvider.selectedPriority != null;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.check_circle_outline_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              AppConstants.appName,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          // Toggle Mode Gelap / Terang
          IconButton(
            tooltip: isDark ? 'Mode Terang' : 'Mode Gelap',
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color:
                  isDark ? const Color(0xFFFBBF24) : const Color(0xFF475569),
            ),
            onPressed: () {
              themeProvider.toggleTheme(!isDark);
            },
          ),
          // Profile Avatar / Settings Button
          IconButton(
            tooltip: 'Pengaturan & Profil',
            icon: Text(
              user?.avatar ?? '⚙️',
              style: const TextStyle(fontSize: 18),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: taskProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await taskProvider.loadTasks();
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  // Kartu Statistik Ringkasan
                  const SliverToBoxAdapter(
                    child: DashboardStatsCard(),
                  ),

                  // Bar Pencarian & Filter & Sort
                  SliverToBoxAdapter(
                    child: FilterSortBar(
                      searchController: _searchController,
                    ),
                  ),

                  const SliverToBoxAdapter(
                    child: SizedBox(height: 12),
                  ),

                  // Daftar Tugas / Tampilan Kosong
                  if (filteredTasks.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: EmptyStateWidget(
                        filterStatus: taskProvider.filterStatus,
                        hasSearchOrFilter: hasSearchOrFilter,
                        onAddTask: () => _openAddTask(context),
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final task = filteredTasks[index];
                          return TaskItemCard(
                            task: task,
                            onToggle: () =>
                                taskProvider.toggleTaskCompletion(task.id),
                            onEdit: () => _openEditTask(context, task),
                            onDelete: () =>
                                _deleteTaskWithUndo(context, task),
                            onTap: () => _showDetailSheet(context, task),
                          );
                        },
                        childCount: filteredTasks.length,
                      ),
                    ),

                  const SliverToBoxAdapter(
                    child: SizedBox(height: 80),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddTask(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Tugas Baru',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
