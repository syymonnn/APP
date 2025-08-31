class Habit {
  final String title;
  final String category;
  String notificationTime; // in HH:mm format
  final String evidence;
  bool completed;
  bool notify;
  int timesPerDay;
  int timesCompletedToday;

  Habit({
    required this.title,
    required this.category,
    required this.notificationTime,
    required this.evidence,
    this.completed = false,
    this.notify = true,
    this.timesPerDay = 1,
    this.timesCompletedToday = 0,
  });

  /// Unique key for storage
  String get key => title;

  /// Convert habit to a map for persistence
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category': category,
      'notificationTime': notificationTime,
      'evidence': evidence,
      'completed': completed,
      'notify': notify,
      'timesPerDay': timesPerDay,
      'timesCompletedToday': timesCompletedToday,
    };
  }

  /// Create a Habit from a map
  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      title: map['title'] as String,
      category: map['category'] as String,
      notificationTime: map['notificationTime'] as String,
      evidence: map['evidence'] as String,
      completed: map['completed'] as bool? ?? false,
      notify: map['notify'] as bool? ?? true,
      timesPerDay: map['timesPerDay'] as int? ?? 1,
      timesCompletedToday: map['timesCompletedToday'] as int? ?? 0,
    );
  }
}