import 'package:flutter/material.dart';
import '../data/services/supabase_service.dart';
import '../data/services/notification_service.dart';
import '../models/task_model.dart';

class TaskViewModel extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  final NotificationService _notificationService = NotificationService();

  // State variables (Pengganti MutableLiveData)
  List<Task> _activeTasks = [];
  List<Task> _doneTasks = [];
  bool _isGridView = false;
  int _currentUserId = -1;

  // Indikator loading agar UI tidak kaku saat nunggu balasan dari Supabase
  bool _isLoading = false;

  // Getters (Pengganti LiveData)
  List<Task> get activeTasks => _activeTasks;
  List<Task> get doneTasks => _doneTasks;
  bool get isGridView => _isGridView;
  bool get isLoading => _isLoading;

  // Set user ID dari login dan langsung panggil refreshTasks()
  void setUserId(int userId) {
    _currentUserId = userId;
    refreshTasks();
  }

  // Mengubah mode tampilan Grid/List
  void setLayoutMode(bool isGrid) {
    _isGridView = isGrid;
    notifyListeners(); // Pengganti isGridView.setValue(isGrid)
  }

  // Pengganti Executors untuk mengambil data dari Supabase
  Future<void> refreshTasks() async {
    if (_currentUserId == -1) {
      print('Error: User ID not set!');
      return;
    }

    _isLoading = true;
    notifyListeners();

    print('Refreshing tasks for user: $_currentUserId');
    _activeTasks = await _supabaseService.getActiveTasks(_currentUserId);
    _doneTasks = await _supabaseService.getDoneTasks(_currentUserId);
    print(
      'Active tasks: ${_activeTasks.length}, Done tasks: ${_doneTasks.length}',
    );

    _isLoading = false;
    notifyListeners();
  }

  // Tambah task baru
  Future<void> addTask(Task task) async {
    task.userId =
        _currentUserId; // pastikan userId sesuai dengan yang sedang login
    print('Adding task with userId: ${task.userId}');
    bool success = await _supabaseService.addTask(task);

    if (success) {
      print('Task added successfully, refreshing...');
      // Schedule notification untuk task baru
      await _notificationService.scheduleTaskNotifications(
        task,
        daysBeforeDeadline: [1, 3, 7],
      );
      await refreshTasks(); // Otomatis perbarui list setelah berhasil
    } else {
      print('Failed to add task');
    }
  }

  // Update task
  Future<void> updateTask(Task task) async {
    bool success = await _supabaseService.updateTask(task);
    if (success) {
      await refreshTasks();
    }
  }

  // Hapus task
  Future<void> deleteTask(int taskId) async {
    // Cancel notification saat task dihapus
    await _notificationService.cancelNotification(taskId);
    bool success = await _supabaseService.deleteTask(taskId);
    if (success) {
      await refreshTasks();
    }
  }

  // Tandai sebagai selesai
  Future<void> markAsDone(Task task) async {
    task.done = true; // Set nilai done jadi true
    await updateTask(task); // Panggil fungsi update
  }
}
