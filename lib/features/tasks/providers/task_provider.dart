import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/theme/app_theme.dart';
import '../models/subtask_model.dart';
import '../models/task_model.dart';

enum TaskFilterStatus { all, todo, inProgress, inReview, done }

enum TaskSortOption {
  dueDateNearest,
  dueDateFarthest,
  priorityHighest,
  priorityLowest,
  newest,
  oldest,
  alphabetical;

  String get label {
    switch (this) {
      case TaskSortOption.dueDateNearest:
        return 'Tenggat Waktu Terdekat';
      case TaskSortOption.dueDateFarthest:
        return 'Tenggat Waktu Terjauh';
      case TaskSortOption.priorityHighest:
        return 'Prioritas Tertinggi (Urgent)';
      case TaskSortOption.priorityLowest:
        return 'Prioritas Terendah';
      case TaskSortOption.newest:
        return 'Terbaru Dibuat';
      case TaskSortOption.oldest:
        return 'Terlama Dibuat';
      case TaskSortOption.alphabetical:
        return 'Alfabetis (A - Z)';
    }
  }
}

class TaskProvider extends ChangeNotifier {
  final StorageService _storageService;

  List<TaskModel> _tasks = [];
  bool _isLoading = true;

  TaskFilterStatus _filterStatus = TaskFilterStatus.all;
  TaskSortOption _sortOption = TaskSortOption.dueDateNearest;
  String _searchQuery = '';
  String? _selectedCategory;
  TaskPriority? _selectedPriority;
  int _streakDays = 7;

  TaskProvider(this._storageService) {
    loadTasks();
    _loadStreak();
  }

  // Getters
  bool get isLoading => _isLoading;
  TaskFilterStatus get filterStatus => _filterStatus;
  TaskSortOption get sortOption => _sortOption;
  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;
  TaskPriority? get selectedPriority => _selectedPriority;
  int get streakDays => _streakDays;

  List<TaskModel> get allTasks => List.unmodifiable(_tasks);

  // Kanban Columns
  List<TaskModel> tasksByStatus(TaskStatus status) {
    return _tasks.where((t) => t.status == status).toList();
  }

  // Analytics Metrics
  int get totalTasksCount => _tasks.length;
  int get todoCount => tasksByStatus(TaskStatus.todo).length;
  int get inProgressCount => tasksByStatus(TaskStatus.inProgress).length;
  int get inReviewCount => tasksByStatus(TaskStatus.inReview).length;
  int get doneCount => tasksByStatus(TaskStatus.done).length;

  double get completionRate =>
      _tasks.isEmpty ? 0.0 : (doneCount / totalTasksCount);

  int get overdueTasksCount {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _tasks.where((t) {
      if (t.status == TaskStatus.done || t.dueDate == null) return false;
      final due = DateTime(t.dueDate!.year, t.dueDate!.month, t.dueDate!.day);
      return due.isBefore(today);
    }).length;
  }

  Map<TaskPriority, int> get priorityBreakdown {
    final Map<TaskPriority, int> map = {
      TaskPriority.urgent: 0,
      TaskPriority.high: 0,
      TaskPriority.medium: 0,
      TaskPriority.low: 0,
    };
    for (final task in _tasks) {
      map[task.priority] = (map[task.priority] ?? 0) + 1;
    }
    return map;
  }

  Map<String, int> get categoryBreakdown {
    final Map<String, int> map = {};
    for (final task in _tasks) {
      map[task.category] = (map[task.category] ?? 0) + 1;
    }
    return map;
  }

  /// List View: Filtered & Sorted Tasks
  List<TaskModel> get filteredTasks {
    final list = _tasks.where((task) {
      // 1. Filter Status
      switch (_filterStatus) {
        case TaskFilterStatus.todo:
          if (task.status != TaskStatus.todo) return false;
          break;
        case TaskFilterStatus.inProgress:
          if (task.status != TaskStatus.inProgress) return false;
          break;
        case TaskFilterStatus.inReview:
          if (task.status != TaskStatus.inReview) return false;
          break;
        case TaskFilterStatus.done:
          if (task.status != TaskStatus.done) return false;
          break;
        case TaskFilterStatus.all:
          break;
      }

      // 2. Filter Kategori
      if (_selectedCategory != null &&
          _selectedCategory != 'Semua' &&
          task.category != _selectedCategory) {
        return false;
      }

      // 3. Filter Prioritas
      if (_selectedPriority != null && task.priority != _selectedPriority) {
        return false;
      }

      // 4. Filter Pencarian
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchTitle = task.title.toLowerCase().contains(query);
        final matchDesc = task.description.toLowerCase().contains(query);
        final matchCat = task.category.toLowerCase().contains(query);
        if (!matchTitle && !matchDesc && !matchCat) return false;
      }

      return true;
    }).toList();

