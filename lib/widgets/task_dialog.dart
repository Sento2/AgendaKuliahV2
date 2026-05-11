import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// --- POIN 1: IMPORT GOOGLE CALENDAR & NOTIFIKASI ---
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../data/services/notification_service.dart'; // <--- Tambahan import alarm
// ---------------------------------------------------

import '../../models/task_model.dart';
import '../../viewmodels/task_viewmodel.dart';
import '../../core/constants/app_theme.dart';

class TaskDialog extends StatefulWidget {
  // Jika ini null, berarti mode "Tambah Task". Jika ada isinya, berarti mode "Edit Task"
  final Task? existingTask;

  const TaskDialog({super.key, this.existingTask});

  @override
  State<TaskDialog> createState() => _TaskDialogState();
}

class _TaskDialogState extends State<TaskDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _courseController = TextEditingController();
  final TextEditingController _deadlineController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  int _selectedPriority = 2; // Default: 2 (Sedang)
  
  // Variabel baru untuk menyimpan format waktu asli buat Google Calendar
  DateTime? _selectedDateTime; 

  // Palet Warna dari AppTheme
  final Color navyBlue = AppTheme.primary;
  final Color softPink = AppTheme.secondary;

  @override
  void initState() {
    super.initState();
    // Jika ada data existingTask (Mode Edit), isi otomatis semua form-nya
    if (widget.existingTask != null) {
      _titleController.text = widget.existingTask!.title;
      _courseController.text = widget.existingTask!.course;
      _deadlineController.text = widget.existingTask!.deadline;
      _descController.text = widget.existingTask!.description;
      _selectedPriority = widget.existingTask!.priority;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _courseController.dispose();
    _deadlineController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // --- POIN 2: MESIN KALENDER (Disetel zona waktu WITA) ---
  Future<void> simpanKeKalender(String judulTugas, DateTime deadline) async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['https://www.googleapis.com/auth/calendar.events'],
      );

      // Cek sesi login
      final GoogleSignInAccount? currentUser = googleSignIn.currentUser ?? await googleSignIn.signInSilently();

      if (currentUser == null) {
        print("Gagal: User belum login Google!");
        return;
      }

      // Minta akses kalender
      final httpClient = await googleSignIn.authenticatedClient();
      if (httpClient == null) {
        print("Gagal mendapatkan akses client kalender.");
        return;
      }

      final calendarApi = calendar.CalendarApi(httpClient);

      // Format jadwal (Durasi 1 jam)
      final event = calendar.Event(
        summary: "Deadline: $judulTugas",
        description: "Tugas dicatat otomatis dari aplikasi Agenda Kuliah",
        start: calendar.EventDateTime(
          dateTime: deadline,
          timeZone: "Asia/Makassar", 
        ),
        end: calendar.EventDateTime(
          dateTime: deadline.add(const Duration(hours: 1)),
          timeZone: "Asia/Makassar",
        ),
      );

      // Tembak ke kalender utama
      await calendarApi.events.insert(event, "primary");
      print("MANTAP! Jadwal berhasil masuk Google Calendar!");

    } catch (e) {
      print("Waduh, error waktu nyimpan ke kalender: $e");
    }
  }
  // --------------------------------------------------------

  // Fungsi memunculkan kalender bawaan Material Design
  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: navyBlue, // Warna header kalender
              onPrimary: Colors.white,
              onSurface: navyBlue,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateTime = picked; // <--- Simpan format aslinya di sini
        _deadlineController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  // --- POIN 3: PANGGIL MESIN DI FUNGSI SIMPAN ---
  // Fungsi _saveTask kita ubah jadi 'async'
  void _saveTask() async { 
    // Validasi sederhana: Judul tidak boleh kosong
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Judul tugas wajib diisi!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Buat objek Task baru dari inputan
    final task = Task(
      id: widget.existingTask?.id,
      title: _titleController.text.trim(),
      course: _courseController.text.trim(),
      deadline: _deadlineController.text.trim(),
      priority: _selectedPriority,
      description: _descController.text.trim(),
      userId: widget.existingTask?.userId ?? 0, 
      done: widget.existingTask?.done ?? false,
    );

    // Kirim ke ViewModel
    if (widget.existingTask == null) {
      // 1. Simpan ke database lokal/Supabase
      context.read<TaskViewModel>().addTask(task);
      
      // 2. Tembak ke Google Calendar 
      DateTime waktuKalender = _selectedDateTime ?? DateTime.now();
      await simpanKeKalender(task.title, waktuKalender);
      
      // 3. PASANG ALARM NOTIFIKASI
      await NotificationService().scheduleTaskNotifications(task, daysBeforeDeadline: [1]);
      
      // 4. NOTIFIKASI INSTAN (Sebagai tanda berhasil saat itu juga)
      await NotificationService().showInstantNotification(
        title: "Tugas Berhasil Disimpan!",
        body: "Alarm disetel H-1 sebelum deadline ${task.title}",
      );

    } else {
      context.read<TaskViewModel>().updateTask(task);
      // Jika butuh update alarm saat edit, bisa dipanggil lagi di sini nanti
    }

    // Tutup dialog
    Navigator.pop(context);
  }
  // ----------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleColor = theme.colorScheme.onSurface;

    return AlertDialog(
      backgroundColor: theme.cardColor,
      shape: AppTheme.cardShape(radius: 20),
      // Mencegah overflow saat keyboard muncul dengan batas aman
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24), 
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 10, 8), // Sedikit digeser biar lonceng muat
      contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      title: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: softPink.withOpacity(0.18),
            child: Icon(
              widget.existingTask == null
                  ? Icons.add_task_rounded
                  : Icons.edit_rounded,
              size: 18,
              color: navyBlue,
            ),
          ),
          const SizedBox(width: 12),
          // BUNGKUS DENGAN EXPANDED AGAR TEKS TIDAK OVERFLOW KE KANAN
          Expanded(
            child: Text(
              widget.existingTask == null ? 'Tambah Tugas' : 'Edit Tugas',
              style: TextStyle(color: titleColor, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          // --- TAMBAHAN TOMBOL LONCENG DARURAT DI SINI BANG ---
          IconButton(
            icon: const Icon(Icons.notifications_active, color: Colors.amber, size: 24),
            onPressed: () async {
              await NotificationService().showInstantNotification(
                title: "TES ALARM MASUK!",
                body: "Halo haddy, notifikasi HP anda aman jaya!",
              );
            },
          ),
          // ----------------------------------------------------
        ],
      ),
      content: SingleChildScrollView(
        // Tambahan agar scroll empuk
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Judul Tugas
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Judul Tugas *',
                border: const OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: navyBlue),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 2. Mata Kuliah
            TextField(
              controller: _courseController,
              decoration: InputDecoration(
                labelText: 'Mata Kuliah',
                border: const OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: navyBlue),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 3. Deadline
            TextField(
              controller: _deadlineController,
              readOnly: true,
              onTap: _selectDate,
              decoration: InputDecoration(
                labelText: 'Deadline',
                border: const OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: navyBlue),
                ),
                suffixIcon: Icon(Icons.calendar_month, color: navyBlue),
              ),
            ),
            const SizedBox(height: 16),

            // 4. RadioGroup Prioritas
            const Text(
              'Prioritas:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            // GANTI ROW MENJADI WRAP AGAR OTOMATIS TURUN KALAU SEMPIT
            Wrap(
              spacing: 12,
              runSpacing: 4,
              children: [
                _buildRadio(1, 'Rendah'),
                _buildRadio(2, 'Sedang'),
                _buildRadio(3, 'Tinggi'),
              ],
            ),
            const SizedBox(height: 16),

            // 5. Deskripsi
            TextField(
              controller: _descController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Deskripsi (opsional)',
                alignLabelWithHint: true,
                border: const OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: navyBlue),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Batal',
            style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(minimumSize: const Size(104, 46)),
          onPressed: _saveTask,
          child: const Text(
            'Simpan',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  // Widget Helper untuk membuat Radio Button lebih rapi
  Widget _buildRadio(int value, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<int>(
          value: value,
          groupValue: _selectedPriority,
          activeColor: navyBlue,
          onChanged: (int? newValue) {
            setState(() {
              _selectedPriority = newValue!;
            });
          },
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}