import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/habit.dart';
import '../services/notification_service.dart';

/// Provides access to the list of habits and handles persistence.
/// Extends ChangeNotifier so that UI widgets can listen for changes.
class HabitsRepository extends ChangeNotifier {
  final List<Habit> _habits = [];
  final NotificationService _notificationService;
  bool _initialized = false;

  HabitsRepository(this._notificationService);

  /// Initialize the repository: load default habits and saved state.
  Future<void> init() async {
    if (_initialized) return;
    // Define default habits. Evidence strings can be replaced with
    // summarized and more general descriptions to avoid overstating claims.
    final defaultHabits = [
      Habit(
        title: 'Meditazione di 5 minuti prima di dormire',
        category: 'Sleep',
        notificationTime: '21:00',
        evidence:
            'Riduce lo stress e favorisce il sonno profondo (ricerca recente)',
      ),
      Habit(
        title: 'Doccia fredda di 1 minuto',
        category: 'Cold',
        notificationTime: '07:00',
        evidence:
            'Può aumentare vigilanza e energia mattutina (studi osservazionali)',
      ),
      Habit(
        title: 'Assumi 500mg di magnesio',
        category: 'Longevity',
        notificationTime: '20:00',
        evidence: 'Il magnesio contribuisce a regolazione del sonno e relax',
      ),
      Habit(
        title: 'Cammina 10k passi',
        category: 'Performance',
        notificationTime: '09:00',
        evidence: 'L’attività fisica regolare migliora energia e umore',
      ),
      Habit(
        title: 'Esercizio mindfulness 10min',
        category: 'Brain',
        notificationTime: '12:00',
        evidence: 'La mindfulness aiuta concentrazione e chiarezza mentale',
      ),
      Habit(
        title: 'Tecnica di respiro',
        category: 'Resilience',
        notificationTime: '18:00',
        evidence: 'Esercizi di respiro migliorano la gestione dello stress',
      ),
    ];
    // Initialize the list with default habits
    _habits.addAll(defaultHabits);
    // Load saved state
    final prefs = await SharedPreferences.getInstance();
    for (final habit in _habits) {
      habit.completed = prefs.getBool('${habit.key}_completed') ?? false;
      habit.notify = prefs.getBool('${habit.key}_notify') ?? true;
      habit.notificationTime =
          prefs.getString('${habit.key}_time') ?? habit.notificationTime;
      habit.timesPerDay = prefs.getInt('${habit.key}_timesPerDay') ?? 1;
      habit.timesCompletedToday =
          prefs.getInt('${habit.key}_timesCompletedToday') ?? 0;
    }
    // Schedule notifications for all habits
    for (var i = 0; i < _habits.length; i++) {
      final habit = _habits[i];
      if (habit.notify) {
        await _notificationService.scheduleDailyNotification(habit, i);
      }
    }
    _initialized = true;
    notifyListeners();
  }

  /// Expose an unmodifiable list to consumers
  UnmodifiableListView<Habit> get habits => UnmodifiableListView(_habits);

  /// Get habits filtered by category
  List<Habit> habitsByCategory(String category) {
    return _habits.where((h) => h.category == category).toList();
  }

  /// Toggle completion of a habit. Increments timesCompletedToday and sets
  /// completed when timesCompletedToday reaches timesPerDay.
  Future<void> toggleCompletion(Habit habit) async {
    habit.timesCompletedToday++;
    if (habit.timesCompletedToday >= habit.timesPerDay) {
      habit.completed = true;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('${habit.key}_completed', habit.completed);
    await prefs.setInt('${habit.key}_timesCompletedToday',
        habit.timesCompletedToday);
  }

  /// Reset a habit’s completion for a new day. Should be called daily.
  Future<void> resetDaily() async {
    for (final habit in _habits) {
      habit.completed = false;
      habit.timesCompletedToday = 0;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('${habit.key}_completed', habit.completed);
      await prefs.setInt('${habit.key}_timesCompletedToday', 0);
    }
    notifyListeners();
  }

  /// Toggle notifications for a habit and reschedule or cancel
  Future<void> toggleNotification(Habit habit) async {
    habit.notify = !habit.notify;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('${habit.key}_notify', habit.notify);
    final id = _habits.indexOf(habit);
    if (habit.notify) {
      await _notificationService.scheduleDailyNotification(habit, id);
    } else {
      await _notificationService.cancel(id);
    }
    notifyListeners();
  }

  /// Update the notification time for a habit
  Future<void> updateNotificationTime(Habit habit, String newTime) async {
    habit.notificationTime = newTime;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${habit.key}_time', newTime);
    final id = _habits.indexOf(habit);
    // Reschedule
    if (habit.notify) {
      await _notificationService.scheduleDailyNotification(habit, id);
    }
    notifyListeners();
  }

  /// Update the number of times per day a habit must be done
  Future<void> updateTimesPerDay(Habit habit, int times) async {
    habit.timesPerDay = times;
    habit.timesCompletedToday = 0;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('${habit.key}_timesPerDay', times);
    await prefs.setInt('${habit.key}_timesCompletedToday', 0);
    notifyListeners();
  }

  /// Compute completion percentage across all habits
  double get completionPercentage {
    final total = _habits.length;
    final completed = _habits.where((h) => h.completed).length;
    return total == 0 ? 0 : (completed / total) * 100;
  }
}