    // Sorting
    list.sort((a, b) {
      // Pinned selalu paling atas
      if (a.isPinned != b.isPinned) {
        return a.isPinned ? -1 : 1;
      }

      switch (_sortOption) {
        case TaskSortOption.dueDateNearest:
          if (a.dueDate != null && b.dueDate != null) {
            return a.dueDate!.compareTo(b.dueDate!);
          } else if (a.dueDate != null) {
            return -1;
          } else if (b.dueDate != null) {
            return 1;
          }
          return b.createdAt.compareTo(a.createdAt);

        case TaskSortOption.dueDateFarthest:
          if (a.dueDate != null && b.dueDate != null) {
            return b.dueDate!.compareTo(a.dueDate!);
          } else if (a.dueDate != null) {
            return -1;
          } else if (b.dueDate != null) {
            return 1;
          }
          return b.createdAt.compareTo(a.createdAt);

        case TaskSortOption.priorityHighest:
          return b.priority.index.compareTo(a.priority.index);

        case TaskSortOption.priorityLowest:
          return a.priority.index.compareTo(b.priority.index);

        case TaskSortOption.newest:
          return b.createdAt.compareTo(a.createdAt);

        case TaskSortOption.oldest:
          return a.createdAt.compareTo(b.createdAt);

        case TaskSortOption.alphabetical:
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
      }
    });

