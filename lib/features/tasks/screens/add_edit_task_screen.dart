import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../models/subtask_model.dart';
import '../models/task_model.dart';

class AddEditTaskScreen extends StatefulWidget {
  final TaskModel? existingTask;
  final TaskStatus? initialStatus;

  const AddEditTaskScreen({
    super.key,
    this.existingTask,
    this.initialStatus,
  });

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  final TextEditingController _subtaskInputController =
      TextEditingController();

  late String _selectedCategory;
  late TaskStatus _selectedStatus;
  late TaskPriority _selectedPriority;
  DateTime? _selectedDueDate;
  bool _isPinned = false;
  late List<SubTaskModel> _subtasks;

  @override
  void initState() {
    super.initState();
    final task = widget.existingTask;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descController = TextEditingController(text: task?.description ?? '');
    _selectedCategory = task?.category ?? 'Coding';
    _selectedStatus =
        task?.status ?? widget.initialStatus ?? TaskStatus.todo;
    _selectedPriority = task?.priority ?? TaskPriority.medium;
    _selectedDueDate = task?.dueDate;
    _isPinned = task?.isPinned ?? false;
    _subtasks = task != null ? List.from(task.subtasks) : [];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _subtaskInputController.dispose();
    super.dispose();
  }

  void _addSubtask() {
    final text = _subtaskInputController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _subtasks.add(
          SubTaskModel(
            id: const Uuid().v4(),
            title: text,
            isCompleted: false,
          ),
        );
        _subtaskInputController.clear();
      });
    }
  }

  void _removeSubtask(int index) {
    setState(() {
      _subtasks.removeAt(index);
    });
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final initial = _selectedDueDate ?? now;
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );

    if (pickedDate != null) {
      if (!mounted) return;
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: _selectedDueDate != null
            ? TimeOfDay.fromDateTime(_selectedDueDate!)
            : const TimeOfDay(hour: 12, minute: 0),
      );

      setState(() {
        if (pickedTime != null) {
          _selectedDueDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        } else {
          _selectedDueDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            23,
            59,
          );
        }
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final isEdit = widget.existingTask != null;
    final task = TaskModel(
      id: isEdit ? widget.existingTask!.id : const Uuid().v4(),
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      category: _selectedCategory,
      status: _selectedStatus,
      priority: _selectedPriority,
      dueDate: _selectedDueDate,
      isPinned: _isPinned,
      subtasks: _subtasks,
      createdAt: isEdit ? widget.existingTask!.createdAt : DateTime.now(),
    );

    Navigator.of(context).pop(task);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingTask != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Tugas' : 'Tambah Tugas Baru'),
        actions: [
          TextButton.icon(
            onPressed: _submit,
            icon: const Icon(Icons.check_rounded, color: AppTheme.primarySeed),
            label: Text(
              'Simpan',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isDark ? Colors.white : AppTheme.primarySeed,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        physics: const BouncingScrollPhysics(),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Field Judul
              const Text(
                'Judul Tugas *',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                autofocus: !isEdit,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  hintText: 'Misal: Selesaikan audit modul security',
                  prefixIcon: Icon(Icons.title_rounded),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Judul tugas tidak boleh kosong';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Status Kanban (To Do, In Progress, In Review, Done)
              const Text(
                'Status Papan Kanban',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                children: TaskStatus.values.map((status) {
                  final isSelected = _selectedStatus == status;
                  final sColor = AppTheme.getStatusColor(status);

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: InkWell(
                        onTap: () => setState(() => _selectedStatus = status),
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? sColor.withValues(alpha: 0.15)
                                : (isDark
                                    ? const Color(0xFF1E293B)
                                    : Colors.white),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? sColor
                                  : (isDark
                                      ? const Color(0xFF334155)
                                      : const Color(0xFFE2E8F0)),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              status.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                color: isSelected
                                    ? sColor
                                    : (isDark
                                        ? Colors.white70
                                        : const Color(0xFF475569)),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // Prioritas (Low, Medium, High, Urgent)
              const Text(
                'Tingkat Prioritas',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                children: TaskPriority.values.map((priority) {
                  final isSelected = _selectedPriority == priority;
                  final pColor = AppTheme.getPriorityColor(priority);

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: InkWell(
                        onTap: () =>
                            setState(() => _selectedPriority = priority),
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? pColor.withValues(alpha: 0.15)
                                : (isDark
                                    ? const Color(0xFF1E293B)
                                    : Colors.white),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? pColor
                                  : (isDark
                                      ? const Color(0xFF334155)
                                      : const Color(0xFFE2E8F0)),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: pColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                priority.label,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? pColor
                                      : (isDark
                                          ? Colors.white70
                                          : const Color(0xFF475569)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // Kategori
              const Text(
                'Kategori / Label',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AppConstants.defaultCategories.map((category) {
                  final isSelected = _selectedCategory == category;
                  final catColor = AppTheme.getCategoryColor(category);

                  return ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    selectedColor: catColor,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : (isDark
                              ? Colors.white70
                              : const Color(0xFF334155)),
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                    backgroundColor:
                        isDark ? const Color(0xFF1E293B) : Colors.white,
                    side: BorderSide(
                      color: isSelected
                          ? catColor
                          : (isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFFE2E8F0)),
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedCategory = category);
                      }
                    },
                    showCheckmark: false,
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // Tenggat Waktu (Due Date)
              const Text(
                'Tenggat Waktu (Deadline)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFE2E8F0)),
                ),
                child: ListTile(
                  leading: const Icon(Icons.calendar_today_rounded,
                      color: AppTheme.primarySeed),
                  title: Text(
                    _selectedDueDate == null
                        ? 'Pilih Tanggal & Waktu'
                        : DateFormat('EEEE, d MMM yyyy - HH:mm')
                            .format(_selectedDueDate!),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: _selectedDueDate != null
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: _selectedDueDate == null
                          ? (isDark ? Colors.white38 : Colors.black38)
                          : (isDark ? Colors.white : const Color(0xFF0F172A)),
                    ),
                  ),
                  trailing: _selectedDueDate != null
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 20),
                          onPressed: () =>
                              setState(() => _selectedDueDate = null),
                        )
                      : null,
                  onTap: _pickDueDate,
                ),
              ),

              const SizedBox(height: 20),

              // Pin Tugas Switch
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Sematkan Tugas ke Atas (Pin)',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                subtitle: const Text(
                  'Tugas yang disematkan akan selalu berada di urutan teratas.',
                  style: TextStyle(fontSize: 12),
                ),
                value: _isPinned,
                activeTrackColor: AppTheme.primarySeed,
                onChanged: (val) => setState(() => _isPinned = val),
              ),

              const SizedBox(height: 20),

              // Checklist Sub-tugas
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Checklist Sub-tugas',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${_subtasks.where((s) => s.isCompleted).length}/${_subtasks.length} Selesai',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white60 : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Subtasks list
              ...List.generate(_subtasks.length, (index) {
                final subtask = _subtasks[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Checkbox(
                        value: subtask.isCompleted,
                        onChanged: (val) {
                          setState(() {
                            _subtasks[index] =
                                subtask.copyWith(isCompleted: val ?? false);
                          });
                        },
                      ),
                      Expanded(
                        child: Text(
                          subtask.title,
                          style: TextStyle(
                            decoration: subtask.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            color: subtask.isCompleted
                                ? (isDark ? Colors.white38 : Colors.black38)
                                : null,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        onPressed: () => _removeSubtask(index),
                      ),
                    ],
                  ),
                );
              }),

              // Input Tambah Subtask
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _subtaskInputController,
                      decoration: const InputDecoration(
                        hintText: 'Tambah langkah sub-tugas...',
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                      onSubmitted: (_) => _addSubtask(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.primarySeed,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.add_rounded),
                    onPressed: _addSubtask,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Field Deskripsi
              const Text(
                'Deskripsi / Catatan Tambahan',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descController,
                maxLines: 3,
                textInputAction: TextInputAction.newline,
                decoration: const InputDecoration(
                  hintText: 'Tuliskan detail tugas atau petunjuk pengerjaan...',
                  alignLabelWithHint: true,
                ),
              ),

              const SizedBox(height: 36),

              // Tombol Simpan
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.save_rounded),
                  label: Text(
                    isEdit ? 'Perbarui Tugas' : 'Simpan Tugas Baru',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.primarySeed,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
