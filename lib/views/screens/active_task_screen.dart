import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_theme.dart';
import '../../viewmodels/task_viewmodel.dart';
import '../../widgets/task_item.dart'; // Import ini sudah benar

class ActiveTaskScreen extends StatelessWidget {
  const ActiveTaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      // Consumer untuk otomatis mereload layar ini kalau ada tugas baru yang ditambahkan
      child: Consumer<TaskViewModel>(
        builder: (context, taskViewModel, child) {
          // Tampilkan animasi loading saat mengambil data dari Supabase
          if (taskViewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            );
          }

          final activeTasks = taskViewModel.activeTasks;

          return Column(
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: AppTheme.mainGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x220A192F),
                      blurRadius: 16,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white24,
                      child: Icon(
                        Icons.task_alt_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${activeTasks.length} tugas aktif',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 17,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Fokus ke tugas yang belum selesai.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: activeTasks.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 34,
                                backgroundColor: AppTheme.secondary.withOpacity(
                                  0.16,
                                ),
                                child: const Icon(
                                  Icons.assignment_turned_in_rounded,
                                  size: 36,
                                  color: AppTheme.primary,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Tidak ada tugas aktif',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Mantap! Semua sudah beres. Kalau ada tugas baru, tinggal tambahkan dari tombol +.',
                                style: TextStyle(color: Colors.grey[600]),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    : Padding(
                        padding: taskViewModel.isGridView
                            ? const EdgeInsets.symmetric(
                                horizontal: 6.0,
                                vertical: 8.0,
                              )
                            : const EdgeInsets.all(12.0),
                        child: taskViewModel.isGridView
                            ? GridView.builder(
                                physics: const BouncingScrollPhysics(),
                                gridDelegate:
                                    SliverGridDelegateWithMaxCrossAxisExtent(
                                      maxCrossAxisExtent:
                                          MediaQuery.of(context).size.width <
                                              600
                                          ? 200 // Mobile: 2 columns
                                          : 280, // Tablet+: 3-4 columns
                                      crossAxisSpacing: 8,
                                      mainAxisSpacing: 8,
                                      childAspectRatio: 0.78,
                                    ),
                                itemCount: activeTasks.length,
                                itemBuilder: (context, index) {
                                  return TaskItem(task: activeTasks[index]);
                                },
                              )
                            : ListView.separated(
                                physics: const BouncingScrollPhysics(),
                                itemCount: activeTasks.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 10),
                                itemBuilder: (context, index) {
                                  return TaskItem(task: activeTasks[index]);
                                },
                              ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