    return list;
  }

  Future<void> _loadStreak() async {
    _streakDays = await _storageService.loadStreak();
    notifyListeners();
  }

  Future<void> loadTasks() async {
    _isLoading = true;
    notifyListeners();

    _tasks = await _storageService.loadTasks();

    if (_tasks.isEmpty) {
      _tasks = [
        TaskModel(
          id: const Uuid().v4(),
          title: 'Implementasi UI Kanban Enterprise',
          description: 'Selesaikan 4 kolom (To Do, In Progress, In Review, Done) dengan drag and drop.',
          category: 'Coding',
          status: TaskStatus.inProgress,
          priority: TaskPriority.urgent,
          dueDate: DateTime.now().add(const Duration(days: 1)),
          isPinned: true,
          subtasks: [
            SubTaskModel(id: 's1', title: 'Buat KanbanColumnWidget', isCompleted: true),
            SubTaskModel(id: 's2', title: 'Konfigurasi DragTarget interaktif', isCompleted: true),
            SubTaskModel(id: 's3', title: 'Tambahkan Review workflow', isCompleted: false),
          ],
        ),
        TaskModel(
          id: const Uuid().v4(),
          title: 'Review Modul Keamanan & Auth',
          description: 'Pastikan penyimpanan profil lokal dan token terisolasi secara aman.',
          category: 'Kerja',
          status: TaskStatus.inReview,
          priority: TaskPriority.high,
          dueDate: DateTime.now().add(const Duration(days: 2)),
          subtasks: [
            SubTaskModel(id: 's4', title: 'Audit SQLite schema', isCompleted: true),
            SubTaskModel(id: 's5', title: 'Testing SharedPreferences fallback', isCompleted: true),
          ],
        ),
        TaskModel(
          id: const Uuid().v4(),
          title: 'Persiapan Ujian Kecerdasan Buatan',
          description: 'Pelajari konsep neural networks dan decision tree algoritma.',
          category: 'Sekolah',
          status: TaskStatus.todo,
          priority: TaskPriority.medium,
          dueDate: DateTime.now().add(const Duration(days: 4)),
        ),
        TaskModel(
          id: const Uuid().v4(),
          title: 'Meditasi & Olahraga Pagi',
          description: 'Latihan peregangan 20 menit dan jalan santai.',
          category: 'Personal',
          status: TaskStatus.done,
          priority: TaskPriority.low,
          dueDate: DateTime.now(),
        ),
      ];
      await _storageService.saveTasks(_tasks);
    }

    _isLoading = false;
    notifyListeners();
  }

  // Filter & Sort Setters
  void setFilterStatus(TaskFilterStatus status) {
    _filterStatus = status;
    notifyListeners();
  }

  void setSortOption(TaskSortOption option) {
    _sortOption = option;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSelectedPriority(TaskPriority? priority) {
    _selectedPriority = priority;
    notifyListeners();
  }

  // CRUD Operations
  Future<void> addTask(TaskModel task) async {
    _tasks.add(task);
    await _storageService.saveTasks(_tasks);
    notifyListeners();
  }

  Future<void> updateTask(TaskModel updatedTask) async {
    final index = _tasks.indexWhere((task) => task.id == updatedTask.id);
    if (index != -1) {
      _tasks[index] = updatedTask;
      await _storageService.saveTasks(_tasks);
      notifyListeners();
    }
  }

  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((task) => task.id == id);
    await _storageService.saveTasks(_tasks);
    notifyListeners();
  }

  Future<void> togglePin(String id) async {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(isPinned: !_tasks[index].isPinned);
      await _storageService.saveTasks(_tasks);
      notifyListeners();
    }
  }

  Future<void> updateTaskStatus(String id, TaskStatus newStatus) async {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(status: newStatus);
      await _storageService.saveTasks(_tasks);
      notifyListeners();
    }
  }

  Future<void> toggleTaskCompletion(String id) async {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      final current = _tasks[index];
      final newStatus =
          current.status == TaskStatus.done ? TaskStatus.todo : TaskStatus.done;
      _tasks[index] = current.copyWith(status: newStatus);
      await _storageService.saveTasks(_tasks);
      notifyListeners();
    }
  }

  Future<void> toggleSubtask(String taskId, String subtaskId) async {
    final taskIndex = _tasks.indexWhere((t) => t.id == taskId);
    if (taskIndex != -1) {
      final task = _tasks[taskIndex];
      final updatedSubtasks = task.subtasks.map((st) {
        if (st.id == subtaskId) {
          return st.copyWith(isCompleted: !st.isCompleted);
        }
        return st;
      }).toList();

      _tasks[taskIndex] = task.copyWith(subtasks: updatedSubtasks);
      await _storageService.saveTasks(_tasks);
      notifyListeners();
    }
  }

  Future<void> clearCompletedTasks() async {
    _tasks.removeWhere((t) => t.status == TaskStatus.done);
    await _storageService.saveTasks(_tasks);
    notifyListeners();
  }

  // Backup & Export / Import
  String exportJson() {
    return _storageService.exportTasksToJson(_tasks);
  }

  Future<bool> importJson(String jsonString) async {
    final imported = _storageService.importTasksFromJson(jsonString);
    if (imported != null && imported.isNotEmpty) {
      _tasks = imported;
      await _storageService.saveTasks(_tasks);
      notifyListeners();
      return true;
    }
    return false;
  }

  String generateFormattedShareText() {
    final buffer = StringBuffer();
    buffer.writeln('📋 *Daftar Tugas (${DateFormat('d MMM yyyy').format(DateTime.now())})*');
    buffer.writeln('Total: ${_tasks.length} | Selesai: $doneCount');
    buffer.writeln('----------------------------------');

    for (final task in _tasks) {
      final statusIcon = task.isCompleted ? '✅' : '⏳';
      final priorityEmoji = task.priority == TaskPriority.urgent
          ? '🔴'
          : task.priority == TaskPriority.high
              ? '🟠'
              : '🟢';
      buffer.writeln('$statusIcon $priorityEmoji *${task.title}* [${task.category}]');
      if (task.description.isNotEmpty) {
        buffer.writeln('   _${task.description}_');
      }
      if (task.dueDate != null) {
        buffer.writeln('   📅 Deadline: ${DateFormat('d MMM yyyy').format(task.dueDate!)}');
      }
      buffer.writeln('');
    }
    buffer.writeln('Dikelola dengan TugasKu Enterprise.');
    return buffer.toString();
  }
}
