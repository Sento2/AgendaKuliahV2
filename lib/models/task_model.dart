class Task {
  int? id;
  String title;
  String course;
  String deadline;
  int priority;
  bool done;
  String description;
  int userId;

  Task({
    this.id,
    required this.title,
    required this.course,
    required this.deadline,
    required this.priority,
    this.done = false,
    required this.description,
    required this.userId,
  });

  String get priorityLabel {
    switch (priority) {
      case 3:
        return "Tinggi";
      case 2:
        return "Sedang";
      default:
        return "Rendah";
    }
  }

  // Supabase menerima JSON, jadi kita biarkan 'done' sebagai boolean
  Map<String, dynamic> toMap() {
    return {
      // id biasanya di-generate otomatis oleh Supabase, jadi bisa diabaikan saat insert
      if (id != null) 'id': id,
      'title': title,
      'course': course,
      'deadline': deadline,
      'priority': priority,
      'is_done': done, // Gunakan is_done untuk match dengan column di Supabase
      'description': description,
      'user_id':
          userId, // Pastikan nama kolom di tabel Supabase-mu adalah user_id
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      course: map['course'],
      deadline: map['deadline'],
      priority: map['priority'],
      done:
          map['is_done'] ?? false, // Baca dari is_done, default false jika null
      description: map['description'],
      userId: map['user_id'],
    );
  }
}
