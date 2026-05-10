import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../../models/task_model.dart';
import '../../models/user_model.dart';

class SupabaseService {
  // Inisialisasi client Supabase
  final _supabase = Supabase.instance.client;

  // 1. REGISTER USER
  Future<bool> registerUser(
    String username,
    String password,
    String email,
  ) async {
    try {
      await _supabase.from('users').insert({
        'username': username,
        'password': password,
        'email': email,
      });
      return true;
    } catch (e) {
      print('Error Register: $e');
      return false;
    }
  }

  // 2. CHECK LOGIN
  Future<User?> checkLogin(String username, String password) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('username', username)
          .eq('password', password)
          .maybeSingle(); // Mengambil satu baris data jika cocok

      if (response != null) {
        return User.fromMap(response);
      }
      return null;
    } catch (e) {
      print('Error Login: $e');
      return null;
    }
  }

  // 3. ADD TASK
  Future<bool> addTask(Task task) async {
    try {
      print('Adding task: ${task.toMap()}'); // Debug
      await _supabase.from('tasks').insert(task.toMap());
      print('Task added successfully!'); // Debug
      return true;
    } catch (e) {
      print('Error Add Task: $e');
      return false;
    }
  }

  // 4. GET ACTIVE & DONE TASKS
  Future<List<Task>> getActiveTasks(int userId) async {
    return _getTasksByStatus(userId, false);
  }

  Future<List<Task>> getDoneTasks(int userId) async {
    return _getTasksByStatus(userId, true);
  }

  // Fungsi helper internal untuk mengambil task berdasarkan status
  Future<List<Task>> _getTasksByStatus(int userId, bool isDone) async {
    try {
      print('Fetching tasks: userId=$userId, isDone=$isDone');
      final List<dynamic> response = await _supabase
          .from('tasks')
          .select()
          .eq('user_id', userId)
          .eq('is_done', isDone)
          .order('priority', ascending: false); // Menggantikan DESC di SQLite

      print('Fetched ${response.length} tasks');
      return response.map((taskMap) => Task.fromMap(taskMap)).toList();
    } catch (e) {
      print('Error Get Tasks: $e');
      return [];
    }
  }

  // 5. UPDATE TASK
  Future<bool> updateTask(Task task) async {
    try {
      await _supabase.from('tasks').update(task.toMap()).eq('id', task.id!);
      return true;
    } catch (e) {
      print('Error Update Task: $e');
      return false;
    }
  }

  // 6. DELETE TASK
  Future<bool> deleteTask(int taskId) async {
    try {
      await _supabase.from('tasks').delete().eq('id', taskId);
      return true;
    } catch (e) {
      print('Error Delete Task: $e');
      return false;
    }
  }
}
