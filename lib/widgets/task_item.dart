import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/task_model.dart';
import '../../viewmodels/task_viewmodel.dart';
import '../../core/constants/app_theme.dart';
import 'task_dialog.dart';

class TaskItem extends StatelessWidget {
  final Task task;

  const TaskItem({super.key, required this.task});

  // Fungsi untuk menentukan warna garis atas berdasarkan level prioritas
  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 3:
        return Colors.red; // Tinggi
      case 2:
        return Colors.orange; // Sedang
      default:
        return Colors.green; // Rendah
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceTint = isDark ? AppTheme.darkCard : Colors.white;
    final primaryText = theme.colorScheme.onSurface;

    return Card(
      elevation: 12,
      shadowColor: AppTheme.primary.withOpacity(0.12),
      margin: const EdgeInsets.all(6.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      clipBehavior: Clip.antiAlias,
      color: surfaceTint,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 7,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_getPriorityColor(task.priority), AppTheme.primary],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppTheme.primary.withOpacity(0.12),
                      child: Text(
                        task.title.isNotEmpty
                            ? task.title[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              decoration: task.done
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: primaryText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: [
                              _buildChip(
                                task.priorityLabel,
                                _priorityBackground(task.priority, isDark),
                                isDark ? Colors.white : AppTheme.primary,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: task.done
                            ? Colors.green.withOpacity(0.12)
                            : Colors.grey.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        task.done
                            ? Icons.check_circle_rounded
                            : Icons.pending_actions_rounded,
                        size: 18,
                        color: task.done ? Colors.green : Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_month_rounded,
                      size: 15,
                      color: Colors.redAccent.shade200,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        task.deadline,
                        style: TextStyle(
                          color: Colors.redAccent.shade200,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                if (task.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.shade50,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      task.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 10, height: 1.1),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 4,
                  runSpacing: 2,
                  children: [
                    if (!task.done)
                      _iconButton(
                        icon: Icons.check_circle_rounded,
                        color: Colors.green,
                        onPressed: () {
                          context.read<TaskViewModel>().markAsDone(task);
                        },
                      ),
                    _iconButton(
                      icon: Icons.edit_rounded,
                      color: Colors.blue,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => TaskDialog(existingTask: task),
                        );
                      },
                    ),
                    _iconButton(
                      icon: Icons.delete_rounded,
                      color: Colors.red,
                      onPressed: () {
                        context.read<TaskViewModel>().deleteTask(task.id!);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, Color backgroundColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Color _priorityBackground(int priority, bool isDark) {
    switch (priority) {
      case 3:
        return isDark
            ? Colors.red.withOpacity(0.18)
            : Colors.red.withOpacity(0.10);
      case 2:
        return isDark
            ? Colors.orange.withOpacity(0.18)
            : Colors.orange.withOpacity(0.12);
      default:
        return isDark
            ? Colors.green.withOpacity(0.18)
            : Colors.green.withOpacity(0.12);
    }
  }

  Widget _iconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}
