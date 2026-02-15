import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../providers/task_provider.dart';
import '../widgets/duck_mascot.dart';
import '../widgets/task_card.dart';
import '../widgets/progress_ring.dart';
import '../widgets/confetti_overlay.dart';
import '../widgets/streak_badge.dart';
import '../models/task.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskList = ref.watch(taskListProvider);
    final completedTasks = taskList.where((t) => t.isCompleted).toList();
    final pendingTasks = taskList.where((t) => !t.isCompleted).toList();
    final progress = ref.watch(taskProgressProvider);
    final allDone = ref.watch(allTasksDoneProvider);
    final streak = ref.watch(streakProvider);

    return Scaffold(
      backgroundColor: AppTheme.creamBackground,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTaskDialog(context, ref),
        label: Text(
          'New Task',
          style: GoogleFonts.fredoka(fontWeight: FontWeight.w600),
        ),
        icon: const Icon(Icons.add),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Greeting Header ──
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Builder(builder: (context) {
                                    final user = FirebaseAuth.instance.currentUser;
                                    final displayName = user?.displayName ?? 
                                                      (user?.email != null ? user!.email!.split('@')[0] : 'User');
                                    final name = displayName.isNotEmpty 
                                        ? displayName[0].toUpperCase() + displayName.substring(1)
                                        : 'User';
                                    
                                    return Text(
                                      'Hello, $name 👋',
                                      style: AppTheme.headingStyle.copyWith(fontSize: 24),
                                    );
                                  }),
                                  const SizedBox(height: 4),
                                  Text(
                                    _getGreetingText(),
                                    style: AppTheme.bodyStyle,
                                  ),
                                ],
                              ),
                            ),
                            // Streak badge next to profile
                            Row(
                              children: [
                                StreakBadge(streak: streak),
                                const SizedBox(width: 12),
                                PopupMenuButton(
                                  child: const CircleAvatar(
                                    backgroundColor: AppTheme.accentYellow,
                                    child: Icon(Icons.person, color: AppTheme.brownOutline),
                                  ),
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'logout',
                                      child: Row(
                                        children: [
                                          Icon(Icons.logout, color: Colors.red),
                                          SizedBox(width: 8),
                                          Text('Sign Out', style: TextStyle(color: Colors.red)),
                                        ],
                                      ),
                                    ),
                                  ],
                                  onSelected: (value) async {
                                    if (value == 'logout') {
                                      await FirebaseAuth.instance.signOut();
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),

                        // ── Duck Mascot Area with Progress Ring ──
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withValues(alpha: 0.5),
                                Colors.white.withValues(alpha: 0.2),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.8),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            children: [
                              // Duck inside Progress Ring
                              ProgressRing(
                                progress: progress,
                                child: const DuckMascot(),
                              ),
                              const SizedBox(height: 12),
                              // Progress Text
                              Text(
                                '${completedTasks.length} / ${taskList.length} tasks done',
                                style: AppTheme.bodyStyle.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Mood Message Bubble
                              Consumer(
                                builder: (context, ref, _) {
                                  final mood = ref.watch(duckMoodProvider);
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.05),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      _getMoodMessage(mood),
                                      style: AppTheme.subheadingStyle.copyWith(fontSize: 14),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),

                        // ── Smart Suggestion ──
                        if (pendingTasks.isNotEmpty) _buildSmartSuggestion(pendingTasks),

                        // ── Tasks Header ──
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Today's Tasks", style: AppTheme.headingStyle),
                            if (taskList.isNotEmpty)
                              Text(
                                '${(progress * 100).toInt()}%',
                                style: GoogleFonts.fredoka(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.primaryGreen,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),

                // ── Empty State ──
                if (taskList.isEmpty)
                  SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: Column(
                          children: [
                            Icon(Icons.assignment_outlined,
                                size: 64, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            Text(
                              "No tasks yet!\nTap + to add your first task 🦆",
                              textAlign: TextAlign.center,
                              style: AppTheme.subheadingStyle.copyWith(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // ── Pending Tasks ──
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return TaskCard(
                          task: pendingTasks[index],
                          index: index,
                        );
                      },
                      childCount: pendingTasks.length,
                    ),
                  ),
                ),

                // ── Completed Tasks ──
                if (completedTasks.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_outline,
                              size: 18, color: Colors.green),
                          const SizedBox(width: 8),
                          Text(
                            "Completed (${completedTasks.length})",
                            style: AppTheme.subheadingStyle.copyWith(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return Opacity(
                            opacity: 0.55,
                            child: TaskCard(
                              task: completedTasks[index],
                              index: index,
                            ),
                          );
                        },
                        childCount: completedTasks.length,
                      ),
                    ),
                  ),
                ],

                // Bottom Padding for FAB
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),

          // ── Confetti Overlay ──
          Positioned.fill(
            child: ConfettiOverlay(trigger: allDone),
          ),
        ],
      ),
    );
  }

  String _getGreetingText() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning! Ready to crush it? ☀️';
    if (hour < 17) return 'Good afternoon! Keep the momentum! 🚀';
    return 'Good evening! Finish strong tonight! 🌙';
  }

  String _getMoodMessage(DuckMood mood) {
    switch (mood) {
      case DuckMood.party:
        return "Woohoo! All tasks done! 🎉🔥";
      case DuckMood.cool:
        return "Looking great! Keep it up! 😎";
      case DuckMood.sleepy:
        return "Zzz... Let's get started! 😴";
      default:
        return "Let's get quacking! 🦆";
    }
  }

  Widget _buildSmartSuggestion(List<Task> pendingTasks) {
    // Find lowest energy task for "low energy" suggestion
    final sortedByEnergy = List<Task>.from(pendingTasks)
      ..sort((a, b) => a.energyLevel.compareTo(b.energyLevel));
    final easiest = sortedByEnergy.first;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.accentYellow.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.accentYellow.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          children: [
            const Text('💡', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Smart Tip',
                    style: GoogleFonts.fredoka(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.brownOutline,
                    ),
                  ),
                  Text(
                    'Low energy? Start with "${easiest.title}"',
                    style: AppTheme.bodyStyle.copyWith(fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddTaskSheet(),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Add Task Bottom Sheet (with Category selector)
// ─────────────────────────────────────────────────────────
class AddTaskSheet extends ConsumerStatefulWidget {
  const AddTaskSheet({Key? key}) : super(key: key);

  @override
  ConsumerState<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends ConsumerState<AddTaskSheet> {
  final _titleController = TextEditingController();
  TaskPriority _selectedPriority = TaskPriority.medium;
  int _energyLevel = 2;
  String _selectedCategory = 'General';
  DateTime? _selectedDueDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'New Task 🦆',
                  style: AppTheme.headingStyle.copyWith(fontSize: 24),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Title Input
            TextField(
              controller: _titleController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: "What needs to be done?",
                hintStyle: GoogleFonts.baloo2(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                prefixIcon: const Icon(Icons.edit_outlined, color: Colors.grey),
              ),
              style: GoogleFonts.baloo2(fontSize: 18),
            ),
            const SizedBox(height: 20),

            // Category Selector
            Text('Category', style: AppTheme.subheadingStyle.copyWith(fontSize: 16)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: TaskCategories.all.map((cat) {
                final isSelected = _selectedCategory == cat;
                final catColor = Color(TaskCategories.colors[cat] ?? 0xFF78909C);
                final emoji = TaskCategories.icons[cat] ?? '📋';
                return ChoiceChip(
                  label: Text('$emoji $cat'),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedCategory = cat);
                  },
                  selectedColor: catColor.withValues(alpha: 0.2),
                  labelStyle: TextStyle(
                    color: isSelected ? catColor : Colors.grey,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Priority Selector
            Text('Priority', style: AppTheme.subheadingStyle.copyWith(fontSize: 16)),
            const SizedBox(height: 10),
            Row(
              children: TaskPriority.values.map((priority) {
                final isSelected = _selectedPriority == priority;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: ChoiceChip(
                    label: Text(priority.name.toUpperCase()),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedPriority = priority);
                    },
                    selectedColor: AppTheme.primaryGreen.withValues(alpha: 0.2),
                    labelStyle: TextStyle(
                      color: isSelected ? AppTheme.primaryGreen : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Due Date / Reminder
            Text('Due Date', style: AppTheme.subheadingStyle.copyWith(fontSize: 16)),
            const SizedBox(height: 10),
            InkWell(
              onTap: _pickDateTime,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: _selectedDueDate != null
                          ? AppTheme.primaryGreen
                          : Colors.grey,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _selectedDueDate != null
                          ? '${_selectedDueDate!.day}/${_selectedDueDate!.month}/${_selectedDueDate!.year} at ${_selectedDueDate!.hour}:${_selectedDueDate!.minute.toString().padLeft(2, '0')}'
                          : 'Set Reminder',
                      style: GoogleFonts.baloo2(
                        fontSize: 16,
                        color: _selectedDueDate != null
                            ? Colors.black87
                            : Colors.grey,
                      ),
                    ),
                    if (_selectedDueDate != null) ...[
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () => setState(() => _selectedDueDate = null),
                      ),
                    ]
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Energy Level
            Text('Energy Level',
                style: AppTheme.subheadingStyle.copyWith(fontSize: 16)),
            Row(
              children: [
                const Icon(Icons.battery_1_bar, size: 16, color: Colors.grey),
                Expanded(
                  child: Slider(
                    value: _energyLevel.toDouble(),
                    min: 1,
                    max: 3,
                    divisions: 2,
                    label: _energyLevel == 1
                        ? "⚡ Low"
                        : _energyLevel == 2
                            ? "⚡⚡ Medium"
                            : "⚡⚡⚡ High",
                    activeColor: AppTheme.accentYellow,
                    thumbColor: AppTheme.brownOutline,
                    onChanged: (val) =>
                        setState(() => _energyLevel = val.toInt()),
                  ),
                ),
                const Icon(Icons.battery_full, size: 16, color: Colors.amber),
              ],
            ),
            const SizedBox(height: 28),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    ),
                  elevation: 0,
                ),
                child: Text(
                  'Add Task 🚀',
                  style: GoogleFonts.fredoka(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;

    setState(() {
      _selectedDueDate = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  void _submit() {
    if (_titleController.text.trim().isEmpty) return;

    ref.read(taskListProvider.notifier).addTask(
          _titleController.text.trim(),
          _selectedPriority,
          _energyLevel,
          category: _selectedCategory,
          dueDate: _selectedDueDate,
        );
    Navigator.pop(context);
  }
}
