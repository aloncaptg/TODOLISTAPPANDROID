import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/task_provider.dart';

class FilterSortBar extends StatelessWidget {
  final TextEditingController searchController;

  const FilterSortBar({
    super.key,
    required this.searchController,
  });

  void _showSortModal(BuildContext context) {
    final taskProvider = context.read<TaskProvider>();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(
                    'Urutkan Berdasarkan',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const Divider(),
                ...TaskSortOption.values.map((option) {
                  final isSelected = taskProvider.sortOption == option;
                  return ListTile(
                    leading: Icon(
                      isSelected
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: isSelected ? AppTheme.primarySeed : null,
                    ),
                    title: Text(
                      option.label,
                      style: TextStyle(
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? AppTheme.primarySeed : null,
                      ),
                    ),
                    onTap: () {
                      taskProvider.setSortOption(option);
                      Navigator.of(ctx).pop();
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final filterStatus = taskProvider.filterStatus;
    final selectedCategory = taskProvider.selectedCategory;
    final selectedPriority = taskProvider.selectedPriority;
    final currentSort = taskProvider.sortOption;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final categories = ['Semua', ...AppTheme.categoryColors.keys];

    return Column(
      children: [
        // Bar Pencarian & Tombol Sort
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: searchController,
                  onChanged: (val) => taskProvider.setSearchQuery(val),
                  decoration: InputDecoration(
                    hintText: 'Cari tugas atau deskripsi...',
                    hintStyle: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              searchController.clear();
                              taskProvider.setSearchQuery('');
                            },
                          )
                        : null,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Tombol Sortir Modal
              IconButton.filledTonal(
                tooltip: 'Urutkan: ${currentSort.label}',
                icon: const Icon(Icons.sort_rounded, size: 20),
                onPressed: () => _showSortModal(context),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Filter Status 5 Tab (Semua, To Do, In Progress, In Review, Done)
        SizedBox(
          height: 38,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            children: [
              _buildFilterStatusChip(
                context,
                label: 'Semua (${taskProvider.totalTasksCount})',
                isSelected: filterStatus == TaskFilterStatus.all,
                onTap: () =>
                    taskProvider.setFilterStatus(TaskFilterStatus.all),
              ),
              const SizedBox(width: 6),
              _buildFilterStatusChip(
                context,
                label: 'To Do (${taskProvider.todoCount})',
                isSelected: filterStatus == TaskFilterStatus.todo,
                color: AppTheme.statusTodo,
                onTap: () =>
                    taskProvider.setFilterStatus(TaskFilterStatus.todo),
              ),
              const SizedBox(width: 6),
              _buildFilterStatusChip(
                context,
                label: 'In Progress (${taskProvider.inProgressCount})',
                isSelected: filterStatus == TaskFilterStatus.inProgress,
                color: AppTheme.statusInProgress,
                onTap: () =>
                    taskProvider.setFilterStatus(TaskFilterStatus.inProgress),
              ),
              const SizedBox(width: 6),
              _buildFilterStatusChip(
                context,
                label: 'In Review (${taskProvider.inReviewCount})',
                isSelected: filterStatus == TaskFilterStatus.inReview,
                color: AppTheme.statusInReview,
                onTap: () =>
                    taskProvider.setFilterStatus(TaskFilterStatus.inReview),
              ),
              const SizedBox(width: 6),
              _buildFilterStatusChip(
                context,
                label: 'Done (${taskProvider.doneCount})',
                isSelected: filterStatus == TaskFilterStatus.done,
                color: AppTheme.statusDone,
                onTap: () =>
                    taskProvider.setFilterStatus(TaskFilterStatus.done),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Filter Kategori (Horizontal Scroll)
        SizedBox(
          height: 34,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (context, index) => const SizedBox(width: 6),
            itemBuilder: (context, index) {
              final cat = categories[index];
              final isCatSelected =
                  (selectedCategory == null && cat == 'Semua') ||
                      (selectedCategory == cat);

              return ChoiceChip(
                label: Text(
                  cat,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight:
                        isCatSelected ? FontWeight.bold : FontWeight.normal,
                    color: isCatSelected
                        ? Colors.white
                        : (isDark ? Colors.white70 : const Color(0xFF475569)),
                  ),
                ),
                selected: isCatSelected,
                selectedColor: AppTheme.primarySeed,
                backgroundColor:
                    isDark ? const Color(0xFF1E293B) : Colors.white,
                side: BorderSide(
                  color: isCatSelected
                      ? AppTheme.primarySeed
                      : (isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFE2E8F0)),
                ),
                onSelected: (selected) {
                  if (selected) {
                    taskProvider
                        .setSelectedCategory(cat == 'Semua' ? null : cat);
                  }
                },
                showCheckmark: false,
                padding: const EdgeInsets.symmetric(horizontal: 6),
              );
            },
          ),
        ),

        // Filter Prioritas jika ada filter
        if (selectedPriority != null) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'Prioritas: ${selectedPriority.label}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.getPriorityColor(selectedPriority),
                  ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () => taskProvider.setSelectedPriority(null),
                  child: const Icon(Icons.close_rounded, size: 16),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFilterStatusChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    Color? color,
    required VoidCallback onTap,
  }) {
    final chipColor = color ?? AppTheme.primarySeed;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? chipColor
              : (isDark ? const Color(0xFF1E293B) : Colors.white),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? chipColor
                : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected
                  ? Colors.white
                  : (isDark ? Colors.white70 : const Color(0xFF475569)),
            ),
          ),
        ),
      ),
    );
  }
}
