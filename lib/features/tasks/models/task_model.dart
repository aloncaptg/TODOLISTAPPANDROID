import 'dart:convert';
import '../../../core/theme/app_theme.dart';
import 'subtask_model.dart';

/// Model data tugas untuk Enterprise Task Management (Todoist & Trello style)
class TaskModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final TaskStatus status;
  final TaskPriority priority;
  final DateTime? dueDate;
  final bool isPinned;
  final List<SubTaskModel> subtasks;
  final DateTime createdAt;

  TaskModel({
    required this.id,
    required this.title,
    this.description = '',
    required this.category,
    this.status = TaskStatus.todo,
    this.priority = TaskPriority.medium,
    this.dueDate,
    this.isPinned = false,
    List<SubTaskModel>? subtasks,
    DateTime? createdAt,
  })  : subtasks = subtasks ?? const [],
        createdAt = createdAt ?? DateTime.now();

  bool get isCompleted => status == TaskStatus.done;

  int get completedSubtasksCount =>
      subtasks.where((subtask) => subtask.isCompleted).length;

  int get totalSubtasksCount => subtasks.length;

  double get subtasksProgress => totalSubtasksCount == 0
      ? 0.0
      : completedSubtasksCount / totalSubtasksCount;

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    TaskStatus? status,
    TaskPriority? priority,
    DateTime? dueDate,
    bool? isPinned,
    List<SubTaskModel>? subtasks,
    DateTime? createdAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      isPinned: isPinned ?? this.isPinned,
      subtasks: subtasks ?? this.subtasks,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'status': status.name,
      'priority': priority.name,
      'dueDate': dueDate?.toIso8601String(),
      'isPinned': isPinned ? 1 : 0,
      'subtasks': json.encode(subtasks.map((s) => s.toMap()).toList()),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    TaskStatus parsedStatus = TaskStatus.todo;
    if (map['status'] != null) {
      parsedStatus = TaskStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => TaskStatus.todo,
      );
    } else if (map['isCompleted'] == true) {
      parsedStatus = TaskStatus.done;
    }

    List<SubTaskModel> parsedSubtasks = [];
    if (map['subtasks'] != null) {
      if (map['subtasks'] is String && (map['subtasks'] as String).isNotEmpty) {
        try {
          final List<dynamic> decoded = json.decode(map['subtasks'] as String);
          parsedSubtasks = decoded
              .map((item) => SubTaskModel.fromMap(item as Map<String, dynamic>))
              .toList();
        } catch (_) {}
      } else if (map['subtasks'] is List) {
        parsedSubtasks = (map['subtasks'] as List)
            .map((item) => SubTaskModel.fromMap(item as Map<String, dynamic>))
            .toList();
      }
    }

    return TaskModel(
      id: (map['id'] as String?) ?? '',
      title: (map['title'] as String?) ?? '',
      description: (map['description'] as String?) ?? '',
      category: (map['category'] as String?) ?? 'Lainnya',
      status: parsedStatus,
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == map['priority'],
        orElse: () => TaskPriority.medium,
      ),
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate'] as String) : null,
      isPinned: map['isPinned'] == 1 || map['isPinned'] == true,
      subtasks: parsedSubtasks,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory TaskModel.fromJson(String source) =>
      TaskModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
