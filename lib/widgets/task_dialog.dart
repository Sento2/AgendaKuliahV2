import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
      // Format tanggal sederhana: DD/MM/YYYY
      setState(() {
        _deadlineController.text =
            "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  void _saveTask() {
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
      id: widget.existingTask?.id, // Akan tetap null jika mode Add
      title: _titleController.text.trim(),
      course: _courseController.text.trim(),
      deadline: _deadlineController.text.trim(),
      priority: _selectedPriority,
      description: _descController.text.trim(),
      userId:
          widget.existingTask?.userId ??
          0, // 0 ini nanti akan ditimpa oleh ViewModel
      done: widget.existingTask?.done ?? false,
    );

    // Kirim ke ViewModel
    if (widget.existingTask == null) {
      context.read<TaskViewModel>().addTask(task);
    } else {
      context.read<TaskViewModel>().updateTask(task);
    }

    // Tutup dialog
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleColor = theme.colorScheme.onSurface;

    return AlertDialog(
      backgroundColor: theme.cardColor,
      shape: AppTheme.cardShape(radius: 20),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
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
          Text(
            widget.existingTask == null ? 'Tambah Tugas' : 'Edit Tugas',
            style: TextStyle(color: titleColor, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: SingleChildScrollView(
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

            // 3. Deadline (Mode ReadOnly + OnTap memunculkan kalender)
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
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
